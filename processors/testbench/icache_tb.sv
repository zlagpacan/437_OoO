/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: icache_tb.sv
    Description: 
        Testbench for icache module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module icache_tb ();

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
        // synchronous, blocking interface
        // essentially same as 437
	logic tb_icache_REN;
	word_t tb_icache_addr;
	logic tb_icache_halt;
	logic DUT_icache_hit, expected_icache_hit;
	word_t DUT_icache_load, expected_icache_load;

    ////////////////////
    // mem interface: //
    ////////////////////
        // synchronous, blocking interface
        // essentially same as 437
	logic DUT_imem_REN, expected_imem_REN;
	block_addr_t DUT_imem_block_addr, expected_imem_block_addr;
	logic tb_imem_hit;
	word_t [1:0] tb_imem_load;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	icache DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    /////////////////////
	    // core interface: //
	    /////////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
		.icache_REN(tb_icache_REN),
		.icache_addr(tb_icache_addr),
		.icache_halt(tb_icache_halt),
		.icache_hit(DUT_icache_hit),
		.icache_load(DUT_icache_load),

	    ////////////////////
	    // mem interface: //
	    ////////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
		.imem_REN(DUT_imem_REN),
		.imem_block_addr(DUT_imem_block_addr),
		.imem_hit(tb_imem_hit),
		.imem_load(tb_imem_load)
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

		if (expected_icache_hit !== DUT_icache_hit) begin
			$display("TB ERROR: expected_icache_hit (%h) != DUT_icache_hit (%h)",
				expected_icache_hit, DUT_icache_hit);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_icache_load !== DUT_icache_load) begin
			$display("TB ERROR: expected_icache_load (%h) != DUT_icache_load (%h)",
				expected_icache_load, DUT_icache_load);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem_REN !== DUT_imem_REN) begin
			$display("TB ERROR: expected_imem_REN (%h) != DUT_imem_REN (%h)",
				expected_imem_REN, DUT_imem_REN);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem_block_addr !== DUT_imem_block_addr) begin
			$display("TB ERROR: expected_imem_block_addr (%h) != DUT_imem_block_addr (%h)",
				expected_imem_block_addr, DUT_imem_block_addr);
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
		tb_icache_REN = 1'b0;
		tb_icache_addr = 32'h0;
		tb_icache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		tb_imem_hit = 1'b0;
		tb_imem_load = {32'h0, 32'h0};

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
		expected_icache_hit = 1'b0;
		expected_icache_load = 32'h0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 13'h0;

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
		tb_icache_REN = 1'b0;
		tb_icache_addr = 32'h0;
		tb_icache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		tb_imem_hit = 1'b0;
		tb_imem_load = {32'h0, 32'h0};

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
		expected_icache_hit = 1'b0;
		expected_icache_load = 32'h0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 13'h0;

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
		tb_icache_REN = 1'b0;
		tb_icache_addr = 32'h0;
		tb_icache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		tb_imem_hit = 1'b0;
		tb_imem_load = {32'h0, 32'h0};

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
		expected_icache_hit = 1'b0;
		expected_icache_load = 32'h0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 13'h0;

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

