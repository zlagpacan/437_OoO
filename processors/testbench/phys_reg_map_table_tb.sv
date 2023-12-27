/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_map_table_tb.sv
    Instantiation Hierarchy: system -> core -> phys_reg_map_table
    Description: 
       Testbench for phys_reg_map_table module. 
*/

`timescale 1ns/100ps

`include "instr_types.vh"
import instr_types_pkg::*;

module phys_reg_map_table_tb ();

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
    // DUT input signals:

    // reg map reading
    arch_reg_tag_t tb_source_arch_reg_tag_0;
    arch_reg_tag_t tb_source_arch_reg_tag_1;

    // reg map writing
    logic tb_new_map_valid;
    arch_reg_tag_t tb_new_map_dest_arch_reg_tag;
    phys_reg_tag_t tb_new_map_dest_phys_reg_tag;

    // reg map killing
    logic tb_kill_map_valid;
    arch_reg_tag_t tb_kill_map_dest_arch_reg_tag;
    phys_reg_tag_t tb_kill_map_old_dest_phys_reg_tag;
    phys_reg_tag_t tb_kill_map_new_dest_phys_reg_tag;
        // can use for assertion but otherwise don't need

endmodule