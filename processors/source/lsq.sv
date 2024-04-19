/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: lsq.sv
    Instantiation Hierarchy: system -> core -> lsq
    Description:

        The LSQ (Load-Store Queue) takes dispatched LSQ tasks (LW, SW, LL, SC; data memory accesses) 
        and completes them.

        The LSQ is capable of out-of-order load completion and load restart detection. Loads can
        forward their values from older stores. Loads are stalled if an older store has an ambiguous
        address or matching address (no out-of-order if there is a potential dependence). Stores are
        in-order and complete when they reach the ROB head.

        The LSQ directly interfaces with the dcache:
            - read req interface:
                - valid
                - LQ index
                - addr
                - linked
                - conditional
                - blocked
            - read resp interface:
                - valid
                - LQ index
                - read data
            - write req interface:
                - valid
                - addr
                - write data
                - conditional
                - blocked

            - dcache is non-blocking
                - take req's in single cycle (if D$ has space)

        TODO: LL and SC
            - LL
                - can have link reg in core, reuse funcitonality that passes inv's into core to 
                    inv link reg
                    - actually no sense doing this, just put link reg in D$
                        - link reg in D$better for non-blocking LQ enQ solution below
                - should be fine OoO
                    - technically don't even have to restart if get inv as long as only use 
                        LL value for SC (which will fail anyway)
            - SC
                - need to keep in-order, execute at ROB head
                - tricky part is return value
                    - could enQ into LQ and SQ
                        - OoO LQ:
                            - LQ
                                - returns 1 OoO
                                - if link reg get's inv, restart SC
                                    - this doesn't work as need to return 0
                            - SQ
                                - normal
                        - non-blocking LQ:
                            - LQ
                                - forced to go to cache as special link success load
                                    - respond when associated SC is completed
                                - block SQ retire while waiting for LQ response
                                    - really just since SC not done, want to keep around
                                    - ROB should be able to move on from SC even if LQ return 
                                        value not finished
                            - SQ
                                - normal
                    - could do separate pipeline for SC return value
                        - don't have to hinder LQ functionality by being in-order
                            - or needlessly try to be OoO so okay in LQ
                        - whens SC retired by ROB, check link reg
*/

