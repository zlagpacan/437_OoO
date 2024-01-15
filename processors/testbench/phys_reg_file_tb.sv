/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_file_tb.sv
    Description: 
       Testbench for phys_reg_file module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_file_tb ();

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

    // overloaded read flag
	logic DUT_read_overload, expected_read_overload;

    // read reqs:

    // LQ read req
	logic tb_LQ_read_req_valid;
	phys_reg_tag_t tb_LQ_read_req_tag;
	logic DUT_LQ_read_req_serviced, expected_LQ_read_req_serviced;

    // ALU 0 read req
	logic tb_ALU_0_read_req_valid;
	phys_reg_tag_t tb_ALU_0_read_req_0_tag;
	phys_reg_tag_t tb_ALU_0_read_req_1_tag;
	logic DUT_ALU_0_read_req_serviced, expected_ALU_0_read_req_serviced;

    // ALU 1 read req 0
	logic tb_ALU_1_read_req_valid;
	phys_reg_tag_t tb_ALU_1_read_req_0_tag;
	phys_reg_tag_t tb_ALU_1_read_req_1_tag;
	logic DUT_ALU_1_read_req_serviced, expected_ALU_1_read_req_serviced;

    // BRU read req 0
	logic tb_BRU_read_req_valid;
	phys_reg_tag_t tb_BRU_read_req_0_tag;
	phys_reg_tag_t tb_BRU_read_req_1_tag;
	logic DUT_BRU_read_req_serviced, expected_BRU_read_req_serviced;

    // SQ read req 0
	logic tb_SQ_read_req_valid;
	phys_reg_tag_t tb_SQ_read_req_0_tag;
	phys_reg_tag_t tb_SQ_read_req_1_tag;
	logic DUT_SQ_read_req_serviced, expected_SQ_read_req_serviced;

    // read bus:
	word_t DUT_read_bus_0_data, expected_read_bus_0_data;
	word_t DUT_read_bus_1_data, expected_read_bus_1_data;

    // write reqs:

    // LQ write req
	logic tb_LQ_write_req_valid;
	phys_reg_tag_t tb_LQ_write_req_tag;
	word_t tb_LQ_write_req_data;
	logic DUT_LQ_write_req_serviced, expected_LQ_write_req_serviced;

    // ALU 0 write req
	logic tb_ALU_0_write_req_valid;
	phys_reg_tag_t tb_ALU_0_write_req_tag;
	word_t tb_ALU_0_write_req_data;
	logic DUT_ALU_0_write_req_serviced, expected_ALU_0_write_req_serviced;

    // ALU 1 write req
	logic tb_ALU_1_write_req_valid;
	phys_reg_tag_t tb_ALU_1_write_req_tag;
	word_t tb_ALU_1_write_req_data;
	logic DUT_ALU_1_write_req_serviced, expected_ALU_1_write_req_serviced;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	phys_reg_file DUT (

		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // overloaded read flag
		.read_overload(DUT_read_overload),

	    // read reqs:

	    // LQ read req
		.LQ_read_req_valid(tb_LQ_read_req_valid),
		.LQ_read_req_tag(tb_LQ_read_req_tag),
		.LQ_read_req_serviced(DUT_LQ_read_req_serviced),

	    // ALU 0 read req
		.ALU_0_read_req_valid(tb_ALU_0_read_req_valid),
		.ALU_0_read_req_0_tag(tb_ALU_0_read_req_0_tag),
		.ALU_0_read_req_1_tag(tb_ALU_0_read_req_1_tag),
		.ALU_0_read_req_serviced(DUT_ALU_0_read_req_serviced),

	    // ALU 1 read req 0
		.ALU_1_read_req_valid(tb_ALU_1_read_req_valid),
		.ALU_1_read_req_0_tag(tb_ALU_1_read_req_0_tag),
		.ALU_1_read_req_1_tag(tb_ALU_1_read_req_1_tag),
		.ALU_1_read_req_serviced(DUT_ALU_1_read_req_serviced),

	    // BRU read req 0
		.BRU_read_req_valid(tb_BRU_read_req_valid),
		.BRU_read_req_0_tag(tb_BRU_read_req_0_tag),
		.BRU_read_req_1_tag(tb_BRU_read_req_1_tag),
		.BRU_read_req_serviced(DUT_BRU_read_req_serviced),

	    // SQ read req 0
		.SQ_read_req_valid(tb_SQ_read_req_valid),
		.SQ_read_req_0_tag(tb_SQ_read_req_0_tag),
		.SQ_read_req_1_tag(tb_SQ_read_req_1_tag),
		.SQ_read_req_serviced(DUT_SQ_read_req_serviced),

	    // read bus:
		.read_bus_0_data(DUT_read_bus_0_data),
		.read_bus_1_data(DUT_read_bus_1_data),

	    // write reqs:

	    // LQ write req
		.LQ_write_req_valid(tb_LQ_write_req_valid),
		.LQ_write_req_tag(tb_LQ_write_req_tag),
		.LQ_write_req_data(tb_LQ_write_req_data),
		.LQ_write_req_serviced(DUT_LQ_write_req_serviced),

	    // ALU 0 write req
		.ALU_0_write_req_valid(tb_ALU_0_write_req_valid),
		.ALU_0_write_req_tag(tb_ALU_0_write_req_tag),
		.ALU_0_write_req_data(tb_ALU_0_write_req_data),
		.ALU_0_write_req_serviced(DUT_ALU_0_write_req_serviced),

	    // ALU 1 write req
		.ALU_1_write_req_valid(tb_ALU_1_write_req_valid),
		.ALU_1_write_req_tag(tb_ALU_1_write_req_tag),
		.ALU_1_write_req_data(tb_ALU_1_write_req_data),
		.ALU_1_write_req_serviced(DUT_ALU_1_write_req_serviced)
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

		if (expected_read_overload !== DUT_read_overload) begin
			$display("TB ERROR: expected_read_overload (%h) != DUT_read_overload (%h)",
				expected_read_overload, DUT_read_overload);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_read_req_serviced !== DUT_LQ_read_req_serviced) begin
			$display("TB ERROR: expected_LQ_read_req_serviced (%h) != DUT_LQ_read_req_serviced (%h)",
				expected_LQ_read_req_serviced, DUT_LQ_read_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_0_read_req_serviced !== DUT_ALU_0_read_req_serviced) begin
			$display("TB ERROR: expected_ALU_0_read_req_serviced (%h) != DUT_ALU_0_read_req_serviced (%h)",
				expected_ALU_0_read_req_serviced, DUT_ALU_0_read_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_1_read_req_serviced !== DUT_ALU_1_read_req_serviced) begin
			$display("TB ERROR: expected_ALU_1_read_req_serviced (%h) != DUT_ALU_1_read_req_serviced (%h)",
				expected_ALU_1_read_req_serviced, DUT_ALU_1_read_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_BRU_read_req_serviced !== DUT_BRU_read_req_serviced) begin
			$display("TB ERROR: expected_BRU_read_req_serviced (%h) != DUT_BRU_read_req_serviced (%h)",
				expected_BRU_read_req_serviced, DUT_BRU_read_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_read_req_serviced !== DUT_SQ_read_req_serviced) begin
			$display("TB ERROR: expected_SQ_read_req_serviced (%h) != DUT_SQ_read_req_serviced (%h)",
				expected_SQ_read_req_serviced, DUT_SQ_read_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_read_bus_0_data !== DUT_read_bus_0_data) begin
			$display("TB ERROR: expected_read_bus_0_data (%h) != DUT_read_bus_0_data (%h)",
				expected_read_bus_0_data, DUT_read_bus_0_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_read_bus_1_data !== DUT_read_bus_1_data) begin
			$display("TB ERROR: expected_read_bus_1_data (%h) != DUT_read_bus_1_data (%h)",
				expected_read_bus_1_data, DUT_read_bus_1_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_write_req_serviced !== DUT_LQ_write_req_serviced) begin
			$display("TB ERROR: expected_LQ_write_req_serviced (%h) != DUT_LQ_write_req_serviced (%h)",
				expected_LQ_write_req_serviced, DUT_LQ_write_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_0_write_req_serviced !== DUT_ALU_0_write_req_serviced) begin
			$display("TB ERROR: expected_ALU_0_write_req_serviced (%h) != DUT_ALU_0_write_req_serviced (%h)",
				expected_ALU_0_write_req_serviced, DUT_ALU_0_write_req_serviced);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_1_write_req_serviced !== DUT_ALU_1_write_req_serviced) begin
			$display("TB ERROR: expected_ALU_1_write_req_serviced (%h) != DUT_ALU_1_write_req_serviced (%h)",
				expected_ALU_1_write_req_serviced, DUT_ALU_1_write_req_serviced);
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
	    // overloaded read flag
	    // read reqs:
	    // LQ read req
		tb_LQ_read_req_valid = 1'b0;
		tb_LQ_read_req_tag = phys_reg_tag_t'(0);
	    // ALU 0 read req
		tb_ALU_0_read_req_valid = 1'b0;
		tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(0);
		tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(0);
	    // ALU 1 read req 0
		tb_ALU_1_read_req_valid = 1'b0;
		tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(0);
		tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(0);
	    // BRU read req 0
		tb_BRU_read_req_valid = 1'b0;
		tb_BRU_read_req_0_tag = phys_reg_tag_t'(0);
		tb_BRU_read_req_1_tag = phys_reg_tag_t'(0);
	    // SQ read req 0
		tb_SQ_read_req_valid = 1'b0;
		tb_SQ_read_req_0_tag = phys_reg_tag_t'(0);
		tb_SQ_read_req_1_tag = phys_reg_tag_t'(0);
	    // read bus:
	    // write reqs:
	    // LQ write req
		tb_LQ_write_req_valid = 1'b0;
		tb_LQ_write_req_tag = phys_reg_tag_t'(0);
		tb_LQ_write_req_data = word_t'(0);
	    // ALU 0 write req
		tb_ALU_0_write_req_valid = 1'b0;
		tb_ALU_0_write_req_tag = phys_reg_tag_t'(0);
		tb_ALU_0_write_req_data = word_t'(0);
	    // ALU 1 write req
		tb_ALU_1_write_req_valid = 1'b0;
		tb_ALU_1_write_req_tag = phys_reg_tag_t'(0);
		tb_ALU_1_write_req_data = word_t'(0);

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // overloaded read flag
		expected_read_overload = 1'b0;
	    // read reqs:
	    // LQ read req
		expected_LQ_read_req_serviced = 1'b0;
	    // ALU 0 read req
		expected_ALU_0_read_req_serviced = 1'b0;
	    // ALU 1 read req 0
		expected_ALU_1_read_req_serviced = 1'b0;
	    // BRU read req 0
		expected_BRU_read_req_serviced = 1'b0;
	    // SQ read req 0
		expected_SQ_read_req_serviced = 1'b0;
	    // read bus:
		expected_read_bus_0_data = word_t'(0);
		expected_read_bus_1_data = word_t'(0);
	    // write reqs:
	    // LQ write req
		expected_LQ_write_req_serviced = 1'b0;
	    // ALU 0 write req
		expected_ALU_0_write_req_serviced = 1'b0;
	    // ALU 1 write req
		expected_ALU_1_write_req_serviced = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // overloaded read flag
	    // read reqs:
	    // LQ read req
		tb_LQ_read_req_valid = 1'b0;
		tb_LQ_read_req_tag = phys_reg_tag_t'(0);
	    // ALU 0 read req
		tb_ALU_0_read_req_valid = 1'b0;
		tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(0);
		tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(0);
	    // ALU 1 read req 0
		tb_ALU_1_read_req_valid = 1'b0;
		tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(0);
		tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(0);
	    // BRU read req 0
		tb_BRU_read_req_valid = 1'b0;
		tb_BRU_read_req_0_tag = phys_reg_tag_t'(0);
		tb_BRU_read_req_1_tag = phys_reg_tag_t'(0);
	    // SQ read req 0
		tb_SQ_read_req_valid = 1'b0;
		tb_SQ_read_req_0_tag = phys_reg_tag_t'(0);
		tb_SQ_read_req_1_tag = phys_reg_tag_t'(0);
	    // read bus:
	    // write reqs:
	    // LQ write req
		tb_LQ_write_req_valid = 1'b0;
		tb_LQ_write_req_tag = phys_reg_tag_t'(0);
		tb_LQ_write_req_data = word_t'(0);
	    // ALU 0 write req
		tb_ALU_0_write_req_valid = 1'b0;
		tb_ALU_0_write_req_tag = phys_reg_tag_t'(0);
		tb_ALU_0_write_req_data = word_t'(0);
	    // ALU 1 write req
		tb_ALU_1_write_req_valid = 1'b0;
		tb_ALU_1_write_req_tag = phys_reg_tag_t'(0);
		tb_ALU_1_write_req_data = word_t'(0);

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // overloaded read flag
		expected_read_overload = 1'b0;
	    // read reqs:
	    // LQ read req
		expected_LQ_read_req_serviced = 1'b0;
	    // ALU 0 read req
		expected_ALU_0_read_req_serviced = 1'b0;
	    // ALU 1 read req 0
		expected_ALU_1_read_req_serviced = 1'b0;
	    // BRU read req 0
		expected_BRU_read_req_serviced = 1'b0;
	    // SQ read req 0
		expected_SQ_read_req_serviced = 1'b0;
	    // read bus:
		expected_read_bus_0_data = word_t'(0);
		expected_read_bus_1_data = word_t'(0);
	    // write reqs:
	    // LQ write req
		expected_LQ_write_req_serviced = 1'b0;
	    // ALU 0 write req
		expected_ALU_0_write_req_serviced = 1'b0;
	    // ALU 1 write req
		expected_ALU_1_write_req_serviced = 1'b0;

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
	    // overloaded read flag
	    // read reqs:
	    // LQ read req
		tb_LQ_read_req_valid = 1'b0;
		tb_LQ_read_req_tag = phys_reg_tag_t'(0);
	    // ALU 0 read req
		tb_ALU_0_read_req_valid = 1'b0;
		tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(0);
		tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(0);
	    // ALU 1 read req 0
		tb_ALU_1_read_req_valid = 1'b0;
		tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(0);
		tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(0);
	    // BRU read req 0
		tb_BRU_read_req_valid = 1'b0;
		tb_BRU_read_req_0_tag = phys_reg_tag_t'(0);
		tb_BRU_read_req_1_tag = phys_reg_tag_t'(0);
	    // SQ read req 0
		tb_SQ_read_req_valid = 1'b0;
		tb_SQ_read_req_0_tag = phys_reg_tag_t'(0);
		tb_SQ_read_req_1_tag = phys_reg_tag_t'(0);
	    // read bus:
	    // write reqs:
	    // LQ write req
		tb_LQ_write_req_valid = 1'b0;
		tb_LQ_write_req_tag = phys_reg_tag_t'(0);
		tb_LQ_write_req_data = word_t'(0);
	    // ALU 0 write req
		tb_ALU_0_write_req_valid = 1'b0;
		tb_ALU_0_write_req_tag = phys_reg_tag_t'(0);
		tb_ALU_0_write_req_data = word_t'(0);
	    // ALU 1 write req
		tb_ALU_1_write_req_valid = 1'b0;
		tb_ALU_1_write_req_tag = phys_reg_tag_t'(0);
		tb_ALU_1_write_req_data = word_t'(0);

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // overloaded read flag
		expected_read_overload = 1'b0;
	    // read reqs:
	    // LQ read req
		expected_LQ_read_req_serviced = 1'b0;
	    // ALU 0 read req
		expected_ALU_0_read_req_serviced = 1'b0;
	    // ALU 1 read req 0
		expected_ALU_1_read_req_serviced = 1'b0;
	    // BRU read req 0
		expected_BRU_read_req_serviced = 1'b0;
	    // SQ read req 0
		expected_SQ_read_req_serviced = 1'b0;
	    // read bus:
		expected_read_bus_0_data = word_t'(0);
		expected_read_bus_1_data = word_t'(0);
	    // write reqs:
	    // LQ write req
		expected_LQ_write_req_serviced = 1'b0;
	    // ALU 0 write req
		expected_ALU_0_write_req_serviced = 1'b0;
	    // ALU 1 write req
		expected_ALU_1_write_req_serviced = 1'b0;

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // reset read strobe:
        test_case = "reset read strobe";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		for (int i = 0; i < 64; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("read reg's %d and %d with port %d", 6'(unsigned'(i)), 6'(unsigned'(i + 1)), 3'(unsigned'(i % 5)));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			// overloaded read flag
			// read reqs:
			// LQ read req
			tb_LQ_read_req_valid = (i % 5) == 0;
			tb_LQ_read_req_tag = phys_reg_tag_t'(i);
			// ALU 0 read req
			tb_ALU_0_read_req_valid = (i % 5) == 1;
			tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(i);
			tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// ALU 1 read req 0
			tb_ALU_1_read_req_valid = (i % 5) == 2;
			tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(i);
			tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// BRU read req 0
			tb_BRU_read_req_valid = (i % 5) == 3;
			tb_BRU_read_req_0_tag = phys_reg_tag_t'(i);
			tb_BRU_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// SQ read req 0
			tb_SQ_read_req_valid = (i % 5) == 4;
			tb_SQ_read_req_0_tag = phys_reg_tag_t'(i);
			tb_SQ_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// read bus:
			// write reqs:
			// LQ write req
			tb_LQ_write_req_valid = 1'b0;
			tb_LQ_write_req_tag = phys_reg_tag_t'(i);
			tb_LQ_write_req_data = word_t'(32'h12345678);
			// ALU 0 write req
			tb_ALU_0_write_req_valid = 1'b0;
			tb_ALU_0_write_req_tag = phys_reg_tag_t'(i * 3);
			tb_ALU_0_write_req_data = word_t'(32'habcdef01);
			// ALU 1 write req
			tb_ALU_1_write_req_valid = 1'b0;
			tb_ALU_1_write_req_tag = phys_reg_tag_t'(i * 7);
			tb_ALU_1_write_req_data = word_t'(32'h6543210f);

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			// overloaded read flag
			expected_read_overload = 1'b0;
			// read reqs:
			// LQ read req
			expected_LQ_read_req_serviced = (i % 5) == 0;
			// ALU 0 read req
			expected_ALU_0_read_req_serviced = (i % 5) == 1;
			// ALU 1 read req 0
			expected_ALU_1_read_req_serviced = (i % 5) == 2;
			// BRU read req 0
			expected_BRU_read_req_serviced = (i % 5) == 3;
			// SQ read req 0
			expected_SQ_read_req_serviced = (i % 5) == 4;
			// read bus:
			expected_read_bus_0_data = word_t'(0);
			expected_read_bus_1_data = word_t'(0);
			// write reqs:
			// LQ write req
			expected_LQ_write_req_serviced = 1'b0;
			// ALU 0 write req
			expected_ALU_0_write_req_serviced = 1'b0;
			// ALU 1 write req
			expected_ALU_1_write_req_serviced = 1'b0;

			check_outputs();

		end

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // i write; i-2,i-1 read strobe:
        test_case = "i write; i-2,i-1 read strobe";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		for (int i = 0; i < 64; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("write reg %d with port %d, read reg's %d, %d with port %d", 
				6'(unsigned'(i)), 2'(unsigned'(i % 3)),
				6'(unsigned'(i - 2)), 6'(unsigned'(i - 1)), 3'(unsigned'(i % 5)));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			// overloaded read flag
			// read reqs:
			// LQ read req
			tb_LQ_read_req_valid = (i % 5) == 0;
			tb_LQ_read_req_tag = phys_reg_tag_t'(i - 2);
			// ALU 0 read req
			tb_ALU_0_read_req_valid = (i % 5) == 1;
			tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(i - 2);
			tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(i - 1);
			// ALU 1 read req 0
			tb_ALU_1_read_req_valid = (i % 5) == 2;
			tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(i - 2);
			tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(i - 1);
			// BRU read req 0
			tb_BRU_read_req_valid = (i % 5) == 3;
			tb_BRU_read_req_0_tag = phys_reg_tag_t'(i - 2);
			tb_BRU_read_req_1_tag = phys_reg_tag_t'(i - 1);
			// SQ read req 0
			tb_SQ_read_req_valid = (i % 5) == 4;
			tb_SQ_read_req_0_tag = phys_reg_tag_t'(i - 2);
			tb_SQ_read_req_1_tag = phys_reg_tag_t'(i - 1);
			// read bus:
			// write reqs:
			// LQ write req
			tb_LQ_write_req_valid = (i % 3) == 0;
			tb_LQ_write_req_tag = phys_reg_tag_t'(i);
			tb_LQ_write_req_data = word_t'({4{8'(i)}});
			// ALU 0 write req
			tb_ALU_0_write_req_valid = (i % 3) == 1;
			tb_ALU_0_write_req_tag = phys_reg_tag_t'(i);
			tb_ALU_0_write_req_data = word_t'({4{8'(i)}});
			// ALU 1 write req
			tb_ALU_1_write_req_valid = (i % 3) == 2;
			tb_ALU_1_write_req_tag = phys_reg_tag_t'(i);
			tb_ALU_1_write_req_data = word_t'({4{8'(i)}});

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			// overloaded read flag
			expected_read_overload = 1'b0;
			// read reqs:
			// LQ read req
			expected_LQ_read_req_serviced = (i % 5) == 0;
			// ALU 0 read req
			expected_ALU_0_read_req_serviced = (i % 5) == 1;
			// ALU 1 read req 0
			expected_ALU_1_read_req_serviced = (i % 5) == 2;
			// BRU read req 0
			expected_BRU_read_req_serviced = (i % 5) == 3;
			// SQ read req 0
			expected_SQ_read_req_serviced = (i % 5) == 4;
			// read bus:
			expected_read_bus_0_data = i < 2 ? 0 : word_t'({4{8'(i - 2)}});
			expected_read_bus_1_data = i < 1 ? 0 : word_t'({4{8'(i - 1)}});
			// write reqs:
			// LQ write req
			expected_LQ_write_req_serviced = (i % 3) == 0;
			// ALU 0 write req
			expected_ALU_0_write_req_serviced = (i % 3) == 1;
			// ALU 1 write req
			expected_ALU_1_write_req_serviced = (i % 3) == 2;

			check_outputs();

		end

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // triple write double read strobe:
        test_case = "triple write double read strobe";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		for (int i = 0; i < 62; i++) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("write reg's %d,%d,%d read reg's %d,%d with port %d", 
				6'(unsigned'(i)), 6'(unsigned'(i + 1)), 6'(unsigned'(i + 2)),
				6'(unsigned'(i)), 6'(unsigned'(i + 1)), 3'(unsigned'(i % 5)));
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			// overloaded read flag
			// read reqs:
			// LQ read req
			tb_LQ_read_req_valid = (i % 5) == 0;
			tb_LQ_read_req_tag = phys_reg_tag_t'(i);
			// ALU 0 read req
			tb_ALU_0_read_req_valid = (i % 5) == 1;
			tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(i);
			tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// ALU 1 read req 0
			tb_ALU_1_read_req_valid = (i % 5) == 2;
			tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(i);
			tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// BRU read req 0
			tb_BRU_read_req_valid = (i % 5) == 3;
			tb_BRU_read_req_0_tag = phys_reg_tag_t'(i);
			tb_BRU_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// SQ read req 0
			tb_SQ_read_req_valid = (i % 5) == 4;
			tb_SQ_read_req_0_tag = phys_reg_tag_t'(i);
			tb_SQ_read_req_1_tag = phys_reg_tag_t'(i + 1);
			// read bus:
			// write reqs:
			// LQ write req
			tb_LQ_write_req_valid = 1'b1;
			tb_LQ_write_req_tag = phys_reg_tag_t'(i + 1);
			tb_LQ_write_req_data = word_t'({4{8'(255-(i%64))}});
			// ALU 0 write req
			tb_ALU_0_write_req_valid = 1'b1;
			tb_ALU_0_write_req_tag = phys_reg_tag_t'(i + 2);
			tb_ALU_0_write_req_data = word_t'({4{8'(133-(i%64))}});
			// ALU 1 write req
			tb_ALU_1_write_req_valid = 1'b1;
			tb_ALU_1_write_req_tag = phys_reg_tag_t'(i);
			tb_ALU_1_write_req_data = word_t'({4{8'(22-(i%64))}});

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			// overloaded read flag
			expected_read_overload = 1'b0;
			// read reqs:
			// LQ read req
			expected_LQ_read_req_serviced = (i % 5) == 0;
			// ALU 0 read req
			expected_ALU_0_read_req_serviced = (i % 5) == 1;
			// ALU 1 read req 0
			expected_ALU_1_read_req_serviced = (i % 5) == 2;
			// BRU read req 0
			expected_BRU_read_req_serviced = (i % 5) == 3;
			// SQ read req 0
			expected_SQ_read_req_serviced = (i % 5) == 4;
			// read bus:
			expected_read_bus_0_data = word_t'({4{8'(22-(i%64))}});
			expected_read_bus_1_data = word_t'({4{8'(255-(i%64))}});
			// write reqs:
			// LQ write req
			expected_LQ_write_req_serviced = 1'b1;
			// ALU 0 write req
			expected_ALU_0_write_req_serviced = 1'b1;
			// ALU 1 write req
			expected_ALU_1_write_req_serviced = 1'b1;

			check_outputs();

		end

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // read overloading:
        test_case = "read overloading";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		for (logic [5:0] i = 6'b011111; i != 6'b111111; i--) begin

			@(posedge CLK);

			// inputs
			sub_test_case = $sformatf("read reg %d = %b: LQ: %d, ALU 0: %d, ALU 1: %d, BRU: %d, SQ: %d", 
				i, i, i[4], i[3], i[2], i[1], i[0]	
			);
			$display("\t- sub_test: %s", sub_test_case);

			// reset
			nRST = 1'b1;
			// DUT error
			// overloaded read flag
			// read reqs:
			// LQ read req
			tb_LQ_read_req_valid = i[4];
			tb_LQ_read_req_tag = phys_reg_tag_t'(i);
			// ALU 0 read req
			tb_ALU_0_read_req_valid = i[3];
			tb_ALU_0_read_req_0_tag = phys_reg_tag_t'(i + 1);
			tb_ALU_0_read_req_1_tag = phys_reg_tag_t'(i + 2);
			// ALU 1 read req 0
			tb_ALU_1_read_req_valid = i[2];
			tb_ALU_1_read_req_0_tag = phys_reg_tag_t'(i + 2);
			tb_ALU_1_read_req_1_tag = phys_reg_tag_t'(i + 3);
			// BRU read req 0
			tb_BRU_read_req_valid = i[1];
			tb_BRU_read_req_0_tag = phys_reg_tag_t'(i + 3);
			tb_BRU_read_req_1_tag = phys_reg_tag_t'(i + 4);
			// SQ read req 0
			tb_SQ_read_req_valid = i[0];
			tb_SQ_read_req_0_tag = phys_reg_tag_t'(i + 4);
			tb_SQ_read_req_1_tag = phys_reg_tag_t'(i + 5);
			// read bus:
			// write reqs:
			// LQ write req
			tb_LQ_write_req_valid = 1'b0;
			tb_LQ_write_req_tag = phys_reg_tag_t'(i + 1);
			tb_LQ_write_req_data = word_t'({4{8'(255-(i%64))}});
			// ALU 0 write req
			tb_ALU_0_write_req_valid = 1'b0;
			tb_ALU_0_write_req_tag = phys_reg_tag_t'(i + 2);
			tb_ALU_0_write_req_data = word_t'({4{8'(133-(i%64))}});
			// ALU 1 write req
			tb_ALU_1_write_req_valid = 1'b0;
			tb_ALU_1_write_req_tag = phys_reg_tag_t'(i);
			tb_ALU_1_write_req_data = word_t'({4{8'(22-(i%64))}});

			@(negedge CLK);

			// outputs:

			// DUT error
			expected_DUT_error = 1'b0;
			// overloaded read flag
			expected_read_overload = $countones(i) > 1;
			// read reqs:
			// LQ read req
			expected_LQ_read_req_serviced = i[4];
			// ALU 0 read req
			expected_ALU_0_read_req_serviced = ~i[4] & i[3];
			// ALU 1 read req 0
			expected_ALU_1_read_req_serviced = ~i[4] & ~i[3] & i[2];
			// BRU read req 0
			expected_BRU_read_req_serviced = ~i[4] & ~i[3] & ~i[2] & i[1];
			// SQ read req 0
			expected_SQ_read_req_serviced = ~i[4] & ~i[3] & ~i[2] & ~i[1] & i[0];
			// read bus:
			expected_read_bus_0_data = 
				i[4] ? word_t'({4{8'(22-(i%64))}}) :
				i[3] ? word_t'({4{8'(22-((i+1)%64))}}) :
				i[2] ? word_t'({4{8'(22-((i+2)%64))}}) :
				i[1] ? word_t'({4{8'(22-((i+3)%64))}}) :
				i[0] ? word_t'({4{8'(22-((i+4)%64))}}) :
				word_t'({4{8'(22-((i+1)%64))}})
			;
			expected_read_bus_1_data = 
				i[4] ? word_t'({4{8'(22-((i+2)%64))}}) :
				i[3] ? word_t'({4{8'(22-((i+2)%64))}}) :
				i[2] ? word_t'({4{8'(22-((i+3)%64))}}) :
				i[1] ? word_t'({4{8'(22-((i+4)%64))}}) :
				i[0] ? word_t'({4{8'(22-((i+5)%64))}}) :
				word_t'({4{8'(22-((i+2)%64))}})
			;
			// write reqs:
			// LQ write req
			expected_LQ_write_req_serviced = 1'b0;
			// ALU 0 write req
			expected_ALU_0_write_req_serviced = 1'b0;
			// ALU 1 write req
			expected_ALU_1_write_req_serviced = 1'b0;

			check_outputs();

		end

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

