/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dual_mem_controller_tb.sv
    Description: 
        Testbench for dual_mem_controller module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

`include "cpu_ram_if.vh"

module dual_mem_controller_tb ();

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

    ////////////////////////
    // CPU RAM interface: //
    ////////////////////////

    cpu_ram_if prif ();
        // // cpu ports
        // modport cpu (
        //     input   ramstate, ramload,
        //     output  memaddr, memREN, memWEN, memstore
        // );
	logic expected_prif_memREN;
	logic expected_prif_memWEN;
	word_t expected_prif_memaddr;
	word_t expected_prif_memstore;

    //////////////////////
    // imem interfaces: //
    //////////////////////
        // synchronous, blocking interface
        // essentially same as 437
        // multicore: 2x

    // imem0:
	logic tb_imem0_REN;
	block_addr_t tb_imem0_block_addr;
	logic DUT_imem0_hit, expected_imem0_hit;
	word_t [1:0] DUT_imem0_load, expected_imem0_load;

    // imem1:
	logic tb_imem1_REN;
	block_addr_t tb_imem1_block_addr;
	logic DUT_imem1_hit, expected_imem1_hit;
	word_t [1:0] DUT_imem1_load, expected_imem1_load;

    ///////////////////////////////
    // dmem read req interfaces: //
    ///////////////////////////////
        // asynchronous, non-blocking interface

    // dmem0 read req:
	logic tb_dmem0_read_req_valid;
	block_addr_t tb_dmem0_read_req_block_addr;

    // dmem1 read req:
	logic tb_dmem1_read_req_valid;
	block_addr_t tb_dmem1_read_req_block_addr;

    ////////////////////////////////
    // dmem read resp interfaces: //
    ////////////////////////////////
        // asynchronous, non-blocking interface

    // dmem0 read resp:
	logic DUT_dmem0_read_resp_valid, expected_dmem0_read_resp_valid;
	word_t [1:0] DUT_dmem0_read_resp_data, expected_dmem0_read_resp_data;

    // dmem1 read resp:
	logic DUT_dmem1_read_resp_valid, expected_dmem1_read_resp_valid;
	word_t [1:0] DUT_dmem1_read_resp_data, expected_dmem1_read_resp_data;

    ////////////////////////////////
    // dmem write req interfaces: //
    ////////////////////////////////
        // asynchronous, non-blocking interface

    // dmem0 write req:
	logic tb_dmem0_write_req_valid;
	block_addr_t tb_dmem0_write_req_block_addr;
	word_t [1:0] tb_dmem0_write_req_data;
	logic DUT_dmem0_write_req_slow_down, expected_dmem0_write_req_slow_down;

    // dmem1 write req:
	logic tb_dmem1_write_req_valid;
	block_addr_t tb_dmem1_write_req_block_addr;
	word_t [1:0] tb_dmem1_write_req_data;
	logic DUT_dmem1_write_req_slow_down, expected_dmem1_write_req_slow_down;

    //////////////
    // flushed: //
    //////////////

	logic tb_dcache0_flushed;
	logic tb_dcache1_flushed;
	logic DUT_mem_controller_flushed, expected_mem_controller_flushed;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	dual_mem_controller DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////

	    .prif(prif),
	        // // cpu ports
	        // modport cpu (
	        //     input   ramstate, ramload,
	        //     output  memaddr, memREN, memWEN, memstore
	        // );

	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
	        // multicore: 2x

	    // imem0:
		.imem0_REN(tb_imem0_REN),
		.imem0_block_addr(tb_imem0_block_addr),
		.imem0_hit(DUT_imem0_hit),
		.imem0_load(DUT_imem0_load),

	    // imem1:
		.imem1_REN(tb_imem1_REN),
		.imem1_block_addr(tb_imem1_block_addr),
		.imem1_hit(DUT_imem1_hit),
		.imem1_load(DUT_imem1_load),

	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	        // asynchronous, non-blocking interface

	    // dmem0 read req:
		.dmem0_read_req_valid(tb_dmem0_read_req_valid),
		.dmem0_read_req_block_addr(tb_dmem0_read_req_block_addr),

	    // dmem1 read req:
		.dmem1_read_req_valid(tb_dmem1_read_req_valid),
		.dmem1_read_req_block_addr(tb_dmem1_read_req_block_addr),

	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	        // asynchronous, non-blocking interface

	    // dmem0 read resp:
		.dmem0_read_resp_valid(DUT_dmem0_read_resp_valid),
		.dmem0_read_resp_data(DUT_dmem0_read_resp_data),

	    // dmem1 read resp:
		.dmem1_read_resp_valid(DUT_dmem1_read_resp_valid),
		.dmem1_read_resp_data(DUT_dmem1_read_resp_data),

	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	        // asynchronous, non-blocking interface

	    // dmem0 write req:
		.dmem0_write_req_valid(tb_dmem0_write_req_valid),
		.dmem0_write_req_block_addr(tb_dmem0_write_req_block_addr),
		.dmem0_write_req_data(tb_dmem0_write_req_data),
		.dmem0_write_req_slow_down(DUT_dmem0_write_req_slow_down),

	    // dmem1 write req:
		.dmem1_write_req_valid(tb_dmem1_write_req_valid),
		.dmem1_write_req_block_addr(tb_dmem1_write_req_block_addr),
		.dmem1_write_req_data(tb_dmem1_write_req_data),
		.dmem1_write_req_slow_down(DUT_dmem1_write_req_slow_down),

	    //////////////
	    // flushed: //
	    //////////////

		.dcache0_flushed(tb_dcache0_flushed),
		.dcache1_flushed(tb_dcache1_flushed),
		.mem_controller_flushed(DUT_mem_controller_flushed)
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

		if (expected_prif_memREN !== prif.memREN) begin
			$display("TB ERROR: expected_prif_memREN (%h) != prif.memREN (%h)",
				expected_prif_memREN, prif.memREN);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_prif_memWEN !== prif.memWEN) begin
			$display("TB ERROR: expected_prif_memWEN (%h) != prif.memWEN (%h)",
				expected_prif_memWEN, prif.memWEN);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_prif_memaddr !== prif.memaddr) begin
			$display("TB ERROR: expected_prif_memaddr (%h) != prif.memaddr (%h)",
				expected_prif_memaddr, prif.memaddr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_prif_memstore !== prif.memstore) begin
			$display("TB ERROR: expected_prif_memstore (%h) != prif.memstore (%h)",
				expected_prif_memstore, prif.memstore);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem0_hit !== DUT_imem0_hit) begin
			$display("TB ERROR: expected_imem0_hit (%h) != DUT_imem0_hit (%h)",
				expected_imem0_hit, DUT_imem0_hit);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem0_load !== DUT_imem0_load) begin
			$display("TB ERROR: expected_imem0_load (%h) != DUT_imem0_load (%h)",
				expected_imem0_load, DUT_imem0_load);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem1_hit !== DUT_imem1_hit) begin
			$display("TB ERROR: expected_imem1_hit (%h) != DUT_imem1_hit (%h)",
				expected_imem1_hit, DUT_imem1_hit);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem1_load !== DUT_imem1_load) begin
			$display("TB ERROR: expected_imem1_load (%h) != DUT_imem1_load (%h)",
				expected_imem1_load, DUT_imem1_load);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem0_read_resp_valid !== DUT_dmem0_read_resp_valid) begin
			$display("TB ERROR: expected_dmem0_read_resp_valid (%h) != DUT_dmem0_read_resp_valid (%h)",
				expected_dmem0_read_resp_valid, DUT_dmem0_read_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem0_read_resp_data !== DUT_dmem0_read_resp_data) begin
			$display("TB ERROR: expected_dmem0_read_resp_data (%h) != DUT_dmem0_read_resp_data (%h)",
				expected_dmem0_read_resp_data, DUT_dmem0_read_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem1_read_resp_valid !== DUT_dmem1_read_resp_valid) begin
			$display("TB ERROR: expected_dmem1_read_resp_valid (%h) != DUT_dmem1_read_resp_valid (%h)",
				expected_dmem1_read_resp_valid, DUT_dmem1_read_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem1_read_resp_data !== DUT_dmem1_read_resp_data) begin
			$display("TB ERROR: expected_dmem1_read_resp_data (%h) != DUT_dmem1_read_resp_data (%h)",
				expected_dmem1_read_resp_data, DUT_dmem1_read_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem0_write_req_slow_down !== DUT_dmem0_write_req_slow_down) begin
			$display("TB ERROR: expected_dmem0_write_req_slow_down (%h) != DUT_dmem0_write_req_slow_down (%h)",
				expected_dmem0_write_req_slow_down, DUT_dmem0_write_req_slow_down);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem1_write_req_slow_down !== DUT_dmem1_write_req_slow_down) begin
			$display("TB ERROR: expected_dmem1_write_req_slow_down (%h) != DUT_dmem1_write_req_slow_down (%h)",
				expected_dmem1_write_req_slow_down, DUT_dmem1_write_req_slow_down);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_mem_controller_flushed !== DUT_mem_controller_flushed) begin
			$display("TB ERROR: expected_mem_controller_flushed (%h) != DUT_mem_controller_flushed (%h)",
				expected_mem_controller_flushed, DUT_mem_controller_flushed);
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
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
	    prif.ramstate = ACCESS;
		prif.ramload = 32'h0;
	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	    // imem0:
		tb_imem0_REN = 1'b0;
		tb_imem0_block_addr = 13'h0;
	    // imem1:
		tb_imem1_REN = 1'b0;
		tb_imem1_block_addr = 13'h0;
	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	    // dmem0 read req:
		tb_dmem0_read_req_valid = 1'b0;
		tb_dmem0_read_req_block_addr = 13'h0;
	    // dmem1 read req:
		tb_dmem1_read_req_valid = 1'b0;
		tb_dmem1_read_req_block_addr = 13'h0;
	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	    // dmem0 read resp:
	    // dmem1 read resp:
	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	    // dmem0 write req:
		tb_dmem0_write_req_valid = 1'b0;
		tb_dmem0_write_req_block_addr = 13'h0;
		tb_dmem0_write_req_data = {32'h0, 32'h0};
	    // dmem1 write req:
		tb_dmem1_write_req_valid = 1'b0;
		tb_dmem1_write_req_block_addr = 13'h0;
		tb_dmem1_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache0_flushed = 1'b0;
		tb_dcache1_flushed = 1'b0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
		expected_prif_memREN = 1'b0;
		expected_prif_memWEN = 1'b0;
		expected_prif_memaddr = 32'h0;
		expected_prif_memstore = 32'h0;
	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	    // imem0:
		expected_imem0_hit = 1'b0;
		expected_imem0_load = {32'h0, 32'h0};
	    // imem1:
		expected_imem1_hit = 1'b0;
		expected_imem1_load = {32'h0, 32'h0};
	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	    // dmem0 read req:
	    // dmem1 read req:
	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	    // dmem0 read resp:
		expected_dmem0_read_resp_valid = 1'b0;
		expected_dmem0_read_resp_data = 32'h0;
	    // dmem1 read resp:
		expected_dmem1_read_resp_valid = 1'b0;
		expected_dmem1_read_resp_data = 32'h0;
	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	    // dmem0 write req:
		expected_dmem0_write_req_slow_down = 1'b0;
	    // dmem1 write req:
		expected_dmem1_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////
		expected_mem_controller_flushed = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
	    prif.ramstate = ACCESS;
		prif.ramload = 32'h0;
	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	    // imem0:
		tb_imem0_REN = 1'b0;
		tb_imem0_block_addr = 13'h0;
	    // imem1:
		tb_imem1_REN = 1'b0;
		tb_imem1_block_addr = 13'h0;
	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	    // dmem0 read req:
		tb_dmem0_read_req_valid = 1'b0;
		tb_dmem0_read_req_block_addr = 13'h0;
	    // dmem1 read req:
		tb_dmem1_read_req_valid = 1'b0;
		tb_dmem1_read_req_block_addr = 13'h0;
	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	    // dmem0 read resp:
	    // dmem1 read resp:
	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	    // dmem0 write req:
		tb_dmem0_write_req_valid = 1'b0;
		tb_dmem0_write_req_block_addr = 13'h0;
		tb_dmem0_write_req_data = {32'h0, 32'h0};
	    // dmem1 write req:
		tb_dmem1_write_req_valid = 1'b0;
		tb_dmem1_write_req_block_addr = 13'h0;
		tb_dmem1_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache0_flushed = 1'b0;
		tb_dcache1_flushed = 1'b0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
		expected_prif_memREN = 1'b0;
		expected_prif_memWEN = 1'b0;
		expected_prif_memaddr = 32'h0;
		expected_prif_memstore = 32'h0;
	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	    // imem0:
		expected_imem0_hit = 1'b0;
		expected_imem0_load = {32'h0, 32'h0};
	    // imem1:
		expected_imem1_hit = 1'b0;
		expected_imem1_load = {32'h0, 32'h0};
	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	    // dmem0 read req:
	    // dmem1 read req:
	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	    // dmem0 read resp:
		expected_dmem0_read_resp_valid = 1'b0;
		expected_dmem0_read_resp_data = 32'h0;
	    // dmem1 read resp:
		expected_dmem1_read_resp_valid = 1'b0;
		expected_dmem1_read_resp_data = 32'h0;
	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	    // dmem0 write req:
		expected_dmem0_write_req_slow_down = 1'b0;
	    // dmem1 write req:
		expected_dmem1_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////
		expected_mem_controller_flushed = 1'b0;

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
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
	    prif.ramstate = ACCESS;
		prif.ramload = 32'h0;
	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	    // imem0:
		tb_imem0_REN = 1'b0;
		tb_imem0_block_addr = 13'h0;
	    // imem1:
		tb_imem1_REN = 1'b0;
		tb_imem1_block_addr = 13'h0;
	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	    // dmem0 read req:
		tb_dmem0_read_req_valid = 1'b0;
		tb_dmem0_read_req_block_addr = 13'h0;
	    // dmem1 read req:
		tb_dmem1_read_req_valid = 1'b0;
		tb_dmem1_read_req_block_addr = 13'h0;
	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	    // dmem0 read resp:
	    // dmem1 read resp:
	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	    // dmem0 write req:
		tb_dmem0_write_req_valid = 1'b0;
		tb_dmem0_write_req_block_addr = 13'h0;
		tb_dmem0_write_req_data = {32'h0, 32'h0};
	    // dmem1 write req:
		tb_dmem1_write_req_valid = 1'b0;
		tb_dmem1_write_req_block_addr = 13'h0;
		tb_dmem1_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache0_flushed = 1'b0;
		tb_dcache1_flushed = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
		expected_prif_memREN = 1'b0;
		expected_prif_memWEN = 1'b0;
		expected_prif_memaddr = 32'h0;
		expected_prif_memstore = 32'h0;
	    //////////////////////
	    // imem interfaces: //
	    //////////////////////
	    // imem0:
		expected_imem0_hit = 1'b0;
		expected_imem0_load = {32'h0, 32'h0};
	    // imem1:
		expected_imem1_hit = 1'b0;
		expected_imem1_load = {32'h0, 32'h0};
	    ///////////////////////////////
	    // dmem read req interfaces: //
	    ///////////////////////////////
	    // dmem0 read req:
	    // dmem1 read req:
	    ////////////////////////////////
	    // dmem read resp interfaces: //
	    ////////////////////////////////
	    // dmem0 read resp:
		expected_dmem0_read_resp_valid = 1'b0;
		expected_dmem0_read_resp_data = 32'h0;
	    // dmem1 read resp:
		expected_dmem1_read_resp_valid = 1'b0;
		expected_dmem1_read_resp_data = 32'h0;
	    ////////////////////////////////
	    // dmem write req interfaces: //
	    ////////////////////////////////
	    // dmem0 write req:
		expected_dmem0_write_req_slow_down = 1'b0;
	    // dmem1 write req:
		expected_dmem1_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////
		expected_mem_controller_flushed = 1'b0;

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

