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
			$display("TB ERROR: expected_reg_file_read_req_0_tag (%h) != DUT_reg_file_read_req_0_tag (%h)",
				expected_reg_file_read_req_0_tag, DUT_reg_file_read_req_0_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_1_tag !== DUT_reg_file_read_req_1_tag) begin
			$display("TB ERROR: expected_reg_file_read_req_1_tag (%h) != DUT_reg_file_read_req_1_tag (%h)",
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
			$display("TB ERROR: expected_this_complete_bus_tag (%h) != DUT_this_complete_bus_tag (%h)",
				expected_this_complete_bus_tag, DUT_this_complete_bus_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_ROB_index !== DUT_this_complete_bus_ROB_index) begin
			$display("TB ERROR: expected_this_complete_bus_ROB_index (%h) != DUT_this_complete_bus_ROB_index (%h)",
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
			$display("TB ERROR: expected_this_complete_bus_data (%h) != DUT_this_complete_bus_data (%h)",
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

