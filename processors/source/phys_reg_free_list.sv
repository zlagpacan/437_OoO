/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_free_list.sv
    Instantiation Hierarchy: system -> core -> dispatch_unit -> phys_reg_free_list
    Description: 
        The Physical Register Free List is a FIFO providing the next free physical register which a new
        register writing instruction can rename an architectural register to. The table can also checkpoint
        a free list which can be restored using a FIFO of free list head pointers.

        Consider: Update to prevent potential free + dispatch or dispatch then old free
            - simple flat table of ready/not ready
                - actually this might still be same problem

        It is the external controller's responsibility to prevent making phys reg 0 free.
*/

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_free_list (
    
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // dequeue
    input logic dequeue_valid,
    output phys_reg_tag_t dequeue_phys_reg_tag,

    // enqueue
    input logic enqueue_valid,
    input phys_reg_tag_t enqueue_phys_reg_tag,

    // full/empty
        // should be left unused but may want to account for potential functionality externally
        // can use for assertions
    output logic full,
    output logic empty,

    // reg map revert
    input logic revert_valid,
        // input arch_reg_tag_t revert_dest_arch_reg_tag,
        // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
    input phys_reg_tag_t revert_speculated_dest_phys_reg_tag,
        // can use for assertion but otherwise don't need

    // free list checkpoint save
    input logic save_checkpoint_valid,
    input ROB_index_t save_checkpoint_ROB_index,    // from ROB, write tag val
    output checkpoint_column_t save_checkpoint_safe_column,

    // free list checkpoint restore
    input logic restore_checkpoint_valid,
    input logic restore_checkpoint_speculate_failed,
    input ROB_index_t restore_checkpoint_ROB_index,  // from restore system, check tag val
    input checkpoint_column_t restore_checkpoint_safe_column,
    output logic restore_checkpoint_success
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
    // free list FIFO array:

    phys_reg_tag_t [FREE_LIST_DEPTH-1:0] phys_reg_free_list_by_index;
    phys_reg_tag_t [FREE_LIST_DEPTH-1:0] next_phys_reg_free_list_by_index;

    // free list FIFO pointers
        // lower bits for indexing array
        // msb for detecting empty/full
    // typedef logic [LOG_FREE_LIST_DEPTH:0] free_list_ptr_t;
    typedef struct packed {
        logic msb;
        logic [LOG_FREE_LIST_DEPTH-1:0] index;
    } free_list_ptr_t;

    // head
    free_list_ptr_t head_index_ptr;
    free_list_ptr_t next_head_index_ptr;
    
    // previous head
    free_list_ptr_t prev_head_index_ptr;

    // tail
    free_list_ptr_t tail_index_ptr;
    free_list_ptr_t next_tail_index_ptr;

    // FIFO array of checkpoint head pointers
        // wrap around allowed, only need tail
    typedef struct packed {
        logic valid;
        ROB_index_t ROB_index;
        free_list_ptr_t checkpoint_head_index_ptr;
    } free_list_checkpoint_column_t;

    free_list_checkpoint_column_t [CHECKPOINT_COLUMNS-1:0] checkpoint_columns_by_column_index;
    free_list_checkpoint_column_t [CHECKPOINT_COLUMNS-1:0] next_checkpoint_columns_by_column_index;
        // tail column: where next speculated head ptr will be appended to the checkpoint head FIFO
    checkpoint_column_t checkpoint_tail_column;
    checkpoint_column_t next_checkpoint_tail_column;

    // logic:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            
            ///////////////////////////////////////////////////////////////////////////////////////////////
            
            // // phys reg free list:
            //     // reset free list follows the phys reg tags > arch reg tags
            //     // start from next after highest arch reg tag
            // for (int i = 0; i < FREE_LIST_DEPTH; i++) begin
            //     phys_reg_free_list_by_index[i] <= phys_reg_tag_t'(NUM_ARCH_REGS + i);
            // end
            
            // // reset with free list full
            // head_index_ptr.index <= '0;
            // head_index_ptr.msb <= 1'b0;
            // tail_index_ptr.index <= '0;
            // tail_index_ptr.msb <= 1'b1;

            // // start with no checkpoints
            // checkpoint_columns_by_column_index <= '0;
            // checkpoint_tail_column <= checkpoint_column_t'(0);

            ///////////////////////////////////////////////////////////////////////////////////////////////

            // tricky edge case: first free's of arch reg's after reset
                // just make room for all phys reg's
                // start head at phys reg tags > arch reg tags
           
            // phys reg free list:
                // reset free list follows the phys reg tags > arch reg tags
                // start from next after highest arch reg tag
            for (int i = 0; i < FREE_LIST_DEPTH; i++) begin
                phys_reg_free_list_by_index[i] <= phys_reg_tag_t'(i);
            end

            // reset with free half full
                // head pointer starting at phys reg tags > arch reg tags
                // tail pointer starting at 0 wrapped around
            head_index_ptr.msb <= 1'b0;
            head_index_ptr.index <= (FREE_LIST_DEPTH >> 1);
            tail_index_ptr.msb <= 1'b1;
            tail_index_ptr.index <= '0;

            // start with no checkpoints
            checkpoint_columns_by_column_index <= '0;
            checkpoint_tail_column <= checkpoint_column_t'(0);
        end
        else begin
            phys_reg_free_list_by_index <= next_phys_reg_free_list_by_index;
            head_index_ptr <= next_head_index_ptr;
            tail_index_ptr <= next_tail_index_ptr;
            checkpoint_columns_by_column_index <= next_checkpoint_columns_by_column_index;
            checkpoint_tail_column <= next_checkpoint_tail_column;
        end
    end

    // free list array access logic
    always_comb begin

        // constant connections:
        
        // dequeue read
        dequeue_phys_reg_tag = phys_reg_free_list_by_index[head_index_ptr.index];

        // previous head
        prev_head_index_ptr = head_index_ptr - 1;

        // defaults:

        // no DUT error
        next_DUT_error = 1'b0;
            
        // hold state
        next_phys_reg_free_list_by_index = phys_reg_free_list_by_index;
        next_head_index_ptr = head_index_ptr;
        next_tail_index_ptr = tail_index_ptr;
        next_checkpoint_columns_by_column_index = checkpoint_columns_by_column_index;
        next_checkpoint_tail_column = checkpoint_tail_column;

        // restore failed
        restore_checkpoint_success = 1'b0;

        // enqueue logic:
            // can happen same cycle as save, restore, or dequeue, no problem
            // this is only operation that directly writes to the array
        if (enqueue_valid) begin

            // DUT error: FIFO full
            if (full) begin
                $display("phys_reg_free_list: ERROR: tried to enqueue when free list full");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // write @ tail
            next_phys_reg_free_list_by_index[tail_index_ptr.index] = enqueue_phys_reg_tag;

            // increment tail
            next_tail_index_ptr = tail_index_ptr + 1;
        end

        // checkpoint invalidate logic:
            // keep separate since can do this during a dequeue or save
        if (restore_checkpoint_valid & ~restore_checkpoint_speculate_failed) begin

            // check for VTM on restore col
            if (checkpoint_columns_by_column_index[restore_checkpoint_safe_column].valid &
                checkpoint_columns_by_column_index[restore_checkpoint_safe_column].ROB_index ==
                restore_checkpoint_ROB_index
            ) begin
                // invalidate safe column
                next_checkpoint_columns_by_column_index[restore_checkpoint_safe_column]
                    .valid = 1'b0;

                // give successful
                restore_checkpoint_success = 1'b1;
            end

            // otherwise, give unsuccessful
            else begin
                restore_checkpoint_success = 1'b0;
            end
        end

        // revert/restore/save/dequeue logic:
            // implied that each of these cases are mutually exclusive
            // these operations only change the values of pointers, don't write to the array

        // revert
        if (revert_valid) begin

            // DUT error: check value at head - 1 == expected speculated value to re-free
            if (phys_reg_free_list_by_index[prev_head_index_ptr.index] != revert_speculated_dest_phys_reg_tag) begin
                $display("phys_reg_free_list: ERROR: revert -> speculated phys reg mapping not in expected free list slot");
                $display("\t\trevert_speculated_dest_phys_reg_tag = %d", 
                    revert_speculated_dest_phys_reg_tag);
                $display("\t\tfree list value = %d",
                    phys_reg_free_list_by_index[prev_head_index_ptr.index]);
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
            end

            // decrement head
            next_head_index_ptr = prev_head_index_ptr;
        end

        // restore
        else if (restore_checkpoint_valid & restore_checkpoint_speculate_failed) begin

            // check for VTM on restore col
            if (checkpoint_columns_by_column_index[restore_checkpoint_safe_column].valid & 
                checkpoint_columns_by_column_index[restore_checkpoint_safe_column].ROB_index ==
                restore_checkpoint_ROB_index
            ) begin
                // revert to safe column
                next_checkpoint_tail_column = restore_checkpoint_safe_column;

                // update head pointer following safe column value
                next_head_index_ptr = checkpoint_columns_by_column_index[restore_checkpoint_safe_column]
                    .checkpoint_head_index_ptr;

                // invalidate all other columns
                for (int i = 0; i < CHECKPOINT_COLUMNS; i++) begin
                    if (checkpoint_column_t'(i) != restore_checkpoint_safe_column) begin
                        next_checkpoint_columns_by_column_index[i]
                            .valid = 1'b0;
                    end
                end

                // give successful
                restore_checkpoint_success = 1'b1;
            end

            // otherwise, give unsuccessful
            else begin
                restore_checkpoint_success = 1'b0;
            end
        end

        // save
        else if (save_checkpoint_valid) begin

            // enqueue new checkpoint
                // valid
                // ROB index of dispatching instr
                // copy head pointer value
            next_checkpoint_columns_by_column_index[checkpoint_tail_column]
                .valid = 1'b1;
            next_checkpoint_columns_by_column_index[checkpoint_tail_column]
                .ROB_index = save_checkpoint_ROB_index;
            next_checkpoint_columns_by_column_index[checkpoint_tail_column]
                .checkpoint_head_index_ptr = head_index_ptr;

            // increment checkpoint FIFO tail
            next_checkpoint_tail_column = checkpoint_tail_column + 1;
        end

        // dequeue
        else if (dequeue_valid) begin

            // increment head
            next_head_index_ptr = head_index_ptr + 1;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // free list full/empty:
        // definitely want empty to signal that can't do new rename, need to stall dispatch
        // for full, should naturally never overflow since cannot have more mappings which can be in the 
            // free list than (NUM_PHYS_REGS - NUM_ARCH_REGS) == (FREE_LIST_DEPTH)

    ////////////////////////////
    // combinational version: //
    ////////////////////////////
        // combinational logic on current head and tail pointer values

    // always_comb begin

    //     // default: not full/empty
    //     full = 1'b0;
    //     empty = 1'b0;

    //     // check for full/empty
    //     if (head_index_ptr.index == tail_index_ptr.index) begin

    //         // check for empty
    //         if (head_index_ptr.msb == tail_index_ptr.msb) begin
    //             empty = 1'b1;
    //         end

    //         // check for full
    //         else if (head_index_ptr.msb != tail_index_ptr.msb) begin
    //             full = 1'b1;
    //         end

    //         // otherwise, unexpected
    //         else begin
    //             $display("phys_reg_free_list: invalid full/empty case");
    //             assert(0);
    //         end
    //     end
    // end

    /////////////////////////
    // registered version: //
    /////////////////////////
        // equivalent timing to combinational version but have value at beginning of cycle
        // determine will be full/emptpy on cycle before

    // next full/empty
    logic next_full;
    logic next_empty;

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // // start full, not empty
            // full <= 1'b1;
            // empty <= 1'b0;
            // start half full, not empty
            full <= 1'b0;
            empty <= 1'b0;
        end
        else begin
            full <= next_full;
            empty <= next_empty;
        end
    end

    // comb
    always_comb begin

        // default: not full/empty
        next_full = 1'b0;
        next_empty = 1'b0;

        // check for full/empty
        if (next_head_index_ptr.index == next_tail_index_ptr.index) begin

            // check for empty
            if (next_head_index_ptr.msb == next_tail_index_ptr.msb) begin
                next_empty = 1'b1;
            end

            // check for full
            else if (next_head_index_ptr.msb != next_tail_index_ptr.msb) begin
                next_full = 1'b1;
            end

            // otherwise, unexpected
            else begin
                $display("phys_reg_free_list: ERROR: invalid full/empty case");
                $display("\t@: %0t",$realtime);
                assert(0);
            end
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // wires:

    // outputs
    assign save_checkpoint_safe_column = checkpoint_tail_column;

endmodule