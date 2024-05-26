/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: alu_pipeline.sv
    Instantiation Hierarchy: system -> core -> alu_pipeline
    Description:
        The ALU Pipeline takes dispatched ALU tasks and completes them. 

        The ALU Pipeline can be instantiated multiple times in the core. Current plan is to have 2 ALU
        Pipelines, so that if one has a LQ data dependence, the other can work on independent ALU ops.

        The ALU Pipeline consists of 4 stages:

            - Dispatch Stage
                - take in task struct from dispatch unit
                - same clock cycle dispatch happens
                - guaranteed to take 1 cycle
                    - really just need to latch dispatch unit

            - Reservation Station Stage
                - prepare operands for task execution
                - make register reads
                - determine if task can continue
                    -  have all operands or can grab complete bus value next cycle
                - task can be in RS stage for multiple cycles
                - can get killed, preventing forward to execution stage

            - Execution Stage
                - perform ALU op, generating data value to be written to register
                - guaranteed to take 1 cycle
                - make complete bus broadcast tag stage unless getting killed
                - forward data to data broadcast stage unless getting killed

            - Data Broadcast Stage
                - broadcast latched data to data stage of complete bus transaction
                - guaranteed to take 1 cycle

        Kills are only successful on ALU tasks that are in the RS Stage. 
            - can get same-cycle tag/ROB index complete and kill
                - this is safe since completes only affect PRRT and ROB, which will have been rolled back
                    with same-cycle tag/ROB index kill in plenty of time before used again
                - point of kill is to get rid of arbitrarily long tasks which can complete after new 
                    rename has occurred
            - this is simpler and makes logic for complete bus faster
*/

