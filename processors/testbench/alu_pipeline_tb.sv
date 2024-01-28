/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: alu_pipeline_tb.sv
    Description: 
       Testbench for alu_pipeline module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module alu_pipeline_tb ();

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // TB setup:

    // parameters
    parameter PERIOD = 10;

    // TB signals:
    logic CLK = 1'b1, nRST;
    string test_case;
    string sub_test_case;
    int test_num = 0;
    int num_errors = 0;
    logic tb_error = 1'b0;

    // clock gen
    always begin #(PERIOD/2); CLK = ~CLK; end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT signals:


    // DUT error
	logic DUT_DUT_error, expected_DUT_error;

    // full
	logic DUT_ALU_RS_full, expected_ALU_RS_full;

    // dispatch unit interface
	logic tb_dispatch_unit_task_valid;
	ALU_RS_input_struct_t tb_dispatch_unit_task_struct;
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
	logic DUT_reg_file_read_req_valid, expected_reg_file_read_req_valid;
	phys_reg_tag_t DUT_reg_file_read_req_0_tag, expected_reg_file_read_req_0_tag;
	phys_reg_tag_t DUT_reg_file_read_req_1_tag, expected_reg_file_read_req_1_tag;
	logic tb_reg_file_read_req_serviced;
	word_t tb_reg_file_read_bus_0_data;
	word_t tb_reg_file_read_bus_1_data;

    // kill bus interface
	logic tb_kill_bus_valid;
	ROB_index_t tb_kill_bus_ROB_index;

    // complete bus interface:

    // input side (take from any 3 buses):

    // complete bus 0 (ALU 0)
	logic tb_complete_bus_0_tag_valid;
	phys_reg_tag_t tb_complete_bus_0_tag;
	word_t tb_complete_bus_0_data;

    // complete bus 1 (ALU 1)
	logic tb_complete_bus_1_tag_valid;
	phys_reg_tag_t tb_complete_bus_1_tag;
	word_t tb_complete_bus_1_data;

    // complete bus 2 (LQ)
	logic tb_complete_bus_2_tag_valid;
	phys_reg_tag_t tb_complete_bus_2_tag;
	word_t tb_complete_bus_2_data;

    // output side (output to this ALU Pipeline's associated bus)
	logic DUT_this_complete_bus_tag_valid, expected_this_complete_bus_tag_valid;
	phys_reg_tag_t DUT_this_complete_bus_tag, expected_this_complete_bus_tag;
	ROB_index_t DUT_this_complete_bus_ROB_index, expected_this_complete_bus_ROB_index;
	logic DUT_this_complete_bus_data_valid, expected_this_complete_bus_data_valid;
	word_t DUT_this_complete_bus_data, expected_this_complete_bus_data;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	`ifndef MAPPED
	alu_pipeline DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // full
		.ALU_RS_full(DUT_ALU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(tb_dispatch_unit_task_valid),
		.dispatch_unit_task_struct(tb_dispatch_unit_task_struct),
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
		.reg_file_read_req_valid(DUT_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(DUT_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(DUT_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(tb_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(tb_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(tb_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(tb_complete_bus_0_tag_valid),
		.complete_bus_0_tag(tb_complete_bus_0_tag),
		.complete_bus_0_data(tb_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(tb_complete_bus_1_tag_valid),
		.complete_bus_1_tag(tb_complete_bus_1_tag),
		.complete_bus_1_data(tb_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(tb_complete_bus_2_tag_valid),
		.complete_bus_2_tag(tb_complete_bus_2_tag),
		.complete_bus_2_data(tb_complete_bus_2_data),

	    // output side (output to this ALU Pipeline's associated bus)
		.this_complete_bus_tag_valid(DUT_this_complete_bus_tag_valid),
		.this_complete_bus_tag(DUT_this_complete_bus_tag),
		.this_complete_bus_ROB_index(DUT_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(DUT_this_complete_bus_data_valid),
		.this_complete_bus_data(DUT_this_complete_bus_data)
	);

	`else

	alu_pipeline DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // full
		.ALU_RS_full(DUT_ALU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(tb_dispatch_unit_task_valid),
		// .dispatch_unit_task_struct(tb_dispatch_unit_task_struct),
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
		.\dispatch_unit_task_struct.op (tb_dispatch_unit_task_struct.op),
		.\dispatch_unit_task_struct.itype (tb_dispatch_unit_task_struct.itype),
		.\dispatch_unit_task_struct.source_0.needed (tb_dispatch_unit_task_struct.source_0.needed),
		.\dispatch_unit_task_struct.source_0.ready (tb_dispatch_unit_task_struct.source_0.ready),
		.\dispatch_unit_task_struct.source_0.phys_reg_tag (tb_dispatch_unit_task_struct.source_0.phys_reg_tag),
		.\dispatch_unit_task_struct.source_1.needed (tb_dispatch_unit_task_struct.source_1.needed),
		.\dispatch_unit_task_struct.source_1.ready (tb_dispatch_unit_task_struct.source_1.ready),
		.\dispatch_unit_task_struct.source_1.phys_reg_tag (tb_dispatch_unit_task_struct.source_1.phys_reg_tag),
		.\dispatch_unit_task_struct.dest_phys_reg_tag (tb_dispatch_unit_task_struct.dest_phys_reg_tag),
		.\dispatch_unit_task_struct.imm16 (tb_dispatch_unit_task_struct.imm16),
		.\dispatch_unit_task_struct.ROB_index (tb_dispatch_unit_task_struct.ROB_index),

	    // reg file read req interface
		.reg_file_read_req_valid(DUT_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(DUT_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(DUT_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(tb_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(tb_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(tb_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(tb_complete_bus_0_tag_valid),
		.complete_bus_0_tag(tb_complete_bus_0_tag),
		.complete_bus_0_data(tb_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(tb_complete_bus_1_tag_valid),
		.complete_bus_1_tag(tb_complete_bus_1_tag),
		.complete_bus_1_data(tb_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(tb_complete_bus_2_tag_valid),
		.complete_bus_2_tag(tb_complete_bus_2_tag),
		.complete_bus_2_data(tb_complete_bus_2_data),

	    // output side (output to this ALU Pipeline's associated bus)
		.this_complete_bus_tag_valid(DUT_this_complete_bus_tag_valid),
		.this_complete_bus_tag(DUT_this_complete_bus_tag),
		.this_complete_bus_ROB_index(DUT_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(DUT_this_complete_bus_data_valid),
		.this_complete_bus_data(DUT_this_complete_bus_data)
	);

	`endif

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
		if (expected_DUT_error !== DUT_DUT_error) begin
			$display("TB ERROR: expected_DUT_error (%h) != DUT_DUT_error (%h)",
				expected_DUT_error, DUT_DUT_error);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_RS_full !== DUT_ALU_RS_full) begin
			$display("TB ERROR: expected_ALU_RS_full (%h) != DUT_ALU_RS_full (%h)",
				expected_ALU_RS_full, DUT_ALU_RS_full);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_valid !== DUT_reg_file_read_req_valid) begin
			$display("TB ERROR: expected_reg_file_read_req_valid (%h) != DUT_reg_file_read_req_valid (%h)",
				expected_reg_file_read_req_valid, DUT_reg_file_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_0_tag !== DUT_reg_file_read_req_0_tag) begin
			$display("TB ERROR: expected_reg_file_read_req_0_tag (%d) != DUT_reg_file_read_req_0_tag (%d)",
				expected_reg_file_read_req_0_tag, DUT_reg_file_read_req_0_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_1_tag !== DUT_reg_file_read_req_1_tag) begin
			$display("TB ERROR: expected_reg_file_read_req_1_tag (%d) != DUT_reg_file_read_req_1_tag (%d)",
				expected_reg_file_read_req_1_tag, DUT_reg_file_read_req_1_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_tag_valid !== DUT_this_complete_bus_tag_valid) begin
			$display("TB ERROR: expected_this_complete_bus_tag_valid (%h) != DUT_this_complete_bus_tag_valid (%h)",
				expected_this_complete_bus_tag_valid, DUT_this_complete_bus_tag_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_tag !== DUT_this_complete_bus_tag) begin
			$display("TB ERROR: expected_this_complete_bus_tag (%d) != DUT_this_complete_bus_tag (%d)",
				expected_this_complete_bus_tag, DUT_this_complete_bus_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_ROB_index !== DUT_this_complete_bus_ROB_index) begin
			$display("TB ERROR: expected_this_complete_bus_ROB_index (%d) != DUT_this_complete_bus_ROB_index (%d)",
				expected_this_complete_bus_ROB_index, DUT_this_complete_bus_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_data_valid !== DUT_this_complete_bus_data_valid) begin
			$display("TB ERROR: expected_this_complete_bus_data_valid (%h) != DUT_this_complete_bus_data_valid (%h)",
				expected_this_complete_bus_data_valid, DUT_this_complete_bus_data_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_data !== DUT_this_complete_bus_data) begin
			$display("TB ERROR: expected_this_complete_bus_data (0x%h) != DUT_this_complete_bus_data (0x%h)",
				expected_this_complete_bus_data, DUT_this_complete_bus_data);
			num_errors++;
			tb_error = 1'b1;
		end

        #(PERIOD / 10);
        tb_error = 1'b0;
    end
    endtask

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // initial block:

    initial begin

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // reset:
        test_case = "reset";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // inputs:
        sub_test_case = "assert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b0;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;
	    // output side (output to this ALU Pipeline's associated bus)

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;
	    // output side (output to this ALU Pipeline's associated bus)

		@(posedge CLK);

		// outputs:

	    // outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // default:
        test_case = "default";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "default";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();
		
		///////////////////////////////////////////////////////////////////////////////////////////////////
        // ALU instr stream:
        test_case = "ALU instr stream";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		// see notes/alu_pipeline_tb_asm.txt

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 00: ADDU r1->p1/p32, r2->p2, r3->p3", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 01: ADD r2->p2/p33, r2->p2, r5->p5", "\n\t\t",
			" | RS: 00: ADDU r1->p1/p32, r2->p2, r3->p3 2x read success (0x2222, 0x3333)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(1);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h2222;
		tb_reg_file_read_bus_1_data = 32'h3333;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(17);
		tb_complete_bus_0_data = 32'h297349;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(14);
		tb_complete_bus_1_data = 32'h298349;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(9);
		tb_complete_bus_2_data = 32'h4f23;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 02: AND r30->p30/p34, r5->p5, r2->p33", "\n\t\t",
			" | RS: 01: ADD r2->p2/p33, r2->p2, r5->p5 2x read success (0x2222, 0x5555)", "\n\t\t",
			" | EX: 00: ADDU r1->p1/p32, r2->p2, r3->p3 (0x2222 + 0x3333)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_AND);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(2);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h2222;
		tb_reg_file_read_bus_1_data = 32'h5555;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(32);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h298349;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h4f23;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(5);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(32);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 02: AND r30->p30/p34, r5->p5, r2->p33 1x read success (0x5555) + ALU 0 p33 tag accept", "\n\t\t",
			" | EX: 01: ADD r2->p2/p33, r2->p2, r5->p5 (0x2222 + 0x5555)","\n\t\t",
			" | DATA: 00: ADDU r1->p1/p32, r2->p2, r3->p3 (0x2222 + 0x3333 = 0x5555)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(99);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h5555;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(33);
		tb_complete_bus_0_data = 32'h5555;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h298349;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h4f23;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(5);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(33);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h5555;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 04: NOR r13-p13/p35, r6->p6, r19->p19 (neither ready)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 02: AND r30->p30/p34, r5->p5, r2->p33 (0x5555 & 0x7777 (ALU 0 bus))", "\n\t\t",
			" | DATA: 01: ADD r2->p2/p33, r2->p2, r5->p5 (0x2222 + 0x5555 = 0x7777)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_NOR);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(4);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(34);
		tb_complete_bus_0_data = 32'h7777;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h298349;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h4f23;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(5);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(33);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(2);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h7777;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 05: OR r14->p14/p36, r0->p0, r21->p21 (p0 ready, p21 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 04: NOR r13-p13/p35, r6->p6, r19->p19 + p6 complete", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 02: AND r30->p30/p34, r5->p5, r2->p33 (0x5555 & 0x7777 = 0xcccc)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_NOR);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(5);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h34eba;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(6);
		tb_complete_bus_1_data = 32'h298349;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h4f23;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(6);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(19);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(2);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h5555;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 05: OR r14->p14/p36, r0->p0, r21->p21 (p0 ready, p21 not ready)", "\n\t\t",
			" | RS: 04: NOR r13-p13/p35, r6->p6, r19->p19 + p6 ready (0x6666) + p19 complete (0x19191919)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_OR);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(5);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h6666;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h34eba;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h298349;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(19);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(6);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(19);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(35);
		expected_this_complete_bus_ROB_index = ROB_index_t'(4);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 06: SLT r15->p15/p37, r25->p25, r1->p32 (p25 not ready, p32 ready)", "\n\t\t",
			" | RS: 05: OR r14->p14/p36, r0->p0, r21->p21 (p0 ready, p21 complete bus 1)", "\n\t\t",
			" | EX: 04: NOR r13-p13/p35, r6->p6, r19->p19 ~(0x6666 | 0x19191919 (from bus 2))", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLT);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(32);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(37);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(6);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h34eba;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(21);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h19191919;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(21);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(35);
		expected_this_complete_bus_ROB_index = ROB_index_t'(4);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'hffffffff;	// from NOR of 32'h0, 32'h0

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 07: SLTU r16->p16/p38, r22->p22, r13->p35 (p22 ready, p35 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 06: SLT r15->p15/p37, r25->p25, r1->p32 (p25 not ready, p32 ready)", "\n\t\t",
			" | EX: 05: OR r14->p14/p36, r0->p0, r21->p21 (0x0 | 0x21212121 (bus 1))", "\n\t\t",
			" | DATA: 04: NOR r13-p13/p35, r6->p6, r19->p19 ~(0x6666 | 0x19191919) = "
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLTU);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h34eba;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h21212121;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h19191919;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(25);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(32);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(36);
		expected_this_complete_bus_ROB_index = ROB_index_t'(5);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = ~(32'h6666 | 32'h19191919);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 07: SLTU r16->p16/p38, r22->p22, r13->p35 (p22 ready, p35 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 06: SLT r15->p15/p37, r25->p25, r1->p32 (p25 not ready, p32 ready)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 05: OR r14->p14/p36, r0->p0, r21->p21 (0x0 | 0x21212121 = 0x21212121)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLTU);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(25);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(32);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(6);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h21212121;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 07: SLTU r16->p16/p38, r22->p22, r13->p35 (p22 ready, p35 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 06: SLT r15->p15/p37, r25->p25, r1->p32 (p25 complete bus 2, p32 reg read fail)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLTU);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(25);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(25);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(32);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(6);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 07: SLTU r16->p16/p38, r22->p22, r13->p35 (p22 ready, p35 not ready)", "\n\t\t",
			" | RS: 06: SLT r15->p15/p37, r25->p25, r1->p32 2x reg read success (-1 < 0x32323232)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLTU);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'hffffffff;
		tb_reg_file_read_bus_1_data = 32'h32323232;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hffffffff;	// in real system, would use this, here no diff
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(25);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(32);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(6);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 08: SLLV r17->p17/p39, r2->p33, r16->p38 (p39 not ready, p33 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 07: SLTU r16->p16/p38, r22->p22, r13->p35 (p22 reg read fail, p35 complete bus 0)", "\n\t\t",
			" | EX: 06: SLT r15->p15/p37, r25->p25, r1->p32 2x reg read success (-1 < 0x32323232)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLLV);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(8);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(35);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(22);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(35);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(6);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 08: SLLV r17->p17/p39, r2->p33, r16->p38 (p33 not ready, p38 not ready)", "\n\t\t",
			" | RS: 07: SLTU r16->p16/p38, r22->p22, r13->p35 2x reg read success (0xffffffff < 0x35353535)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 06: SLT r15->p15/p37, r25->p25, r1->p32 2x reg read success (-1 < 0x32323232) = 1"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLLV);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(8);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'hffffffff;
		tb_reg_file_read_bus_1_data = 32'h35353535;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h35353535;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(22);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(35);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(7);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h1;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 09: SRLV r18->p18/p40, r1->p32, r29->p29 (p32 ready, p29 not ready)", "\n\t\t",
			" | RS: 08: SLLV r17->p17/p39, r2->p33, r16->p38 (p33 complete bus 0, p38 complete bus 1)", "\n\t\t",
			" | EX: 07: SLTU r16->p16/p38, r22->p22, r13->p35 2x reg read success (0xffffffff < 0x35353535) = 0", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SRLV);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(32);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(29);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(9);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(33);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(38);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(33);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(38);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(7);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 10: SUBU r19->p19/p41, r15->p37, r17->p39 (p37 not ready, p39 ready)", "\n\t\t",
			" | RS: 09: SRLV r18->p18/p40, r1->p32, r29->p29 (p32 reg read success (0x04040404), p29 complete bus 1)", "\n\t\t",
			" | EX: 08: SLLV r17->p17/p39, r2->p33, r16->p38 (0x0f0f0f0f, 0x00010001)", "\n\t\t",
			" | DATA: 07: SLTU r16->p16/p38, r22->p22, r13->p35 2x reg read success (0xffffffff < 0x35353535) = 0"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SUB);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(37);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(10);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h04040404;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0f0f0f0f;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(29);
		tb_complete_bus_1_data = 32'h00010001;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(32);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(29);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(39);
		expected_this_complete_bus_ROB_index = ROB_index_t'(8);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 11: SUB r20->p20/p42, r23->p23, r19->p41 (p23 ready, p41 ready)", "\n\t\t",
			" | RS: 10: SUBU r19->p19/p41, r15->p37, r17->p39 (p37 (complete bus 2), p39 reg read success)", "\n\t\t",
			" | EX: 09: SRLV r18->p18/p40, r1->p32, r29->p29 (0x04040404, 0x87654321 (complete bus 1))", "\n\t\t",
			" | DATA: 08: SLLV r17->p17/p39, r2->p33, r16->p38 (0x00010001 << 15 = 0x80008000)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SUB);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(42);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(11);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'h39393939;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h87654321;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(37);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(37);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(39);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(9);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h80008000;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 12: XOR r21->p21/p43, r0->p0, r0->p0 (p0 ready, p0 ready) (fail enqueue)", "\n\t\t",
			" | RS: 11: SUB r20->p20/p42, r23->p23, r19->p41 reg read fail (p23 ready, p41 ready)", "\n\t\t",
			" | EX: 10: SUBU r19->p19/p41, r15->p37, r17->p39 (0x37373737 (complete bus 2), 0x39393939)", "\n\t\t",
			" | DATA: 09: SRLV r18->p18/p40, r1->p32, r29->p29 (0x87654321 >> 0x04040404 = 0x08765432)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_XOR);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(43);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(12);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h37373737;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(23);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(41);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(41);
		expected_this_complete_bus_ROB_index = ROB_index_t'(10);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h08765432;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 12: XOR r21->p21/p43, r0->p0, r0->p0 (p0 ready, p0 ready) (fail enqueue)", "\n\t\t",
			" | RS: 11: SUB r20->p20/p42, r23->p23, r19->p41 2x reg read success (0x23232323, 0x41414141)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 10: SUBU r19->p19/p41, r15->p37, r17->p39 (0x37373737 - 0x39393939 = fefdfdfd)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_XOR);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(43);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(12);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h23232323;
		tb_reg_file_read_bus_1_data = 32'h41414141;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(23);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(41);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(42);
		expected_this_complete_bus_ROB_index = ROB_index_t'(11);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h37373737 - 32'h39393939;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 13: ADDIU r22->p22/p44, r13->p35, 0x5 (p35 not ready)", "\n\t\t",
			" | RS: 12: XOR r21->p21/p43, r0->p0, r0->p0 2x reg read success (0x35353535, 0x53535353)", "\n\t\t",
			" | EX: 11: SUB r20->p20/p42, r23->p23, r19->p41 (0x 23232323 - 0x41414141)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(44);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        tb_dispatch_unit_task_struct.imm16 = 16'h5;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(13);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h35353535;
		tb_reg_file_read_bus_1_data = 32'h53535353;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(42);
		expected_this_complete_bus_ROB_index = ROB_index_t'(11);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 14: ADDI r23->p23/p45, r1->p32, 0x201 (p32 ready)", "\n\t\t",
			" | RS:13: ADDIU r22->p22/p44, r13->p35, 0x5 (p35 complete bus 2) ", "\n\t\t",
			" | EX: 12: XOR r21->p21/p43, r0->p0, r0->p0 2x reg read success (0x35353535, 0x53535353)", "\n\t\t",
			" | DATA: 11: SUB r20->p20/p42, r23->p23, r19->p41 (0x23232323 - 0x41414141 = )"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(32);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(45);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(45);
        tb_dispatch_unit_task_struct.imm16 = 16'h201;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(14);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(35);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(35);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(44);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(43);
		expected_this_complete_bus_ROB_index = ROB_index_t'(12);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h23232323 - 32'h41414141;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 15: ANDI r24->p24/p46, r23->p45, 0x71A7 (p45 ready)", "\n\t\t",
			" | RS: 14: ADDI r23->p23/p45, r1->p32, 0x201 (p32 reg read success)", "\n\t\t",
			" | EX: 13: ADDIU r22->p22/p44, r13->p35, 0x5 (0x35353535 (complete bus 2), 0x5)", "\n\t\t",
			" | DATA: 12: XOR r21->p21/p43, r0->p0, r0->p0 (0x35353535 ^ 0x53535353 = 0x66666666)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_AND);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(45);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(46);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(46);
        tb_dispatch_unit_task_struct.imm16 = 16'h71a7;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(15);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h32323232;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h35353535;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(32);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(45);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(44);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h66666666;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop in (fail enqueue)", "\n\t\t",
			" | RS: 15: ANDI r24->p24/p46, r23->p45, 0x71A7 (p45 reg read fail)", "\n\t\t",
			" | EX: 14: ADDI r23->p23/p45, r1->p32, 0x201 (p32 reg read success)", "\n\t\t",
			" | DATA: 13: ADDIU r22->p22/p44, r13->p35, 0x5 (0x35353535 + 0x5 = 0x3535353a)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'hbeef;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(16);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(45);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(46);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(45);
		expected_this_complete_bus_ROB_index = ROB_index_t'(14);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h3535353a;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 17: ADDU r1->p1/p32, r2->p2, r3->p3 (p2 ready, p3 ready)", "\n\t\t",
			" | RS: 15: ANDI r24->p24/p46, r23->p45, 0x71A7 (p45 reg read success)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 14: ADDI r23->p23/p45, r1->p32, 0x201 (0x32323232 + 0x00000201 = 0x32323433)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(17);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h45454545;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(45);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(46);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(46);
		expected_this_complete_bus_ROB_index = ROB_index_t'(15);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h32323433;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 18: ADD r2->p2/p33, r2->p2, r5->p5 (p2 not ready, p5 not ready)", "\n\t\t",
			" | RS: 17: ADDU r1->p1/p32, r2->p2, r3->p3 (p2 ready, p3 ready)", "\n\t\t",
			" | EX: 15: ANDI r24->p24/p46, r23->p45, 0x71A7 (0x45454545 & 0x71a7)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(18);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h2222;
		tb_reg_file_read_bus_1_data = 32'h3333;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(46);
		expected_this_complete_bus_ROB_index = ROB_index_t'(15);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'hdeadbeef; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 19: AND r30->p30/p34, r5->p5, r2->p33 (p5 ready, p33 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 18: ADD r2->p2/p33, r2->p2, r5->p5 (p2 not ready, p5 complete bus 1)", "\n\t\t",
			" | EX: 17: ADDU r1->p1/p32, r2->p2, r3->p3 (0x2222, 0x3333) (KILL (fails))", "\n\t\t",
			" | DATA: 15: ANDI r24->p24/p46, r23->p45, 0x71A7 (p45 reg read success)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_AND);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(19);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(17);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(5);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(5);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(32);
		expected_this_complete_bus_ROB_index = ROB_index_t'(17);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h45454545 & 32'h71a7;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 19: AND r30->p30/p34, r5->p5, r2->p33 (p5 ready, p33 not ready)", "\n\t\t",
			" | RS: 18: ADD r2->p2/p33, r2->p2, r5->p5 (p2 not ready, p5 complete bus 1) (KILL)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 17: ADDU r1->p1/p32, r2->p2, r3->p3 (0x2222 + 0x3333 = 0x5555)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_AND);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(19);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(18);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(5);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(5);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(18);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h5555;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 20: NOR r13-p13/p35, r6->p6, r19->p19 (p6 ready, p19 ready)", "\n\t\t",
			" | RS: 19: AND r30->p30/p34, r5->p5, r2->p33 (p5 ready, p33 complete bus 2) (KILL)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_NOR);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(20);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h5555;
		tb_reg_file_read_bus_1_data = 32'h33333333;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(19);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h5555;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(33);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(5);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(33);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(18);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'hbd5b7dde; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 20: NOR r13-p13/p35, r6->p6, r19->p19 (p6 ready, p19 ready) (KILL)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_ADD);
        tb_dispatch_unit_task_struct.itype = 1'b0;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h6666;
		tb_reg_file_read_bus_1_data = 32'h19191919;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(20);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h5555;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h33333333;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(6);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(19);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(19);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'hbd5b7dde; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 18: LUI r25->p25/p47, 0xFEDC", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LUI);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(47);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        tb_dispatch_unit_task_struct.imm16 = 16'hFEDC;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(18);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(21);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(6);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(19);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(35);
		expected_this_complete_bus_ROB_index = ROB_index_t'(20);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h00001111; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 18: LUI r25->p25/p47, 0xFEDC", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LINK);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(47);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        tb_dispatch_unit_task_struct.imm16 = 16'hFEDC;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(18);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(47);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(35);
		expected_this_complete_bus_ROB_index = ROB_index_t'(20);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'he6e68080; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 20: ORI r27->p27/p49, r25->p47, 0x5353 (p47 ready)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 18: LUI r25->p25/p47, 0xFEDC", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_OR);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(47);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(49);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(49);
        tb_dispatch_unit_task_struct.imm16 = 16'h5353;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(20);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(47);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(47);
		expected_this_complete_bus_ROB_index = ROB_index_t'(18);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'hffffffff; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 21: SLTI r28->p28/p50, r30->p34, 0x7F (p34 not ready) (fail enqueue)", "\n\t\t",
			" | RS: 20: ORI r27->p27/p49, r25->p47, 0x5353 (p47 reg read fail)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 18: LUI r25->p25/p47, 0xFEDC"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLT);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(50);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(50);
        tb_dispatch_unit_task_struct.imm16 = 16'h5353;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(20);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(47);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(49);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(47);
		expected_this_complete_bus_ROB_index = ROB_index_t'(18);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'hFEDC0000;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 21: SLTI r28->p28/p50, r30->p34, 0x8000 (p34 not ready)", "\n\t\t",
			" | RS: 20: ORI r27->p27/p49, r25->p47, 0x5353 (p47 (0x35353535) reg read success)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLT);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(50);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(50);
        tb_dispatch_unit_task_struct.imm16 = 16'h8000;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(21);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h35353535;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(47);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(49);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(49);
		expected_this_complete_bus_ROB_index = ROB_index_t'(20);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 22: SLTIU r29->p29/p51, r9->p9, 0x8000 (p9 not ready)", "\n\t\t",
			" | RS: 21: SLTI r28->p28/p50, r30->p34, 0x8000 (p34 complete bus 0 (0xffffffff))", "\n\t\t",
			" | EX: 20: ORI r27->p27/p49, r25->p47, 0x5353 (0x35353535 | 0x00005353)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLTU);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(9);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(51);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(51);
        tb_dispatch_unit_task_struct.imm16 = 16'h8000;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(22);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(34);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(34);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(50);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(49);
		expected_this_complete_bus_ROB_index = ROB_index_t'(20);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'hdeadbeef; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop (fail enqueue)", "\n\t\t",
			" | RS: 22: SLTIU r29->p29/p51, r9->p9, 0x8000 (p9 not ready)", "\n\t\t",
			" | EX: 21: SLTI r28->p28/p50, r30->p34, 0x8000 (0xffffffff < 0xffff8000)", "\n\t\t",
			" | DATA: 20: ORI r27->p27/p49, r25->p47, 0x5353 (0x35353535 | 0x00005353)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_SLTU);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(9);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(51);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(51);
        tb_dispatch_unit_task_struct.imm16 = 16'h8000;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(22);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hffffffff;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(9);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(51);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(50);
		expected_this_complete_bus_ROB_index = ROB_index_t'(21);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h35357777;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 24: XORI r30->p34/p52, r30->p34, 0x5353 (p34 not ready)", "\n\t\t",
			" | RS: 22: SLTIU r29->p29/p51, r9->p9, 0x8000 (p9 complete bus 1)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 20: 21: SLTI r28->p28/p50, r30->p34, 0x8000 (0xffffffff < 0xffff8000 = 0)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_XOR);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(52);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(52);
        tb_dispatch_unit_task_struct.imm16 = 16'h5353;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(24);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(9);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(9);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(51);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(51);
		expected_this_complete_bus_ROB_index = ROB_index_t'(22);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 24: XORI r30->p34/p52, r30->p34, 0x5353 (p34 complete bus 1)", "\n\t\t",
			" | EX: 22: SLTIU r29->p29/p51, r9->p9, 0x8000 (0xffffffff, 0xffff8000)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_XOR);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(52);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(52);
        tb_dispatch_unit_task_struct.imm16 = 16'h5353;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(24);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(34);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(34);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(52);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(51);
		expected_this_complete_bus_ROB_index = ROB_index_t'(22);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 26: JAL (goto 99) (r31->p31/p53 <= PC+1)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 24: XORI r30->p34/p52, r30->p34, 0x5353 (p34 complete bus 1)", "\n\t\t",
			" | DATA: 22: SLTIU r29->p29/p51, r9->p9, 0x8000 (0xffffffff < 0xffff8000 = 0)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LINK);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        tb_dispatch_unit_task_struct.imm16 = 16'h0104;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h35353535;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(34);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(52);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(52);
		expected_this_complete_bus_ROB_index = ROB_index_t'(24);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h1;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 26: JAL (goto 99) (r31->p31/p53 <= PC+1) (0x0104)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 24: XORI r30->p34/p52, r30->p34, 0x5353 (0x35353535 ^ 0x00005353)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LINK);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        tb_dispatch_unit_task_struct.imm16 = 16'h0104;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(52);
		expected_this_complete_bus_ROB_index = ROB_index_t'(24);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h35356666;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 26: JAL (goto 99) (r31->p31/p53 <= PC+1) (0x0104)", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LINK);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        tb_dispatch_unit_task_struct.imm16 = 16'h0104;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(53);
		expected_this_complete_bus_ROB_index = ROB_index_t'(26);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0; // residual

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: 26: JAL (goto 99) (r31->p31/p53 <= PC+1) (0x0104)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LINK);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        tb_dispatch_unit_task_struct.imm16 = 16'h0104;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(53);
		expected_this_complete_bus_ROB_index = ROB_index_t'(26);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h0108;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | DATA: nop"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = ALU_op_t'(ALU_LINK);
        tb_dispatch_unit_task_struct.itype = 1'b1;
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        tb_dispatch_unit_task_struct.imm16 = 16'h0104;
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // output side (output to this ALU Pipeline's associated bus)

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_ALU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // output side (output to this ALU Pipeline's associated bus)
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(53);
		expected_this_complete_bus_ROB_index = ROB_index_t'(26);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0000bef0; // residual

		check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // finish:
        @(posedge CLK);
        
        test_case = "finish";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        @(posedge CLK);

        $display();
        if (num_errors) begin
            $display("FAIL: %d tests fail", num_errors);
        end
        else begin
            $display("SUCCESS: all tests pass");
        end
        $display();

        $finish();
    end

endmodule

