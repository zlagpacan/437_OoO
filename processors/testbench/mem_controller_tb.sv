/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: mem_controller_tb.sv
    Description: 
        Testbench for mem_controller module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

`include "cpu_ram_if.vh"

// `include "cpu_types_pkg.vh"
// import cpu_types_pkg::*;
	// use mine instead

module mem_controller_tb ();

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

    /////////////////////
    // imem interface: //
    /////////////////////
        // synchronous, blocking interface
        // essentially same as 437
	logic tb_imem_REN;
	block_addr_t tb_imem_block_addr;
	logic DUT_imem_hit, expected_imem_hit;
	word_t [1:0] DUT_imem_load, expected_imem_load;

    /////////////////////
    // dmem interface: //
    /////////////////////
        // asynchronous, non-blocking interface

    // dmem read req:
	logic tb_dmem_read_req_valid;
	block_addr_t tb_dmem_read_req_block_addr;

    // dmem read resp:
	logic DUT_dmem_read_resp_valid, expected_dmem_read_resp_valid;
	block_addr_t DUT_dmem_read_resp_block_addr, expected_dmem_read_resp_block_addr;
	word_t [1:0] DUT_dmem_read_resp_data, expected_dmem_read_resp_data;

    // dmem write req:
	logic tb_dmem_write_req_valid;
	block_addr_t tb_dmem_write_req_block_addr;
	word_t [1:0] tb_dmem_write_req_data;

    //////////////
    // flushed: //
    //////////////

	logic tb_dcache_flushed;
	logic DUT_mem_controller_flushed, expected_mem_controller_flushed;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	mem_controller DUT (
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

	    /////////////////////
	    // imem interface: //
	    /////////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
		.imem_REN(tb_imem_REN),
		.imem_block_addr(tb_imem_block_addr),
		.imem_hit(DUT_imem_hit),
		.imem_load(DUT_imem_load),

	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	        // asynchronous, non-blocking interface

	    // dmem read req:
		.dmem_read_req_valid(tb_dmem_read_req_valid),
		.dmem_read_req_block_addr(tb_dmem_read_req_block_addr),

	    // dmem read resp:
		.dmem_read_resp_valid(DUT_dmem_read_resp_valid),
		.dmem_read_resp_block_addr(DUT_dmem_read_resp_block_addr),
		.dmem_read_resp_data(DUT_dmem_read_resp_data),

	    // dmem write req:
		.dmem_write_req_valid(tb_dmem_write_req_valid),
		.dmem_write_req_block_addr(tb_dmem_write_req_block_addr),
		.dmem_write_req_data(tb_dmem_write_req_data),

	    //////////////
	    // flushed: //
	    //////////////

		.dcache_flushed(tb_dcache_flushed),
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

		if (expected_imem_hit !== DUT_imem_hit) begin
			$display("TB ERROR: expected_imem_hit (%h) != DUT_imem_hit (%h)",
				expected_imem_hit, DUT_imem_hit);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem_load !== DUT_imem_load) begin
			$display("TB ERROR: expected_imem_load (%h) != DUT_imem_load (%h)",
				expected_imem_load, DUT_imem_load);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_resp_valid !== DUT_dmem_read_resp_valid) begin
			$display("TB ERROR: expected_dmem_read_resp_valid (%h) != DUT_dmem_read_resp_valid (%h)",
				expected_dmem_read_resp_valid, DUT_dmem_read_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_resp_block_addr !== DUT_dmem_read_resp_block_addr) begin
			$display("TB ERROR: expected_dmem_read_resp_block_addr (%h) != DUT_dmem_read_resp_block_addr (%h)",
				expected_dmem_read_resp_block_addr, DUT_dmem_read_resp_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_resp_data !== DUT_dmem_read_resp_data) begin
			$display("TB ERROR: expected_dmem_read_resp_data (%h) != DUT_dmem_read_resp_data (%h)",
				expected_dmem_read_resp_data, DUT_dmem_read_resp_data);
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
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		tb_imem_REN = 1'b0;
		tb_imem_block_addr = 13'h0;
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
		tb_dmem_read_req_valid = 1'b0;
		tb_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		tb_dmem_write_req_valid = 1'b0;
		tb_dmem_write_req_block_addr = 13'h0;
		tb_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache_flushed = 1'b0;

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
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		expected_imem_hit = 1'b0;
		expected_imem_load = {32'h0, 32'h0};
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
	    // dmem read resp:
		expected_dmem_read_resp_valid = 1'b0;
		expected_dmem_read_resp_block_addr = 13'h0;
		expected_dmem_read_resp_data = {32'h0, 32'h0};
	    // dmem write req:
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
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		tb_imem_REN = 1'b0;
		tb_imem_block_addr = 13'h0;
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
		tb_dmem_read_req_valid = 1'b0;
		tb_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		tb_dmem_write_req_valid = 1'b0;
		tb_dmem_write_req_block_addr = 13'h0;
		tb_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache_flushed = 1'b0;

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
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		expected_imem_hit = 1'b0;
		expected_imem_load = {32'h0, 32'h0};
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
	    // dmem read resp:
		expected_dmem_read_resp_valid = 1'b0;
		expected_dmem_read_resp_block_addr = 13'h0;
		expected_dmem_read_resp_data = {32'h0, 32'h0};
	    // dmem write req:
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
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		tb_imem_REN = 1'b0;
		tb_imem_block_addr = 13'h0;
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
		tb_dmem_read_req_valid = 1'b0;
		tb_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		tb_dmem_write_req_valid = 1'b0;
		tb_dmem_write_req_block_addr = 13'h0;
		tb_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache_flushed = 1'b0;

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
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		expected_imem_hit = 1'b0;
		expected_imem_load = {32'h0, 32'h0};
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
	    // dmem read resp:
		expected_dmem_read_resp_valid = 1'b0;
		expected_dmem_read_resp_block_addr = 13'h0;
		expected_dmem_read_resp_data = {32'h0, 32'h0};
	    // dmem write req:
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