`include "core_types.vh"
import core_types_pkg::*;

module alu_pipeline (

    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // full
    output logic ALU_RS_full,

    // dispatch unit interface
    input logic dispatch_unit_task_valid,
    input ALU_RS_input_struct_t dispatch_unit_task_struct,
        // typedef struct packed {
        //     // ALU needs
        //     ALU_op_t op;
        //     logic itype;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     phys_reg_tag_t dest_phys_reg_tag;
        //     imm16_t imm16;
        //     // ROB needs
        //     ROB_index_t ROB_index;
        // } ALU_RS_input_struct_t;
    
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

    // output side (output to this ALU Pipeline's associated bus)
    output logic this_complete_bus_tag_valid,
    output phys_reg_tag_t this_complete_bus_tag,
    output ROB_index_t this_complete_bus_ROB_index,
    output logic this_complete_bus_data_valid, // only needs to go to reg file
    output word_t this_complete_bus_data
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
    ALU_RS_input_struct_t RS_stage_task_struct;
    ALU_RS_input_struct_t next_RS_stage_task_struct;

    ////////////////////////////////////////
    // RS Stage -> | Latch | -> EX Stage:

    // valid will be determined in RS stage logic
    logic EX_stage_task_valid;
    logic next_EX_stage_task_valid;

    ALU_op_t EX_stage_op;
    ALU_op_t next_EX_stage_op;

    word_t EX_stage_operand_0;
    word_t next_EX_stage_operand_0;

    word_t EX_stage_operand_1;
    word_t next_EX_stage_operand_1;

    logic [1:0] EX_stage_operand_0_bus_select;
    logic [1:0] next_EX_stage_operand_0_bus_select;

    logic [1:0] EX_stage_operand_1_bus_select;
    logic [1:0] next_EX_stage_operand_1_bus_select;

    phys_reg_tag_t EX_stage_tag;
    phys_reg_tag_t next_EX_stage_tag;

    ROB_index_t EX_stage_ROB_index;
    ROB_index_t next_EX_stage_ROB_index;

    //////////////////////////////////////////
    // EX Stage -> | Latch | -> DATA Stage:

    // valid will be determined in EX stage logic
    logic DATA_stage_task_valid;
    logic next_DATA_stage_task_valid;

    word_t DATA_stage_output_data;
    word_t next_DATA_stage_output_data;

    /////////////////////
    // RS Stage imm32: 

    word_t RS_stage_operand_1_imm32;

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

    ////////////
    // logic: 

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // send invalid tasks with reasonable defaults
            RS_stage_task_valid <= 1'b0;
            RS_stage_task_struct <= '0; // all 0's is safe nop (doesn't matter because valid 0 anyway)
            EX_stage_task_valid <= 1'b0;
            EX_stage_op <= ALU_op_t'(ALU_ADD);  // default ADD
            EX_stage_operand_0 <= 32'h0;    
            EX_stage_operand_1 <= 32'h0;
            EX_stage_operand_0_bus_select <= 2'd3;  // default raw operand 0
            EX_stage_operand_1_bus_select <= 2'd3;  // default raw operand 1
            EX_stage_tag <= phys_reg_tag_t'(0); // default write p0 (good warning if there is problem?)
            EX_stage_ROB_index <= ROB_index_t'(0);  // default 0
            DATA_stage_task_valid <= 1'b0;
            DATA_stage_output_data <= 32'h0;
        end
        else begin
            RS_stage_task_valid <= next_RS_stage_task_valid;
            RS_stage_task_struct <= next_RS_stage_task_struct;
            EX_stage_task_valid <= next_EX_stage_task_valid;
            EX_stage_op <= next_EX_stage_op;
            EX_stage_operand_0 <= next_EX_stage_operand_0;
            EX_stage_operand_1 <= next_EX_stage_operand_1;
            EX_stage_operand_0_bus_select <= next_EX_stage_operand_0_bus_select;
            EX_stage_operand_1_bus_select <= next_EX_stage_operand_1_bus_select;
            EX_stage_tag <= next_EX_stage_tag;
            EX_stage_ROB_index <= next_EX_stage_ROB_index;
            DATA_stage_task_valid <= next_DATA_stage_task_valid;
            DATA_stage_output_data <= next_DATA_stage_output_data;
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
        ALU_RS_full = 1'b0;

        // reg file read req invalid
        reg_file_read_req_valid = 1'b0;
            // will depend on if 1 or more operands ready in reg file and not getting killed
        reg_file_read_req_0_tag = RS_stage_task_struct.source_0.phys_reg_tag;
        reg_file_read_req_1_tag = RS_stage_task_struct.source_1.phys_reg_tag;

        // complete bus output
        this_complete_bus_tag_valid = EX_stage_task_valid;
            // will depend on if not getting killed
            // no it won't, got rid of this functionality
        this_complete_bus_tag = EX_stage_tag;
        this_complete_bus_ROB_index = EX_stage_ROB_index;
        this_complete_bus_data_valid = DATA_stage_task_valid; 
        this_complete_bus_data = DATA_stage_output_data;

        // hold latch state for RS
        next_RS_stage_task_valid = RS_stage_task_valid;
        next_RS_stage_task_struct = RS_stage_task_struct;

        // invalid EX state from RS
        next_EX_stage_task_valid = 1'b0;
            // depends on task ready for EX
        next_EX_stage_op = RS_stage_task_struct.op;
        next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
        next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
        next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
        next_EX_stage_operand_1_bus_select = 2'd3;          // this can change
        next_EX_stage_tag = RS_stage_task_struct.dest_phys_reg_tag;
        next_EX_stage_ROB_index = RS_stage_task_struct.ROB_index;

        // DATA always takes EX
        next_DATA_stage_task_valid = EX_stage_task_valid;
        // next_DATA_stage_output_data = EX_stage_output_data;
            // override with ALU mux

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

        //////////////////
        // imm32 logic: //
        //////////////////

        casez (RS_stage_task_struct.op)

            // sign extend
            ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU, ALU_SLLV, ALU_SRLV, ALU_LUI, ALU_LINK:
                RS_stage_operand_1_imm32 = {
                    {16{RS_stage_task_struct.imm16[15]}}, 
                    RS_stage_task_struct.imm16
                };

            // zero extend
            ALU_AND, ALU_OR, ALU_NOR, ALU_XOR:
            begin
                RS_stage_operand_1_imm32 = {
                    16'h0, 
                    RS_stage_task_struct.imm16
                };
            end
                
            // default: sign extend
            default:
            begin
                RS_stage_operand_1_imm32 = {
                    {16{RS_stage_task_struct.imm16[15]}},  
                    RS_stage_task_struct.imm16
                };
            end

        endcase
        
        /////////////////////
        // RS stage logic: //
        /////////////////////

        // valid task in RS
        if (RS_stage_task_valid) begin

            // check for kill
            if (kill_bus_valid & RS_stage_task_struct.ROB_index == kill_bus_ROB_index) begin

                // not full
                ALU_RS_full = 1'b0;

                // invalidate RS and EX task
                next_RS_stage_task_valid = 1'b0;
                next_EX_stage_task_valid = 1'b0;
            end
            
            // otherwise, try to move to EX stage
            else begin

                // not as simple as either need operand 0 or operand 0 and operand 1
                    // ALU_LUI and ALU_LINK don't need any operands
                // check needed's individually

                // check need operand 0 and operand 1
                if (RS_stage_task_struct.source_0.needed & RS_stage_task_struct.source_1.needed) begin

                    // operand 0 ready, operand 1 ready
                    if (RS_stage_task_struct.source_0.ready & RS_stage_task_struct.source_1.ready) begin

                        // give read req
                        reg_file_read_req_valid = 1'b1;

                        // succeed if reg read req succeeds
                        if (reg_file_read_req_serviced) begin

                            // move to EX with raw operand 0 and raw operand 1
                            next_EX_stage_task_valid = 1'b1;
                            next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                            next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
                            next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                            next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                            // not full
                            ALU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            ALU_RS_full = 1'b1;
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
                            next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                            next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
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
                                $display("alu_pipeline: ERROR: operand 1 VTM OR but no individual VTM");
                                $display("\t@: %0t",$realtime);
                                next_DUT_error = 1'b1;
                                `endif
                            end

                            // not full
                            ALU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            ALU_RS_full = 1'b1;

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
                            next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                            next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
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
                                $display("alu_pipeline: ERROR: operand 0 VTM OR but no individual VTM");
                                $display("\t@: %0t",$realtime);
                                next_DUT_error = 1'b1;
                                `endif
                            end

                            // not full
                            ALU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            ALU_RS_full = 1'b1;

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
                        next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                        next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
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
                            $display("alu_pipeline: ERROR: operand 0 VTM OR but no individual VTM");
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
                            $display("alu_pipeline: ERROR: operand 1 VTM OR but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            next_DUT_error = 1'b1;
                            `endif
                        end

                        // not full
                        ALU_RS_full = 1'b0;

                        // invalidate RS task
                        next_RS_stage_task_valid = 1'b0;
                    end

                    // otherwise, can't move to EX, but can mark single ready
                    else begin

                        // full
                        ALU_RS_full = 1'b1;

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
                
                // check only need operand 0 -> itype operand 1
                else if (RS_stage_task_struct.source_0.needed & ~RS_stage_task_struct.source_1.needed) begin

                    // assert itype
                    if (~RS_stage_task_struct.itype) begin
                        `ifdef ERROR_PRINTS
                        $display("alu_pipeline: ERROR: only need operand 0 but not itype");
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
                            next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                            // next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
                            next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                            next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                            // select imm32 for operand 1
                            next_EX_stage_operand_1 = RS_stage_operand_1_imm32;

                            // not full
                            ALU_RS_full = 1'b0;

                            // invalidate RS task
                            next_RS_stage_task_valid = 1'b0;
                        end
                        else begin
                            // full
                            ALU_RS_full = 1'b1;
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
                        next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                        // next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
                        // next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                        next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                        // select imm32 for operand 1
                        next_EX_stage_operand_1 = RS_stage_operand_1_imm32;

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
                            $display("alu_pipeline: ERROR: operand 0 VTM OR but no individual VTM");
                            $display("\t@: %0t",$realtime);
                            next_DUT_error = 1'b1;
                            `endif
                        end

                        // not full
                        ALU_RS_full = 1'b0;

                        // invalidate RS task
                        next_RS_stage_task_valid = 1'b0;
                    end

                    // otherwise, can't move to EX
                    else begin
                        
                        // full
                        ALU_RS_full = 1'b1;
                    end
                end

                // check don't need either operand -> itype operand 1
                else if (~RS_stage_task_struct.source_0.needed & ~RS_stage_task_struct.source_0.needed) begin

                    // assert itype
                    if (~RS_stage_task_struct.itype) begin
                        `ifdef ERROR_PRINTS
                        $display("alu_pipeline: ERROR: only need operand 0 but not itype");
                        $display("\t@: %0t",$realtime);
                        next_DUT_error = 1'b1;
                        `endif
                    end

                    // don't need read req

                    // move to EX
                    next_EX_stage_task_valid = 1'b1;
                    next_EX_stage_operand_0 = reg_file_read_bus_0_data; // this can change
                        // don't care
                    next_EX_stage_operand_1 = reg_file_read_bus_1_data; // this can change
                        // don't care
                    next_EX_stage_operand_0_bus_select = 2'd3;          // this can change
                    next_EX_stage_operand_1_bus_select = 2'd3;          // this can change

                    // select imm32 for operand 1
                    next_EX_stage_operand_1 = RS_stage_operand_1_imm32;

                    // not full
                    ALU_RS_full = 1'b0;

                    // invalidate RS task
                    next_RS_stage_task_valid = 1'b0;
                end

                // otherwise, bad case where only need operand 1
                else begin
                    `ifdef ERROR_PRINTS
                    $display("alu_pipeline: ERROR: only need operand 1");
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
            if (ALU_RS_full) begin
                `ifdef ERROR_PRINTS
                $display("alu_pipeline: ERROR: dispatch_unit_task_valid while ALU_RS_full");
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

        // ALU mux
        casez (EX_stage_op)

            ALU_ADD:    next_DATA_stage_output_data = EX_stage_A + EX_stage_B;
            ALU_SUB:    next_DATA_stage_output_data = EX_stage_A - EX_stage_B;
            ALU_AND:    next_DATA_stage_output_data = EX_stage_A & EX_stage_B;
            ALU_OR:     next_DATA_stage_output_data = EX_stage_A | EX_stage_B;
            ALU_NOR:    next_DATA_stage_output_data = ~(EX_stage_A | EX_stage_B);
            ALU_XOR:    next_DATA_stage_output_data = EX_stage_A ^ EX_stage_B;
            ALU_SLT:    next_DATA_stage_output_data = ($signed(EX_stage_A) < $signed(EX_stage_B)) ? 32'd1 : 32'd0;
            ALU_SLTU:   next_DATA_stage_output_data = (EX_stage_A < EX_stage_B) ? 32'd1 : 32'd0;
            ALU_SLLV:   next_DATA_stage_output_data = EX_stage_B << EX_stage_A[4:0];
            ALU_SRLV:   next_DATA_stage_output_data = EX_stage_B >> EX_stage_A[4:0];
            ALU_LUI:    next_DATA_stage_output_data = {EX_stage_B[15:0], 16'h0};
            ALU_LINK:   next_DATA_stage_output_data = {16'h0, EX_stage_B[15:2] + 14'd1, 2'b00};
            default:    
            begin
                `ifdef ERROR_PRINTS
                $display("alu_pipeline: ERROR: invalid op in EX stage");
                $display("\t@: %0t",$realtime);
                next_DUT_error = 1'b1;
                `endif

                // default ADD
                next_DATA_stage_output_data = EX_stage_A + EX_stage_B;
            end 

        endcase

    end

endmodule