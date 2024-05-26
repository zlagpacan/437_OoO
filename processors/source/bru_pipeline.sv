/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: bru_pipeline.sv
    Instantiation Hierarchy: system -> core -> bru_pipeline
    Description:
        The Branch Resolution Unit Pipeline takes dispatched BRU tasks (BEQ, BNE, and JR instructions,
        the conditional branches) and completes them. 

        The BRU Pipeline can be instantiated multiple times in the core. Current plan is to have 1 BRU
        Pipeline, resolving all conditional branches in-order.

        The BRU Pipeline consists of 4 stages:

            - Dispatch Stage
                - take in task struct from dispatch unit
                - same clock cycle dispatch happens
                - guaranteed to take 1 cycle
                    - really just need to latch dispatch unit

            - Reservation Station Stage
                - prepare operands for task execution
                - make register reads
                - do PC + 4 add
                - do branch PC add
                - determine if task can continue
                    -  have all operands or can grab complete bus value next cycle
                - task can be in RS stage for multiple cycles
                - can get killed, preventing forward to execution stage

            - Execution Stage
                - perform Branch resolution op, potentially generating resolution to be sent to the ROB
                - guaranteed to take 1 cycle
                - make complete bus broadcast tag stage unless getting killed
                - forward data to data broadcast stage unless getting killed

        Kills are only successful on BRU tasks that are in the RS Stage. 
            - can get same-cycle resolution complete and kill 
                - this is safe since ROB is already responsible for considering new resolutions
                - point of kill is to get rid of arbitrarily long tasks which can complete after new 
                    rename has occurred
            - this is simpler and makes logic for restart signals faster
*/

