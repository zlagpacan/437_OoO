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
	// ROB_index_t tb_BRU_complete_ROB_index;
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
	logic tb_SQ_retire_blocked;

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

	`ifndef MAPPED
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
		// .BRU_complete_ROB_index(tb_BRU_complete_ROB_index),
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
		.SQ_retire_blocked(tb_SQ_retire_blocked),

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
	`else

	// signals for type cast
	logic [1:0] DUT_ROB_state_out_casted;

	// assign enum to pure logic array
	assign DUT_ROB_state_out = ROB_state_t'(DUT_ROB_state_out_casted);

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
		// .dispatch_unit_enqueue_struct(tb_dispatch_unit_enqueue_struct),
			// struct -> need to enumerate
		.\dispatch_unit_enqueue_struct.valid (tb_dispatch_unit_enqueue_struct.valid),
		.\dispatch_unit_enqueue_struct.complete (tb_dispatch_unit_enqueue_struct.complete),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_J (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD),
		.\dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT (tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT),
		.\dispatch_unit_enqueue_struct.restart_PC (tb_dispatch_unit_enqueue_struct.restart_PC),
		.\dispatch_unit_enqueue_struct.reg_write (tb_dispatch_unit_enqueue_struct.reg_write),
		.\dispatch_unit_enqueue_struct.dest_arch_reg_tag (tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag),
		.\dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag (tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag),
		.\dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag (tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag),
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
		// .BRU_complete_ROB_index(tb_BRU_complete_ROB_index),
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
		// .ROB_state_out(DUT_ROB_state_out),
			// enum -> need to typecast intermediate signals
		.ROB_state_out(DUT_ROB_state_out_casted),

	    // if complete is invalid
		.invalid_complete(DUT_invalid_complete),

	    // current ROB capacity
		.ROB_capacity(DUT_ROB_capacity)
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		tb_SQ_retire_blocked = 1'b0;
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		sub_test_case = "enqueue: 07|07: goofy ALU 1 write r2/p33->p36 + JR complete speculate fail";
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(3);
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
		sub_test_case = "fail enqueue: 04|36: NOR r13-p13/p35, r6->p6, r19->p19 + restore success";
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
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		tb_restore_checkpoint_success = 1'b1;
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

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 04|36: NOR r13-p13/p35, r6->p6, r19->p19 + AND complete + kill ROB index 4";
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
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(34);
		tb_complete_bus_0_ROB_index = ROB_index_t'(2);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(4);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
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
		expected_ROB_capacity = 5'd2;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 04|36: NOR r13-p13/p35, r6->p6, r19->p19 + AND retire + kill ROB index 5";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(36);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(13);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(35);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(34);
		tb_complete_bus_0_ROB_index = ROB_index_t'(2);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_ROB_index = ROB_index_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_ROB_index = ROB_index_t'(0);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_retire_valid = 1'b1;
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
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(4);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0);
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
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
		expected_ROB_capacity = 5'd2;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 05|37: OR r14->p14/p36, r0->p0, r21->p21 (ALU 0) + JR retire + kill ROB index 6";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(37);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(14);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(36);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(3);
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(3);
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(5);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(6); // from bad speculate
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(6);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(35);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
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
		expected_ROB_capacity = 5'd2;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 06|38: SLT r15->p15/p37, r25->p25, r1->p32 (ALU 1) + NOR complete + kill ROB index 7";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(38);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(15);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(15);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(37);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(35);
		tb_complete_bus_0_ROB_index = ROB_index_t'(4);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(13); // head
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(4); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(4); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(6);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
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
		expected_ROB_capacity = 5'd2;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 07|39: SLTU r16->p16/p38, r22->p22, r13->p35 + retire NOR + OR complete + SLT complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(39);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(16);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(38);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(36);
		tb_complete_bus_0_ROB_index = ROB_index_t'(5);
		tb_complete_bus_1_valid = 1'b1;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(37);
		tb_complete_bus_1_ROB_index = ROB_index_t'(6);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(7);
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(13); // head
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(4); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(4); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(7);
		expected_revert_arch_reg_tag = arch_reg_tag_t'(2); // from bad speculate
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(33);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(36);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(7); // last restart end of kill
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
		sub_test_case = "enqueue: 08|40: SLLV r17->p17/p39, r2->p33, r16->p3 + retire OR";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(40);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(17);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(39);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(14); // head
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(5); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(5); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4);
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(8); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(8); // tail or end of inorder kill
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
		sub_test_case = "enqueue: 09|41: SRLV r18->p18/p40, r1->p32, r29->p29 + retire SLT";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(41);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(18);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(40);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(9); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(15); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(6); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(6); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(9); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(9); // tail or end of inorder kill
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
		sub_test_case = "enqueue: 10|42: SUBU r19->p19/p41, r15->p37, r17->p39";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(42);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(19);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(41);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(10); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(10); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(10); // tail or end of inorder kill
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
		sub_test_case = "enqueue: 11|43: SUB r20->p20/p42, r23->p23, r19->p41";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(43);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(20);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(42);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(11); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(11); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(11); // tail or end of inorder kill
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
		sub_test_case = "enqueue: 12|44: XOR r21->p21/p43, r0->p0, r0->p0";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(44);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(21);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(21);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(43);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(12); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(12); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(12); // tail or end of inorder kill
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
		sub_test_case = "enqueue: 13|45: ADDIU r22->p22/p44, r13->p35, 0x5";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(45);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(22);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(13); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(13); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(13); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd6;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 14|46: ADDI r23->p23/p45, r1->p32, 0x201";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(46);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(23);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(45);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(14); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(14); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(14); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd7;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 15|47: ANDI r24->p24/p46, r23->p45, 0x71A7";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(47);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(24);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(24);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(46);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(15); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(15); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(15); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd8;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 16|48: BEQ r24->p46, r23->p45 (goto 81)";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(48);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(16); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(16); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(1); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(1);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(32);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(16); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd9;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 17|49: ALU 0 reg write r25->p25/p47";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(49);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(17); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(17); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(2); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(2);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(33);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(17); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 18|50: ALU 1 reg write r25->p47/p48";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(50);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(47);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(18); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(18); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(30); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(30);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(34);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(18); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 19|51: dead instr";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(51);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(48);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(49);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(19); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(19); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(19); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd12;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 20|52: LQ write r25->p48/p49";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(52);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(48);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(49);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(20); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(20); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(13); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(13);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(35);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(20); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd13;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 21|53: SQ + BEQ complete/restart";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(53);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b1;
		// tb_BRU_complete_ROB_index = ROB_index_t'(16);
	    // restart info
		tb_BRU_restart_valid = 1'b1;
		tb_BRU_restart_ROB_index = ROB_index_t'(16);
		tb_BRU_restart_PC = pc_t'(81);
		tb_BRU_restart_safe_column = checkpoint_column_t'(2);
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
		expected_fetch_unit_resolved_PC = pc_t'(81);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(21); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(4); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(2); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(21); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(14); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(14);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(36);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(21); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd14;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 22|54: ALU 0 write r25->p49/p50 + BEQ restore (fails -> revert) + LQ restart (fails, younger than BEQ)";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(54);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(49);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(50);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b1;
		tb_LQ_restart_ROB_index = ROB_index_t'(20);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(22); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b1;
		expected_restore_checkpoint_speculate_failed = 1'b1;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(16); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(2); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(22); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(15); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(15);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(37);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(22); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 17|81: BNE r22->p44, r0->p0 (don't goto +0123) + 21|53: SQ revert (so none) + SLTU complete";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(81);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(38);
		tb_complete_bus_0_ROB_index = ROB_index_t'(7);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(21); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(21); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(21); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd14;

		check_outputs();
		
		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 17|81: BNE r22->p44, r0->p0 (don't goto +0123) + 20|52: LQ write r25->p48/p49 revert + SLTU retire (fails)";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(81);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(20); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(20); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(48);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(49);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(20); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd13;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 17|81: BNE r22->p44, r0->p0 (don't goto +0123) + 19|51: dead instr revert (so none) + SLTU retire (fails)";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(81);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(19); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(19); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(48);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(49);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(19); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd12;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 17|81: BNE r22->p44, r0->p0 (don't goto +0123) + 18|50: ALU 1 reg write r25->p47/p48 revert + SLTU retire (fails)";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(81);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(18); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(18); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(47);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(48);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(18); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 17|81: BNE r22->p44, r0->p0 (don't goto +0123) + 17|49: ALU 0 reg write r25->p25/p47 revert + SLTU retire (fails)";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(81);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(17); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(17); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(25);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(47);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(17); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 17|81: BNE r22->p44, r0->p0 (don't goto +0123) + SLTU retire (now succeeds)";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(81);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(17); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(16); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(7); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(17); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(25);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(47);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(17); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 18|82: LUI r25->p25/p47, 0xFEDC";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(82);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(18); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(18); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(47);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(48);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(18); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 19|83: LW r26->p26/p48, 0x9D4(r19->p41)";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(83);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(19); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(19); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(48);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(49);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(19); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 20|84: ORI r27->p27/p49, r25->p47, 0x98";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(84);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(27);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(27);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(49);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(20); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(20); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(48);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(49);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(20); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd12;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 21|85: SLTI r28->p28/p50, r30->p34, 0x7F";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(85);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(28);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(28);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(50);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(21); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(21); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(21); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd13;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 22|86: SLTIU r29->p51, r9->p9, 0x4BE9 + LW restart";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(86);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(29);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(29);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(51);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(0);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(0);
	    // LQ interface
	    // retire
	    // restart info
		tb_LQ_restart_valid = 1'b1;
		tb_LQ_restart_ROB_index = ROB_index_t'(19);
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
		expected_fetch_unit_resolved_PC = pc_t'(83);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(22); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(22); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(15); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(15);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(37);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(22); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd14;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 23|87: SW r3->p3, 0x10D(r13->p3) + 22|86: SLTIU r29->p51, r9->p9, 0x4BE9 revert";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(87);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(22); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(22); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(29); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(29);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(51);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(22); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd14;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 19|83: LW r26->p26/p48, 0x9D4(r19->p41) + 21|85: SLTI r28->p28/p50, r30->p34, 0x7F revert + 08|40: SLLV r17->p17/p39, r2->p33, r16->p38 complete";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(83);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(39);
		tb_complete_bus_0_ROB_index = ROB_index_t'(8);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(21); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(21); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(28); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(28);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(50);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(21); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd13;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 19|83: LW r26->p26/p48, 0x9D4(r19->p41) + 20|84: ORI r27->p27/p49, r25->p47, 0x98 revert + fail retire 08|40: SLLV r17->p17/p39, r2->p33, r16->p38";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(83);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(20); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(20); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(27); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(27);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(49);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(20); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd12;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 19|83: LW r26->p26/p48, 0x9D4(r19->p41) + 19|83: LW r26->p26/p48, 0x9D4(r19->p41) revert + fail retire 08|40: SLLV r17->p17/p39, r2->p33, r16->p38";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(83);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(19); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b1;
		expected_revert_ROB_index = ROB_index_t'(19); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(26); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(26);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(48);
	    // kill bus interface
		expected_kill_bus_valid = 1'b1;
		expected_kill_bus_ROB_index = ROB_index_t'(19); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b1;
		expected_core_control_halt_assert = 1'b0;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_REVERT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 19|83: LW r26->p26/p48, 0x9D4(r19->p41) + retire 08|40: SLLV r17->p17/p39, r2->p33, r16->p38";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(83);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(26);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(19); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(17); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(8); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(19); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(26); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(26);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(48);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(19); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 20|84: ORI r27->p27/p49, r25->p47, 0x98";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(84);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(27);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(27);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(49);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(20); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(20); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(27); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(27);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(49);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(20); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 21|85: SLTI r28->p28/p50, r30->p34, 0x7F";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(85);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(28);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(28);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(50);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(21); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(21); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(28); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(28);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(50);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(21); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd12;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 22|86: SLTIU r29->p29/p51, r9->p9, 0x4BE9";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(86);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(29);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(29);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(51);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(22); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(22); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(29); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(29);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(51);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(22); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd13;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 23|87: SW r3->p3, 0x10D(r13->p3)";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(87);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(23); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(23); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(16); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(16);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(38);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(23); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd14;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 24|88: XORI r30->p34/p52, r30->p34, 0x1C9";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(88);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(30);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(52);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(24); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(24); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(17); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(17);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(39);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(24); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "full fail enqueue: 25|89: J (goto 26)";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(89);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(0);
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
		expected_full = 1'b1;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(25); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(25); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(18); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(18);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(40);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(25); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd16;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "full fail enqueue: 25|89: J (goto 26) + 09|41: SRLV r18->p18/p40, r1->p32, r29->p29 complete + 17|81: BNE r22->p44, r0->p0 (don't goto +0123) complete";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(89);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(40);
		tb_complete_bus_0_ROB_index = ROB_index_t'(9);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b1;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
	    // restart info
		tb_BRU_restart_valid = 1'b0;
		tb_BRU_restart_ROB_index = ROB_index_t'(17);
		tb_BRU_restart_PC = pc_t'(0);
		tb_BRU_restart_safe_column = checkpoint_column_t'(3);
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
		tb_restore_checkpoint_success = 1'b1;
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
		expected_full = 1'b1;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(25); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b1;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(17); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(3); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(25); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(18); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(18);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(40);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(25); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd16;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "full fail enqueue: 25|89: J (goto 26) + 09|41: SRLV r18->p18/p40, r1->p32, r29->p29 retire + 10|42: SUBU r19->p19/p41, r15->p37, r17->p39 complete + 19|83: LW r26->p26/p48, 0x9D4(r19->p41) complete";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(89);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(41);
		tb_complete_bus_0_ROB_index = ROB_index_t'(10);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b1;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(48);
		tb_complete_bus_2_ROB_index = ROB_index_t'(19);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_full = 1'b1;
		expected_empty = 1'b0;
	    // fetch unit interface
		expected_fetch_unit_take_resolved = 1'b0;
		expected_fetch_unit_resolved_PC = pc_t'(0);
	    // dispatch unit interface
	    // dispatch @ tail
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(25); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(18); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(9); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(25); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(18); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(18);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(40);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(25); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd16;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 25|89: J (goto 26) + 10|42: SUBU r19->p19/p41, r15->p37, r17->p39 retire + 11|43: SUB r20->p20/p42, r23->p23, r19->p41 complete + 23|87: SW r3->p3, 0x10D(r13->p3) complete";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(89);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(42);
		tb_complete_bus_0_ROB_index = ROB_index_t'(11);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		tb_SQ_complete_valid = 1'b1;
		tb_SQ_complete_ROB_index = ROB_index_t'(23);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(25); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(19); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(10); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(10); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(25); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(18); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(18);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(40);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(25); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 26|26: JAL (goto 99) (r31->p31/p53 <= PC+1) + 11|43: SUB r20->p20/p42, r23->p23, r19->p41 retire + 12|44: XOR r21->p21/p43, r0->p0, r0->p0 complete";
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
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(26);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(31);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(31);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(53);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(43);
		tb_complete_bus_0_ROB_index = ROB_index_t'(12);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(26); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(20); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(11); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(11); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(26); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(19); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(19);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(41);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(26); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 27|99: ADD r0->p0/-, r25->p25, r30->p34 + 12|44: XOR r21->p21/p43, r0->p0, r0->p0 retire + 13|45: ADDIU r22->p22/p44, r13->p35, 0x5 complete";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(99);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(44);
		tb_complete_bus_0_ROB_index = ROB_index_t'(13);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(27); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(21); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(12); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(12); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(27); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(20); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(20);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(42);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(27); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 28|100: ORI r0->p0/-, r25->p25, 0x234 + 13|45: ADDIU r22->p22/p44, r13->p35, 0x5 retire + 14|46: ADDI r23->p23/p45, r1->p32, 0x201 complete";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(100);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(45);
		tb_complete_bus_0_ROB_index = ROB_index_t'(14);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(28); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(22); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(13); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(13); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(28); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(21); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(21);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(43);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(28); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 29|101: LW r0->p0/-, 0x7E0(r30->p34) + 14|46: ADDI r23->p23/p45, r1->p32, 0x201 retire + 15|47: ANDI r24->p24/p46, r23->p45, 0x71A7 complete";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b0;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(101);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(46);
		tb_complete_bus_0_ROB_index = ROB_index_t'(15);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(29); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(23); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(14); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(14); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(29); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(22); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(22);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(44);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(29); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 30|102: HALT + 15|47: ANDI r24->p24/p46, r23->p45, 0x71A7 retire";
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
        tb_dispatch_unit_enqueue_struct.complete = 1'b1;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_0 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_ALU_1 = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_LQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_SQ = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_BRU = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_J = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_DEAD = 1'b0;
        tb_dispatch_unit_enqueue_struct.dispatched_unit.DU_HALT = 1'b1;
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(102);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b0;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(30); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(24); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(15); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(15); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(30); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(23); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(23);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(45);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(30); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 31|103: XORI r30->p52/p54, r30->p52, 0x55 + 16|48: BEQ r24->p46, r23->p45 (goto 81) retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(103);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(30);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(52);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(54);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(31); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(16); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(16); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(31); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(24); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(24);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(46);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(31); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 32|104: ADDU r1->p1/p32, r2->p2, r3->p3 + 17|81: BNE r22->p44, r0->p0 (don't goto +0123) retire + 18|82: LUI r25->p25/p47, 0xFEDC complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(103);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(47);
		tb_complete_bus_0_ROB_index = ROB_index_t'(18);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(32); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(17); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(17); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(32); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(32); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd15;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 32|104: ADDU r1->p1/p32, r2->p2, r3->p3 + 18|82: LUI r25->p25/p47, 0xFEDC retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(103);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(32); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(25); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(18); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(18); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(32); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(32); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd14;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 32|104: ADDU r1->p1/p32, r2->p2, r3->p3 + 19|83: LW r26->p26/p48, 0x9D4(r19->p41) retire + 20|84: ORI r27->p27/p49, r25->p47, 0x98 complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(103);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(49);
		tb_complete_bus_0_ROB_index = ROB_index_t'(20);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(32); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(26); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b1;
		expected_LQ_retire_ROB_index = ROB_index_t'(19); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(19); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(32); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(32); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd13;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 32|104: ADDU r1->p1/p32, r2->p2, r3->p3 + 20|84: ORI r27->p27/p49, r25->p47, 0x98 retire + 21|85: SLTI r28->p28/p50, r30->p34, 0x7F complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(103);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(50);
		tb_complete_bus_0_ROB_index = ROB_index_t'(21);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(32); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(27); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(20); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(20); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(32); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(32); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd12;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 32|104: ADDU r1->p1/p32, r2->p2, r3->p3 + 21|85: SLTI r28->p28/p50, r30->p34, 0x7F retire + 22|86: SLTIU r29->p29/p51, r9->p9, 0x4BE9 complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(103);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(51);
		tb_complete_bus_0_ROB_index = ROB_index_t'(22);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(32); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(28); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(21); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(21); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(32); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(32); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd11;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "enqueue: 32|104: ADDU r1->p1/p32, r2->p2, r3->p3 + 22|86: SLTIU r29->p29/p51, r9->p9, 0x4BE9 retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(104);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(32); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(29); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(22); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(22); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(32); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(32); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 23|87: SW r3->p3, 0x10D(r13->p3) fail retire (blocked) + 24|88: XORI r30->p34/p52, r30->p34, 0x1C9 complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(52);
		tb_complete_bus_0_ROB_index = ROB_index_t'(24);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		tb_SQ_retire_blocked = 1'b1;
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(23); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(23); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 23|87: SW r3->p3, 0x10D(r13->p3) retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		tb_SQ_retire_blocked = 1'b0;
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(23); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b1;
		expected_SQ_retire_ROB_index = ROB_index_t'(23); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd10;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 24|88: XORI r30->p34/p52, r30->p34, 0x1C9 retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(34); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(24); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(24); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd9;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 25|89: J (goto 26) retire + 26|26: JAL (goto 99) (r31->p31/p53 <= PC+1) complete";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(53);
		tb_complete_bus_0_ROB_index = ROB_index_t'(26);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(25); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(25); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd8;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 26|26: JAL (goto 99) (r31->p31/p53 <= PC+1) retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b1;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(31); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(26); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(26); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd7;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 27|99: ADD r0->p0/-, r25->p25, r30->p34 retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(27); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(27); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		expected_ROB_capacity = 5'd6;

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 28|100: ORI r0->p0/-, r25->p25, 0x234 retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(28); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(28); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 29|101: LW r0->p0/-, 0x7E0(r30->p34) retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(29); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(29); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		sub_test_case = "enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + 30|102: HALT retire";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(33); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(0); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(30); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(30); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(33); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(0); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(0);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(0);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(33); // tail or end of inorder kill
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
		sub_test_case = "fail enqueue: 33|105: ADD r2->p2/p33, r2->p2, r5->p5 + HALT STATE";
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
        tb_dispatch_unit_enqueue_struct.restart_PC = pc_t'(105);
        tb_dispatch_unit_enqueue_struct.reg_write = 1'b1;
        tb_dispatch_unit_enqueue_struct.dest_arch_reg_tag = arch_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_enqueue_struct.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // complete bus interfaces
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_0_ROB_index = ROB_index_t'(999);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_1_ROB_index = ROB_index_t'(999);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(999);
		tb_complete_bus_2_ROB_index = ROB_index_t'(999);
	    // BRU interface
	    // complete
		tb_BRU_complete_valid = 1'b0;
		// tb_BRU_complete_ROB_index = ROB_index_t'(17);
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
		expected_dispatch_unit_ROB_tail_index = ROB_index_t'(34); // tail
	    // retire from head
		expected_dispatch_unit_retire_valid = 1'b0;
		expected_dispatch_unit_retire_phys_reg_tag = phys_reg_tag_t'(52); // head's tag
	    // complete bus interfaces
	    // BRU interface
	    // complete
	    // restart info
	    // LQ interface
	    // retire
		expected_LQ_retire_valid = 1'b0;
		expected_LQ_retire_ROB_index = ROB_index_t'(31); // head
	    // restart info
	    // SQ interface
	    // complete
	    // retire
		expected_SQ_retire_valid = 1'b0;
		expected_SQ_retire_ROB_index = ROB_index_t'(31); // head
	    // restore interface
		expected_restore_checkpoint_valid = 1'b0;
		expected_restore_checkpoint_speculate_failed = 1'b0;
		expected_restore_checkpoint_ROB_index = ROB_index_t'(19); // last restart index
		expected_restore_checkpoint_safe_column = checkpoint_column_t'(0); // BRU restart column
	    // revert interface
		expected_revert_valid = 1'b0;
		expected_revert_ROB_index = ROB_index_t'(34); // tail
		expected_revert_arch_reg_tag = arch_reg_tag_t'(25); // from bad speculate or reset or old @ tail
		expected_revert_safe_phys_reg_tag = phys_reg_tag_t'(25);
		expected_revert_speculated_phys_reg_tag = phys_reg_tag_t'(47);
	    // kill bus interface
		expected_kill_bus_valid = 1'b0;
		expected_kill_bus_ROB_index = ROB_index_t'(34); // tail or end of inorder kill
	    // core control interface
		expected_core_control_restore_flush = 1'b0;
		expected_core_control_revert_stall = 1'b0;
		expected_core_control_halt_assert = 1'b1;
	    // optional outputs:
	    // ROB state
		expected_ROB_state_out = ROB_state_t'(ROB_HALT);
	    // if complete is invalid
		expected_invalid_complete = 1'b0;
	    // current ROB capacity
		expected_ROB_capacity = 5'd3;

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

