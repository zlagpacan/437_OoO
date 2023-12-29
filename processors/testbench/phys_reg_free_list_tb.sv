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
    // input logic dequeue_valid,
    logic tb_dequeue_valid;
    // output phys_reg_tag_t dequeue_phys_reg_tag,
    phys_reg_tag_t prfl_dequeue_phys_reg_tag, expected_dequeue_phys_reg_tag;

    // enqueue
    // input logic enqueue_valid,
    logic tb_enqueue_valid;
    // input phys_reg_tag_t enqueue_phys_reg_tag,
    phys_reg_tag_t prfl_enqueue_phys_reg_tag, expected_phys_reg_tag;

    // full/empty
        // should be left unused by may want to account for potential functionality externally
        // can use for assertions
    // output logic full,
    logic prfl_full, expected_full;
    // output logic empty,
    logic prfl_empty, expected_empty;

    // reg map revert
    // input logic revert_valid,
    logic tb_revert_valid;
    // input arch_reg_tag_t revert_dest_arch_reg_tag,
    // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
    // input phys_reg_tag_t revert_speculated_dest_phys_reg_tag,
    //     // can use for assertion but otherwise don't need
    phys_reg_tag_t tb_revert_speculated_dest_phys_reg_tag, expected_revert_speculated_dest_phys_reg_tag;

    // free list checkpoint save
    // input logic save_checkpoint_valid,
    logic tb_save_checkpoint_valid;
    // input ROB_index_t save_checkpoint_ROB_index,    // from ROB, write tag val
    ROB_index_t tb_save_checkpoint_ROB_index;
    // output checkpoint_column_t save_checkpoint_safe_column,
    checkpoint_column_t prfl_save_checkpoint_safe_column, expected_save_checkpoint_safe_column;

    // free list checkpoint restore
    // input logic restore_checkpoint_valid,
    logic tb_restore_checkpoint_valid;
    // input logic restore_checkpoint_speculate_failed,
    logic tb_restore_checkpoint_speculate_failed;
    // input ROB_index_t restore_checkpoint_ROB_index,  // from restore system, check tag val
    ROB_index_t tb_restore_checkpoint_ROB_index;
    // input checkpoint_column_t restore_checkpoint_safe_column,
    checkpoint_column_t tb_restore_checkpoint_safe_column;
    // output logic restore_checkpoint_success
    logic prfl_restore_checkpoint_success, expected_restore_checkpoint_success;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

    phys_reg_free_list #(
        // no params
    ) DUT (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // dequeue
        .dequeue_valid(tb_dequeue_valid),
        .dequeue_phys_reg_tag(prfl_dequeue_phys_reg_tag),

        // enqueue
        .enqueue_valid(tb_enqueue_valid),
        .enqueue_phys_reg_tag(tb_enqueue_phys_reg_tag),

        // full/empty
            // should be left unused by may want to account for potential functionality externally
            // can use for assertions
        .full(prfl_full),
        .empty(prfl_empty),

        // reg map revert
        .revert_valid(tb_revert_valid),
        // input arch_reg_tag_t revert_dest_arch_reg_tag,
        // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
        .revert_speculated_dest_phys_reg_tag(revert_speculated_dest_phys_reg_tag),
            // can use for assertion but otherwise don't need

        // free list checkpoint save
        .save_checkpoint_valid(tb_save_checkpoint_valid),
        .save_checkpoint_ROB_index(tb_save_checkpoint_ROB_index),    // from ROB, write tag val
        .save_checkpoint_safe_column(prfl_save_checkpoint_safe_column),

        // free list checkpoint restore
        .restore_checkpoint_valid(tb_restore_checkpoint_valid),
        .restore_checkpoint_speculate_failed(tb_restore_checkpoint_speculate_failed),
        .restore_checkpoint_ROB_index(tb_restore_checkpoint_ROB_index),  // from restore system, check tag val
        .restore_checkpoint_safe_column(tb_restore_checkpoint_safe_column),
        .restore_checkpoint_success(prfl_restore_checkpoint_success)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
        if (expected_dequeue_phys_reg_tag !== prfl_dequeue_phys_reg_tag) begin
            $display("\tERROR: expected_dequeue_phys_reg_tag (%h) != prfl_dequeue_phys_reg_tag (%h)", 
                expected_dequeue_phys_reg_tag, prfl_dequeue_phys_reg_tag);
            num_errors++;
            error = 1'b1;
        end

        if (expected_full !== prfl_full) begin
            $display("\tERROR: expected_full (%h) != prfl_full (%h)", 
                expected_full, prfl_full);
            num_errors++;
            error = 1'b1;
        end

        if (expected_save_checkpoint_safe_column !== prfl_save_checkpoint_safe_column) begin
            $display("\tERROR: expected_save_checkpoint_safe_column (%h) != prfl_save_checkpoint_safe_column (%h)",
                expected_save_checkpoint_safe_column, prfl_save_checkpoint_safe_column);
            num_errors++;
            error = 1'b1;
        end

        if (expected_restore_checkpoint_success !== prfl_restore_checkpoint_success) begin
            $display("\tERROR: expected_restore_checkpoint_success (%h) != prfl_restore_checkpoint_success (%h)", 
                expected_restore_checkpoint_success, prfl_restore_checkpoint_success);
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