`include "core_types.vh"
import core_types_pkg::*;

module bru_pipeline (

    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // full
    output logic BRU_RS_full,

    // dispatch unit interface
    input logic dispatch_unit_task_valid,
    input BRU_RS_input_struct_t dispatch_unit_task_struct,
        // typedef struct packed {
        //     // BRU needs
        //     BRU_op_t op;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     logic [15:0] imm16;
        //     pc_t PC;    // will use to grab PC bits for BTB/DIRP index and do branch add ((PC + 4) + imm16)
        //     pc_t nPC;   // PC taken to check against
        //     // save/restore info
        //     checkpoint_column_t checkpoint_safe_column;
        //     // admin
        //     ROB_index_t ROB_index;
        // } BRU_RS_input_struct_t;
    
    // reg file read req interface
    output logic reg_file_read_req_valid,
    output phys_reg_tag_t reg_file_read_req_0_tag,
    output phys_reg_tag_t reg_file_read_req_1_tag,
    input logic reg_file_read_req_serviced,
    input word_t reg_file_read_bus_0_data,
    input word_t reg_file_read_bus_1_data,

    // kill bus interface
    input logic kill_bus_valid,
    input ROB_index_t kill_bus_ROB_index,

    // complete bus interface:

    // input side (take from any 3 buses):

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
    input word_t complete_bus_2_data,

    // complete output to ROB
    output logic this_complete_valid,

    // restart output to ROB
    output logic this_restart_valid,
    output ROB_index_t this_restart_ROB_index,
    output pc_t this_restart_PC,
    output checkpoint_column_t this_restart_safe_column,

    // BTB/DIRP updates to fetch_unit
    output logic this_BTB_DIRP_update,
    output BTB_DIRP_index_t this_BTB_DIRP_index,
    output pc_t this_BTB_target,
    output logic this_DIRP_taken
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
    // Pipeline Logic: 

    //////////////////////////////////////////////
    // Dispatch Stage -> | Latch | -> RS Stage:

    logic RS_stage_task_valid;
    logic next_RS_stage_task_valid;
    BRU_RS_input_struct_t RS_stage_task_struct;
    BRU_RS_input_struct_t next_RS_stage_task_struct;

    ////////////////////////////////////////
    // RS Stage -> | Latch | -> EX Stage:

    // valid will be determined in RS stage logic
    logic EX_stage_task_valid;
    logic next_EX_stage_task_valid;

    BRU_op_t EX_stage_op;
    BRU_op_t next_EX_stage_op;

    word_t EX_stage_operand_0;
    word_t next_EX_stage_operand_0;

    word_t EX_stage_operand_1;
    word_t next_EX_stage_operand_1;

    logic [1:0] EX_stage_operand_0_bus_select;
    logic [1:0] next_EX_stage_operand_0_bus_select;

    logic [1:0] EX_stage_operand_1_bus_select;
    logic [1:0] next_EX_stage_operand_1_bus_select;

    BTB_DIRP_index_t EX_stage_BTB_DIRP_index;
    BTB_DIRP_index_t next_EX_stage_BTB_DIRP_index;

    pc_t EX_stage_branch_PC;
    pc_t next_EX_stage_branch_PC;

    pc_t EX_stage_PC_plus_4;
    pc_t next_EX_stage_PC_plus_4;

    pc_t EX_stage_nPC;
    pc_t next_EX_stage_nPC;

    checkpoint_column_t EX_stage_checkpoint_safe_column;
    checkpoint_column_t next_EX_stage_checkpoint_safe_column;

    ROB_index_t EX_stage_ROB_index;
    ROB_index_t next_EX_stage_ROB_index;

    /////////////////////////
    // RS Stage tag match:

    logic RS_stage_operand_0_complete_bus_0_VTM;
    logic RS_stage_operand_0_complete_bus_1_VTM;
    logic RS_stage_operand_0_complete_bus_2_VTM;
    logic RS_stage_operand_1_complete_bus_0_VTM;
    logic RS_stage_operand_1_complete_bus_1_VTM;
    logic RS_stage_operand_1_complete_bus_2_VTM;

    ////////////////////////////////////
    // EX Stage complete bus mux out: 

    word_t EX_stage_A;
    word_t EX_stage_B;

    //////////////////////////////////////////////////////////
    // prevent successive restarts (only care about first): 

    logic flush_BP;

    ////////////
    // logic: 

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin

        if (~nRST) begin
            
            // Dispatch -> RS Latch
            // send invalid tasks with reasonable defaults
            RS_stage_task_valid <= 1'b0;
            // RS_stage_task_struct <= '0; // all 0's is safe nop (doesn't matter because valid 0 anyway)
            RS_stage_task_struct.op <= BRU_BEQ;
            RS_stage_task_struct.source_0.needed <= 1'b0;
            RS_stage_task_struct.source_0.ready <= 1'b0;
            RS_stage_task_struct.source_0.phys_reg_tag <= phys_reg_tag_t'(0);
            RS_stage_task_struct.source_1.needed <= 1'b0;
            RS_stage_task_struct.source_1.ready <= 1'b0;
            RS_stage_task_struct.source_1.phys_reg_tag <= phys_reg_tag_t'(0);
            RS_stage_task_struct.imm16 <= 16'h0;
            RS_stage_task_struct.PC <= pc_t'(0);    // default 0
            RS_stage_task_struct.nPC <= pc_t'(1);   // default PC + 4 = 0 + 1 = 1
            RS_stage_task_struct.checkpoint_safe_column <= checkpoint_column_t'(0); // default 0
            RS_stage_task_struct.ROB_index <= ROB_index_t'(0);  // default 0

            // RS -> EX Latch
            EX_stage_task_valid <= 1'b0;
            EX_stage_op <= BRU_op_t'(BRU_BEQ);      // default BEQ
            EX_stage_operand_0 <= 32'h0;    
            EX_stage_operand_1 <= 32'h0;
            EX_stage_operand_0_bus_select <= 2'd3;  // default raw operand 0
            EX_stage_operand_1_bus_select <= 2'd3;  // default raw operand 1
            EX_stage_BTB_DIRP_index <= BTB_DIRP_index_t'(0);    // default 0
            EX_stage_branch_PC <= pc_t'(1);         // default PC + 4 + 0 = 0 + 1 + 0 = 1
            EX_stage_PC_plus_4 <= pc_t'(1);         // default 0 + 1 = 1
            EX_stage_nPC <= pc_t'(1);               // default PC + 4 = 0 + 1 = 1
            EX_stage_checkpoint_safe_column <= checkpoint_column_t'(0); // default 0
            EX_stage_ROB_index <= ROB_index_t'(0);  // default 0
        end

        else if (flush_BP) begin

            // Dispatch -> RS Latch
            // send invalid tasks with reasonable defaults
            RS_stage_task_valid <= 1'b0;
            // RS_stage_task_struct <= '0; // all 0's is safe nop (doesn't matter because valid 0 anyway)
            RS_stage_task_struct.op <= BRU_BEQ;
            RS_stage_task_struct.source_0.needed <= 1'b0;
            RS_stage_task_struct.source_0.ready <= 1'b0;
            RS_stage_task_struct.source_0.phys_reg_tag <= phys_reg_tag_t'(0);
            RS_stage_task_struct.source_1.needed <= 1'b0;
            RS_stage_task_struct.source_1.ready <= 1'b0;
            RS_stage_task_struct.source_1.phys_reg_tag <= phys_reg_tag_t'(0);
            RS_stage_task_struct.imm16 <= 16'h0;
            RS_stage_task_struct.PC <= pc_t'(0);    // default 0
            RS_stage_task_struct.nPC <= pc_t'(1);   // default PC + 4 = 0 + 1 = 1
            RS_stage_task_struct.checkpoint_safe_column <= checkpoint_column_t'(0); // default 0
            RS_stage_task_struct.ROB_index <= ROB_index_t'(0);  // default 0

            // RS -> EX Latch
            EX_stage_task_valid <= 1'b0;
            EX_stage_op <= BRU_op_t'(BRU_BEQ);      // default BEQ
            EX_stage_operand_0 <= 32'h0;    
            EX_stage_operand_1 <= 32'h0;
            EX_stage_operand_0_bus_select <= 2'd3;  // default raw operand 0
            EX_stage_operand_1_bus_select <= 2'd3;  // default raw operand 1
            EX_stage_BTB_DIRP_index <= BTB_DIRP_index_t'(0);    // default 0
            EX_stage_branch_PC <= pc_t'(1);         // default PC + 4 + 0 = 0 + 1 + 0 = 1
            EX_stage_PC_plus_4 <= pc_t'(1);         // default 0 + 1 = 1
            EX_stage_nPC <= pc_t'(1);               // default PC + 4 = 0 + 1 = 1
            EX_stage_checkpoint_safe_column <= checkpoint_column_t'(0); // default 0
            EX_stage_ROB_index <= ROB_index_t'(0);  // default 0
        end

        else begin

            // Dispatch -> RS Latch
            RS_stage_task_valid <= next_RS_stage_task_valid;
            RS_stage_task_struct <= next_RS_stage_task_struct;

            // RS -> EX Latch
            EX_stage_task_valid <= next_EX_stage_task_valid;
            EX_stage_op <= next_EX_stage_op;
            EX_stage_operand_0 <= next_EX_stage_operand_0;
            EX_stage_operand_1 <= next_EX_stage_operand_1;
            EX_stage_operand_0_bus_select <= next_EX_stage_operand_0_bus_select;
            EX_stage_operand_1_bus_select <= next_EX_stage_operand_1_bus_select;
            EX_stage_BTB_DIRP_index <= next_EX_stage_BTB_DIRP_index;
            EX_stage_branch_PC <= next_EX_stage_branch_PC;
            EX_stage_PC_plus_4 <= next_EX_stage_PC_plus_4;
            EX_stage_nPC <= next_EX_stage_nPC;
            EX_stage_checkpoint_safe_column <= next_EX_stage_checkpoint_safe_column;
            EX_stage_ROB_index <= next_EX_stage_ROB_index;
        end
    end

    // comb logic
    always_comb begin

        //////////////////////
        // default outputs: //
        //////////////////////

        // no DUT error
        next_DUT_error = 1'b0;

        // RS not full
        BRU_RS_full = 1'b0;

        // reg file read req invalid
        reg_file_read_req_valid = 1'b0;
            // will depend on if 1 or more operands ready in reg file and not getting killed
        reg_file_read_req_0_tag = RS_stage_task_struct.source_0.phys_reg_tag;
        reg_file_read_req_1_tag = RS_stage_task_struct.source_1.phys_reg_tag;

        // complete output to ROB
        this_complete_valid = EX_stage_task_valid;

        // restart output to ROB
        this_restart_valid = 1'b0;
            // depends on branch resolution logic
        this_restart_ROB_index = EX_stage_ROB_index;
        this_restart_PC = EX_stage_PC_plus_4;
            // will mux out output later
        this_restart_safe_column = EX_stage_checkpoint_safe_column;

        // BTB/DIRP updates to fetch_unit
        this_BTB_DIRP_update = 1'b0;
            // will have logic for output later (only update on BEQ/BNE)
        this_BTB_DIRP_index = EX_stage_BTB_DIRP_index;
        this_BTB_target = EX_stage_branch_PC;
        this_DIRP_taken = 1'b0; 
            // will have logic for output later (determine if BEQ/BNE branch taken)

        // hold latch state for RS
        next_RS_stage_task_valid = RS_stage_task_valid;
        next_RS_stage_task_struct = RS_stage_task_struct;

        // invalid EX state from RS
        next_EX_stage_task_valid = 1'b0;
            // depends on task ready for EX
        next_EX_stage_op = RS_stage_task_struct.op;
        next_EX_stage_operand_0 = reg_file_read_bus_0_data;
        next_EX_stage_operand_1 = reg_file_read_bus_1_data;
        next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
        next_EX_stage_operand_1_bus_select = 2'd3;          // this can change
        next_EX_stage_BTB_DIRP_index = BTB_DIRP_index_t'(RS_stage_task_struct.PC);
        next_EX_stage_branch_PC = RS_stage_task_struct.PC + pc_t'(1) + pc_t'(RS_stage_task_struct.imm16[PC_WIDTH-1:0]);
        next_EX_stage_PC_plus_4 = RS_stage_task_struct.PC + pc_t'(1);
        next_EX_stage_nPC = RS_stage_task_struct.nPC;
        next_EX_stage_checkpoint_safe_column = RS_stage_task_struct.checkpoint_safe_column;
        next_EX_stage_ROB_index = RS_stage_task_struct.ROB_index;

        ////////////////////////////////////////////
        // RS state complete bus tag match logic: //
        ////////////////////////////////////////////

        RS_stage_operand_0_complete_bus_0_VTM = complete_bus_0_tag_valid & (
            RS_stage_task_struct.source_0.phys_reg_tag == complete_bus_0_tag);
        RS_stage_operand_0_complete_bus_1_VTM = complete_bus_1_tag_valid & (
            RS_stage_task_struct.source_0.phys_reg_tag == complete_bus_1_tag);
        RS_stage_operand_0_complete_bus_2_VTM = complete_bus_2_tag_valid & (
            RS_stage_task_struct.source_0.phys_reg_tag == complete_bus_2_tag);
        RS_stage_operand_1_complete_bus_0_VTM = complete_bus_0_tag_valid & (
            RS_stage_task_struct.source_1.phys_reg_tag == complete_bus_0_tag);
        RS_stage_operand_1_complete_bus_1_VTM = complete_bus_1_tag_valid & (
            RS_stage_task_struct.source_1.phys_reg_tag == complete_bus_1_tag);
        RS_stage_operand_1_complete_bus_2_VTM = complete_bus_2_tag_valid & (
            RS_stage_task_struct.source_1.phys_reg_tag == complete_bus_2_tag);
        
        /////////////////////
        // RS stage logic: //
        /////////////////////

        // valid task in RS
        if (RS_stage_task_valid) begin

            // check for kill
            if (kill_bus_valid & RS_stage_task_struct.ROB_index == kill_bus_ROB_index) begin

                // not full
                BRU_RS_full = 1'b0;

                // invalidate RS and EX task
                next_RS_stage_task_valid = 1'b0;
                next_EX_stage_task_valid = 1'b0;
            end
            
            // otherwise, try to move to EX stage
            else begin

                // need operand 0 only or need operand 0 and operand 1

                // check need operand 0 and operand 1 (BEQ, BNE)
                if (RS_stage_task_struct.source_0.needed & RS_stage_task_struct.source_1.needed) begin

                    // assert BEQ or BNE
                    if (!(RS_stage_task_struct.op == BRU_BEQ | RS_stage_task_struct.op == BRU_BNE)) begin
                        `ifdef ERROR_PRINTS
                        $display("bru_pipeline: ERROR: need operand 0 and operand 1 but not BEQ or BNE");
                        $display("\t@: %0t",$realtime);
                        next_DUT_error = 1'b1;
                        `endif
                    end

                    // operand 0 ready, operand 1 ready
                    if (RS_stage_task_struct.source_0.ready & RS_stage_task_struct.source_1.ready) begin

                        // give read req
                        reg_file_read_req_valid = 1'b1;

                        // succeed if reg read req succeeds
                        if (reg_file_read_req_serviced) begin

                            // move to EX with raw operand 0 and raw operand 1
                            next_EX_stage_task_valid = 1'b1;
                            next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                            next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                            // not full
                            BRU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            BRU_RS_full = 1'b1;
                        end
                    end
                    
                    // operand 0 ready, operand 1 VTM
                    else if (RS_stage_task_struct.source_0.ready & (
                        RS_stage_operand_1_complete_bus_0_VTM |
                        RS_stage_operand_1_complete_bus_1_VTM |
                        RS_stage_operand_1_complete_bus_2_VTM
                    )) begin

                        // give read req
                        reg_file_read_req_valid = 1'b1;

                        // succeed if reg read req succeeds
                        if (reg_file_read_req_serviced) begin
                        
                            // move to EX with raw operand 0
                            next_EX_stage_task_valid = 1'b1;
                            next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                            // next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                            // select corresponding bus for operand 1
                            if (RS_stage_operand_1_complete_bus_0_VTM) begin
                                next_EX_stage_operand_1_bus_select = 2'd0;
                            end 
                            else if (RS_stage_operand_1_complete_bus_1_VTM) begin
                                next_EX_stage_operand_1_bus_select = 2'd1;
                            end
                            else if (RS_stage_operand_1_complete_bus_2_VTM) begin
                                next_EX_stage_operand_1_bus_select = 2'd2;
                            end
                            else begin
                                `ifdef ERROR_PRINTS
                                $display("bru_pipeline: ERROR: operand 1 VTM OR but no individual VTM");
                                $display("\t@: %0t",$realtime);
                                next_DUT_error = 1'b1;
                                `endif
                            end

                            // not full
                            BRU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            BRU_RS_full = 1'b1;

                            // mark operand 1 ready
                            next_RS_stage_task_struct.source_1.ready = 1'b1;
                        end
                    end

                    // operand 1 ready, operand 0 VTM
                    else if (RS_stage_task_struct.source_1.ready & (
                        RS_stage_operand_0_complete_bus_0_VTM |
                        RS_stage_operand_0_complete_bus_1_VTM |
                        RS_stage_operand_0_complete_bus_2_VTM
                    )) begin

                        // give read req
                        reg_file_read_req_valid = 1'b1;

                        // succeed if reg read req succeeds
                        if (reg_file_read_req_serviced) begin

                            // move to EX with raw operand 1
                            next_EX_stage_task_valid = 1'b1;
                            // next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                            next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                            // select corresponding bus for operand 0
                            if (RS_stage_operand_0_complete_bus_0_VTM) begin
                                next_EX_stage_operand_0_bus_select = 2'd0;
                            end 
                            else if (RS_stage_operand_0_complete_bus_1_VTM) begin
                                next_EX_stage_operand_0_bus_select = 2'd1;
                            end
                            else if (RS_stage_operand_0_complete_bus_2_VTM) begin
                                next_EX_stage_operand_0_bus_select = 2'd2;
                            end
                            else begin
                                `ifdef ERROR_PRINTS
                                $display("bru_pipeline: ERROR: operand 0 VTM OR but no individual VTM");
                                $display("\t@: %0t",$realtime);
                                next_DUT_error = 1'b1;
                                `endif
                            end

                            // not full
                            BRU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            BRU_RS_full = 1'b1;

                            // mark operand 0 ready
                            next_RS_stage_task_struct.source_0.ready = 1'b1;
                        end
                    end

                    // operand 0 VTM and operand 1 VTM
                    else if ((
                            RS_stage_operand_0_complete_bus_0_VTM |
                            RS_stage_operand_0_complete_bus_1_VTM |
                            RS_stage_operand_0_complete_bus_2_VTM
                        ) & (
                            RS_stage_operand_1_complete_bus_0_VTM |
                            RS_stage_operand_1_complete_bus_1_VTM |
                            RS_stage_operand_1_complete_bus_2_VTM
                        )
                    ) begin

                        // don't need read req

                        // move to EX
                        next_EX_stage_task_valid = 1'b1;
                        // next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                        // next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                        // select corresponding bus for operand 0
                        if (RS_stage_operand_0_complete_bus_0_VTM) begin
                            next_EX_stage_operand_0_bus_select = 2'd0;
                        end 
                        else if (RS_stage_operand_0_complete_bus_1_VTM) begin
                            next_EX_stage_operand_0_bus_select = 2'd1;
                        end
                        else if (RS_stage_operand_0_complete_bus_2_VTM) begin
                            next_EX_stage_operand_0_bus_select = 2'd2;
                        end
                        else begin
                            `ifdef ERROR_PRINTS
                            $display("bru_pipeline: ERROR: operand 0 VTM OR but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            next_DUT_error = 1'b1;
                            `endif
                        end

                        // select corresponding bus for operand 1
                        if (RS_stage_operand_1_complete_bus_0_VTM) begin
                            next_EX_stage_operand_1_bus_select = 2'd0;
                        end 
                        else if (RS_stage_operand_1_complete_bus_1_VTM) begin
                            next_EX_stage_operand_1_bus_select = 2'd1;
                        end
                        else if (RS_stage_operand_1_complete_bus_2_VTM) begin
                            next_EX_stage_operand_1_bus_select = 2'd2;
                        end
                        else begin
                            `ifdef ERROR_PRINTS
                            $display("bru_pipeline: ERROR: operand 1 VTM OR but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            next_DUT_error = 1'b1;
                            `endif
                        end

                        // not full
                        BRU_RS_full = 1'b0;

                        // invalidate RS task
                        next_RS_stage_task_valid = 1'b0;
                    end

                    // otherwise, can't move to EX, but can mark single ready
                    else begin

                        // full
                        BRU_RS_full = 1'b1;

                        // mark ready if VTM on operand 0
                        if (
                            RS_stage_operand_0_complete_bus_0_VTM |
                            RS_stage_operand_0_complete_bus_1_VTM |
                            RS_stage_operand_0_complete_bus_2_VTM
                        ) begin
                            next_RS_stage_task_struct.source_0.ready = 1'b1;
                        end

                        // mark ready if VTM on operand 1
                        if (
                            RS_stage_operand_1_complete_bus_0_VTM |
                            RS_stage_operand_1_complete_bus_1_VTM |
                            RS_stage_operand_1_complete_bus_2_VTM
                        ) begin
                            next_RS_stage_task_struct.source_1.ready = 1'b1;
                        end
                    end
                end
                
                // check only need operand 0 -> JR
                else if (RS_stage_task_struct.source_0.needed & ~RS_stage_task_struct.source_1.needed) begin

                    // assert JR
                    if (!(RS_stage_task_struct.op == BRU_JR)) begin
                        `ifdef ERROR_PRINTS
                        $display("bru_pipeline: ERROR: need only operand 0 but not JR");
                        $display("\t@: %0t",$realtime);
                        next_DUT_error = 1'b1;
                        `endif
                    end
                    
                    // operand 0 ready
                    if (RS_stage_task_struct.source_0.ready) begin

                        // give read req
                        reg_file_read_req_valid = 1'b1;

                        // succeed if reg read req succeeds
                        if (reg_file_read_req_serviced) begin

                            // move to EX with raw operand 0 and raw operand 1
                            next_EX_stage_task_valid = 1'b1;
                            next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                            next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                            // not full
                            BRU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            BRU_RS_full = 1'b1;
                        end
                    end

                    // operand 0 VTM
                    else if (
                        RS_stage_operand_0_complete_bus_0_VTM |
                        RS_stage_operand_0_complete_bus_1_VTM |
                        RS_stage_operand_0_complete_bus_2_VTM
                    ) begin
                        
                        // don't need read req

                        // move to EX
                        next_EX_stage_task_valid = 1'b1;
                        // next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                        next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                        // select corresponding bus for operand 0
                        if (RS_stage_operand_0_complete_bus_0_VTM) begin
                            next_EX_stage_operand_0_bus_select = 2'd0;
                        end 
                        else if (RS_stage_operand_0_complete_bus_1_VTM) begin
                            next_EX_stage_operand_0_bus_select = 2'd1;
                        end
                        else if (RS_stage_operand_0_complete_bus_2_VTM) begin
                            next_EX_stage_operand_0_bus_select = 2'd2;
                        end
                        else begin
                            `ifdef ERROR_PRINTS
                            $display("bru_pipeline: ERROR: operand 0 VTM OR but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            next_DUT_error = 1'b1;
                            `endif
                        end

                        // not full
                        BRU_RS_full = 1'b0;

                        // invalidate RS task
                        next_RS_stage_task_valid = 1'b0;
                    end

                    // otherwise, can't move to EX
                    else begin
                        
                        // full
                        BRU_RS_full = 1'b1;
                    end
                end

                // check don't need either operand (bad case)
                else if (~RS_stage_task_struct.source_0.needed & ~RS_stage_task_struct.source_0.needed) begin
                    `ifdef ERROR_PRINTS
                    $display("bru_pipeline: ERROR: don't need either operand");
                    $display("\t@: %0t",$realtime);
                    next_DUT_error = 1'b1;
                    `endif
                end

                // otherwise, bad case where only need operand 1
                else begin
                    `ifdef ERROR_PRINTS
                    $display("bru_pipeline: ERROR: only need operand 1");
                    $display("\t@: %0t",$realtime);
                    next_DUT_error = 1'b1;
                    `endif
                end
            end
        end

        // take in input struct if valid
        if (dispatch_unit_task_valid) begin

            // pass in dispatch unit struct
            next_RS_stage_task_valid = 1'b1;
            next_RS_stage_task_struct = dispatch_unit_task_struct;
            
            // assert not full
            if (BRU_RS_full) begin
                `ifdef ERROR_PRINTS
                $display("bru_pipeline: ERROR: dispatch_unit_task_valid while BRU_RS_full");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
                `endif
            end
        end

        /////////////////////
        // EX stage logic: //
        /////////////////////

        // operand 0 complete bus data mux
        casez (EX_stage_operand_0_bus_select)
            2'd0:   EX_stage_A = complete_bus_0_data;
            2'd1:   EX_stage_A = complete_bus_1_data;
            2'd2:   EX_stage_A = complete_bus_2_data;
            2'd3:   EX_stage_A = EX_stage_operand_0;
        endcase
        
        // operand 1 complete bus data mux
        casez (EX_stage_operand_1_bus_select)
            2'd0:   EX_stage_B = complete_bus_0_data;
            2'd1:   EX_stage_B = complete_bus_1_data;
            2'd2:   EX_stage_B = complete_bus_2_data;
            2'd3:   EX_stage_B = EX_stage_operand_1;
        endcase

        // no flush
        flush_BP = 1'b0;

        // BRU EX stage behavior by op
        casez (EX_stage_op)

            BRU_BEQ:
            begin
                // restart logic:

                // check for reg's equal
                if (EX_stage_A == EX_stage_B) begin

                    // expect branch
                    this_restart_PC = EX_stage_branch_PC;

                    // restart if didn't take branch PC
                    if (EX_stage_nPC != EX_stage_branch_PC) begin
                        
                        // if valid task, send restart, flush BP
                        if (EX_stage_task_valid) begin
                            this_restart_valid = 1'b1;
                            flush_BP = 1'b1;
                        end
                    end

                    // direction is taken
                    this_DIRP_taken = 1'b1;
                end

                // otherwise reg's not equal
                else begin

                    // expect no branch
                    this_restart_PC = EX_stage_PC_plus_4;

                    // restart if didn't take PC+4
                    if (EX_stage_nPC != EX_stage_PC_plus_4) begin
                        
                        // if valid task, send restart, flush BP
                        if (EX_stage_task_valid) begin
                            this_restart_valid = 1'b1;
                            flush_BP = 1'b1;
                        end
                    end

                    // direction is not taken
                    this_DIRP_taken = 1'b0;
                end

                // BTB/DIRP logic:
                this_BTB_DIRP_update = EX_stage_task_valid;
            end

            BRU_BNE:
            begin
                // restart logic:

                // check for reg's not equal
                if (EX_stage_A != EX_stage_B) begin

                    // expect branch
                    this_restart_PC = EX_stage_branch_PC;

                    // restart if didn't take branch PC
                    if (EX_stage_nPC != EX_stage_branch_PC) begin
                        
                        // if valid task, send restart, flush BP
                        if (EX_stage_task_valid) begin
                            this_restart_valid = 1'b1;
                            flush_BP = 1'b1;
                        end
                    end

                    // direction is taken
                    this_DIRP_taken = 1'b1;
                end

                // otherwise reg's equal
                else begin

                    // expect no branch
                    this_restart_PC = EX_stage_PC_plus_4;

                    // restart if didn't take PC+4
                    if (EX_stage_nPC != EX_stage_PC_plus_4) begin
                        
                        // if valid task, send restart, flush BP
                        if (EX_stage_task_valid) begin
                            this_restart_valid = 1'b1;
                            flush_BP = 1'b1;
                        end
                    end

                    // direction is not taken
                    this_DIRP_taken = 1'b0;
                end

                // BTB/DIRP logic:
                this_BTB_DIRP_update = EX_stage_task_valid;
            end

            BRU_JR:
            begin
                // restart logic:
                    // PC <= R[rs]
                        // pc14 only cares about bits [15:2]
                this_restart_PC = pc_t'(EX_stage_A[PC_WIDTH-1+2:2]);

                // restart if didn't take JR (reg A)
                if (EX_stage_nPC != pc_t'(EX_stage_A[PC_WIDTH-1+2:2])) begin
                        
                    // if valid task, send restart, flush BP
                    if (EX_stage_task_valid) begin
                        this_restart_valid = 1'b1;
                        flush_BP = 1'b1;
                    end
                end
            end

            default:    
            begin
                `ifdef ERROR_PRINTS
                $display("bru_pipeline: ERROR: invalid op in EX stage");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
                `endif
            end 

        endcase

    end

endmodule