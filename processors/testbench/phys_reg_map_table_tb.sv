/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_map_table_tb.sv
    Instantiation Hierarchy: system -> core -> phys_reg_map_table
    Description: 
       Testbench for phys_reg_map_table module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_map_table_tb ();

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

    // // reg map reading
    // input arch_reg_tag_t source_arch_reg_tag_0,
    arch_reg_tag_t tb_source_arch_reg_tag_0;
    // output phys_reg_tag_t source_phys_reg_tag_0,
    phys_reg_tag_t prmt_source_phys_reg_tag_0, expected_source_phys_reg_tag_0;
    // input arch_reg_tag_t source_arch_reg_tag_1,
    arch_reg_tag_t tb_source_arch_reg_tag_1;
    // output phys_reg_tag_t source_phys_reg_tag_1,
    phys_reg_tag_t prmt_source_phys_reg_tag_1, expected_source_phys_reg_tag_1;

    // // reg map rename
    // input logic rename_valid,
    logic tb_rename_valid;
    // input arch_reg_tag_t rename_dest_arch_reg_tag,
    arch_reg_tag_t tb_rename_dest_arch_reg_tag;
    // input phys_reg_tag_t rename_dest_phys_reg_tag,
    phys_reg_tag_t tb_rename_dest_phys_reg_tag;

    // // reg map revert
    // input logic revert_valid,
    logic tb_revert_valid;
    // input arch_reg_tag_t revert_dest_arch_reg_tag,
    arch_reg_tag_t tb_revert_dest_arch_reg_tag;
    // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
    phys_reg_tag_t tb_revert_safe_dest_phys_reg_tag;
    // input phys_reg_tag_t revert_speculated_dest_phys_reg_tag,
    //     // can use for assertion but otherwise don't need
    phys_reg_tag_t tb_revert_speculated_dest_phys_reg_tag;

    // // reg map checkpoint save
    // input logic save_checkpoint_valid,
    logic tb_save_checkpoint_valid;
    // output logic save_checkpoint_success,
    logic prmt_save_checkpoint_success, expected_save_checkpoint_success;
    // input ROB_index_t save_checkpoint_ROB_index,    // from ROB, write tag val
    ROB_index_t tb_save_checkpoint_ROB_index;
    // output checkpoint_column_t save_checkpoint_safe_column,
    checkpoint_column_t prmt_save_checkpoint_safe_column, expected_save_checkpoint_safe_column;

    // // reg map checkpoint restore
    // input logic restore_checkpoint_valid,
    logic tb_restore_checkpoint_valid;
    // input logic restore_checkpoint_speculate_failed,
    logic tb_restore_checkpoint_speculate_failed;
    // output logic restore_checkpoint_success,
    logic prmt_restore_checkpoint_success, expected_restore_checkpoint_success;
    // input ROB_index_t restore_checkpoint_ROB_index  // from restore system, check tag val
    ROB_index_t tb_restore_checkpoint_ROB_index;
    // input checkpoint_column_t restore_checkpoint_safe_column,
    checkpoint_column_t tb_restore_checkpoint_safe_column;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

    phys_reg_map_table #(
        // no params
    ) DUT (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // reg map reading
        .source_arch_reg_tag_0(tb_source_arch_reg_tag_0),
        .source_phys_reg_tag_0(prmt_source_phys_reg_tag_0),
        .source_arch_reg_tag_1(tb_source_arch_reg_tag_1),
        .source_phys_reg_tag_1(prmt_source_phys_reg_tag_1),

        // reg map rename
        .rename_valid(tb_rename_valid),
        .rename_dest_arch_reg_tag(tb_rename_dest_arch_reg_tag),
        .rename_dest_phys_reg_tag(tb_rename_dest_phys_reg_tag),

        // reg map revert
        .revert_valid(tb_revert_valid),
        .revert_dest_arch_reg_tag(tb_revert_dest_arch_reg_tag),
        .revert_safe_dest_phys_reg_tag(tb_revert_safe_dest_phys_reg_tag),
        .revert_speculated_dest_phys_reg_tag(tb_revert_speculated_dest_phys_reg_tag),

        // reg map checkpoint save
        .save_checkpoint_valid(tb_save_checkpoint_valid),
        .save_checkpoint_success(prmt_save_checkpoint_success),
        .save_checkpoint_ROB_index(tb_save_checkpoint_ROB_index),       // from ROB, write tag val
        .save_checkpoint_safe_column(prmt_save_checkpoint_safe_column),

        // reg map checkpoint restore
        .restore_checkpoint_valid(tb_restore_checkpoint_valid),
        .restore_checkpoint_speculate_failed(tb_restore_checkpoint_speculate_failed),
        .restore_checkpoint_success(prmt_restore_checkpoint_success),
        .restore_checkpoint_ROB_index(tb_restore_checkpoint_ROB_index),     // from restore system, check tag val
        .restore_checkpoint_safe_column(tb_restore_checkpoint_safe_column)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
        if (expected_source_phys_reg_tag_0 !== prmt_source_phys_reg_tag_0) begin
            $display("\tERROR: expected_source_phys_reg_tag_0 (%h) != prmt_source_phys_reg_tag_0 (%h)", 
                expected_source_phys_reg_tag_0, prmt_source_phys_reg_tag_0);
            num_errors++;
            error = 1'b1;
        end

        if (expected_source_phys_reg_tag_1 !== prmt_source_phys_reg_tag_1) begin
            $display("\tERROR: expected_source_phys_reg_tag_1 (%h) != prmt_source_phys_reg_tag_1 (%h)", 
                expected_source_phys_reg_tag_1, prmt_source_phys_reg_tag_1);
            num_errors++;
            error = 1'b1;
        end

        if (expected_save_checkpoint_success !== prmt_save_checkpoint_success) begin
            $display("\tERROR: expected_save_checkpoint_success (%h) != prmt_save_checkpoint_success (%h)", 
                expected_save_checkpoint_success, prmt_save_checkpoint_success);
            num_errors++;
            error = 1'b1;
        end
        
        if (expected_save_checkpoint_safe_column !== prmt_save_checkpoint_safe_column) begin
            $display("\tERROR: expected_save_checkpoint_safe_column (%h) != prmt_save_checkpoint_safe_column (%h)", 
                expected_save_checkpoint_safe_column, prmt_save_checkpoint_safe_column);
            num_errors++;
            error = 1'b1;
        end

        if (expected_restore_checkpoint_success !== prmt_restore_checkpoint_success) begin
            $display("\tERROR: expected_restore_checkpoint_success (%h) != prmt_restore_checkpoint_success (%h)", 
                expected_restore_checkpoint_success, prmt_restore_checkpoint_success);
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
            // assert reset
        sub_test_case = "assert reset";
        $display("\t- sub_test %s", test_num, sub_test_case);

        // reset
        nRST = 1'b0;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(posedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_success = 1'b0;
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        // inputs
            // deassert reset
        sub_test_case = "deassert reset";
        $display("\t- sub_test %s", test_num, sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(posedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_success = 1'b0;
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // strobe reset mappings:
        test_case = "strobe reset mappings";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // finish:
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