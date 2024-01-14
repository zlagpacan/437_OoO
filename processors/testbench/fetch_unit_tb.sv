/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: fetch_unit_tb.sv
    Instantiation Hierarchy: system -> core -> fetch_unit
    Description: 
       Testbench for fetch_unit module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module fetch_unit_tb ();

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT signals:

    // parameters
    parameter PERIOD = 10;

    parameter PC_RESET_VAL = 16'h0;
    parameter BTB_FRAMES = 256;
    parameter RAS_DEPTH = 8;
    parameter LOG_BTB_FRAMES = $clog2(BTB_FRAMES);
    parameter LOG_RAS_DEPTH = $clog2(RAS_DEPTH);

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
    // DUT input signals:

    // BTB/DIRP inputs from pipeline
    logic tb_from_pipeline_BTB_DIRP_update;
    logic [LOG_BTB_FRAMES-1:0] tb_from_pipeline_BTB_DIRP_index;
    pc_t tb_from_pipeline_BTB_target;
    logic tb_from_pipeline_DIRP_taken;

    // resolved target from pipepline
    logic tb_from_pipeline_take_resolved;
    pc_t tb_from_pipeline_resolved_PC;

    // I$
    logic tb_icache_hit;
    word_t tb_icache_load;

    // core controller
    logic tb_core_control_stall_fetch_unit;
    logic tb_core_control_halt;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT output signals:

    // DUT error
    logic DUT_DUT_error, expected_DUT_error;

    // I$
    logic fu_icache_REN, expected_icache_REN;
    word_t fu_icache_addr, expected_icache_addr;
    logic fu_icache_halt, expected_icache_halt;

    // to pipeline
    word_t fu_to_pipeline_instr, expected_to_pipeline_instr;
    logic fu_to_pipeline_ivalid, expected_to_pipeline_ivalid;
    pc_t fu_to_pipeline_PC, expected_to_pipeline_PC;
    pc_t fu_to_pipeline_nPC, expected_to_pipeline_nPC;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

    fetch_unit #(

    ) DUT (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // DUT error
        .DUT_error(DUT_DUT_error),

        // inputs
        .from_pipeline_BTB_DIRP_update(tb_from_pipeline_BTB_DIRP_update),
        .from_pipeline_BTB_DIRP_index(tb_from_pipeline_BTB_DIRP_index),
        .from_pipeline_BTB_target(tb_from_pipeline_BTB_target),
        .from_pipeline_DIRP_taken(tb_from_pipeline_DIRP_taken),
        
        .from_pipeline_take_resolved(tb_from_pipeline_take_resolved),
        .from_pipeline_resolved_PC(tb_from_pipeline_resolved_PC),
        
        .icache_hit(tb_icache_hit),
        .icache_load(tb_icache_load),
        
        .core_control_stall_fetch_unit(tb_core_control_stall_fetch_unit),
        .core_control_halt(tb_core_control_halt),

        // outputs
        .icache_REN(fu_icache_REN),
        .icache_addr(fu_icache_addr),
        .icache_halt(fu_icache_halt),

        .to_pipeline_instr(fu_to_pipeline_instr),
        .to_pipeline_ivalid(fu_to_pipeline_ivalid),
        .to_pipeline_PC(fu_to_pipeline_PC),
        .to_pipeline_nPC(fu_to_pipeline_nPC)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
        if (expected_DUT_error !== DUT_DUT_error) begin
            $display("\tERROR: expected_DUT_error (%h) != DUT_DUT_error (%h)", expected_DUT_error, DUT_DUT_error);
            num_errors++;
            error = 1'b1;
        end

        if (expected_icache_REN !== fu_icache_REN) begin
            $display("\tERROR: expected_icache_REN (%h) != fu_icache_REN (%h)", expected_icache_REN, fu_icache_REN);
            num_errors++;
            error = 1'b1;
        end

        if (expected_icache_addr !== fu_icache_addr) begin
            $display("\tERROR: expected_icache_addr (%h) != fu_icache_addr (%h)", expected_icache_addr, fu_icache_addr);
            num_errors++;
            error = 1'b1;
        end

        if (expected_icache_halt !== fu_icache_halt) begin
            $display("\tERROR: expected_icache_halt (%h) != fu_icache_halt (%h)", expected_icache_halt, fu_icache_halt);
            num_errors++;
            error = 1'b1;
        end
        
        if (expected_to_pipeline_instr !== fu_to_pipeline_instr) begin
            $display("\tERROR: expected_to_pipeline_instr (%h) != fu_to_pipeline_instr (%h)", expected_to_pipeline_instr, fu_to_pipeline_instr);
            num_errors++;
            error = 1'b1;
        end

        if (expected_to_pipeline_ivalid !== fu_to_pipeline_ivalid) begin
            $display("\tERROR: expected_to_pipeline_ivalid (%h) != fu_to_pipeline_ivalid (%h)", expected_to_pipeline_ivalid, fu_to_pipeline_ivalid);
            num_errors++;
            error = 1'b1;
        end

        if (expected_to_pipeline_PC !== fu_to_pipeline_PC) begin
            $display("\tERROR: expected_to_pipeline_PC (%h) != fu_to_pipeline_PC (%h)", expected_to_pipeline_PC, fu_to_pipeline_PC);
            num_errors++;
            error = 1'b1;
        end

        if (expected_to_pipeline_nPC !== fu_to_pipeline_nPC) begin
            $display("\tERROR: expected_to_pipeline_nPC (%h) != fu_to_pipeline_nPC (%h)", expected_to_pipeline_nPC, fu_to_pipeline_nPC);
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
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b0;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'h0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(posedge CLK);

        // outputs:

        // DUT error (SET ONCE HERE)
        expected_DUT_error = 1'b0;
        // I$
        expected_icache_REN = 1'b0;
        expected_icache_addr = 32'h0;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h0;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0;
        expected_to_pipeline_nPC = 14'h0;

        check_outputs();

        // inputs
            // deassert reset
        sub_test_case = "deassert reset";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'h0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(posedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b0;
        expected_icache_addr = 32'h0;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h0;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0;
        expected_to_pipeline_nPC = 14'h0;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // seq PC, all ihit's:
        test_case = "seq PC, all ihit's";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // hit, hit, hit

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00111111;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00111111;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0;
        expected_to_pipeline_nPC = 14'h1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00222222;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h4;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00222222;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h1;
        expected_to_pipeline_nPC = 14'h2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00333333;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h8;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00333333;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h2;
        expected_to_pipeline_nPC = 14'h3;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // seq PC, some ihit's, some misses:
        test_case = "seq PC, some ihit's, some misses";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // miss, miss, hit, miss, hit

        @(posedge CLK);

        // inputs:
            // miss
        sub_test_case = "miss";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hc;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h3;
        expected_to_pipeline_nPC = 14'h3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss
        sub_test_case = "miss";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hc;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h3;
        expected_to_pipeline_nPC = 14'h3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00444444;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hc;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00444444;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h3;
        expected_to_pipeline_nPC = 14'h4;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss
        sub_test_case = "miss";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h10;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h4;
        expected_to_pipeline_nPC = 14'h4;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00555555;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h10;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00555555;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h4;
        expected_to_pipeline_nPC = 14'h5;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // seq PC, all ihit's, w/ j/jal/jr:
        test_case = "seq PC, all ihit's, w/ j/jal/jr";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // hit (j), hit (jal), hit, hit (jr), hit, hit (jal), hit (jal), hit (jr), hit, hit (jr)

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + (14'ha00);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h14;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + (14'ha00);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h5;
        expected_to_pipeline_nPC = 14'ha00;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (jal)
        sub_test_case = "hit (jal)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(JAL) << 26) + (14'hb00);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'ha00 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(JAL) << 26) + (14'hb00);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'ha00;
        expected_to_pipeline_nPC = 14'hb00;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00abcdef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hb00 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00abcdef;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'hb00;
        expected_to_pipeline_nPC = 14'hb01;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (jr)
        sub_test_case = "hit (jr)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(RTYPE) << 26) + funct_t'(JR);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hb01 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(RTYPE) << 26) + funct_t'(JR);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'hb01;
        expected_to_pipeline_nPC = 14'ha01;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00fedcba;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'ha01 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00fedcba;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'ha01;
        expected_to_pipeline_nPC = 14'ha02;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (jal)
        sub_test_case = "hit (jal)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(JAL) << 26) + 14'hc00;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'ha02 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(JAL) << 26) + 14'hc00;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'ha02;
        expected_to_pipeline_nPC = 14'hc00;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (jal)
        sub_test_case = "hit (jal)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(JAL) << 26) + 14'hd00;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hc00 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(JAL) << 26) + 14'hd00;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'hc00;
        expected_to_pipeline_nPC = 14'hd00;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (jr)
        sub_test_case = "hit (jr)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(RTYPE) << 26) + funct_t'(JR);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hd00 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(RTYPE) << 26) + funct_t'(JR);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'hd00;
        expected_to_pipeline_nPC = 14'hc01;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00bababa;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hc01 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00bababa;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'hc01;
        expected_to_pipeline_nPC = 14'hc02;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (jr)
        sub_test_case = "hit (jr)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(RTYPE) << 26) + funct_t'(JR);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'hc02 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(RTYPE) << 26) + funct_t'(JR);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'hc02;
        expected_to_pipeline_nPC = 14'ha03;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // seq PC, all ihit's, w/ beq/bne/j, correct NT:
        test_case = "seq PC, all ihit's, w/ beq/bne/j, correct NT";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // hit (j), hit (beq, NT (correct)), hit, hit (bne, NT (correct))

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + (14'h0a0);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'ha03 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + (14'h0a0);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'ha03;
        expected_to_pipeline_nPC = 14'h0a0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (beq, NT (correct))
        sub_test_case = "hit (beq, NT (correct))";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BEQ) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0a0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BEQ) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0a0;
        expected_to_pipeline_nPC = 14'h0a1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00a1b2c3;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0a1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00a1b2c3;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0a1;
        expected_to_pipeline_nPC = 14'h0a2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (beq, NT (correct))
        sub_test_case = "hit (beq, NT (correct))";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + (16'h01f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0a2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + (16'h01f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0a2;
        expected_to_pipeline_nPC = 14'h0a3;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // exercise beq BTB
        test_case = "exercise beq BTB";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // hit (j), hit (beq, NT), hit, hit, hit + resolved PC + BTB update (T), hit, 
        // hit (j), hit (beq, T), hit,
        // hit (j), hit (beq, T), hit + BTB update (NT),
        // hit (j), hit (beq, T), hit + BTB update (NT),
        // hit (j), hit (beq, NT), hit

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + (16'h0b0);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0a3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + (16'h0b0);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0a3;
        expected_to_pipeline_nPC = 14'h0b0;

        check_outputs();
        
        @(posedge CLK);

        // inputs:
            // hit (beq, NT)
        sub_test_case = "hit (beq, NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BEQ) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BEQ) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b0;
        expected_to_pipeline_nPC = 14'h0b1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00121212;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00121212;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b1;
        expected_to_pipeline_nPC = 14'h0b2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00232323;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00232323;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b2;
        expected_to_pipeline_nPC = 14'h0b3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + resolved PC + BTB update (T)
        sub_test_case = "hit + resolved PC + BTB update (T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'hb0;
        tb_from_pipeline_BTB_target = 14'h0c0;
        tb_from_pipeline_DIRP_taken = 1'b1;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b1;
        tb_from_pipeline_resolved_PC = 14'h0c0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00343434;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00343434;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0b3;
        expected_to_pipeline_nPC = 14'h0c0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00454545;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00454545;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c0;
        expected_to_pipeline_nPC = 14'h0c1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + (16'h0b0);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + (16'h0b0);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c1;
        expected_to_pipeline_nPC = 14'h0b0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (beq, T)
        sub_test_case = "hit (beq, T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BEQ) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BEQ) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b0;
        expected_to_pipeline_nPC = 14'h0c0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00676767;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00676767;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c0;
        expected_to_pipeline_nPC = 14'h0c1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0b0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0b0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c1;
        expected_to_pipeline_nPC = 14'h0b0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (beq, T)
        sub_test_case = "hit (beq, T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BEQ) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BEQ) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b0;
        expected_to_pipeline_nPC = 14'h0c0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + BTB update (NT)
        sub_test_case = "hit + BTB update (NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'hb0;
        tb_from_pipeline_BTB_target = 14'h0c0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00676767;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00676767;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c0;
        expected_to_pipeline_nPC = 14'h0c1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0b0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0b0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c1;
        expected_to_pipeline_nPC = 14'h0b0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (beq, T)
        sub_test_case = "hit (beq, T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BEQ) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BEQ) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b0;
        expected_to_pipeline_nPC = 14'h0c0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + BTB update (NT)
        sub_test_case = "hit + BTB update (NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'hb0;
        tb_from_pipeline_BTB_target = 14'h0c0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00676767;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00676767;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c0;
        expected_to_pipeline_nPC = 14'h0c1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0b0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0c1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0b0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0c1;
        expected_to_pipeline_nPC = 14'h0b0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (beq, NT)
        sub_test_case = "hit (beq, NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BEQ) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BEQ) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b0;
        expected_to_pipeline_nPC = 14'h0b1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00787878;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00787878;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b1;
        expected_to_pipeline_nPC = 14'h0b2;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // exercise bne BTB
        test_case = "exercise bne BTB";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // hit (j), hit (bne, NT), hit, hit, hit + resolved PC + BTB update (T), hit, 
        // hit (j), hit (bne, T), hit,
        // hit (j), hit (bne, T), hit + BTB update (NT),
        // hit (j), hit (bne, T), hit + BTB update (NT),
        // hit (j), hit (bne, NT), hit

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + (16'h0e0);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0b2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + (16'h0e0);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0b2;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();
        
        @(posedge CLK);

        // inputs:
            // hit (bne, NT)
        sub_test_case = "hit (bne, NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0e1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00121212;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00121212;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e1;
        expected_to_pipeline_nPC = 14'h0e2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00232323;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00232323;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e2;
        expected_to_pipeline_nPC = 14'h0e3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + resolved PC + BTB update (T)
        sub_test_case = "hit + resolved PC + BTB update (T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'he0;
        tb_from_pipeline_BTB_target = 14'h0f0;
        tb_from_pipeline_DIRP_taken = 1'b1;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b1;
        tb_from_pipeline_resolved_PC = 14'h0f0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00343434;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00343434;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e3;
        expected_to_pipeline_nPC = 14'h0f0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00454545;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00454545;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f0;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + (16'h0e0);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + (16'h0e0);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (bne, T)
        sub_test_case = "hit (bne, T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0f0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00676767;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00676767;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f0;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0e0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0e0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (bne, T)
        sub_test_case = "hit (bne, T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0f0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + BTB update (NT)
        sub_test_case = "hit + BTB update (NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'he0;
        tb_from_pipeline_BTB_target = 14'h0f0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00676767;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00676767;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f0;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0e0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0e0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (bne, T)
        sub_test_case = "hit (bne, T)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0f0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + BTB update (NT)
        sub_test_case = "hit + BTB update (NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'he0;
        tb_from_pipeline_BTB_target = 14'h0f0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00676767;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00676767;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f0;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j)
        sub_test_case = "hit (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0e0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0e0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (bne, NT)
        sub_test_case = "hit (bne, NT)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + (16'h00f);
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + (16'h00f);
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0e1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00787878;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00787878;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e1;
        expected_to_pipeline_nPC = 14'h0e2;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // exercise core control w/ beq/bne/j
        test_case = "exercise core control w/ beq/bne/j";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // miss, miss + core control stall, hit + core control stall, hit + BTB update
        // miss (j), miss (j) + core control stall, hit (j) + core control stall, hit (j) + BTB update
        // miss (bne), miss (bne) + core control stall, hit (bne) + core control stall, hit (bne)
        // hit + core control halt, miss + core control halt
        // unhalt before, unhalt after

        // reg instr

        @(posedge CLK);

        // inputs:
            // miss
        sub_test_case = "miss";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e2;
        expected_to_pipeline_nPC = 14'h0e2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss + core control stall
        sub_test_case = "miss + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e2;
        expected_to_pipeline_nPC = 14'h0e2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + core control stall
        sub_test_case = "hit + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e2;
        expected_to_pipeline_nPC = 14'h0e2;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit + BTB update
        sub_test_case = "hit + BTB update";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'he0;
        tb_from_pipeline_BTB_target = 14'h0f0;
        tb_from_pipeline_DIRP_taken = 1'b1;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e2 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e2;
        expected_to_pipeline_nPC = 14'h0e3;

        check_outputs();

        // j instr

        @(posedge CLK);

        // inputs:
            // miss (j)
        sub_test_case = "miss (j)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e3;
        expected_to_pipeline_nPC = 14'h0e3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss (j) + core control stall
        sub_test_case = "miss (j) + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e3;
        expected_to_pipeline_nPC = 14'h0e3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j) + core control stall
        sub_test_case = "hit (j) + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0e4;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0e4;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e3;
        expected_to_pipeline_nPC = 14'h0e3;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (j) + BTB update
        sub_test_case = "hit (j) + BTB update";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b1;
        tb_from_pipeline_BTB_DIRP_index = 8'he0;
        tb_from_pipeline_BTB_target = 14'h0f0;
        tb_from_pipeline_DIRP_taken = 1'b1;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(J) << 26) + 16'h0e0;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e3 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(J) << 26) + 16'h0e0;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e3;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        // bne instr

        @(posedge CLK);

        // inputs:
            // miss (bne)
        sub_test_case = "miss (bne)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss (bne) + core control stall
        sub_test_case = "miss (bne) + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (bne) + core control stall
        sub_test_case = "hit (bne) + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + 16'h00f;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + 16'h00f;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0e0;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit (bne)
        sub_test_case = "hit (bne)";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = (opcode_t'(BNE) << 26) + 16'h00f;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0e0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = (opcode_t'(BNE) << 26) + 16'h00f;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h0e0;
        expected_to_pipeline_nPC = 14'h0f0;

        check_outputs();

        // halts

        @(posedge CLK);

        // inputs:
            // hit + core control halt
        sub_test_case = "hit + core control halt";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b1;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f0 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0f0;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss + core control halt
        sub_test_case = "miss + core control halt";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b1;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b0;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b1;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();
        
        @(posedge CLK);

        // inputs:
            // unhalt before
        sub_test_case = "unhalt before";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b0;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b1;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // unhalt after
        sub_test_case = "unhalt after";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h0f1;

        check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // exercise core control w/ resolve
        test_case = "exercise core control w/ resolve";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

        // miss + resolve, miss, hit, 
        // miss + resolve + core control stall, miss + core control stall, miss, hit

        @(posedge CLK);

        // inputs:
            // miss + resolve
        sub_test_case = "miss + resolve";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b1;
        tb_from_pipeline_resolved_PC = 14'h040;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h0f1 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h0f1;
        expected_to_pipeline_nPC = 14'h040;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss
        sub_test_case = "miss";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h040 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h040;
        expected_to_pipeline_nPC = 14'h040;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h040 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h040;
        expected_to_pipeline_nPC = 14'h041;

        check_outputs();

        // w/ core control stall

        @(posedge CLK);

        // inputs:
            // miss + resolve + core control stall
        sub_test_case = "miss + resolve + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b1;
        tb_from_pipeline_resolved_PC = 14'h050;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h041 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h041;
        expected_to_pipeline_nPC = 14'h050;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // miss + core control stall
        sub_test_case = "miss + core control stall";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b0;
        tb_icache_load = 32'hdeadbeef;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b1;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h050 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'hdeadbeef;
        expected_to_pipeline_ivalid = 1'b0;
        expected_to_pipeline_PC = 14'h050;
        expected_to_pipeline_nPC = 14'h050;

        check_outputs();

        @(posedge CLK);

        // inputs:
            // hit
        sub_test_case = "hit";
        $display("\t- sub_test:%s", sub_test_case);

        // reset
        nRST = 1'b1;
        // BTB/DIRP inputs from pipeline
        tb_from_pipeline_BTB_DIRP_update = 1'b0;
        tb_from_pipeline_BTB_DIRP_index = 8'h0;
        tb_from_pipeline_BTB_target = 14'h0;
        tb_from_pipeline_DIRP_taken = 1'b0;
        // resolved target from pipepline
        tb_from_pipeline_take_resolved = 1'b0;
        tb_from_pipeline_resolved_PC = 14'h0;
        // I$
        tb_icache_hit = 1'b1;
        tb_icache_load = 32'h00123456;
        // core controller
        tb_core_control_stall_fetch_unit = 1'b0;
        tb_core_control_halt = 1'b0;

        @(negedge CLK);

        // outputs:

        // I$
        expected_icache_REN = 1'b1;
        expected_icache_addr = 32'h050 << 2;
        expected_icache_halt = 1'b0;
        // to pipeline
        expected_to_pipeline_instr = 32'h00123456;
        expected_to_pipeline_ivalid = 1'b1;
        expected_to_pipeline_PC = 14'h050;
        expected_to_pipeline_nPC = 14'h051;

        check_outputs();

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