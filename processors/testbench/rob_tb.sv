/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: rob_tb.sv
    Description: 
       Testbench for rob module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module rob_tb ();

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

    // full/empty
	logic DUT_full, expected_full;
	logic DUT_empty, expected_empty;

    // fetch unit interface
	logic DUT_fetch_unit_take_resolved, expected_fetch_unit_take_resolved;
	pc_t DUT_fetch_unit_resolved_PC, expected_fetch_unit_resolved_PC;

    // dispatch unit interface
    // dispatch @ tail
	ROB_index_t DUT_dispatch_unit_ROB_tail_index, expected_dispatch_unit_ROB_tail_index;
	logic tb_dispatch_unit_enqueue_valid;
	ROB_entry_t tb_dispatch_unit_enqueue_struct;
    // retire from head
	logic DUT_dispatch_unit_retire_valid, expected_dispatch_unit_retire_valid;
	phys_reg_tag_t DUT_dispatch_unit_retire_phys_reg_tag, expected_dispatch_unit_retire_phys_reg_tag;

    // complete bus interfaces
        // want ROB index for complete write
        // ROB doesn't need write tag but can use for assertion
	logic tb_complete_bus_0_valid;
	phys_reg_tag_t tb_complete_bus_0_dest_phys_reg_tag;
	ROB_index_t tb_complete_bus_0_ROB_index;
	logic tb_complete_bus_1_valid;
	phys_reg_tag_t tb_complete_bus_1_dest_phys_reg_tag;
	ROB_index_t tb_complete_bus_1_ROB_index;
	logic tb_complete_bus_2_valid;
	phys_reg_tag_t tb_complete_bus_2_dest_phys_reg_tag;
	ROB_index_t tb_complete_bus_2_ROB_index;

    // BRU interface
    // complete
	logic tb_BRU_complete_valid;
	ROB_index_t tb_BRU_complete_ROB_index;
    // restart info
	logic tb_BRU_restart_valid;
	ROB_index_t tb_BRU_restart_ROB_index;
	pc_t tb_BRU_restart_PC;
	checkpoint_column_t tb_BRU_restart_safe_column;

    // LQ interface
    // retire
	logic DUT_LQ_retire_valid, expected_LQ_retire_valid;
	ROB_index_t DUT_LQ_retire_ROB_index, expected_LQ_retire_ROB_index;
    // restart info
	logic tb_LQ_restart_valid;
	ROB_index_t tb_LQ_restart_ROB_index;

    // SQ interface
    // complete
	logic tb_SQ_complete_valid;
	ROB_index_t tb_SQ_complete_ROB_index;
    // retire
	logic DUT_SQ_retire_valid, expected_SQ_retire_valid;
	ROB_index_t DUT_SQ_retire_ROB_index, expected_SQ_retire_ROB_index;

    // restore interface
        // send restore command and check for success
	logic DUT_restore_checkpoint_valid, expected_restore_checkpoint_valid;
	logic DUT_restore_checkpoint_speculate_failed, expected_restore_checkpoint_speculate_failed;
	ROB_index_t DUT_restore_checkpoint_ROB_index, expected_restore_checkpoint_ROB_index;
	checkpoint_column_t DUT_restore_checkpoint_safe_column, expected_restore_checkpoint_safe_column;
	logic tb_restore_checkpoint_success;

    // revert interface
        // send revert command to dispatch unit
	logic DUT_revert_valid, expected_revert_valid;
	ROB_index_t DUT_revert_ROB_index, expected_revert_ROB_index;
	arch_reg_tag_t DUT_revert_arch_reg_tag, expected_revert_arch_reg_tag;
	phys_reg_tag_t DUT_revert_safe_phys_reg_tag, expected_revert_safe_phys_reg_tag;
	phys_reg_tag_t DUT_revert_speculated_phys_reg_tag, expected_revert_speculated_phys_reg_tag;

    // kill bus interface
        // send kill command to execution units
	logic DUT_kill_bus_valid, expected_kill_bus_valid;
	ROB_index_t DUT_kill_bus_ROB_index, expected_kill_bus_ROB_index;

    // core control interface
	logic DUT_core_control_restore_flush, expected_core_control_restore_flush;
	logic DUT_core_control_revert_stall, expected_core_control_revert_stall;
	logic DUT_core_control_halt_assert, expected_core_control_halt_assert;
        // for when halt instr retires

    // optional outputs:

    // ROB state
	ROB_state_t DUT_ROB_state_out, expected_ROB_state_out;

    // if complete is invalid
	logic DUT_invalid_complete, expected_invalid_complete;

    // current ROB capacity
	logic [LOG_ROB_DEPTH:0] DUT_ROB_capacity, expected_ROB_capacity;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	rob DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),


	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // full/empty
		.full(DUT_full),
		.empty(DUT_empty),

	    // fetch unit interface
		.fetch_unit_take_resolved(DUT_fetch_unit_take_resolved),
		.fetch_unit_resolved_PC(DUT_fetch_unit_resolved_PC),

	    // dispatch unit interface
	    // dispatch @ tail
		.dispatch_unit_ROB_tail_index(DUT_dispatch_unit_ROB_tail_index),
		.dispatch_unit_enqueue_valid(tb_dispatch_unit_enqueue_valid),
		.dispatch_unit_enqueue_struct(tb_dispatch_unit_enqueue_struct),
	    // retire from head
		.dispatch_unit_retire_valid(DUT_dispatch_unit_retire_valid),
		.dispatch_unit_retire_phys_reg_tag(DUT_dispatch_unit_retire_phys_reg_tag),

	    // complete bus interfaces
	        // want ROB index for complete write
	        // ROB doesn't need write tag but can use for assertion
		.complete_bus_0_valid(tb_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(tb_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_0_ROB_index(tb_complete_bus_0_ROB_index),
		.complete_bus_1_valid(tb_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(tb_complete_bus_1_dest_phys_reg_tag),
		.complete_bus_1_ROB_index(tb_complete_bus_1_ROB_index),
		.complete_bus_2_valid(tb_complete_bus_2_valid),
		.complete_bus_2_dest_phys_reg_tag(tb_complete_bus_2_dest_phys_reg_tag),
		.complete_bus_2_ROB_index(tb_complete_bus_2_ROB_index),

	    // BRU interface
	    // complete
		.BRU_complete_valid(tb_BRU_complete_valid),
		.BRU_complete_ROB_index(tb_BRU_complete_ROB_index),
	    // restart info
		.BRU_restart_valid(tb_BRU_restart_valid),
		.BRU_restart_ROB_index(tb_BRU_restart_ROB_index),
		.BRU_restart_PC(tb_BRU_restart_PC),
		.BRU_restart_safe_column(tb_BRU_restart_safe_column),

	    // LQ interface
	    // retire
		.LQ_retire_valid(DUT_LQ_retire_valid),
		.LQ_retire_ROB_index(DUT_LQ_retire_ROB_index),
	    // restart info
		.LQ_restart_valid(tb_LQ_restart_valid),
		.LQ_restart_ROB_index(tb_LQ_restart_ROB_index),

	    // SQ interface
	    // complete
		.SQ_complete_valid(tb_SQ_complete_valid),
		.SQ_complete_ROB_index(tb_SQ_complete_ROB_index),
	    // retire
		.SQ_retire_valid(DUT_SQ_retire_valid),
		.SQ_retire_ROB_index(DUT_SQ_retire_ROB_index),

	    // restore interface
	        // send restore command and check for success
		.restore_checkpoint_valid(DUT_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(DUT_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(DUT_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(DUT_restore_checkpoint_safe_column),
		.restore_checkpoint_success(tb_restore_checkpoint_success),

	    // revert interface
	        // send revert command to dispatch unit
		.revert_valid(DUT_revert_valid),
		.revert_ROB_index(DUT_revert_ROB_index),
		.revert_arch_reg_tag(DUT_revert_arch_reg_tag),
		.revert_safe_phys_reg_tag(DUT_revert_safe_phys_reg_tag),
		.revert_speculated_phys_reg_tag(DUT_revert_speculated_phys_reg_tag),

	    // kill bus interface
	        // send kill command to execution units
		.kill_bus_valid(DUT_kill_bus_valid),
		.kill_bus_ROB_index(DUT_kill_bus_ROB_index),

	    // core control interface
		.core_control_restore_flush(DUT_core_control_restore_flush),
		.core_control_revert_stall(DUT_core_control_revert_stall),
		.core_control_halt_assert(DUT_core_control_halt_assert),
	        // for when halt instr retires

	    // optional outputs:

	    // ROB state
		.ROB_state_out(DUT_ROB_state_out),

	    // if complete is invalid
		.invalid_complete(DUT_invalid_complete),

	    // current ROB capacity
		.ROB_capacity(DUT_ROB_capacity)
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

		if (expected_full !== DUT_full) begin
			$display("TB ERROR: expected_full (%h) != DUT_full (%h)",
				expected_full, DUT_full);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_empty !== DUT_empty) begin
			$display("TB ERROR: expected_empty (%h) != DUT_empty (%h)",
				expected_empty, DUT_empty);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_fetch_unit_take_resolved !== DUT_fetch_unit_take_resolved) begin
			$display("TB ERROR: expected_fetch_unit_take_resolved (%h) != DUT_fetch_unit_take_resolved (%h)",
				expected_fetch_unit_take_resolved, DUT_fetch_unit_take_resolved);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_fetch_unit_resolved_PC !== DUT_fetch_unit_resolved_PC) begin
			$display("TB ERROR: expected_fetch_unit_resolved_PC (%d) != DUT_fetch_unit_resolved_PC (%d)",
				expected_fetch_unit_resolved_PC, DUT_fetch_unit_resolved_PC);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dispatch_unit_ROB_tail_index !== DUT_dispatch_unit_ROB_tail_index) begin
			$display("TB ERROR: expected_dispatch_unit_ROB_tail_index (%d) != DUT_dispatch_unit_ROB_tail_index (%d)",
				expected_dispatch_unit_ROB_tail_index, DUT_dispatch_unit_ROB_tail_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dispatch_unit_retire_valid !== DUT_dispatch_unit_retire_valid) begin
			$display("TB ERROR: expected_dispatch_unit_retire_valid (%h) != DUT_dispatch_unit_retire_valid (%h)",
				expected_dispatch_unit_retire_valid, DUT_dispatch_unit_retire_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dispatch_unit_retire_phys_reg_tag !== DUT_dispatch_unit_retire_phys_reg_tag) begin
			$display("TB ERROR: expected_dispatch_unit_retire_phys_reg_tag (%d) != DUT_dispatch_unit_retire_phys_reg_tag (%d)",
				expected_dispatch_unit_retire_phys_reg_tag, DUT_dispatch_unit_retire_phys_reg_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_retire_valid !== DUT_LQ_retire_valid) begin
			$display("TB ERROR: expected_LQ_retire_valid (%h) != DUT_LQ_retire_valid (%h)",
				expected_LQ_retire_valid, DUT_LQ_retire_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_retire_ROB_index !== DUT_LQ_retire_ROB_index) begin
			$display("TB ERROR: expected_LQ_retire_ROB_index (%d) != DUT_LQ_retire_ROB_index (%d)",
				expected_LQ_retire_ROB_index, DUT_LQ_retire_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_retire_valid !== DUT_SQ_retire_valid) begin
			$display("TB ERROR: expected_SQ_retire_valid (%h) != DUT_SQ_retire_valid (%h)",
				expected_SQ_retire_valid, DUT_SQ_retire_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_retire_ROB_index !== DUT_SQ_retire_ROB_index) begin
			$display("TB ERROR: expected_SQ_retire_ROB_index (%d) != DUT_SQ_retire_ROB_index (%d)",
				expected_SQ_retire_ROB_index, DUT_SQ_retire_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restore_checkpoint_valid !== DUT_restore_checkpoint_valid) begin
			$display("TB ERROR: expected_restore_checkpoint_valid (%h) != DUT_restore_checkpoint_valid (%h)",
				expected_restore_checkpoint_valid, DUT_restore_checkpoint_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restore_checkpoint_speculate_failed !== DUT_restore_checkpoint_speculate_failed) begin
			$display("TB ERROR: expected_restore_checkpoint_speculate_failed (%h) != DUT_restore_checkpoint_speculate_failed (%h)",
				expected_restore_checkpoint_speculate_failed, DUT_restore_checkpoint_speculate_failed);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restore_checkpoint_ROB_index !== DUT_restore_checkpoint_ROB_index) begin
			$display("TB ERROR: expected_restore_checkpoint_ROB_index (%d) != DUT_restore_checkpoint_ROB_index (%d)",
				expected_restore_checkpoint_ROB_index, DUT_restore_checkpoint_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restore_checkpoint_safe_column !== DUT_restore_checkpoint_safe_column) begin
			$display("TB ERROR: expected_restore_checkpoint_safe_column (%h) != DUT_restore_checkpoint_safe_column (%h)",
				expected_restore_checkpoint_safe_column, DUT_restore_checkpoint_safe_column);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_revert_valid !== DUT_revert_valid) begin
			$display("TB ERROR: expected_revert_valid (%h) != DUT_revert_valid (%h)",
				expected_revert_valid, DUT_revert_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_revert_ROB_index !== DUT_revert_ROB_index) begin
			$display("TB ERROR: expected_revert_ROB_index (%d) != DUT_revert_ROB_index (%d)",
				expected_revert_ROB_index, DUT_revert_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_revert_arch_reg_tag !== DUT_revert_arch_reg_tag) begin
			$display("TB ERROR: expected_revert_arch_reg_tag (%d) != DUT_revert_arch_reg_tag (%d)",
				expected_revert_arch_reg_tag, DUT_revert_arch_reg_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_revert_safe_phys_reg_tag !== DUT_revert_safe_phys_reg_tag) begin
			$display("TB ERROR: expected_revert_safe_phys_reg_tag (%d) != DUT_revert_safe_phys_reg_tag (%d)",
				expected_revert_safe_phys_reg_tag, DUT_revert_safe_phys_reg_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_revert_speculated_phys_reg_tag !== DUT_revert_speculated_phys_reg_tag) begin
			$display("TB ERROR: expected_revert_speculated_phys_reg_tag (%d) != DUT_revert_speculated_phys_reg_tag (%d)",
				expected_revert_speculated_phys_reg_tag, DUT_revert_speculated_phys_reg_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_kill_bus_valid !== DUT_kill_bus_valid) begin
			$display("TB ERROR: expected_kill_bus_valid (%h) != DUT_kill_bus_valid (%h)",
				expected_kill_bus_valid, DUT_kill_bus_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_kill_bus_ROB_index !== DUT_kill_bus_ROB_index) begin
			$display("TB ERROR: expected_kill_bus_ROB_index (%d) != DUT_kill_bus_ROB_index (%d)",
				expected_kill_bus_ROB_index, DUT_kill_bus_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_core_control_restore_flush !== DUT_core_control_restore_flush) begin
			$display("TB ERROR: expected_core_control_restore_flush (%h) != DUT_core_control_restore_flush (%h)",
				expected_core_control_restore_flush, DUT_core_control_restore_flush);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_core_control_revert_stall !== DUT_core_control_revert_stall) begin
			$display("TB ERROR: expected_core_control_revert_stall (%h) != DUT_core_control_revert_stall (%h)",
				expected_core_control_revert_stall, DUT_core_control_revert_stall);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_core_control_halt_assert !== DUT_core_control_halt_assert) begin
			$display("TB ERROR: expected_core_control_halt_assert (%h) != DUT_core_control_halt_assert (%h)",
				expected_core_control_halt_assert, DUT_core_control_halt_assert);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_state_out !== DUT_ROB_state_out) begin
			$display("TB ERROR: expected_ROB_state_out (%h) != DUT_ROB_state_out (%h)",
				expected_ROB_state_out, DUT_ROB_state_out);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_invalid_complete !== DUT_invalid_complete) begin
			$display("TB ERROR: expected_invalid_complete (%h) != DUT_invalid_complete (%h)",
				expected_invalid_complete, DUT_invalid_complete);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_capacity !== DUT_ROB_capacity) begin
			$display("TB ERROR: expected_ROB_capacity (%d) != DUT_ROB_capacity (%d)",
				expected_ROB_capacity, DUT_ROB_capacity);
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
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b0;
		tb_dispatch_unit_enqueue_struct.valid = 1'b0;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(0);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b1;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(0);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(0);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd0;

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b0;
		tb_dispatch_unit_enqueue_struct.valid = 1'b0;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(0);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b1;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(0);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(0);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd0;

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
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b0;
		tb_dispatch_unit_enqueue_struct.valid = 1'b0;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(0);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b1;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(0);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(0);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd0;

		check_outputs();

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // instr stream:
        test_case = "instr stream";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 00|00: ADDU r1->p1/p32, r2->p2, r3->p3 (ALU 0)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(0);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b1;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(0);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(0);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd0;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 01|01: ADD r2->p2/p33, r2->p2, r5->p5 (ALU 1)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(1);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(1);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(1);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(1);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(1);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd1;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "no dispatch: 02|02: AND r30->p30/p34, r5->p5, r2->p33 (ALU 0)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b0;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(2);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(30);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(30);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(34);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(2);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(1);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(2);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(2);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd2;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 02|02: AND r30->p30/p34, r5->p5, r2->p33 (ALU 0)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(2);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(30);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(30);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(34);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(2);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(1);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(2);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(2);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd2;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 03|03: JR r30->p34 (goto 36)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(3);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(3);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(1);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(3);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(3);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd3;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 04|04: goofy SQ no write + ADDU complete";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(4);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(32);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(4);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(1);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(4);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(4);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd4;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 05|05: goofy LQ write r6/p6->p35 + ADD complete + ADDU retire";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(5);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(6);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(35);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b1;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(33);
		tb_complete_bus_1_ROB_index = ROB_index_t'(1);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(5);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(1);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(0);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(0);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(5);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(5);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd5;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 06|06: goofy HALT + ADD retire";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b1;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(6);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b1;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(33);
		tb_complete_bus_1_ROB_index = ROB_index_t'(1);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(6);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(2);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(1);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(1);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(6);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(6);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd5;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 07|07: goofy ALU 1 write r2/p33->p36 + JR complete speculate fail";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b1;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(7);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(36);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b1;
		tb_BRU_complete_ROB_index = ROB_index_t'(3);
	    // restart info
		tb_BRU_restart_valid = 1'b1;
		tb_BRU_restart_ROB_index = ROB_index_t'(3);
		tb_BRU_restart_PC = pc_t'(36);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b1;
		expected_fetch_unit_resolved_PC = pc_t'(36);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(7);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(30);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(2);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(2);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(0);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(7);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(7);
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_IDLE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd5;

		check_outputs();

        @(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 04|36: NOR r13-p13/p35, r6->p6, r19->p19";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full/empty
	    // fetch unit interface
	    // dispatch unit interface
	    // dispatch @ tail
		tb_dispatch_unit_enqueue_valid = 1'b0;
		tb_dispatch_unit_enqueue_struct.valid = 1'b1;
        tb_dispatch_unit_enqueue_struct.complete = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(36);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(13);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(35);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_ROB_index = ROB_index_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b0;
		tb_LQ_restart_ROB_index = ROB_index_t'(0);
	    // SQ interface
	    // complete
		tb_SQ_complete_valid = 1'b0;
		tb_SQ_complete_ROB_index = ROB_index_t'(0);
	    // retire
	    // restore interface
		tb_restore_checkpoint_success = 1'b0;
	    // revert interface
	    // kill bus interface
	    // core control interface
	    // optional outputs:
	    // ROB state
	    // if complete is invalid
	    // current ROB capacity

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full/empty
		expected_full = 1'b0;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(8);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(30);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(2);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(2);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b1;
		expected_restore_checkpoint_speculate_failed = 1'b1;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(3);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(8);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(8);
	    // core control interface
		expected_core_control_restore_flush = 1'b1;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_RESTORE);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd6;

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

