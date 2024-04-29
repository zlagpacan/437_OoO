/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dcache_tb.sv
    Description: 
        Testbench for dcache module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module dcache_tb ();

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

    /////////////////////
    // core interface: //
    /////////////////////
        // asynchronous, non-blocking interface

    // read req interface:
	logic tb_dcache_read_req_valid;
	LQ_index_t tb_dcache_read_req_LQ_index;
	daddr_t tb_dcache_read_req_addr;
	logic tb_dcache_read_req_linked;
	logic tb_dcache_read_req_conditional;
	logic DUT_dcache_read_req_blocked, expected_dcache_read_req_blocked;

    // read resp interface:
	logic DUT_dcache_read_resp_valid, expected_dcache_read_resp_valid;
	LQ_index_t DUT_dcache_read_resp_LQ_index, expected_dcache_read_resp_LQ_index;
	word_t DUT_dcache_read_resp_data, expected_dcache_read_resp_data;

    // write req interface:
	logic tb_dcache_write_req_valid;
	daddr_t tb_dcache_write_req_addr;
	word_t tb_dcache_write_req_data;
	logic tb_dcache_write_req_conditional;
	logic DUT_dcache_write_req_blocked, expected_dcache_write_req_blocked;

    // read kill interface x2:
        // even though doing bus resp block addr broadcast, still want these to 
	logic tb_dcache_read_kill_0_valid;
	LQ_index_t tb_dcache_read_kill_0_LQ_index;
	logic tb_dcache_read_kill_1_valid;
	LQ_index_t tb_dcache_read_kill_1_LQ_index;

    // invalidation interface:
        // TODO: implement logic for multicore
            // already implemented eviction inv's, technically don't need for unicore
            // need to add snoop inv's -> potentially need new Q or double this interface to core
	logic DUT_dcache_inv_valid, expected_dcache_inv_valid;
	block_addr_t DUT_dcache_inv_block_addr, expected_dcache_inv_block_addr;

    // halt interface:
	logic tb_dcache_halt;

    ////////////////////
    // mem interface: //
    ////////////////////
        // asynchronous, non-blocking interface

    // dmem read req:
	logic DUT_dmem_read_req_valid, expected_dmem_read_req_valid;
	block_addr_t DUT_dmem_read_req_block_addr, expected_dmem_read_req_block_addr;

    // dmem read resp:
	logic tb_dmem_read_resp_valid;
	block_addr_t tb_dmem_read_resp_block_addr;
	word_t [1:0] tb_dmem_read_resp_data;

    // dmem write req:
	logic DUT_dmem_write_req_valid, expected_dmem_write_req_valid;
	block_addr_t DUT_dmem_write_req_block_addr, expected_dmem_write_req_block_addr;
	word_t [1:0] DUT_dmem_write_req_data, expected_dmem_write_req_data;
	logic tb_dmem_write_req_slow_down;

    //////////////
    // flushed: //
    //////////////

	logic DUT_flushed, expected_flushed;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	`ifndef MAPPED
	dcache DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    /////////////////////
	    // core interface: //
	    /////////////////////
	        // asynchronous, non-blocking interface

	    // read req interface:
		.dcache_read_req_valid(tb_dcache_read_req_valid),
		.dcache_read_req_LQ_index(tb_dcache_read_req_LQ_index),
		.dcache_read_req_addr(tb_dcache_read_req_addr),
		.dcache_read_req_linked(tb_dcache_read_req_linked),
		.dcache_read_req_conditional(tb_dcache_read_req_conditional),
		.dcache_read_req_blocked(DUT_dcache_read_req_blocked),

	    // read resp interface:
		.dcache_read_resp_valid(DUT_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(DUT_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(DUT_dcache_read_resp_data),

	    // write req interface:
		.dcache_write_req_valid(tb_dcache_write_req_valid),
		.dcache_write_req_addr(tb_dcache_write_req_addr),
		.dcache_write_req_data(tb_dcache_write_req_data),
		.dcache_write_req_conditional(tb_dcache_write_req_conditional),
		.dcache_write_req_blocked(DUT_dcache_write_req_blocked),

	    // read kill interface x2:
	        // even though doing bus resp block addr broadcast, still want these to 
		.dcache_read_kill_0_valid(tb_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(tb_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(tb_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(tb_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
	        // TODO: implement logic for multicore
	            // already implemented eviction inv's, technically don't need for unicore
	            // need to add snoop inv's -> potentially need new Q or double this interface to core
		.dcache_inv_valid(DUT_dcache_inv_valid),
		.dcache_inv_block_addr(DUT_dcache_inv_block_addr),

	    // halt interface:
		.dcache_halt(tb_dcache_halt),

	    ////////////////////
	    // mem interface: //
	    ////////////////////
	        // asynchronous, non-blocking interface

	    // dmem read req:
		.dmem_read_req_valid(DUT_dmem_read_req_valid),
		.dmem_read_req_block_addr(DUT_dmem_read_req_block_addr),

	    // dmem read resp:
		.dmem_read_resp_valid(tb_dmem_read_resp_valid),
		.dmem_read_resp_block_addr(tb_dmem_read_resp_block_addr),
		.dmem_read_resp_data(tb_dmem_read_resp_data),

	    // dmem write req:
		.dmem_write_req_valid(DUT_dmem_write_req_valid),
		.dmem_write_req_block_addr(DUT_dmem_write_req_block_addr),
		.dmem_write_req_data(DUT_dmem_write_req_data),
		.dmem_write_req_slow_down(tb_dmem_write_req_slow_down),

	    //////////////
	    // flushed: //
	    //////////////

		.flushed(DUT_flushed)
	);
	`else

	dcache DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    /////////////////////
	    // core interface: //
	    /////////////////////
	        // asynchronous, non-blocking interface

	    // read req interface:
		.dcache_read_req_valid(tb_dcache_read_req_valid),
		.dcache_read_req_LQ_index(tb_dcache_read_req_LQ_index),
		.dcache_read_req_addr(tb_dcache_read_req_addr),
		.dcache_read_req_linked(tb_dcache_read_req_linked),
		.dcache_read_req_conditional(tb_dcache_read_req_conditional),
		.dcache_read_req_blocked(DUT_dcache_read_req_blocked),

	    // read resp interface:
		.dcache_read_resp_valid(DUT_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(DUT_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(DUT_dcache_read_resp_data),

	    // write req interface:
		.dcache_write_req_valid(tb_dcache_write_req_valid),
		.dcache_write_req_addr(tb_dcache_write_req_addr),
		.dcache_write_req_data(tb_dcache_write_req_data),
		.dcache_write_req_conditional(tb_dcache_write_req_conditional),
		.dcache_write_req_blocked(DUT_dcache_write_req_blocked),

	    // read kill interface x2:
	        // even though doing bus resp block addr broadcast, still want these to 
		.dcache_read_kill_0_valid(tb_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(tb_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(tb_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(tb_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
	        // TODO: implement logic for multicore
	            // already implemented eviction inv's, technically don't need for unicore
	            // need to add snoop inv's -> potentially need new Q or double this interface to core
		.dcache_inv_valid(DUT_dcache_inv_valid),
		.dcache_inv_block_addr(DUT_dcache_inv_block_addr),

	    // halt interface:
		.dcache_halt(tb_dcache_halt),

	    ////////////////////
	    // mem interface: //
	    ////////////////////
	        // asynchronous, non-blocking interface

	    // dmem read req:
		.dmem_read_req_valid(DUT_dmem_read_req_valid),
		.dmem_read_req_block_addr(DUT_dmem_read_req_block_addr),

	    // dmem read resp:
		.dmem_read_resp_valid(tb_dmem_read_resp_valid),
		.dmem_read_resp_block_addr(tb_dmem_read_resp_block_addr),
		// .dmem_read_resp_data(tb_dmem_read_resp_data),
		.dmem_read_resp_data_0_0(tb_dmem_read_resp_data[0][0]),
		.dmem_read_resp_data_0_1(tb_dmem_read_resp_data[0][1]),
		.dmem_read_resp_data_0_2(tb_dmem_read_resp_data[0][2]),
		.dmem_read_resp_data_0_3(tb_dmem_read_resp_data[0][3]),
		.dmem_read_resp_data_0_4(tb_dmem_read_resp_data[0][4]),
		.dmem_read_resp_data_0_5(tb_dmem_read_resp_data[0][5]),
		.dmem_read_resp_data_0_6(tb_dmem_read_resp_data[0][6]),
		.dmem_read_resp_data_0_7(tb_dmem_read_resp_data[0][7]),
		.dmem_read_resp_data_0_8(tb_dmem_read_resp_data[0][8]),
		.dmem_read_resp_data_0_9(tb_dmem_read_resp_data[0][9]),
		.dmem_read_resp_data_0_10(tb_dmem_read_resp_data[0][10]),
		.dmem_read_resp_data_0_11(tb_dmem_read_resp_data[0][11]),
		.dmem_read_resp_data_0_12(tb_dmem_read_resp_data[0][12]),
		.dmem_read_resp_data_0_13(tb_dmem_read_resp_data[0][13]),
		.dmem_read_resp_data_0_14(tb_dmem_read_resp_data[0][14]),
		.dmem_read_resp_data_0_15(tb_dmem_read_resp_data[0][15]),
		.dmem_read_resp_data_0_16(tb_dmem_read_resp_data[0][16]),
		.dmem_read_resp_data_0_17(tb_dmem_read_resp_data[0][17]),
		.dmem_read_resp_data_0_18(tb_dmem_read_resp_data[0][18]),
		.dmem_read_resp_data_0_19(tb_dmem_read_resp_data[0][19]),
		.dmem_read_resp_data_0_20(tb_dmem_read_resp_data[0][20]),
		.dmem_read_resp_data_0_21(tb_dmem_read_resp_data[0][21]),
		.dmem_read_resp_data_0_22(tb_dmem_read_resp_data[0][22]),
		.dmem_read_resp_data_0_23(tb_dmem_read_resp_data[0][23]),
		.dmem_read_resp_data_0_24(tb_dmem_read_resp_data[0][24]),
		.dmem_read_resp_data_0_25(tb_dmem_read_resp_data[0][25]),
		.dmem_read_resp_data_0_26(tb_dmem_read_resp_data[0][26]),
		.dmem_read_resp_data_0_27(tb_dmem_read_resp_data[0][27]),
		.dmem_read_resp_data_0_28(tb_dmem_read_resp_data[0][28]),
		.dmem_read_resp_data_0_29(tb_dmem_read_resp_data[0][29]),
		.dmem_read_resp_data_0_30(tb_dmem_read_resp_data[0][30]),
		.dmem_read_resp_data_0_31(tb_dmem_read_resp_data[0][31]),
		.dmem_read_resp_data_1_0(tb_dmem_read_resp_data[1][0]),
		.dmem_read_resp_data_1_1(tb_dmem_read_resp_data[1][1]),
		.dmem_read_resp_data_1_2(tb_dmem_read_resp_data[1][2]),
		.dmem_read_resp_data_1_3(tb_dmem_read_resp_data[1][3]),
		.dmem_read_resp_data_1_4(tb_dmem_read_resp_data[1][4]),
		.dmem_read_resp_data_1_5(tb_dmem_read_resp_data[1][5]),
		.dmem_read_resp_data_1_6(tb_dmem_read_resp_data[1][6]),
		.dmem_read_resp_data_1_7(tb_dmem_read_resp_data[1][7]),
		.dmem_read_resp_data_1_8(tb_dmem_read_resp_data[1][8]),
		.dmem_read_resp_data_1_9(tb_dmem_read_resp_data[1][9]),
		.dmem_read_resp_data_1_10(tb_dmem_read_resp_data[1][10]),
		.dmem_read_resp_data_1_11(tb_dmem_read_resp_data[1][11]),
		.dmem_read_resp_data_1_12(tb_dmem_read_resp_data[1][12]),
		.dmem_read_resp_data_1_13(tb_dmem_read_resp_data[1][13]),
		.dmem_read_resp_data_1_14(tb_dmem_read_resp_data[1][14]),
		.dmem_read_resp_data_1_15(tb_dmem_read_resp_data[1][15]),
		.dmem_read_resp_data_1_16(tb_dmem_read_resp_data[1][16]),
		.dmem_read_resp_data_1_17(tb_dmem_read_resp_data[1][17]),
		.dmem_read_resp_data_1_18(tb_dmem_read_resp_data[1][18]),
		.dmem_read_resp_data_1_19(tb_dmem_read_resp_data[1][19]),
		.dmem_read_resp_data_1_20(tb_dmem_read_resp_data[1][20]),
		.dmem_read_resp_data_1_21(tb_dmem_read_resp_data[1][21]),
		.dmem_read_resp_data_1_22(tb_dmem_read_resp_data[1][22]),
		.dmem_read_resp_data_1_23(tb_dmem_read_resp_data[1][23]),
		.dmem_read_resp_data_1_24(tb_dmem_read_resp_data[1][24]),
		.dmem_read_resp_data_1_25(tb_dmem_read_resp_data[1][25]),
		.dmem_read_resp_data_1_26(tb_dmem_read_resp_data[1][26]),
		.dmem_read_resp_data_1_27(tb_dmem_read_resp_data[1][27]),
		.dmem_read_resp_data_1_28(tb_dmem_read_resp_data[1][28]),
		.dmem_read_resp_data_1_29(tb_dmem_read_resp_data[1][29]),
		.dmem_read_resp_data_1_30(tb_dmem_read_resp_data[1][30]),
		.dmem_read_resp_data_1_31(tb_dmem_read_resp_data[1][31]),

	    // dmem write req:
		.dmem_write_req_valid(DUT_dmem_write_req_valid),
		.dmem_write_req_block_addr(DUT_dmem_write_req_block_addr),
		// .dmem_write_req_data(DUT_dmem_write_req_data),
		.dmem_write_req_data_0_0(DUT_dmem_write_req_data[0][0]),
		.dmem_write_req_data_0_1(DUT_dmem_write_req_data[0][1]),
		.dmem_write_req_data_0_2(DUT_dmem_write_req_data[0][2]),
		.dmem_write_req_data_0_3(DUT_dmem_write_req_data[0][3]),
		.dmem_write_req_data_0_4(DUT_dmem_write_req_data[0][4]),
		.dmem_write_req_data_0_5(DUT_dmem_write_req_data[0][5]),
		.dmem_write_req_data_0_6(DUT_dmem_write_req_data[0][6]),
		.dmem_write_req_data_0_7(DUT_dmem_write_req_data[0][7]),
		.dmem_write_req_data_0_8(DUT_dmem_write_req_data[0][8]),
		.dmem_write_req_data_0_9(DUT_dmem_write_req_data[0][9]),
		.dmem_write_req_data_0_10(DUT_dmem_write_req_data[0][10]),
		.dmem_write_req_data_0_11(DUT_dmem_write_req_data[0][11]),
		.dmem_write_req_data_0_12(DUT_dmem_write_req_data[0][12]),
		.dmem_write_req_data_0_13(DUT_dmem_write_req_data[0][13]),
		.dmem_write_req_data_0_14(DUT_dmem_write_req_data[0][14]),
		.dmem_write_req_data_0_15(DUT_dmem_write_req_data[0][15]),
		.dmem_write_req_data_0_16(DUT_dmem_write_req_data[0][16]),
		.dmem_write_req_data_0_17(DUT_dmem_write_req_data[0][17]),
		.dmem_write_req_data_0_18(DUT_dmem_write_req_data[0][18]),
		.dmem_write_req_data_0_19(DUT_dmem_write_req_data[0][19]),
		.dmem_write_req_data_0_20(DUT_dmem_write_req_data[0][20]),
		.dmem_write_req_data_0_21(DUT_dmem_write_req_data[0][21]),
		.dmem_write_req_data_0_22(DUT_dmem_write_req_data[0][22]),
		.dmem_write_req_data_0_23(DUT_dmem_write_req_data[0][23]),
		.dmem_write_req_data_0_24(DUT_dmem_write_req_data[0][24]),
		.dmem_write_req_data_0_25(DUT_dmem_write_req_data[0][25]),
		.dmem_write_req_data_0_26(DUT_dmem_write_req_data[0][26]),
		.dmem_write_req_data_0_27(DUT_dmem_write_req_data[0][27]),
		.dmem_write_req_data_0_28(DUT_dmem_write_req_data[0][28]),
		.dmem_write_req_data_0_29(DUT_dmem_write_req_data[0][29]),
		.dmem_write_req_data_0_30(DUT_dmem_write_req_data[0][30]),
		.dmem_write_req_data_0_31(DUT_dmem_write_req_data[0][31]),
		.dmem_write_req_data_1_0(DUT_dmem_write_req_data[1][0]),
		.dmem_write_req_data_1_1(DUT_dmem_write_req_data[1][1]),
		.dmem_write_req_data_1_2(DUT_dmem_write_req_data[1][2]),
		.dmem_write_req_data_1_3(DUT_dmem_write_req_data[1][3]),
		.dmem_write_req_data_1_4(DUT_dmem_write_req_data[1][4]),
		.dmem_write_req_data_1_5(DUT_dmem_write_req_data[1][5]),
		.dmem_write_req_data_1_6(DUT_dmem_write_req_data[1][6]),
		.dmem_write_req_data_1_7(DUT_dmem_write_req_data[1][7]),
		.dmem_write_req_data_1_8(DUT_dmem_write_req_data[1][8]),
		.dmem_write_req_data_1_9(DUT_dmem_write_req_data[1][9]),
		.dmem_write_req_data_1_10(DUT_dmem_write_req_data[1][10]),
		.dmem_write_req_data_1_11(DUT_dmem_write_req_data[1][11]),
		.dmem_write_req_data_1_12(DUT_dmem_write_req_data[1][12]),
		.dmem_write_req_data_1_13(DUT_dmem_write_req_data[1][13]),
		.dmem_write_req_data_1_14(DUT_dmem_write_req_data[1][14]),
		.dmem_write_req_data_1_15(DUT_dmem_write_req_data[1][15]),
		.dmem_write_req_data_1_16(DUT_dmem_write_req_data[1][16]),
		.dmem_write_req_data_1_17(DUT_dmem_write_req_data[1][17]),
		.dmem_write_req_data_1_18(DUT_dmem_write_req_data[1][18]),
		.dmem_write_req_data_1_19(DUT_dmem_write_req_data[1][19]),
		.dmem_write_req_data_1_20(DUT_dmem_write_req_data[1][20]),
		.dmem_write_req_data_1_21(DUT_dmem_write_req_data[1][21]),
		.dmem_write_req_data_1_22(DUT_dmem_write_req_data[1][22]),
		.dmem_write_req_data_1_23(DUT_dmem_write_req_data[1][23]),
		.dmem_write_req_data_1_24(DUT_dmem_write_req_data[1][24]),
		.dmem_write_req_data_1_25(DUT_dmem_write_req_data[1][25]),
		.dmem_write_req_data_1_26(DUT_dmem_write_req_data[1][26]),
		.dmem_write_req_data_1_27(DUT_dmem_write_req_data[1][27]),
		.dmem_write_req_data_1_28(DUT_dmem_write_req_data[1][28]),
		.dmem_write_req_data_1_29(DUT_dmem_write_req_data[1][29]),
		.dmem_write_req_data_1_30(DUT_dmem_write_req_data[1][30]),
		.dmem_write_req_data_1_31(DUT_dmem_write_req_data[1][31]),

		.dmem_write_req_slow_down(tb_dmem_write_req_slow_down),

	    //////////////
	    // flushed: //
	    //////////////

		.flushed(DUT_flushed)
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

		if (expected_dcache_read_req_blocked !== DUT_dcache_read_req_blocked) begin
			$display("TB ERROR: expected_dcache_read_req_blocked (%h) != DUT_dcache_read_req_blocked (%h)",
				expected_dcache_read_req_blocked, DUT_dcache_read_req_blocked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_resp_valid !== DUT_dcache_read_resp_valid) begin
			$display("TB ERROR: expected_dcache_read_resp_valid (%h) != DUT_dcache_read_resp_valid (%h)",
				expected_dcache_read_resp_valid, DUT_dcache_read_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_resp_LQ_index !== DUT_dcache_read_resp_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_resp_LQ_index (%h) != DUT_dcache_read_resp_LQ_index (%h)",
				expected_dcache_read_resp_LQ_index, DUT_dcache_read_resp_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_resp_data !== DUT_dcache_read_resp_data) begin
			$display("TB ERROR: expected_dcache_read_resp_data (%h) != DUT_dcache_read_resp_data (%h)",
				expected_dcache_read_resp_data, DUT_dcache_read_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_blocked !== DUT_dcache_write_req_blocked) begin
			$display("TB ERROR: expected_dcache_write_req_blocked (%h) != DUT_dcache_write_req_blocked (%h)",
				expected_dcache_write_req_blocked, DUT_dcache_write_req_blocked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_inv_valid !== DUT_dcache_inv_valid) begin
			$display("TB ERROR: expected_dcache_inv_valid (%h) != DUT_dcache_inv_valid (%h)",
				expected_dcache_inv_valid, DUT_dcache_inv_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_inv_block_addr !== DUT_dcache_inv_block_addr) begin
			$display("TB ERROR: expected_dcache_inv_block_addr (%h) != DUT_dcache_inv_block_addr (%h)",
				expected_dcache_inv_block_addr, DUT_dcache_inv_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_req_valid !== DUT_dmem_read_req_valid) begin
			$display("TB ERROR: expected_dmem_read_req_valid (%h) != DUT_dmem_read_req_valid (%h)",
				expected_dmem_read_req_valid, DUT_dmem_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_read_req_block_addr !== DUT_dmem_read_req_block_addr) begin
			$display("TB ERROR: expected_dmem_read_req_block_addr (%h) != DUT_dmem_read_req_block_addr (%h)",
				expected_dmem_read_req_block_addr, DUT_dmem_read_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_valid !== DUT_dmem_write_req_valid) begin
			$display("TB ERROR: expected_dmem_write_req_valid (%h) != DUT_dmem_write_req_valid (%h)",
				expected_dmem_write_req_valid, DUT_dmem_write_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_block_addr !== DUT_dmem_write_req_block_addr) begin
			$display("TB ERROR: expected_dmem_write_req_block_addr (%h) != DUT_dmem_write_req_block_addr (%h)",
				expected_dmem_write_req_block_addr, DUT_dmem_write_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem_write_req_data !== DUT_dmem_write_req_data) begin
			$display("TB ERROR: expected_dmem_write_req_data (%h) != DUT_dmem_write_req_data (%h)",
				expected_dmem_write_req_data, DUT_dmem_write_req_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_flushed !== DUT_flushed) begin
			$display("TB ERROR: expected_flushed (%h) != DUT_flushed (%h)",
				expected_flushed, DUT_flushed);
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
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		tb_dcache_read_req_valid = 1'b0;
		tb_dcache_read_req_LQ_index = LQ_index_t'(0);
		tb_dcache_read_req_addr = 14'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 14'h0;
		tb_dcache_write_req_data = 32'h0;
		tb_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		tb_dcache_read_kill_0_valid = 1'b0;
		tb_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		tb_dcache_read_kill_1_valid = 1'b0;
		tb_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		tb_dcache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
	    // dmem read resp:
		tb_dmem_read_resp_valid = 1'b0;
		tb_dmem_read_resp_block_addr = 13'h0;
		tb_dmem_read_resp_data = {32'hdeadbeef, 32'hdeadbeef};
	    // dmem write req:
		tb_dmem_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		expected_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		expected_dcache_read_resp_valid = 1'b0;
		expected_dcache_read_resp_LQ_index = LQ_index_t'(0);
		expected_dcache_read_resp_data = 32'h0;
	    // write req interface:
		expected_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		expected_dcache_inv_valid = 1'b0;
		expected_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
		expected_dmem_read_req_valid = 1'b0;
		expected_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		expected_dmem_write_req_valid = 1'b0;
		expected_dmem_write_req_block_addr = 13'h0;
		expected_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		expected_flushed = 1'b0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		tb_dcache_read_req_valid = 1'b0;
		tb_dcache_read_req_LQ_index = LQ_index_t'(0);
		tb_dcache_read_req_addr = 14'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 14'h0;
		tb_dcache_write_req_data = 32'h0;
		tb_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		tb_dcache_read_kill_0_valid = 1'b0;
		tb_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		tb_dcache_read_kill_1_valid = 1'b0;
		tb_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		tb_dcache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
	    // dmem read resp:
		tb_dmem_read_resp_valid = 1'b0;
		tb_dmem_read_resp_block_addr = 13'h0;
		tb_dmem_read_resp_data = {32'hdeadbeef, 32'hdeadbeef};
	    // dmem write req:
		tb_dmem_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		expected_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		expected_dcache_read_resp_valid = 1'b0;
		expected_dcache_read_resp_LQ_index = LQ_index_t'(0);
		expected_dcache_read_resp_data = 32'h0;
	    // write req interface:
		expected_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		expected_dcache_inv_valid = 1'b0;
		expected_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
		expected_dmem_read_req_valid = 1'b0;
		expected_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		expected_dmem_write_req_valid = 1'b0;
		expected_dmem_write_req_block_addr = 13'h0;
		expected_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		expected_flushed = 1'b0;

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
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		tb_dcache_read_req_valid = 1'b0;
		tb_dcache_read_req_LQ_index = LQ_index_t'(0);
		tb_dcache_read_req_addr = 14'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 14'h0;
		tb_dcache_write_req_data = 32'h0;
		tb_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
		tb_dcache_read_kill_0_valid = 1'b0;
		tb_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		tb_dcache_read_kill_1_valid = 1'b0;
		tb_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    // halt interface:
		tb_dcache_halt = 1'b0;
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
	    // dmem read resp:
		tb_dmem_read_resp_valid = 1'b0;
		tb_dmem_read_resp_block_addr = 13'h0;
		tb_dmem_read_resp_data = {32'hdeadbeef, 32'hdeadbeef};
	    // dmem write req:
		tb_dmem_write_req_slow_down = 1'b0;
	    //////////////
	    // flushed: //
	    //////////////

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    /////////////////////
	    // core interface: //
	    /////////////////////
	    // read req interface:
		expected_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
		expected_dcache_read_resp_valid = 1'b0;
		expected_dcache_read_resp_LQ_index = LQ_index_t'(0);
		expected_dcache_read_resp_data = 32'h0;
	    // write req interface:
		expected_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    // invalidation interface:
		expected_dcache_inv_valid = 1'b0;
		expected_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    ////////////////////
	    // mem interface: //
	    ////////////////////
	    // dmem read req:
		expected_dmem_read_req_valid = 1'b0;
		expected_dmem_read_req_block_addr = 13'h0;
	    // dmem read resp:
	    // dmem write req:
		expected_dmem_write_req_valid = 1'b0;
		expected_dmem_write_req_block_addr = 13'h0;
		expected_dmem_write_req_data = {32'h0, 32'h0};
	    //////////////
	    // flushed: //
	    //////////////
		expected_flushed = 1'b0;

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

