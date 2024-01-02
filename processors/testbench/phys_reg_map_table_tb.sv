/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_map_table_tb.sv
    Instantiation Hierarchy: system -> core -> dispatch_unit -> phys_reg_map_table
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

    // DUT error
	logic DUT_DUT_error, expected_DUT_error;

    // // reg map reading
    // input arch_reg_tag_t source_arch_reg_tag_0,
    arch_reg_tag_t tb_source_arch_reg_tag_0;
    // output phys_reg_tag_t source_phys_reg_tag_0,
    phys_reg_tag_t prmt_source_phys_reg_tag_0, expected_source_phys_reg_tag_0;
    // input arch_reg_tag_t source_arch_reg_tag_1,
    arch_reg_tag_t tb_source_arch_reg_tag_1;
    // output phys_reg_tag_t source_phys_reg_tag_1,
    phys_reg_tag_t prmt_source_phys_reg_tag_1, expected_source_phys_reg_tag_1;
    // input arch_reg_tag_t old_dest_arch_reg_tag,
    phys_reg_tag_t tb_old_dest_arch_reg_tag;
    // output phys_reg_tag_t old_dest_phys_reg_tag,
    phys_reg_tag_t prmt_old_dest_phys_reg_tag, expected_old_dest_phys_reg_tag;

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
    // input ROB_index_t save_checkpoint_ROB_index,    // from ROB, write tag val
    ROB_index_t tb_save_checkpoint_ROB_index;
    // output checkpoint_column_t save_checkpoint_safe_column,
    checkpoint_column_t prmt_save_checkpoint_safe_column, expected_save_checkpoint_safe_column;

    // // reg map checkpoint restore
    // input logic restore_checkpoint_valid,
    logic tb_restore_checkpoint_valid;
    // input logic restore_checkpoint_speculate_failed,
    logic tb_restore_checkpoint_speculate_failed;
    // input ROB_index_t restore_checkpoint_ROB_index  // from restore system, check tag val
    ROB_index_t tb_restore_checkpoint_ROB_index;
    // input checkpoint_column_t restore_checkpoint_safe_column,
    checkpoint_column_t tb_restore_checkpoint_safe_column;
    // output logic restore_checkpoint_success,
    logic prmt_restore_checkpoint_success, expected_restore_checkpoint_success;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

    phys_reg_map_table #(
        // no params
    ) DUT (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // DUT error
        .DUT_error(DUT_DUT_error),

        // reg map reading
        .source_arch_reg_tag_0(tb_source_arch_reg_tag_0),
        .source_phys_reg_tag_0(prmt_source_phys_reg_tag_0),
        .source_arch_reg_tag_1(tb_source_arch_reg_tag_1),
        .source_phys_reg_tag_1(prmt_source_phys_reg_tag_1),
        .old_dest_arch_reg_tag(tb_old_dest_arch_reg_tag),
        .old_dest_phys_reg_tag(prmt_old_dest_phys_reg_tag),

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
        .save_checkpoint_ROB_index(tb_save_checkpoint_ROB_index),       // from ROB, write tag val
        .save_checkpoint_safe_column(prmt_save_checkpoint_safe_column),

        // reg map checkpoint restore
        .restore_checkpoint_valid(tb_restore_checkpoint_valid),
        .restore_checkpoint_speculate_failed(tb_restore_checkpoint_speculate_failed),
        .restore_checkpoint_ROB_index(tb_restore_checkpoint_ROB_index),     // from restore system, check tag val
        .restore_checkpoint_safe_column(tb_restore_checkpoint_safe_column),
        .restore_checkpoint_success(prmt_restore_checkpoint_success)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
        if (expected_DUT_error !== DUT_DUT_error) begin
            $display("\tERROR: expected_DUT_error (%h) != DUT_DUT_error (%h)", 
                expected_DUT_error, DUT_DUT_error);
            num_errors++;
            error = 1'b1;
        end

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

        if (expected_old_dest_phys_reg_tag !== prmt_old_dest_phys_reg_tag) begin
            $display("\tERROR: expected_old_dest_phys_reg_tag (%h) != prmt_old_dest_phys_reg_tag (%h)",
                expected_old_dest_phys_reg_tag, prmt_old_dest_phys_reg_tag);
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
        sub_test_case = "assert reset";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b0;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
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

        // DUT error (SET ONCE HERE)
        expected_DUT_error = 1'b0;
        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        // inputs
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
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
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // strobe reset mappings:
        test_case = "strobe reset mappings";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // test each mapping 0 to NUM_ARCH_REGS
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("check registers %h, %h", i, i+1);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i+1);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i+1);
            // reg map rename
            tb_rename_valid = 1'b0;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
            tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
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

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i);
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'((i+1) % NUM_ARCH_REGS);
            expected_old_dest_phys_reg_tag = phys_reg_tag_t'((i+1) % NUM_ARCH_REGS);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // save checkpoint w/ reset values:
        test_case = "save checkpoint w/ reset values";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        @(posedge CLK);

        // inputs
        sub_test_case = $sformatf("save checkpoint");
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'('ha);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // strobe write-read:
        test_case = "strobe write-read";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // test each mapping 0 to NUM_ARCH_REGS-1
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("write reg %h, check registers %h, %h", i, i-1 >= 0 ? i-1 : 0, i);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i-1 >= 0 ? i-1 : 0);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i);
            // reg map rename
            tb_rename_valid = 1'b1;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(i);
            tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(i*2);
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

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i-1 >= 0 ? (i-1) * 2 : 0);
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'(i);
            expected_old_dest_phys_reg_tag = phys_reg_tag_t'(i);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // restore checkpoint w/ reset values:
        test_case = "restore checkpoint w/ reset values";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        @(posedge CLK);

        // inputs
        sub_test_case = $sformatf("restore checkpoint");
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b1;
        tb_restore_checkpoint_ROB_index = ROB_index_t'('ha);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b1;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // strobe restored reset mappings:
        test_case = "strobe restored reset mappings";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // test each mapping 0 to NUM_ARCH_REGS
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("check registers %h, %h", i, i+1);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i+1);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i);
            // reg map rename
            tb_rename_valid = 1'b0;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
            tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
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

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i);
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'((i+1) % NUM_ARCH_REGS);
            expected_old_dest_phys_reg_tag = phys_reg_tag_t'(i);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // failed restores
        test_case = "failed restores";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        @(posedge CLK);

        // inputs
        sub_test_case = $sformatf("invalid column failed restore");
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b1;
        tb_restore_checkpoint_ROB_index = ROB_index_t'('h9);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(2);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        @(posedge CLK);

        // inputs
        sub_test_case = $sformatf("bad tag failed restore");
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b1;
        tb_restore_checkpoint_ROB_index = ROB_index_t'('h5);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // strobe revert:
        test_case = "strobe revert";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // test each mapping 0 to NUM_ARCH_REGS
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("write reg %h, check registers %h, %h", i, i-1 >= 0 ? i-1 : 0, i);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i-1 >= 0 ? i-1 : 0);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i);
            // reg map rename
            tb_rename_valid = 1'b0;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
            tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
            // reg map revert
            tb_revert_valid = i-1 > 0 && i % 10 == 0 ? 1 : 0;
            tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(i);
            tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(i % 10 == 0 ? 'h2b : i);
            tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(i);
            // reg map checkpoint save
            tb_save_checkpoint_valid = 1'b0;
            tb_save_checkpoint_ROB_index = ROB_index_t'(0);
            // reg map checkpoint restore
            tb_restore_checkpoint_valid = 1'b0;
            tb_restore_checkpoint_speculate_failed = 1'b0;
            tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
            tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i-1 <= 0 ? 0 : ((i-1) % 10 == 0 ? 'h2b : i-1));
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'(i);
            expected_old_dest_phys_reg_tag = phys_reg_tag_t'(i);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // exercise saves and restores:
        test_case = "exercise saves and restores";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // save 1, write all 1's, save 2, write all 2's, save 3, write all 3's, 
            // kill save 1, restore save 2, fail restore save 3, fail kill save 3

        @(posedge CLK);

        // inputs
        sub_test_case = "save 1";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(1);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(0);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(0);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        // write all mappings to 1
            // previous mappings had i mod 10 == 0 ? 'h2b : i
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("write reg %h, check registers %h, %h", i, i-1 >= 0 ? i-1 : 0, i);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i-1 >= 0 ? i-1 : 0);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i);
            // reg map rename
            tb_rename_valid = 1'b1;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(i);
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

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i-1 >= 0 ? 1 : 0);
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'(i == 0 ? 0 : i % 10 == 0 ? 'h2b : i);
            expected_old_dest_phys_reg_tag = phys_reg_tag_t'(i == 0 ? 0 : i % 10 == 0 ? 'h2b : i);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        @(posedge CLK);

        // inputs
        sub_test_case = "save 2";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(2);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        // write all mappings to 2
            // previous mappings all 1's
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("write reg %h, check registers %h, %h", i, i-1 >= 0 ? i-1 : 0, i);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i-1 >= 0 ? i-1 : 0);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i-1 >= 0 ? i-1 : 0);
            // reg map rename
            tb_rename_valid = 1'b1;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(i);
            tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(2);
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

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i-1 >= 0 ? 2 : 1);
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
            expected_old_dest_phys_reg_tag = phys_reg_tag_t'(i-1 >= 0 ? 2 : 1);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(2);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        @(posedge CLK);

        // inputs
        sub_test_case = "save 3";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(3);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(2);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(2);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(2);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(2);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        // write all mappings to 3
            // previous mappings all 2's
        for (int i = 0; i < NUM_ARCH_REGS; i++) begin

            @(posedge CLK);

            // inputs
            sub_test_case = $sformatf("write reg %h, check registers %h, %h", i, i-1 >= 0 ? i-1 : 0, i);
            $display("\t- sub_test: %s", sub_test_case);

            // reset
            nRST = 1'b1;
            // reg map reading
            tb_source_arch_reg_tag_0 = arch_reg_tag_t'(i-1 >= 0 ? i-1 : 0);
            tb_source_arch_reg_tag_1 = arch_reg_tag_t'(i);
            tb_old_dest_arch_reg_tag = arch_reg_tag_t'(i);
            // reg map rename
            tb_rename_valid = 1'b1;
            tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(i);
            tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(3);
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

            @(negedge CLK);

            // outputs:

            // reg map reading
            expected_source_phys_reg_tag_0 = phys_reg_tag_t'(i-1 >= 0 ? 3 : 2);
            expected_source_phys_reg_tag_1 = phys_reg_tag_t'(2);
            expected_old_dest_phys_reg_tag = arch_reg_tag_t'(2);
            // reg map checkpoint save
            expected_save_checkpoint_safe_column = checkpoint_column_t'(3);
            // reg map checkpoint restore
            expected_restore_checkpoint_success = 1'b0;

            check_outputs();
        end

        @(posedge CLK);

        // inputs
        sub_test_case = "kill save 1";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(1);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(3);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(3);
        expected_old_dest_phys_reg_tag = arch_reg_tag_t'(3);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(3);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b1;

        check_outputs();

        @(posedge CLK);

        // inputs
        sub_test_case = "restore save 2";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b1;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(2);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(1);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(3);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(3);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(3);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(3);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b1;

        check_outputs();

        @(posedge CLK);

        // inputs
        sub_test_case = "fail restore save 3";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b1;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(3);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(2);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = arch_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        @(posedge CLK);

        // inputs
        sub_test_case = "fail kill save 3";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(3);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(2);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // save wrap around:
        test_case = "save wrap around";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // save column 1, save column 2, save column 3, save column 0, save column 1,
            // fail restore old save @ column 1

         @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "save @ column 1";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(15);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

         @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "save @ column 2";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(16);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(2);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

         @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "save @ column 3";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(17);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(3);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "save @ column 0";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(18);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(0);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "save @ column 1";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b1;
        tb_save_checkpoint_ROB_index = ROB_index_t'(19);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b0;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(1);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "fail restore old save @ column 1";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b1;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(15);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(1);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(2);
        // reg map checkpoint restore
        expected_restore_checkpoint_success = 1'b0;

        check_outputs();

        @(posedge CLK);

        // inputs
            // previous mapping all 1's
        sub_test_case = "fail invalidate old save @ column 1";
        $display("\t- sub_test: %s", sub_test_case);

        // reset
        nRST = 1'b1;
        // reg map reading
        tb_source_arch_reg_tag_0 = arch_reg_tag_t'(0);
        tb_source_arch_reg_tag_1 = arch_reg_tag_t'(0);
        tb_old_dest_arch_reg_tag = arch_reg_tag_t'(0);
        // reg map rename
        tb_rename_valid = 1'b0;
        tb_rename_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_rename_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map revert
        tb_revert_valid = 1'b0;
        tb_revert_dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_revert_safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_revert_speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
        // reg map checkpoint save
        tb_save_checkpoint_valid = 1'b0;
        tb_save_checkpoint_ROB_index = ROB_index_t'(0);
        // reg map checkpoint restore
        tb_restore_checkpoint_valid = 1'b1;
        tb_restore_checkpoint_speculate_failed = 1'b0;
        tb_restore_checkpoint_ROB_index = ROB_index_t'(15);
        tb_restore_checkpoint_safe_column = checkpoint_column_t'(1);

        @(negedge CLK);

        // outputs:

        // reg map reading
        expected_source_phys_reg_tag_0 = phys_reg_tag_t'(1);
        expected_source_phys_reg_tag_1 = phys_reg_tag_t'(1);
        expected_old_dest_phys_reg_tag = phys_reg_tag_t'(1);
        // reg map checkpoint save
        expected_save_checkpoint_safe_column = checkpoint_column_t'(2);
        // reg map checkpoint restore
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