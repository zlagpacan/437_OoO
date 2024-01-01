/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_ready_table_tb.sv
    Instantiation Hierarchy: system -> core -> phys_reg_ready_table
    Description: 
       Testbench for phys_reg_ready_table module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_ready_table_tb ();

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

    // dispatch
        // read @ source 0
        // read @ source 1
        // clear @ dest
	phys_reg_tag_t tb_dispatch_source_0_phys_reg_tag;
	logic DUT_dispatch_source_0_ready, expected_dispatch_source_0_ready;
	phys_reg_tag_t tb_dispatch_source_1_phys_reg_tag;
	logic DUT_dispatch_source_1_ready, expected_dispatch_source_1_ready;
	logic tb_dispatch_dest_write;
	phys_reg_tag_t tb_dispatch_dest_phys_reg_tag;

    // complete
        // set @ complete bus 0 dest
        // set @ complete bus 1 dest
	logic tb_complete_bus_0_valid;
	phys_reg_tag_t tb_complete_bus_0_dest_phys_reg_tag;
	logic tb_complete_bus_1_valid;
	phys_reg_tag_t tb_complete_bus_1_dest_phys_reg_tag;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	phys_reg_ready_table #(

	) DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // dispatch
	        // read @ source 0
	        // read @ source 1
	        // clear @ dest
		.dispatch_source_0_phys_reg_tag(tb_dispatch_source_0_phys_reg_tag),
		.dispatch_source_0_ready(DUT_dispatch_source_0_ready),
		.dispatch_source_1_phys_reg_tag(tb_dispatch_source_1_phys_reg_tag),
		.dispatch_source_1_ready(DUT_dispatch_source_1_ready),
		.dispatch_dest_write(tb_dispatch_dest_write),
		.dispatch_dest_phys_reg_tag(tb_dispatch_dest_phys_reg_tag),

	    // complete
	        // set @ complete bus 0 dest
	        // set @ complete bus 1 dest
		.complete_bus_0_valid(tb_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(tb_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_1_valid(tb_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(tb_complete_bus_1_dest_phys_reg_tag)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
		if (expected_DUT_error !== DUT_DUT_error) begin
			$display("\tERROR: expected_DUT_error (%h) != DUT_DUT_error (%h)",
				expected_DUT_error, DUT_DUT_error);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dispatch_source_0_ready !== DUT_dispatch_source_0_ready) begin
			$display("\tERROR: expected_dispatch_source_0_ready (%h) != DUT_dispatch_source_0_ready (%h)",
				expected_dispatch_source_0_ready, DUT_dispatch_source_0_ready);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dispatch_source_1_ready !== DUT_dispatch_source_1_ready) begin
			$display("\tERROR: expected_dispatch_source_1_ready (%h) != DUT_dispatch_source_1_ready (%h)",
				expected_dispatch_source_1_ready, DUT_dispatch_source_1_ready);
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
	    // dispatch
		tb_dispatch_source_0_phys_reg_tag = phys_reg_tag_t'(0);
		tb_dispatch_source_1_phys_reg_tag = phys_reg_tag_t'(0);
		tb_dispatch_dest_write = 1'b0;
		tb_dispatch_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // dispatch
		expected_dispatch_source_0_ready = 1'b1;
		expected_dispatch_source_1_ready = 1'b1;
	    // complete

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // dispatch
		tb_dispatch_source_0_phys_reg_tag = phys_reg_tag_t'(0);
		tb_dispatch_source_1_phys_reg_tag = phys_reg_tag_t'(0);
		tb_dispatch_dest_write = 1'b0;
		tb_dispatch_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // dispatch
		expected_dispatch_source_0_ready = 1'b1;
		expected_dispatch_source_1_ready = 1'b1;
	    // complete

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
	    // dispatch
		tb_dispatch_source_0_phys_reg_tag = phys_reg_tag_t'(0);
		tb_dispatch_source_1_phys_reg_tag = phys_reg_tag_t'(0);
		tb_dispatch_dest_write = 1'b0;
		tb_dispatch_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // dispatch
		expected_dispatch_source_0_ready = 1'b1;
		expected_dispatch_source_1_ready = 1'b1;
	    // complete

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

