/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: bus_controller_tb.sv
    Description: 
        Testbench for bus_controller module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module bus_controller_tb ();

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

    //////////////////////////////////////////
    // data bus request/response interface: //
    //////////////////////////////////////////
        // asynchronous, non-blocking interface

    // dbus0 req:
	logic tb_dbus0_req_valid;
	block_addr_t tb_dbus0_req_block_addr;
	logic tb_dbus0_req_exclusive;
	MOESI_state_t tb_dbus0_req_curr_state;

    // dbus0 resp:
	logic DUT_dbus0_resp_valid, expected_dbus0_resp_valid;
	block_addr_t DUT_dbus0_resp_block_addr, expected_dbus0_resp_block_addr;
	word_t [1:0] DUT_dbus0_resp_data, expected_dbus0_resp_data;
	logic DUT_dbus0_resp_need_block, expected_dbus0_resp_need_block;
	MOESI_state_t DUT_dbus0_resp_new_state, expected_dbus0_resp_new_state;

    // dbus1 req:
	logic tb_dbus1_req_valid;
	block_addr_t tb_dbus1_req_block_addr;
	logic tb_dbus1_req_exclusive;
	MOESI_state_t tb_dbus1_req_curr_state;

    // dbus1 resp:
	logic DUT_dbus1_resp_valid, expected_dbus1_resp_valid;
	block_addr_t DUT_dbus1_resp_block_addr, expected_dbus1_resp_block_addr;
	word_t [1:0] DUT_dbus1_resp_data, expected_dbus1_resp_data;
	logic DUT_dbus1_resp_need_block, expected_dbus1_resp_need_block;
	MOESI_state_t DUT_dbus1_resp_new_state, expected_dbus1_resp_new_state;

    ///////////////////////////////////////
    // snoop request/response interface: //
    ///////////////////////////////////////

    // snoop0 req:
	logic DUT_snoop0_req_valid, expected_snoop0_req_valid;
	block_addr_t DUT_snoop0_req_block_addr, expected_snoop0_req_block_addr;
	logic DUT_snoop0_req_exclusive, expected_snoop0_req_exclusive;
	MOESI_state_t DUT_snoop0_req_curr_state, expected_snoop0_req_curr_state;

    // snoop0 resp:
	logic tb_snoop0_resp_valid;
	block_addr_t tb_snoop0_resp_block_addr;
	word_t [1:0] tb_snoop0_resp_data;
	logic tb_snoop0_resp_present;
	logic tb_snoop0_resp_need_block;
	MOESI_state_t tb_snoop0_resp_new_state;

    // snoop1 req:
	logic DUT_snoop1_req_valid, expected_snoop1_req_valid;
	block_addr_t DUT_snoop1_req_block_addr, expected_snoop1_req_block_addr;
	logic DUT_snoop1_req_exclusive, expected_snoop1_req_exclusive;
	MOESI_state_t DUT_snoop1_req_curr_state, expected_snoop1_req_curr_state;

    // snoop1 resp:
	logic tb_snoop1_resp_valid;
	block_addr_t tb_snoop1_resp_block_addr;
	word_t [1:0] tb_snoop1_resp_data;
	logic tb_snoop1_resp_present;
	logic tb_snoop1_resp_need_block;
	MOESI_state_t tb_snoop1_resp_new_state;

    ///////////////////////////////
    // mem controller interface: //
    ///////////////////////////////

    // dmem0 read req:
	logic DUT_dmem0_read_req_valid, expected_dmem0_read_req_valid;
	block_addr_t DUT_dmem0_read_req_block_addr, expected_dmem0_read_req_block_addr;

    // dmem0 read resp:
	logic tb_dmem0_read_resp_valid;
	word_t [1:0] tb_dmem0_read_resp_data;

    // dmem1 read req:
	logic DUT_dmem1_read_req_valid, expected_dmem1_read_req_valid;
	block_addr_t DUT_dmem1_read_req_block_addr, expected_dmem1_read_req_block_addr;

    // dmem1 read resp:
	logic tb_dmem1_read_resp_valid;
	word_t [1:0] tb_dmem1_read_resp_data;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	bus_controller DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	        // asynchronous, non-blocking interface

	    // dbus0 req:
		.dbus0_req_valid(tb_dbus0_req_valid),
		.dbus0_req_block_addr(tb_dbus0_req_block_addr),
		.dbus0_req_exclusive(tb_dbus0_req_exclusive),
		.dbus0_req_curr_state(tb_dbus0_req_curr_state),

	    // dbus0 resp:
		.dbus0_resp_valid(DUT_dbus0_resp_valid),
		.dbus0_resp_block_addr(DUT_dbus0_resp_block_addr),
		.dbus0_resp_data(DUT_dbus0_resp_data),
		.dbus0_resp_need_block(DUT_dbus0_resp_need_block),
		.dbus0_resp_new_state(DUT_dbus0_resp_new_state),

	    // dbus1 req:
		.dbus1_req_valid(tb_dbus1_req_valid),
		.dbus1_req_block_addr(tb_dbus1_req_block_addr),
		.dbus1_req_exclusive(tb_dbus1_req_exclusive),
		.dbus1_req_curr_state(tb_dbus1_req_curr_state),

	    // dbus1 resp:
		.dbus1_resp_valid(DUT_dbus1_resp_valid),
		.dbus1_resp_block_addr(DUT_dbus1_resp_block_addr),
		.dbus1_resp_data(DUT_dbus1_resp_data),
		.dbus1_resp_need_block(DUT_dbus1_resp_need_block),
		.dbus1_resp_new_state(DUT_dbus1_resp_new_state),

	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////

	    // snoop0 req:
		.snoop0_req_valid(DUT_snoop0_req_valid),
		.snoop0_req_block_addr(DUT_snoop0_req_block_addr),
		.snoop0_req_exclusive(DUT_snoop0_req_exclusive),
		.snoop0_req_curr_state(DUT_snoop0_req_curr_state),

	    // snoop0 resp:
		.snoop0_resp_valid(tb_snoop0_resp_valid),
		.snoop0_resp_block_addr(tb_snoop0_resp_block_addr),
		.snoop0_resp_data(tb_snoop0_resp_data),
		.snoop0_resp_present(tb_snoop0_resp_present),
		.snoop0_resp_need_block(tb_snoop0_resp_need_block),
		.snoop0_resp_new_state(tb_snoop0_resp_new_state),

	    // snoop1 req:
		.snoop1_req_valid(DUT_snoop1_req_valid),
		.snoop1_req_block_addr(DUT_snoop1_req_block_addr),
		.snoop1_req_exclusive(DUT_snoop1_req_exclusive),
		.snoop1_req_curr_state(DUT_snoop1_req_curr_state),

	    // snoop1 resp:
		.snoop1_resp_valid(tb_snoop1_resp_valid),
		.snoop1_resp_block_addr(tb_snoop1_resp_block_addr),
		.snoop1_resp_data(tb_snoop1_resp_data),
		.snoop1_resp_present(tb_snoop1_resp_present),
		.snoop1_resp_need_block(tb_snoop1_resp_need_block),
		.snoop1_resp_new_state(tb_snoop1_resp_new_state),

	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////

	    // dmem0 read req:
		.dmem0_read_req_valid(DUT_dmem0_read_req_valid),
		.dmem0_read_req_block_addr(DUT_dmem0_read_req_block_addr),

	    // dmem0 read resp:
		.dmem0_read_resp_valid(tb_dmem0_read_resp_valid),
		.dmem0_read_resp_data(tb_dmem0_read_resp_data),

	    // dmem1 read req:
		.dmem1_read_req_valid(DUT_dmem1_read_req_valid),
		.dmem1_read_req_block_addr(DUT_dmem1_read_req_block_addr),

	    // dmem1 read resp:
		.dmem1_read_resp_valid(tb_dmem1_read_resp_valid),
		.dmem1_read_resp_data(tb_dmem1_read_resp_data)
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

		if (expected_dbus0_resp_valid !== DUT_dbus0_resp_valid) begin
			$display("TB ERROR: expected_dbus0_resp_valid (%h) != DUT_dbus0_resp_valid (%h)",
				expected_dbus0_resp_valid, DUT_dbus0_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus0_resp_block_addr !== DUT_dbus0_resp_block_addr) begin
			$display("TB ERROR: expected_dbus0_resp_block_addr (%h) != DUT_dbus0_resp_block_addr (%h)",
				expected_dbus0_resp_block_addr, DUT_dbus0_resp_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus0_resp_data !== DUT_dbus0_resp_data) begin
			$display("TB ERROR: expected_dbus0_resp_data (%h) != DUT_dbus0_resp_data (%h)",
				expected_dbus0_resp_data, DUT_dbus0_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus0_resp_need_block !== DUT_dbus0_resp_need_block) begin
			$display("TB ERROR: expected_dbus0_resp_need_block (%h) != DUT_dbus0_resp_need_block (%h)",
				expected_dbus0_resp_need_block, DUT_dbus0_resp_need_block);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus0_resp_new_state !== DUT_dbus0_resp_new_state) begin
			$display("TB ERROR: expected_dbus0_resp_new_state (%h) != DUT_dbus0_resp_new_state (%h)",
				expected_dbus0_resp_new_state, DUT_dbus0_resp_new_state);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus1_resp_valid !== DUT_dbus1_resp_valid) begin
			$display("TB ERROR: expected_dbus1_resp_valid (%h) != DUT_dbus1_resp_valid (%h)",
				expected_dbus1_resp_valid, DUT_dbus1_resp_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus1_resp_block_addr !== DUT_dbus1_resp_block_addr) begin
			$display("TB ERROR: expected_dbus1_resp_block_addr (%h) != DUT_dbus1_resp_block_addr (%h)",
				expected_dbus1_resp_block_addr, DUT_dbus1_resp_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus1_resp_data !== DUT_dbus1_resp_data) begin
			$display("TB ERROR: expected_dbus1_resp_data (%h) != DUT_dbus1_resp_data (%h)",
				expected_dbus1_resp_data, DUT_dbus1_resp_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus1_resp_need_block !== DUT_dbus1_resp_need_block) begin
			$display("TB ERROR: expected_dbus1_resp_need_block (%h) != DUT_dbus1_resp_need_block (%h)",
				expected_dbus1_resp_need_block, DUT_dbus1_resp_need_block);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dbus1_resp_new_state !== DUT_dbus1_resp_new_state) begin
			$display("TB ERROR: expected_dbus1_resp_new_state (%h) != DUT_dbus1_resp_new_state (%h)",
				expected_dbus1_resp_new_state, DUT_dbus1_resp_new_state);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop0_req_valid !== DUT_snoop0_req_valid) begin
			$display("TB ERROR: expected_snoop0_req_valid (%h) != DUT_snoop0_req_valid (%h)",
				expected_snoop0_req_valid, DUT_snoop0_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop0_req_block_addr !== DUT_snoop0_req_block_addr) begin
			$display("TB ERROR: expected_snoop0_req_block_addr (%h) != DUT_snoop0_req_block_addr (%h)",
				expected_snoop0_req_block_addr, DUT_snoop0_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop0_req_exclusive !== DUT_snoop0_req_exclusive) begin
			$display("TB ERROR: expected_snoop0_req_exclusive (%h) != DUT_snoop0_req_exclusive (%h)",
				expected_snoop0_req_exclusive, DUT_snoop0_req_exclusive);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop0_req_curr_state !== DUT_snoop0_req_curr_state) begin
			$display("TB ERROR: expected_snoop0_req_curr_state (%h) != DUT_snoop0_req_curr_state (%h)",
				expected_snoop0_req_curr_state, DUT_snoop0_req_curr_state);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop1_req_valid !== DUT_snoop1_req_valid) begin
			$display("TB ERROR: expected_snoop1_req_valid (%h) != DUT_snoop1_req_valid (%h)",
				expected_snoop1_req_valid, DUT_snoop1_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop1_req_block_addr !== DUT_snoop1_req_block_addr) begin
			$display("TB ERROR: expected_snoop1_req_block_addr (%h) != DUT_snoop1_req_block_addr (%h)",
				expected_snoop1_req_block_addr, DUT_snoop1_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop1_req_exclusive !== DUT_snoop1_req_exclusive) begin
			$display("TB ERROR: expected_snoop1_req_exclusive (%h) != DUT_snoop1_req_exclusive (%h)",
				expected_snoop1_req_exclusive, DUT_snoop1_req_exclusive);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_snoop1_req_curr_state !== DUT_snoop1_req_curr_state) begin
			$display("TB ERROR: expected_snoop1_req_curr_state (%h) != DUT_snoop1_req_curr_state (%h)",
				expected_snoop1_req_curr_state, DUT_snoop1_req_curr_state);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem0_read_req_valid !== DUT_dmem0_read_req_valid) begin
			$display("TB ERROR: expected_dmem0_read_req_valid (%h) != DUT_dmem0_read_req_valid (%h)",
				expected_dmem0_read_req_valid, DUT_dmem0_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem0_read_req_block_addr !== DUT_dmem0_read_req_block_addr) begin
			$display("TB ERROR: expected_dmem0_read_req_block_addr (%h) != DUT_dmem0_read_req_block_addr (%h)",
				expected_dmem0_read_req_block_addr, DUT_dmem0_read_req_block_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem1_read_req_valid !== DUT_dmem1_read_req_valid) begin
			$display("TB ERROR: expected_dmem1_read_req_valid (%h) != DUT_dmem1_read_req_valid (%h)",
				expected_dmem1_read_req_valid, DUT_dmem1_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dmem1_read_req_block_addr !== DUT_dmem1_read_req_block_addr) begin
			$display("TB ERROR: expected_dmem1_read_req_block_addr (%h) != DUT_dmem1_read_req_block_addr (%h)",
				expected_dmem1_read_req_block_addr, DUT_dmem1_read_req_block_addr);
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
	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	    // dbus0 req:
		tb_dbus0_req_valid = 1'b0;
		tb_dbus0_req_block_addr = 13'h0;
		tb_dbus0_req_exclusive = 1'b0;
		tb_dbus0_req_curr_state = MOESI_I;
	    // dbus0 resp:
	    // dbus1 req:
		tb_dbus1_req_valid = 1'b0;
		tb_dbus1_req_block_addr = 13'h0;
		tb_dbus1_req_exclusive = 1'b0;
		tb_dbus1_req_curr_state = MOESI_I;
	    // dbus1 resp:
	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////
	    // snoop0 req:
	    // snoop0 resp:
		tb_snoop0_resp_valid = 1'b0;
		tb_snoop0_resp_block_addr = 13'h0;
		tb_snoop0_resp_data = {32'h0, 32'h0};
		tb_snoop0_resp_present = 1'b0;
		tb_snoop0_resp_need_block = 1'b0;
		tb_snoop0_resp_new_state = MOESI_I;
	    // snoop1 req:
	    // snoop1 resp:
		tb_snoop1_resp_valid = 1'b0;
		tb_snoop1_resp_block_addr = 13'h0;
		tb_snoop1_resp_data = {32'h0, 32'h0};
		tb_snoop1_resp_present = 1'b0;
		tb_snoop1_resp_need_block = 1'b0;
		tb_snoop1_resp_new_state = MOESI_I;
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
	    // dmem0 read req:
	    // dmem0 read resp:
		tb_dmem0_read_resp_valid = 1'b0;
		tb_dmem0_read_resp_data = {32'h0, 32'h0};
	    // dmem1 read req:
	    // dmem1 read resp:
		tb_dmem1_read_resp_valid = 1'b0;
		tb_dmem1_read_resp_data = {32'h0, 32'h0};

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	    // dbus0 req:
	    // dbus0 resp:
		expected_dbus0_resp_valid = 1'b0;
		expected_dbus0_resp_block_addr = 13'h0;
		expected_dbus0_resp_data = {32'h0, 32'h0};
		expected_dbus0_resp_need_block = 1'b0;
		expected_dbus0_resp_new_state = MOESI_I;
	    // dbus1 req:
	    // dbus1 resp:
		expected_dbus1_resp_valid = 1'b0;
		expected_dbus1_resp_block_addr = 13'h0;
		expected_dbus1_resp_data = {32'h0, 32'h0};
		expected_dbus1_resp_need_block = 1'b0;
		expected_dbus1_resp_new_state = MOESI_I;
	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////
	    // snoop0 req:
		expected_snoop0_req_valid = 1'b0;
		expected_snoop0_req_block_addr = 13'h0;
		expected_snoop0_req_exclusive = 1'b0;
		expected_snoop0_req_curr_state = MOESI_I;
	    // snoop0 resp:
	    // snoop1 req:
		expected_snoop1_req_valid = 1'b0;
		expected_snoop1_req_block_addr = 13'h0;
		expected_snoop1_req_exclusive = 1'b0;
		expected_snoop1_req_curr_state = MOESI_I;
	    // snoop1 resp:
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
	    // dmem0 read req:
		expected_dmem0_read_req_valid = 1'b0;
		expected_dmem0_read_req_block_addr = 13'h0;
	    // dmem0 read resp:
	    // dmem1 read req:
		expected_dmem1_read_req_valid = 1'b0;
		expected_dmem1_read_req_block_addr = 13'h0;
	    // dmem1 read resp:

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	    // dbus0 req:
		tb_dbus0_req_valid = 1'b0;
		tb_dbus0_req_block_addr = 13'h0;
		tb_dbus0_req_exclusive = 1'b0;
		tb_dbus0_req_curr_state = MOESI_I;
	    // dbus0 resp:
	    // dbus1 req:
		tb_dbus1_req_valid = 1'b0;
		tb_dbus1_req_block_addr = 13'h0;
		tb_dbus1_req_exclusive = 1'b0;
		tb_dbus1_req_curr_state = MOESI_I;
	    // dbus1 resp:
	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////
	    // snoop0 req:
	    // snoop0 resp:
		tb_snoop0_resp_valid = 1'b0;
		tb_snoop0_resp_block_addr = 13'h0;
		tb_snoop0_resp_data = {32'h0, 32'h0};
		tb_snoop0_resp_present = 1'b0;
		tb_snoop0_resp_need_block = 1'b0;
		tb_snoop0_resp_new_state = MOESI_I;
	    // snoop1 req:
	    // snoop1 resp:
		tb_snoop1_resp_valid = 1'b0;
		tb_snoop1_resp_block_addr = 13'h0;
		tb_snoop1_resp_data = {32'h0, 32'h0};
		tb_snoop1_resp_present = 1'b0;
		tb_snoop1_resp_need_block = 1'b0;
		tb_snoop1_resp_new_state = MOESI_I;
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
	    // dmem0 read req:
	    // dmem0 read resp:
		tb_dmem0_read_resp_valid = 1'b0;
		tb_dmem0_read_resp_data = {32'h0, 32'h0};
	    // dmem1 read req:
	    // dmem1 read resp:
		tb_dmem1_read_resp_valid = 1'b0;
		tb_dmem1_read_resp_data = {32'h0, 32'h0};

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	    // dbus0 req:
	    // dbus0 resp:
		expected_dbus0_resp_valid = 1'b0;
		expected_dbus0_resp_block_addr = 13'h0;
		expected_dbus0_resp_data = {32'h0, 32'h0};
		expected_dbus0_resp_need_block = 1'b0;
		expected_dbus0_resp_new_state = MOESI_I;
	    // dbus1 req:
	    // dbus1 resp:
		expected_dbus1_resp_valid = 1'b0;
		expected_dbus1_resp_block_addr = 13'h0;
		expected_dbus1_resp_data = {32'h0, 32'h0};
		expected_dbus1_resp_need_block = 1'b0;
		expected_dbus1_resp_new_state = MOESI_I;
	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////
	    // snoop0 req:
		expected_snoop0_req_valid = 1'b0;
		expected_snoop0_req_block_addr = 13'h0;
		expected_snoop0_req_exclusive = 1'b0;
		expected_snoop0_req_curr_state = MOESI_I;
	    // snoop0 resp:
	    // snoop1 req:
		expected_snoop1_req_valid = 1'b0;
		expected_snoop1_req_block_addr = 13'h0;
		expected_snoop1_req_exclusive = 1'b0;
		expected_snoop1_req_curr_state = MOESI_I;
	    // snoop1 resp:
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
	    // dmem0 read req:
		expected_dmem0_read_req_valid = 1'b0;
		expected_dmem0_read_req_block_addr = 13'h0;
	    // dmem0 read resp:
	    // dmem1 read req:
		expected_dmem1_read_req_valid = 1'b0;
		expected_dmem1_read_req_block_addr = 13'h0;
	    // dmem1 read resp:

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
	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	    // dbus0 req:
		tb_dbus0_req_valid = 1'b0;
		tb_dbus0_req_block_addr = 13'h0;
		tb_dbus0_req_exclusive = 1'b0;
		tb_dbus0_req_curr_state = MOESI_I;
	    // dbus0 resp:
	    // dbus1 req:
		tb_dbus1_req_valid = 1'b0;
		tb_dbus1_req_block_addr = 13'h0;
		tb_dbus1_req_exclusive = 1'b0;
		tb_dbus1_req_curr_state = MOESI_I;
	    // dbus1 resp:
	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////
	    // snoop0 req:
	    // snoop0 resp:
		tb_snoop0_resp_valid = 1'b0;
		tb_snoop0_resp_block_addr = 13'h0;
		tb_snoop0_resp_data = {32'h0, 32'h0};
		tb_snoop0_resp_present = 1'b0;
		tb_snoop0_resp_need_block = 1'b0;
		tb_snoop0_resp_new_state = MOESI_I;
	    // snoop1 req:
	    // snoop1 resp:
		tb_snoop1_resp_valid = 1'b0;
		tb_snoop1_resp_block_addr = 13'h0;
		tb_snoop1_resp_data = {32'h0, 32'h0};
		tb_snoop1_resp_present = 1'b0;
		tb_snoop1_resp_need_block = 1'b0;
		tb_snoop1_resp_new_state = MOESI_I;
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
	    // dmem0 read req:
	    // dmem0 read resp:
		tb_dmem0_read_resp_valid = 1'b0;
		tb_dmem0_read_resp_data = {32'h0, 32'h0};
	    // dmem1 read req:
	    // dmem1 read resp:
		tb_dmem1_read_resp_valid = 1'b0;
		tb_dmem1_read_resp_data = {32'h0, 32'h0};

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    //////////////////////////////////////////
	    // data bus request/response interface: //
	    //////////////////////////////////////////
	    // dbus0 req:
	    // dbus0 resp:
		expected_dbus0_resp_valid = 1'b0;
		expected_dbus0_resp_block_addr = 13'h0;
		expected_dbus0_resp_data = {32'h0, 32'h0};
		expected_dbus0_resp_need_block = 1'b0;
		expected_dbus0_resp_new_state = MOESI_I;
	    // dbus1 req:
	    // dbus1 resp:
		expected_dbus1_resp_valid = 1'b0;
		expected_dbus1_resp_block_addr = 13'h0;
		expected_dbus1_resp_data = {32'h0, 32'h0};
		expected_dbus1_resp_need_block = 1'b0;
		expected_dbus1_resp_new_state = MOESI_I;
	    ///////////////////////////////////////
	    // snoop request/response interface: //
	    ///////////////////////////////////////
	    // snoop0 req:
		expected_snoop0_req_valid = 1'b0;
		expected_snoop0_req_block_addr = 13'h0;
		expected_snoop0_req_exclusive = 1'b0;
		expected_snoop0_req_curr_state = MOESI_I;
	    // snoop0 resp:
	    // snoop1 req:
		expected_snoop1_req_valid = 1'b0;
		expected_snoop1_req_block_addr = 13'h0;
		expected_snoop1_req_exclusive = 1'b0;
		expected_snoop1_req_curr_state = MOESI_I;
	    // snoop1 resp:
	    ///////////////////////////////
	    // mem controller interface: //
	    ///////////////////////////////
	    // dmem0 read req:
		expected_dmem0_read_req_valid = 1'b0;
		expected_dmem0_read_req_block_addr = 13'h0;
	    // dmem0 read resp:
	    // dmem1 read req:
		expected_dmem1_read_req_valid = 1'b0;
		expected_dmem1_read_req_block_addr = 13'h0;
	    // dmem1 read resp:

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

