/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: snoop_dcache_tb.sv
    Description: 
        Testbench for snoop_dcache module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module snoop_dcache_tb ();

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
        // doubled the interface at LSQ for eviction invalidations and snoop invalidations
	logic DUT_dcache_inv_valid, expected_dcache_inv_valid;
	block_addr_t DUT_dcache_inv_block_addr, expected_dcache_inv_block_addr;
	logic DUT_dcache_evict_valid, expected_dcache_evict_valid;
	block_addr_t DUT_dcache_evict_block_addr, expected_dcache_evict_block_addr;

    // halt interface:
	logic tb_dcache_halt;

    ///////////////////////////////
    // bus controller interface: //
    ///////////////////////////////
        // asynchronous, non-blocking interface

    // dbus req:
	logic DUT_dbus_req_valid, expected_dbus_req_valid;
	block_addr_t DUT_dbus_req_block_addr, expected_dbus_req_block_addr;
	logic DUT_dbus_req_exclusive, expected_dbus_req_exclusive;
	MOESI_state_t DUT_dbus_req_curr_state, expected_dbus_req_curr_state;

    // dbus resp:
	logic tb_dbus_resp_valid;
	block_addr_t tb_dbus_resp_block_addr;
	word_t [1:0] tb_dbus_resp_data;
	logic tb_dbus_resp_need_block;
	MOESI_state_t tb_dbus_resp_new_state;

    // snoop req:
	logic tb_snoop_req_valid;
	block_addr_t tb_snoop_req_block_addr;
	logic tb_snoop_req_exclusive;
	MOESI_state_t tb_snoop_req_curr_state;

    // snoop resp:
	logic DUT_snoop_resp_valid, expected_snoop_resp_valid;
	block_addr_t DUT_snoop_resp_block_addr, expected_snoop_resp_block_addr;
	word_t [1:0] DUT_snoop_resp_data, expected_snoop_resp_data;
	logic DUT_snoop_resp_present, expected_snoop_resp_present;
	logic DUT_snoop_resp_need_block, expected_snoop_resp_need_block;
	MOESI_state_t DUT_snoop_resp_new_state, expected_snoop_resp_new_state;

    ///////////////////////////////
    // mem controller interface: //
    ///////////////////////////////

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

	snoop_dcache DUT (
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
	        // doubled the interface at LSQ for eviction invalidations and snoop invalidations
		.dcache_inv_valid(DUT_dcache_inv_valid),
		.dcache_inv_block_addr(DUT_dcache_inv_block_addr),
		.dcache_evict_valid(DUT_dcache_evict_valid),
		.dcache_evict_block_addr(DUT_dcache_evict_block_addr),

	    // halt interface:
		.dcache_halt(tb_dcache_halt),

	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	        // asynchronous, non-blocking interface

	    // dbus req:
		.dbus_req_valid(DUT_dbus_req_valid),
		.dbus_req_block_addr(DUT_dbus_req_block_addr),
		.dbus_req_exclusive(DUT_dbus_req_exclusive),
		.dbus_req_curr_state(DUT_dbus_req_curr_state),

	    // dbus resp:
		.dbus_resp_valid(tb_dbus_resp_valid),
		.dbus_resp_block_addr(tb_dbus_resp_block_addr),
		.dbus_resp_data(tb_dbus_resp_data),
		.dbus_resp_need_block(tb_dbus_resp_need_block),
		.dbus_resp_new_state(tb_dbus_resp_new_state),

	    // snoop req:
		.snoop_req_valid(tb_snoop_req_valid),
		.snoop_req_block_addr(tb_snoop_req_block_addr),
		.snoop_req_exclusive(tb_snoop_req_exclusive),
		.snoop_req_curr_state(tb_snoop_req_curr_state),

	    // snoop resp:
		.snoop_resp_valid(DUT_snoop_resp_valid),
		.snoop_resp_block_addr(DUT_snoop_resp_block_addr),
		.snoop_resp_data(DUT_snoop_resp_data),
		.snoop_resp_present(DUT_snoop_resp_present),
		.snoop_resp_need_block(DUT_snoop_resp_need_block),
		.snoop_resp_new_state(DUT_snoop_resp_new_state),

	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////

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

		if (expected_dcache_evict_valid !== DUT_dcache_evict_valid) begin
			$display("TB ERROR: expected_dcache_evict_valid (%h) != DUT_dcache_evict_valid (%h)",
				expected_dcache_evict_valid, DUT_dcache_evict_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_evict_block_addr !== DUT_dcache_evict_block_addr) begin
			$display("TB ERROR: expected_dcache_evict_block_addr (%h) != DUT_dcache_evict_block_addr (%h)",
				expected_dcache_evict_block_addr, DUT_dcache_evict_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus_req_valid !== DUT_dbus_req_valid) begin
			$display("TB ERROR: expected_dbus_req_valid (%h) != DUT_dbus_req_valid (%h)",
				expected_dbus_req_valid, DUT_dbus_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus_req_block_addr !== DUT_dbus_req_block_addr) begin
			$display("TB ERROR: expected_dbus_req_block_addr (%h) != DUT_dbus_req_block_addr (%h)",
				expected_dbus_req_block_addr, DUT_dbus_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus_req_exclusive !== DUT_dbus_req_exclusive) begin
			$display("TB ERROR: expected_dbus_req_exclusive (%h) != DUT_dbus_req_exclusive (%h)",
				expected_dbus_req_exclusive, DUT_dbus_req_exclusive);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus_req_curr_state !== DUT_dbus_req_curr_state) begin
			$display("TB ERROR: expected_dbus_req_curr_state (%h) != DUT_dbus_req_curr_state (%h)",
				expected_dbus_req_curr_state, DUT_dbus_req_curr_state);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop_resp_valid !== DUT_snoop_resp_valid) begin
			$display("TB ERROR: expected_snoop_resp_valid (%h) != DUT_snoop_resp_valid (%h)",
				expected_snoop_resp_valid, DUT_snoop_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop_resp_block_addr !== DUT_snoop_resp_block_addr) begin
			$display("TB ERROR: expected_snoop_resp_block_addr (%h) != DUT_snoop_resp_block_addr (%h)",
				expected_snoop_resp_block_addr, DUT_snoop_resp_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop_resp_data !== DUT_snoop_resp_data) begin
			$display("TB ERROR: expected_snoop_resp_data (%h) != DUT_snoop_resp_data (%h)",
				expected_snoop_resp_data, DUT_snoop_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop_resp_present !== DUT_snoop_resp_present) begin
			$display("TB ERROR: expected_snoop_resp_present (%h) != DUT_snoop_resp_present (%h)",
				expected_snoop_resp_present, DUT_snoop_resp_present);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop_resp_need_block !== DUT_snoop_resp_need_block) begin
			$display("TB ERROR: expected_snoop_resp_need_block (%h) != DUT_snoop_resp_need_block (%h)",
				expected_snoop_resp_need_block, DUT_snoop_resp_need_block);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop_resp_new_state !== DUT_snoop_resp_new_state) begin
			$display("TB ERROR: expected_snoop_resp_new_state (%h) != DUT_snoop_resp_new_state (%h)",
				expected_snoop_resp_new_state, DUT_snoop_resp_new_state);
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
		tb_dcache_read_req_addr = 13'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 13'h0;
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
	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	    // dbus req:
	    // dbus resp:
		tb_dbus_resp_valid = 1'b0;
		tb_dbus_resp_block_addr = 13'h0;
		tb_dbus_resp_data = {32'h0, 32'h0};
		tb_dbus_resp_need_block = 1'b0;
		tb_dbus_resp_new_state = MOESI_I;
	    // snoop req:
		tb_snoop_req_valid = 1'b0;
		tb_snoop_req_block_addr = 13'h0;
		tb_snoop_req_exclusive = 1'b0;
		tb_snoop_req_curr_state = MOESI_I;
	    // snoop resp:
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
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
		expected_dcache_evict_valid = 1'b0;
		expected_dcache_evict_block_addr = 13'h0;
	    // halt interface:
	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	    // dbus req:
		expected_dbus_req_valid = 1'b0;
		expected_dbus_req_block_addr = 13'h0;
		expected_dbus_req_exclusive = 1'b0;
		expected_dbus_req_curr_state = MOESI_I;
	    // dbus resp:
	    // snoop req:
	    // snoop resp:
		expected_snoop_resp_valid = 1'b0;
		expected_snoop_resp_block_addr = 13'h0;
		expected_snoop_resp_data = {32'h0, 32'h0};
		expected_snoop_resp_present = 1'b0;
		expected_snoop_resp_need_block = 1'b0;
		expected_snoop_resp_new_state = MOESI_I;
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
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
		tb_dcache_read_req_addr = 13'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 13'h0;
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
	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	    // dbus req:
	    // dbus resp:
		tb_dbus_resp_valid = 1'b0;
		tb_dbus_resp_block_addr = 13'h0;
		tb_dbus_resp_data = {32'h0, 32'h0};
		tb_dbus_resp_need_block = 1'b0;
		tb_dbus_resp_new_state = MOESI_I;
	    // snoop req:
		tb_snoop_req_valid = 1'b0;
		tb_snoop_req_block_addr = 13'h0;
		tb_snoop_req_exclusive = 1'b0;
		tb_snoop_req_curr_state = MOESI_I;
	    // snoop resp:
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
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
		expected_dcache_evict_valid = 1'b0;
		expected_dcache_evict_block_addr = 13'h0;
	    // halt interface:
	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	    // dbus req:
		expected_dbus_req_valid = 1'b0;
		expected_dbus_req_block_addr = 13'h0;
		expected_dbus_req_exclusive = 1'b0;
		expected_dbus_req_curr_state = MOESI_I;
	    // dbus resp:
	    // snoop req:
	    // snoop resp:
		expected_snoop_resp_valid = 1'b0;
		expected_snoop_resp_block_addr = 13'h0;
		expected_snoop_resp_data = {32'h0, 32'h0};
		expected_snoop_resp_present = 1'b0;
		expected_snoop_resp_need_block = 1'b0;
		expected_snoop_resp_new_state = MOESI_I;
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
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
		tb_dcache_read_req_addr = 13'h0;
		tb_dcache_read_req_linked = 1'b0;
		tb_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    // write req interface:
		tb_dcache_write_req_valid = 1'b0;
		tb_dcache_write_req_addr = 13'h0;
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
	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	    // dbus req:
	    // dbus resp:
		tb_dbus_resp_valid = 1'b0;
		tb_dbus_resp_block_addr = 13'h0;
		tb_dbus_resp_data = {32'h0, 32'h0};
		tb_dbus_resp_need_block = 1'b0;
		tb_dbus_resp_new_state = MOESI_I;
	    // snoop req:
		tb_snoop_req_valid = 1'b0;
		tb_snoop_req_block_addr = 13'h0;
		tb_snoop_req_exclusive = 1'b0;
		tb_snoop_req_curr_state = MOESI_I;
	    // snoop resp:
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
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
		expected_dcache_evict_valid = 1'b0;
		expected_dcache_evict_block_addr = 13'h0;
	    // halt interface:
	    ///////////////////////////////
	    // bus controller interface: //
	    ///////////////////////////////
	    // dbus req:
		expected_dbus_req_valid = 1'b0;
		expected_dbus_req_block_addr = 13'h0;
		expected_dbus_req_exclusive = 1'b0;
		expected_dbus_req_curr_state = MOESI_I;
	    // dbus resp:
	    // snoop req:
	    // snoop resp:
		expected_snoop_resp_valid = 1'b0;
		expected_snoop_resp_block_addr = 13'h0;
		expected_snoop_resp_data = {32'h0, 32'h0};
		expected_snoop_resp_present = 1'b0;
		expected_snoop_resp_need_block = 1'b0;
		expected_snoop_resp_new_state = MOESI_I;
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
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

