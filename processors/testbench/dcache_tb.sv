/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dcache_tb.sv
    Description: 
        Testbench for dcache module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module dcache_tb ();

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

    /////////////////////
    // core interface: //
    /////////////////////
        // asynchronous, non-blocking interface

    // read req interface:
	logic tb_dcache_read_req_valid;
	LQ_index_t tb_dcache_read_req_LQ_index;
	daddr_t tb_dcache_read_req_addr;
	logic tb_dcache_read_req_linked;
	logic tb_dcache_read_req_conditional;
	logic DUT_dcache_read_req_blocked, expected_dcache_read_req_blocked;

    // read resp interface:
	logic DUT_dcache_read_resp_valid, expected_dcache_read_resp_valid;
	LQ_index_t DUT_dcache_read_resp_LQ_index, expected_dcache_read_resp_LQ_index;
	word_t DUT_dcache_read_resp_data, expected_dcache_read_resp_data;

    // write req interface:
	logic tb_dcache_write_req_valid;
	daddr_t tb_dcache_write_req_addr;
	word_t tb_dcache_write_req_data;
	logic tb_dcache_write_req_conditional;
	logic DUT_dcache_write_req_blocked, expected_dcache_write_req_blocked;

    // read kill interface x2:
        // even though doing bus resp block addr broadcast, still want these to 
	logic tb_dcache_read_kill_0_valid;
	LQ_index_t tb_dcache_read_kill_0_LQ_index;
	logic tb_dcache_read_kill_1_valid;
	LQ_index_t tb_dcache_read_kill_1_LQ_index;

    // invalidation interface:
        // TODO: implement logic for multicore
            // already implemented eviction inv's, technically don't need for unicore
            // need to add snoop inv's -> potentially need new Q or double this interface to core
	logic DUT_dcache_inv_valid, expected_dcache_inv_valid;
	block_addr_t DUT_dcache_inv_block_addr, expected_dcache_inv_block_addr;

    // halt interface:
	logic tb_dcache_halt;

    ////////////////////
    // mem interface: //
    ////////////////////
        // asynchronous, non-blocking interface

    // dmem read req:
	logic DUT_dmem_read_req_valid, expected_dmem_read_req_valid;
	daddr_t DUT_dmem_read_req_block_addr, expected_dmem_read_req_block_addr;

    // dmem read resp:
	logic tb_dmem_read_resp_valid;
	daddr_t tb_dmem_read_resp_block_addr;
	word_t [1:0] tb_dmem_read_resp_data;

    // dmem write req:
	logic DUT_dmem_write_req_valid, expected_dmem_write_req_valid;
	daddr_t DUT_dmem_write_req_block_addr, expected_dmem_write_req_block_addr;
	word_t [1:0] DUT_dmem_write_req_data, expected_dmem_write_req_data;

    //////////////
    // flushed: //
    //////////////

	logic DUT_flushed, expected_flushed;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	dcache DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    /////////////////////
	    // core interface: //
	    /////////////////////
	        // asynchronous, non-blocking interface

	    // read req interface:
		.dcache_read_req_valid(tb_dcache_read_req_valid),
		.dcache_read_req_LQ_index(tb_dcache_read_req_LQ_index),
		.dcache_read_req_addr(tb_dcache_read_req_addr),
		.dcache_read_req_linked(tb_dcache_read_req_linked),
		.dcache_read_req_conditional(tb_dcache_read_req_conditional),
		.dcache_read_req_blocked(DUT_dcache_read_req_blocked),

	    // read resp interface:
		.dcache_read_resp_valid(DUT_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(DUT_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(DUT_dcache_read_resp_data),

	    // write req interface:
		.dcache_write_req_valid(tb_dcache_write_req_valid),
		.dcache_write_req_addr(tb_dcache_write_req_addr),
		.dcache_write_req_data(tb_dcache_write_req_data),
		.dcache_write_req_conditional(tb_dcache_write_req_conditional),
		.dcache_write_req_blocked(DUT_dcache_write_req_blocked),

	    // read kill interface x2:
	        // even though doing bus resp block addr broadcast, still want these to 
		.dcache_read_kill_0_valid(tb_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(tb_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(tb_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(tb_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
	        // TODO: implement logic for multicore
	            // already implemented eviction inv's, technically don't need for unicore
	            // need to add snoop inv's -> potentially need new Q or double this interface to core
		.dcache_inv_valid(DUT_dcache_inv_valid),
		.dcache_inv_block_addr(DUT_dcache_inv_block_addr),

	    // halt interface:
		.dcache_halt(tb_dcache_halt),

	    ////////////////////
	    // mem interface: //
	    ////////////////////
	        // asynchronous, non-blocking interface

	    // dmem read req:
		.dmem_read_req_valid(DUT_dmem_read_req_valid),
		.dmem_read_req_block_addr(DUT_dmem_read_req_block_addr),

	    // dmem read resp:
		.dmem_read_resp_valid(tb_dmem_read_resp_valid),
		.dmem_read_resp_block_addr(tb_dmem_read_resp_block_addr),
		.dmem_read_resp_data(tb_dmem_read_resp_data),

	    // dmem write req:
		.dmem_write_req_valid(DUT_dmem_write_req_valid),
		.dmem_write_req_block_addr(DUT_dmem_write_req_block_addr),
		.dmem_write_req_data(DUT_dmem_write_req_data),

	    //////////////
	    // flushed: //
	    //////////////

		.flushed(DUT_flushed)
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

		if (expected_dcache_read_req_blocked !== DUT_dcache_read_req_blocked) begin
			$display("TB ERROR: expected_dcache_read_req_blocked (%h) != DUT_dcache_read_req_blocked (%h)",
				expected_dcache_read_req_blocked, DUT_dcache_read_req_blocked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_resp_valid !== DUT_dcache_read_resp_valid) begin
			$display("TB ERROR: expected_dcache_read_resp_valid (%h) != DUT_dcache_read_resp_valid (%h)",
				expected_dcache_read_resp_valid, DUT_dcache_read_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_resp_LQ_index !== DUT_dcache_read_resp_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_resp_LQ_index (%h) != DUT_dcache_read_resp_LQ_index (%h)",
				expected_dcache_read_resp_LQ_index, DUT_dcache_read_resp_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_resp_data !== DUT_dcache_read_resp_data) begin
			$display("TB ERROR: expected_dcache_read_resp_data (%h) != DUT_dcache_read_resp_data (%h)",
				expected_dcache_read_resp_data, DUT_dcache_read_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_blocked !== DUT_dcache_write_req_blocked) begin
			$display("TB ERROR: expected_dcache_write_req_blocked (%h) != DUT_dcache_write_req_blocked (%h)",
				expected_dcache_write_req_blocked, DUT_dcache_write_req_blocked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_inv_valid !== DUT_dcache_inv_valid) begin
			$display("TB ERROR: expected_dcache_inv_valid (%h) != DUT_dcache_inv_valid (%h)",
				expected_dcache_inv_valid, DUT_dcache_inv_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_inv_block_addr !== DUT_dcache_inv_block_addr) begin
			$display("TB ERROR: expected_dcache_inv_block_addr (%h) != DUT_dcache_inv_block_addr (%h)",
				expected_dcache_inv_block_addr, DUT_dcache_inv_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_req_valid !== DUT_dmem_read_req_valid) begin
			$display("TB ERROR: expected_dmem_read_req_valid (%h) != DUT_dmem_read_req_valid (%h)",
				expected_dmem_read_req_valid, DUT_dmem_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_req_block_addr !== DUT_dmem_read_req_block_addr) begin
			$display("TB ERROR: expected_dmem_read_req_block_addr (%h) != DUT_dmem_read_req_block_addr (%h)",
				expected_dmem_read_req_block_addr, DUT_dmem_read_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_valid !== DUT_dmem_write_req_valid) begin
			$display("TB ERROR: expected_dmem_write_req_valid (%h) != DUT_dmem_write_req_valid (%h)",
				expected_dmem_write_req_valid, DUT_dmem_write_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_block_addr !== DUT_dmem_write_req_block_addr) begin
			$display("TB ERROR: expected_dmem_write_req_block_addr (%h) != DUT_dmem_write_req_block_addr (%h)",
				expected_dmem_write_req_block_addr, DUT_dmem_write_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_data !== DUT_dmem_write_req_data) begin
			$display("TB ERROR: expected_dmem_write_req_data (%h) != DUT_dmem_write_req_data (%h)",
				expected_dmem_write_req_data, DUT_dmem_write_req_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_flushed !== DUT_flushed) begin
			$display("TB ERROR: expected_flushed (%h) != DUT_flushed (%h)",
				expected_flushed, DUT_flushed);
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
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		tb_dcache_read_req_valid = 1'b0;
		tb_dcache_read_req_LQ_index = LQ_index_t'(0);
		tb_dcache_read_req_addr = 14'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 14'h0;
		tb_dcache_write_req_data = 32'h0;
		tb_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		tb_dcache_read_kill_0_valid = 1'b0;
		tb_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		tb_dcache_read_kill_1_valid = 1'b0;
		tb_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		tb_dcache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
	    // dmem read resp:
		tb_dmem_read_resp_valid = 1'b0;
		tb_dmem_read_resp_block_addr = 13'h0;
		tb_dmem_read_resp_data = {32'hdeadbeef, 32'hdeadbeef};
	    // dmem write req:
	    //////////////
	    // flushed: //
	    //////////////

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		expected_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		expected_dcache_read_resp_valid = 1'b0;
		expected_dcache_read_resp_LQ_index = LQ_index_t'(0);
		expected_dcache_read_resp_data = 32'h0;
	    // write req interface:
		expected_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		expected_dcache_inv_valid = 1'b0;
		expected_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
		expected_dmem_read_req_valid = 1'b0;
		expected_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		expected_dmem_write_req_valid = 1'b0;
		expected_dmem_write_req_block_addr = 13'h0;
		expected_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		expected_flushed = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		tb_dcache_read_req_valid = 1'b0;
		tb_dcache_read_req_LQ_index = LQ_index_t'(0);
		tb_dcache_read_req_addr = 14'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 14'h0;
		tb_dcache_write_req_data = 32'h0;
		tb_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		tb_dcache_read_kill_0_valid = 1'b0;
		tb_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		tb_dcache_read_kill_1_valid = 1'b0;
		tb_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		tb_dcache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
	    // dmem read resp:
		tb_dmem_read_resp_valid = 1'b0;
		tb_dmem_read_resp_block_addr = 13'h0;
		tb_dmem_read_resp_data = {32'hdeadbeef, 32'hdeadbeef};
	    // dmem write req:
	    //////////////
	    // flushed: //
	    //////////////

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		expected_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		expected_dcache_read_resp_valid = 1'b0;
		expected_dcache_read_resp_LQ_index = LQ_index_t'(0);
		expected_dcache_read_resp_data = 32'h0;
	    // write req interface:
		expected_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		expected_dcache_inv_valid = 1'b0;
		expected_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
		expected_dmem_read_req_valid = 1'b0;
		expected_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		expected_dmem_write_req_valid = 1'b0;
		expected_dmem_write_req_block_addr = 13'h0;
		expected_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		expected_flushed = 1'b0;

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
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		tb_dcache_read_req_valid = 1'b0;
		tb_dcache_read_req_LQ_index = LQ_index_t'(0);
		tb_dcache_read_req_addr = 14'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 14'h0;
		tb_dcache_write_req_data = 32'h0;
		tb_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		tb_dcache_read_kill_0_valid = 1'b0;
		tb_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		tb_dcache_read_kill_1_valid = 1'b0;
		tb_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		tb_dcache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
	    // dmem read resp:
		tb_dmem_read_resp_valid = 1'b0;
		tb_dmem_read_resp_block_addr = 13'h0;
		tb_dmem_read_resp_data = {32'hdeadbeef, 32'hdeadbeef};
	    // dmem write req:
	    //////////////
	    // flushed: //
	    //////////////

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		expected_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		expected_dcache_read_resp_valid = 1'b0;
		expected_dcache_read_resp_LQ_index = LQ_index_t'(0);
		expected_dcache_read_resp_data = 32'h0;
	    // write req interface:
		expected_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		expected_dcache_inv_valid = 1'b0;
		expected_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
		expected_dmem_read_req_valid = 1'b0;
		expected_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		expected_dmem_write_req_valid = 1'b0;
		expected_dmem_write_req_block_addr = 13'h0;
		expected_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		expected_flushed = 1'b0;

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

