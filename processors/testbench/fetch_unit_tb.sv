/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: fetch_unit_tb.sv
    Instantiation Hierarchy: system -> core -> fetch_unit
    Description: 
       Testbench for fetch_unit module. 
*/

`timescale 1ns/100ps

`include "instr_types.vh"
import instr_types_pkg::*;

module fetch_unit_tb ();

    // parameters
    parameter PERIOD = 10;

    // TB signals:
    logic CLK = 1'b1, nRST;
    string test_case;
    int test_num = 0;
    int num_errors = 0;
    logic error;

    // clock gen
    always begin CLK = ~CLK; #(PERIOD/2); end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT input signals:

    // BTB/DIRP inputs from pipeline
    logic tb_pipeline_BTB_DIRP_update;
    logic [LOG_BTB_SETS-1:0] tb_pipeline_BTB_DIRP_index;
    pc_t tb_pipeline_BTB_target;
    logic tb_pipeline_DIRP_taken;

    // resolved target from pipepline
    logic tb_pipeline_take_resolved;
    pc_t tb_pipeline_resolved_PC;

    // I$
    logic tb_icache_hit;
    word_t tb_icache_load;

    // core controller
    logic tb_pipeline_stall_fetch_unit;
    logic tb_pipeline_halt;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT output signals:

    // I$
    logic fu_icache_REN, expected_icache_REN;
    word_t fu_icache_addr, expected_icache_addr;
    logic fu_icache_halt, expected_icache_halt;

    // to pipeline
    word_t fu_pipeline_instr, expected_pipeline_instr;
    logic fu_pipeline_ivalid, expected_pipeline_ivalid;
    pc_t fu_pipeline_PC, expected_pipeline_PC;
    pc_t fu_pipeline_nPC, expected_pipeline_nPC;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

    fetch_unit #(
        .PC_RESET_VAL(16'h0),
        .BTB_FRAMES(256),
        .RAS_DEPTH(8)
    ) DUT (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // inputs
        .pipeline_BTB_DIRP_update(tb_pipeline_BTB_DIRP_update),
        .pipeline_BTB_DIRP_index(tb_pipeline_BTB_DIRP_index),
        .pipeline_BTB_target(tb_pipeline_BTB_target),
        .pipeline_DIRP_taken(tb_pipeline_DIRP_taken),
        
        .pipeline_take_resolved(tb_pipeline_take_resolved),
        .pipeline_resolved_PC(tb_pipeline_resolved_PC),
        
        .icache_hit(tb_icache_hit),
        .icache_load(tb_icache_load),
        
        .pipeline_stall_fetch_unit(tb_pipeline_stall_fetch_unit),
        .pipeline_halt(tb_pipeline_halt),

        // outputs
        .icache_REN(fu_icache_REN),
        .icache_addr(fu_icache_addr),
        .icache_halt(fu_icache_halt),

        .pipeline_instr(fu_pipeline_instr),
        .pipeline_ivalid(fu_pipeline_ivalid),
        .pipeline_PC(fu_pipeline_PC),
        .pipeline_nPC(fu_pipeline_nPC)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // tasks:

    task check_outputs();
    begin
        int init_num_errors = num_errors;

        if (expected_icache_REN != fu_icache_REN) begin
            $display("ERROR: expected_icache_REN (%d) != fu_icache_REN (%d)", expected_icache_REN, fu_icache_REN);
            num_errors++;
            error = 1'b1;
        end

        if (expected_icache_addr != fu_icache_addr) begin
            $display("ERROR: expected_icache_addr (%d) != fu_icache_addr (%d)", expected_icache_addr, fu_icache_addr);
            num_errors++;
            error = 1'b1;
        end

        if (expected_icache_halt != fu_icache_halt) begin
            $display("ERROR: expected_icache_halt (%d) != fu_icache_halt (%d)", expected_icache_halt, fu_icache_halt);
            num_errors++;
            error = 1'b1;
        end
        
        if (expected_pipeline_instr != fu_pipeline_instr) begin
            $display("ERROR: expected_pipeline_instr (%d) != fu_pipeline_instr (%d)", expected_pipeline_instr, fu_pipeline_instr);
            num_errors++;
            error = 1'b1;
        end

        if (expected_pipeline_ivalid != fu_pipeline_ivalid) begin
            $display("ERROR: expected_pipeline_ivalid (%d) != fu_pipeline_ivalid (%d)", expected_pipeline_ivalid, fu_pipeline_ivalid);
            num_errors++;
            error = 1'b1;
        end

        if (expected_pipeline_PC != fu_pipeline_PC) begin
            $display("ERROR: expected_pipeline_PC (%d) != fu_pipeline_PC (%d)", expected_pipeline_PC, fu_pipeline_PC);
            num_errors++;
            error = 1'b1;
        end

        if (expected_pipeline_nPC != fu_pipeline_nPC) begin
            $display("ERROR: expected_pipeline_nPC (%d) != fu_pipeline_nPC (%d)", expected_pipeline_nPC, fu_pipeline_nPC);
            num_errors++;
            error = 1'b1;
        end

        #(PERIOD / 10);
        error = 1'b0;
    end
    endtask

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // initial:

    initial begin

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // reset:
        test_case = "reset";
        $display("test %d: %s", test_num, test_case);
        test_num++;

        // inputs:

        // reset
        nRST = 1'b0;
        // BTB/DIRP inputs from pipeline
        tb_pipeline_BTB_DIRP_update = 1'b0;
        tb_pipeline_BTB_DIRP_index = 8'h0;
        tb_pipeline_BTB_target = 14'h0;
        tb_pipeline_DIRP_taken = ;
        // resolved target from pipepline
        tb_pipeline_take_resolved;
        tb_pipeline_resolved_PC;
        // I$
        tb_icache_hit;
        tb_icache_load;
        // core controller
        tb_pipeline_stall_fetch_unit;
        tb_pipeline_halt;

        @(posedge CLK);

        // outputs:

        // I$
        expected_icache_REN;
        expected_icache_addr;
        expected_icache_halt;
        // to pipeline
        expected_pipeline_instr;
        expected_pipeline_ivalid;
        expected_pipeline_PC;
        expected_pipeline_nPC;

        check_outputs();

        @(posedge CLK);

        // outputs:

        // I$
        expected_icache_REN;
        expected_icache_addr;
        expected_icache_halt;
        // to pipeline
        expected_pipeline_instr;
        expected_pipeline_ivalid;
        expected_pipeline_PC;
        expected_pipeline_nPC;

        check_outputs();
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // finish:
        if (num_errors) begin
            $display("FAIL: %d tests fail", num_errors);
        end
        else begin
            $display("SUCCESS: all tests pass");
        end

        $finish();
    end

endmodule