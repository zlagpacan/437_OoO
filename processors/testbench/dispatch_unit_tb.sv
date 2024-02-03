/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dispatch_unit_tb.sv
    Instantiation Hierarchy: system -> core -> dispatch_unit
    Description: 
       Testbench for dispatch_unit module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module dispatch_unit_tb ();

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

    // core control interface
	logic tb_core_control_stall_dispatch_unit;
	logic tb_core_control_flush_dispatch_unit;
	logic tb_core_control_halt;
	logic DUT_core_control_dispatch_failed, expected_core_control_dispatch_failed;

    // fetch_unit interface
	word_t tb_fetch_unit_instr;
	logic tb_fetch_unit_ivalid;
	pc_t tb_fetch_unit_PC;
	pc_t tb_fetch_unit_nPC;

    // restore interface
	logic tb_restore_checkpoint_valid;
	logic tb_restore_checkpoint_speculate_failed;
	ROB_index_t tb_restore_checkpoint_ROB_index;
	checkpoint_column_t tb_restore_checkpoint_safe_column;
	logic DUT_restore_checkpoint_success, expected_restore_checkpoint_success;

    // kill bus interface
        // kill for ROB_index, T, T_old
	logic tb_kill_bus_valid;
	ROB_index_t tb_kill_bus_ROB_index;
        // actually don't need this, only need ROB index for execution unit kills
	arch_reg_tag_t tb_kill_bus_arch_reg_tag;
	phys_reg_tag_t tb_kill_bus_speculated_phys_reg_tag;
	phys_reg_tag_t tb_kill_bus_safe_phys_reg_tag;

    // complete bus interface
        // 2x ready @ T
	logic tb_complete_bus_0_valid;
	phys_reg_tag_t tb_complete_bus_0_dest_phys_reg_tag;
	logic tb_complete_bus_1_valid;
	phys_reg_tag_t tb_complete_bus_1_dest_phys_reg_tag;
	logic tb_complete_bus_2_valid;
	phys_reg_tag_t tb_complete_bus_2_dest_phys_reg_tag;

    // ROB interface
    // dispatch @ tail
	logic tb_ROB_full;
	ROB_index_t tb_ROB_tail_index;
	logic DUT_ROB_enqueue_valid, expected_ROB_enqueue_valid;
	ROB_entry_t DUT_ROB_struct_out, expected_ROB_struct_out;
    // retire from head
	logic tb_ROB_retire_valid;
	phys_reg_tag_t tb_ROB_retire_phys_reg_tag;

    // 2x ALU RS interface
	logic [1:0] tb_ALU_RS_full;
	logic [1:0] DUT_ALU_RS_task_valid, expected_ALU_RS_task_valid;
	ALU_RS_input_struct_t [1:0] DUT_ALU_RS_task_struct, expected_ALU_RS_task_struct;

    // LQ interface
	LQ_index_t tb_LQ_tail_index;
	logic tb_LQ_full;
	logic DUT_LQ_task_valid, expected_LQ_task_valid;
	LQ_enqueue_struct_t DUT_LQ_task_struct, expected_LQ_task_struct;

    // SQ interface
	SQ_index_t tb_SQ_tail_index;
	logic tb_SQ_full;
	logic DUT_SQ_task_valid, expected_SQ_task_valid;
	SQ_enqueue_struct_t DUT_SQ_task_struct, expected_SQ_task_struct;

    // BRU RS interface
	logic tb_BRU_RS_full;
	logic DUT_BRU_RS_task_valid, expected_BRU_RS_task_valid;
	BRU_RS_input_struct_t DUT_BRU_RS_task_struct, expected_BRU_RS_task_struct;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	`ifndef MAPPED
	dispatch_unit DUT (
		
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // core control interface
		.core_control_stall_dispatch_unit(tb_core_control_stall_dispatch_unit),
		.core_control_flush_dispatch_unit(tb_core_control_flush_dispatch_unit),
		.core_control_halt(tb_core_control_halt),
		.core_control_dispatch_failed(DUT_core_control_dispatch_failed),

	    // fetch_unit interface
		.fetch_unit_instr(tb_fetch_unit_instr),
		.fetch_unit_ivalid(tb_fetch_unit_ivalid),
		.fetch_unit_PC(tb_fetch_unit_PC),
		.fetch_unit_nPC(tb_fetch_unit_nPC),

	    // restore interface
		.restore_checkpoint_valid(tb_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(tb_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(tb_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(tb_restore_checkpoint_safe_column),
		.restore_checkpoint_success(DUT_restore_checkpoint_success),

	    // kill bus interface
	        // kill for ROB_index, T, T_old
		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),
	        // actually don't need this, only need ROB index for execution unit kills
		.kill_bus_arch_reg_tag(tb_kill_bus_arch_reg_tag),
		.kill_bus_speculated_phys_reg_tag(tb_kill_bus_speculated_phys_reg_tag),
		.kill_bus_safe_phys_reg_tag(tb_kill_bus_safe_phys_reg_tag),

	    // complete bus interface
	        // 2x ready @ T
		.complete_bus_0_valid(tb_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(tb_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_1_valid(tb_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(tb_complete_bus_1_dest_phys_reg_tag),
		.complete_bus_2_valid(tb_complete_bus_2_valid),
		.complete_bus_2_dest_phys_reg_tag(tb_complete_bus_2_dest_phys_reg_tag),

	    // ROB interface
	    // dispatch @ tail
		.ROB_full(tb_ROB_full),
		.ROB_tail_index(tb_ROB_tail_index),
		.ROB_enqueue_valid(DUT_ROB_enqueue_valid),
		.ROB_struct_out(DUT_ROB_struct_out),
	    // retire from head
		.ROB_retire_valid(tb_ROB_retire_valid),
		.ROB_retire_phys_reg_tag(tb_ROB_retire_phys_reg_tag),

	    // 2x ALU RS interface
		.ALU_RS_full(tb_ALU_RS_full),
		.ALU_RS_task_valid(DUT_ALU_RS_task_valid),
		.ALU_RS_task_struct(DUT_ALU_RS_task_struct),

	    // SQ interface
		.SQ_tail_index(tb_SQ_tail_index),
		.SQ_full(tb_SQ_full),
		.SQ_task_valid(DUT_SQ_task_valid),
		.SQ_task_struct(DUT_SQ_task_struct),

	    // LQ interface
		.LQ_tail_index(tb_LQ_tail_index),
		.LQ_full(tb_LQ_full),
		.LQ_task_valid(DUT_LQ_task_valid),
		.LQ_task_struct(DUT_LQ_task_struct),

	    // BRU RS interface
		.BRU_RS_full(tb_BRU_RS_full),
		.BRU_RS_task_valid(DUT_BRU_RS_task_valid),
		.BRU_RS_task_struct(DUT_BRU_RS_task_struct)
	);
	`else

	// // mapped enum types to explicitly cast to
	// typedef logic [3:0] four_wide_t;
	// typedef logic [1:0] two_wide_t;
	// typedef logic one_wide_t;

	// signals for type cast
	logic [3:0] DUT_ALU_RS_task_struct_0_op_casted;
	logic [3:0] DUT_ALU_RS_task_struct_1_op_casted;
	logic [1:0] DUT_LQ_task_struct_op_casted;
	logic DUT_SQ_task_struct_op_casted;
	logic [1:0] DUT_BRU_RS_task_struct_op_casted;

	// assign enum to pure logic array
	assign DUT_ALU_RS_task_struct[0].op = ALU_op_t'(DUT_ALU_RS_task_struct_0_op_casted);
	assign DUT_ALU_RS_task_struct[1].op = ALU_op_t'(DUT_ALU_RS_task_struct_1_op_casted);
	assign DUT_LQ_task_struct.op = LQ_op_t'(DUT_LQ_task_struct_op_casted);
	assign DUT_SQ_task_struct.op = SQ_op_t'(DUT_SQ_task_struct_op_casted);
	assign DUT_BRU_RS_task_struct.op = BRU_op_t'(DUT_BRU_RS_task_struct_op_casted);

	dispatch_unit DUT (
		
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // core control interface
		.core_control_stall_dispatch_unit(tb_core_control_stall_dispatch_unit),
		.core_control_flush_dispatch_unit(tb_core_control_flush_dispatch_unit),
		.core_control_halt(tb_core_control_halt),
		.core_control_dispatch_failed(DUT_core_control_dispatch_failed),

	    // fetch_unit interface
		.fetch_unit_instr(tb_fetch_unit_instr),
		.fetch_unit_ivalid(tb_fetch_unit_ivalid),
		.fetch_unit_PC(tb_fetch_unit_PC),
		.fetch_unit_nPC(tb_fetch_unit_nPC),

	    // restore interface
		.restore_checkpoint_valid(tb_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(tb_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(tb_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(tb_restore_checkpoint_safe_column),
		.restore_checkpoint_success(DUT_restore_checkpoint_success),

	    // kill bus interface
	        // kill for ROB_index, T, T_old
		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),
	        // actually don't need this, only need ROB index for execution unit kills
		.kill_bus_arch_reg_tag(tb_kill_bus_arch_reg_tag),
		.kill_bus_speculated_phys_reg_tag(tb_kill_bus_speculated_phys_reg_tag),
		.kill_bus_safe_phys_reg_tag(tb_kill_bus_safe_phys_reg_tag),

	    // complete bus interface
	        // 2x ready @ T
		.complete_bus_0_valid(tb_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(tb_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_1_valid(tb_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(tb_complete_bus_1_dest_phys_reg_tag),
		.complete_bus_2_valid(tb_complete_bus_2_valid),
		.complete_bus_2_dest_phys_reg_tag(tb_complete_bus_2_dest_phys_reg_tag),

	    // ROB interface
	    // dispatch @ tail
		.ROB_full(tb_ROB_full),
		.ROB_tail_index(tb_ROB_tail_index),
		.ROB_enqueue_valid(DUT_ROB_enqueue_valid),
		// struct -> need to enumerate
		.\ROB_struct_out.valid (DUT_ROB_struct_out.valid),
		.\ROB_struct_out.complete (DUT_ROB_struct_out.complete),
		.\ROB_struct_out.dispatched_unit.DU_ALU_0 (DUT_ROB_struct_out.dispatched_unit.DU_ALU_0),
		.\ROB_struct_out.dispatched_unit.DU_ALU_1 (DUT_ROB_struct_out.dispatched_unit.DU_ALU_1),
		.\ROB_struct_out.dispatched_unit.DU_LQ (DUT_ROB_struct_out.dispatched_unit.DU_LQ),
		.\ROB_struct_out.dispatched_unit.DU_SQ (DUT_ROB_struct_out.dispatched_unit.DU_SQ),
		.\ROB_struct_out.dispatched_unit.DU_BRU (DUT_ROB_struct_out.dispatched_unit.DU_BRU),
		.\ROB_struct_out.dispatched_unit.DU_J (DUT_ROB_struct_out.dispatched_unit.DU_J),
		.\ROB_struct_out.dispatched_unit.DU_DEAD (DUT_ROB_struct_out.dispatched_unit.DU_DEAD),
		.\ROB_struct_out.dispatched_unit.DU_HALT (DUT_ROB_struct_out.dispatched_unit.DU_HALT),
		.\ROB_struct_out.restart_PC (DUT_ROB_struct_out.restart_PC),
		.\ROB_struct_out.reg_write (DUT_ROB_struct_out.reg_write),
		.\ROB_struct_out.dest_arch_reg_tag (DUT_ROB_struct_out.dest_arch_reg_tag),
		.\ROB_struct_out.safe_dest_phys_reg_tag (DUT_ROB_struct_out.safe_dest_phys_reg_tag),
		.\ROB_struct_out.speculated_dest_phys_reg_tag (DUT_ROB_struct_out.speculated_dest_phys_reg_tag),
	    // retire from head
		.ROB_retire_valid(tb_ROB_retire_valid),
		.ROB_retire_phys_reg_tag(tb_ROB_retire_phys_reg_tag),

	    // 2x ALU RS interface
		.ALU_RS_full(tb_ALU_RS_full),
		.ALU_RS_task_valid(DUT_ALU_RS_task_valid),
		// struct -> need to enumerate
			// need to typecast enum's as well
		.\ALU_RS_task_struct[0].op (DUT_ALU_RS_task_struct_0_op_casted),
		.\ALU_RS_task_struct[0].itype (DUT_ALU_RS_task_struct[0].itype),
		.\ALU_RS_task_struct[0].source_0.needed (DUT_ALU_RS_task_struct[0].source_0.needed),
		.\ALU_RS_task_struct[0].source_0.ready (DUT_ALU_RS_task_struct[0].source_0.ready),
		.\ALU_RS_task_struct[0].source_0.phys_reg_tag (DUT_ALU_RS_task_struct[0].source_0.phys_reg_tag),
		.\ALU_RS_task_struct[0].source_1.needed (DUT_ALU_RS_task_struct[0].source_1.needed),
		.\ALU_RS_task_struct[0].source_1.ready (DUT_ALU_RS_task_struct[0].source_1.ready),
		.\ALU_RS_task_struct[0].source_1.phys_reg_tag (DUT_ALU_RS_task_struct[0].source_1.phys_reg_tag),
		.\ALU_RS_task_struct[0].dest_phys_reg_tag (DUT_ALU_RS_task_struct[0].dest_phys_reg_tag),
		.\ALU_RS_task_struct[0].imm16 (DUT_ALU_RS_task_struct[0].imm16),
		.\ALU_RS_task_struct[0].ROB_index (DUT_ALU_RS_task_struct[0].ROB_index),
		// struct -> need to enumerate
			// need to typecast enum's as well
		.\ALU_RS_task_struct[1].op (DUT_ALU_RS_task_struct_1_op_casted),
		.\ALU_RS_task_struct[1].itype (DUT_ALU_RS_task_struct[1].itype),
		.\ALU_RS_task_struct[1].source_0.needed (DUT_ALU_RS_task_struct[1].source_0.needed),
		.\ALU_RS_task_struct[1].source_0.ready (DUT_ALU_RS_task_struct[1].source_0.ready),
		.\ALU_RS_task_struct[1].source_0.phys_reg_tag (DUT_ALU_RS_task_struct[1].source_0.phys_reg_tag),
		.\ALU_RS_task_struct[1].source_1.needed (DUT_ALU_RS_task_struct[1].source_1.needed),
		.\ALU_RS_task_struct[1].source_1.ready (DUT_ALU_RS_task_struct[1].source_1.ready),
		.\ALU_RS_task_struct[1].source_1.phys_reg_tag (DUT_ALU_RS_task_struct[1].source_1.phys_reg_tag),
		.\ALU_RS_task_struct[1].dest_phys_reg_tag (DUT_ALU_RS_task_struct[1].dest_phys_reg_tag),
		.\ALU_RS_task_struct[1].imm16 (DUT_ALU_RS_task_struct[1].imm16),
		.\ALU_RS_task_struct[1].ROB_index (DUT_ALU_RS_task_struct[1].ROB_index),

	    // SQ interface
		.SQ_tail_index(tb_SQ_tail_index),
		.SQ_full(tb_SQ_full),
		.SQ_task_valid(DUT_SQ_task_valid),
		// struct -> need to enumerate
			// need to typecast enum's as well
		.\SQ_task_struct.op (DUT_SQ_task_struct_op_casted),
		.\SQ_task_struct.source_0.needed (DUT_SQ_task_struct.source_0.needed),
		.\SQ_task_struct.source_0.ready (DUT_SQ_task_struct.source_0.ready),
		.\SQ_task_struct.source_0.phys_reg_tag (DUT_SQ_task_struct.source_0.phys_reg_tag),
		.\SQ_task_struct.source_1.needed (DUT_SQ_task_struct.source_1.needed),
		.\SQ_task_struct.source_1.ready (DUT_SQ_task_struct.source_1.ready),
		.\SQ_task_struct.source_1.phys_reg_tag (DUT_SQ_task_struct.source_1.phys_reg_tag),
		.\SQ_task_struct.imm14 (DUT_SQ_task_struct.imm14),
		.\SQ_task_struct.LQ_index (DUT_SQ_task_struct.LQ_index),
		.\SQ_task_struct.ROB_index (DUT_SQ_task_struct.ROB_index),

	    // LQ interface
		.LQ_tail_index(tb_LQ_tail_index),
		.LQ_full(tb_LQ_full),
		.LQ_task_valid(DUT_LQ_task_valid),
		// struct -> need to enumerate
			// need to typecast enum's as well
		.\LQ_task_struct.op (DUT_LQ_task_struct_op_casted),
		.\LQ_task_struct.source.needed (DUT_LQ_task_struct.source.needed),
		.\LQ_task_struct.source.ready (DUT_LQ_task_struct.source.ready),
		.\LQ_task_struct.source.phys_reg_tag (DUT_LQ_task_struct.source.phys_reg_tag),
		.\LQ_task_struct.dest_phys_reg_tag (DUT_LQ_task_struct.dest_phys_reg_tag),
		.\LQ_task_struct.imm14 (DUT_LQ_task_struct.imm14),
		.\LQ_task_struct.SQ_index (DUT_LQ_task_struct.SQ_index),
		.\LQ_task_struct.ROB_index (DUT_LQ_task_struct.ROB_index),

	    // BRU RS interface
		.BRU_RS_full(tb_BRU_RS_full),
		.BRU_RS_task_valid(DUT_BRU_RS_task_valid),
		// struct -> need to enumerate
			// need to typecast enum's as well
		.\BRU_RS_task_struct.op (DUT_BRU_RS_task_struct_op_casted),
		.\BRU_RS_task_struct.source_0.needed (DUT_BRU_RS_task_struct.source_0.needed),
		.\BRU_RS_task_struct.source_0.ready (DUT_BRU_RS_task_struct.source_0.ready),
		.\BRU_RS_task_struct.source_0.phys_reg_tag (DUT_BRU_RS_task_struct.source_0.phys_reg_tag),
		.\BRU_RS_task_struct.source_1.needed (DUT_BRU_RS_task_struct.source_1.needed),
		.\BRU_RS_task_struct.source_1.ready (DUT_BRU_RS_task_struct.source_1.ready),
		.\BRU_RS_task_struct.source_1.phys_reg_tag (DUT_BRU_RS_task_struct.source_1.phys_reg_tag),
		.\BRU_RS_task_struct.imm16 (DUT_BRU_RS_task_struct.imm16),
		.\BRU_RS_task_struct.PC (DUT_BRU_RS_task_struct.PC),
		.\BRU_RS_task_struct.nPC (DUT_BRU_RS_task_struct.nPC),
		.\BRU_RS_task_struct.checkpoint_safe_column (DUT_BRU_RS_task_struct.checkpoint_safe_column),
		.\BRU_RS_task_struct.ROB_index (DUT_BRU_RS_task_struct.ROB_index)
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

		if (expected_core_control_dispatch_failed !== DUT_core_control_dispatch_failed) begin
			$display("TB ERROR: expected_core_control_dispatch_failed (%h) != DUT_core_control_dispatch_failed (%h)",
				expected_core_control_dispatch_failed, DUT_core_control_dispatch_failed);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_restore_checkpoint_success !== DUT_restore_checkpoint_success) begin
			$display("TB ERROR: expected_restore_checkpoint_success (%h) != DUT_restore_checkpoint_success (%h)",
				expected_restore_checkpoint_success, DUT_restore_checkpoint_success);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_enqueue_valid !== DUT_ROB_enqueue_valid) begin
			$display("TB ERROR: expected_ROB_enqueue_valid (%h) != DUT_ROB_enqueue_valid (%h)",
				expected_ROB_enqueue_valid, DUT_ROB_enqueue_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_struct_out !== DUT_ROB_struct_out) begin
			$display("TB ERROR: expected_ROB_struct_out (%h) != DUT_ROB_struct_out (%h)",
				expected_ROB_struct_out, DUT_ROB_struct_out);
			$display("\texpected.valid = %h, DUT.valid = %h", expected_ROB_struct_out.valid, DUT_ROB_struct_out.valid);
			$display("\texpected.complete = %h, DUT.complete = %h", expected_ROB_struct_out.complete, DUT_ROB_struct_out.complete);
			$display("\texpected.dispatched_unit.DU_ALU_0 = %h, DUT.dispatched_unit.DU_ALU_0 = %h", expected_ROB_struct_out.dispatched_unit.DU_ALU_0, DUT_ROB_struct_out.dispatched_unit.DU_ALU_0);
			$display("\texpected.dispatched_unit.DU_ALU_1 = %h, DUT.dispatched_unit.DU_ALU_1 = %h", expected_ROB_struct_out.dispatched_unit.DU_ALU_1, DUT_ROB_struct_out.dispatched_unit.DU_ALU_1);
			$display("\texpected.dispatched_unit.DU_LQ = %h, DUT.dispatched_unit.DU_LQ = %h", expected_ROB_struct_out.dispatched_unit.DU_LQ, DUT_ROB_struct_out.dispatched_unit.DU_LQ);
			$display("\texpected.dispatched_unit.DU_SQ = %h, DUT.dispatched_unit.DU_SQ = %h", expected_ROB_struct_out.dispatched_unit.DU_SQ, DUT_ROB_struct_out.dispatched_unit.DU_SQ);
			$display("\texpected.dispatched_unit.DU_BRU = %h, DUT.dispatched_unit.DU_BRU = %h", expected_ROB_struct_out.dispatched_unit.DU_BRU, DUT_ROB_struct_out.dispatched_unit.DU_BRU);
			$display("\texpected.dispatched_unit.DU_J = %h, DUT.dispatched_unit.DU_J = %h", expected_ROB_struct_out.dispatched_unit.DU_J, DUT_ROB_struct_out.dispatched_unit.DU_J);
			$display("\texpected.dispatched_unit.DU_DEAD = %h, DUT.dispatched_unit.DU_DEAD = %h", expected_ROB_struct_out.dispatched_unit.DU_DEAD, DUT_ROB_struct_out.dispatched_unit.DU_DEAD);
			$display("\texpected.dispatched_unit.DU_HALT = %h, DUT.dispatched_unit.DU_HALT = %h", expected_ROB_struct_out.dispatched_unit.DU_HALT, DUT_ROB_struct_out.dispatched_unit.DU_HALT);
			$display("\texpected.restart_PC = %d, DUT.restart_PC = %d", expected_ROB_struct_out.restart_PC, DUT_ROB_struct_out.restart_PC);
			$display("\texpected.reg_write = %h, DUT.reg_write = %h", expected_ROB_struct_out.reg_write, DUT_ROB_struct_out.reg_write);
			$display("\texpected.dest_arch_reg_tag = %d, DUT.dest_arch_reg_tag = %d", expected_ROB_struct_out.dest_arch_reg_tag, DUT_ROB_struct_out.dest_arch_reg_tag);
			$display("\texpected.safe_dest_phys_reg_tag = %d, DUT.safe_dest_phys_reg_tag = %d", expected_ROB_struct_out.safe_dest_phys_reg_tag, DUT_ROB_struct_out.safe_dest_phys_reg_tag);
			$display("\texpected.speculated_dest_phys_reg_tag = %d, DUT.speculated_dest_phys_reg_tag = %d", expected_ROB_struct_out.speculated_dest_phys_reg_tag, DUT_ROB_struct_out.speculated_dest_phys_reg_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_RS_task_valid !== DUT_ALU_RS_task_valid) begin
			$display("TB ERROR: expected_ALU_RS_task_valid (%h) != DUT_ALU_RS_task_valid (%h)",
				expected_ALU_RS_task_valid, DUT_ALU_RS_task_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ALU_RS_task_struct !== DUT_ALU_RS_task_struct) begin
			$display("TB ERROR: expected_ALU_RS_task_struct (%h) != DUT_ALU_RS_task_struct (%h)",
				expected_ALU_RS_task_struct, DUT_ALU_RS_task_struct);
			num_errors++;
			$display("\texpected[0].op = %h, DUT.op = %h", expected_ALU_RS_task_struct[0].op, DUT_ALU_RS_task_struct[0].op);
			$display("\texpected[0].itype = %h, DUT.itype = %h", expected_ALU_RS_task_struct[0].itype, DUT_ALU_RS_task_struct[0].itype);
			$display("\texpected[0].source_0.needed = %h, DUT.source_0.needed = %h", expected_ALU_RS_task_struct[0].source_0.needed, DUT_ALU_RS_task_struct[0].source_0.needed);
			$display("\texpected[0].source_0.ready = %h, DUT.source_0.ready = %h", expected_ALU_RS_task_struct[0].source_0.ready, DUT_ALU_RS_task_struct[0].source_0.ready);
			$display("\texpected[0].source_0.phys_reg_tag = %d, DUT.source_0.phys_reg_tag = %d", expected_ALU_RS_task_struct[0].source_0.phys_reg_tag, DUT_ALU_RS_task_struct[0].source_0.phys_reg_tag);
			$display("\texpected[0].source_1.needed = %h, DUT.source_1.needed = %h", expected_ALU_RS_task_struct[0].source_1.needed, DUT_ALU_RS_task_struct[0].source_1.needed);
			$display("\texpected[0].source_1.ready = %h, DUT.source_1.ready = %h", expected_ALU_RS_task_struct[0].source_1.ready, DUT_ALU_RS_task_struct[0].source_1.ready);
			$display("\texpected[0].source_1.phys_reg_tag = %d, DUT.source_1.phys_reg_tag = %d", expected_ALU_RS_task_struct[0].source_1.phys_reg_tag, DUT_ALU_RS_task_struct[0].source_1.phys_reg_tag);
			$display("\texpected[0].dest_phys_reg_tag = %d, DUT.dest_phys_reg_tag = %d", expected_ALU_RS_task_struct[0].dest_phys_reg_tag, DUT_ALU_RS_task_struct[0].dest_phys_reg_tag);
			$display("\texpected[0].imm16 = %h, DUT.imm16 = %h", expected_ALU_RS_task_struct[0].imm16, DUT_ALU_RS_task_struct[0].imm16);
			$display("\texpected[0].ROB_index = %d, DUT.ROB_index = %d", expected_ALU_RS_task_struct[0].ROB_index, DUT_ALU_RS_task_struct[0].ROB_index);
			$display("\texpected[1].op = %h, DUT.op = %h", expected_ALU_RS_task_struct[1].op, DUT_ALU_RS_task_struct[1].op);
			$display("\texpected[1].itype = %h, DUT.itype = %h", expected_ALU_RS_task_struct[1].itype, DUT_ALU_RS_task_struct[1].itype);
			$display("\texpected[1].source_0.needed = %h, DUT.source_0.needed = %h", expected_ALU_RS_task_struct[1].source_0.needed, DUT_ALU_RS_task_struct[1].source_0.needed);
			$display("\texpected[1].source_0.ready = %h, DUT.source_0.ready = %h", expected_ALU_RS_task_struct[1].source_0.ready, DUT_ALU_RS_task_struct[1].source_0.ready);
			$display("\texpected[1].source_0.phys_reg_tag = %d, DUT.source_0.phys_reg_tag = %d", expected_ALU_RS_task_struct[1].source_0.phys_reg_tag, DUT_ALU_RS_task_struct[1].source_0.phys_reg_tag);
			$display("\texpected[1].source_1.needed = %h, DUT.source_1.needed = %h", expected_ALU_RS_task_struct[1].source_1.needed, DUT_ALU_RS_task_struct[1].source_1.needed);
			$display("\texpected[1].source_1.ready = %h, DUT.source_1.ready = %h", expected_ALU_RS_task_struct[1].source_1.ready, DUT_ALU_RS_task_struct[1].source_1.ready);
			$display("\texpected[1].source_1.phys_reg_tag = %d, DUT.source_1.phys_reg_tag = %d", expected_ALU_RS_task_struct[1].source_1.phys_reg_tag, DUT_ALU_RS_task_struct[1].source_1.phys_reg_tag);
			$display("\texpected[1].dest_phys_reg_tag = %d, DUT.dest_phys_reg_tag = %d", expected_ALU_RS_task_struct[1].dest_phys_reg_tag, DUT_ALU_RS_task_struct[1].dest_phys_reg_tag);
			$display("\texpected[1].imm16 = %h, DUT.imm16 = %h", expected_ALU_RS_task_struct[1].imm16, DUT_ALU_RS_task_struct[1].imm16);
			$display("\texpected[1].ROB_index = %d, DUT.ROB_index = %d", expected_ALU_RS_task_struct[1].ROB_index, DUT_ALU_RS_task_struct[1].ROB_index);
			tb_error = 1'b1;
		end

		if (expected_LQ_task_valid !== DUT_LQ_task_valid) begin
			$display("TB ERROR: expected_LQ_task_valid (%h) != DUT_LQ_task_valid (%h)",
				expected_LQ_task_valid, DUT_LQ_task_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_task_struct !== DUT_LQ_task_struct) begin
			$display("TB ERROR: expected_LQ_task_struct (%h) != DUT_LQ_task_struct (%h)",
				expected_LQ_task_struct, DUT_LQ_task_struct);
			$display("\texpected.op = %h, DUT.op = %h", expected_LQ_task_struct.op, DUT_LQ_task_struct.op);
			$display("\texpected.source.needed = %h, DUT.source.needed = %h", expected_LQ_task_struct.source.needed, DUT_LQ_task_struct.source.needed);
			$display("\texpected.source.ready = %h, DUT.source.ready = %h", expected_LQ_task_struct.source.ready, DUT_LQ_task_struct.source.ready);
			$display("\texpected.source.phys_reg_tag = %d, DUT.source.phys_reg_tag = %d", expected_LQ_task_struct.source.phys_reg_tag, DUT_LQ_task_struct.source.phys_reg_tag);
			$display("\texpected.dest_phys_reg_tag = %d, DUT.dest_phys_reg_tag = %d", expected_LQ_task_struct.dest_phys_reg_tag, DUT_LQ_task_struct.dest_phys_reg_tag);
			$display("\texpected.imm14 = %h, DUT.imm14 = %h", expected_LQ_task_struct.imm14, DUT_LQ_task_struct.imm14);
			$display("\texpected.SQ_index = %d, DUT.SQ_index = %d", expected_LQ_task_struct.SQ_index, DUT_LQ_task_struct.SQ_index);
			$display("\texpected.ROB_index = %d, DUT.ROB_index = %d", expected_LQ_task_struct.ROB_index, DUT_LQ_task_struct.ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_task_valid !== DUT_SQ_task_valid) begin
			$display("TB ERROR: expected_SQ_task_valid (%h) != DUT_SQ_task_valid (%h)",
				expected_SQ_task_valid, DUT_SQ_task_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_task_struct !== DUT_SQ_task_struct) begin
			$display("TB ERROR: expected_SQ_task_struct (%h) != DUT_SQ_task_struct (%h)",
				expected_SQ_task_struct, DUT_SQ_task_struct);
			$display("\texpected.op = %h, DUT.op = %h", expected_SQ_task_struct.op, DUT_SQ_task_struct.op);
			$display("\texpected.source_0.needed = %h, DUT.source_0.needed = %h", expected_SQ_task_struct.source_0.needed, DUT_SQ_task_struct.source_0.needed);
			$display("\texpected.source_0.ready = %h, DUT.source_0.ready = %h", expected_SQ_task_struct.source_0.ready, DUT_SQ_task_struct.source_0.ready);
			$display("\texpected.source_0.phys_reg_tag = %d, DUT.source_0.phys_reg_tag = %d", expected_SQ_task_struct.source_0.phys_reg_tag, DUT_SQ_task_struct.source_0.phys_reg_tag);
			$display("\texpected.source_1.needed = %h, DUT.source_1.needed = %h", expected_SQ_task_struct.source_1.needed, DUT_SQ_task_struct.source_1.needed);
			$display("\texpected.source_1.ready = %h, DUT.source_1.ready = %h", expected_SQ_task_struct.source_1.ready, DUT_SQ_task_struct.source_1.ready);
			$display("\texpected.source_1.phys_reg_tag = %d, DUT.source_1.phys_reg_tag = %d", expected_SQ_task_struct.source_1.phys_reg_tag, DUT_SQ_task_struct.source_1.phys_reg_tag);
			$display("\texpected.imm14 = %h, DUT.imm14 = %h", expected_SQ_task_struct.imm14, DUT_SQ_task_struct.imm14);
			$display("\texpected.LQ_index = %d, DUT.LQ_index = %d", expected_SQ_task_struct.LQ_index, DUT_SQ_task_struct.LQ_index);
			$display("\texpected.ROB_index = %d, DUT.ROB_index = %d", expected_SQ_task_struct.ROB_index, DUT_SQ_task_struct.ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_BRU_RS_task_valid !== DUT_BRU_RS_task_valid) begin
			$display("TB ERROR: expected_BRU_RS_task_valid (%h) != DUT_BRU_RS_task_valid (%h)",
				expected_BRU_RS_task_valid, DUT_BRU_RS_task_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_BRU_RS_task_struct !== DUT_BRU_RS_task_struct) begin
			$display("TB ERROR: expected_BRU_RS_task_struct (%h) != DUT_BRU_RS_task_struct (%h)",
				expected_BRU_RS_task_struct, DUT_BRU_RS_task_struct);
			$display("\texpected.op = %h, DUT.op = %h", expected_BRU_RS_task_struct.op, DUT_BRU_RS_task_struct.op);
			$display("\texpected.source_0.needed = %h, DUT.source_0.needed = %h", expected_BRU_RS_task_struct.source_0.needed, DUT_BRU_RS_task_struct.source_0.needed);
			$display("\texpected.source_0.ready = %h, DUT.source_0.ready = %h", expected_BRU_RS_task_struct.source_0.ready, DUT_BRU_RS_task_struct.source_0.ready);
			$display("\texpected.source_0.phys_reg_tag = %d, DUT.source_0.phys_reg_tag = %d", expected_BRU_RS_task_struct.source_0.phys_reg_tag, DUT_BRU_RS_task_struct.source_0.phys_reg_tag);
			$display("\texpected.source_1.needed = %h, DUT.source_1.needed = %h", expected_BRU_RS_task_struct.source_1.needed, DUT_BRU_RS_task_struct.source_1.needed);
			$display("\texpected.source_1.ready = %h, DUT.source_1.ready = %h", expected_BRU_RS_task_struct.source_1.ready, DUT_BRU_RS_task_struct.source_1.ready);
			$display("\texpected.source_1.phys_reg_tag = %d, DUT.source_1.phys_reg_tag = %d", expected_BRU_RS_task_struct.source_1.phys_reg_tag, DUT_BRU_RS_task_struct.source_1.phys_reg_tag);
			$display("\texpected.imm16 = %h, DUT.imm16 = %h", expected_BRU_RS_task_struct.imm16, DUT_BRU_RS_task_struct.imm16);
			$display("\texpected.PC = %d, DUT.PC = %d", expected_BRU_RS_task_struct.PC, DUT_BRU_RS_task_struct.PC);
			$display("\texpected.nPC = %d, DUT.nPC = %d", expected_BRU_RS_task_struct.nPC, DUT_BRU_RS_task_struct.nPC);
			$display("\texpected.checkpoint_safe_column = %h, DUT.checkpoint_safe_column = %h", expected_BRU_RS_task_struct.checkpoint_safe_column, DUT_BRU_RS_task_struct.checkpoint_safe_column);
			$display("\texpected.ROB_index = %d, DUT.ROB_index = %d", expected_BRU_RS_task_struct.ROB_index, DUT_BRU_RS_task_struct.ROB_index);
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
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = word_t'(0);
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(0);
		tb_fetch_unit_nPC = pc_t'(0);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0; 
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_valid = 1'b0;
		tb_complete_bus_2_dest_phys_reg_tag = phys_reg_tag_t'(0);
			// don't bother changing entire tb, complete bus 2 tested enough in phys_reg_ready_table
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.imm14 = daddr_t'(0);
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = daddr_t'(0);
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = word_t'(0);
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(0);
		tb_fetch_unit_nPC = pc_t'(0);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0; 
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.imm14 = daddr_t'(0);
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = daddr_t'(0);
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

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
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = word_t'(0);
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(0);
		tb_fetch_unit_nPC = pc_t'(0);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0; 
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.imm14 = daddr_t'(0);
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = daddr_t'(0);
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // strobe instructions:
        test_case = "strobe instructions";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "0: ADDU r1->p1/p32, r2->p2, r3->p3 in | 0: nop out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd3, 5'd1, 5'd0, 6'b100001};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(0);
		tb_fetch_unit_nPC = pc_t'(1);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.imm14 = daddr_t'(0);
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = daddr_t'(0);
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "1: ADD r2->p2/p33, r2->p2, r5->p5 in | 0: ADDU r1->p1/p32, r2->p2, r3->p3 out (RS 0)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(1);
		tb_fetch_unit_nPC = pc_t'(2);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(1);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(1);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(32);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].imm16 = {5'd1, 5'd0, 6'b100001};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].imm16 = {5'd1, 5'd0, 6'b100001};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(2);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.imm14 = daddr_t'({5'd1, 5'd0, 4'b1000});
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_SQ_task_struct.imm14 = daddr_t'({5'd1, 5'd0, 4'b1000});
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_BRU_RS_task_struct.imm16 = {5'd1, 5'd0, 6'b100001};
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(1);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "2: AND r30->p30/p34, r5->p5, r2->p33 in | 1: ADD r2->p2/p33, r2->p2, r5->p5 out (RS 1)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd5, 5'd2, 5'd30, 5'd0, 6'b100100};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(2);
		tb_fetch_unit_nPC = pc_t'(3);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(1);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b01;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(1);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(2);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(2);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(33);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(5);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[0].imm16 = {5'd2, 5'd0, 6'b100000};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(1);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b1;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(5);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[1].imm16 = {5'd2, 5'd0, 6'b100000};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(1);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(2);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        expected_LQ_task_struct.imm14 = daddr_t'({5'd2, 5'd0, 4'b1000});
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(1);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(5);
        expected_SQ_task_struct.imm14 = daddr_t'({5'd2, 5'd0, 4'b1000});
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(1);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(5);
        expected_BRU_RS_task_struct.imm16 = {5'd2, 5'd0, 6'b100000};
        expected_BRU_RS_task_struct.PC = pc_t'(1);
        expected_BRU_RS_task_struct.nPC = pc_t'(2);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(1);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "3: JR r30->p34 in (try) | 2: AND r30->p30/p34, r5->p5, r2->p33 out (fail: RS's full)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd30, 5'd0, 5'd0, 5'd0, 6'b001000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(3);
		tb_fetch_unit_nPC = pc_t'(4);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(2);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b11;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(2);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(30);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(30);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(34);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].imm16 = {5'd30, 5'd0, 6'b100100};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(2);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].imm16 = {5'd30, 5'd0, 6'b100100};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(2);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(5);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.imm14 = daddr_t'({5'd30, 5'd0, 4'b1001});
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(2);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_SQ_task_struct.imm14 = daddr_t'({5'd30, 5'd0, 4'b1001});
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(2);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_BRU_RS_task_struct.imm16 = {5'd30, 5'd0, 6'b100100};
        expected_BRU_RS_task_struct.PC = pc_t'(2);
        expected_BRU_RS_task_struct.nPC = pc_t'(3);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(2);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "3: JR r30->p34 in (accept this time) | 2: AND r30->p30/p34, r5->p5, r2->p33 out (RS 0)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd30, 5'd0, 5'd0, 5'd0, 6'b001000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(3);
		tb_fetch_unit_nPC = pc_t'(36);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(2);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b10;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(2);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(30);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(30);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(34);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_AND;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].imm16 = {5'd30, 5'd0, 6'b100100};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(2);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].imm16 = {5'd30, 5'd0, 6'b100100};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(2);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(5);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.imm14 = daddr_t'({5'd30, 5'd0, 4'b1001});
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(2);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_SQ_task_struct.imm14 = daddr_t'({5'd30, 5'd0, 4'b1001});
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(2);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(33);
        expected_BRU_RS_task_struct.imm16 = {5'd30, 5'd0, 6'b100100};
        expected_BRU_RS_task_struct.PC = pc_t'(2);
        expected_BRU_RS_task_struct.nPC = pc_t'(3);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(2);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "36: NOR r13-p13/p35, r6->p6, r19->p19 in | 3: JR r30->p34 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd6, 5'd19, 5'd13, 5'd28, 6'b100111};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(36);
		tb_fetch_unit_nPC = pc_t'(37);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(3);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b10;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(3);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(35);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[0].imm16 = {5'd0, 5'd0, 6'b001000};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(3);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[1].imm16 = {5'd0, 5'd0, 6'b001000};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(3);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(35);
        expected_LQ_task_struct.imm14 = daddr_t'({5'd0, 5'd0, 4'b0010});
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(3);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = daddr_t'({5'd0, 5'd0, 4'b0010});
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(3);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b1;
		expected_BRU_RS_task_struct.op = BRU_JR;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b0;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = {5'd0, 5'd0, 6'b001000};
        expected_BRU_RS_task_struct.PC = pc_t'(3);
        expected_BRU_RS_task_struct.nPC = pc_t'(36);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(3);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "05|37: OR r14->p14/p36, r0->p0, r21->p21 in (no ivalid) | 04|36: NOR r13-p13/p35, r6->p6, r19->p19 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd0, 5'd21, 5'd14, 5'd0, 6'b100101};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(37);
		tb_fetch_unit_nPC = pc_t'(37);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(4);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(36);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(13);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(13);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(35);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_NOR;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(6);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(19);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[0].imm16 = {5'd13, 5'd28, 6'b100111};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(4);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(6);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(19);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[1].imm16 = {5'd13, 5'd28, 6'b100111};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(4);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(6);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(35);
        expected_LQ_task_struct.imm14 = daddr_t'({5'd13, 5'd28, 4'b1001});
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(6);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        expected_SQ_task_struct.imm14 = daddr_t'({5'd13, 5'd28, 4'b1001});
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(4);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(6);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        expected_BRU_RS_task_struct.imm16 = {5'd13, 5'd28, 6'b100111};
        expected_BRU_RS_task_struct.PC = pc_t'(36);
        expected_BRU_RS_task_struct.nPC = pc_t'(37);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(4);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "05|37: OR r14->p14/p36, r0->p0, r21->p21 in (now ivalid) | 05|37: OR r14->p14/p36, r0->p0, r21->p21 out (no ivalid)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd0, 5'd21, 5'd14, 5'd0, 6'b100101};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(37);
		tb_fetch_unit_nPC = pc_t'(38);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(5);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(37);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(14);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(14);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(36);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(36);
        expected_ALU_RS_task_struct[0].imm16 = {5'd14, 5'd0, 6'b100101};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(5);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(36);
        expected_ALU_RS_task_struct[1].imm16 = {5'd14, 5'd0, 6'b100101};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(5);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        expected_LQ_task_struct.imm14 = {5'd14, 5'd0, 4'b1001};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(5);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_SQ_task_struct.imm14 = {5'd14, 5'd0, 4'b1001};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(5);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_BRU_RS_task_struct.imm16 = {5'd14, 5'd0, 6'b100101};
        expected_BRU_RS_task_struct.PC = pc_t'(37);
        expected_BRU_RS_task_struct.nPC = pc_t'(37);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(5);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "06|38: SLT r15->p15/p37, r25->p25, r1->p32 in | 05|37: OR r14->p14/p36, r0->p0, r21->p21 out (now ivalid)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd25, 5'd1, 5'd15, 5'd0, 6'b101010};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(38);
		tb_fetch_unit_nPC = pc_t'(39);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(5);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(37);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(14);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(14);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(36);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_OR;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(36);
        expected_ALU_RS_task_struct[0].imm16 = {5'd14, 5'd0, 6'b100101};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(5);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(36);
        expected_ALU_RS_task_struct[1].imm16 = {5'd14, 5'd0, 6'b100101};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(5);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        expected_LQ_task_struct.imm14 = {5'd14, 5'd0, 4'b1001};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(5);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_SQ_task_struct.imm14 = {5'd14, 5'd0, 4'b1001};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(5);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        expected_BRU_RS_task_struct.imm16 = {5'd14, 5'd0, 6'b100101};
        expected_BRU_RS_task_struct.PC = pc_t'(37);
        expected_BRU_RS_task_struct.nPC = pc_t'(38);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(5);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "07|39: SLTU r16->p16/p38, r22->p22, r13->p35 in | 06|38: SLT r15->p15/p37, r25->p25, r1->p32 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd22, 5'd13, 5'd16, 5'd0, 6'b101011};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(39);
		tb_fetch_unit_nPC = pc_t'(40);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(6);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(38);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(15);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(15);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(37);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SLT;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(37);
        expected_ALU_RS_task_struct[0].imm16 = {5'd15, 5'd0, 6'b101010};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(6);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(37);
        expected_ALU_RS_task_struct[1].imm16 = {5'd15, 5'd0, 6'b101010};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(6);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(25);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(37);
        expected_LQ_task_struct.imm14 = {5'd15, 5'd0, 4'b1010};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(6);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(32);
        expected_SQ_task_struct.imm14 = {5'd15, 5'd0, 4'b1010};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(6);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(32);
        expected_BRU_RS_task_struct.imm16 = {5'd15, 5'd0, 6'b101010};
        expected_BRU_RS_task_struct.PC = pc_t'(38);
        expected_BRU_RS_task_struct.nPC = pc_t'(39);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(6);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "08|40: SLLV r17->p17/p39, r2->p33, r16->p38 in | 07|39: SLTU r16->p16/p38, r22->p22, r13->p35 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd16, 5'd17, 5'd0, 6'b000100};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(40);
		tb_fetch_unit_nPC = pc_t'(41);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(7);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(39);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(16);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(16);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(38);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SLTU;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(22);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(38);
        expected_ALU_RS_task_struct[0].imm16 = {5'd16, 5'd0, 6'b101011};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(7);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(22);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(38);
        expected_ALU_RS_task_struct[1].imm16 = {5'd16, 5'd0, 6'b101011};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(7);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(22);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(38);
        expected_LQ_task_struct.imm14 = {5'd16, 5'd0, 4'b1010};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(7);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(22);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(35);
        expected_SQ_task_struct.imm14 = {5'd16, 5'd0, 4'b1010};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(7);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(22);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(35);
        expected_BRU_RS_task_struct.imm16 = {5'd16, 5'd0, 6'b101011};
        expected_BRU_RS_task_struct.PC = pc_t'(39);
        expected_BRU_RS_task_struct.nPC = pc_t'(40);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(7);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "09|41: SRLV r18->p18/p40, r1->p32, r29->p29 in (stall) | 08|40: SLLV r17->p17/p39, r2->p33, r16->p38 out (stall)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b1;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd1, 5'd29, 5'd18, 5'd0, 6'b000110};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(41);
		tb_fetch_unit_nPC = pc_t'(41);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(8);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(40);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(17);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(17);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(39);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(39);
        expected_ALU_RS_task_struct[0].imm16 = {5'd17, 5'd0, 6'b000100};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(8);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(39);
        expected_ALU_RS_task_struct[1].imm16 = {5'd17, 5'd0, 6'b000100};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(8);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(33);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        expected_LQ_task_struct.imm14 = {5'd17, 5'd0, 4'b0001};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(8);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_SQ_task_struct.imm14 = {5'd17, 5'd0, 4'b0001};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(8);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_BRU_RS_task_struct.imm16 = {5'd17, 5'd0, 6'b000100};
        expected_BRU_RS_task_struct.PC = pc_t'(40);
        expected_BRU_RS_task_struct.nPC = pc_t'(41);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(8);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "09|41: SRLV r18->p18/p40, r1->p32, r29->p29 in | 08|40: SLLV r17->p17/p39, r2->p33, r16->p38 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd1, 5'd29, 5'd18, 5'd0, 6'b000110};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(41);
		tb_fetch_unit_nPC = pc_t'(42);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(8);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(40);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(17);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(17);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(39);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SLLV;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(39);
        expected_ALU_RS_task_struct[0].imm16 = {5'd17, 5'd0, 6'b000100};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(8);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(39);
        expected_ALU_RS_task_struct[1].imm16 = {5'd17, 5'd0, 6'b000100};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(8);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(33);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        expected_LQ_task_struct.imm14 = {5'd17, 5'd0, 4'b0001};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(8);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_SQ_task_struct.imm14 = {5'd17, 5'd0, 4'b0001};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(8);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(38);
        expected_BRU_RS_task_struct.imm16 = {5'd17, 5'd0, 6'b000100};
        expected_BRU_RS_task_struct.PC = pc_t'(40);
        expected_BRU_RS_task_struct.nPC = pc_t'(41);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(8);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "10|42: SUBU r19->p19/p41, r15->p37, r17->p39 in | 09|41: SRLV r18->p18/p40, r1->p32, r29->p29 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd15, 5'd17, 5'd19, 5'd0, 6'b100011};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(42);
		tb_fetch_unit_nPC = pc_t'(43);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(9);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(41);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(18);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(18);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(40);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SRLV;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(40);
        expected_ALU_RS_task_struct[0].imm16 = {5'd18, 5'd0, 6'b000110};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(9);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(40);
        expected_ALU_RS_task_struct[1].imm16 = {5'd18, 5'd0, 6'b000110};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(9);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(40);
        expected_LQ_task_struct.imm14 = {5'd18, 5'd0, 4'b0001};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(9);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_SQ_task_struct.imm14 = {5'd18, 5'd0, 4'b0001};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(9);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_BRU_RS_task_struct.imm16 = {5'd18, 5'd0, 6'b000110};
        expected_BRU_RS_task_struct.PC = pc_t'(41);
        expected_BRU_RS_task_struct.nPC = pc_t'(42);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(9);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "11|43: SUB r20->p20/p42, r23->p23, r19->p41 in | 10|42: SUBU r19->p19/p41, r15->p37, r17->p39 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd23, 5'd19, 5'd20, 5'd0, 6'b100010};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(43);
		tb_fetch_unit_nPC = pc_t'(44);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(10);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(42);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(19);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(19);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(41);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SUB;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(37);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(39);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[0].imm16 = {5'd19, 5'd0, 6'b100011};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(10);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(37);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(39);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[1].imm16 = {5'd19, 5'd0, 6'b100011};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(10);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(37);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        expected_LQ_task_struct.imm14 = {5'd19, 5'd0, 4'b1000};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(10);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(37);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(39);
        expected_SQ_task_struct.imm14 = {5'd19, 5'd0, 4'b1000};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(10);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(37);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(39);
        expected_BRU_RS_task_struct.imm16 = {5'd19, 5'd0, 6'b100011};
        expected_BRU_RS_task_struct.PC = pc_t'(42);
        expected_BRU_RS_task_struct.nPC = pc_t'(43);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(10);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "12|44: XOR r21->p21/p43, r0->p0, r0->p0 in | 11|43: SUB r20->p20/p42, r23->p23, r19->p41 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd0, 5'd0, 5'd21, 5'd0, 6'b100110};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(44);
		tb_fetch_unit_nPC = pc_t'(45);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(11);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(43);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(20);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(20);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(42);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SUB;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(23);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(42);
        expected_ALU_RS_task_struct[0].imm16 = {5'd20, 5'd0, 6'b100010};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(11);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(23);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(42);
        expected_ALU_RS_task_struct[1].imm16 = {5'd20, 5'd0, 6'b100010};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(11);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(23);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(42);
        expected_LQ_task_struct.imm14 = {5'd20, 5'd0, 4'b1000};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(11);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(23);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(41);
        expected_SQ_task_struct.imm14 = {5'd20, 5'd0, 4'b1000};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(23);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(41);
        expected_BRU_RS_task_struct.imm16 = {5'd20, 5'd0, 6'b100010};
        expected_BRU_RS_task_struct.PC = pc_t'(43);
        expected_BRU_RS_task_struct.nPC = pc_t'(44);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(11);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "13|45: ADDIU r22->p22/p44, r13->p35, 0x5 in | 12|44: XOR r21->p21/p43, r0->p0, r0->p0 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001001, 5'd13, 5'd22, 16'h5};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(45);
		tb_fetch_unit_nPC = pc_t'(46);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(12);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(44);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(21);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(21);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(43);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_XOR;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(43);
        expected_ALU_RS_task_struct[0].imm16 = {5'd21, 5'd0, 6'b100110};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(12);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(43);
        expected_ALU_RS_task_struct[1].imm16 = {5'd21, 5'd0, 6'b100110};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(12);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(43);
        expected_LQ_task_struct.imm14 = {5'd21, 5'd0, 4'b1001};
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(12);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = {5'd21, 5'd0, 4'b1001};
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = {5'd21, 5'd0, 6'b100110};
        expected_BRU_RS_task_struct.PC = pc_t'(44);
        expected_BRU_RS_task_struct.nPC = pc_t'(45);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(12);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "14|46: ADDI r23->p23/p45, r1->p32, 0x201 in | 13|45: ADDIU r22->p22/p44, r13->p35, 0x5 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001000, 5'd1, 5'd23, 16'h201};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(46);
		tb_fetch_unit_nPC = pc_t'(47);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(13);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(45);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(22);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(22);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0; // this one itype
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(22);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h5;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(13);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1; // this one default
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(22);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h5;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(13);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(35);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h5 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(13);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        expected_SQ_task_struct.imm14 = 16'h5 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(13);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        expected_BRU_RS_task_struct.imm16 = 16'h5;
        expected_BRU_RS_task_struct.PC = pc_t'(45);
        expected_BRU_RS_task_struct.nPC = pc_t'(46);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(13);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "15|47: ANDI r24->p24/p46, r23->p45, 0x71A7 in | 14|46: ADDI r23->p23/p45, r1->p32, 0x201 out (RS 1)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001100, 5'd23, 5'd24, 16'h71a7};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(47);
		tb_fetch_unit_nPC = pc_t'(48);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(14);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b01;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(46);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(23);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(23);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(45);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1; // this one default
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(23);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[0].imm16 = 16'h201;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(14);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b1;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b0; // this one itype
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(23);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[1].imm16 = 16'h201;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(14);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(32);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(45);
        expected_LQ_task_struct.imm14 = 16'h201 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        expected_SQ_task_struct.imm14 = 16'h201 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(14);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(32);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        expected_BRU_RS_task_struct.imm16 = 16'h201;
        expected_BRU_RS_task_struct.PC = pc_t'(46);
        expected_BRU_RS_task_struct.nPC = pc_t'(47);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(14);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "16|48: BEQ r24->p46, r23->p45 (goto 81) in | 15|47: ANDI r24->p24/p46, r23->p45, 0x71A7 out (RS 0)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000100, 5'd24, 5'd23, 16'd64};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(48);
		tb_fetch_unit_nPC = pc_t'(81);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(15);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b10;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(3); // misc val
		tb_SQ_full = 1'b1; // misc full
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(7); // misc val
		tb_LQ_full = 1'b1; // misc full
	    // BRU RS interface
		tb_BRU_RS_full = 1'b1; // misc full

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(47);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(24);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(24);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(46);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_AND;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0; // this one itype
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(24);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(46);
        expected_ALU_RS_task_struct[0].imm16 = 16'h71a7;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(15);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1; // this one default
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(24);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(46);
        expected_ALU_RS_task_struct[1].imm16 = 16'h71a7;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(15);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(45);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(46);
        expected_LQ_task_struct.imm14 = 16'h71a7 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(3);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(15);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(45);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(24);
        expected_SQ_task_struct.imm14 = 16'h71a7 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(7);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(15);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(45);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(24);
        expected_BRU_RS_task_struct.imm16 = 16'h71a7;
        expected_BRU_RS_task_struct.PC = pc_t'(47);
        expected_BRU_RS_task_struct.nPC = pc_t'(48);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(15);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "17|81: BNE r22->p44, r0->p0 (don't goto +0123) in | 16|48: BEQ r24->p46, r23->p45 (goto 81) out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000101, 5'd22, 5'd0, 16'h0123};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(81);
		tb_fetch_unit_nPC = pc_t'(82);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(16);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(48);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(46);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].imm16 = 16'd64;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(16);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(46);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].imm16 = 16'd64;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(16);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(46);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.imm14 = 16'd64 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(16);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(46);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(45);
        expected_SQ_task_struct.imm14 = 16'd64 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(16);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b1;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(46);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(45);
        expected_BRU_RS_task_struct.imm16 = 16'd64;
        expected_BRU_RS_task_struct.PC = pc_t'(48);
        expected_BRU_RS_task_struct.nPC = pc_t'(81);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(16);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "18|82: LUI r25->p25/p47, r14->p36, 0xFEDC in (fail dispatch) | 17|81: BNE r22->p44, r0->p0 (don't goto +0123) out (RS full, fail)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001111, 5'd14, 5'd25, 16'hfedc};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(82);
		tb_fetch_unit_nPC = pc_t'(82);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(17);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b1; // give BRU RS full 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1; // BRU RS full, fail 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(81);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0123;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(17);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0123;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(17);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.imm14 = 16'h0123 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(17);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0123 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0123;
        expected_BRU_RS_task_struct.PC = pc_t'(81);
        expected_BRU_RS_task_struct.nPC = pc_t'(82);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(2);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(17);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "18|82: LUI r25->p25/p47, 0xFEDC in (good dispatch) | 17|81: BNE r22->p44, r0->p0 (don't goto +0123) out (RS now empty)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001111, 5'd14, 5'd25, 16'hfedc};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(82);
		tb_fetch_unit_nPC = pc_t'(83);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(17);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(81);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0123;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(17);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0123;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(17);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.imm14 = 16'h0123 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(17);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0123 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b1;
		expected_BRU_RS_task_struct.op = BRU_BNE;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(44);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0123;
        expected_BRU_RS_task_struct.PC = pc_t'(81);
        expected_BRU_RS_task_struct.nPC = pc_t'(82);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(2);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(17);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "19|83: LW r26->p26/p48, 0x9D4(r19->p41) in | 18|82: LUI r25->p25/p47, 0xFEDC out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b100011, 5'd19, 5'd26, 16'h9d4};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(83);
		tb_fetch_unit_nPC = pc_t'(84);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(18);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(82);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(25);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(25);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_LUI;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(36);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].imm16 = 16'hfedc;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(18);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(36);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].imm16 = 16'hfedc;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(18);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(36);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.imm14 = 16'hfedc >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(36);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        expected_SQ_task_struct.imm14 = 16'hfedc >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(18);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(36);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        expected_BRU_RS_task_struct.imm16 = 16'hfedc;
        expected_BRU_RS_task_struct.PC = pc_t'(82);
        expected_BRU_RS_task_struct.nPC = pc_t'(83);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(18);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "20|84: ORI r27->p27/p49, r25->p47, 0x98 in (LQ full, fail) | 19|83: LW r26->p26/p48, 0x9D4(r19->p41) out (LQ full, fail)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001101, 5'd25, 5'd27, 16'h98};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(84);
		tb_fetch_unit_nPC = pc_t'(84);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(19);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b1;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(83);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(1);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_ALU_RS_task_struct[0].imm16 = 16'h9d4;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(19);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_ALU_RS_task_struct[1].imm16 = 16'h9d4;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(19);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(41);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_LQ_task_struct.imm14 = 16'h9d4 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(19);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_SQ_task_struct.imm14 = 16'h9d4 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(19);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_BRU_RS_task_struct.imm16 = 16'h9d4;
        expected_BRU_RS_task_struct.PC = pc_t'(83);
        expected_BRU_RS_task_struct.nPC = pc_t'(84);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(19);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "20|84: ORI r27->p27/p49, r25->p47, 0x98 in (LQ full still, fail) | 19|83: LW r26->p26/p48, 0x9D4(r19->p41) out (LQ full still, fail)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001101, 5'd25, 5'd27, 16'h98};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(84);
		tb_fetch_unit_nPC = pc_t'(84);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(19);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b1;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(83);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(1);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_ALU_RS_task_struct[0].imm16 = 16'h9d4;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(19);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_ALU_RS_task_struct[1].imm16 = 16'h9d4;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(19);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(41);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_LQ_task_struct.imm14 = 16'h9d4 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(19);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_SQ_task_struct.imm14 = 16'h9d4 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(19);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_BRU_RS_task_struct.imm16 = 16'h9d4;
        expected_BRU_RS_task_struct.PC = pc_t'(83);
        expected_BRU_RS_task_struct.nPC = pc_t'(84);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(19);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "20|84: ORI r27->p27/p49, r25->p47, 0x98 in (success) | 19|83: LW r26->p26/p48, 0x9D4(r19->p41) out (success)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001101, 5'd25, 5'd27, 16'h98};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(84);
		tb_fetch_unit_nPC = pc_t'(85);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(19);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(83);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(26);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(26);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(48);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_ALU_RS_task_struct[0].imm16 = 16'h9d4;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(19);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_ALU_RS_task_struct[1].imm16 = 16'h9d4;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(19);
        // LQ interface
		expected_LQ_task_valid = 1'b1;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(41);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(48);
        expected_LQ_task_struct.imm14 = 16'h9d4 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(19);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_SQ_task_struct.imm14 = 16'h9d4 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(19);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(41);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(26);
        expected_BRU_RS_task_struct.imm16 = 16'h9d4;
        expected_BRU_RS_task_struct.PC = pc_t'(83);
        expected_BRU_RS_task_struct.nPC = pc_t'(84);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(19);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "21|85: SLTI r28->p28/p50, r30->p34, 0x7F in | 20|84: ORI r27->p27/p49, r25->p47, 0x98 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001010, 5'd30, 5'd28, 16'h7f};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(85);
		tb_fetch_unit_nPC = pc_t'(86);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(20);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0; 
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(84);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(27);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(27);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(49);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_OR;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(27);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(49);
        expected_ALU_RS_task_struct[0].imm16 = 16'h98;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(20);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(27);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(49);
        expected_ALU_RS_task_struct[1].imm16 = 16'h98;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(20);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(49);
        expected_LQ_task_struct.imm14 = 16'h98 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(20);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(47);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(27);
        expected_SQ_task_struct.imm14 = 16'h98 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(20);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(47);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(27);
        expected_BRU_RS_task_struct.imm16 = 16'h98;
        expected_BRU_RS_task_struct.PC = pc_t'(84);
        expected_BRU_RS_task_struct.nPC = pc_t'(85);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(20);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "22|86: SLTIU r29->p51, r9->p9, 0x4BE9 in (ROB full, fail) | 21|85: SLTI r28->p28/p50, r30->p34, 0x7F out (ROB full, fail)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001011, 5'd9, 5'd29, 16'h4be9};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(86);
		tb_fetch_unit_nPC = pc_t'(86);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b1;
		tb_ROB_tail_index = ROB_index_t'(21);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(85);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(50);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(50);
        expected_ALU_RS_task_struct[0].imm16 = 16'h7f;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(21);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(50);
        expected_ALU_RS_task_struct[1].imm16 = 16'h7f;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(21);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(50);
        expected_LQ_task_struct.imm14 = 16'h7f >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(21);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_SQ_task_struct.imm14 = 16'h7f >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(21);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_BRU_RS_task_struct.imm16 = 16'h7f;
        expected_BRU_RS_task_struct.PC = pc_t'(85);
        expected_BRU_RS_task_struct.nPC = pc_t'(86);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(21);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "22|86: SLTIU r29->p51, r9->p9, 0x4BE9 in (success) | 21|85: SLTI r28->p28/p50, r30->p34, 0x7F out (success) (+ p34 complete)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001011, 5'd9, 5'd29, 16'h4be9};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(86);
		tb_fetch_unit_nPC = pc_t'(87);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b1;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(34);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(21);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(85);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(28);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(28);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(50);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SLT;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(50);
        expected_ALU_RS_task_struct[0].imm16 = 16'h7f;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(21);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(50);
        expected_ALU_RS_task_struct[1].imm16 = 16'h7f;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(21);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(50);
        expected_LQ_task_struct.imm14 = 16'h7f >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(21);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_SQ_task_struct.imm14 = 16'h7f >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(21);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(28);
        expected_BRU_RS_task_struct.imm16 = 16'h7f;
        expected_BRU_RS_task_struct.PC = pc_t'(85);
        expected_BRU_RS_task_struct.nPC = pc_t'(86);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(21);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "23|87: SW r3->p3, 0x10D(r13->p3) in | 22|86: SLTIU r29->p51, r9->p9, 0x4BE9 out + complete 35";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b101011, 5'd13, 5'd3, 16'h10d};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(87);
		tb_fetch_unit_nPC = pc_t'(88);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b1;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(35);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(22);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(86);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(29);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(29);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(51);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_SLTU;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(9);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(51);
        expected_ALU_RS_task_struct[0].imm16 = 16'h4be9;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(22);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(9);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(51);
        expected_ALU_RS_task_struct[1].imm16 = 16'h4be9;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(22);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(9);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(51);
        expected_LQ_task_struct.imm14 = 16'h4be9 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(22);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(9);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_SQ_task_struct.imm14 = 16'h4be9 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(22);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(9);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(29);
        expected_BRU_RS_task_struct.imm16 = 16'h4be9;
        expected_BRU_RS_task_struct.PC = pc_t'(86);
        expected_BRU_RS_task_struct.nPC = pc_t'(87);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(22);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "24|88: XORI r30->p34/p52, r30->p34, 0x1C9 in (SQ full, fail) | 23|87: SW r3->p3, 0x10D(r13->p3) out (SQ full, fail)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001110, 5'd30, 5'd30, 16'h1c9};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(88);
		tb_fetch_unit_nPC = pc_t'(88);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(23);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b1;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(87);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(52);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[0].imm16 = 16'h10d;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(23);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[1].imm16 = 16'h10d;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(23);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(35);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_LQ_task_struct.imm14 = 16'h10d >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(23);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_SQ_task_struct.imm14 = 16'h10d >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(23);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_BRU_RS_task_struct.imm16 = 16'h10d;
        expected_BRU_RS_task_struct.PC = pc_t'(87);
        expected_BRU_RS_task_struct.nPC = pc_t'(88);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(23);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "24|88: XORI r30->p34/p52, r30->p34, 0x1C9 in (success) | 23|87: SW r3->p3, 0x10D(r13->p3) out (success)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001110, 5'd30, 5'd30, 16'h1c9};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(88);
		tb_fetch_unit_nPC = pc_t'(89);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(23);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(2);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(5);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(87);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(3);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(3);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(52);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[0].imm16 = 16'h10d;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(23);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[1].imm16 = 16'h10d;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(23);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(35);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_LQ_task_struct.imm14 = 16'h10d >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(2);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(23);
	    // SQ interface
		expected_SQ_task_valid = 1'b1;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_SQ_task_struct.imm14 = 16'h10d >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(5);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(23);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(35);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_BRU_RS_task_struct.imm16 = 16'h10d;
        expected_BRU_RS_task_struct.PC = pc_t'(87);
        expected_BRU_RS_task_struct.nPC = pc_t'(88);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(23);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "25|89: J (goto 26) in | 24|88: XORI r30->p34/p52, r30->p34, 0x1C9 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000010, 26'd26};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(89);
		tb_fetch_unit_nPC = pc_t'(26);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(24);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(88);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(30);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(34);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(52);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_XOR;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[0].imm16 = 16'h1c9;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(24);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[1].imm16 = 16'h1c9;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(24);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_LQ_task_struct.imm14 = 16'h1c9 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(24);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.imm14 = 16'h1c9 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(24);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.imm16 = 16'h1c9;
        expected_BRU_RS_task_struct.PC = pc_t'(88);
        expected_BRU_RS_task_struct.nPC = pc_t'(89);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(24);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "26|26: JAL (goto 99) (r31->p31/p53 <= PC+1) in | 25|89: J (goto 26) out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000011, 26'd99};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(26);
		tb_fetch_unit_nPC = pc_t'(99);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(25);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(89);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(53);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[0].imm16 = 16'd26;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(25);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[1].imm16 = 16'd26;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(25);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_LQ_task_struct.imm14 = 16'd26 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(25);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'd26 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(25);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'd26;
        expected_BRU_RS_task_struct.PC = pc_t'(89);
        expected_BRU_RS_task_struct.nPC = pc_t'(26);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(25);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "27|99: HALT in (ALU RS full, fail) | 26|26: JAL (goto 99) (r31->p31/p53 <= PC+1) out (ALU RS full, fail)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {32'hffffffff};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(99);
		tb_fetch_unit_nPC = pc_t'(99);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(26);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b11;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b1;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(26);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(53);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[0].imm16 = 16'd99;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(26);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[1].imm16 = 16'd99;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(26);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_LQ_task_struct.imm14 = 16'd99 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(26);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'd99 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(26);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'd99;
        expected_BRU_RS_task_struct.PC = pc_t'(26);
        expected_BRU_RS_task_struct.nPC = pc_t'(99);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(26);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "27|99: HALT in (success) | 26|26: JAL (goto 99) (r31->p31/p53 <= PC+1) out (success, ALU RS 1)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {32'hffffffff};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(99);
		tb_fetch_unit_nPC = pc_t'(100);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(26);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b01;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(26);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(31);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(31);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(53);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[0].imm16 = 16'd99;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(26);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b1;
		expected_ALU_RS_task_struct[1].op = ALU_LINK;
        expected_ALU_RS_task_struct[1].itype = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[1].imm16 = 16'd26 << 2;	// should be byte-addr PC, not imm16
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(26);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_LQ_task_struct.imm14 = 16'd99 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(26);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'd99 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(26);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'd99;
        expected_BRU_RS_task_struct.PC = pc_t'(26);
        expected_BRU_RS_task_struct.nPC = pc_t'(99);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(26);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "28|100: invalid opcode in | 27|99: HALT out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {32'hf8000000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(100);
		tb_fetch_unit_nPC = pc_t'(101);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(27);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b1;
        expected_ROB_struct_out.restart_PC = pc_t'(99);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(31);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(53);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(54);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_ALU_RS_task_struct[0].imm16 = 16'hffff;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(27);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(53);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_ALU_RS_task_struct[1].imm16 = 16'hffff;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(27);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(53);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_LQ_task_struct.imm14 = 16'hffff >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(27);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(53);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(53);
        expected_SQ_task_struct.imm14 = 16'hffff >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(27);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(53);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(53);
        expected_BRU_RS_task_struct.imm16 = 16'hffff;
        expected_BRU_RS_task_struct.PC = pc_t'(99);
        expected_BRU_RS_task_struct.nPC = pc_t'(100);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(27);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "29|101: XORI r30->p52/p53, r30->p52, 0x55 in | 28|100: invalid opcode out + successful invalidate checkpoint 0";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001110, 5'd30, 5'd30, 16'h55};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(101);
		tb_fetch_unit_nPC = pc_t'(102);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b1;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(3);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(28);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b1;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(100);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(54);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(28);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(28);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(28);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(28);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(100);
        expected_BRU_RS_task_struct.nPC = pc_t'(101);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(28);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "30|102: ADDU r1->p1/p32, r2->p2, r3->p3 in | 29|101: XORI r30->p52/p54, r30->p52, 0x55 out (DUT error from last invalid opcode)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd3, 5'd1, 5'd0, 6'b100001};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(102);
		tb_fetch_unit_nPC = pc_t'(103);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(29);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b1;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(101);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(30);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(52);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(54);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b1;
		expected_ALU_RS_task_struct[0].op = ALU_XOR;
        expected_ALU_RS_task_struct[0].itype = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_ALU_RS_task_struct[0].imm16 = 16'h55;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(29);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(52);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_ALU_RS_task_struct[1].imm16 = 16'h55;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(29);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(52);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(54);
        expected_LQ_task_struct.imm14 = 16'h55 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(29);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(52);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b0;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(52);
        expected_SQ_task_struct.imm14 = 16'h55 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(29);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(52);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b0;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(52);
        expected_BRU_RS_task_struct.imm16 = 16'h55;
        expected_BRU_RS_task_struct.PC = pc_t'(101);
        expected_BRU_RS_task_struct.nPC = pc_t'(102);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(29);

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // checkpoint testing:
		test_case = "checkpoint testing";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;
		
		@(posedge CLK);

		// inputs
		sub_test_case = "flush + fail restore checkpoint 0 | 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | 30|102: ADDU r1->p1/p32, r2->p2, r3->p3 out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(103);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b1;
		tb_restore_checkpoint_speculate_failed = 1'b1;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(3);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(102);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(1);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(32);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(55);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(55);
        expected_ALU_RS_task_struct[0].imm16 = {5'd1, 5'd0, 6'b100001};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(55);
        expected_ALU_RS_task_struct[1].imm16 = {5'd1, 5'd0, 6'b100001};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b0;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(33);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(55);
        expected_LQ_task_struct.imm14 = {5'd1, 5'd0, 6'b100001} >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b0;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_SQ_task_struct.imm14 = {5'd1, 5'd0, 6'b100001} >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b0;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(33);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        expected_BRU_RS_task_struct.imm16 = {5'd1, 5'd0, 6'b100001};
        expected_BRU_RS_task_struct.PC = pc_t'(102);
        expected_BRU_RS_task_struct.nPC = pc_t'(103);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "flush + successful restore checkpoint 1 | 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(104);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b1;
		tb_restore_checkpoint_speculate_failed = 1'b1;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(16);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(1);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b1;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(55);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(55);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(55);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(55);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "flush + fail restore checkpoint 2 | 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(104);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b1;
		tb_restore_checkpoint_speculate_failed = 1'b1;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(17);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(2);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // revert testing:
		test_case = "revert testing";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "flush + revert (ROB_index = 15, r24:p24->p46) | 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(104);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(15);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(24);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(46);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(24);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(47);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(47);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "flush + revert (ROB_index = 14, r23:p23->p45) | 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(104);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(14);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(23);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(45);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(23);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(46);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(46);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(46);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(46);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "flush + revert (ROB_index = 13, r22:p22->p44) | 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(104);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(13);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(22);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(44);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(22);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(45);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(45);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(45);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "post reverts, still flushing: 31|103: ADD r2->p2/p33, r2->p2, r5->p5 in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b1;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd2, 5'd5, 5'd2, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(104);
		tb_fetch_unit_nPC = pc_t'(104);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(30);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(30);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(30);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(30);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(30);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(30);

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // dead instr testing:
		test_case = "dead instr testing";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "0|200: ADD r0->p0/-, r25->p25, r30->p34 in (dead instr) | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b000000, 5'd25, 5'd30, 5'd0, 5'd0, 6'b100000};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(200);
		tb_fetch_unit_nPC = pc_t'(201);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(0);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h0;
        expected_BRU_RS_task_struct.PC = pc_t'(0);
        expected_BRU_RS_task_struct.nPC = pc_t'(0);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "1|201: ORI r0->p0/-, r25->p25, 0x234 in (dead instr) | 0|200: ADD r0->p0/-, r25->p25, r30->p34 out (dead instr)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b001101, 5'd25, 5'd0, 16'h234};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(201);
		tb_fetch_unit_nPC = pc_t'(202);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(0);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(200);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = {5'd0, 5'd0, 6'b100000};
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(0);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = {5'd0, 5'd0, 6'b100000};
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(0);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(25);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = {5'd0, 5'd0, 6'b100000} >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.imm14 = {5'd0, 5'd0, 6'b100000} >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.imm16 = {5'd0, 5'd0, 6'b100000};
        expected_BRU_RS_task_struct.PC = pc_t'(200);
        expected_BRU_RS_task_struct.nPC = pc_t'(201);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(0);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "2|202: LW r0->p0/-, 0x7E0(r30->p34) in (dead instr) | 1|201: ORI r0->p0/-, r25->p25, 0x234 out (dead instr)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b100011, 5'd30, 5'd0, 16'h7e0};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(202);
		tb_fetch_unit_nPC = pc_t'(203);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(1);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(201);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h234;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(1);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h234;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(1);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(25);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h234 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(1);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h234 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(1);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(25);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h234;
        expected_BRU_RS_task_struct.PC = pc_t'(201);
        expected_BRU_RS_task_struct.nPC = pc_t'(202);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(1);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "i invalid in | 2|202: LW r0->p0/-, 0x7E0(r30->p34) out (dead instr)";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b0;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b100011, 5'd30, 5'd0, 16'h7e0};
		tb_fetch_unit_ivalid = 1'b0;
		tb_fetch_unit_PC = pc_t'(203);
		tb_fetch_unit_nPC = pc_t'(203);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(2);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b1;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b1;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(202);
        expected_ROB_struct_out.reg_write = 1'b0;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h7e0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(2);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h7e0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(2);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h7e0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(2);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h7e0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(2);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h7e0;
        expected_BRU_RS_task_struct.PC = pc_t'(202);
        expected_BRU_RS_task_struct.nPC = pc_t'(203);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(2);

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // core halt:
        test_case = "core halt";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = "core halt: i valid in | i invalid out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b1;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b100011, 5'd30, 5'd0, 16'h7e0};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(203);
		tb_fetch_unit_nPC = pc_t'(204);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(2);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(203);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h7e0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(2);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h7e0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(2);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h7e0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(2);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h7e0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(2);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h7e0;
        expected_BRU_RS_task_struct.PC = pc_t'(203);
        expected_BRU_RS_task_struct.nPC = pc_t'(203);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(2);

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = "core halt 2: i valid in | flush out";
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // core control interface
		tb_core_control_stall_dispatch_unit = 1'b0;
		tb_core_control_flush_dispatch_unit = 1'b0;
		tb_core_control_halt = 1'b1;
	    // fetch_unit interface
		tb_fetch_unit_instr = {6'b100011, 5'd30, 5'd0, 16'h7e0};
		tb_fetch_unit_ivalid = 1'b1;
		tb_fetch_unit_PC = pc_t'(204);
		tb_fetch_unit_nPC = pc_t'(205);
	    // restore interface
		tb_restore_checkpoint_valid = 1'b0;
		tb_restore_checkpoint_speculate_failed = 1'b0;
		tb_restore_checkpoint_ROB_index = ROB_index_t'(0);
		tb_restore_checkpoint_safe_column = checkpoint_column_t'(0);
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
		tb_kill_bus_arch_reg_tag = arch_reg_tag_t'(0);
		tb_kill_bus_speculated_phys_reg_tag = phys_reg_tag_t'(0);
		tb_kill_bus_safe_phys_reg_tag = phys_reg_tag_t'(0);
	    // complete bus interface
		tb_complete_bus_0_valid = 1'b0;
		tb_complete_bus_0_dest_phys_reg_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_valid = 1'b0;
		tb_complete_bus_1_dest_phys_reg_tag = phys_reg_tag_t'(0);
	    // ROB interface
	    // dispatch @ tail
		tb_ROB_full = 1'b0;
		tb_ROB_tail_index = ROB_index_t'(5);
	    // retire from head
		tb_ROB_retire_valid = 1'b0;
		tb_ROB_retire_phys_reg_tag = phys_reg_tag_t'(0);
	    // 2x ALU RS interface
		tb_ALU_RS_full = 2'b00;
	    // SQ interface
		tb_SQ_tail_index = SQ_index_t'(0);
		tb_SQ_full = 1'b0;
	    // LQ interface
		tb_LQ_tail_index = LQ_index_t'(0);
		tb_LQ_full = 1'b0;
	    // BRU RS interface
		tb_BRU_RS_full = 1'b0; 

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // core control interface
		expected_core_control_dispatch_failed = 1'b0;
	    // fetch_unit interface
	    // restore interface
		expected_restore_checkpoint_success = 1'b0;
	    // kill bus interface
	    // complete bus interface
	    // ROB interface
	    // dispatch @ tail
		expected_ROB_enqueue_valid = 1'b0;
		expected_ROB_struct_out.valid = 1'b1;
        expected_ROB_struct_out.complete = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DU_HALT = 1'b0;
        expected_ROB_struct_out.restart_PC = pc_t'(203);
        expected_ROB_struct_out.reg_write = 1'b1;
        expected_ROB_struct_out.dest_arch_reg_tag = arch_reg_tag_t'(0);
        expected_ROB_struct_out.safe_dest_phys_reg_tag = phys_reg_tag_t'(0);
        expected_ROB_struct_out.speculated_dest_phys_reg_tag = phys_reg_tag_t'(44);
	    // retire from head
	    // 2x ALU RS interface
            // ALU RS 0
		expected_ALU_RS_task_valid[0] = 1'b0;
		expected_ALU_RS_task_struct[0].op = ALU_ADD;
        expected_ALU_RS_task_struct[0].itype = 1'b0;
        expected_ALU_RS_task_struct[0].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[0].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[0].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[0].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[0].imm16 = 16'h7e0;
        expected_ALU_RS_task_struct[0].ROB_index = ROB_index_t'(5);
            // ALU RS 1
        expected_ALU_RS_task_valid[1] = 1'b0;
		expected_ALU_RS_task_struct[1].op = ALU_ADD;
        expected_ALU_RS_task_struct[1].itype = 1'b0;
        expected_ALU_RS_task_struct[1].source_0.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_ALU_RS_task_struct[1].source_1.needed = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.ready = 1'b1;
        expected_ALU_RS_task_struct[1].source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_ALU_RS_task_struct[1].dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_ALU_RS_task_struct[1].imm16 = 16'h7e0;
        expected_ALU_RS_task_struct[1].ROB_index = ROB_index_t'(5);
        // LQ interface
		expected_LQ_task_valid = 1'b0;
		expected_LQ_task_struct.op = LQ_LW;
        expected_LQ_task_struct.source.needed = 1'b1;
        expected_LQ_task_struct.source.ready = 1'b1;
        expected_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(34);
        expected_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(44);
        expected_LQ_task_struct.imm14 = 16'h7e0 >> 2;
        expected_LQ_task_struct.SQ_index = SQ_index_t'(0);
        expected_LQ_task_struct.ROB_index = ROB_index_t'(5);
	    // SQ interface
		expected_SQ_task_valid = 1'b0;
		expected_SQ_task_struct.op = SQ_SW;
        expected_SQ_task_struct.source_0.needed = 1'b1;
        expected_SQ_task_struct.source_0.ready = 1'b1;
        expected_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_SQ_task_struct.source_1.needed = 1'b1;
        expected_SQ_task_struct.source_1.ready = 1'b1;
        expected_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_SQ_task_struct.imm14 = 16'h7e0 >> 2;
        expected_SQ_task_struct.LQ_index = LQ_index_t'(0);
        expected_SQ_task_struct.ROB_index = ROB_index_t'(5);
	    // BRU RS interface
		expected_BRU_RS_task_valid = 1'b0;
		expected_BRU_RS_task_struct.op = BRU_BEQ;
        expected_BRU_RS_task_struct.source_0.needed = 1'b1;
        expected_BRU_RS_task_struct.source_0.ready = 1'b1;
        expected_BRU_RS_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(34);
        expected_BRU_RS_task_struct.source_1.needed = 1'b1;
        expected_BRU_RS_task_struct.source_1.ready = 1'b1;
        expected_BRU_RS_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        expected_BRU_RS_task_struct.imm16 = 16'h7e0;
        expected_BRU_RS_task_struct.PC = pc_t'(203);
        expected_BRU_RS_task_struct.nPC = pc_t'(204);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(5);

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

