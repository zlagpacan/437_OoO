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
    // input LQ_index_t LQ_tail_index,
    // input logic LQ_full,
    // output logic LQ_task_valid,
    // output LQ_enqueue_struct_t LQ_task_struct,

    output LQ_index_t LQ_tail_index,
    output logic LQ_full,
    input logic LQ_task_valid,
    input LQ_enqueue_struct_t LQ_task_struct,
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
    // input SQ_index_t SQ_tail_index,
    // input logic SQ_full,
    // output logic SQ_task_valid,
    // output SQ_enqueue_struct_t SQ_task_struct,

    output SQ_index_t SQ_tail_index,
    output logic SQ_full,
    input logic SQ_task_valid,
    input SQ_enqueue_struct_t SQ_task_struct,
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

    // // LQ interface
    // // retire
    // output logic LQ_retire_valid,
    // output ROB_index_t LQ_retire_ROB_index,
    // // restart info
    // input logic LQ_restart_valid,
    // input ROB_index_t LQ_restart_ROB_index,

    input logic LQ_retire_valid,
    input ROB_index_t LQ_retire_ROB_index,
    output logic LQ_restart_valid,
    output ROB_index_t LQ_restart_ROB_index,

    // // SQ interface
    // // complete
    // input logic SQ_complete_valid,
    // input ROB_index_t SQ_complete_ROB_index,
    // // retire
    // output logic SQ_retire_valid,
    // output ROB_index_t SQ_retire_ROB_index,

    output logic SQ_complete_valid,
    output ROB_index_t SQ_complete_ROB_index,
    input logic SQ_retire_valid,
    input ROB_index_t SQ_retire_ROB_index,

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
    output word_t this_complete_bus_data

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
    input daddr_t dcache_read_resp_data,

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

    // read kill interface:
    //      - valid
    //      - LQ index
        // just means cancel response so don't mix up with later request at same LQ index

    output logic dcache_read_kill_valid,
    output LQ_index_t dcache_read_kill_LQ_index,

    // invalidation interface:
    //      - valid
    //      - inv address

    input logic dcache_inv_valid,
    input block_addr_t dcache_inv_block_addr,

    ///////////////////
    // shared buses: //
    ///////////////////
    
    // kill bus interface
    input logic kill_bus_valid,
    input ROB_index_t kill_bus_ROB_index,

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
    logic SQ_DUT_error;
    logic LQ_operand_pipeline_DUT_error;
    logic LQ_DUT_error;
    logic complete_bus_broadcast_DUT_error;

    always_comb begin

        // top level DUT error is OR of sub-unit DUT errors
        next_DUT_error = |{
            SQ_operand_pipeline_DUT_error, 
            SQ_DUT_error, 
            LQ_operand_pipeline_DUT_error, 
            LQ_DUT_error,
            complete_bus_broadcast_DUT_error
        };
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // SQ Operand Pipeline: 

    logic SQ_reg_read_busy;

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

        //////////////////////
        // default outputs: //
        //////////////////////

        // no DUT error
        SQ_DUT_error = 1'b0;

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

        // operand update stage taking from addr calc stage
        next_SQ_operand_update_stage_valid = SQ_addr_calc_stage_valid;
        next_SQ_operand_update_stage_write_addr = SQ_addr_calc_stage_write_addr;
        next_SQ_operand_update_stage_write_data = SQ_addr_calc_stage_forwarded_write_data;
        next_SQ_operand_update_stage_SQ_index = SQ_addr_calc_stage_SQ_index;

        ///////////////////////
        // reg file outputs: //
        ///////////////////////

        SQ_reg_read_stage_reg_file_write_base_addr = SQ_reg_read_bus_0_data;
        SQ_reg_read_stage_reg_file_write_data = SQ_reg_read_bus_1_data;

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
        SQ_operand_task_valid = SQ_task_valid;
        SQ_operand_task_source_0_ready = SQ_task_struct.source_0.ready;
        SQ_operand_task_source_0_phys_reg_tag = SQ_task_struct.source_0.phys_reg_tag;
        SQ_operand_task_source_1_ready = SQ_task_struct.source_1.ready;
        SQ_operand_task_source_1_phys_reg_tag = SQ_task_struct.source_1.phys_reg_tag;
        SQ_operand_task_imm14 = SQ_task_struct.imm14;
        SQ_operand_task_SQ_index = SQ_tail_ptr.index;
        SQ_operand_task_ROB_index = SQ_task_struct.ROB_index;

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
            2'd3:   SQ_addr_calc_stage_forwarded_write_base_addr = SQ_addr_calc_stage_reg_file_write_base_addr[15:2];
        endcase

        // operand 1 complete bus data mux
            // for forwarded write data
        casez (SQ_addr_calc_stage_operand_0_bus_select) 
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

        //////////////////////
        // default outputs: //
        //////////////////////

        // no DUT error
        LQ_DUT_error = 1'b0;

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

        // operand update stage taking from addr calc stage
        next_LQ_operand_update_stage_valid = LQ_addr_calc_stage_valid;
        next_LQ_operand_update_stage_linked = LQ_addr_calc_stage_linked;
        next_LQ_operand_update_stage_conditional = LQ_addr_calc_stage_conditional;
        next_LQ_operand_update_stage_read_addr = LQ_addr_calc_stage_read_addr;
        next_LQ_operand_update_stage_LQ_index = LQ_addr_calc_stage_LQ_index;

        ///////////////////////
        // reg file outputs: //
        ///////////////////////

        LQ_reg_read_stage_reg_file_read_base_addr = LQ_reg_read_bus_0_data;

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
        LQ_operand_task_valid = LQ_task_valid;
        LQ_operand_task_linked = (LQ_task_struct.op == LQ_LL);
        LQ_operand_task_conditional = (LQ_task_struct.op == LQ_SC);
        LQ_operand_task_source_ready = LQ_task_struct.source.ready;
        LQ_operand_task_source_phys_reg_tag = LQ_task_struct.source.phys_reg_tag;
        LQ_operand_task_imm14 = LQ_task_struct.imm14;
        LQ_operand_task_LQ_index = LQ_tail_ptr.index;
        LQ_operand_task_ROB_index = LQ_task_struct.ROB_index;

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
            2'd3:   LQ_addr_calc_stage_forwarded_read_base_addr = LQ_addr_calc_stage_reg_file_read_base_addr[15:2];
        endcase

        // adder
        LQ_addr_calc_stage_read_addr = 
            LQ_addr_calc_stage_forwarded_read_base_addr
            +
            LQ_addr_calc_stage_imm14
        ;

        
    end

endmodule