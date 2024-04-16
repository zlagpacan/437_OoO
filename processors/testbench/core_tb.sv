/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: core_tb.sv
    Description: 
        Testbench for core module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module core_tb ();

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

    ///////////////////
    // i$ interface: //
    ///////////////////
        // synchronous, blocking interface
        // essentially same as 437
	logic tb_icache_hit;
	word_t tb_icache_load;
	logic DUT_icache_REN, expected_icache_REN;
	word_t DUT_icache_addr, expected_icache_addr;
	logic DUT_icache_halt, expected_icache_halt;

    ///////////////////
    // d$ interface: //
    ///////////////////
        // asynchronous, non-blocking interface

    // read req interface:
	logic DUT_dcache_read_req_valid, expected_dcache_read_req_valid;
	LQ_index_t DUT_dcache_read_req_LQ_index, expected_dcache_read_req_LQ_index;
	daddr_t DUT_dcache_read_req_addr, expected_dcache_read_req_addr;
	logic DUT_dcache_read_req_linked, expected_dcache_read_req_linked;
	logic DUT_dcache_read_req_conditional, expected_dcache_read_req_conditional;
	logic tb_dcache_read_req_blocked;

    // read resp interface:
	logic tb_dcache_read_resp_valid;
	LQ_index_t tb_dcache_read_resp_LQ_index;
	word_t tb_dcache_read_resp_data;

    // write req interface:
	logic DUT_dcache_write_req_valid, expected_dcache_write_req_valid;
	daddr_t DUT_dcache_write_req_addr, expected_dcache_write_req_addr;
	word_t DUT_dcache_write_req_data, expected_dcache_write_req_data;
	logic DUT_dcache_write_req_conditional, expected_dcache_write_req_conditional;
	logic tb_dcache_write_req_blocked;

    // read kill interface x2:
	logic DUT_dcache_read_kill_0_valid, expected_dcache_read_kill_0_valid;
	LQ_index_t DUT_dcache_read_kill_0_LQ_index, expected_dcache_read_kill_0_LQ_index;
	logic DUT_dcache_read_kill_1_valid, expected_dcache_read_kill_1_valid;
	LQ_index_t DUT_dcache_read_kill_1_LQ_index, expected_dcache_read_kill_1_LQ_index;

    // invalidation interface:
	logic tb_dcache_inv_valid;
	block_addr_t tb_dcache_inv_block_addr;

    // halt interface:
	logic DUT_dcache_halt, expected_dcache_halt;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	core #(
        `ifndef MAPPED
        .PC_RESET_VAL(16'h0)
        `endif
	) DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    ///////////////////
	    // i$ interface: //
	    ///////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
		.icache_hit(tb_icache_hit),
		.icache_load(tb_icache_load),
		.icache_REN(DUT_icache_REN),
		.icache_addr(DUT_icache_addr),
		.icache_halt(DUT_icache_halt),

	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	        // asynchronous, non-blocking interface

	    // read req interface:
		.dcache_read_req_valid(DUT_dcache_read_req_valid),
		.dcache_read_req_LQ_index(DUT_dcache_read_req_LQ_index),
		.dcache_read_req_addr(DUT_dcache_read_req_addr),
		.dcache_read_req_linked(DUT_dcache_read_req_linked),
		.dcache_read_req_conditional(DUT_dcache_read_req_conditional),
		.dcache_read_req_blocked(tb_dcache_read_req_blocked),

	    // read resp interface:
		.dcache_read_resp_valid(tb_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(tb_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(tb_dcache_read_resp_data),

	    // write req interface:
		.dcache_write_req_valid(DUT_dcache_write_req_valid),
		.dcache_write_req_addr(DUT_dcache_write_req_addr),
		.dcache_write_req_data(DUT_dcache_write_req_data),
		.dcache_write_req_conditional(DUT_dcache_write_req_conditional),
		.dcache_write_req_blocked(tb_dcache_write_req_blocked),

	    // read kill interface x2:
		.dcache_read_kill_0_valid(DUT_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(DUT_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(DUT_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(DUT_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
		.dcache_inv_valid(tb_dcache_inv_valid),
		.dcache_inv_block_addr(tb_dcache_inv_block_addr),

	    // halt interface:
		.dcache_halt(DUT_dcache_halt)
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

		if (expected_icache_REN !== DUT_icache_REN) begin
			$display("TB ERROR: expected_icache_REN (%h) != DUT_icache_REN (%h)",
				expected_icache_REN, DUT_icache_REN);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_icache_addr !== DUT_icache_addr) begin
			$display("TB ERROR: expected_icache_addr (%h) != DUT_icache_addr (%h)",
				expected_icache_addr, DUT_icache_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_icache_halt !== DUT_icache_halt) begin
			$display("TB ERROR: expected_icache_halt (%h) != DUT_icache_halt (%h)",
				expected_icache_halt, DUT_icache_halt);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_valid !== DUT_dcache_read_req_valid) begin
			$display("TB ERROR: expected_dcache_read_req_valid (%h) != DUT_dcache_read_req_valid (%h)",
				expected_dcache_read_req_valid, DUT_dcache_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_LQ_index !== DUT_dcache_read_req_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_req_LQ_index (%h) != DUT_dcache_read_req_LQ_index (%h)",
				expected_dcache_read_req_LQ_index, DUT_dcache_read_req_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_addr !== DUT_dcache_read_req_addr) begin
			$display("TB ERROR: expected_dcache_read_req_addr (%h) != DUT_dcache_read_req_addr (%h)",
				expected_dcache_read_req_addr, DUT_dcache_read_req_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_linked !== DUT_dcache_read_req_linked) begin
			$display("TB ERROR: expected_dcache_read_req_linked (%h) != DUT_dcache_read_req_linked (%h)",
				expected_dcache_read_req_linked, DUT_dcache_read_req_linked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_conditional !== DUT_dcache_read_req_conditional) begin
			$display("TB ERROR: expected_dcache_read_req_conditional (%h) != DUT_dcache_read_req_conditional (%h)",
				expected_dcache_read_req_conditional, DUT_dcache_read_req_conditional);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_valid !== DUT_dcache_write_req_valid) begin
			$display("TB ERROR: expected_dcache_write_req_valid (%h) != DUT_dcache_write_req_valid (%h)",
				expected_dcache_write_req_valid, DUT_dcache_write_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_addr !== DUT_dcache_write_req_addr) begin
			$display("TB ERROR: expected_dcache_write_req_addr (%h) != DUT_dcache_write_req_addr (%h)",
				expected_dcache_write_req_addr, DUT_dcache_write_req_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_data !== DUT_dcache_write_req_data) begin
			$display("TB ERROR: expected_dcache_write_req_data (%h) != DUT_dcache_write_req_data (%h)",
				expected_dcache_write_req_data, DUT_dcache_write_req_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_conditional !== DUT_dcache_write_req_conditional) begin
			$display("TB ERROR: expected_dcache_write_req_conditional (%h) != DUT_dcache_write_req_conditional (%h)",
				expected_dcache_write_req_conditional, DUT_dcache_write_req_conditional);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_0_valid !== DUT_dcache_read_kill_0_valid) begin
			$display("TB ERROR: expected_dcache_read_kill_0_valid (%h) != DUT_dcache_read_kill_0_valid (%h)",
				expected_dcache_read_kill_0_valid, DUT_dcache_read_kill_0_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_0_LQ_index !== DUT_dcache_read_kill_0_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_kill_0_LQ_index (%h) != DUT_dcache_read_kill_0_LQ_index (%h)",
				expected_dcache_read_kill_0_LQ_index, DUT_dcache_read_kill_0_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_1_valid !== DUT_dcache_read_kill_1_valid) begin
			$display("TB ERROR: expected_dcache_read_kill_1_valid (%h) != DUT_dcache_read_kill_1_valid (%h)",
				expected_dcache_read_kill_1_valid, DUT_dcache_read_kill_1_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_1_LQ_index !== DUT_dcache_read_kill_1_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_kill_1_LQ_index (%h) != DUT_dcache_read_kill_1_LQ_index (%h)",
				expected_dcache_read_kill_1_LQ_index, DUT_dcache_read_kill_1_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_halt !== DUT_dcache_halt) begin
			$display("TB ERROR: expected_dcache_halt (%h) != DUT_dcache_halt (%h)",
				expected_dcache_halt, DUT_dcache_halt);
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
	    ///////////////////
	    // i$ interface: //
	    ///////////////////
		tb_icache_hit = 1'b0;
		tb_icache_load = 32'h0;
	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	    // read req interface:
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ///////////////////
	    // i$ interface: //
	    ///////////////////
		expected_icache_REN = 1'b0;
		expected_icache_addr = 32'h0;
		expected_icache_halt = 1'b0;
	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	    // read req interface:
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		expected_dcache_halt = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ///////////////////
	    // i$ interface: //
	    ///////////////////
		tb_icache_hit = 1'b0;
		tb_icache_load = 32'h0;
	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	    // read req interface:
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ///////////////////
	    // i$ interface: //
	    ///////////////////
		expected_icache_REN = 1'b0;
		expected_icache_addr = 32'h0;
		expected_icache_halt = 1'b0;
	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	    // read req interface:
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		expected_dcache_halt = 1'b0;

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
	    ///////////////////
	    // i$ interface: //
	    ///////////////////
		tb_icache_hit = 1'b0;
		tb_icache_load = 32'h0;
	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	    // read req interface:
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ///////////////////
	    // i$ interface: //
	    ///////////////////
		expected_icache_REN = 1'b0;
		expected_icache_addr = 32'h0;
		expected_icache_halt = 1'b0;
	    ///////////////////
	    // d$ interface: //
	    ///////////////////
	    // read req interface:
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		expected_dcache_halt = 1'b0;

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

