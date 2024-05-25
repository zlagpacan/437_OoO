/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: rob.sv
    Instantiation Hierarchy: system -> core -> rob
    Description: 
        The Reorder Buffer tracks dispatched instructions in a FIFO, checking for their completion so they
        can be retired.
        
        The Reorder Buffer also provides the mechanisms for rolling back mis-speculated instructions. This
        includes sending a checkpoint command to the dispatch_unit, and/or broadcasting to the kill bus.
            - if checkpoint successful, can kill in-order, not needing to pause
            - if checkpoint unsuccessful, need to pause while killing in reverse order

        The ROB interfaces with:

            - Fetch Unit
                - ROB gives restart PC

            - Dispatch Unit
                - ROB receives new instruction struct and valid for struct
                - ROB gives ROB index so on instr completion knows where to write
                - ROB gives retired phys reg tags which can safely be renamed to

            - Complete Buses 0,1,2
                - ROB receives complete @ ROB index
                - assign buses as follows:
                    - complete bus 0: ALU 0
                    - complete bus 1: ALU 1
                    - complete bus 2: LQ

            - Branch Resolution Unit
                - ROB receives complete @ ROB index
                - ROB receives restart info

            - Load Queue
                - ROB receives restart info
                - ROB sends retire to LQ so it can dequeue (and perform LL?)

            - Store Queue
                - ROB receives complete @ ROB index
                - ROB sends retire to SQ so it can dequeue and perform the store

            - Restore Bus
                - ROB sends restore command
                - also Core Control

            - Revert Bus
                - (was calling this the kill bus for the dispatch unit)
                - (goes to dispatch unit)
                - ROB sends revert command
                - also Core Control

            - Kill Bus
                - (goes to execution units)
                - ROB sends kill command
                - also Core Control

            - Core Control
                - ROB sends signals intended to flush or stall fetch and dispatch
                - ROB sends halt assertion
                    - when halt instr retires

        ROB depth will only matter if get more cycles in ROB (possible instr dispatches) than instr takes
        to execute. Worst case for 437, get new dispatch each cycle, wait for bus (15 cycles) + long 
        coherent bus (5 cycles) + full mem (10 cycles) + reg read cycle + complete cycle ~= 31 cycles. 
            - 32 should be enough for no delays in worst case.
            - 16 or even 8 should be plenty for common case no ROB stalls
*/