`include "core_types.vh"
import core_types_pkg::*;

module lsq (

    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    ////////////////////
    // dispatch unit: //
    ////////////////////

    // // LQ interface
    // input LQ_index_t dispatch_unit_LQ_tail_index,
    // input logic dispatch_unit_LQ_full,
    // output logic dispatch_unit_LQ_task_valid,
    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,

    // output LQ_index_t dispatch_unit_LQ_tail_index,
    output logic dispatch_unit_LQ_full,
    input logic dispatch_unit_LQ_task_valid,
    input LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
        // typedef struct packed {
        //     // LQ needs
        //     LQ_op_t op;
        //     source_reg_status_t source;
        //     phys_reg_tag_t dest_phys_reg_tag;
        //     daddr_t imm14;
        //     SQ_index_t SQ_index;   // for SC, doubles as SQ index for store part of SC to track
        //         // may want separate counter tag to link the store and load parts of SC
        //             // or ROB_index serves this role
        //     // admin
        //     ROB_index_t ROB_index;
        // } LQ_enqueue_struct_t;

    // // SQ interface
    // input SQ_index_t dispatch_unit_SQ_tail_index,
    // input logic dispatch_unit_SQ_full,
    // output logic dispatch_unit_SQ_task_valid,
    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,

    // output SQ_index_t dispatch_unit_SQ_tail_index,
    output logic dispatch_unit_SQ_full,
    input logic dispatch_unit_SQ_task_valid,
    input SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
        // typedef struct packed {
        //     // SQ needs
        //     SQ_op_t op;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     daddr_t imm14;
        //     LQ_index_t LQ_index;
        //         // may want separate counter tag to link the store and load parts of SC
        //             // or ROB_index serves this role
        //     // admin
        //     ROB_index_t ROB_index;
        // } SQ_enqueue_struct_t;

    //////////
    // ROB: //
    //////////

    // // kill bus interface
    //     // send kill command to execution units
    // output logic kill_bus_valid,
    // output ROB_index_t kill_bus_ROB_index,

    input logic kill_bus_valid,
    input ROB_index_t kill_bus_ROB_index,

    // // core control interface
    // output logic core_control_restore_flush,
    // output logic core_control_revert_stall,
    // output logic core_control_halt_assert,
    //     // for when halt instr retires
    
    input logic core_control_halt,

    // // LQ interface
    // // restart info
    // input logic ROB_LQ_restart_valid,
    // input logic ROB_LQ_restart_after_instr,
    // input ROB_index_t ROB_LQ_restart_ROB_index,
    // // retire
    // output logic ROB_LQ_retire_valid,
    // output ROB_index_t ROB_LQ_retire_ROB_index,
    // input logic ROB_LQ_retire_blocked,

    output logic ROB_LQ_restart_valid,
    output logic ROB_LQ_restart_after_instr,
    output ROB_index_t ROB_LQ_restart_ROB_index,

    input logic ROB_LQ_retire_valid,
    input ROB_index_t ROB_LQ_retire_ROB_index,
    output logic ROB_LQ_retire_blocked,

    // // SQ interface
    // // complete
    // input logic ROB_SQ_complete_valid,
    // input ROB_index_t ROB_SQ_complete_ROB_index,
    // // retire
    // output logic ROB_SQ_retire_valid,
    // output ROB_index_t ROB_SQ_retire_ROB_index,
    // input logic ROB_SQ_retire_blocked,

    output logic ROB_SQ_complete_valid,
    output ROB_index_t ROB_SQ_complete_ROB_index,

    input logic ROB_SQ_retire_valid,
    input ROB_index_t ROB_SQ_retire_ROB_index,
    output logic ROB_SQ_retire_blocked,

    ////////////////////
    // phys reg file: //
    ////////////////////

    // // LQ read req
    // input logic LQ_read_req_valid,
    // input phys_reg_tag_t LQ_read_req_tag,
    // output logic LQ_read_req_serviced,

    output logic LQ_reg_read_req_valid,
    output phys_reg_tag_t LQ_reg_read_req_tag,
    input logic LQ_reg_read_req_serviced,
    input word_t LQ_reg_read_bus_0_data,

    // // SQ read req
    // input logic SQ_read_req_valid,
    // input phys_reg_tag_t SQ_read_req_0_tag,
    // input phys_reg_tag_t SQ_read_req_1_tag,
    // output logic SQ_read_req_serviced,

    output logic SQ_reg_read_req_valid,
    output phys_reg_tag_t SQ_reg_read_req_0_tag,
    output phys_reg_tag_t SQ_reg_read_req_1_tag,
    input logic SQ_reg_read_req_serviced,
    input word_t SQ_reg_read_bus_0_data,
    input word_t SQ_reg_read_bus_1_data,

    ///////////////////
    // complete bus: //
    ///////////////////

    // // output side (output to this ALU Pipeline's associated bus)
    // output logic this_complete_bus_tag_valid,
    // output phys_reg_tag_t this_complete_bus_tag,
    // output ROB_index_t this_complete_bus_ROB_index,
    // output logic this_complete_bus_data_valid, // only needs to go to reg file
    // output word_t this_complete_bus_data

    output logic this_complete_bus_tag_valid,
    output phys_reg_tag_t this_complete_bus_tag,
    output ROB_index_t this_complete_bus_ROB_index,
    output logic this_complete_bus_data_valid, // only needs to go to reg file
    output word_t this_complete_bus_data,

    /////////////
    // dcache: //
    /////////////

    // read req interface:
    //      - valid
    //      - LQ index
    //      - addr
    //      - linked
    //      - conditional
    //      - blocked

    output logic dcache_read_req_valid,
    output LQ_index_t dcache_read_req_LQ_index,
    output daddr_t dcache_read_req_addr,
    output logic dcache_read_req_linked,
    output logic dcache_read_req_conditional,
    input logic dcache_read_req_blocked,

    // read resp interface:
    //      - valid
    //      - LQ index
    //      - read data

    input logic dcache_read_resp_valid,
    input LQ_index_t dcache_read_resp_LQ_index,
    input word_t dcache_read_resp_data,

    // write req interface:
    //      - valid
    //      - addr
    //      - write data
    //      - conditional
    //      - blocked

    output logic dcache_write_req_valid,
    output daddr_t dcache_write_req_addr,
    output word_t dcache_write_req_data,
    output logic dcache_write_req_conditional,
    input logic dcache_write_req_blocked,

    // read kill interface x2:
    //      - valid
    //      - LQ index
        // just means cancel response to datapath so don't mix up with later request at same LQ index
            // d$'s job to figure out how to cancel
                // e.g. MSHR can get response but don't propagate upward into datapath
            // may also get cancel soon enough that can prevent MSHR bus request
        // 0: datapath ROB index kill load, kill dcache read req
        // 1: SQ forward, kill unneeded dcache read req

    output logic dcache_read_kill_0_valid,
    output LQ_index_t dcache_read_kill_0_LQ_index,
    output logic dcache_read_kill_1_valid,
    output LQ_index_t dcache_read_kill_1_LQ_index,

    // invalidation interface:
    //      - valid
    //      - inv address

    input logic dcache_inv_valid,
    input block_addr_t dcache_inv_block_addr,

    // halt interface:
    //      - halt

    output logic dcache_halt,

    ///////////////////
    // shared buses: //
    ///////////////////

    // complete bus 0 (ALU 0)
    input logic complete_bus_0_tag_valid,
    input phys_reg_tag_t complete_bus_0_tag,
    input word_t complete_bus_0_data,

    // complete bus 1 (ALU 1)
    input logic complete_bus_1_tag_valid,
    input phys_reg_tag_t complete_bus_1_tag,
    input word_t complete_bus_1_data,

    // complete bus 2 (LQ)
    input logic complete_bus_2_tag_valid,
    input phys_reg_tag_t complete_bus_2_tag,
    input word_t complete_bus_2_data
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

    // sub-unit DUT errors

    logic SQ_operand_pipeline_DUT_error;
    logic LQ_operand_pipeline_DUT_error;
    logic central_LSQ_DUT_error;

    always_comb begin

        // top level DUT error is OR of sub-unit DUT errors
        next_DUT_error = |{
            SQ_operand_pipeline_DUT_error, 
            LQ_operand_pipeline_DUT_error, 
            central_LSQ_DUT_error
        };
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // SQ Operand Pipeline: 

    logic SQ_reg_read_busy;

    // array pointers
    typedef struct packed {
        logic msb;
        logic [LOG_SQ_DEPTH-1:0] index;
    } SQ_ptr_t;
    // head
    SQ_ptr_t SQ_head_ptr;
    SQ_ptr_t next_SQ_head_ptr;
    // tail
    SQ_ptr_t SQ_tail_ptr;
    SQ_ptr_t next_SQ_tail_ptr;
        // defined up here so SQ operand pipeline can use

    // array pointers
    typedef struct packed {
        logic msb;
        logic [LOG_LQ_DEPTH-1:0] index;
    } LQ_ptr_t;
    // head
    LQ_ptr_t LQ_head_ptr;
    LQ_ptr_t next_LQ_head_ptr;
    // tail
    LQ_ptr_t LQ_tail_ptr;
    LQ_ptr_t next_LQ_tail_ptr;
    // SQ search ptr
    LQ_ptr_t LQ_SQ_search_ptr;
    LQ_ptr_t next_LQ_SQ_search_ptr;
        // defined up here so LQ operand pipeline can use

    ///////////////////////////////////////////////////////
    // Dispatch Stage -> | Latch | -> SQ Reg Read Stage: 

    // SQ dispatch stage side:

    logic SQ_operand_task_valid;
    logic SQ_operand_task_source_0_ready;
    phys_reg_tag_t SQ_operand_task_source_0_phys_reg_tag;
    logic SQ_operand_task_source_1_ready;
    phys_reg_tag_t SQ_operand_task_source_1_phys_reg_tag;
    daddr_t SQ_operand_task_imm14;
    SQ_index_t SQ_operand_task_SQ_index;
    ROB_index_t SQ_operand_task_ROB_index;

    // SQ reg read stage side:

    logic SQ_reg_read_stage_valid;
    logic next_SQ_reg_read_stage_valid;

    logic SQ_reg_read_stage_source_0_ready;
    logic next_SQ_reg_read_stage_source_0_ready;

    phys_reg_tag_t SQ_reg_read_stage_source_0_phys_reg_tag;
    phys_reg_tag_t next_SQ_reg_read_stage_source_0_phys_reg_tag;

    logic SQ_reg_read_stage_source_1_ready;
    logic next_SQ_reg_read_stage_source_1_ready;

    phys_reg_tag_t SQ_reg_read_stage_source_1_phys_reg_tag;
    phys_reg_tag_t next_SQ_reg_read_stage_source_1_phys_reg_tag;

    daddr_t SQ_reg_read_stage_imm14;
    daddr_t next_SQ_reg_read_stage_imm14;
    
    SQ_index_t SQ_reg_read_stage_SQ_index;
    SQ_index_t next_SQ_reg_read_stage_SQ_index;

    ROB_index_t SQ_reg_read_stage_ROB_index;
    ROB_index_t next_SQ_reg_read_stage_ROB_index;

    ///////////////////////////////////////////////////////////
    // SQ Reg Read Stage -> | Latch | -> SQ Addr Calc Stage:

    // SQ reg read stage side:

    daddr_t SQ_reg_read_stage_reg_file_write_base_addr;
    word_t SQ_reg_read_stage_reg_file_write_data;
    logic SQ_reg_read_stage_operand_0_complete_bus_0_VTM;
    logic SQ_reg_read_stage_operand_0_complete_bus_1_VTM;
    logic SQ_reg_read_stage_operand_0_complete_bus_2_VTM;
    logic SQ_reg_read_stage_operand_1_complete_bus_0_VTM;
    logic SQ_reg_read_stage_operand_1_complete_bus_1_VTM;
    logic SQ_reg_read_stage_operand_1_complete_bus_2_VTM;

    // SQ addr calc stage side:

    logic SQ_addr_calc_stage_valid;
    logic next_SQ_addr_calc_stage_valid;

    daddr_t SQ_addr_calc_stage_reg_file_write_base_addr;
    daddr_t next_SQ_addr_calc_stage_reg_file_write_base_addr;

    word_t SQ_addr_calc_stage_reg_file_write_data;
    word_t next_SQ_addr_calc_stage_reg_file_write_data;
    
    daddr_t SQ_addr_calc_stage_imm14;
    daddr_t next_SQ_addr_calc_stage_imm14;
    
    SQ_index_t SQ_addr_calc_stage_SQ_index;
    SQ_index_t next_SQ_addr_calc_stage_SQ_index;

    logic [1:0] SQ_addr_calc_stage_operand_0_bus_select;
    logic [1:0] next_SQ_addr_calc_stage_operand_0_bus_select;

    logic [1:0] SQ_addr_calc_stage_operand_1_bus_select;
    logic [1:0] next_SQ_addr_calc_stage_operand_1_bus_select;

    /////////////////////////////////////////////////////////////////
    // SQ Addr Calc Stage -> | Latch | -> SQ Operand Update Stage:

    // SQ addr calc side:

    daddr_t SQ_addr_calc_stage_forwarded_write_base_addr;
    daddr_t SQ_addr_calc_stage_write_addr;
    word_t SQ_addr_calc_stage_forwarded_write_data;

    // SQ operand update stage side:

    logic SQ_operand_update_stage_valid;
    logic next_SQ_operand_update_stage_valid;

    daddr_t SQ_operand_update_stage_write_addr;
    daddr_t next_SQ_operand_update_stage_write_addr;

    word_t SQ_operand_update_stage_write_data;
    word_t next_SQ_operand_update_stage_write_data;

    SQ_index_t SQ_operand_update_stage_SQ_index;
    SQ_index_t next_SQ_operand_update_stage_SQ_index;

    ////////////
    // logic: 

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        
        if (~nRST) begin

            // SQ dispatch stage -> SQ reg read stage
            SQ_reg_read_stage_valid <= 1'b0;
            SQ_reg_read_stage_source_0_ready <= 1'b0;
            SQ_reg_read_stage_source_0_phys_reg_tag <= phys_reg_tag_t'(0);
            SQ_reg_read_stage_source_1_ready <= 1'b0;
            SQ_reg_read_stage_source_1_phys_reg_tag <= phys_reg_tag_t'(0);
            SQ_reg_read_stage_imm14 <= 14'h0;
            SQ_reg_read_stage_SQ_index <= SQ_index_t'(0);
            SQ_reg_read_stage_ROB_index <= ROB_index_t'(0);

            // SQ reg read stage -> SQ addr calc stage
            SQ_addr_calc_stage_valid <= 1'b0;
            SQ_addr_calc_stage_reg_file_write_base_addr <= daddr_t'(0);
            SQ_addr_calc_stage_reg_file_write_data <= 32'h0;
            SQ_addr_calc_stage_imm14 <= 14'h0;
            SQ_addr_calc_stage_SQ_index <= SQ_index_t'(0);
            SQ_addr_calc_stage_operand_0_bus_select <= 2'd3;
            SQ_addr_calc_stage_operand_1_bus_select <= 2'd3;

            // SQ addr calc stage -> SQ operand update stage
            SQ_operand_update_stage_valid <= 1'b0;
            SQ_operand_update_stage_write_addr <= daddr_t'(0);
            SQ_operand_update_stage_write_data <= 32'h0;
            SQ_operand_update_stage_SQ_index <= SQ_index_t'(0);
        end 

        else begin

            // SQ dispatch stage -> SQ reg read stage
            SQ_reg_read_stage_valid <= next_SQ_reg_read_stage_valid;
            SQ_reg_read_stage_source_0_ready <= next_SQ_reg_read_stage_source_0_ready;
            SQ_reg_read_stage_source_0_phys_reg_tag <= next_SQ_reg_read_stage_source_0_phys_reg_tag;
            SQ_reg_read_stage_source_1_ready <= next_SQ_reg_read_stage_source_1_ready;
            SQ_reg_read_stage_source_1_phys_reg_tag <= next_SQ_reg_read_stage_source_1_phys_reg_tag;
            SQ_reg_read_stage_imm14 <= next_SQ_reg_read_stage_imm14;
            SQ_reg_read_stage_SQ_index <= next_SQ_reg_read_stage_SQ_index;
            SQ_reg_read_stage_ROB_index <= next_SQ_reg_read_stage_ROB_index;

            // SQ reg read stage -> SQ addr calc stage
            SQ_addr_calc_stage_valid <= next_SQ_addr_calc_stage_valid;
            SQ_addr_calc_stage_reg_file_write_base_addr <= next_SQ_addr_calc_stage_reg_file_write_base_addr;
            SQ_addr_calc_stage_reg_file_write_data <= next_SQ_addr_calc_stage_reg_file_write_data;
            SQ_addr_calc_stage_imm14 <= next_SQ_addr_calc_stage_imm14;
            SQ_addr_calc_stage_SQ_index <= next_SQ_addr_calc_stage_SQ_index;
            SQ_addr_calc_stage_operand_0_bus_select <= next_SQ_addr_calc_stage_operand_0_bus_select;
            SQ_addr_calc_stage_operand_1_bus_select <= next_SQ_addr_calc_stage_operand_1_bus_select;

            // SQ addr calc stage -> SQ operand update stage
            SQ_operand_update_stage_valid <= next_SQ_operand_update_stage_valid;
            SQ_operand_update_stage_write_addr <= next_SQ_operand_update_stage_write_addr;
            SQ_operand_update_stage_write_data <= next_SQ_operand_update_stage_write_data;
            SQ_operand_update_stage_SQ_index <= next_SQ_operand_update_stage_SQ_index;
        end
    end

    // comb logic
    always_comb begin

        ///////////////////////
        // reg file outputs: //
        ///////////////////////

        SQ_reg_read_stage_reg_file_write_base_addr = SQ_reg_read_bus_0_data[15:2];
        SQ_reg_read_stage_reg_file_write_data = SQ_reg_read_bus_1_data;

        //////////////////////
        // default outputs: //
        //////////////////////

        // no DUT error
        SQ_operand_pipeline_DUT_error = 1'b0;

        // not busy
        SQ_reg_read_busy = 1'b0;

        // reg file read req invalid
        SQ_reg_read_req_valid = 1'b0;
            // will depend on if 1 or more operands ready in reg file and not getting killed
        SQ_reg_read_req_0_tag = SQ_reg_read_stage_source_0_phys_reg_tag;
        SQ_reg_read_req_1_tag = SQ_reg_read_stage_source_1_phys_reg_tag;

        // hold latch state for reg read stage
        next_SQ_reg_read_stage_valid = SQ_reg_read_stage_valid;
        next_SQ_reg_read_stage_source_0_ready = SQ_reg_read_stage_source_0_ready;
        next_SQ_reg_read_stage_source_0_phys_reg_tag = SQ_reg_read_stage_source_0_phys_reg_tag;
        next_SQ_reg_read_stage_source_1_ready = SQ_reg_read_stage_source_1_ready;
        next_SQ_reg_read_stage_source_1_phys_reg_tag = SQ_reg_read_stage_source_1_phys_reg_tag;
        next_SQ_reg_read_stage_imm14 = SQ_reg_read_stage_imm14;
        next_SQ_reg_read_stage_SQ_index = SQ_reg_read_stage_SQ_index;
        next_SQ_reg_read_stage_ROB_index = SQ_reg_read_stage_ROB_index;

        // invalid addr calc stage taking from reg read stage
        next_SQ_addr_calc_stage_valid = 1'b0;
        next_SQ_addr_calc_stage_reg_file_write_base_addr = SQ_reg_read_stage_reg_file_write_base_addr;
        next_SQ_addr_calc_stage_reg_file_write_data = SQ_reg_read_stage_reg_file_write_data;
        next_SQ_addr_calc_stage_imm14 = SQ_reg_read_stage_imm14;
        next_SQ_addr_calc_stage_SQ_index = SQ_reg_read_stage_SQ_index;
        next_SQ_addr_calc_stage_operand_0_bus_select = 2'd3;    // default reg file val
        next_SQ_addr_calc_stage_operand_1_bus_select = 2'd3;    // default reg file val

        // // operand update stage taking from addr calc stage
        // next_SQ_operand_update_stage_valid = SQ_addr_calc_stage_valid;
        // next_SQ_operand_update_stage_write_addr = SQ_addr_calc_stage_write_addr;
        // next_SQ_operand_update_stage_write_data = SQ_addr_calc_stage_forwarded_write_data;
        // next_SQ_operand_update_stage_SQ_index = SQ_addr_calc_stage_SQ_index;
            // have to move to end so get propagated values

        ///////////////////////////////////
        // complete bus tag match logic: //
        ///////////////////////////////////

        SQ_reg_read_stage_operand_0_complete_bus_0_VTM = complete_bus_0_tag_valid & (
            SQ_reg_read_stage_source_0_phys_reg_tag == complete_bus_0_tag);
        SQ_reg_read_stage_operand_0_complete_bus_1_VTM = complete_bus_1_tag_valid & (
            SQ_reg_read_stage_source_0_phys_reg_tag == complete_bus_1_tag);
        SQ_reg_read_stage_operand_0_complete_bus_2_VTM = complete_bus_2_tag_valid & (
            SQ_reg_read_stage_source_0_phys_reg_tag == complete_bus_2_tag);
        SQ_reg_read_stage_operand_1_complete_bus_0_VTM = complete_bus_0_tag_valid & (
            SQ_reg_read_stage_source_1_phys_reg_tag == complete_bus_0_tag);
        SQ_reg_read_stage_operand_1_complete_bus_1_VTM = complete_bus_1_tag_valid & (
            SQ_reg_read_stage_source_1_phys_reg_tag == complete_bus_1_tag);
        SQ_reg_read_stage_operand_1_complete_bus_2_VTM = complete_bus_2_tag_valid & (
            SQ_reg_read_stage_source_1_phys_reg_tag == complete_bus_2_tag);

        ///////////////////////////
        // reg read stage logic: //
        ///////////////////////////

        // valid task in reg read stage
        if (SQ_reg_read_stage_valid) begin

            // check for kill
            if (kill_bus_valid & SQ_reg_read_stage_ROB_index == kill_bus_ROB_index) begin

                // not busy
                SQ_reg_read_busy = 1'b0;

                // invalidate reg read stage and addr calc stage
                next_SQ_reg_read_stage_valid = 1'b0;
                next_SQ_addr_calc_stage_valid = 1'b0;
            end

            // otherwise, try to move to addr calc stage
            else begin

                // know need both operand 0 and operand 1

                // operand 0 ready, operand 1 ready
                if (SQ_reg_read_stage_source_0_ready & SQ_reg_read_stage_source_1_ready) begin

                    // give read req
                    SQ_reg_read_req_valid = 1'b1;

                    // succeed if reg read req succeeds
                    if (SQ_reg_read_req_serviced) begin

                        // move to addr calc stage with raw operand 0 and raw operand 1
                        next_SQ_addr_calc_stage_valid = 1'b1;
                        next_SQ_addr_calc_stage_operand_0_bus_select = 2'd3;
                        next_SQ_addr_calc_stage_operand_1_bus_select = 2'd3;

                        // not busy
                        SQ_reg_read_busy = 1'b0;

                        // invalidate reg read stage task
                        next_SQ_reg_read_stage_valid = 1'b0;
                    end

                    // otherwise, fail, stay in reg read stage
                    else begin

                        // busy
                        SQ_reg_read_busy = 1'b1;
                    end
                end

                // operand 0 ready, operand 1 VTM
                else if (
                    SQ_reg_read_stage_source_0_ready & (
                        SQ_reg_read_stage_operand_1_complete_bus_0_VTM |
                        SQ_reg_read_stage_operand_1_complete_bus_1_VTM |
                        SQ_reg_read_stage_operand_1_complete_bus_2_VTM
                    )
                ) begin

                    // give read req
                    SQ_reg_read_req_valid = 1'b1;

                    // succeed if reg read req succeeds
                    if (SQ_reg_read_req_serviced) begin

                        // move to addr calc stage with raw operand 0
                        next_SQ_addr_calc_stage_valid = 1'b1;
                        next_SQ_addr_calc_stage_operand_0_bus_select = 2'd3;

                        // select corresponding bus for operand 1
                        if (SQ_reg_read_stage_operand_1_complete_bus_0_VTM) begin
                            next_SQ_addr_calc_stage_operand_1_bus_select = 2'd0;
                        end 
                        else if (SQ_reg_read_stage_operand_1_complete_bus_1_VTM) begin
                            next_SQ_addr_calc_stage_operand_1_bus_select = 2'd1;
                        end
                        else if (SQ_reg_read_stage_operand_1_complete_bus_2_VTM) begin
                            next_SQ_addr_calc_stage_operand_1_bus_select = 2'd2;
                        end
                        else begin
                            $display("lsq: SQ Operand Pipeline: ERROR: operand 1 VTM but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            SQ_operand_pipeline_DUT_error = 1'b1;
                        end

                        // not busy
                        SQ_reg_read_busy = 1'b0;

                        // invalidate reg read stage task
                        next_SQ_reg_read_stage_valid = 1'b0;
                    end

                    // otherwise, fail, stay in reg read stage
                    else begin

                        // busy
                        SQ_reg_read_busy = 1'b1;

                        // mark operand 1 ready
                        next_SQ_reg_read_stage_source_1_ready = 1'b1;
                    end
                end

                // operand 1 ready, operand 0 VTM
                else if (
                    SQ_reg_read_stage_source_1_ready & (
                        SQ_reg_read_stage_operand_0_complete_bus_0_VTM |
                        SQ_reg_read_stage_operand_0_complete_bus_1_VTM |
                        SQ_reg_read_stage_operand_0_complete_bus_2_VTM
                    )
                ) begin

                    // give read req
                    SQ_reg_read_req_valid = 1'b1;

                    // succeed if reg read req succeeds
                    if (SQ_reg_read_req_serviced) begin

                        // move to addr calc stage with raw operand 1
                        next_SQ_addr_calc_stage_valid = 1'b1;
                        next_SQ_addr_calc_stage_operand_1_bus_select = 2'd3;

                        // select corresponding bus for operand 0
                        if (SQ_reg_read_stage_operand_0_complete_bus_0_VTM) begin
                            next_SQ_addr_calc_stage_operand_0_bus_select = 2'd0;
                        end 
                        else if (SQ_reg_read_stage_operand_0_complete_bus_1_VTM) begin
                            next_SQ_addr_calc_stage_operand_0_bus_select = 2'd1;
                        end
                        else if (SQ_reg_read_stage_operand_0_complete_bus_2_VTM) begin
                            next_SQ_addr_calc_stage_operand_0_bus_select = 2'd2;
                        end
                        else begin
                            $display("lsq: SQ Operand Pipeline: ERROR: operand 0 VTM but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            SQ_operand_pipeline_DUT_error = 1'b1;
                        end

                        // not busy
                        SQ_reg_read_busy = 1'b0;

                        // invalidate reg read stage task
                        next_SQ_reg_read_stage_valid = 1'b0;
                    end

                    // otherwise, fail, stay in reg read stage
                    else begin

                        // busy
                        SQ_reg_read_busy = 1'b1;

                        // mark operand 0 ready
                        next_SQ_reg_read_stage_source_0_ready = 1'b1;
                    end
                end

                // operand 0 VTM and operand 1 VTM
                else if (
                    (
                        SQ_reg_read_stage_operand_0_complete_bus_0_VTM |
                        SQ_reg_read_stage_operand_0_complete_bus_1_VTM |
                        SQ_reg_read_stage_operand_0_complete_bus_2_VTM
                    ) & (
                        SQ_reg_read_stage_operand_1_complete_bus_0_VTM |
                        SQ_reg_read_stage_operand_1_complete_bus_1_VTM |
                        SQ_reg_read_stage_operand_1_complete_bus_2_VTM
                    )
                ) begin

                    // don't need read req

                    // move to addr calc stage
                    next_SQ_addr_calc_stage_valid = 1'b1;

                    // select corresponding bus for operand 0
                    if (SQ_reg_read_stage_operand_0_complete_bus_0_VTM) begin
                        next_SQ_addr_calc_stage_operand_0_bus_select = 2'd0;
                    end 
                    else if (SQ_reg_read_stage_operand_0_complete_bus_1_VTM) begin
                        next_SQ_addr_calc_stage_operand_0_bus_select = 2'd1;
                    end
                    else if (SQ_reg_read_stage_operand_0_complete_bus_2_VTM) begin
                        next_SQ_addr_calc_stage_operand_0_bus_select = 2'd2;
                    end
                    else begin
                        $display("lsq: SQ Operand Pipeline: ERROR: operand 0 VTM but no individual VTM");
                        $display("\t@: %0t",$realtime);
                        SQ_operand_pipeline_DUT_error = 1'b1;
                    end

                    // select corresponding bus for operand 1
                    if (SQ_reg_read_stage_operand_1_complete_bus_0_VTM) begin
                        next_SQ_addr_calc_stage_operand_1_bus_select = 2'd0;
                    end 
                    else if (SQ_reg_read_stage_operand_1_complete_bus_1_VTM) begin
                        next_SQ_addr_calc_stage_operand_1_bus_select = 2'd1;
                    end
                    else if (SQ_reg_read_stage_operand_1_complete_bus_2_VTM) begin
                        next_SQ_addr_calc_stage_operand_1_bus_select = 2'd2;
                    end
                    else begin
                        $display("lsq: SQ Operand Pipeline: ERROR: operand 1 VTM but no individual VTM");
                        $display("\t@: %0t",$realtime);
                        SQ_operand_pipeline_DUT_error = 1'b1;
                    end

                    // not busy
                    SQ_reg_read_busy = 1'b0;

                    // invalidate reg read stage task
                    next_SQ_reg_read_stage_valid = 1'b0;
                end

                // otherwise, can't move to addr calc stage, but can mark single ready
                else begin

                    // busy
                    SQ_reg_read_busy = 1'b1;

                    // mark ready if VTM on operand 0
                    if (
                        SQ_reg_read_stage_operand_0_complete_bus_0_VTM |
                        SQ_reg_read_stage_operand_0_complete_bus_1_VTM |
                        SQ_reg_read_stage_operand_0_complete_bus_2_VTM
                    ) begin
                        next_SQ_reg_read_stage_source_0_ready = 1'b1;
                    end

                    // mark ready if VTM on operand 1
                    if (
                        SQ_reg_read_stage_operand_1_complete_bus_0_VTM |
                        SQ_reg_read_stage_operand_1_complete_bus_1_VTM |
                        SQ_reg_read_stage_operand_1_complete_bus_2_VTM
                    ) begin
                        next_SQ_reg_read_stage_source_1_ready = 1'b1;
                    end
                end
            end
        end

        /////////////////////////
        // operand task logic: //
        /////////////////////////

        // translate top level inputs into operand task
        SQ_operand_task_valid = dispatch_unit_SQ_task_valid;
        SQ_operand_task_source_0_ready = dispatch_unit_SQ_task_struct.source_0.ready;
        SQ_operand_task_source_0_phys_reg_tag = dispatch_unit_SQ_task_struct.source_0.phys_reg_tag;
        SQ_operand_task_source_1_ready = dispatch_unit_SQ_task_struct.source_1.ready;
        SQ_operand_task_source_1_phys_reg_tag = dispatch_unit_SQ_task_struct.source_1.phys_reg_tag;
        SQ_operand_task_imm14 = dispatch_unit_SQ_task_struct.imm14;
        SQ_operand_task_SQ_index = SQ_tail_ptr.index;
        SQ_operand_task_ROB_index = dispatch_unit_SQ_task_struct.ROB_index;

        // take in operand task if valid
            // put this after reg read state logic so that can take in new task after kill detected
        if (SQ_operand_task_valid) begin

            // pass in values
            next_SQ_reg_read_stage_valid = 1'b1;
            next_SQ_reg_read_stage_source_0_ready = SQ_operand_task_source_0_ready;
            next_SQ_reg_read_stage_source_0_phys_reg_tag = SQ_operand_task_source_0_phys_reg_tag;
            next_SQ_reg_read_stage_source_1_ready = SQ_operand_task_source_1_ready;
            next_SQ_reg_read_stage_source_1_phys_reg_tag = SQ_operand_task_source_1_phys_reg_tag;
            next_SQ_reg_read_stage_imm14 = SQ_operand_task_imm14;
            next_SQ_reg_read_stage_SQ_index = SQ_operand_task_SQ_index;
            next_SQ_reg_read_stage_ROB_index = SQ_operand_task_ROB_index;
        end

        ////////////////////////////
        // addr calc stage logic: //
        ////////////////////////////

        // operand 0 complete bus data mux
            // for forwarded write base addr
        casez (SQ_addr_calc_stage_operand_0_bus_select) 
            2'd0:   SQ_addr_calc_stage_forwarded_write_base_addr = complete_bus_0_data[15:2];
            2'd1:   SQ_addr_calc_stage_forwarded_write_base_addr = complete_bus_1_data[15:2];
            2'd2:   SQ_addr_calc_stage_forwarded_write_base_addr = complete_bus_2_data[15:2];
            2'd3:   SQ_addr_calc_stage_forwarded_write_base_addr = SQ_addr_calc_stage_reg_file_write_base_addr;
                                                                    // already selected out [15:2] in reg read stage
        endcase

        // operand 1 complete bus data mux
            // for forwarded write data
        casez (SQ_addr_calc_stage_operand_1_bus_select) 
            2'd0:   SQ_addr_calc_stage_forwarded_write_data = complete_bus_0_data;
            2'd1:   SQ_addr_calc_stage_forwarded_write_data = complete_bus_1_data;
            2'd2:   SQ_addr_calc_stage_forwarded_write_data = complete_bus_2_data;
            2'd3:   SQ_addr_calc_stage_forwarded_write_data = SQ_addr_calc_stage_reg_file_write_data;
        endcase

        // adder
        SQ_addr_calc_stage_write_addr = 
            SQ_addr_calc_stage_forwarded_write_base_addr 
            + 
            SQ_addr_calc_stage_imm14
        ;

        // operand update stage taking from addr calc stage
        next_SQ_operand_update_stage_valid = SQ_addr_calc_stage_valid;
        next_SQ_operand_update_stage_write_addr = SQ_addr_calc_stage_write_addr;
        next_SQ_operand_update_stage_write_data = SQ_addr_calc_stage_forwarded_write_data;
        next_SQ_operand_update_stage_SQ_index = SQ_addr_calc_stage_SQ_index;

    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // LQ Operand Pipeline:

    logic LQ_reg_read_busy;

    /////////////////////////////////////////////////////////
    // Dispatch Stage -> | Latched | -> LQ Reg Read Stage: 

    // LQ dispatch stage side:

    logic LQ_operand_task_valid;
    logic LQ_operand_task_linked;
    logic LQ_operand_task_conditional;
    logic LQ_operand_task_source_ready;
    phys_reg_tag_t LQ_operand_task_source_phys_reg_tag;
    daddr_t LQ_operand_task_imm14;
    LQ_index_t LQ_operand_task_LQ_index;
    ROB_index_t LQ_operand_task_ROB_index;

    // LQ reg read stage side:

    logic LQ_reg_read_stage_valid;
    logic next_LQ_reg_read_stage_valid;

    logic LQ_reg_read_stage_linked;
    logic next_LQ_reg_read_stage_linked;

    logic LQ_reg_read_stage_conditional;
    logic next_LQ_reg_read_stage_conditional;

    logic LQ_reg_read_stage_source_ready;
    logic next_LQ_reg_read_stage_source_ready;

    phys_reg_tag_t LQ_reg_read_stage_source_phys_reg_tag;
    phys_reg_tag_t next_LQ_reg_read_stage_source_phys_reg_tag;

    daddr_t LQ_reg_read_stage_imm14;
    daddr_t next_LQ_reg_read_stage_imm14;

    LQ_index_t LQ_reg_read_stage_LQ_index;
    LQ_index_t next_LQ_reg_read_stage_LQ_index;

    ROB_index_t LQ_reg_read_stage_ROB_index;
    ROB_index_t next_LQ_reg_read_stage_ROB_index;

    ///////////////////////////////////////////////////////////
    // LQ Reg Read Stage -> | Latch | -> LQ Addr Calc Stage: 

    // LQ reg read stage side:

    daddr_t LQ_reg_read_stage_reg_file_read_base_addr;
    logic LQ_reg_read_stage_operand_complete_bus_0_VTM;
    logic LQ_reg_read_stage_operand_complete_bus_1_VTM;
    logic LQ_reg_read_stage_operand_complete_bus_2_VTM;

    // LQ addr calc stage side:

    logic LQ_addr_calc_stage_valid;
    logic next_LQ_addr_calc_stage_valid;

    logic LQ_addr_calc_stage_linked;
    logic next_LQ_addr_calc_stage_linked;

    logic LQ_addr_calc_stage_conditional;
    logic next_LQ_addr_calc_stage_conditional;

    daddr_t LQ_addr_calc_stage_reg_file_read_base_addr;
    daddr_t next_LQ_addr_calc_stage_reg_file_read_base_addr;

    daddr_t LQ_addr_calc_stage_imm14;
    daddr_t next_LQ_addr_calc_stage_imm14;

    LQ_index_t LQ_addr_calc_stage_LQ_index;
    LQ_index_t next_LQ_addr_calc_stage_LQ_index;

    logic [1:0] LQ_addr_calc_stage_operand_bus_select;
    logic [1:0] next_LQ_addr_calc_stage_operand_bus_select;

    /////////////////////////////////////////////////////////////////
    // LQ Addr Calc Stage -> | Latch | -> LQ Operand Update Stage: 

    // LQ addr calc side:

    daddr_t LQ_addr_calc_stage_forwarded_read_base_addr;
    daddr_t LQ_addr_calc_stage_read_addr;

    // LQ operand update stage side:

    logic LQ_operand_update_stage_valid;
    logic next_LQ_operand_update_stage_valid;
    
    logic LQ_operand_update_stage_linked;
    logic next_LQ_operand_update_stage_linked;

    logic LQ_operand_update_stage_conditional;
    logic next_LQ_operand_update_stage_conditional;

    daddr_t LQ_operand_update_stage_read_addr;
    daddr_t next_LQ_operand_update_stage_read_addr;

    LQ_index_t LQ_operand_update_stage_LQ_index;
    LQ_index_t next_LQ_operand_update_stage_LQ_index;

    ////////////
    // logic: 

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin

        if (~nRST) begin

            // LQ dispatch stage -> LQ reg read stage
            LQ_reg_read_stage_valid <= 1'b0;
            LQ_reg_read_stage_linked <= 1'b0;
            LQ_reg_read_stage_conditional <= 1'b0;
            LQ_reg_read_stage_source_ready <= 1'b0;
            LQ_reg_read_stage_source_phys_reg_tag <= phys_reg_tag_t'(0);
            LQ_reg_read_stage_imm14 <= 14'h0;
            LQ_reg_read_stage_LQ_index <= LQ_index_t'(0);
            LQ_reg_read_stage_ROB_index <= ROB_index_t'(0);

            // LQ reg read stage -> LQ addr calc stage
            LQ_addr_calc_stage_valid <= 1'b0;
            LQ_addr_calc_stage_linked <= 1'b0;
            LQ_addr_calc_stage_conditional <= 1'b0;
            LQ_addr_calc_stage_reg_file_read_base_addr <= daddr_t'(0);
            LQ_addr_calc_stage_imm14 <= 14'h0;
            LQ_addr_calc_stage_LQ_index <= LQ_index_t'(0);
            LQ_addr_calc_stage_operand_bus_select <= 2'd3;

            // LQ addr calc stage -> LQ operand update stage
            LQ_operand_update_stage_valid <= 1'b0;
            LQ_operand_update_stage_linked <= 1'b0;
            LQ_operand_update_stage_conditional <= 1'b0;
            LQ_operand_update_stage_read_addr <= daddr_t'(0);
            LQ_operand_update_stage_LQ_index <= LQ_index_t'(0);
        end

        else begin

            // LQ dispatch stage -> LQ reg read stage
            LQ_reg_read_stage_valid <= next_LQ_reg_read_stage_valid;
            LQ_reg_read_stage_linked <= next_LQ_reg_read_stage_linked;
            LQ_reg_read_stage_conditional <= next_LQ_reg_read_stage_conditional;
            LQ_reg_read_stage_source_ready <= next_LQ_reg_read_stage_source_ready;
            LQ_reg_read_stage_source_phys_reg_tag <= next_LQ_reg_read_stage_source_phys_reg_tag;
            LQ_reg_read_stage_imm14 <= next_LQ_reg_read_stage_imm14;
            LQ_reg_read_stage_LQ_index <= next_LQ_reg_read_stage_LQ_index;
            LQ_reg_read_stage_ROB_index <= next_LQ_reg_read_stage_ROB_index;

            // LQ reg read stage -> LQ addr calc stage
            LQ_addr_calc_stage_valid <= next_LQ_addr_calc_stage_valid;
            LQ_addr_calc_stage_linked <= next_LQ_addr_calc_stage_linked;
            LQ_addr_calc_stage_conditional <= next_LQ_addr_calc_stage_conditional;
            LQ_addr_calc_stage_reg_file_read_base_addr <= next_LQ_addr_calc_stage_reg_file_read_base_addr;
            LQ_addr_calc_stage_imm14 <= next_LQ_addr_calc_stage_imm14;
            LQ_addr_calc_stage_LQ_index <= next_LQ_addr_calc_stage_LQ_index;
            LQ_addr_calc_stage_operand_bus_select <= next_LQ_addr_calc_stage_operand_bus_select;

            // LQ addr calc stage -> LQ operand update stage
            LQ_operand_update_stage_valid <= next_LQ_operand_update_stage_valid;
            LQ_operand_update_stage_linked <= next_LQ_operand_update_stage_linked;
            LQ_operand_update_stage_conditional <= next_LQ_operand_update_stage_conditional;
            LQ_operand_update_stage_read_addr <= next_LQ_operand_update_stage_read_addr;
            LQ_operand_update_stage_LQ_index <= next_LQ_operand_update_stage_LQ_index;
        end
    end

    // comb logic
    always_comb begin

        ///////////////////////
        // reg file outputs: //
        ///////////////////////

        LQ_reg_read_stage_reg_file_read_base_addr = LQ_reg_read_bus_0_data[15:2];

        //////////////////////
        // default outputs: //
        //////////////////////

        // no DUT error
        LQ_operand_pipeline_DUT_error = 1'b0;

        // not busy
        LQ_reg_read_busy = 1'b0;

        // reg file read req invalid
        LQ_reg_read_req_valid = 1'b0;
            // will depend on if 1 or more operands ready in reg file and not getting killed
        LQ_reg_read_req_tag = LQ_reg_read_stage_source_phys_reg_tag;

        // hold latch state for reg read stage
        next_LQ_reg_read_stage_valid = LQ_reg_read_stage_valid;
        next_LQ_reg_read_stage_linked = LQ_reg_read_stage_linked;
        next_LQ_reg_read_stage_conditional = LQ_reg_read_stage_conditional;
        next_LQ_reg_read_stage_source_ready = LQ_reg_read_stage_source_ready;
        next_LQ_reg_read_stage_source_phys_reg_tag = LQ_reg_read_stage_source_phys_reg_tag;
        next_LQ_reg_read_stage_imm14 = LQ_reg_read_stage_imm14;
        next_LQ_reg_read_stage_LQ_index = LQ_reg_read_stage_LQ_index;
        next_LQ_reg_read_stage_ROB_index = LQ_reg_read_stage_ROB_index;

        // invalid addr calc stage taking from reg read stage
        next_LQ_addr_calc_stage_valid = 1'b0;
        next_LQ_addr_calc_stage_linked = LQ_reg_read_stage_linked;
        next_LQ_addr_calc_stage_conditional = LQ_reg_read_stage_conditional;
        next_LQ_addr_calc_stage_reg_file_read_base_addr = LQ_reg_read_stage_reg_file_read_base_addr;
        next_LQ_addr_calc_stage_imm14 = LQ_reg_read_stage_imm14;
        next_LQ_addr_calc_stage_LQ_index = LQ_reg_read_stage_LQ_index;
        next_LQ_addr_calc_stage_operand_bus_select = 2'd3;  // default reg file val

        // // operand update stage taking from addr calc stage
        // next_LQ_operand_update_stage_valid = LQ_addr_calc_stage_valid;
        // next_LQ_operand_update_stage_linked = LQ_addr_calc_stage_linked;
        // next_LQ_operand_update_stage_conditional = LQ_addr_calc_stage_conditional;
        // next_LQ_operand_update_stage_read_addr = LQ_addr_calc_stage_read_addr;
        // next_LQ_operand_update_stage_LQ_index = LQ_addr_calc_stage_LQ_index;
            // have to move to end so get propagated values

        ///////////////////////////////////
        // complete bus tag match logic: //
        ///////////////////////////////////

        LQ_reg_read_stage_operand_complete_bus_0_VTM = complete_bus_0_tag_valid & (
            LQ_reg_read_stage_source_phys_reg_tag == complete_bus_0_tag);
        LQ_reg_read_stage_operand_complete_bus_1_VTM = complete_bus_1_tag_valid & (
            LQ_reg_read_stage_source_phys_reg_tag == complete_bus_1_tag);
        LQ_reg_read_stage_operand_complete_bus_2_VTM = complete_bus_2_tag_valid & (
            LQ_reg_read_stage_source_phys_reg_tag == complete_bus_2_tag);

        ///////////////////////////
        // reg read stage logic: //
        ///////////////////////////

        // valid task in reg read stage
        if (LQ_reg_read_stage_valid) begin

            // check for kill
            if (kill_bus_valid & LQ_reg_read_stage_ROB_index == kill_bus_ROB_index) begin

                // not busy
                LQ_reg_read_busy = 1'b0;

                // invalidate reg read stage and addr calc stage
                next_LQ_reg_read_stage_valid = 1'b0;
                next_LQ_addr_calc_stage_valid = 1'b0;
            end

            // otherwise, try to move to addr calc stage
            else begin

                // check don't need operand (conditional)
                if (LQ_reg_read_stage_conditional) begin

                    // move to addr calc stage
                    next_LQ_addr_calc_stage_valid = 1'b1;

                    // not busy
                    LQ_reg_read_busy = 1'b0;

                    // invalidate reg read stage task
                    next_LQ_reg_read_stage_valid = 1'b0;
                end

                // otherwise, need operand
                else begin

                    // operand ready
                    if (LQ_reg_read_stage_source_ready) begin

                        // give read req
                        LQ_reg_read_req_valid = 1'b1;

                        // succeed if reg read req succeeds
                        if (LQ_reg_read_req_serviced) begin

                            // move to addr calc stage with raw operand
                            next_LQ_addr_calc_stage_valid = 1'b1;
                            next_LQ_addr_calc_stage_operand_bus_select = 2'd3;

                            // not busy
                            LQ_reg_read_busy = 1'b0;

                            // invalidate reg read stage task
                            next_LQ_reg_read_stage_valid = 1'b0;
                        end

                        // otherwise, fail, stay in reg read stage
                        else begin

                            // busy
                            LQ_reg_read_busy = 1'b1;
                        end
                    end

                    // operand VTM
                    else if (
                        LQ_reg_read_stage_operand_complete_bus_0_VTM |
                        LQ_reg_read_stage_operand_complete_bus_1_VTM |
                        LQ_reg_read_stage_operand_complete_bus_2_VTM
                    ) begin

                        // don't need read req

                        // move to addr calc stage
                        next_LQ_addr_calc_stage_valid = 1'b1;

                        // select corresponding bus for operand
                        if (LQ_reg_read_stage_operand_complete_bus_0_VTM) begin
                            next_LQ_addr_calc_stage_operand_bus_select = 2'd0;
                        end 
                        else if (LQ_reg_read_stage_operand_complete_bus_1_VTM) begin
                            next_LQ_addr_calc_stage_operand_bus_select = 2'd1;
                        end
                        else if (LQ_reg_read_stage_operand_complete_bus_2_VTM) begin
                            next_LQ_addr_calc_stage_operand_bus_select = 2'd2;
                        end
                        else begin
                            $display("lsq: LQ Operand Pipeline: ERROR: operand VTM but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            LQ_operand_pipeline_DUT_error = 1'b1;
                        end

                        // not busy
                        LQ_reg_read_busy = 1'b0;

                        // invalidate reg read stage task
                        next_LQ_reg_read_stage_valid = 1'b0;
                    end

                    // otherwise, can't move to addr calc stage
                    else begin

                        // busy 
                        LQ_reg_read_busy = 1'b1;
                    end
                end

            end
        end

        /////////////////////////
        // operand task logic: //
        /////////////////////////

        // translate top level inputs into operand task
        LQ_operand_task_valid = dispatch_unit_LQ_task_valid;
        LQ_operand_task_linked = (dispatch_unit_LQ_task_struct.op == LQ_LL);
        LQ_operand_task_conditional = (dispatch_unit_LQ_task_struct.op == LQ_SC);
        LQ_operand_task_source_ready = dispatch_unit_LQ_task_struct.source.ready;
        LQ_operand_task_source_phys_reg_tag = dispatch_unit_LQ_task_struct.source.phys_reg_tag;
        LQ_operand_task_imm14 = dispatch_unit_LQ_task_struct.imm14;
        LQ_operand_task_LQ_index = LQ_tail_ptr.index;
        LQ_operand_task_ROB_index = dispatch_unit_LQ_task_struct.ROB_index;

        // take in operand task if valid
            // put this after reg read state logic so that can take in new task after kill detected
        if (LQ_operand_task_valid) begin

            // pass in values
            next_LQ_reg_read_stage_valid = 1'b1;
            next_LQ_reg_read_stage_linked = LQ_operand_task_linked;
            next_LQ_reg_read_stage_conditional = LQ_operand_task_conditional;
            next_LQ_reg_read_stage_source_ready = LQ_operand_task_source_ready;
            next_LQ_reg_read_stage_source_phys_reg_tag = LQ_operand_task_source_phys_reg_tag;
            next_LQ_reg_read_stage_imm14 = LQ_operand_task_imm14;
            next_LQ_reg_read_stage_LQ_index = LQ_operand_task_LQ_index;
            next_LQ_reg_read_stage_ROB_index = LQ_operand_task_ROB_index;
        end

        ////////////////////////////
        // addr calc stage logic: //
        ////////////////////////////

        // operand complete bus data mux
            // for forwarded read base addr
        casez (LQ_addr_calc_stage_operand_bus_select)
            2'd0:   LQ_addr_calc_stage_forwarded_read_base_addr = complete_bus_0_data[15:2];
            2'd1:   LQ_addr_calc_stage_forwarded_read_base_addr = complete_bus_1_data[15:2];
            2'd2:   LQ_addr_calc_stage_forwarded_read_base_addr = complete_bus_2_data[15:2];
            2'd3:   LQ_addr_calc_stage_forwarded_read_base_addr = LQ_addr_calc_stage_reg_file_read_base_addr;
                                                                    // already selected out [15:2] in reg read stage
        endcase

        // adder
        LQ_addr_calc_stage_read_addr = 
            LQ_addr_calc_stage_forwarded_read_base_addr
            +
            LQ_addr_calc_stage_imm14
        ;

        // operand update stage taking from addr calc stage
        next_LQ_operand_update_stage_valid = LQ_addr_calc_stage_valid;
        next_LQ_operand_update_stage_linked = LQ_addr_calc_stage_linked;
        next_LQ_operand_update_stage_conditional = LQ_addr_calc_stage_conditional;
        next_LQ_operand_update_stage_read_addr = LQ_addr_calc_stage_read_addr;
        next_LQ_operand_update_stage_LQ_index = LQ_addr_calc_stage_LQ_index;

    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Central LSQ Signals and Regs:

        // LQ FIFO array
        // LQ enQ
        // LQ operand update
        // LQ retire CAM
        // LQ ROB index kill CAM
        // LQ deQ

        // SQ FIFO array
        // SQ enQ
        // SQ operand update
        // SQ retire CAM
        // SQ ROB index kill CAM
        // SQ deQ
        
        // SQ search CAM
        // LQ complete bus broadcast logic
        // LQ dcache invalidation CAM
        // SQ complete to ROB
        // LQ array halt
        // SQ array halt
        // LQ full
        // SQ full

        // d$ interface
        // remaining interfaces

        // LQ restart reg
        // LQ complete bus reg

    ////////////////////
    // LQ FIFO array: //
    ////////////////////

    // array
    LQ_entry_t [LQ_DEPTH-1:0] LQ_array, next_LQ_array;

    // // array pointers
    // typedef struct packed {
    //     logic msb;
    //     logic [LOG_LQ_DEPTH-1:0] index;
    // } LQ_ptr_t;
    // // head
    // LQ_ptr_t LQ_head_ptr;
    // LQ_ptr_t next_LQ_head_ptr;
    // // tail
    // LQ_ptr_t LQ_tail_ptr;
    // LQ_ptr_t next_LQ_tail_ptr;
    // // SQ search ptr
    // LQ_ptr_t LQ_SQ_search_ptr;
    // LQ_ptr_t next_LQ_SQ_search_ptr;
        // have to move above so can be used by LQ operand pipeline

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            LQ_array <= '0;
                // all 0's fine, really just need invalid
            LQ_head_ptr <= LQ_ptr_t'(0);
            LQ_tail_ptr <= LQ_ptr_t'(0);
            LQ_SQ_search_ptr <= LQ_ptr_t'(0);
        end
        else begin
            LQ_array <= next_LQ_array;
            LQ_head_ptr <= next_LQ_head_ptr;
            LQ_tail_ptr <= next_LQ_tail_ptr;
            LQ_SQ_search_ptr <= next_LQ_SQ_search_ptr;
        end 
    end

    // full/empty
    logic LQ_full;
        // top level output to dispatch unit can be called "full" if this full or d$ read req blocked
            // although d$ read req should only be blocked if all MSHR's waiting anyway
                // which means LQ full
            // OR also LQ operand pipeline reg read busy
    logic next_LQ_full;
    logic LQ_empty;
    logic next_LQ_empty;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // init empty
            LQ_full <= 1'b0;
            LQ_empty <= 1'b1;
        end
        else begin
            LQ_full <= next_LQ_full;
            LQ_empty <= next_LQ_empty;
        end 
    end

    /////////////
    // LQ enQ: //
    /////////////
        // just mess with LQ_array, ptr's, input LQ task struct

    ////////////////////////
    // LQ operand update: //
    ////////////////////////
        // just mess with LQ_array, LQ operand update stage

    ////////////////////
    // LQ retire CAM: //
    ////////////////////
        // just mess with LQ_array, retire, LQ blocked signal
        // check LQ entry valid, ready, searched

    ////////////////////////////
    // LQ ROB index kill CAM: //
    ////////////////////////////
        // just mess with LQ_array, kill, dcache read kill
        // can retract tail ptr if not enQing and previous entry is being killed
            // potentially messy if enqueue same cycle
            // should be uncommon case, fine with bubble

    /////////////
    // LQ deQ: //
    /////////////
        // just mess with LQ_array, ptr's, retire, kill
        // can check early deQ with retire logic and kill logic
            // read next valid

    ////////////////////
    // SQ FIFO array: //
    ////////////////////

    // array
    SQ_entry_t [SQ_DEPTH-1:0] SQ_array, next_SQ_array;

    // // array pointers
    // typedef struct packed {
    //     logic msb;
    //     logic [LOG_SQ_DEPTH-1:0] index;
    // } SQ_ptr_t;
    // // head
    // SQ_ptr_t SQ_head_ptr;
    // SQ_ptr_t next_SQ_head_ptr;
    // // tail
    // SQ_ptr_t SQ_tail_ptr;
    // SQ_ptr_t next_SQ_tail_ptr;
        // needs to be defined above so can be used in SQ operand pipeline

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            SQ_array <= '0;
                // all 0's fine, really just need invalid
            SQ_head_ptr <= SQ_ptr_t'(0);
            SQ_tail_ptr <= SQ_ptr_t'(0);
        end
        else begin
            SQ_array <= next_SQ_array;
            SQ_head_ptr <= next_SQ_head_ptr;
            SQ_tail_ptr <= next_SQ_tail_ptr;
        end 
    end

    // full/empty
    logic SQ_full;
        // top level output to dispatch unit can be "full" if this full or SQ operand pipeline reg read busy
    logic next_SQ_full;
    logic SQ_empty;
    logic next_SQ_empty;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // init empty
            SQ_full <= 1'b0;
            SQ_empty <= 1'b1;
        end
        else begin
            SQ_full <= next_SQ_full;
            SQ_empty <= next_SQ_empty;
        end 
    end

    /////////////
    // SQ enQ: //
    /////////////
        // just mess with SQ_array, ptr's, input SQ task struct

    ////////////////////////
    // SQ operand update: //
    ////////////////////////
        // just mess with SQ_array, SQ operand update stage

    ////////////////////
    // SQ retire CAM: //
    ////////////////////
        // mess with SQ_array, retire, SQ blocked signal
        // check SQ entry valid, ready, not blocked

    // reg b/w CAM result and d$ write req interface
    logic next_dcache_write_req_valid;
    daddr_t next_dcache_write_req_addr;
    word_t next_dcache_write_req_data;
    logic next_dcache_write_req_conditional;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // invalid registered d$ write req
            dcache_write_req_valid <= 1'b0;
            dcache_write_req_addr <= 14'h0;
            dcache_write_req_data <= 32'h0;
            dcache_write_req_conditional <= 1'b0;
        end
        else begin
            dcache_write_req_valid <= next_dcache_write_req_valid;
            dcache_write_req_addr <= next_dcache_write_req_addr;
            dcache_write_req_data <= next_dcache_write_req_data;
            dcache_write_req_conditional <= next_dcache_write_req_conditional;
        end 
    end

    ////////////////////////////
    // SQ ROB index kill CAM: //
    ////////////////////////////
        // just mess with SQ_array, kill
        // can retract tail ptr if not enQing and previous entry is being killed
            // potentially messy if enqueue same cycle
            // should be uncommon case, fine with bubble

    /////////////
    // SQ deQ: //
    /////////////
        // just mess with SQ_array, ptr's, retire, kill
        // can check early deQ with retire logic and kill logic
            // read next valid

    ////////////////////
    // SQ search CAM: //
    ////////////////////
        // mess with SQ_array, LQ_array, LQ_SQ_search_ptr

    // SQ search req
    logic SQ_search_req_valid;
    daddr_t SQ_search_req_read_addr;
    SQ_index_t SQ_search_req_SQ_index;

    // SQ search intermediate vals
    logic SQ_search_CAM_ambiguous;
    logic SQ_search_CAM_unwritten_present;
    SQ_index_t SQ_search_CAM_unwritten_youngest_older_index;
    word_t SQ_search_CAM_unwritten_youngest_older_data;
    logic SQ_search_CAM_written_present;
    SQ_index_t SQ_search_CAM_written_youngest_older_index;
    word_t SQ_search_CAM_written_youngest_older_data;

    // reg b/w CAM result and complete bus broadcast logic
    logic SQ_search_resp_valid;
    logic next_SQ_search_resp_valid;

    logic SQ_search_resp_present;
    logic next_SQ_search_resp_present;

    word_t SQ_search_resp_data;
    word_t next_SQ_search_resp_data;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // invalid registered SQ search CAM resp
            SQ_search_resp_valid <= 1'b0;
            SQ_search_resp_present <= 1'b0;
            SQ_search_resp_data <= 32'h0;
        end
        else begin
            SQ_search_resp_valid <= next_SQ_search_resp_valid;
            SQ_search_resp_present <= next_SQ_search_resp_present;
            SQ_search_resp_data <= next_SQ_search_resp_data;
        end 
    end

    //////////////////////////////////////
    // LQ complete bus broadcast logic: //
    //////////////////////////////////////
        // mess with LQ_array, complete bus, restart

    // register b/w tag transfer cycle and data transfer cycle
    logic next_this_complete_bus_data_valid;
    word_t next_this_complete_bus_data;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // invalid complete bus data transfer
            this_complete_bus_data_valid <= 1'b0;
            this_complete_bus_data <= 32'h0;
        end
        else begin
            this_complete_bus_data_valid <= next_this_complete_bus_data_valid;
            this_complete_bus_data <= next_this_complete_bus_data;
        end 
    end

    /////////////////////////////////
    // LQ dcache invalidation CAM: //
    /////////////////////////////////
        // just mess with LQ_array, dcache inv, restart

    // need to select b/w potential invalidation due to dcache inv vs. missed SQ forward
        // if both valid, pick older instr
    logic LQ_restart_missed_SQ_forward_valid;
    ROB_index_t LQ_restart_missed_SQ_forward_ROB_index;
    logic LQ_restart_dcache_inv_valid;
    LQ_index_t LQ_restart_dcache_inv_LQ_index;
    ROB_index_t LQ_restart_dcache_inv_ROB_index;

    /////////////////////////
    // SQ complete to ROB: //
    /////////////////////////
        // just mess with SQ_array, SQ operand update stage

    //////////////////////////
    // LQ array halt logic: //
    //////////////////////////
        // just mess with LQ_array, core control halt

    //////////////////////////
    // SQ array halt logic: //
    //////////////////////////
        // just mess with SQ_array, core control halt

    ////////////////////
    // LQ full logic: //
    ////////////////////
        // just mess with pointers, LQ reg read busy, d$ read req blocked

    ////////////////////
    // SQ full logic: //
    ////////////////////
        // just mess with pointers, SQ reg read busy

    ///////////////////
    // d$ interface: //
    ///////////////////
        // make assignments to d$ inferface signals based on Central LSQ Signals and Regs

    ///////////////////////////
    // remaining interfaces: //
    ///////////////////////////

    /////////////////////
    // LQ restart reg: //
    /////////////////////

    logic next_ROB_LQ_restart_valid;
    logic next_ROB_LQ_restart_after_instr;
    ROB_index_t next_ROB_LQ_restart_ROB_index;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            ROB_LQ_restart_valid <= 1'b0;
            ROB_LQ_restart_after_instr <= 1'b0;
            ROB_LQ_restart_ROB_index <= ROB_index_t'(0);
        end
        else begin
            ROB_LQ_restart_valid <= next_ROB_LQ_restart_valid;
            ROB_LQ_restart_after_instr <= next_ROB_LQ_restart_after_instr;
            ROB_LQ_restart_ROB_index <= next_ROB_LQ_restart_ROB_index;
        end
    end

    //////////////////////////
    // LQ complete bus reg: //
    //////////////////////////

    logic next_this_complete_bus_tag_valid;
    phys_reg_tag_t next_this_complete_bus_tag;
    ROB_index_t next_this_complete_bus_ROB_index;
    logic next_next_this_complete_bus_data_valid; // only needs to go to reg file
    word_t next_next_this_complete_bus_data;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            this_complete_bus_tag_valid <= 1'b0;
            this_complete_bus_tag <= phys_reg_tag_t'(0);
            this_complete_bus_ROB_index <= ROB_index_t'(0);
            next_this_complete_bus_data_valid <= 1'b0;
            next_this_complete_bus_data <= 32'h0;
        end
        else begin
            this_complete_bus_tag_valid <= next_this_complete_bus_tag_valid;
            this_complete_bus_tag <= next_this_complete_bus_tag;
            this_complete_bus_ROB_index <= next_this_complete_bus_ROB_index;
            next_this_complete_bus_data_valid <= next_next_this_complete_bus_data_valid;
            next_this_complete_bus_data <= next_next_this_complete_bus_data;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Central LSQ Logic:

    always_comb begin

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // default outputs: 

        // no DUT error
        central_LSQ_DUT_error = 1'b0;

        ////////////////////
        // LQ FIFO array: //
        ////////////////////

        // hold LQ array
        next_LQ_array = LQ_array;

        // hold LQ pointers
        next_LQ_head_ptr = LQ_head_ptr;
        next_LQ_tail_ptr = LQ_tail_ptr;
        next_LQ_SQ_search_ptr = LQ_SQ_search_ptr;

        // hold full/empty
            // logic at end of block so next_..._ptr values propagated

        /////////////
        // LQ enQ: //
        /////////////
            // just mess with LQ_array, ptr's

        ////////////////////////
        // LQ operand update: //
        ////////////////////////
            // just mess with LQ_array

        ////////////////////
        // LQ retire CAM: //
        ////////////////////
            // just mess with LQ_array, retire, LQ blocked signal
            // check LQ entry valid, ready, searched

        ////////////////////////////
        // LQ ROB index kill CAM: //
        ////////////////////////////
            // just mess with LQ_array, kill, dcache read kill
            // can retract tail ptr if not enQing and previous entry is being killed

        /////////////
        // LQ deQ: //
        /////////////
            // just mess with LQ_array, ptr's

        ////////////////////
        // SQ FIFO array: //
        ////////////////////

        // hold SQ array
        next_SQ_array = SQ_array;

        // hold SQ pointers
        next_SQ_head_ptr = SQ_head_ptr;
        next_SQ_tail_ptr = SQ_tail_ptr;

        /////////////
        // SQ enQ: //
        /////////////
            // just mess with SQ_array, ptr's

        ////////////////////////
        // SQ operand update: //
        ////////////////////////
            // just mess with SQ_array

        ////////////////////
        // SQ retire CAM: //
        ////////////////////
            // just mess with SQ_array, retire, SQ blocked signal
            // check SQ entry valid, ready, not blocked

        // invalid registered retire CAM result
        next_dcache_write_req_valid = 1'b0;
        next_dcache_write_req_addr = 14'h0;
        next_dcache_write_req_data = 32'h0;
        next_dcache_write_req_conditional = 1'b0;

        ////////////////////////////
        // SQ ROB index kill CAM: //
        ////////////////////////////
            // just mess with SQ_array, kill
            // can retract tail ptr if not enQing and previous entry is being killed

        /////////////
        // SQ deQ: //
        /////////////
            // just mess with SQ_array, ptr's

        ////////////////////
        // SQ search CAM: //
        ////////////////////
            // just mess with SQ_array, LQ_array, LQ_SQ_search_ptr

        // invalid SQ search req
        SQ_search_req_valid = 1'b0;
        SQ_search_req_read_addr = LQ_array[LQ_SQ_search_ptr.index].read_addr;
        SQ_search_req_SQ_index = LQ_array[LQ_SQ_search_ptr.index].SQ_index;

        // invalid registered search CAM resp
        next_SQ_search_resp_valid = 1'b0;
        next_SQ_search_resp_present = 1'b0;
        next_SQ_search_resp_data = 32'h0;
            // don't init this so CAM is simplified?

        //////////////////////////////////////
        // LQ complete bus broadcast logic: //
        //////////////////////////////////////
            // mess with LQ_array, complete bus, restart

        // invalid complete bus broadcast
        next_this_complete_bus_tag_valid = 1'b0;
        next_this_complete_bus_tag = LQ_array[LQ_SQ_search_ptr.index].dest_phys_reg_tag;
        next_this_complete_bus_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;
        next_next_this_complete_bus_data_valid = 1'b0;
        next_next_this_complete_bus_data = SQ_search_resp_data;

        /////////////////////////////////
        // LQ dcache invalidation CAM: //
        /////////////////////////////////
            // just mess with LQ_array, dcache inv, restart

        /////////////////////////
        // SQ complete to ROB: //
        /////////////////////////
            // just mess with SQ_array, SQ operand update stage

        //////////////////////////
        // LQ array halt logic: //
        //////////////////////////
            // just mess with LQ_array, core control halt

        //////////////////////////
        // SQ array halt logic: //
        //////////////////////////
            // just mess with SQ_array, core control halt

        //////////////////////////
        // LQ array full logic: //
        //////////////////////////
            // just mess with pointers, LQ reg read busy, d$ read req blocked

        //////////////////////////
        // SQ array full logic: //
        //////////////////////////
            // just mess with pointers, SQ reg read busy

        ///////////////////
        // d$ interface: //
        ///////////////////
            // make assignments to d$ inferface signals based on Central LSQ Signals and Regs
            // logic at end of block so Central LSQ Signals and Regs values propagated

        ///////////////////////////
        // remaining interfaces: //
        ///////////////////////////

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // logic implementation: 

        ////////////////////
        // LQ FIFO array: //
        ////////////////////
            // logic handled elsewhere

        /////////////
        // LQ enQ: //
        /////////////
        
        // enQ operand task at tail
            // job of dispatch unit to only assert dispatch_unit_LQ_task_valid if LQ not full
        if (dispatch_unit_LQ_task_valid) begin

            // write entry at tail
                // valid, not ready, not searched, not loaded
                // share some decoding from LQ operand pipeline
            next_LQ_array[LQ_tail_ptr.index].valid = 1'b1;
            next_LQ_array[LQ_tail_ptr.index].ready = 1'b0;
            next_LQ_array[LQ_tail_ptr.index].linked = LQ_operand_task_linked;
            next_LQ_array[LQ_tail_ptr.index].conditional = LQ_operand_task_conditional;
            next_LQ_array[LQ_tail_ptr.index].SQ_searched = 1'b0;
            next_LQ_array[LQ_tail_ptr.index].SQ_loaded = 1'b0;
            next_LQ_array[LQ_tail_ptr.index].dcache_loaded = 1'b0;
            next_LQ_array[LQ_tail_ptr.index].ROB_index = LQ_operand_task_ROB_index;
            next_LQ_array[LQ_tail_ptr.index].SQ_index = SQ_tail_ptr.index;
            next_LQ_array[LQ_tail_ptr.index].read_addr = 32'h0;
            next_LQ_array[LQ_tail_ptr.index].dest_phys_reg_tag = dispatch_unit_LQ_task_struct.dest_phys_reg_tag;

            // increment tail
            next_LQ_tail_ptr = LQ_tail_ptr + LQ_ptr_t'(1);

            // assert dispatch unit not asserting when shouldn't:
            if (dispatch_unit_LQ_full) begin
                $display("lsq: ERROR: dispatch unit enQing task when LQ busy");
                $display("\t@: %0t",$realtime);
                central_LSQ_DUT_error = 1'b1;
            end
        end

        ////////////////////////
        // LQ operand udpate: //
        ////////////////////////

        // write operand update at given index
            // make entry ready, update addr
        if (LQ_operand_update_stage_valid) begin
            next_LQ_array[LQ_operand_update_stage_LQ_index].ready = 1'b1;
            next_LQ_array[LQ_operand_update_stage_LQ_index].read_addr = LQ_operand_update_stage_read_addr;
        end

        ////////////////////
        // LQ retire CAM: //
        ////////////////////

        // default: retire not blocked
        ROB_LQ_retire_blocked = 1'b0;

        // CAM search ROB index's for retire ROB index
        if (ROB_LQ_retire_valid) begin

            for (int i = 0; i < LQ_DEPTH; i++) begin

                // check ROB index match
                if (ROB_LQ_retire_ROB_index == LQ_array[i].ROB_index) begin

                    // check entry valid
                    if (LQ_array[i].valid) begin

                        // if searched and loaded, fulfill retire: invalidate
                        if (LQ_array[i].SQ_searched & (LQ_array[i].SQ_loaded | LQ_array[i].dcache_loaded)) begin

                            next_LQ_array[i].valid = 1'b0;
                        end

                        // otherwise, need to block retire attempt
                        else begin
                            ROB_LQ_retire_blocked = 1'b1;
                        end
                    end

                    // otherwise, don't care, shouldn't happen
                        // can happen for retiring ROB index 0, don't care if invalid
                        // otherwise, shouldn't be invalid since should stay in SQ
                end
            end
        end

        ////////////////////////////
        // LQ ROB index kill CAM: //
        ////////////////////////////

        // default: no datapath kill sent to d$
        dcache_read_kill_0_valid = 1'b0;
        dcache_read_kill_0_LQ_index = LQ_index_t'(0);

        // CAM search for ROB index's for kill ROB index
        if (kill_bus_valid) begin

            for (int i = 0; i < LQ_DEPTH; i++) begin

                // could already be invalid, don't check valid since need to cancel still
                if (kill_bus_ROB_index == LQ_array[i].ROB_index) begin

                    // invalidate entry
                        // could already be invalid
                    next_LQ_array[i].valid = 1'b0;

                    // send kill to d$
                    dcache_read_kill_0_valid = 1'b1;
                    dcache_read_kill_0_LQ_index = LQ_index_t'(i);
                end
            end
        end

        /////////////
        // LQ deQ: //
        /////////////
            
        // deQ from head if LQ not empty, entry (going to be) invalid
        if (~LQ_empty & ~next_LQ_array[LQ_head_ptr.index].valid) begin

            // increment head
            next_LQ_head_ptr = LQ_head_ptr + LQ_ptr_t'(1);
        end

        ////////////////////
        // SQ FIFO array: //
        ////////////////////
            // logic handled elsewhere

        /////////////
        // SQ enQ: //
        /////////////
        
        // enQ operand task at tail
            // job of dispatch unit to only assert dispatch_unit_SQ_task_valid if SQ not full
        if (dispatch_unit_SQ_task_valid) begin

            // write entry at tail
                // valid, not ready
                // share some decoding from SQ operand pipeline
            next_SQ_array[SQ_tail_ptr.index].valid = 1'b1;
            next_SQ_array[SQ_tail_ptr.index].ready = 1'b0;
            next_SQ_array[SQ_tail_ptr.index].written = 1'b0;
            next_SQ_array[SQ_tail_ptr.index].conditional = (dispatch_unit_SQ_task_struct.op == SQ_SC);
            next_SQ_array[SQ_tail_ptr.index].ROB_index = SQ_operand_task_ROB_index;
            next_SQ_array[SQ_tail_ptr.index].write_addr = 14'h0;
            next_SQ_array[SQ_tail_ptr.index].write_data = 32'h0;
            
            // increment tail
            next_SQ_tail_ptr = SQ_tail_ptr + SQ_ptr_t'(1);
        end

        ////////////////////////
        // SQ operand update: //
        ////////////////////////

        // write operand update at given index
            // make entry ready, update addr, update data
        if (SQ_operand_update_stage_valid) begin
            next_SQ_array[SQ_operand_update_stage_SQ_index].ready = 1'b1;
            next_SQ_array[SQ_operand_update_stage_SQ_index].write_addr = SQ_operand_update_stage_write_addr;
            next_SQ_array[SQ_operand_update_stage_SQ_index].write_data = SQ_operand_update_stage_write_data;
        end

        ////////////////////
        // SQ retire CAM: //
        ////////////////////

        // store should already be complete if getting retire valid
        // should just come down to sending store to d$ if d$ not blocked

        // SQ retire blocked if d$ write req blocked
        ROB_SQ_retire_blocked = dcache_write_req_blocked;

        // CAM search SQ ROB index's for retire ROB index if not blocked
        if (ROB_SQ_retire_valid & ~dcache_write_req_blocked) begin

            for (int i = 0; i < SQ_DEPTH; i++) begin

                if (ROB_SQ_retire_ROB_index == SQ_array[i].ROB_index) begin

                    // check entry valid and not written
                    if (SQ_array[i].valid & ~SQ_array[i].written) begin

                        // can guarantee ready, ROB wouldn't be sending retire valid if wasn't complete

                        // send write req to d$ write req port based on CAM entry values
                        next_dcache_write_req_valid = 1'b1;
                        next_dcache_write_req_addr = SQ_array[i].write_addr;
                        next_dcache_write_req_data = SQ_array[i].write_data;
                        next_dcache_write_req_conditional = SQ_array[i].conditional;

                        // // invalidate entry
                        // next_SQ_array[i].valid = 1'b0;
                            // instead, mark written, still available to forward from with SQ search
                        next_SQ_array[i].written = 1'b1;
                    end

                    // otherwise, don't care, shouldn't happen
                        // can happen for retiring old ROB index, don't care if invalid
                        // otherwise, shouldn't be invalid since should stay in SQ
                end
            end
        end

        ////////////////////////////
        // SQ ROB index kill CAM: //
        ////////////////////////////

        // CAM search for ROB index's for kill ROB index
        if (kill_bus_valid) begin

            for (int i = 0; i < SQ_DEPTH; i++) begin

                if (kill_bus_ROB_index == SQ_array[i].ROB_index) begin

                    // invalidate entry
                        // prevent bad forwarding from written or unwritten
                    next_SQ_array[i].valid = 1'b0;
                end
            end
        end

        /////////////
        // SQ deQ: //
        /////////////

        // deQ from head if SQ not empty, entry (going to be) invalid or valid and (going to be) written
        if (~SQ_empty & 
            (
                ~next_SQ_array[SQ_head_ptr.index].valid
                |
                (
                    SQ_array[SQ_head_ptr.index].valid
                    &
                    next_SQ_array[SQ_head_ptr.index].written
                )
            )
        ) begin

            // increment head
            next_SQ_head_ptr = SQ_head_ptr + SQ_ptr_t'(1);
        end

        ////////////////////
        // SQ search CAM: //
        ////////////////////

        // invariants:
            // req, resp, or no req/resp is always related to current search pointer
                // means can't have lingering resp from old pointer val req
                // when get resp, deassert req

        // check if there can be search req, search resp at search pointer
        SQ_search_req_valid = 1'b0;
        if (LQ_array[LQ_SQ_search_ptr.index].valid & ~LQ_array[LQ_SQ_search_ptr.index].SQ_searched) begin

            // check for search resp
            if (SQ_search_resp_valid) begin
                
                // increment search pointer
                next_LQ_SQ_search_ptr = LQ_SQ_search_ptr + LQ_ptr_t'(1);

                // do logic for updating entry values as part of LQ complete bus broadcast logic
            end

            // otherwise, send req if ready and not LQ_SC, don't move on
            else if (LQ_array[LQ_SQ_search_ptr.index].ready & ~LQ_array[LQ_SQ_search_ptr.index].conditional) begin
                SQ_search_req_valid = 1'b1;
                next_LQ_SQ_search_ptr = LQ_SQ_search_ptr;
            end

            // otherwise, if LQ_SC, move on
            else if (LQ_array[LQ_SQ_search_ptr.index].conditional) begin

                // increment search pointer
                next_LQ_SQ_search_ptr = LQ_SQ_search_ptr + LQ_ptr_t'(1);
            end

            // otherwise, not ready, don't move on
            else begin
                next_LQ_SQ_search_ptr = LQ_SQ_search_ptr;
            end
        end

        // otherwise if invalid or already SQ searched (can happen if tail jumps around), not tail, increment search pointer
        else if (LQ_SQ_search_ptr != LQ_tail_ptr) begin
            next_LQ_SQ_search_ptr = LQ_SQ_search_ptr + LQ_ptr_t'(1);
        end 

        // // otherwise, invalid, LQ empty, so hold search pointer (should == head == tail)
        // else begin
        //     next_LQ_SQ_search_ptr = LQ_SQ_search_ptr;

        //     if (LQ_SQ_search_ptr != LQ_head_ptr) begin
        //         $display("lsq: Central LSQ: ERROR: LQ empty but LQ_SQ_search_ptr != LQ_head_ptr");
        //         $display("\t@: %0t",$realtime);
        //         central_LSQ_DUT_error = 1'b1;
        //     end
        // end
            // just don't want LQ_SQ_search_ptr to pass tail

        // // try to service request with CAM search
        // SQ_search_CAM_ambiguous = 1'b0;
        // SQ_search_CAM_present = 1'b0;
        // SQ_search_CAM_youngest_older_index = SQ_head_ptr.index;
        //     // safe init value should be head, which is oldest possible instr
        //     // don't init this so CAM is simplified?
        //         // if don't init, need way to find max without comparing to this signal
        // SQ_search_CAM_youngest_older_data = 32'h0;
        //     // don't init this so CAM is simplified?

        // if (SQ_search_req_valid) begin

        //     // CAM search through SQ
        //     for (int i = 0; i < SQ_DEPTH; i++) begin

        //         // check for valid and older
        //             // older -> less than
        //             // subtract from current head
        //             // compare against SQ tail when LQ was dispatched
        //         if (
        //             SQ_array[i].valid
        //             & 
        //             (
        //                 SQ_index_t'(i) - SQ_head_ptr.index
        //                 <
        //                 SQ_search_req_SQ_index - SQ_head_ptr.index
        //             )
        //         ) begin

        //             // potential optimization in here: use next ready and next write addr
        //                 // will likely be very costly since CAM checking non-reg outputs
        //                     // next values will be results of combinational logic muxing from 
        //                     //  SQ array or SQ operand update stage
        //                     // CAM must wait on this combination delay

        //             // check amgiguous addr (not ready)
        //             if (~SQ_array[i].ready) begin

        //                 // search is ambiguous
        //                 SQ_search_CAM_ambiguous = 1'b1;
        //             end

        //             // otherwise, addr ready, check addr match
        //             else if (
        //                 SQ_search_req_read_addr
        //                 ==
        //                 SQ_array[i].write_addr
        //             ) begin

        //                 // forwarding store is present
        //                 SQ_search_CAM_present = 1'b1;

        //                 // check new youngest
        //                     // younger -> greater than
        //                 if (
        //                     SQ_index_t'(i)
        //                     >
        //                     SQ_search_CAM_youngest_older_index
        //                 ) begin

        //                     // update youngest
        //                     SQ_search_CAM_youngest_older_index = SQ_index_t'(i);

        //                     // update youngest data
        //                     SQ_search_CAM_youngest_older_data = SQ_array[i].write_data;
        //                 end
        //             end
        //         end
        //     end

        //     // check for ambiguous
        //     if (SQ_search_CAM_ambiguous) begin

        //         // don't give resp
        //         next_SQ_search_resp_valid = 1'b0;
        //     end

        //     // otherwise, have successful search
        //     else begin

        //         // give resp valid
        //         next_SQ_search_resp_valid = 1'b1;

        //         // give resp present based on search
        //         next_SQ_search_resp_present = SQ_search_CAM_present;

        //         // give resp data based on search
        //         next_SQ_search_resp_data = SQ_search_CAM_youngest_older_data;
        //     end
        // end

        //////////////////////////////////////
        // LQ complete bus broadcast logic: //
        //////////////////////////////////////

        // LQ array updates are independent of what choose to broadcast
            // not true, if want to delay SQ search resp, don't think want to provide array updates
                // no, this should be fine as real conflict is when d$ and SQ search doing same load,
                //  already have logic handling this conflict (same as if on first cycle of SQ search resp)

        // dcache resp array updates
        if (dcache_read_resp_valid) begin

            // naively update array entry saying dcache loaded
                // may have been recently killed
            next_LQ_array[dcache_read_resp_LQ_index].dcache_loaded = 1'b1;

            // error if already loaded 
            if (LQ_array[dcache_read_resp_LQ_index].dcache_loaded) begin
                $display("lsq: ERROR: d$ read resp when already d$ loaded");
                $display("\t@: %0t",$realtime);
                central_LSQ_DUT_error = 1'b1;
            end

            // response when invalid
                // can happen if read req not killed soon enough
            if (~LQ_array[dcache_read_resp_LQ_index].valid) begin
                $display("lsq: INFO: d$ read resp on invalid LQ entry");
            end

            // response when not ready
                // can happen if read req not killed soon enough
            if (~LQ_array[dcache_read_resp_LQ_index].valid) begin
                $display("lsq: INFO: d$ read resp on not ready LQ entry");
            end
        end

        // SQ search resp array updates
        if (SQ_search_resp_valid) begin

            // naively update array entry saying SQ searched and SQ was loaded if it was present
            next_LQ_array[LQ_SQ_search_ptr.index].SQ_searched = 1'b1;
            next_LQ_array[LQ_SQ_search_ptr.index].SQ_loaded = SQ_search_resp_present;

            // // error if already SQ searched
            // if (LQ_array[LQ_SQ_search_ptr.index].SQ_searched) begin
            //     $display("lsq: ERROR: SQ search resp when already SQ searched");
            //     $display("\t@: %0t",$realtime);
            //     central_LSQ_DUT_error = 1'b1;
            // end
                // actually, this is okay, if ever get d$ read resp at same time, need to retry SQ search
        end

        //////////////////////
        // broadcast logic:

        // default: no missed SQ forward restart
        LQ_restart_missed_SQ_forward_valid = 1'b0;
        LQ_restart_missed_SQ_forward_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;

        // default: no SQ forward d$ read kill
        dcache_read_kill_1_valid = 1'b0;
        dcache_read_kill_1_LQ_index = LQ_SQ_search_ptr.index;
        
        // check for simultaneous valid d$ read resp and SQ search resp
        if (dcache_read_resp_valid & LQ_array[dcache_read_resp_LQ_index].valid & SQ_search_resp_valid) begin

            // check correspond to same load -> == LQ index
            if (
                dcache_read_resp_LQ_index
                ==
                LQ_SQ_search_ptr.index
            ) begin

                // if SQ search present, broadcast SQ value
                if (SQ_search_resp_present) begin

                    // valid complete bus broadcast from SQ
                    next_this_complete_bus_tag_valid = 1'b1;
                    next_this_complete_bus_tag = LQ_array[LQ_SQ_search_ptr.index].dest_phys_reg_tag;
                    next_this_complete_bus_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;
                    next_next_this_complete_bus_data_valid = 1'b1;
                    next_next_this_complete_bus_data = SQ_search_resp_data;

                    // no need to kill d$ read
                end

                // otherwise, broadcast d$ value
                else begin

                    // valid complete bus broadcast from d$
                    next_this_complete_bus_tag_valid = 1'b1;
                    next_this_complete_bus_tag = LQ_array[dcache_read_resp_LQ_index].dest_phys_reg_tag;
                    next_this_complete_bus_ROB_index = LQ_array[dcache_read_resp_LQ_index].ROB_index;
                    next_next_this_complete_bus_data_valid = 1'b1;
                    next_next_this_complete_bus_data = dcache_read_resp_data;
                end
            end

            // otherwise, different loads, prioritize dcache read resp
            else begin

                // check if d$ load already loaded from SQ
                if (LQ_array[dcache_read_resp_LQ_index].SQ_loaded) begin

                    // can service SQ search resp instead:

                    // check present
                    if (SQ_search_resp_present) begin

                        // valid complete bus broadcast from SQ
                        next_this_complete_bus_tag_valid = 1'b1;
                        next_this_complete_bus_tag = LQ_array[LQ_SQ_search_ptr.index].dest_phys_reg_tag;
                        next_this_complete_bus_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;
                        next_next_this_complete_bus_data_valid = 1'b1;
                        next_next_this_complete_bus_data = SQ_search_resp_data;
                    
                        // check for d$ loaded
                            // mis-speculated load, should have taken from SQ
                        if (LQ_array[LQ_SQ_search_ptr.index].dcache_loaded) begin

                            // send restart
                            LQ_restart_missed_SQ_forward_valid = 1'b1;
                            LQ_restart_missed_SQ_forward_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;
                        end

                        // otherwise, haven't finished d$ read yet, kill d$ read
                        else begin

                            // kill d$ read
                            dcache_read_kill_1_valid = 1'b1;
                            dcache_read_kill_1_LQ_index = LQ_SQ_search_ptr.index;
                        end
                    end
                end

                // otherwise, service d$ load:
                else begin

                    // valid complete bus broadcast from d$
                    next_this_complete_bus_tag_valid = 1'b1;
                    next_this_complete_bus_tag = LQ_array[dcache_read_resp_LQ_index].dest_phys_reg_tag;
                    next_this_complete_bus_ROB_index = LQ_array[dcache_read_resp_LQ_index].ROB_index;
                    next_next_this_complete_bus_data_valid = 1'b1;
                    next_next_this_complete_bus_data = dcache_read_resp_data;

                    // don't move SQ search on
                    SQ_search_req_valid = 1'b1;
                    next_LQ_SQ_search_ptr = LQ_SQ_search_ptr;
                end
            end
        end

        // otherwise, check for lone valid d$ read resp 
        else if (dcache_read_resp_valid & LQ_array[dcache_read_resp_LQ_index].valid) begin

            // service d$ load:

            // check d$ load entry valid and NOT already loaded from SQ
            if (~LQ_array[dcache_read_resp_LQ_index].SQ_loaded) begin

                // valid complete bus broadcast from d$
                next_this_complete_bus_tag_valid = 1'b1;
                next_this_complete_bus_tag = LQ_array[dcache_read_resp_LQ_index].dest_phys_reg_tag;
                next_this_complete_bus_ROB_index = LQ_array[dcache_read_resp_LQ_index].ROB_index;
                next_next_this_complete_bus_data_valid = 1'b1;
                next_next_this_complete_bus_data = dcache_read_resp_data;
            end
        end

        // otherwise, check for lone SQ search resp
        else if (SQ_search_resp_valid) begin

            // service SQ search load:

            // check present
            if (SQ_search_resp_present) begin

                // valid complete bus broadcast from SQ
                next_this_complete_bus_tag_valid = 1'b1;
                next_this_complete_bus_tag = LQ_array[LQ_SQ_search_ptr.index].dest_phys_reg_tag;
                next_this_complete_bus_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;
                next_next_this_complete_bus_data_valid = 1'b1;
                next_next_this_complete_bus_data = SQ_search_resp_data;
            
                // check for d$ loaded
                    // mis-speculated load, should have taken from SQ
                if (LQ_array[LQ_SQ_search_ptr.index].dcache_loaded) begin

                    // send restart
                    LQ_restart_missed_SQ_forward_valid = 1'b1;
                    LQ_restart_missed_SQ_forward_ROB_index = LQ_array[LQ_SQ_search_ptr.index].ROB_index;
                end

                // otherwise, haven't finished d$ read yet, kill d$ read
                else begin

                    // kill d$ read
                    dcache_read_kill_1_valid = 1'b1;
                    dcache_read_kill_1_LQ_index = LQ_SQ_search_ptr.index;
                end
            end
        end

        // try to service request with CAM search
        SQ_search_CAM_ambiguous = 1'b0;
        SQ_search_CAM_unwritten_present = 1'b0;
        SQ_search_CAM_unwritten_youngest_older_index = SQ_head_ptr.index;
            // safe init value should be head, which is oldest possible instr
            // don't init this so CAM is simplified?
                // if don't init, need way to find max without comparing to this signal
        SQ_search_CAM_unwritten_youngest_older_data = 32'h0;
            // don't init this so CAM is simplified?
        SQ_search_CAM_written_present = 1'b0;
        SQ_search_CAM_written_youngest_older_index = SQ_head_ptr.index;
            // safe init value should be head, which is oldest possible instr
            // don't init this so CAM is simplified?
                // if don't init, need way to find max without comparing to this signal
        SQ_search_CAM_written_youngest_older_data = 32'h0;
            // don't init this so CAM is simplified?

        if (SQ_search_req_valid) begin

            // CAM search through SQ
            for (int i = 0; i < SQ_DEPTH; i++) begin

                // check for valid, unwritten, and older
                    // older -> less than
                    // subtract from current head
                    // compare against SQ tail when LQ was dispatched
                if (
                    SQ_array[i].valid
                    & 
                    ~SQ_array[i].written
                    &
                    (
                        SQ_index_t'(i) - SQ_head_ptr.index
                        <
                        SQ_search_req_SQ_index - SQ_head_ptr.index
                    )
                ) begin

                    // potential optimization in here: use next ready and next write addr
                        // will likely be very costly since CAM checking non-reg outputs
                            // next values will be results of combinational logic muxing from 
                            //  SQ array or SQ operand update stage
                            // CAM must wait on this combination delay

                    // check amgiguous addr (not ready)
                    if (~SQ_array[i].ready) begin

                        // search is ambiguous
                        SQ_search_CAM_ambiguous = 1'b1;
                    end

                    // otherwise, addr ready, check addr match
                    else if (
                        SQ_search_req_read_addr
                        ==
                        SQ_array[i].write_addr
                    ) begin

                        // forwarding store is present
                        SQ_search_CAM_unwritten_present = 1'b1;

                        // check new youngest
                            // younger -> greater than
                            // subtract from current head
                            // check == since can be taking from oldest possible instr
                                // init value of SQ_search_CAM_youngest_older_index
                        if (
                            SQ_index_t'(i) - SQ_head_ptr.index
                            >=
                            SQ_search_CAM_unwritten_youngest_older_index - SQ_head_ptr.index
                        ) begin

                            // update youngest
                            SQ_search_CAM_unwritten_youngest_older_index = SQ_index_t'(i);

                            // update youngest data
                            SQ_search_CAM_unwritten_youngest_older_data = SQ_array[i].write_data;
                        end
                    end
                end

                // check for valid, written
                else if (
                    SQ_array[i].valid
                    & 
                    SQ_array[i].written
                ) begin

                    // check addr match
                    if (
                        SQ_search_req_read_addr
                        ==
                        SQ_array[i].write_addr
                    ) begin

                        // forwarding store is present
                        SQ_search_CAM_written_present = 1'b1;

                        // check new youngest
                            // younger -> greater than
                            // subtract from current head
                            // check == since can be taking from oldest possible instr
                                // init value of SQ_search_CAM_youngest_older_index
                        if (
                            SQ_index_t'(i) - SQ_head_ptr.index
                            >=
                            SQ_search_CAM_written_youngest_older_index - SQ_head_ptr.index
                        ) begin

                            // update youngest
                            SQ_search_CAM_written_youngest_older_index = SQ_index_t'(i);

                            // update youngest data
                            SQ_search_CAM_written_youngest_older_data = SQ_array[i].write_data;
                        end
                    end
                end
            end

            // check for ambiguous
            if (SQ_search_CAM_ambiguous) begin

                // don't give resp
                next_SQ_search_resp_valid = 1'b0;
            end

            // otherwise, have successful search
            else begin

                // give resp valid
                next_SQ_search_resp_valid = 1'b1;

                // give resp present based on search
                    // favor unwritten present, then written present

                // check unwritten present
                if (SQ_search_CAM_unwritten_present) begin

                    next_SQ_search_resp_present = 1'b1;

                    // give resp data based on unwritten search
                    next_SQ_search_resp_data = SQ_search_CAM_unwritten_youngest_older_data;
                end

                // otherwise, check written present
                else if (SQ_search_CAM_written_present) begin

                    next_SQ_search_resp_present = 1'b1;

                    // give resp data based on written search
                    next_SQ_search_resp_data = SQ_search_CAM_written_youngest_older_data;
                end

                
            end
        end

        /////////////////////////////////
        // LQ dcache invalidation CAM: //
        /////////////////////////////////

        // default: no dcache inv restart
        LQ_restart_dcache_inv_valid = 1'b0;
        LQ_restart_dcache_inv_LQ_index = LQ_index_t'(0);
        LQ_restart_dcache_inv_ROB_index = ROB_index_t'(0);

        // check for invalidation due to dcache inv
        if (dcache_inv_valid) begin

            // CAM search for addr match
            for (int i = 0; i < LQ_DEPTH; i++) begin

                // check for entry valid and block addr match
                if (
                    LQ_array[i].valid
                    &
                    (
                        dcache_inv_block_addr
                        ==
                        LQ_array[i].read_addr[13:1]
                    )
                ) begin

                    // only restart if this entry grabbed value from d$ load
                        // NOT SQ loaded, YES dcache loaded
                            // don't care if forwarding SQ value
                            // if haven't loaded from dcache yet, means 

                        // TODO: verify
                            // this behavior may have tricky edge case bugs which don't guarantee SeqC
                                // e.g.:
                                //  SW X
                                //  LW Y
                                //  LW X
                                //  inv Y
                                    // although here, would restart at invalidated LW Y, so
                                    //  LW X would get another try, potentially forward or not from SW X 
                    if (~LQ_array[i].SQ_loaded & LQ_array[i].dcache_loaded) begin

                        // have dcache inv restart
                        LQ_restart_dcache_inv_valid = 1'b1;
                        LQ_restart_dcache_inv_LQ_index = LQ_index_t'(i);
                        LQ_restart_dcache_inv_ROB_index = LQ_array[i].ROB_index;

                        // invalidate entry
                        next_LQ_array[i].valid = 1'b0;
                    end
                end
            end
        end

        // default: no top level restart
        next_ROB_LQ_restart_valid = 1'b0;
        next_ROB_LQ_restart_after_instr = 1'b0;
        next_ROB_LQ_restart_ROB_index = ROB_index_t'(0);

        // need to select b/w potential invalidation due to d$ inv vs. missed SQ forward
            // if both valid, pick older instr
            // set LQ tail to restarting instr
        if (LQ_restart_dcache_inv_valid & LQ_restart_missed_SQ_forward_valid) begin

            // definitely valid
            next_ROB_LQ_restart_valid = 1'b1;

            // check older instruction based on current head
                // they can be same instr
                // older -> less than

            // check d$ inv older
            if (
                LQ_restart_dcache_inv_ROB_index - ROB_LQ_retire_ROB_index
                <
                LQ_restart_missed_SQ_forward_ROB_index - ROB_LQ_retire_ROB_index
            ) begin

                // restart d$ inv
                next_ROB_LQ_restart_after_instr = 1'b0;
                next_ROB_LQ_restart_ROB_index = LQ_restart_dcache_inv_ROB_index;

                // tail follows d$ inv
                    // adjust msb still greater than head as expect
                    // if new tail index >= old tail index, then need to flip msb to undo wraparound
                next_LQ_tail_ptr = {
                    (LQ_restart_dcache_inv_LQ_index >= LQ_tail_ptr.index) ? 
                        ~LQ_tail_ptr.msb
                        :    
                        LQ_tail_ptr.msb
                    , 
                    LQ_restart_dcache_inv_LQ_index
                };
            end

            // otherwise, missed SQ forward older or same instr
            else begin

                // restart missed SQ forward
                next_ROB_LQ_restart_after_instr = 1'b1;
                next_ROB_LQ_restart_ROB_index = LQ_restart_missed_SQ_forward_ROB_index;

                // tail follows LQ entry after LQ SQ search ptr
                next_LQ_tail_ptr = LQ_SQ_search_ptr + LQ_ptr_t'(1);
            end
        end

        // otherwise, follow lone dcache inv
        else if (LQ_restart_dcache_inv_valid) begin

            // still valid (really just OR)
            next_ROB_LQ_restart_valid = 1'b1;

            // restart d$ inv
            next_ROB_LQ_restart_after_instr = 1'b0;
            next_ROB_LQ_restart_ROB_index = LQ_restart_dcache_inv_ROB_index;

            // tail follows d$ inv
                // adjust msb still greater than head as expect
                // if new tail index >= old tail index, then need to flip msb to undo wraparound
            next_LQ_tail_ptr = {
                (LQ_restart_dcache_inv_LQ_index >= LQ_tail_ptr.index) ? 
                    ~LQ_tail_ptr.msb
                    :    
                    LQ_tail_ptr.msb
                , 
                LQ_restart_dcache_inv_LQ_index
            };
        end

        // otherwise, follow lone missed SQ forward
        else if (LQ_restart_missed_SQ_forward_valid) begin

            // still valid (really just OR)
            next_ROB_LQ_restart_valid = 1'b1;

            // restart missed SQ forward
            next_ROB_LQ_restart_after_instr = 1'b1;
            next_ROB_LQ_restart_ROB_index = LQ_restart_missed_SQ_forward_ROB_index;

            // tail follows LQ entry after LQ SQ search ptr
            next_LQ_tail_ptr = LQ_SQ_search_ptr + LQ_ptr_t'(1);
        end

        /////////////////////////
        // SQ complete to ROB: //
        /////////////////////////

        // default: SQ complete invalid
        ROB_SQ_complete_valid = 1'b0;
        ROB_SQ_complete_ROB_index = ROB_index_t'(0);

        // complete if valid SQ operand update stage
            // have write addr and write data ready
        if (SQ_operand_update_stage_valid) begin

            // give valid
            ROB_SQ_complete_valid = 1'b1;

            // grab ROB index from SQ_array based on where operand update stage writing
            ROB_SQ_complete_ROB_index = SQ_array[SQ_operand_update_stage_SQ_index].ROB_index;
        end

        //////////////////////////
        // LQ array halt logic: //
        //////////////////////////

        // clear valids in LQ on halt
        if (core_control_halt) begin

            for (int i = 0; i < LQ_DEPTH; i++) begin
                next_LQ_array[i].valid = 1'b0;
            end
        end

        //////////////////////////
        // SQ array halt logic: //
        //////////////////////////

        // clear valids in SQ on halt
        if (core_control_halt) begin

            for (int i = 0; i < SQ_DEPTH; i++) begin
                next_SQ_array[i].valid = 1'b0;
            end
        end

        // ////////////////////
        // // LQ full logic: //
        // ////////////////////

        // // LQ full for dispatch if any of:
        //     // LQ full 
        //     // LQ reg read busy
        //     // d$ req blocked (shouldn't ever happen)
        // dispatch_unit_LQ_full = LQ_full | LQ_reg_read_busy | dcache_read_req_blocked;
            // needs to be in separate block

        // ////////////////////
        // // SQ full logic: //
        // ////////////////////

        // // SQ full for dispatch if any of:
        //     // SQ full
        //     // SQ reg read busy
        // dispatch_unit_SQ_full = SQ_full | SQ_reg_read_busy;
            // needs to be in separate block

        ///////////////////////
        // full/empty logic: //
        ///////////////////////

        // default outputs:

        // not full or empty
        next_LQ_full = 1'b0;
        next_LQ_empty = 1'b0;
        next_SQ_full = 1'b0;
        next_SQ_empty = 1'b0;

        // LQ: check for full/empty
        if (next_LQ_head_ptr.index == next_LQ_tail_ptr.index) begin

            // check for empty
            if (next_LQ_head_ptr.msb == next_LQ_tail_ptr.msb) begin
                next_LQ_empty = 1'b1;
            end

            // otherwise, full
            else begin
                next_LQ_full = 1'b1;
            end
        end

        // SQ: check for full/empty
        if (next_SQ_head_ptr.index == next_SQ_tail_ptr.index) begin

            // check for empty
            if (next_SQ_head_ptr.msb == next_SQ_tail_ptr.msb) begin
                next_SQ_empty = 1'b1;
            end

            // otherwise, full
            else begin
                next_SQ_full = 1'b1;
            end
        end

        ///////////////////
        // d$ interface: //
        ///////////////////

        // dcache read req:
            // take from LQ operand u pdate stage
        dcache_read_req_valid = LQ_operand_update_stage_valid;
        dcache_read_req_LQ_index = LQ_operand_update_stage_LQ_index;
        dcache_read_req_addr = LQ_operand_update_stage_read_addr;
        dcache_read_req_linked = LQ_operand_update_stage_linked;
        dcache_read_req_conditional = LQ_operand_update_stage_conditional;

        // dcache read resp:
            // all inputs

        // dcache write req:
            // already assigned by registered SQ retire CAM result

        // dcache read kill:
            // already assigned by LQ ROB index kill CAM logic

        // dcache invalidation:
            // all inputs

        // dcache halt:
        dcache_halt = core_control_halt;

        ///////////////////////////
        // remaining interfaces: //
        ///////////////////////////

        // // LQ interface
        // dispatch_unit_LQ_tail_index = LQ_tail_ptr.index;

        // // SQ interface
        // dispatch_unit_SQ_tail_index = SQ_tail_ptr.index;

    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // assigns:
        // these had to be pulled out of main always_comb else would not get correct assignment order

    ////////////////////
    // LQ full logic: //
    ////////////////////

    // LQ full for dispatch if any of:
        // LQ full 
        // LQ reg read busy
        // d$ req blocked (shouldn't ever happen)
    assign dispatch_unit_LQ_full = LQ_full | LQ_reg_read_busy | dcache_read_req_blocked;

    ////////////////////
    // SQ full logic: //
    ////////////////////

    // SQ full for dispatch if any of:
        // SQ full
        // SQ reg read busy
    assign dispatch_unit_SQ_full = SQ_full | SQ_reg_read_busy;

endmodule