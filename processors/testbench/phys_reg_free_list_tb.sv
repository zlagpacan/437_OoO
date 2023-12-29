/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_free_list_tb.sv
    Instantiation Hierarchy: system -> core -> phys_reg_free_list
    Description: 
       Testbench for phys_reg_free_list module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_free_list_tb ();

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
    logic error = 1'b0;

    // clock gen
    always begin #(PERIOD/2); CLK = ~CLK; end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT signals:

    // dequeue
	logic tb_dequeue_valid;
	phys_reg_tag_t DUT_dequeue_phys_reg_tag, expected_dequeue_phys_reg_tag;

    // enqueue
	logic tb_enqueue_valid;
	phys_reg_tag_t tb_enqueue_phys_reg_tag;

    // full/empty
        // should be left unused but may want to account for potential functionality externally
        // can use for assertions
	logic DUT_full, expected_full;
	logic DUT_empty, expected_empty;

    // reg map revert
	logic tb_revert_valid;
        // input arch_reg_tag_t revert_dest_arch_reg_tag,
        // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
	phys_reg_tag_t tb_revert_speculated_dest_phys_reg_tag;
        // can use for assertion but otherwise don't need

    // free list checkpoint save
	logic tb_save_checkpoint_valid;
	ROB_index_t tb_save_checkpoint_ROB_index;
	checkpoint_column_t DUT_save_checkpoint_safe_column, expected_save_checkpoint_safe_column;

    // free list checkpoint restore
	logic tb_restore_checkpoint_valid;
	logic tb_restore_checkpoint_speculate_failed;
	ROB_index_t tb_restore_checkpoint_ROB_index;
	checkpoint_column_t tb_restore_checkpoint_safe_column;
	logic DUT_restore_checkpoint_success, expected_restore_checkpoint_success;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	phys_reg_free_list #(

	) DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // dequeue
		.dequeue_valid(tb_dequeue_valid),
		.dequeue_phys_reg_tag(DUT_dequeue_phys_reg_tag),

	    // enqueue
		.enqueue_valid(tb_enqueue_valid),
		.enqueue_phys_reg_tag(tb_enqueue_phys_reg_tag),

	    // full/empty
	        // should be left unused but may want to account for potential functionality externally
	        // can use for assertions
		.full(DUT_full),
		.empty(DUT_empty),

	    // reg map revert
		.revert_valid(tb_revert_valid),
	        // input arch_reg_tag_t revert_dest_arch_reg_tag,
	        // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
		.revert_speculated_dest_phys_reg_tag(tb_revert_speculated_dest_phys_reg_tag),
	        // can use for assertion but otherwise don't need

	    // free list checkpoint save
		.save_checkpoint_valid(tb_save_checkpoint_valid),
		.save_checkpoint_ROB_index(tb_save_checkpoint_ROB_index),
		.save_checkpoint_safe_column(DUT_save_checkpoint_safe_column),

	    // free list checkpoint restore
		.restore_checkpoint_valid(tb_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(tb_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(tb_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(tb_restore_checkpoint_safe_column),
		.restore_checkpoint_success(DUT_restore_checkpoint_success)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
		if (expected_dequeue_phys_reg_tag !== DUT_dequeue_phys_reg_tag) begin
			$display("\tERROR: expected_dequeue_phys_reg_tag (%h) != DUT_dequeue_phys_reg_tag (%h)",
				expected_dequeue_phys_reg_tag, DUT_dequeue_phys_reg_tag);
			num_errors++;
			error = 1'b1;
		end

		if (expected_full !== DUT_full) begin
			$display("\tERROR: expected_full (%h) != DUT_full (%h)",
				expected_full, DUT_full);
			num_errors++;
			error = 1'b1;
		end

		if (expected_empty !== DUT_empty) begin
			$display("\tERROR: expected_empty (%h) != DUT_empty (%h)",
				expected_empty, DUT_empty);
			num_errors++;
			error = 1'b1;
		end

		if (expected_save_checkpoint_safe_column !== DUT_save_checkpoint_safe_column) begin
			$display("\tERROR: expected_save_checkpoint_safe_column (%h) != DUT_save_checkpoint_safe_column (%h)",
				expected_save_checkpoint_safe_column, DUT_save_checkpoint_safe_column);
			num_errors++;
			error = 1'b1;
		end

		if (expected_restore_checkpoint_success !== DUT_restore_checkpoint_success) begin
			$display("\tERROR: expected_restore_checkpoint_success (%h) != DUT_restore_checkpoint_success (%h)",
				expected_restore_checkpoint_success, DUT_restore_checkpoint_success);
			num_errors++;
			error = 1'b1;
		end

        #(PERIOD / 10);
        error = 1'b0;
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
	    // dequeue
		tb_dequeue_valid = 1'b0;
	    // enqueue
		tb_enqueue_valid = 1'b0;
		tb_enqueue_phys_reg_tag = phys_reg_tag_t'(0);
	    // full/empty
	    // reg map revert
		tb_revert_valid = 1'b0;
		tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // free list checkpoint save
		tb_save_checkpoint_valid = 1'b0;
		tb_save_checkpoint_ROB_index = ROB_index_t'(0);
	    // free list checkpoint restore
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

		@(posedge CLK);

		// outputs:

	    // dequeue
		expected_dequeue_phys_reg_tag = phys_reg_tag_t'(32);
	    // enqueue
	    // full/empty
		expected_full = 1'b1;
		expected_empty = 1'b0;
	    // reg map revert
	    // free list checkpoint save
		expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
	    // free list checkpoint restore
		expected_restore_checkpoint_success = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // dequeue
		tb_dequeue_valid = 1'b0;
	    // enqueue
		tb_enqueue_valid = 1'b0;
		tb_enqueue_phys_reg_tag = phys_reg_tag_t'(0);
	    // full/empty
	    // reg map revert
		tb_revert_valid = 1'b0;
		tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // free list checkpoint save
		tb_save_checkpoint_valid = 1'b0;
		tb_save_checkpoint_ROB_index = ROB_index_t'(0);
	    // free list checkpoint restore
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

		@(posedge CLK);

		// outputs:

	    // dequeue
		expected_dequeue_phys_reg_tag = phys_reg_tag_t'(32);
	    // enqueue
	    // full/empty
		expected_full = 1'b1;
		expected_empty = 1'b0;
	    // reg map revert
	    // free list checkpoint save
		expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
	    // free list checkpoint restore
		expected_restore_checkpoint_success = 1'b0;

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
	    // dequeue
		tb_dequeue_valid = 1'b0;
	    // enqueue
		tb_enqueue_valid = 1'b0;
		tb_enqueue_phys_reg_tag = phys_reg_tag_t'(0);
	    // full/empty
	    // reg map revert
		tb_revert_valid = 1'b0;
		tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // free list checkpoint save
		tb_save_checkpoint_valid = 1'b0;
		tb_save_checkpoint_ROB_index = ROB_index_t'(0);
	    // free list checkpoint restore
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

		@(negedge CLK);

		// outputs:

	    // dequeue
		expected_dequeue_phys_reg_tag = phys_reg_tag_t'(32);
	    // enqueue
	    // full/empty
		expected_full = 1'b1;
		expected_empty = 1'b0;
	    // reg map revert
	    // free list checkpoint save
		expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
	    // free list checkpoint restore
		expected_restore_checkpoint_success = 1'b0;

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