`include "core_types.vh"
import core_types_pkg::*;

module rob (

    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // full/empty
    output logic full,
    output logic empty,

    // fetch unit interface
    output logic fetch_unit_take_resolved,
    output pc_t fetch_unit_resolved_PC,

    // dispatch unit interface
    // dispatch @ tail
    output ROB_index_t dispatch_unit_ROB_tail_index,
    input logic dispatch_unit_enqueue_valid,
    input ROB_entry_t dispatch_unit_enqueue_struct,
    // retire from head
    output logic dispatch_unit_retire_valid,
    output phys_reg_tag_t dispatch_unit_retire_phys_reg_tag,
    
    // complete bus interfaces
        // want ROB index for complete write
        // ROB doesn't need write tag but can use for assertion
    input logic complete_bus_0_valid,
    input phys_reg_tag_t complete_bus_0_dest_phys_reg_tag,
    input ROB_index_t complete_bus_0_ROB_index,
    input logic complete_bus_1_valid,
    input phys_reg_tag_t complete_bus_1_dest_phys_reg_tag,
    input ROB_index_t complete_bus_1_ROB_index,
    input logic complete_bus_2_valid,
    input phys_reg_tag_t complete_bus_2_dest_phys_reg_tag,
    input ROB_index_t complete_bus_2_ROB_index,

    // BRU interface
    // complete
    input logic BRU_complete_valid,
    // input ROB_index_t BRU_complete_ROB_index,
    // restart info
    input logic BRU_restart_valid,
    input ROB_index_t BRU_restart_ROB_index,
    input pc_t BRU_restart_PC,
    input checkpoint_column_t BRU_restart_safe_column,

    // LQ interface
    // restart info
    input logic LQ_restart_valid,
    input logic LQ_restart_after_instr,
    input ROB_index_t LQ_restart_ROB_index,
    // retire
    output logic LQ_retire_valid,
    output ROB_index_t LQ_retire_ROB_index,
    input logic LQ_retire_blocked,

    // SQ interface
    // complete
    input logic SQ_complete_valid,
    input ROB_index_t SQ_complete_ROB_index,
    // retire
    output logic SQ_retire_valid,
    output ROB_index_t SQ_retire_ROB_index,
    input logic SQ_retire_blocked,

    // restore interface
        // send restore command and check for success
    output logic restore_checkpoint_valid,
    output logic restore_checkpoint_speculate_failed, // send successful one on BRU complete
    output ROB_index_t restore_checkpoint_ROB_index,
    output checkpoint_column_t restore_checkpoint_safe_column,
    input logic restore_checkpoint_success,

    // revert interface
        // send revert command to dispatch unit
    output logic revert_valid,
    output ROB_index_t revert_ROB_index,
    output arch_reg_tag_t revert_arch_reg_tag,
    output phys_reg_tag_t revert_safe_phys_reg_tag,
    output phys_reg_tag_t revert_speculated_phys_reg_tag,

    // kill bus interface
        // send kill command to execution units
    output logic kill_bus_valid,
    output ROB_index_t kill_bus_ROB_index,

    // core control interface
    output logic core_control_restore_flush,
    output logic core_control_revert_stall,
    output logic core_control_halt_assert,
        // for when halt instr retires

    // optional outputs:

    // ROB state
    output ROB_state_t ROB_state_out,

    // if complete is invalid
    output logic invalid_complete,

    // current ROB capacity
    output logic [LOG_ROB_DEPTH:0] ROB_capacity
);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT error:

    logic next_DUT_error;

    // seq + logic
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            DUT_error <= 1'b0;
        end
        else begin
            DUT_error <= next_DUT_error;
        end
    end
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ROB FIFO array:

    // array of ROB entries
    ROB_entry_t [ROB_DEPTH-1:0] ROB_array_by_entry, next_ROB_array_by_entry;

    // array pointers
    typedef struct packed {
        logic msb;
        logic [LOG_ROB_DEPTH-1:0] index;
    } ROB_ptr_t;
    // head
    ROB_ptr_t head_index_ptr;
    ROB_ptr_t next_head_index_ptr;
    // tail
    ROB_ptr_t tail_index_ptr;
    ROB_ptr_t next_tail_index_ptr;
    // restart info
    ROB_ptr_t restart_ROB_index_ptr;
    ROB_ptr_t next_restart_ROB_index_ptr;
    checkpoint_column_t restart_column;
    checkpoint_column_t next_restart_column;
    ROB_index_t inorder_kill_start_ROB_index;
    ROB_index_t next_inorder_kill_start_ROB_index;
    ROB_index_t inorder_kill_end_ROB_index;
    ROB_index_t next_inorder_kill_end_ROB_index;

    // full/empty
    logic next_full;
    logic next_empty;

    // ROB state
    ROB_state_t ROB_state, next_ROB_state;

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            ROB_array_by_entry <= '0;
                // could do custom for loop for each entry but should have valid == 0 so safe reset state
            ROB_state <= ROB_IDLE;
            head_index_ptr <= '0;
            tail_index_ptr <= '0;
            restart_ROB_index_ptr <= '0;
            restart_column <= '0;
            inorder_kill_start_ROB_index <= '0;
            inorder_kill_end_ROB_index <= '0;
            full <= 1'b0;
            empty <= 1'b1;  // start empty
        end
        else begin
            ROB_array_by_entry <= next_ROB_array_by_entry;
            ROB_state <= next_ROB_state;
            head_index_ptr <= next_head_index_ptr;
            tail_index_ptr <= next_tail_index_ptr;
            restart_ROB_index_ptr <= next_restart_ROB_index_ptr;
            inorder_kill_start_ROB_index <= next_inorder_kill_start_ROB_index;
            inorder_kill_end_ROB_index <= next_inorder_kill_end_ROB_index;
            restart_column <= next_restart_column;
            full <= next_full;
            empty <= next_empty;
        end
    end

    // comb logic
    always_comb begin

        //////////////////////
        // default outputs: //
        //////////////////////

        // no DUT error
        next_DUT_error = 1'b0;

        // hold state
        next_ROB_array_by_entry = ROB_array_by_entry;
        next_head_index_ptr = head_index_ptr;
        next_tail_index_ptr = tail_index_ptr;
        next_restart_ROB_index_ptr = restart_ROB_index_ptr;
        next_inorder_kill_start_ROB_index = inorder_kill_start_ROB_index;
        next_inorder_kill_end_ROB_index = inorder_kill_end_ROB_index;
        next_restart_column = restart_column;
        next_ROB_state = ROB_state;

        // connect tail
        dispatch_unit_ROB_tail_index = tail_index_ptr;

        // connect ROB state
        ROB_state_out = ROB_state;

        // no invalid complete
        invalid_complete = 1'b0;

        // ROB capacity = tail - head
        ROB_capacity = tail_index_ptr - head_index_ptr;

        // retire from head (unsuccessful)
        dispatch_unit_retire_valid = 1'b0;
        dispatch_unit_retire_phys_reg_tag = ROB_array_by_entry[head_index_ptr.index].safe_dest_phys_reg_tag;
        LQ_retire_valid = 1'b0;
        LQ_retire_ROB_index = head_index_ptr;
        SQ_retire_valid = 1'b0;
        SQ_retire_ROB_index = head_index_ptr;

        // restore from BRU ROB index (invalid)
        restore_checkpoint_valid = 1'b0;
        restore_checkpoint_speculate_failed = 1'b0;
        restore_checkpoint_ROB_index = restart_ROB_index_ptr;
        restore_checkpoint_safe_column = BRU_restart_safe_column;

        // revert from tail (invalid)
        revert_valid = 1'b0;
        revert_ROB_index = tail_index_ptr;
        revert_arch_reg_tag = ROB_array_by_entry[tail_index_ptr.index].dest_arch_reg_tag;
        revert_safe_phys_reg_tag = ROB_array_by_entry[tail_index_ptr.index].safe_dest_phys_reg_tag;
        revert_speculated_phys_reg_tag = ROB_array_by_entry[tail_index_ptr.index].speculated_dest_phys_reg_tag;

        // kill from tail (invalid)
        kill_bus_valid = 1'b0;
        kill_bus_ROB_index = tail_index_ptr;
        // kill_bus_arch_reg_tag = ROB_array_by_entry[tail_index_ptr.index].dest_arch_reg_tag;
        // kill_bus_safe_phys_reg_tag = ROB_array_by_entry[tail_index_ptr.index].safe_dest_phys_reg_tag;
        // kill_bus_speculated_phys_reg_tag = ROB_array_by_entry[tail_index_ptr.index].speculated_dest_phys_reg_tag;

        // no stall, flush, halt
        core_control_restore_flush = 1'b0;
        core_control_revert_stall = 1'b0;
        core_control_halt_assert = 1'b0;

        // resolve to fetch unit from BRU (invalid)
        fetch_unit_take_resolved = 1'b0;
        fetch_unit_resolved_PC = BRU_restart_PC;

        //////////////////////////////
        // state-independent logic: //
        //////////////////////////////

        // ROB dispatch enqueue
            // safe to do in all states
                // wouldn't be doing during restore or revert anyway since dispatch flushed or stalled
        if (dispatch_unit_enqueue_valid) begin

            // assert no enqueue while full
            if (full) begin
                $display("rob: ERROR: ROB enqueued when already full");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // assert in IDLE state
            if (ROB_state != ROB_IDLE) begin
                $display("rob: ERROR: ROB enqueued when not ROB_IDLE");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // perform enqueue at tail
            next_ROB_array_by_entry[tail_index_ptr.index] = dispatch_unit_enqueue_struct;

            // increment tail
            next_tail_index_ptr = tail_index_ptr + ROB_ptr_t'(1);            
        end

        // ROB complete writes:
            // safe to do in all states
        
        // complete bus 0
        if (complete_bus_0_valid) begin

            // check for invalid
                // this is allowed (mis-speculated instr completes)
                // track for perf analysis
            if (~ROB_array_by_entry[complete_bus_0_ROB_index[LOG_ROB_DEPTH-1:0]].valid) begin
                $display("rob: INFO: invalid completion on complete bus 0");
                invalid_complete = 1'b1;

                // // don't mark complete in this case
                // next_ROB_array_by_entry[complete_bus_0_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b0;
                    // this cause issue where new immediately complete instruction becomes uncomplete, can never retire
            end

            // otherwise, safe to mark complete
            else begin
                next_ROB_array_by_entry[complete_bus_0_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b1;
            end

            // assert tag match
            if (ROB_array_by_entry[complete_bus_0_ROB_index[LOG_ROB_DEPTH-1:0]].speculated_dest_phys_reg_tag != 
                complete_bus_0_dest_phys_reg_tag
            ) begin
                $display("rob: ERROR: tag mismatch on complete bus 0");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // assert bus match: ALU 0
            if (~ROB_array_by_entry[complete_bus_0_ROB_index[LOG_ROB_DEPTH-1:0]].dispatched_unit.DU_ALU_0) begin
                $display("rob: ERROR: bus mismatch on complete bus 0 (no ALU 0)");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end
        end

        // complete bus 1
        if (complete_bus_1_valid) begin

            // check for invalid
                // this is allowed (mis-speculated instr completes)
                // track for perf analysis
            if (~ROB_array_by_entry[complete_bus_1_ROB_index[LOG_ROB_DEPTH-1:0]].valid) begin
                $display("rob: INFO: invalid completion on complete bus 1");
                invalid_complete = 1'b1;

                // // don't mark complete in this case
                // next_ROB_array_by_entry[complete_bus_1_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b0;
                    // this cause issue where new immediately complete instruction becomes uncomplete, can never retire
            end

            // otherwise, safe to mark complete
            else begin
                next_ROB_array_by_entry[complete_bus_1_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b1;
            end

            // assert tag match
            if (ROB_array_by_entry[complete_bus_1_ROB_index[LOG_ROB_DEPTH-1:0]].speculated_dest_phys_reg_tag != 
                complete_bus_1_dest_phys_reg_tag
            ) begin
                $display("rob: ERROR: tag mismatch on complete bus 1");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // assert bus match: ALU 1
            if (~ROB_array_by_entry[complete_bus_1_ROB_index[LOG_ROB_DEPTH-1:0]].dispatched_unit.DU_ALU_1) begin
                $display("rob: ERROR: bus mismatch on complete bus 1 (no ALU 1)");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end
        end

        // complete bus 2
        if (complete_bus_2_valid) begin

            // check for invalid
                // this is allowed (mis-speculated instr completes)
                // track for perf analysis
            if (~ROB_array_by_entry[complete_bus_2_ROB_index[LOG_ROB_DEPTH-1:0]].valid) begin
                $display("rob: INFO: invalid completion on complete bus 2");
                invalid_complete = 1'b1;

                // // don't mark complete in this case
                // next_ROB_array_by_entry[complete_bus_2_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b0;
                    // this cause issue where new immediately complete instruction becomes uncomplete, can never retire
            end
            
            // otherwise, safe to mark complete, load returned
            else begin
                next_ROB_array_by_entry[complete_bus_2_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b1;
                next_ROB_array_by_entry[complete_bus_2_ROB_index[LOG_ROB_DEPTH-1:0]].load_returned = 1'b1;
            end

            // assert tag match
            if (ROB_array_by_entry[complete_bus_2_ROB_index[LOG_ROB_DEPTH-1:0]].speculated_dest_phys_reg_tag != 
                complete_bus_2_dest_phys_reg_tag
            ) begin
                $display("rob: ERROR: tag mismatch on complete bus 2");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // assert bus match: LQ
            if (~ROB_array_by_entry[complete_bus_2_ROB_index[LOG_ROB_DEPTH-1:0]].dispatched_unit.DU_LQ) begin
                $display("rob: ERROR: bus mismatch on complete bus 2 (no LQ)");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end
        end

        // BRU complete
        if (BRU_complete_valid) begin

            // check for invalid
                // this is allowed (mis-speculated instr completes)
                // track for perf analysis
            if (~ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid) begin
                $display("rob: INFO: invalid completion by BRU");
                invalid_complete = 1'b1;

                // // don't mark complete in this case
                // next_ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b0;
                    // this cause issue where new immediately complete instruction becomes uncomplete, can never retire
            end
            
            // otherwise, safe to mark complete
            else begin
                next_ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b1;
            end

            // check for no restart needed -> send checkpoint invalidate to dispatch unit
            if (~BRU_restart_valid) begin
                restore_checkpoint_valid = 1'b1;
                restore_checkpoint_speculate_failed = 1'b0;
                restore_checkpoint_ROB_index = BRU_restart_ROB_index;
                restore_checkpoint_safe_column = BRU_restart_safe_column;
            end

            // assert BRU match
            if (~ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].dispatched_unit.DU_BRU) begin
                $display("rob: ERROR: BRU mismatch on complete");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end
        end

        // SQ complete
        if (SQ_complete_valid) begin

            // check for invalid
                // this is allowed (mis-speculated instr completes)
                // track for perf analysis
            if (~ROB_array_by_entry[SQ_complete_ROB_index[LOG_ROB_DEPTH-1:0]].valid) begin
                $display("rob: INFO: invalid completion by SQ");
                invalid_complete = 1'b1;

                // // don't mark complete in this case
                // next_ROB_array_by_entry[SQ_complete_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b0;
                    // this cause issue where new immediately complete instruction becomes uncomplete, can never retire
            end

            // otherwise, safe to mark complete
            else begin
                next_ROB_array_by_entry[SQ_complete_ROB_index[LOG_ROB_DEPTH-1:0]].complete = 1'b1;
            end

            // assert SQ match
            if (~ROB_array_by_entry[SQ_complete_ROB_index[LOG_ROB_DEPTH-1:0]].dispatched_unit.DU_SQ) begin
                $display("rob: ERROR: SQ mismatch on complete");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end
        end

        // inorder kill (whenever start hasn't met end)
        if (inorder_kill_start_ROB_index != inorder_kill_end_ROB_index) begin

            // kill if entry valid
            if (ROB_array_by_entry[inorder_kill_start_ROB_index[LOG_ROB_DEPTH-1:0]].valid) begin

                // send kill command
                kill_bus_valid = 1'b1;
                kill_bus_ROB_index = inorder_kill_start_ROB_index;
            end

            // invalidate entry
            next_ROB_array_by_entry[inorder_kill_start_ROB_index[LOG_ROB_DEPTH-1:0]].valid = 1'b0;

            // increment start
            next_inorder_kill_start_ROB_index = inorder_kill_start_ROB_index + 1;
        end

        ////////////////////////////
        // state-dependent logic: //
        ////////////////////////////

        // other state-dep logic
        casez (ROB_state)

            ///////////////////////////////////////////////////////////////////////////////////////////////
            // ROB_IDLE state:
                // state where not restoring, reverting, killing, or halting
                // all ROB functions are supported
                    // enqueueing shouldn't be happening since core control stalls dispatch
                    // dequeueing only allowed here
                // transitions:
                    // if retire halt, goto ROB_HALT
                    // 
            
            ROB_IDLE:
            begin
                // ROB retire dequeue
                    // not safe during restore or revert
                        // may be dequeueing beyond rolled back instr's
                        // technically, could still dequeue if above rollback target
                        // unlikely to cause issues since rolling back, so ROB being shrunk, so not short
                        //      on ROB entries
                    // can dequeue if entry at head is valid and complete
                if (ROB_array_by_entry[head_index_ptr.index].valid & ROB_array_by_entry[head_index_ptr.index].complete) begin

                    // assert no dequeue while empty
                    if (empty) begin
                        $display("rob: ERROR: ROB dequeued when already empty");
                        $display("\t@: %0t",$realtime);
                        next_DUT_error = 1'b1;
                    end

                    // perform dequeue at head
                        // invalidate entry
                    next_ROB_array_by_entry[head_index_ptr.index].valid = 1'b0;

                    // increment head
                    next_head_index_ptr = head_index_ptr + ROB_ptr_t'(1);

                    // send retire to applicable units:

                    // if uses new tag, send retired tag to dispatch unit
                    if (ROB_array_by_entry[head_index_ptr.index].reg_write) begin
                        dispatch_unit_retire_valid = 1'b1;
                        dispatch_unit_retire_phys_reg_tag = ROB_array_by_entry[head_index_ptr.index].safe_dest_phys_reg_tag;
                    end

                    // ll/sc
                    // check in LQ and SQ -> SC
                    if (
                        ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_LQ
                        &
                        ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_SQ
                    ) begin

                        // retire indexes safe regardless
                        SQ_retire_ROB_index = head_index_ptr;
                        LQ_retire_ROB_index = head_index_ptr;

                        // check for no store sent
                        if (~ROB_array_by_entry[head_index_ptr.index].store_sent) begin

                            // prevent old rename from being freed
                            dispatch_unit_retire_valid = 1'b0;

                            // keep entry valid
                            next_ROB_array_by_entry[head_index_ptr.index].valid = 1'b1;

                            // stall head
                            next_head_index_ptr = head_index_ptr;

                            // check not being blocked
                            if (~SQ_retire_blocked) begin

                                // send retire
                                SQ_retire_valid = 1'b1;

                                // mark store sent
                                next_ROB_array_by_entry[head_index_ptr.index].store_sent = 1'b1;
                            end
                        end

                        // otherwise, check waiting for load return
                        else if (~ROB_array_by_entry[head_index_ptr.index].load_returned) begin

                            // prevent old rename from being freed
                            dispatch_unit_retire_valid = 1'b0;

                            // keep entry valid
                            next_ROB_array_by_entry[head_index_ptr.index].valid = 1'b1;

                            // stall head
                            next_head_index_ptr = head_index_ptr;
                        end

                        // otherwise, all parts of SC done, treat as LQ retire
                        else begin
                            
                            // send retire
                            LQ_retire_valid = 1'b1;
                                // why was this okay if blocked?
                                // LSQ was checking if blocked
                                // must do this way, else comb loop

                            LQ_retire_ROB_index = head_index_ptr;

                            // if LQ blocked, don't move on
                            if (LQ_retire_blocked) begin

                                // prevent old rename from being freed
                                dispatch_unit_retire_valid = 1'b0;

                                // keep entry valid
                                next_ROB_array_by_entry[head_index_ptr.index].valid = 1'b1;

                                // stall head
                                next_head_index_ptr = head_index_ptr;
                            end

                            // // otherwise, can send retire, advance head
                            // else begin

                            //     // send retire
                            //     LQ_retire_valid = 1'b1;
                            // end
                                // can't do this way comb loop
                        end
                    end

                    // otherwise, LW or LL, only in LQ, send retire
                    else if (ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_LQ) begin

                        // send retire
                        LQ_retire_valid = 1'b1;
                            // why was this okay if blocked?
                            // LSQ was checking if blocked
                            // must do this way, else comb loop

                        LQ_retire_ROB_index = head_index_ptr;

                        // if LQ blocked, don't move on
                        if (LQ_retire_blocked) begin

                            // prevent old rename from being freed
                            dispatch_unit_retire_valid = 1'b0;

                            // keep entry valid
                            next_ROB_array_by_entry[head_index_ptr.index].valid = 1'b1;

                            // stall head
                            next_head_index_ptr = head_index_ptr;
                        end

                        // // otherwise, can send retire, advance head
                        // else begin

                        //     // send retire
                        //     LQ_retire_valid = 1'b1;
                        // end
                            // can't do this way comb loop
                    end

                    // otherwise, SW, only in SQ, send retire, only move on if not blocked
                    else if (ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_SQ) begin
                        
                        // // send retire
                        // SQ_retire_valid = 1'b1;
                            // why was this okay if blocked?
                            // LSQ was checking if blocked

                        SQ_retire_ROB_index = head_index_ptr;

                        // if SQ blocked, don't move on
                        if (SQ_retire_blocked) begin

                            // keep entry valid
                            next_ROB_array_by_entry[head_index_ptr.index].valid = 1'b1;

                            // stall head
                            next_head_index_ptr = head_index_ptr;
                        end 

                        // otherwise, can send retire, advance head
                        else begin

                            // send retire
                            SQ_retire_valid = 1'b1;
                        end
                    end

                    // if halt, goto ROB_HALT state
                    if (ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_HALT) begin
                        next_ROB_state = ROB_HALT;
                    end

                    // commit info print:
                    if (~next_ROB_array_by_entry[head_index_ptr.index].valid) begin
                        $display("ROB RETIRE:");
                        $display("\tDU_ALU_0 = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_ALU_0);
                        $display("\tDU_ALU_1 = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_ALU_1);
                        $display("\tDU_LQ = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_LQ);
                        $display("\tDU_SQ = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_SQ);
                        $display("\tDU_BRU = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_BRU);
                        $display("\tDU_J = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_J);
                        $display("\tDU_DEAD = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_DEAD);
                        $display("\tDU_HALT = %h", ROB_array_by_entry[head_index_ptr.index].dispatched_unit.DU_HALT);
                        $display("\trestart_PC = 0x%h", ROB_array_by_entry[head_index_ptr.index].restart_PC);
                        $display("\treg_write = %h", ROB_array_by_entry[head_index_ptr.index].reg_write);
                        $display("\tdest_arch_reg_tag = 0x%h", ROB_array_by_entry[head_index_ptr.index].dest_arch_reg_tag);
                        $display("\tsafe_dest_phys_reg_tag = 0x%h", ROB_array_by_entry[head_index_ptr.index].safe_dest_phys_reg_tag);
                        $display("\tspeculated_dest_phys_reg_tag = 0x%h", ROB_array_by_entry[head_index_ptr.index].speculated_dest_phys_reg_tag);
                        $display("\tstore_sent = %h", ROB_array_by_entry[head_index_ptr.index].store_sent);
                        $display("\tload_returned = %h", ROB_array_by_entry[head_index_ptr.index].load_returned);
                        $display("\t@: %0t",$realtime);
                    end
                end

                // // ROB invalid move dequeue
                //     // invalid and head != tail
                // else if (
                //     ~ROB_array_by_entry[head_index_ptr.index].valid
                //     &
                //     (
                //         head_index_ptr 
                //         !=
                //         tail_index_ptr
                //     )
                // ) begin
                //     // increment head
                //     next_head_index_ptr = head_index_ptr + ROB_ptr_t'(1);
                // end

                // restart req for ROB_IDLE:

                // simultaneous BRU and LQ restarts -> restart at older
                    // also check LQ entry valid
                        // restart can come in late, don't care if entry invalid
                    // also check LQ entry not going to be killed -> between inorder start and end
                        // (LQ entry - head) >= (start - head)
                        // AND
                        // (LQ entry - head) < (end - head)
                if (
                    BRU_restart_valid
                    &
                    ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    & 
                    LQ_restart_valid
                    &
                    ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    &
                    !(
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            >=
                            (inorder_kill_start_ROB_index - head_index_ptr)
                        )
                        &
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            <
                            (inorder_kill_end_ROB_index - head_index_ptr)
                        )
                    )
                ) begin

                    // age logic: subtract head index

                    // check BRU older -> restart BRU
                    if (
                        BRU_restart_ROB_index - head_index_ptr
                        <
                        LQ_restart_ROB_index - head_index_ptr
                    ) begin

                        // BRU -> check for checkpoint restore
                        next_ROB_state = ROB_RESTORE;

                        // save ROB index restarting to (instr after BRU)
                        next_restart_ROB_index_ptr = BRU_restart_ROB_index + ROB_index_t'(1);

                        // save checkpoint column
                        next_restart_column = BRU_restart_safe_column;

                        // route BRU restart PC to fetch unit
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = BRU_restart_PC;
                    end

                    // else LQ older 
                    else begin

                        // LQ -> no check for checkpoint restore, immediately revert
                        next_ROB_state = ROB_REVERT;

                        // set tail so points to youngest dispatched instr
                            // if dispatching this cycle, keep tail same
                            // otherwise, decrement tail
                        if (dispatch_unit_enqueue_valid) begin
                            next_tail_index_ptr = tail_index_ptr;
                        end
                        else begin
                            next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);
                        end

                        // tricky: forwarded load value from SQ can be handled by LQ itself, it just 
                            // does another write to the reg file
                        // do want to restart load itself if due to invalidation
                            // want new signal to differentiate restart at load or after load

                        // check restart after this load (SQ forward handles)
                        if (LQ_restart_after_instr) begin

                            // save ROB index restarting to (instr after LW)
                            next_restart_ROB_index_ptr = LQ_restart_ROB_index + ROB_index_t'(1);

                            // route LQ ROB entry restart PC+4 to fetch unit
                                // fetch instr after load again
                                // guaranteed to be PC+4 after load
                            fetch_unit_take_resolved = 1'b1;
                            fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC + pc_t'(1);
                        end
                        
                        // otherwise, restart this load (need to do load again)
                        else begin
                        
                            // save ROB index restarting to
                                // need to restart load itself
                                    // without anything fancy, can just fetch and dispatch load again
                            next_restart_ROB_index_ptr = LQ_restart_ROB_index;
                                
                            // route LQ ROB entry restart PC to fetch unit
                                // fetch at load instr again
                            fetch_unit_take_resolved = 1'b1;
                            fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC;
                        end 
                    end
                end

                // otherwise, choose BRU or LQ individually

                // restart BRU
                else if (
                    BRU_restart_valid
                    &
                    ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                ) begin

                    // BRU -> check for checkpoint restore
                    next_ROB_state = ROB_RESTORE;

                    // save ROB index restarting to (instr after BRU)
                    next_restart_ROB_index_ptr = BRU_restart_ROB_index + ROB_index_t'(1);

                    // save checkpoint column
                    next_restart_column = BRU_restart_safe_column;

                    // route BRU restart PC to fetch unit
                    fetch_unit_take_resolved = 1'b1;
                    fetch_unit_resolved_PC = BRU_restart_PC;
                end

                // restart LQ
                else if (
                    LQ_restart_valid
                    &
                    ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    &
                    !(
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            >=
                            (inorder_kill_start_ROB_index - head_index_ptr)
                        )
                        &
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            <
                            (inorder_kill_end_ROB_index - head_index_ptr)
                        )
                    )
                ) begin

                    // LQ -> no check for checkpoint restore, immediately revert
                    next_ROB_state = ROB_REVERT;

                    // set tail so points to youngest dispatched instr
                        // if dispatching this cycle, keep tail same
                        // otherwise, decrement tail
                    if (dispatch_unit_enqueue_valid) begin
                        next_tail_index_ptr = tail_index_ptr;
                    end
                    else begin
                        next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);
                    end

                    // check restart after this load (SQ forward handles)
                    if (LQ_restart_after_instr) begin

                        // save ROB index restarting to (instr after LW)
                        next_restart_ROB_index_ptr = LQ_restart_ROB_index + ROB_index_t'(1);

                        // route LQ ROB entry restart PC+4 to fetch unit
                            // fetch instr after load again
                            // guaranteed to be PC+4 after load
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC + pc_t'(1);
                    end
                    
                    // otherwise, restart this load (need to do load again)
                    else begin
                    
                        // save ROB index restarting to
                            // need to restart load itself
                                // without anything fancy, can just fetch and dispatch load again
                        next_restart_ROB_index_ptr = LQ_restart_ROB_index;
                            
                        // route LQ ROB entry restart PC to fetch unit
                            // fetch at load instr again
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC;
                    end 
                end
                
            end

            ///////////////////////////////////////////////////////////////////////////////////////////////
            // ROB_RESTORE state:
                // state where send restore attempt to dispatch unit
                // transitions:
                    // if get higher priority restart, follow that state transition
                    // if restore successful, schedule kills
                    // if restore unsuccessful, goto ROB_IDLE and setup inorder kill
            
            ROB_RESTORE:
            begin
                // core control flush
                core_control_restore_flush = 1'b1;

                // assert restore command
                restore_checkpoint_valid = 1'b1;
                restore_checkpoint_speculate_failed = 1'b1;
                restore_checkpoint_ROB_index = restart_ROB_index_ptr - ROB_ptr_t'(1); // need index before
                restore_checkpoint_safe_column = restart_column;

                // check for successful restore -> start kill task
                if (restore_checkpoint_success) begin

                    next_ROB_state = ROB_IDLE;

                    // setup inorder kill pointers
                        // start from oldest wrong instr
                    next_inorder_kill_start_ROB_index = restart_ROB_index_ptr;
                    next_inorder_kill_end_ROB_index = tail_index_ptr;

                    // set tail pointer to oldest wrong instr (first instr that can replace)
                    next_tail_index_ptr = restart_ROB_index_ptr;
                end
                // otherwise, goto ROB_REVERT
                else begin
                    next_ROB_state = ROB_REVERT;

                    // decrement the tail so points to youngest dispatched instr
                    next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);
                end

                // restart req for ROB_RESTORE:

                // check BRU valid and older than current restart
                if (
                    BRU_restart_valid
                    &
                    ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    &
                    (
                        BRU_restart_ROB_index - head_index_ptr
                        <
                        restart_ROB_index_ptr - head_index_ptr
                    )
                ) begin

                    // check LQ valid and older than BRU -> restart LQ
                    if (
                        LQ_restart_valid
                        &
                        ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                        &
                        !(
                            (
                                (LQ_restart_ROB_index - head_index_ptr)
                                >=
                                (inorder_kill_start_ROB_index - head_index_ptr)
                            )
                            &
                            (
                                (LQ_restart_ROB_index - head_index_ptr)
                                <
                                (inorder_kill_end_ROB_index - head_index_ptr)
                            )
                        )
                        &
                        (
                            LQ_restart_ROB_index - head_index_ptr
                            <
                            BRU_restart_ROB_index - head_index_ptr
                        )
                    ) begin

                        // LQ -> no check for checkpoint restore, immediately revert
                        next_ROB_state = ROB_REVERT;

                        // // set tail so points to youngest dispatched instr
                        //     // if dispatching this cycle, keep tail same
                        //     // otherwise, decrement tail
                        // if (dispatch_unit_enqueue_valid) begin
                        //     next_tail_index_ptr = tail_index_ptr;
                        // end
                        // else begin
                        //     next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);
                        // end
                            // want to keep tail logic determined from checkpoint success/failure

                        // check restart after this load (SQ forward handles)
                        if (LQ_restart_after_instr) begin

                            // save ROB index restarting to (instr after LW)
                            next_restart_ROB_index_ptr = LQ_restart_ROB_index + ROB_index_t'(1);

                            // route LQ ROB entry restart PC+4 to fetch unit
                                // fetch instr after load again
                                // guaranteed to be PC+4 after load
                            fetch_unit_take_resolved = 1'b1;
                            fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC + pc_t'(1);
                        end
                        
                        // otherwise, restart this load (need to do load again)
                        else begin
                        
                            // save ROB index restarting to
                                // need to restart load itself
                                    // without anything fancy, can just fetch and dispatch load again
                            next_restart_ROB_index_ptr = LQ_restart_ROB_index;
                                
                            // route LQ ROB entry restart PC to fetch unit
                                // fetch at load instr again
                            fetch_unit_take_resolved = 1'b1;
                            fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC;
                        end 
                    end

                    // otherwise, restart BRU
                    else begin

                        // BRU -> check for checkpoint restore
                        next_ROB_state = ROB_RESTORE;

                        // save ROB index restarting to (instr after BRU)
                        next_restart_ROB_index_ptr = BRU_restart_ROB_index + ROB_index_t'(1);

                        // save checkpoint column
                        next_restart_column = BRU_restart_safe_column;

                        // route BRU restart PC to fetch unit
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = BRU_restart_PC;
                    end
                end

                // check LQ valid and older than current restart
                if (
                    LQ_restart_valid 
                    &
                    ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    &
                    !(
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            >=
                            (inorder_kill_start_ROB_index - head_index_ptr)
                        )
                        &
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            <
                            (inorder_kill_end_ROB_index - head_index_ptr)
                        )
                    )
                    & 
                    (
                        LQ_restart_ROB_index - head_index_ptr
                        <
                        restart_ROB_index_ptr - head_index_ptr
                    )
                ) begin

                    // LQ -> no check for checkpoint restore, immediately revert
                    next_ROB_state = ROB_REVERT;

                    // // set tail so points to youngest dispatched instr
                    //     // if dispatching this cycle, keep tail same
                    //     // otherwise, decrement tail
                    // if (dispatch_unit_enqueue_valid) begin
                    //     next_tail_index_ptr = tail_index_ptr;
                    // end
                    // else begin
                    //     next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);
                    // end
                        // want to keep tail logic determined from checkpoint success/failure

                    // check restart after this load (SQ forward handles)
                    if (LQ_restart_after_instr) begin

                        // save ROB index restarting to (instr after LW)
                        next_restart_ROB_index_ptr = LQ_restart_ROB_index + ROB_index_t'(1);

                        // route LQ ROB entry restart PC+4 to fetch unit
                            // fetch instr after load again
                            // guaranteed to be PC+4 after load
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC + pc_t'(1);
                    end
                    
                    // otherwise, restart this load (need to do load again)
                    else begin
                    
                        // save ROB index restarting to
                            // need to restart load itself
                                // without anything fancy, can just fetch and dispatch load again
                        next_restart_ROB_index_ptr = LQ_restart_ROB_index;
                            
                        // route LQ ROB entry restart PC to fetch unit
                            // fetch at load instr again
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC;
                    end 
                end

            end

            ///////////////////////////////////////////////////////////////////////////////////////////////
            // ROB_REVERT state:
                // state where send revert to dispatch unit and kill on kill bus
                // transitions:
                    // if get higher priority restart, follow that state transition
                    // if reverting done, goto ROB_IDLE
                    // if reverting not done, stay in ROB_REVERT

            ROB_REVERT:
            begin
                // core control stall
                core_control_revert_stall = 1'b1;

                // check arrived at desired tail
                if (tail_index_ptr == restart_ROB_index_ptr) begin

                    next_ROB_state = ROB_IDLE;

                    // hold tail
                    next_tail_index_ptr = tail_index_ptr;
                end

                // otherwise, keep reverting tail backward
                else begin

                    // decrement tail
                    next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);
                end

                // revert and kill if entry valid
                if (ROB_array_by_entry[tail_index_ptr.index].valid) begin

                    // assert revert command if entry writes reg
                        // current tail points to youngest ROB entry with dispatched instr
                            // although may have been invalidated along the way
                    if (ROB_array_by_entry[tail_index_ptr.index].reg_write) begin
                        revert_valid = 1'b1;
                        revert_ROB_index = tail_index_ptr;
                        revert_arch_reg_tag = ROB_array_by_entry[tail_index_ptr.index].dest_arch_reg_tag;
                        revert_safe_phys_reg_tag = ROB_array_by_entry[tail_index_ptr.index].safe_dest_phys_reg_tag;
                        revert_speculated_phys_reg_tag = ROB_array_by_entry[tail_index_ptr.index].speculated_dest_phys_reg_tag;
                    end

                    // send kill command
                    kill_bus_valid = 1'b1;
                    kill_bus_ROB_index = tail_index_ptr;
                end

                // invalidate entry
                next_ROB_array_by_entry[tail_index_ptr.index].valid = 1'b0;

                // restart req for ROB_REVERT:

                // check BRU valid and older than current restart
                if (
                    BRU_restart_valid
                    &
                    ROB_array_by_entry[BRU_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    &
                    (
                        BRU_restart_ROB_index - head_index_ptr
                        <
                        restart_ROB_index_ptr - head_index_ptr
                    )
                ) begin

                    // check LQ valid and older than BRU -> restart LQ
                    if (
                        LQ_restart_valid
                        &
                        ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid 
                        &
                        !(
                            (
                                (LQ_restart_ROB_index - head_index_ptr)
                                >=
                                (inorder_kill_start_ROB_index - head_index_ptr)
                            )
                            &
                            (
                                (LQ_restart_ROB_index - head_index_ptr)
                                <
                                (inorder_kill_end_ROB_index - head_index_ptr)
                            )
                        )
                        & 
                        (
                            LQ_restart_ROB_index - head_index_ptr
                            <
                            BRU_restart_ROB_index - head_index_ptr
                        )
                    ) begin

                        // LQ -> no check for checkpoint restore, immediately revert
                        next_ROB_state = ROB_REVERT;

                        // decrement the tail so points to youngest dispatched instr
                        next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);

                        // check restart after this load (SQ forward handles)
                        if (LQ_restart_after_instr) begin

                            // save ROB index restarting to (instr after LW)
                            next_restart_ROB_index_ptr = LQ_restart_ROB_index + ROB_index_t'(1);

                            // route LQ ROB entry restart PC+4 to fetch unit
                                // fetch instr after load again
                                // guaranteed to be PC+4 after load
                            fetch_unit_take_resolved = 1'b1;
                            fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC + pc_t'(1);
                        end
                        
                        // otherwise, restart this load (need to do load again)
                        else begin
                        
                            // save ROB index restarting to
                                // need to restart load itself
                                    // without anything fancy, can just fetch and dispatch load again
                            next_restart_ROB_index_ptr = LQ_restart_ROB_index;
                                
                            // route LQ ROB entry restart PC to fetch unit
                                // fetch at load instr again
                            fetch_unit_take_resolved = 1'b1;
                            fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC;
                        end 
                    end

                    // otherwise, restart BRU
                    else begin

                        // BRU -> check for checkpoint restore
                        next_ROB_state = ROB_RESTORE;

                        // save ROB index restarting to (instr after BRU)
                        next_restart_ROB_index_ptr = BRU_restart_ROB_index + ROB_index_t'(1);

                        // save checkpoint column
                        next_restart_column = BRU_restart_safe_column;

                        // route BRU restart PC to fetch unit
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = BRU_restart_PC;
                    end
                end

                // check LQ valid and older than current restart
                if (
                    LQ_restart_valid 
                    &
                    ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].valid
                    &
                    !(
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            >=
                            (inorder_kill_start_ROB_index - head_index_ptr)
                        )
                        &
                        (
                            (LQ_restart_ROB_index - head_index_ptr)
                            <
                            (inorder_kill_end_ROB_index - head_index_ptr)
                        )
                    )
                    & 
                    (
                        LQ_restart_ROB_index - head_index_ptr
                        <
                        restart_ROB_index_ptr - head_index_ptr
                    )
                ) begin

                    // LQ -> no check for checkpoint restore, immediately revert
                    next_ROB_state = ROB_REVERT;

                    // decrement the tail so points to youngest dispatched instr
                    next_tail_index_ptr = tail_index_ptr - ROB_ptr_t'(1);

                    // check restart after this load (SQ forward handles)
                    if (LQ_restart_after_instr) begin

                        // save ROB index restarting to (instr after LW)
                        next_restart_ROB_index_ptr = LQ_restart_ROB_index + ROB_index_t'(1);

                        // route LQ ROB entry restart PC+4 to fetch unit
                            // fetch instr after load again
                            // guaranteed to be PC+4 after load
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC + pc_t'(1);
                    end
                    
                    // otherwise, restart this load (need to do load again)
                    else begin
                    
                        // save ROB index restarting to
                            // need to restart load itself
                                // without anything fancy, can just fetch and dispatch load again
                        next_restart_ROB_index_ptr = LQ_restart_ROB_index;
                            
                        // route LQ ROB entry restart PC to fetch unit
                            // fetch at load instr again
                        fetch_unit_take_resolved = 1'b1;
                        fetch_unit_resolved_PC = ROB_array_by_entry[LQ_restart_ROB_index[LOG_ROB_DEPTH-1:0]].restart_PC;
                    end 
                end
            end

            ///////////////////////////////////////////////////////////////////////////////////////////////
            // ROB_HALT state:
                // convergent final state
                // once halt instr is retired, go and stay here
            
            ROB_HALT:
            begin
                // core control halt
                core_control_halt_assert = 1'b1;
                next_ROB_state = ROB_HALT;
            end

            ///////////////////////////////////////////////////////////////////////////////////////////////
            // default:
                // shouldn't every get to any other state
            
            default:
            begin
                $display("rob: ERROR: ROB in default state");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

        endcase

        ///////////////////////
        // full/empty logic: //
        ///////////////////////

        // default outputs:

        // not full or empty
        next_full = 1'b0;
        next_empty = 1'b0;

        // check for full/empty
        if (next_head_index_ptr.index == next_tail_index_ptr.index) begin

            // check for empty
            if (next_head_index_ptr.msb == next_tail_index_ptr.msb) begin
                next_empty = 1'b1;
            end

            // otherwise, full
            else begin
                next_full = 1'b1;
            end
        end

    end

endmodule