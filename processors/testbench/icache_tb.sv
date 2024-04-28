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

	`ifndef MAPPED
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
	`else

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
		// .imem_load(tb_imem_load)
		.imem_load_0_0(tb_imem_load[0][0]),
		.imem_load_0_1(tb_imem_load[0][1]),
		.imem_load_0_2(tb_imem_load[0][2]),
		.imem_load_0_3(tb_imem_load[0][3]),
		.imem_load_0_4(tb_imem_load[0][4]),
		.imem_load_0_5(tb_imem_load[0][5]),
		.imem_load_0_6(tb_imem_load[0][6]),
		.imem_load_0_7(tb_imem_load[0][7]),
		.imem_load_0_8(tb_imem_load[0][8]),
		.imem_load_0_9(tb_imem_load[0][9]),
		.imem_load_0_10(tb_imem_load[0][10]),
		.imem_load_0_11(tb_imem_load[0][11]),
		.imem_load_0_12(tb_imem_load[0][12]),
		.imem_load_0_13(tb_imem_load[0][13]),
		.imem_load_0_14(tb_imem_load[0][14]),
		.imem_load_0_15(tb_imem_load[0][15]),
		.imem_load_0_16(tb_imem_load[0][16]),
		.imem_load_0_17(tb_imem_load[0][17]),
		.imem_load_0_18(tb_imem_load[0][18]),
		.imem_load_0_19(tb_imem_load[0][19]),
		.imem_load_0_20(tb_imem_load[0][20]),
		.imem_load_0_21(tb_imem_load[0][21]),
		.imem_load_0_22(tb_imem_load[0][22]),
		.imem_load_0_23(tb_imem_load[0][23]),
		.imem_load_0_24(tb_imem_load[0][24]),
		.imem_load_0_25(tb_imem_load[0][25]),
		.imem_load_0_26(tb_imem_load[0][26]),
		.imem_load_0_27(tb_imem_load[0][27]),
		.imem_load_0_28(tb_imem_load[0][28]),
		.imem_load_0_29(tb_imem_load[0][29]),
		.imem_load_0_30(tb_imem_load[0][30]),
		.imem_load_0_31(tb_imem_load[0][31]),
		.imem_load_1_0(tb_imem_load[1][0]),
		.imem_load_1_1(tb_imem_load[1][1]),
		.imem_load_1_2(tb_imem_load[1][2]),
		.imem_load_1_3(tb_imem_load[1][3]),
		.imem_load_1_4(tb_imem_load[1][4]),
		.imem_load_1_5(tb_imem_load[1][5]),
		.imem_load_1_6(tb_imem_load[1][6]),
		.imem_load_1_7(tb_imem_load[1][7]),
		.imem_load_1_8(tb_imem_load[1][8]),
		.imem_load_1_9(tb_imem_load[1][9]),
		.imem_load_1_10(tb_imem_load[1][10]),
		.imem_load_1_11(tb_imem_load[1][11]),
		.imem_load_1_12(tb_imem_load[1][12]),
		.imem_load_1_13(tb_imem_load[1][13]),
		.imem_load_1_14(tb_imem_load[1][14]),
		.imem_load_1_15(tb_imem_load[1][15]),
		.imem_load_1_16(tb_imem_load[1][16]),
		.imem_load_1_17(tb_imem_load[1][17]),
		.imem_load_1_18(tb_imem_load[1][18]),
		.imem_load_1_19(tb_imem_load[1][19]),
		.imem_load_1_20(tb_imem_load[1][20]),
		.imem_load_1_21(tb_imem_load[1][21]),
		.imem_load_1_22(tb_imem_load[1][22]),
		.imem_load_1_23(tb_imem_load[1][23]),
		.imem_load_1_24(tb_imem_load[1][24]),
		.imem_load_1_25(tb_imem_load[1][25]),
		.imem_load_1_26(tb_imem_load[1][26]),
		.imem_load_1_27(tb_imem_load[1][27]),
		.imem_load_1_28(tb_imem_load[1][28]),
		.imem_load_1_29(tb_imem_load[1][29]),
		.imem_load_1_30(tb_imem_load[1][30]),
		.imem_load_1_31(tb_imem_load[1][31])
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
        // First Miss:
        test_case = "First Miss";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "first icache req";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b1;
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

		// simulate LAT=2
			// 5 cycles to get block
		for (int i = 0; i < ICACHE_NUM_SETS * 5; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("imem req (%h)", 4'(i / 5));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			/////////////////////
			// core interface: //
			/////////////////////
			tb_icache_REN = 1'b1;
			tb_icache_addr = 32'h0;
			tb_icache_halt = 1'b0;
			////////////////////
			// mem interface: //
			////////////////////
			tb_imem_hit = i % 5 == 4;
			tb_imem_load = {{16'hffff, 16'((i / 5) * 2 + 1)}, {16'hffff, 16'((i / 5) * 2)}};

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			/////////////////////
			// core interface: //
			/////////////////////
			expected_icache_hit = i >= 5 ? 1'b1 : 1'b0;
			expected_icache_load = i >= 5 ? {16'hffff, 16'h0} : 32'h0;
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b1;
			expected_imem_block_addr = i / 5;

			check_outputs();
		end

		// get stream buffer hits
		for (int i = 0; i < ICACHE_NUM_SETS * 2; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("icache req (%h, %h)", 4'(i >> 1), 1'(i[0]));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			/////////////////////
			// core interface: //
			/////////////////////
			tb_icache_REN = 1'b1;
			tb_icache_addr = i << 2;
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
			expected_icache_hit = 1'b1;
			expected_icache_load = {16'hffff, 16'(i)};
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b0;
			expected_imem_block_addr = 13'h0;

			check_outputs();
		end

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // Pop a Miss:
        test_case = "Pop a Miss";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "icache req @ 0x0200";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b1;
		tb_icache_addr = 32'h00000200;
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
		expected_icache_load = 32'hffff0000;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 13'h0;

		check_outputs();

		// simulate LAT=2
			// 5 cycles to get block
		for (int i = 0; i < ICACHE_NUM_SETS * 5; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("imem req (%h)", 8'(32'h200 >> 3) + 4'(i / 5));
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
			tb_imem_hit = i % 5 == 4;
			tb_imem_load = {{16'he3e3, 16'((i / 5) * 2 + 1)}, {16'he3e3, 16'((i / 5) * 2)}};

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			/////////////////////
			// core interface: //
			/////////////////////
			expected_icache_hit = 1'b0;
			expected_icache_load = 32'hffff0000;
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b1;
			expected_imem_block_addr = (32'h200 >> 3) + i / 5;

			check_outputs();
		end

		// still get loop way hits
		for (int i = 0; i < ICACHE_NUM_SETS * 2; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("icache req (%h, %h)", 4'(i >> 1), 1'(i[0]));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			/////////////////////
			// core interface: //
			/////////////////////
			tb_icache_REN = 1'b1;
			tb_icache_addr = i << 2;
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
			expected_icache_hit = 1'b1;
			expected_icache_load = {16'hffff, 16'(i)};
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b0;
			expected_imem_block_addr = 16'h200 >> 3;

			check_outputs();
		end

		// stream buffer hits
		for (int i = 0; i < ICACHE_NUM_SETS * 2; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("icache req (%h, %h)", 8'((32'h200 >> 3) + i >> 1), 1'(i[0]));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			/////////////////////
			// core interface: //
			/////////////////////
			tb_icache_REN = 1'b1;
			tb_icache_addr = (32'h200) + (i << 2);
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
			expected_icache_hit = 1'b1;
			expected_icache_load = {16'he3e3, 16'(i)};
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b0;
			expected_imem_block_addr = 16'h200 >> 3;

			check_outputs();
		end

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // Pop a Miss @ Middle Index:
        test_case = "Pop a Miss @ Middle Index";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "icache req @ 0x141C";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b1;
		tb_icache_addr = 32'h0000141C;
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
		expected_icache_load = 32'he3e30007;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 16'h200 >> 3;

		check_outputs();

		// simulate LAT=2
			// 5 cycles to get block
		for (int i = 0; i < ICACHE_NUM_SETS * 5; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("imem req (%h)", 12'(32'h141C >> 3) + 4'(i / 5));
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
			tb_imem_hit = i % 5 == 4;
			tb_imem_load = {{16'h1414, 16'((i / 5) * 2 + 1)}, {16'h1414, 16'((i / 5) * 2)}};

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			/////////////////////
			// core interface: //
			/////////////////////
			expected_icache_hit = 1'b0;
			expected_icache_load = 32'he3e30000;
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b1;
			expected_imem_block_addr = (32'h141C >> 3) + i / 5;

			check_outputs();
		end

		// still get loop way hits
		for (int i = 0; i < ICACHE_NUM_SETS * 2; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("icache req (%h, %h)", 8'((32'h200 >> 3) + i >> 1), 1'(i[0]));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			/////////////////////
			// core interface: //
			/////////////////////
			tb_icache_REN = 1'b1;
			tb_icache_addr = (32'h200) + (i << 2);
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
			expected_icache_hit = 1'b1;
			expected_icache_load = {16'he3e3, 16'(i)};
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b0;
			expected_imem_block_addr = 16'h141C >> 3;

			check_outputs();
		end

		// stream buffer hits
		for (int i = 0; i < ICACHE_NUM_SETS * 2; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("icache req (%h, %h)", 8'((32'h1418 >> 3) + i >> 1), 1'(i[0]));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			/////////////////////
			// core interface: //
			/////////////////////
			tb_icache_REN = 1'b1;
			tb_icache_addr = (32'h1418) + (i << 2);
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
			expected_icache_hit = 1'b1;
			expected_icache_load = {16'h1414, 16'(i)};
			////////////////////
			// mem interface: //
			////////////////////
			expected_imem_REN = 1'b0;
			expected_imem_block_addr = 16'h141C >> 3;

			check_outputs();
		end

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // icache halt:
        test_case = "icache halt";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "icache halt";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b0;
		tb_icache_addr = 32'h0;
		tb_icache_halt = 1'b1;
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
		expected_icache_load = 32'h1414000a;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 16'h141C >> 3;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "try to start stream with miss @ 0x0100";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b1;
		tb_icache_addr = 32'h0100;
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
		expected_icache_load = 32'h1414000a;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 16'h141C >> 3;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "couldn't start stream with miss @ 0x0100";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b1;
		tb_icache_addr = 32'h0100;
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
		expected_icache_load = 32'h1414000a;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 16'h0100 >> 3;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "still couldn't start stream with miss @ 0x0100";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
		tb_icache_REN = 1'b0;
		tb_icache_addr = 32'h0100;
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
		expected_icache_load = 32'h1414000a;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
		expected_imem_REN = 1'b0;
		expected_imem_block_addr = 16'h0100 >> 3;

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

