/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: mem_controller_tb.sv
    Description: 
        Testbench for mem_controller module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

`include "cpu_ram_if.vh"

// `include "cpu_types_pkg.vh"
// import cpu_types_pkg::*;
	// use mine instead

module mem_controller_tb ();

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

    ////////////////////////
    // CPU RAM interface: //
    ////////////////////////

    cpu_ram_if prif ();
        // // cpu ports
        // modport cpu (
        //     input   ramstate, ramload,
        //     output  memaddr, memREN, memWEN, memstore
        // );
	logic expected_prif_memREN;
	logic expected_prif_memWEN;
	word_t expected_prif_memaddr;
	word_t expected_prif_memstore;

    /////////////////////
    // imem interface: //
    /////////////////////
        // synchronous, blocking interface
        // essentially same as 437
	logic tb_imem_REN;
	block_addr_t tb_imem_block_addr;
	logic DUT_imem_hit, expected_imem_hit;
	word_t [1:0] DUT_imem_load, expected_imem_load;

    /////////////////////
    // dmem interface: //
    /////////////////////
        // asynchronous, non-blocking interface

    // dmem read req:
	logic tb_dmem_read_req_valid;
	block_addr_t tb_dmem_read_req_block_addr;

    // dmem read resp:
	logic DUT_dmem_read_resp_valid, expected_dmem_read_resp_valid;
	block_addr_t DUT_dmem_read_resp_block_addr, expected_dmem_read_resp_block_addr;
	word_t [1:0] DUT_dmem_read_resp_data, expected_dmem_read_resp_data;

    // dmem write req:
	logic tb_dmem_write_req_valid;
	block_addr_t tb_dmem_write_req_block_addr;
	word_t [1:0] tb_dmem_write_req_data;
	logic DUT_dmem_write_req_slow_down, expected_dmem_write_req_slow_down;

    //////////////
    // flushed: //
    //////////////

	logic tb_dcache_flushed;
	logic DUT_mem_controller_flushed, expected_mem_controller_flushed;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	`ifndef MAPPED
	mem_controller DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////

	    .prif(prif),
	        // // cpu ports
	        // modport cpu (
	        //     input   ramstate, ramload,
	        //     output  memaddr, memREN, memWEN, memstore
	        // );

	    /////////////////////
	    // imem interface: //
	    /////////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
		.imem_REN(tb_imem_REN),
		.imem_block_addr(tb_imem_block_addr),
		.imem_hit(DUT_imem_hit),
		.imem_load(DUT_imem_load),

	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	        // asynchronous, non-blocking interface

	    // dmem read req:
		.dmem_read_req_valid(tb_dmem_read_req_valid),
		.dmem_read_req_block_addr(tb_dmem_read_req_block_addr),

	    // dmem read resp:
		.dmem_read_resp_valid(DUT_dmem_read_resp_valid),
		.dmem_read_resp_block_addr(DUT_dmem_read_resp_block_addr),
		.dmem_read_resp_data(DUT_dmem_read_resp_data),

	    // dmem write req:
		.dmem_write_req_valid(tb_dmem_write_req_valid),
		.dmem_write_req_block_addr(tb_dmem_write_req_block_addr),
		.dmem_write_req_data(tb_dmem_write_req_data),
		.dmem_write_req_slow_down(DUT_dmem_write_req_slow_down),

	    //////////////
	    // flushed: //
	    //////////////

		.dcache_flushed(tb_dcache_flushed),
		.mem_controller_flushed(DUT_mem_controller_flushed)
	);
	`else

	mem_controller DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////

	    // .prif(prif),
	        // // cpu ports
	        // modport cpu (
	        //     input   ramstate, ramload,
	        //     output  memaddr, memREN, memWEN, memstore
	        // );
		.\prif.memstore (prif.memstore),
		.\prif.memWEN (prif.memWEN),
		.\prif.memREN (prif.memREN),
		.\prif.memaddr (prif.memaddr),
		.\prif.ramload (prif.ramload),
		.\prif.ramstate (prif.ramstate),

	    /////////////////////
	    // imem interface: //
	    /////////////////////
	        // synchronous, blocking interface
	        // essentially same as 437
		.imem_REN(tb_imem_REN),
		.imem_block_addr(tb_imem_block_addr),
		.imem_hit(DUT_imem_hit),
		// .imem_load(DUT_imem_load),
		.imem_load_0_0(DUT_imem_load[0][0]),
		.imem_load_0_1(DUT_imem_load[0][1]),
		.imem_load_0_2(DUT_imem_load[0][2]),
		.imem_load_0_3(DUT_imem_load[0][3]),
		.imem_load_0_4(DUT_imem_load[0][4]),
		.imem_load_0_5(DUT_imem_load[0][5]),
		.imem_load_0_6(DUT_imem_load[0][6]),
		.imem_load_0_7(DUT_imem_load[0][7]),
		.imem_load_0_8(DUT_imem_load[0][8]),
		.imem_load_0_9(DUT_imem_load[0][9]),
		.imem_load_0_10(DUT_imem_load[0][10]),
		.imem_load_0_11(DUT_imem_load[0][11]),
		.imem_load_0_12(DUT_imem_load[0][12]),
		.imem_load_0_13(DUT_imem_load[0][13]),
		.imem_load_0_14(DUT_imem_load[0][14]),
		.imem_load_0_15(DUT_imem_load[0][15]),
		.imem_load_0_16(DUT_imem_load[0][16]),
		.imem_load_0_17(DUT_imem_load[0][17]),
		.imem_load_0_18(DUT_imem_load[0][18]),
		.imem_load_0_19(DUT_imem_load[0][19]),
		.imem_load_0_20(DUT_imem_load[0][20]),
		.imem_load_0_21(DUT_imem_load[0][21]),
		.imem_load_0_22(DUT_imem_load[0][22]),
		.imem_load_0_23(DUT_imem_load[0][23]),
		.imem_load_0_24(DUT_imem_load[0][24]),
		.imem_load_0_25(DUT_imem_load[0][25]),
		.imem_load_0_26(DUT_imem_load[0][26]),
		.imem_load_0_27(DUT_imem_load[0][27]),
		.imem_load_0_28(DUT_imem_load[0][28]),
		.imem_load_0_29(DUT_imem_load[0][29]),
		.imem_load_0_30(DUT_imem_load[0][30]),
		.imem_load_0_31(DUT_imem_load[0][31]),
		.imem_load_1_0(DUT_imem_load[1][0]),
		.imem_load_1_1(DUT_imem_load[1][1]),
		.imem_load_1_2(DUT_imem_load[1][2]),
		.imem_load_1_3(DUT_imem_load[1][3]),
		.imem_load_1_4(DUT_imem_load[1][4]),
		.imem_load_1_5(DUT_imem_load[1][5]),
		.imem_load_1_6(DUT_imem_load[1][6]),
		.imem_load_1_7(DUT_imem_load[1][7]),
		.imem_load_1_8(DUT_imem_load[1][8]),
		.imem_load_1_9(DUT_imem_load[1][9]),
		.imem_load_1_10(DUT_imem_load[1][10]),
		.imem_load_1_11(DUT_imem_load[1][11]),
		.imem_load_1_12(DUT_imem_load[1][12]),
		.imem_load_1_13(DUT_imem_load[1][13]),
		.imem_load_1_14(DUT_imem_load[1][14]),
		.imem_load_1_15(DUT_imem_load[1][15]),
		.imem_load_1_16(DUT_imem_load[1][16]),
		.imem_load_1_17(DUT_imem_load[1][17]),
		.imem_load_1_18(DUT_imem_load[1][18]),
		.imem_load_1_19(DUT_imem_load[1][19]),
		.imem_load_1_20(DUT_imem_load[1][20]),
		.imem_load_1_21(DUT_imem_load[1][21]),
		.imem_load_1_22(DUT_imem_load[1][22]),
		.imem_load_1_23(DUT_imem_load[1][23]),
		.imem_load_1_24(DUT_imem_load[1][24]),
		.imem_load_1_25(DUT_imem_load[1][25]),
		.imem_load_1_26(DUT_imem_load[1][26]),
		.imem_load_1_27(DUT_imem_load[1][27]),
		.imem_load_1_28(DUT_imem_load[1][28]),
		.imem_load_1_29(DUT_imem_load[1][29]),
		.imem_load_1_30(DUT_imem_load[1][30]),
		.imem_load_1_31(DUT_imem_load[1][31]),

	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	        // asynchronous, non-blocking interface

	    // dmem read req:
		.dmem_read_req_valid(tb_dmem_read_req_valid),
		.dmem_read_req_block_addr(tb_dmem_read_req_block_addr),

	    // dmem read resp:
		.dmem_read_resp_valid(DUT_dmem_read_resp_valid),
		.dmem_read_resp_block_addr(DUT_dmem_read_resp_block_addr),
		// .dmem_read_resp_data(DUT_dmem_read_resp_data),
		.dmem_read_resp_data_0_0(DUT_dmem_read_resp_data[0][0]),
		.dmem_read_resp_data_0_1(DUT_dmem_read_resp_data[0][1]),
		.dmem_read_resp_data_0_2(DUT_dmem_read_resp_data[0][2]),
		.dmem_read_resp_data_0_3(DUT_dmem_read_resp_data[0][3]),
		.dmem_read_resp_data_0_4(DUT_dmem_read_resp_data[0][4]),
		.dmem_read_resp_data_0_5(DUT_dmem_read_resp_data[0][5]),
		.dmem_read_resp_data_0_6(DUT_dmem_read_resp_data[0][6]),
		.dmem_read_resp_data_0_7(DUT_dmem_read_resp_data[0][7]),
		.dmem_read_resp_data_0_8(DUT_dmem_read_resp_data[0][8]),
		.dmem_read_resp_data_0_9(DUT_dmem_read_resp_data[0][9]),
		.dmem_read_resp_data_0_10(DUT_dmem_read_resp_data[0][10]),
		.dmem_read_resp_data_0_11(DUT_dmem_read_resp_data[0][11]),
		.dmem_read_resp_data_0_12(DUT_dmem_read_resp_data[0][12]),
		.dmem_read_resp_data_0_13(DUT_dmem_read_resp_data[0][13]),
		.dmem_read_resp_data_0_14(DUT_dmem_read_resp_data[0][14]),
		.dmem_read_resp_data_0_15(DUT_dmem_read_resp_data[0][15]),
		.dmem_read_resp_data_0_16(DUT_dmem_read_resp_data[0][16]),
		.dmem_read_resp_data_0_17(DUT_dmem_read_resp_data[0][17]),
		.dmem_read_resp_data_0_18(DUT_dmem_read_resp_data[0][18]),
		.dmem_read_resp_data_0_19(DUT_dmem_read_resp_data[0][19]),
		.dmem_read_resp_data_0_20(DUT_dmem_read_resp_data[0][20]),
		.dmem_read_resp_data_0_21(DUT_dmem_read_resp_data[0][21]),
		.dmem_read_resp_data_0_22(DUT_dmem_read_resp_data[0][22]),
		.dmem_read_resp_data_0_23(DUT_dmem_read_resp_data[0][23]),
		.dmem_read_resp_data_0_24(DUT_dmem_read_resp_data[0][24]),
		.dmem_read_resp_data_0_25(DUT_dmem_read_resp_data[0][25]),
		.dmem_read_resp_data_0_26(DUT_dmem_read_resp_data[0][26]),
		.dmem_read_resp_data_0_27(DUT_dmem_read_resp_data[0][27]),
		.dmem_read_resp_data_0_28(DUT_dmem_read_resp_data[0][28]),
		.dmem_read_resp_data_0_29(DUT_dmem_read_resp_data[0][29]),
		.dmem_read_resp_data_0_30(DUT_dmem_read_resp_data[0][30]),
		.dmem_read_resp_data_0_31(DUT_dmem_read_resp_data[0][31]),
		.dmem_read_resp_data_1_0(DUT_dmem_read_resp_data[1][0]),
		.dmem_read_resp_data_1_1(DUT_dmem_read_resp_data[1][1]),
		.dmem_read_resp_data_1_2(DUT_dmem_read_resp_data[1][2]),
		.dmem_read_resp_data_1_3(DUT_dmem_read_resp_data[1][3]),
		.dmem_read_resp_data_1_4(DUT_dmem_read_resp_data[1][4]),
		.dmem_read_resp_data_1_5(DUT_dmem_read_resp_data[1][5]),
		.dmem_read_resp_data_1_6(DUT_dmem_read_resp_data[1][6]),
		.dmem_read_resp_data_1_7(DUT_dmem_read_resp_data[1][7]),
		.dmem_read_resp_data_1_8(DUT_dmem_read_resp_data[1][8]),
		.dmem_read_resp_data_1_9(DUT_dmem_read_resp_data[1][9]),
		.dmem_read_resp_data_1_10(DUT_dmem_read_resp_data[1][10]),
		.dmem_read_resp_data_1_11(DUT_dmem_read_resp_data[1][11]),
		.dmem_read_resp_data_1_12(DUT_dmem_read_resp_data[1][12]),
		.dmem_read_resp_data_1_13(DUT_dmem_read_resp_data[1][13]),
		.dmem_read_resp_data_1_14(DUT_dmem_read_resp_data[1][14]),
		.dmem_read_resp_data_1_15(DUT_dmem_read_resp_data[1][15]),
		.dmem_read_resp_data_1_16(DUT_dmem_read_resp_data[1][16]),
		.dmem_read_resp_data_1_17(DUT_dmem_read_resp_data[1][17]),
		.dmem_read_resp_data_1_18(DUT_dmem_read_resp_data[1][18]),
		.dmem_read_resp_data_1_19(DUT_dmem_read_resp_data[1][19]),
		.dmem_read_resp_data_1_20(DUT_dmem_read_resp_data[1][20]),
		.dmem_read_resp_data_1_21(DUT_dmem_read_resp_data[1][21]),
		.dmem_read_resp_data_1_22(DUT_dmem_read_resp_data[1][22]),
		.dmem_read_resp_data_1_23(DUT_dmem_read_resp_data[1][23]),
		.dmem_read_resp_data_1_24(DUT_dmem_read_resp_data[1][24]),
		.dmem_read_resp_data_1_25(DUT_dmem_read_resp_data[1][25]),
		.dmem_read_resp_data_1_26(DUT_dmem_read_resp_data[1][26]),
		.dmem_read_resp_data_1_27(DUT_dmem_read_resp_data[1][27]),
		.dmem_read_resp_data_1_28(DUT_dmem_read_resp_data[1][28]),
		.dmem_read_resp_data_1_29(DUT_dmem_read_resp_data[1][29]),
		.dmem_read_resp_data_1_30(DUT_dmem_read_resp_data[1][30]),
		.dmem_read_resp_data_1_31(DUT_dmem_read_resp_data[1][31]),

	    // dmem write req:
		.dmem_write_req_valid(tb_dmem_write_req_valid),
		.dmem_write_req_block_addr(tb_dmem_write_req_block_addr),
		// .dmem_write_req_data(tb_dmem_write_req_data),
		.dmem_write_req_data_0_0(tb_dmem_write_req_data[0][0]),
		.dmem_write_req_data_0_1(tb_dmem_write_req_data[0][1]),
		.dmem_write_req_data_0_2(tb_dmem_write_req_data[0][2]),
		.dmem_write_req_data_0_3(tb_dmem_write_req_data[0][3]),
		.dmem_write_req_data_0_4(tb_dmem_write_req_data[0][4]),
		.dmem_write_req_data_0_5(tb_dmem_write_req_data[0][5]),
		.dmem_write_req_data_0_6(tb_dmem_write_req_data[0][6]),
		.dmem_write_req_data_0_7(tb_dmem_write_req_data[0][7]),
		.dmem_write_req_data_0_8(tb_dmem_write_req_data[0][8]),
		.dmem_write_req_data_0_9(tb_dmem_write_req_data[0][9]),
		.dmem_write_req_data_0_10(tb_dmem_write_req_data[0][10]),
		.dmem_write_req_data_0_11(tb_dmem_write_req_data[0][11]),
		.dmem_write_req_data_0_12(tb_dmem_write_req_data[0][12]),
		.dmem_write_req_data_0_13(tb_dmem_write_req_data[0][13]),
		.dmem_write_req_data_0_14(tb_dmem_write_req_data[0][14]),
		.dmem_write_req_data_0_15(tb_dmem_write_req_data[0][15]),
		.dmem_write_req_data_0_16(tb_dmem_write_req_data[0][16]),
		.dmem_write_req_data_0_17(tb_dmem_write_req_data[0][17]),
		.dmem_write_req_data_0_18(tb_dmem_write_req_data[0][18]),
		.dmem_write_req_data_0_19(tb_dmem_write_req_data[0][19]),
		.dmem_write_req_data_0_20(tb_dmem_write_req_data[0][20]),
		.dmem_write_req_data_0_21(tb_dmem_write_req_data[0][21]),
		.dmem_write_req_data_0_22(tb_dmem_write_req_data[0][22]),
		.dmem_write_req_data_0_23(tb_dmem_write_req_data[0][23]),
		.dmem_write_req_data_0_24(tb_dmem_write_req_data[0][24]),
		.dmem_write_req_data_0_25(tb_dmem_write_req_data[0][25]),
		.dmem_write_req_data_0_26(tb_dmem_write_req_data[0][26]),
		.dmem_write_req_data_0_27(tb_dmem_write_req_data[0][27]),
		.dmem_write_req_data_0_28(tb_dmem_write_req_data[0][28]),
		.dmem_write_req_data_0_29(tb_dmem_write_req_data[0][29]),
		.dmem_write_req_data_0_30(tb_dmem_write_req_data[0][30]),
		.dmem_write_req_data_0_31(tb_dmem_write_req_data[0][31]),
		.dmem_write_req_data_1_0(tb_dmem_write_req_data[1][0]),
		.dmem_write_req_data_1_1(tb_dmem_write_req_data[1][1]),
		.dmem_write_req_data_1_2(tb_dmem_write_req_data[1][2]),
		.dmem_write_req_data_1_3(tb_dmem_write_req_data[1][3]),
		.dmem_write_req_data_1_4(tb_dmem_write_req_data[1][4]),
		.dmem_write_req_data_1_5(tb_dmem_write_req_data[1][5]),
		.dmem_write_req_data_1_6(tb_dmem_write_req_data[1][6]),
		.dmem_write_req_data_1_7(tb_dmem_write_req_data[1][7]),
		.dmem_write_req_data_1_8(tb_dmem_write_req_data[1][8]),
		.dmem_write_req_data_1_9(tb_dmem_write_req_data[1][9]),
		.dmem_write_req_data_1_10(tb_dmem_write_req_data[1][10]),
		.dmem_write_req_data_1_11(tb_dmem_write_req_data[1][11]),
		.dmem_write_req_data_1_12(tb_dmem_write_req_data[1][12]),
		.dmem_write_req_data_1_13(tb_dmem_write_req_data[1][13]),
		.dmem_write_req_data_1_14(tb_dmem_write_req_data[1][14]),
		.dmem_write_req_data_1_15(tb_dmem_write_req_data[1][15]),
		.dmem_write_req_data_1_16(tb_dmem_write_req_data[1][16]),
		.dmem_write_req_data_1_17(tb_dmem_write_req_data[1][17]),
		.dmem_write_req_data_1_18(tb_dmem_write_req_data[1][18]),
		.dmem_write_req_data_1_19(tb_dmem_write_req_data[1][19]),
		.dmem_write_req_data_1_20(tb_dmem_write_req_data[1][20]),
		.dmem_write_req_data_1_21(tb_dmem_write_req_data[1][21]),
		.dmem_write_req_data_1_22(tb_dmem_write_req_data[1][22]),
		.dmem_write_req_data_1_23(tb_dmem_write_req_data[1][23]),
		.dmem_write_req_data_1_24(tb_dmem_write_req_data[1][24]),
		.dmem_write_req_data_1_25(tb_dmem_write_req_data[1][25]),
		.dmem_write_req_data_1_26(tb_dmem_write_req_data[1][26]),
		.dmem_write_req_data_1_27(tb_dmem_write_req_data[1][27]),
		.dmem_write_req_data_1_28(tb_dmem_write_req_data[1][28]),
		.dmem_write_req_data_1_29(tb_dmem_write_req_data[1][29]),
		.dmem_write_req_data_1_30(tb_dmem_write_req_data[1][30]),
		.dmem_write_req_data_1_31(tb_dmem_write_req_data[1][31]),

		.dmem_write_req_slow_down(DUT_dmem_write_req_slow_down),

	    //////////////
	    // flushed: //
	    //////////////

		.dcache_flushed(tb_dcache_flushed),
		.mem_controller_flushed(DUT_mem_controller_flushed)
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

		if (expected_prif_memREN !== prif.memREN) begin
			$display("TB ERROR: expected_prif_memREN (%h) != prif.memREN (%h)",
				expected_prif_memREN, prif.memREN);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_prif_memWEN !== prif.memWEN) begin
			$display("TB ERROR: expected_prif_memWEN (%h) != prif.memWEN (%h)",
				expected_prif_memWEN, prif.memWEN);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_prif_memaddr !== prif.memaddr) begin
			$display("TB ERROR: expected_prif_memaddr (%h) != prif.memaddr (%h)",
				expected_prif_memaddr, prif.memaddr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_prif_memstore !== prif.memstore) begin
			$display("TB ERROR: expected_prif_memstore (%h) != prif.memstore (%h)",
				expected_prif_memstore, prif.memstore);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem_hit !== DUT_imem_hit) begin
			$display("TB ERROR: expected_imem_hit (%h) != DUT_imem_hit (%h)",
				expected_imem_hit, DUT_imem_hit);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_imem_load !== DUT_imem_load) begin
			$display("TB ERROR: expected_imem_load (%h) != DUT_imem_load (%h)",
				expected_imem_load, DUT_imem_load);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_resp_valid !== DUT_dmem_read_resp_valid) begin
			$display("TB ERROR: expected_dmem_read_resp_valid (%h) != DUT_dmem_read_resp_valid (%h)",
				expected_dmem_read_resp_valid, DUT_dmem_read_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_resp_block_addr !== DUT_dmem_read_resp_block_addr) begin
			$display("TB ERROR: expected_dmem_read_resp_block_addr (%h) != DUT_dmem_read_resp_block_addr (%h)",
				expected_dmem_read_resp_block_addr, DUT_dmem_read_resp_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_resp_data !== DUT_dmem_read_resp_data) begin
			$display("TB ERROR: expected_dmem_read_resp_data (%h) != DUT_dmem_read_resp_data (%h)",
				expected_dmem_read_resp_data, DUT_dmem_read_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_slow_down !== DUT_dmem_write_req_slow_down) begin
			$display("TB ERROR: expected_dmem_write_req_slow_down (%h) != DUT_dmem_write_req_slow_down (%h)",
				expected_dmem_write_req_slow_down, DUT_dmem_write_req_slow_down);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_mem_controller_flushed !== DUT_mem_controller_flushed) begin
			$display("TB ERROR: expected_mem_controller_flushed (%h) != DUT_mem_controller_flushed (%h)",
				expected_mem_controller_flushed, DUT_mem_controller_flushed);
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
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
	    prif.ramstate = ACCESS;
		prif.ramload = 32'h0;
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		tb_imem_REN = 1'b0;
		tb_imem_block_addr = 13'h0;
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
		tb_dmem_read_req_valid = 1'b0;
		tb_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		tb_dmem_write_req_valid = 1'b0;
		tb_dmem_write_req_block_addr = 13'h0;
		tb_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache_flushed = 1'b0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
		expected_prif_memREN = 1'b0;
		expected_prif_memWEN = 1'b0;
		expected_prif_memaddr = 32'h0;
		expected_prif_memstore = 32'h0;
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		expected_imem_hit = 1'b0;
		expected_imem_load = {32'h0, 32'h0};
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
	    // dmem read resp:
		expected_dmem_read_resp_valid = 1'b0;
		expected_dmem_read_resp_block_addr = 13'h0;
		expected_dmem_read_resp_data = {32'h0, 32'h0};
	    // dmem write req:
		expected_dmem_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////
		expected_mem_controller_flushed = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
	    prif.ramstate = ACCESS;
		prif.ramload = 32'h0;
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		tb_imem_REN = 1'b0;
		tb_imem_block_addr = 13'h0;
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
		tb_dmem_read_req_valid = 1'b0;
		tb_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		tb_dmem_write_req_valid = 1'b0;
		tb_dmem_write_req_block_addr = 13'h0;
		tb_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache_flushed = 1'b0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
		expected_prif_memREN = 1'b0;
		expected_prif_memWEN = 1'b0;
		expected_prif_memaddr = 32'h0;
		expected_prif_memstore = 32'h0;
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		expected_imem_hit = 1'b0;
		expected_imem_load = {32'h0, 32'h0};
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
	    // dmem read resp:
		expected_dmem_read_resp_valid = 1'b0;
		expected_dmem_read_resp_block_addr = 13'h0;
		expected_dmem_read_resp_data = {32'h0, 32'h0};
	    // dmem write req:
		expected_dmem_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////
		expected_mem_controller_flushed = 1'b0;

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
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
	    prif.ramstate = ACCESS;
		prif.ramload = 32'h0;
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		tb_imem_REN = 1'b0;
		tb_imem_block_addr = 13'h0;
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
		tb_dmem_read_req_valid = 1'b0;
		tb_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		tb_dmem_write_req_valid = 1'b0;
		tb_dmem_write_req_block_addr = 13'h0;
		tb_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		tb_dcache_flushed = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////////
	    // CPU RAM interface: //
	    ////////////////////////
		expected_prif_memREN = 1'b0;
		expected_prif_memWEN = 1'b0;
		expected_prif_memaddr = 32'h0;
		expected_prif_memstore = 32'h0;
	    /////////////////////
	    // imem interface: //
	    /////////////////////
		expected_imem_hit = 1'b0;
		expected_imem_load = {32'h0, 32'h0};
	    /////////////////////
	    // dmem interface: //
	    /////////////////////
	    // dmem read req:
	    // dmem read resp:
		expected_dmem_read_resp_valid = 1'b0;
		expected_dmem_read_resp_block_addr = 13'h0;
		expected_dmem_read_resp_data = {32'h0, 32'h0};
	    // dmem write req:
		expected_dmem_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////
		expected_mem_controller_flushed = 1'b0;

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

