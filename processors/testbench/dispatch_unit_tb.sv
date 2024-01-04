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

	dispatch_unit #(

	) DUT (
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
			$display("\texpected.dispatched_unit.ALU_0 = %h, DUT.dispatched_unit.ALU_0 = %h", expected_ROB_struct_out.dispatched_unit.ALU_0, DUT_ROB_struct_out.dispatched_unit.ALU_0);
			$display("\texpected.dispatched_unit.ALU_1 = %h, DUT.dispatched_unit.ALU_1 = %h", expected_ROB_struct_out.dispatched_unit.ALU_1, DUT_ROB_struct_out.dispatched_unit.ALU_1);
			$display("\texpected.dispatched_unit.LQ = %h, DUT.dispatched_unit.LQ = %h", expected_ROB_struct_out.dispatched_unit.LQ, DUT_ROB_struct_out.dispatched_unit.LQ);
			$display("\texpected.dispatched_unit.SQ = %h, DUT.dispatched_unit.SQ = %h", expected_ROB_struct_out.dispatched_unit.SQ, DUT_ROB_struct_out.dispatched_unit.SQ);
			$display("\texpected.dispatched_unit.BRU = %h, DUT.dispatched_unit.BRU = %h", expected_ROB_struct_out.dispatched_unit.BRU, DUT_ROB_struct_out.dispatched_unit.BRU);
			$display("\texpected.dispatched_unit.J = %h, DUT.dispatched_unit.J = %h", expected_ROB_struct_out.dispatched_unit.J, DUT_ROB_struct_out.dispatched_unit.J);
			$display("\texpected.dispatched_unit.DEAD = %h, DUT.dispatched_unit.DEAD = %h", expected_ROB_struct_out.dispatched_unit.DEAD, DUT_ROB_struct_out.dispatched_unit.DEAD);
			$display("\texpected.dispatched_unit.HALT = %h, DUT.dispatched_unit.HALT = %h", expected_ROB_struct_out.dispatched_unit.HALT, DUT_ROB_struct_out.dispatched_unit.HALT);
			$display("\texpected.restart_PC = %h, DUT.restart_PC = %h", expected_ROB_struct_out.restart_PC, DUT_ROB_struct_out.restart_PC);
			$display("\texpected.reg_write = %h, DUT.reg_write = %h", expected_ROB_struct_out.reg_write, DUT_ROB_struct_out.reg_write);
			$display("\texpected.dest_arch_reg_tag = %h, DUT.dest_arch_reg_tag = %h", expected_ROB_struct_out.dest_arch_reg_tag, DUT_ROB_struct_out.dest_arch_reg_tag);
			$display("\texpected.safe_dest_phys_reg_tag = %h, DUT.safe_dest_phys_reg_tag = %h", expected_ROB_struct_out.safe_dest_phys_reg_tag, DUT_ROB_struct_out.safe_dest_phys_reg_tag);
			$display("\texpected.speculated_dest_phys_reg_tag = %h, DUT.speculated_dest_phys_reg_tag = %h", expected_ROB_struct_out.speculated_dest_phys_reg_tag, DUT_ROB_struct_out.speculated_dest_phys_reg_tag);
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
			$display("\texpected[0].source_0.phys_reg_tag = %h, DUT.source_0.phys_reg_tag = %h", expected_ALU_RS_task_struct[0].source_0.phys_reg_tag, DUT_ALU_RS_task_struct[0].source_0.phys_reg_tag);
			$display("\texpected[0].source_1.needed = %h, DUT.source_1.needed = %h", expected_ALU_RS_task_struct[0].source_1.needed, DUT_ALU_RS_task_struct[0].source_1.needed);
			$display("\texpected[0].source_1.ready = %h, DUT.source_1.ready = %h", expected_ALU_RS_task_struct[0].source_1.ready, DUT_ALU_RS_task_struct[0].source_1.ready);
			$display("\texpected[0].source_1.phys_reg_tag = %h, DUT.source_1.phys_reg_tag = %h", expected_ALU_RS_task_struct[0].source_1.phys_reg_tag, DUT_ALU_RS_task_struct[0].source_1.phys_reg_tag);
			$display("\texpected[0].dest_phys_reg_tag = %h, DUT.dest_phys_reg_tag = %h", expected_ALU_RS_task_struct[0].dest_phys_reg_tag, DUT_ALU_RS_task_struct[0].dest_phys_reg_tag);
			$display("\texpected[0].imm16 = %h, DUT.imm16 = %h", expected_ALU_RS_task_struct[0].imm16, DUT_ALU_RS_task_struct[0].imm16);
			$display("\texpected[0].ROB_index = %h, DUT.ROB_index = %h", expected_ALU_RS_task_struct[0].ROB_index, DUT_ALU_RS_task_struct[0].ROB_index);
			$display("\texpected[1].op = %h, DUT.op = %h", expected_ALU_RS_task_struct[1].op, DUT_ALU_RS_task_struct[1].op);
			$display("\texpected[1].itype = %h, DUT.itype = %h", expected_ALU_RS_task_struct[1].itype, DUT_ALU_RS_task_struct[1].itype);
			$display("\texpected[1].source_0.needed = %h, DUT.source_0.needed = %h", expected_ALU_RS_task_struct[1].source_0.needed, DUT_ALU_RS_task_struct[1].source_0.needed);
			$display("\texpected[1].source_0.ready = %h, DUT.source_0.ready = %h", expected_ALU_RS_task_struct[1].source_0.ready, DUT_ALU_RS_task_struct[1].source_0.ready);
			$display("\texpected[1].source_0.phys_reg_tag = %h, DUT.source_0.phys_reg_tag = %h", expected_ALU_RS_task_struct[1].source_0.phys_reg_tag, DUT_ALU_RS_task_struct[1].source_0.phys_reg_tag);
			$display("\texpected[1].source_1.needed = %h, DUT.source_1.needed = %h", expected_ALU_RS_task_struct[1].source_1.needed, DUT_ALU_RS_task_struct[1].source_1.needed);
			$display("\texpected[1].source_1.ready = %h, DUT.source_1.ready = %h", expected_ALU_RS_task_struct[1].source_1.ready, DUT_ALU_RS_task_struct[1].source_1.ready);
			$display("\texpected[1].source_1.phys_reg_tag = %h, DUT.source_1.phys_reg_tag = %h", expected_ALU_RS_task_struct[1].source_1.phys_reg_tag, DUT_ALU_RS_task_struct[1].source_1.phys_reg_tag);
			$display("\texpected[1].dest_phys_reg_tag = %h, DUT.dest_phys_reg_tag = %h", expected_ALU_RS_task_struct[1].dest_phys_reg_tag, DUT_ALU_RS_task_struct[1].dest_phys_reg_tag);
			$display("\texpected[1].imm16 = %h, DUT.imm16 = %h", expected_ALU_RS_task_struct[1].imm16, DUT_ALU_RS_task_struct[1].imm16);
			$display("\texpected[1].ROB_index = %h, DUT.ROB_index = %h", expected_ALU_RS_task_struct[1].ROB_index, DUT_ALU_RS_task_struct[1].ROB_index);
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
			$display("\texpected.source.phys_reg_tag = %h, DUT.source.phys_reg_tag = %h", expected_LQ_task_struct.source.phys_reg_tag, DUT_LQ_task_struct.source.phys_reg_tag);
			$display("\texpected.dest_phys_reg_tag = %h, DUT.dest_phys_reg_tag = %h", expected_LQ_task_struct.dest_phys_reg_tag, DUT_LQ_task_struct.dest_phys_reg_tag);
			$display("\texpected.imm14 = %h, DUT.imm14 = %h", expected_LQ_task_struct.imm14, DUT_LQ_task_struct.imm14);
			$display("\texpected.SQ_index = %h, DUT.SQ_index = %h", expected_LQ_task_struct.SQ_index, DUT_LQ_task_struct.SQ_index);
			$display("\texpected.ROB_index = %h, DUT.ROB_index = %h", expected_LQ_task_struct.ROB_index, DUT_LQ_task_struct.ROB_index);
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
			$display("\texpected.source_0.phys_reg_tag = %h, DUT.source_0.phys_reg_tag = %h", expected_SQ_task_struct.source_0.phys_reg_tag, DUT_SQ_task_struct.source_0.phys_reg_tag);
			$display("\texpected.source_1.needed = %h, DUT.source_1.needed = %h", expected_SQ_task_struct.source_1.needed, DUT_SQ_task_struct.source_1.needed);
			$display("\texpected.source_1.ready = %h, DUT.source_1.ready = %h", expected_SQ_task_struct.source_1.ready, DUT_SQ_task_struct.source_1.ready);
			$display("\texpected.source_1.phys_reg_tag = %h, DUT.source_1.phys_reg_tag = %h", expected_SQ_task_struct.source_1.phys_reg_tag, DUT_SQ_task_struct.source_1.phys_reg_tag);
			$display("\texpected.imm14 = %h, DUT.imm14 = %h", expected_SQ_task_struct.imm14, DUT_SQ_task_struct.imm14);
			$display("\texpected.LQ_index = %h, DUT.LQ_index = %h", expected_SQ_task_struct.LQ_index, DUT_SQ_task_struct.LQ_index);
			$display("\texpected.ROB_index = %h, DUT.ROB_index = %h", expected_SQ_task_struct.ROB_index, DUT_SQ_task_struct.ROB_index);
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
			$display("\texpected.source_0.phys_reg_tag = %h, DUT.source_0.phys_reg_tag = %h", expected_BRU_RS_task_struct.source_0.phys_reg_tag, DUT_BRU_RS_task_struct.source_0.phys_reg_tag);
			$display("\texpected.source_1.needed = %h, DUT.source_1.needed = %h", expected_BRU_RS_task_struct.source_1.needed, DUT_BRU_RS_task_struct.source_1.needed);
			$display("\texpected.source_1.ready = %h, DUT.source_1.ready = %h", expected_BRU_RS_task_struct.source_1.ready, DUT_BRU_RS_task_struct.source_1.ready);
			$display("\texpected.source_1.phys_reg_tag = %h, DUT.source_1.phys_reg_tag = %h", expected_BRU_RS_task_struct.source_1.phys_reg_tag, DUT_BRU_RS_task_struct.source_1.phys_reg_tag);
			$display("\texpected.imm14 = %h, DUT.imm14 = %h", expected_BRU_RS_task_struct.imm14, DUT_BRU_RS_task_struct.imm14);
			$display("\texpected.PC = %h, DUT.PC = %h", expected_BRU_RS_task_struct.PC, DUT_BRU_RS_task_struct.PC);
			$display("\texpected.nPC = %h, DUT.nPC = %h", expected_BRU_RS_task_struct.nPC, DUT_BRU_RS_task_struct.nPC);
			$display("\texpected.checkpoint_safe_column = %h, DUT.checkpoint_safe_column = %h", expected_BRU_RS_task_struct.checkpoint_safe_column, DUT_BRU_RS_task_struct.checkpoint_safe_column);
			$display("\texpected.ROB_index = %h, DUT.ROB_index = %h", expected_BRU_RS_task_struct.ROB_index, DUT_BRU_RS_task_struct.ROB_index);
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'(0);
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'(0);
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'(0);
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'(0);
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'({5'd1, 5'd0, 4'b1000});
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'({5'd2, 5'd0, 4'b1000});
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
		tb_fetch_unit_instr = {6'b000000, 5'd34, 5'd0, 5'd0, 5'd0, 6'b001000};
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'({5'd30, 5'd0, 4'b1001});
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
		tb_fetch_unit_instr = {6'b000000, 5'd34, 5'd0, 5'd0, 5'd0, 6'b001000};
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'({5'd30, 5'd0, 4'b1001});
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
		tb_fetch_unit_instr = {6'b000000, 5'd13, 5'd6, 5'd19, 5'd28, 6'b100111};
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
        expected_ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
        expected_ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        expected_ROB_struct_out.dispatched_unit.LQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.SQ = 1'b0;
        expected_ROB_struct_out.dispatched_unit.BRU = 1'b0;
        expected_ROB_struct_out.dispatched_unit.J = 1'b0;
        expected_ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        expected_ROB_struct_out.dispatched_unit.HALT = 1'b0;
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
        expected_BRU_RS_task_struct.imm14 = pc_t'({5'd30, 5'd0, 4'b1001});
        expected_BRU_RS_task_struct.PC = pc_t'(2);
        expected_BRU_RS_task_struct.nPC = pc_t'(3);
        expected_BRU_RS_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        expected_BRU_RS_task_struct.ROB_index = ROB_index_t'(2);

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

