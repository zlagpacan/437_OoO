/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dispatch_unit.sv
    Instantiation Hierarchy: system -> core -> dispatch_unit
    Description: 
        The Dispatch Unit handles decoding, register renaming, and demuxing an input instruction to an
        execution unit. This module instantiates the phys_reg_map_table, phys_reg_free_list, and 
        phys_reg_ready_table modules.
        
        This unit mostly autonomously takes in instructions and spits out tasks for execution units. 
        Non-autonomous functionalities come from:
            - core control stall, flush, and halt
                - facilitate speculation restores and reverts during flush
            - checkpoint restore (always, but should only happen during flush)
                - perform checkpoint restore
                - combine with core control flush
            - kill bus (always, but should only happen during flush)
                - perform phys reg revert
                - combine with core control flush
            - complete bus (always)
                - update phys reg ready's
            - execution unit stalls (when applicable to dispatching instr)
                - execution unit not ready for dispatch
            - ROB stall (if want to dispatch (don't need to if dead instr or no ivalid))
                - ROB not ready for dispatch

        Instruction input is latched at beginning of dispatch_unit. 
        Demux'd task struct output is latched at beginning of execution unit
            // i.e. not here in dispatch_unit
*/

`include "core_types.vh"
import core_types_pkg::*;

module dispatch_unit #(

) (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // core control interface
    input logic core_control_stall_dispatch_unit,
    input logic core_control_flush_dispatch_unit,
    input logic core_control_halt,
    output logic core_control_dispatch_failed,

    // fetch_unit interface
    input word_t fetch_unit_instr,
    input logic fetch_unit_ivalid,
    input pc_t fetch_unit_PC,
    input pc_t fetch_unit_nPC,

    // restore interface
    input logic restore_checkpoint_valid,
    input logic restore_checkpoint_speculate_failed,
    input ROB_index_t restore_checkpoint_ROB_index,  // from restore system, check tag val
    input checkpoint_column_t restore_checkpoint_safe_column,
    output logic restore_checkpoint_success,

    // kill bus interface
        // kill for ROB_index, T, T_old
    input logic kill_bus_valid,
    input ROB_index_t kill_bus_ROB_index,
        // actually don't need this, only need ROB index for execution unit kills
    input arch_reg_tag_t kill_bus_arch_reg_tag;
    input phys_reg_tag_t kill_bus_speculated_phys_reg_tag,
    input phys_reg_tag_t kill_bus_safe_phys_reg_tag,

    // complete bus interface
        // 2x ready @ T
    input logic complete_bus_0_valid,
    input phys_reg_tag_t complete_bus_0_dest_phys_reg_tag,
    input logic complete_bus_1_valid,
    input phys_reg_tag_t complete_bus_1_dest_phys_reg_tag,

    // ROB interface
    // dispatch @ tail
    input logic ROB_full,
    input ROB_index_t ROB_tail_index,
    output logic ROB_enqueue_valid,
    output ROB_input_struct_t ROB_struct_out,
    // retire from head
    input logic ROB_retire_valid,
    input phys_reg_tag_t ROB_retire_phys_reg_tag;

    // 2x ALU RS interface
    input logic [1:0] ALU_RS_full,
    output logic [1:0] ALU_RS_task_valid,
    output ALU_RS_input_struct_t [1:0] ALU_RS_task_struct,

    // SQ interface
    input SQ_index_t SQ_tail_index,
    input logic SQ_full,
    output logic SQ_task_valid,
    output SQ_enqueue_struct_t SQ_task_struct,

    // LQ interface
    input LQ_index_t LQ_tail_index,
    input logic LQ_full,
    output logic LQ_task_valid,
    output LQ_enqueue_struct_t LQ_task_struct,

    // BRU RS interface
    input logic BRU_RS_full,
    output logic BRU_RS_task_valid,
    output BRU_RS_input_struct_t BRU_RS_task_struct
);
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // phys_reg_map_table:
    
    // DUT error
    logic prmt_DUT_error;

    // reg map reading
    arch_reg_tag_t prmt_source_arch_reg_tag_0;
    phys_reg_tag_t prmt_source_phys_reg_tag_0;
    arch_reg_tag_t prmt_source_arch_reg_tag_1;
    phys_reg_tag_t prmt_source_phys_reg_tag_1;
    arch_reg_tag_t prmt_old_dest_arch_reg_tag;
    phys_reg_tag_t prmt_old_dest_phys_reg_tag;

    // reg map rename
    logic prmt_rename_valid;
    arch_reg_tag_t prmt_rename_dest_arch_reg_tag;
    phys_reg_tag_t prmt_rename_dest_phys_reg_tag;

    // reg map revert
    logic prmt_revert_valid;
    arch_reg_tag_t prmt_revert_dest_arch_reg_tag;
    phys_reg_tag_t prmt_revert_safe_dest_phys_reg_tag;
    phys_reg_tag_t prmt_revert_speculated_dest_phys_reg_tag;
        // can use for assertion but otherwise don't need

    // reg map checkpoint save
    logic prmt_save_checkpoint_valid;
    ROB_index_t prmt_save_checkpoint_ROB_index;    // from ROB, write tag val
    checkpoint_column_t prmt_save_checkpoint_safe_column;

    // reg map checkpoint restore
    logic prmt_restore_checkpoint_valid;
    logic prmt_restore_checkpoint_speculate_failed;
    ROB_index_t prmt_restore_checkpoint_ROB_index;  // from restore system, check tag val
    checkpoint_column_t prmt_restore_checkpoint_safe_column;
    logic prmt_restore_checkpoint_success;

    // phys_reg_map_table instantiation
    phys_reg_map_table #(
        // no params
    ) prmt (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // DUT error
        .DUT_error(prmt_DUT_error),

        // reg map reading
        .source_arch_reg_tag_0(prmt_source_arch_reg_tag_0),
        .source_phys_reg_tag_0(prmt_source_phys_reg_tag_0),
        .source_arch_reg_tag_1(prmt_source_arch_reg_tag_1),
        .source_phys_reg_tag_1(prmt_source_phys_reg_tag_1),
        .old_dest_arch_reg_tag(prmt_old_dest_arch_reg_tag),
        .old_dest_phys_reg_tag(prmt_old_dest_phys_reg_tag),

        // reg map rename
        .rename_valid(prmt_rename_valid),
        .rename_dest_arch_reg_tag(prmt_rename_dest_arch_reg_tag),
        .rename_dest_phys_reg_tag(prmt_rename_dest_phys_reg_tag),

        // reg map revert
        .revert_valid(prmt_revert_valid),
        .revert_dest_arch_reg_tag(prmt_revert_dest_arch_reg_tag),
        .revert_safe_dest_phys_reg_tag(prmt_revert_safe_dest_phys_reg_tag),
        .revert_speculated_dest_phys_reg_tag(prmt_revert_speculated_dest_phys_reg_tag),

        // reg map checkpoint save
        .save_checkpoint_valid(prmt_save_checkpoint_valid),
        .save_checkpoint_ROB_index(prmt_save_checkpoint_ROB_index),       // from ROB, write tag val
        .save_checkpoint_safe_column(prmt_save_checkpoint_safe_column),

        // reg map checkpoint restore
        .restore_checkpoint_valid(prmt_restore_checkpoint_valid),
        .restore_checkpoint_speculate_failed(prmt_restore_checkpoint_speculate_failed),
        .restore_checkpoint_ROB_index(prmt_restore_checkpoint_ROB_index),     // from restore system, check tag val
        .restore_checkpoint_safe_column(prmt_restore_checkpoint_safe_column),
        .restore_checkpoint_success(prmt_restore_checkpoint_success)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // phys_reg_free_list:

    // DUT error
	logic prfl_DUT_error;

    // dequeue
	logic prfl_dequeue_valid;
	phys_reg_tag_t prfl_dequeue_phys_reg_tag;

    // enqueue
	logic prfl_enqueue_valid;
	phys_reg_tag_t prfl_enqueue_phys_reg_tag;

    // full/empty
        // should be left unused but may want to account for potential functionality externally
        // can use for assertions
	logic prfl_full;
	logic prfl_empty;

    // reg map revert
	logic prfl_revert_valid;
        // input arch_reg_tag_t revert_dest_arch_reg_tag,
        // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
	phys_reg_tag_t prfl_revert_speculated_dest_phys_reg_tag;
        // can use for assertion but otherwise don't need

    // free list checkpoint save
	logic prfl_save_checkpoint_valid;
	ROB_index_t prfl_save_checkpoint_ROB_index;
	checkpoint_column_t prfl_save_checkpoint_safe_column;

    // free list checkpoint restore
	logic prfl_restore_checkpoint_valid;
	logic prfl_restore_checkpoint_speculate_failed;
	ROB_index_t prfl_restore_checkpoint_ROB_index;
	checkpoint_column_t prfl_restore_checkpoint_safe_column;
	logic prfl_restore_checkpoint_success;

    // phys_reg_free_list instantiation
	phys_reg_free_list #(

	) DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

		// DUT error
		.DUT_error(prfl_DUT_error),

	    // dequeue
		.dequeue_valid(prfl_dequeue_valid),
		.dequeue_phys_reg_tag(prfl_dequeue_phys_reg_tag),

	    // enqueue
		.enqueue_valid(prfl_enqueue_valid),
		.enqueue_phys_reg_tag(prfl_enqueue_phys_reg_tag),

	    // full/empty
	        // should be left unused but may want to account for potential functionality externally
	        // can use for assertions
		.full(prfl_full),
		.empty(prfl_empty),

	    // reg map revert
		.revert_valid(prfl_revert_valid),
	        // input arch_reg_tag_t revert_dest_arch_reg_tag,
	        // input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
		.revert_speculated_dest_phys_reg_tag(prfl_revert_speculated_dest_phys_reg_tag),
	        // can use for assertion but otherwise don't need

	    // free list checkpoint save
		.save_checkpoint_valid(prfl_save_checkpoint_valid),
		.save_checkpoint_ROB_index(prfl_save_checkpoint_ROB_index),
		.save_checkpoint_safe_column(prfl_save_checkpoint_safe_column),

	    // free list checkpoint restore
		.restore_checkpoint_valid(prfl_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(prfl_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(prfl_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(prfl_restore_checkpoint_safe_column),
		.restore_checkpoint_success(prfl_restore_checkpoint_success)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // phys_reg_ready_table:
    
    // DUT error
	logic prrt_DUT_error;

    // dispatch
        // read @ source 0
        // read @ source 1
        // clear @ dest
	phys_reg_tag_t prrt_dispatch_source_0_phys_reg_tag;
	logic prrt_dispatch_source_0_ready;
	phys_reg_tag_t prrt_dispatch_source_1_phys_reg_tag;
	logic prrt_dispatch_source_1_ready;
	logic prrt_dispatch_dest_write;
	phys_reg_tag_t prrt_dispatch_dest_phys_reg_tag;

    // complete
        // set @ complete bus 0 dest
        // set @ complete bus 1 dest
	logic prrt_complete_bus_0_valid;
	phys_reg_tag_t prrt_complete_bus_0_dest_phys_reg_tag;
	logic prrt_complete_bus_1_valid;
	phys_reg_tag_t prrt_complete_bus_1_dest_phys_reg_tag;

    // phys_reg_ready_table instantiation
	phys_reg_ready_table #(

	) DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(prrt_DUT_error),

	    // dispatch
	        // read @ source 0
	        // read @ source 1
	        // clear @ dest
		.dispatch_source_0_phys_reg_tag(prrt_dispatch_source_0_phys_reg_tag),
		.dispatch_source_0_ready(prrt_dispatch_source_0_ready),
		.dispatch_source_1_phys_reg_tag(prrt_dispatch_source_1_phys_reg_tag),
		.dispatch_source_1_ready(prrt_dispatch_source_1_ready),
		.dispatch_dest_write(prrt_dispatch_dest_write),
		.dispatch_dest_phys_reg_tag(prrt_dispatch_dest_phys_reg_tag),

	    // complete
	        // set @ complete bus 0 dest
	        // set @ complete bus 1 dest
		.complete_bus_0_valid(prrt_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(prrt_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_1_valid(prrt_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(prrt_complete_bus_1_dest_phys_reg_tag)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // fetch unit -> dispatch unit latch:
        // always take fetch unit input
        // core control handles stalls and flushes

    word_t dispatch_unit_instr;
    logic dispatch_unit_ivalid;
    pc_t dispatch_unit_PC;
    pc_t dispatch_unit_nPC;

    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            dispatch_unit_instr <= 32'h0;
            dispatch_unit_ivalid <= 1'b0;
            dispatch_unit_PC <= 14'h0;
            dispatch_unit_nPC <= 14'h0;
        end
        else begin
            dispatch_unit_instr <= fetch_unit_instr;
            dispatch_unit_ivalid <= fetch_unit_ivalid;
            dispatch_unit_PC <= fetch_unit_PC;
            dispatch_unit_nPC <= fetch_unit_nPC;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BIG logic:

    // signals:

    // instr fields
    r_t instr_rtype;
    i_t instr_itype;
    j_t instr_jtype;
    opcode_t instr_opcode;
    arch_reg_tag_t instr_rs;
    arch_reg_tag_t instr_rt;
    arch_reg_tag_t instr_rd;
    imm16_t instr_imm16;
    funct_t instr_funct;

    // ALU RS select
    logic ALU_RS_select;
    logic ALU_RS_both_full;

    // seq
        // all sequential logic is in map table, free list, and ready table?
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            
        end
        else begin
            
        end
    end

    // comb
    always_comb begin

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // hardwired outputs:

        ///////////////////
        // instr fields: //
        ///////////////////

        instr_rtype = dispatch_unit_instr;
        instr_itype = dispatch_unit_instr;
        instr_jtype = dispatch_unit_instr;
        instr_opcode = instr_rtype.opcode;
        instr_rs = instr_rtype.rs;
        instr_rt = instr_rtype.rt;
        instr_rd = instr_rtype.rd;
        instr_imm16 = instr_itype.imm16;
        instr_funct = instr_rtype.funct;

        ////////////////////////////////////
        // internal module input signals: //
        ////////////////////////////////////

        // phys_reg_map_table:

        // reg map reading
        prmt_source_arch_reg_tag_0 = instr_rs;  // always rs
        prmt_source_arch_reg_tag_1 = instr_rt;  // always rt
        // prmt_old_dest_arch_reg_tag = instr_rd;  // can be rd, rt, or 31
        // reg map rename
        // prmt_rename_valid = 1'b0;   // can be 0 (non-writing instr or no ivalid) or 1 (successful dispatch writing instr)
        // prmt_rename_dest_arch_reg_tag = instr_rd;  // can be rd, rt, or 31
        prmt_rename_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;  // always prfl dequeue
        // reg map revert
        prmt_revert_valid = kill_bus_valid;   // always kill bus valid
        prmt_revert_dest_arch_reg_tag = kill_bus_arch_reg_tag;  // always kill bus val
        prmt_revert_safe_dest_phys_reg_tag = kill_bus_safe_phys_reg_tag;    // always kill bus val
        prmt_revert_speculated_dest_phys_reg_tag = kill_bus_speculated_phys_reg_tag;    // always kill bus val
        // reg map checkpoint save
        // prmt_save_checkpoint_valid = 1'b0;  // can be 0 or 1 (successful dispatch jr, beq, or bne)
        prmt_save_checkpoint_ROB_index = ROB_tail_index;    // always ROB tail index
        // reg map checkpoint restore
        prmt_restore_checkpoint_valid = restore_checkpoint_valid;   // always restore valid
        prmt_restore_checkpoint_speculate_failed = restore_checkpoint_speculate_failed; // always restore val
        prmt_restore_checkpoint_ROB_index = restore_checkpoint_ROB_index;   // always restore val
        prmt_restore_checkpoint_safe_column = restore_checkpoint_safe_column;   // always restore val

        // phys_reg_free_list:

        // dequeue
        // prfl_dequeue_valid = 1'b0;  // can be 0 or 1 (successful dispatch writing instr)
        // enqueue
        prfl_enqueue_valid = ROB_retire_valid;  // always ROB retire valid
        prfl_enqueue_phys_reg_tag = ROB_retire_phys_reg_tag;    // always ROB retire val
        // full/empty
        // reg map revert
        prfl_revert_valid = kill_bus_valid; // always kill bus valid
        prfl_revert_speculated_dest_phys_reg_tag = kill_bus_speculated_phys_reg_tag;    // always kill bus val
        // free list checkpoint save
        // prfl_save_checkpoint_valid = 1'b0;  // can be 0 or 1 (successful dispatch jr, beq, or bne)
        prfl_save_checkpoint_ROB_index = ROB_tail_index;    // always ROB tail index
        // free list checkpoint restore
        prfl_restore_checkpoint_valid = restore_checkpoint_valid;   // always restore valid
        prfl_restore_checkpoint_speculate_failed = restore_checkpoint_speculate_failed; // always restore
        prfl_restore_checkpoint_ROB_index = restore_checkpoint_ROB_index;   // always restore val
        prfl_restore_checkpoint_safe_column = restore_checkpoint_safe_column;   // always restore val

        // phys_reg_ready_table:
    
        // dispatch
        prrt_dispatch_source_0_phys_reg_tag = prmt_source_phys_reg_tag_0;   // always phys reg rs
        prrt_dispatch_source_1_phys_reg_tag = prmt_source_phys_reg_tag_1;   // always phys reg rt
        // prrt_dispatch_dest_write = 1'b0;    // can be 0 or 1 (successful dispatch writing instr)
        prrt_dispatch_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;    // always dequeue'd phys reg from free list 
        // complete
        prrt_complete_bus_0_valid = complete_bus_0_valid;   // always complete bus valid
        prrt_complete_bus_0_dest_phys_reg_tag = complete_bus_0_dest_phys_reg_tag;   // always complete bus val
        prrt_complete_bus_1_valid = complete_bus_1_valid;   // always complete bus valid
        prrt_complete_bus_1_dest_phys_reg_tag = complete_bus_1_dest_phys_reg_tag;   // always complete bus val

        /////////////////////////////////////
        // internal module output signals: //
        /////////////////////////////////////
            // check these are actually used as intended later

        // phys_reg_map_table:
        // reg map reading
        prmt_source_phys_reg_tag_0;
        prmt_source_phys_reg_tag_1;
        prmt_old_dest_phys_reg_tag;
        // reg map rename
        // reg map revert
        // reg map checkpoint save
        prmt_save_checkpoint_safe_column;
        // reg map checkpoint restore
        prmt_restore_checkpoint_success;

        // phys_reg_free_list:
        // dequeue
        prfl_dequeue_phys_reg_tag;
        // enqueue
        // full/empty
        prfl_full;
        prfl_empty;
        // reg map revert
        // free list checkpoint save
        prfl_save_checkpoint_safe_column;
        // free list checkpoint restore
        prfl_restore_checkpoint_success;

        // dispatch
        prrt_dispatch_source_0_ready;
        prrt_dispatch_source_1_ready;
        // complete

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // default outputs:

        // ALU RS select default 0
        ALU_RS_select = 1'b0;
        ALU_RS_both_full = 1'b0;

        ////////////////////////////////////
        // internal module input signals: //
        ////////////////////////////////////

        // phys_reg_map_table:

        // reg map reading
        // prmt_source_arch_reg_tag_0 = instr_rs;  // always rs
        // prmt_source_arch_reg_tag_1 = instr_rt;  // always rt
        prmt_old_dest_arch_reg_tag = instr_rd;  // can be rd, rt, or 31
        // reg map rename
        prmt_rename_valid = 1'b0;   // can be 0 (non-writing instr or no ivalid) or 1 (successful dispatch writing instr)
        prmt_rename_dest_arch_reg_tag = instr_rd;  // can be rd, rt, or 31
        // prmt_rename_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;  // always prfl dequeue
        // reg map revert
        // prmt_revert_valid = kill_bus_valid;   // always kill bus valid
        // prmt_revert_dest_arch_reg_tag = kill_bus_arch_reg_tag;  // always kill bus val
        // prmt_revert_safe_dest_phys_reg_tag = kill_bus_safe_phys_reg_tag;    // always kill bus val
        // prmt_revert_speculated_dest_phys_reg_tag = kill_bus_speculated_phys_reg_tag;    // always kill bus val
        // reg map checkpoint save
        prmt_save_checkpoint_valid = 1'b0;  // can be 0 or 1 (successful dispatch jr, beq, or bne)
        // prmt_save_checkpoint_ROB_index = ROB_tail_index;    // always ROB tail index
        // reg map checkpoint restore
        // prmt_restore_checkpoint_valid = restore_checkpoint_valid;   // always restore valid
        // prmt_restore_checkpoint_speculate_failed = restore_checkpoint_speculate_failed; // always restore val
        // prmt_restore_checkpoint_ROB_index = restore_checkpoint_ROB_index;   // always restore val
        // prmt_restore_checkpoint_safe_column = restore_checkpoint_safe_column;   // always restore val

        // phys_reg_free_list:

        // dequeue
        prfl_dequeue_valid = 1'b0;  // can be 0 or 1 (successful dispatch writing instr)
        // enqueue
        // prfl_enqueue_valid = ROB_retire_valid;  // always ROB retire valid
        // prfl_enqueue_phys_reg_tag = ROB_retire_phys_reg_tag;    // always ROB retire val
        // full/empty
        // reg map revert
        // prfl_revert_valid = kill_bus_valid; // always kill bus valid
        // prfl_revert_speculated_dest_phys_reg_tag = kill_bus_speculated_phys_reg_tag;    // always kill bus val
        // free list checkpoint save
        prfl_save_checkpoint_valid = 1'b0;  // can be 0 or 1 (successful dispatch jr, beq, or bne)
        // prfl_save_checkpoint_ROB_index = ROB_tail_index;    // always ROB tail index
        // free list checkpoint restore
        // prfl_restore_checkpoint_valid = restore_checkpoint_valid;   // always restore valid
        // prfl_restore_checkpoint_speculate_failed = restore_checkpoint_speculate_failed; // always restore
        // prfl_restore_checkpoint_ROB_index = restore_checkpoint_ROB_index;   // always restore val
        // prfl_restore_checkpoint_safe_column = restore_checkpoint_safe_column;   // always restore val

        // phys_reg_ready_table:
    
        // dispatch
        // prrt_dispatch_source_0_phys_reg_tag = prmt_source_phys_reg_tag_0;   // always phys reg rs
        // prrt_dispatch_source_1_phys_reg_tag = prmt_source_phys_reg_tag_1;   // always phys reg rt
        prrt_dispatch_dest_write = 1'b0;    // can be 0 or 1 (successful dispatch writing instr)
        // prrt_dispatch_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;    // always dequeue'd phys reg from free list 
        // complete
        // prrt_complete_bus_0_valid = complete_bus_0_valid;   // always complete bus valid
        // prrt_complete_bus_0_dest_phys_reg_tag = complete_bus_0_dest_phys_reg_tag;   // always complete bus val
        // prrt_complete_bus_1_valid = complete_bus_1_valid;   // always complete bus valid
        // prrt_complete_bus_1_dest_phys_reg_tag = complete_bus_1_dest_phys_reg_tag;   // always complete bus val

        /////////////////////
        // output signals: //
        /////////////////////

        // DUT error
            // accumulate internal modules here
            // add own module error later in block
        next_DUT_error = prmt_DUT_error | prfl_DUT_error | prrt_DUT_error;

        // core control interface
            // dispatch fails by default
        core_control_dispatch_failed = 1'b1;

        // restore interface
            // no success by default
        restore_checkpoint_success = 1'b0;

        // ROB interface
            // no ROB enqueue by default
        ROB_enqueue_valid = 1'b0;

        // ALU RS 0 interface
            // no task by default
        ALU_RS_task_valid[0] = 1'b0;

        // ALU RS 1 interface
            // no task by default
        ALU_RS_task_valid[1] = 1'b0;

        // SQ interface
            // no task by default
        SQ_task_valid = 1'b0;

        // LQ interface
            // no task by default
        LQ_task_valid = 1'b0;

        // BRU RS interface
            // no task by default
        BRU_RS_task_valid = 1'b0;

        /////////////////////
        // output structs: //
        /////////////////////

        // ROB struct
            // valid, incomplete writing instr to rd
            // no dispatched unit
        ROB_struct_out.valid = 1'b1;
        ROB_struct_out.complete = 1'b0;
        ROB_struct_out.dispatched_unit.ALU_0 = 1'b0;
        ROB_struct_out.dispatched_unit.ALU_1 = 1'b0;
        ROB_struct_out.dispatched_unit.LQ = 1'b0;
        ROB_struct_out.dispatched_unit.SQ = 1'b0;
        ROB_struct_out.dispatched_unit.BRU = 1'b0;
        ROB_struct_out.dispatched_unit.J = 1'b0;
        ROB_struct_out.dispatched_unit.DEAD = 1'b0;
        ROB_struct_out.dispatched_unit.HALT = 1'b0;
        ROB_struct_out.restart_PC = dispatch_unit_PC;
        ROB_struct_out.reg_write = 1'b1;
        ROB_struct_out.dest_arch_reg_tag = instr_rd;
        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;

        // ALU 0 struct
            // RTYPE ADD
            // rs, rt, rd -> map table phys 0, map table phys 1, free list phys
            // needed and ready
        ALU_RS_task_struct[0].op = ALU_ADD;
        ALU_RS_task_struct[0].itype = 1'b0;
        ALU_RS_task_struct[0].source_0.needed = 1'b1;
        ALU_RS_task_struct[0].source_0.ready = prrt_dispatch_source_0_ready;
        ALU_RS_task_struct[0].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
        ALU_RS_task_struct[0].source_1.needed = 1'b1;
        ALU_RS_task_struct[0].source_1.ready = prrt_dispatch_source_1_ready;
        ALU_RS_task_struct[0].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
        ALU_RS_task_struct[0].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
        ALU_RS_task_struct[0].imm16 = instr_imm16;
        ALU_RS_task_struct[0].ROB_index = ROB_tail_index;

        // ALU 1 struct
            // RTYPE ADD
            // rs, rt, rd -> map table phys 0, map table phys 1, free list phys
            // rs and rt needed and ready
        ALU_RS_task_struct[1].op = ALU_ADD;
        ALU_RS_task_struct[1].itype = 1'b0;
        ALU_RS_task_struct[1].source_0.needed = 1'b1;
        ALU_RS_task_struct[1].source_0.ready = prrt_dispatch_source_0_ready;
        ALU_RS_task_struct[1].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
        ALU_RS_task_struct[1].source_1.needed = 1'b1;
        ALU_RS_task_struct[1].source_1.ready = prrt_dispatch_source_1_ready;
        ALU_RS_task_struct[1].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
        ALU_RS_task_struct[1].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
        ALU_RS_task_struct[1].imm16 = instr_imm16;
        ALU_RS_task_struct[1].ROB_index = ROB_tail_index;

        // LQ struct
            // LW
            // R[rt] <= M[low14(R[rs]) + low14(imm16)]
            // rs needed and ready
        LQ_task_struct.op = LQ_LW;
        LQ_task_struct.source.needed = 1'b1;
        LQ_task_struct.source.ready = prrt_dispatch_source_0_ready;
        LQ_task_struct.source.phys_reg_tag = prmt_source_phys_reg_tag_0;
        LQ_task_struct.dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
        LQ_task_struct.imm14 = imm16[15:2];
        LQ_task_struct.SQ_index = SQ_tail_index;
        LQ_task_struct.ROB_index = ROB_tail_index;

        // SQ struct
            // SW
            // M[low14(R[rs]) + low14(imm16)] <= R[rt]
            // rs and rt needed and ready
        SQ_task_struct.op = SQ_SW;
        SQ_task_struct.source_0.needed = 1'b1;
        SQ_task_struct.source_0.ready = prrt_dispatch_source_0_ready;
        SQ_task_struct.source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
        SQ_task_struct.source_1.needed = 1'b1;
        SQ_task_struct.source_1.ready = prrt_dispatch_source_1_ready;
        SQ_task_struct.source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
        SQ_task_struct.imm14 = imm16[15:2];
        SQ_task_struct.LQ_index = LQ_tail_index;
        SQ_task_struct.ROB_index = ROB_tail_index;

        // BRU struct
            // BEQ
            // PC <= (low14(R[rs]) == low14(R[rt])) ? PC14+1+low14(imm16) : PC14+1
            // rs and rt needed
            // checkpoint column from phys reg map table
        BRU_RS_task_struct.op = BRU_BEQ;
        BRU_RS_task_struct.source_0.needed = 1'b1;
        BRU_RS_task_struct.source_0.ready = prrt_dispatch_source_0_ready;
        BRU_RS_task_struct.source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
        BRU_RS_task_struct.source_1.needed = 1'b1;
        BRU_RS_task_struct.source_1.ready = prrt_dispatch_source_1_ready;
        BRU_RS_task_struct.source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
        BRU_RS_task_struct.imm14 = imm16[15:2];
        BRU_RS_task_struct.PC = dispatch_unit_PC;
        BRU_RS_task_struct.nPC = dispatch_unit_nPC;
        BRU_RS_task_struct.checkpoint_safe_column = prmt_save_checkpoint_safe_column;
        BRU_RS_task_struct.ROB_index = ROB_tail_index;

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // logic:

        ////////////////////////////////
        // ALU RS availability logic: //
        ////////////////////////////////
            // always allowed
            // 0 > 1 priority

        // cover 4 cases
        casez (ALU_RS_full) begin
            
            2'b00:
            begin
                ALU_RS_select = 1'b0;
                ALU_RS_both_full = 1'b0;
            end

            2'b01:
            begin
                ALU_RS_select = 1'b1;
                ALU_RS_both_full = 1'b0;
            end

            2'b10:
            begin
                ALU_RS_select = 1'b0;
                ALU_RS_both_full = 1'b0;
            end

            2'b11:
            begin
                ALU_RS_select = 1'b0;
                ALU_RS_both_full = 1'b1;
            end
        end
        endcase

        /////////////////////
        // complete logic: //
        /////////////////////
            // always allowed
            // ALREADY CONNECTED

        ////////////////////
        // restore logic: //
        ////////////////////
            // always allowed
            // MOSTLY CONNECTED
            // need connect restore successes 
                // can just choose one since should always be same
            // assert restore successes always same
            // assert in flush state if restoring

        // top level restore success follows map table success
        restore_checkpoint_success = prmt_restore_checkpoint_success;
        // assert restore successes always same
        if (prmt_restore_checkpoint_success != prfl_restore_checkpoint_success) begin
            $display("dispatch_unit: ERROR: prmt_restore_checkpoint_success != prfl_restore_checkpoint_success");
            $display("\tprmt_restore_checkpoint_success = %h", prmt_restore_checkpoint_success);
            $display("\tprfl_restore_checkpoint_success = %h", prfl_restore_checkpoint_success);
            next_DUT_error = 1'b1;
        end
        // assert in flush state if restoring
        if (restore_checkpoint_valid & ~core_control_flush_dispatch_unit) begin
            $display("dispatch_unit: ERROR: restoring but not flushing");
            $display("\trestore_checkpoint_valid = %h", restore_checkpoint_valid);
            $display("\tcore_control_flush_dispatch_unit = %h", core_control_flush_dispatch_unit);
            next_DUT_error = 1'b1;
        end

        /////////////////////
        // kill bus logic: //
        /////////////////////
            // always allowed
            // ALREADY CONNECTED
            // assert in flush state if killing

        // assert in flush state if killing
        if (kill_bus_valid & ~core_control_flush_dispatch_unit) begin
            $display("dispatch_unit: ERROR: killing but not flushing");
            $display("\tkill_bus_valid = %h", kill_bus_valid);
            $display("\tcore_control_flush_dispatch_unit = %h", core_control_flush_dispatch_unit);
            next_DUT_error = 1'b1;
        end

        /////////////////////
        // dispatch logic: //
        /////////////////////
            // priority order

        // check for halt
        if (core_control_halt) begin

            // FAIL: keep default outputs

            $display("dispatch_unit: FAIL: core_control_halt");
        end

        // check for flush
        else if (core_control_flush_dispatch_unit) begin

            // FAIL: keep default outputs

            $display("dispatch_unit: FAIL: core_control_flush_dispatch_unit");
        end

        // check for stall
        else if (core_control_stall_dispatch_unit) begin

            // FAIL: keep default outputs

            $display("dispatch_unit: FAIL: core_control_stall_dispatch_unit");
        end

        // check for no available instr 
        else if (~dispatch_unit_ivalid) begin

            // FAIL: keep default outputs

            $display("dispatch_unit: FAIL: ~dispatch_unit_ivalid");
        end

        // otherwise, have instr that can try to dispatch
        else begin

            // by opcode
            casez (instr_opcode) begin

                ///////////////////////////////////////////////////////////////////////////////////////////
                // RTYPE
                RTYPE: 
                begin

                    // special case: JR -> needs to go to BRU
                    if (instr_funct == JR) begin

                        // fail if BRU RS full
                        if (BRU_RS_full) begin
                            $display("dispatch_unit: FAIL: BRU_RS_full");
                            core_control_dispatch_failed = 1'b1;
                        end

                        // otherwise, can dispatch to BRU
                            // incomplete
                            // need rs
                            // non-writing instr
                            // save checkpoint
                        else begin

                            // internal module control
                            prmt_old_dest_arch_reg_tag = instr_rd;
                            prmt_rename_valid = 1'b0;
                            prmt_rename_dest_arch_reg_tag = instr_rd;
                            prmt_save_checkpoint_valid = 1'b1;
                            prfl_dequeue_valid = 1'b0;
                            prfl_save_checkpoint_valid = 1'b1;
                            prrt_dispatch_dest_write = 1'b0;
                            // no dispatch fail
                            core_control_dispatch_failed = 1'b0;
                            // enqueue ROB
                            ROB_enqueue_valid = 1'b1;
                            // fill in ROB struct
                            ROB_struct_out.valid = 1'b1;
                            ROB_struct_out.complete = 1'b0;
                            ROB_struct_out.dispatched_unit.BRU = 1'b1;
                            ROB_struct_out.restart_PC = dispatch_unit_PC;
                            ROB_struct_out.reg_write = 1'b0;
                            ROB_struct_out.dest_arch_reg_tag = instr_rd;
                            ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                            ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                            // send BRU task
                            BRU_RS_task_valid = 1'b1;
                            // fill in BRU struct
                            BRU_RS_task_struct.op = BRU_JR;
                            BRU_RS_task_struct.source_0.needed = 1'b1;
                            BRU_RS_task_struct.source_0.ready = prrt_dispatch_source_0_ready;
                            BRU_RS_task_struct.source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                            BRU_RS_task_struct.source_1.needed = 1'b0;
                            BRU_RS_task_struct.source_1.ready = prrt_dispatch_source_1_ready;
                            BRU_RS_task_struct.source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                            BRU_RS_task_struct.imm14 = imm16[15:2];
                            BRU_RS_task_struct.PC = dispatch_unit_PC;
                            BRU_RS_task_struct.nPC = dispatch_unit_nPC;
                            BRU_RS_task_struct.checkpoint_safe_column = prmt_save_checkpoint_safe_column;
                            BRU_RS_task_struct.ROB_index = ROB_tail_index;
                        end
                    end

                    // otherwise, potential proper RTYPE instr
                    else begin

                        // check for dead instr -> write to rd = $0
                        if (instr_rd == 5'd0) begin
                            $display("dispatch_unit: FAIL: instr_rd == 5'd0");
                            
                            // immediately complete
                            // dispatched unit is DEAD

                            // no dispatch fail
                            core_control_dispatch_failed = 1'b0;
                            // enqueue ROB
                            ROB_enqueue_valid = 1'b1;
                            // fill in ROB struct
                            ROB_struct_out.valid = 1'b1;
                            ROB_struct_out.complete = 1'b1;
                            ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                            ROB_struct_out.restart_PC = dispatch_unit_PC;
                            ROB_struct_out.reg_write = 1'b0;
                            ROB_struct_out.dest_arch_reg_tag = instr_rd;
                            ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                            ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        end

                        // fail if ALU RS's full 
                        else if (ALU_RS_both_full) begin
                            $display("dispatch_unit: FAIL: ALU_RS_both_full");
                            core_control_dispatch_failed = 1'b1;
                        end

                        // otherwise, can dispatch to an ALU RS
                        else begin
                            // incomplete
                            // need rs and rt
                            // writing instr

                            // internal module control
                            prmt_old_dest_arch_reg_tag = instr_rd;
                            prmt_rename_valid = 1'b1;
                            prmt_rename_dest_arch_reg_tag = instr_rd;
                            prmt_save_checkpoint_valid = 1'b0;
                            prfl_dequeue_valid = 1'b1;
                            prfl_save_checkpoint_valid = 1'b0;
                            prrt_dispatch_dest_write = 1'b1;
                            // no dispatch fail
                            core_control_dispatch_failed = 1'b0;
                            // enqueue ROB
                            ROB_enqueue_valid = 1'b1;
                            // fill in ROB struct
                            ROB_struct_out.valid = 1'b1;
                            ROB_struct_out.complete = 1'b0;
                            if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                            else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                            ROB_struct_out.restart_PC = dispatch_unit_PC;
                            ROB_struct_out.reg_write = 1'b1;
                            ROB_struct_out.dest_arch_reg_tag = instr_rd;
                            ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                            ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                            // send ALU RS task to selected
                            ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                            // fill in selected ALU RS struct
                                // ALU_RS_task_struct[ALU_RS_select].op = ALU_ADD;
                                // select op below
                            ALU_RS_task_struct[ALU_RS_select].itype = 1'b0;
                            ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                            ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                            ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                            ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b1;
                            ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                            ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                            ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                            ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                            ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;

                            // fill in ALU RS struct by funct
                            casez (instr_funct) begin

                                NOP:
                                begin
                                    $display("dispatch_unit: ERROR: got to RTYPE NOP case when should've been caught in rd == $0 check");
                                    next_DUT_error = 1'b1;
                                end

                                SLLV:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_SLLV;
                                end

                                SRLV:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_SRLV;
                                end

                                JR:
                                begin
                                    $display("dispatch_unit: ERROR: got to RTYPE JR case when should've been caught in RTYPE & JR check");
                                    next_DUT_error = 1'b1;
                                end

                                ADD, ADDU:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_ADD;
                                end

                                SUB, SUBU:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_SUB;
                                end

                                AND:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_AND;
                                end

                                OR:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_OR;
                                end

                                XOR:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_XOR;
                                end

                                NOR:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_NOR;
                                end

                                SLT:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_SLT;
                                end

                                SLTU:
                                begin
                                    ALU_RS_task_struct[ALU_RS_select].op = ALU_SLTU;
                                end

                                // otherwise, unrecognized RTYPE instr
                                default:
                                begin
                                    $display("dispatch_unit: ERROR: unrecognized RTYPE instr");
                                    next_DUT_error = 1'b1;
                                end
                            end
                            endcase
                        end
                    end
                end

                ///////////////////////////////////////////////////////////////////////////////////////////
                // JTYPE:

                J:
                begin
                    // immediately complete
                    // dispatched unit is J

                    // no dispatch fail
                    core_control_dispatch_failed = 1'b0;
                    // enqueue ROB
                    ROB_enqueue_valid = 1'b1;
                    // fill in ROB struct
                    ROB_struct_out.valid = 1'b1;
                    ROB_struct_out.complete = 1'b1;
                    ROB_struct_out.dispatched_unit.J = 1'b1;
                    ROB_struct_out.restart_PC = dispatch_unit_PC;
                    ROB_struct_out.reg_write = 1'b0;
                    ROB_struct_out.dest_arch_reg_tag = instr_rd;
                    ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                    ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                end

                JAL:
                begin
                    // JAL is an RTYPE LINK op to ALU RS

                    // fail if ALU RS's full 
                    if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // ALU LINK to ALU RS
                        // dispatched units J and ALU
                        // write to $31
                        // don't need rs or rt
                        // PC bits become imm16

                        // internal module control
                        prmt_old_dest_arch_reg_tag = 31;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = 31;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        ROB_struct_out.dispatched_unit.J = 1'b1;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = 31;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_LINK;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = 16'{dispatch_unit_PC, 2'b00};
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                ///////////////////////////////////////////////////////////////////////////////////////////
                // BRANCH:

                BEQ:
                begin
                    // fail if BRU RS full
                    if (BRU_RS_full) begin
                        $display("dispatch_unit: FAIL: BRU_RS_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to BRU
                        // incomplete
                        // need rs and rt
                        // non-writing instr
                        // save checkpoint
                    else begin

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rd;
                        prmt_rename_valid = 1'b0;
                        prmt_rename_dest_arch_reg_tag = instr_rd;
                        prmt_save_checkpoint_valid = 1'b1;
                        prfl_dequeue_valid = 1'b0;
                        prfl_save_checkpoint_valid = 1'b1;
                        prrt_dispatch_dest_write = 1'b0;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        ROB_struct_out.dispatched_unit.BRU = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send BRU task
                        BRU_RS_task_valid = 1'b1;
                        // fill in BRU struct
                        BRU_RS_task_struct.op = BRU_BEQ;
                        BRU_RS_task_struct.source_0.needed = 1'b1;
                        BRU_RS_task_struct.source_0.ready = prrt_dispatch_source_0_ready;
                        BRU_RS_task_struct.source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        BRU_RS_task_struct.source_1.needed = 1'b1;
                        BRU_RS_task_struct.source_1.ready = prrt_dispatch_source_1_ready;
                        BRU_RS_task_struct.source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        BRU_RS_task_struct.imm14 = imm16[15:2];
                        BRU_RS_task_struct.PC = dispatch_unit_PC;
                        BRU_RS_task_struct.nPC = dispatch_unit_nPC;
                        BRU_RS_task_struct.checkpoint_safe_column = prmt_save_checkpoint_safe_column;
                        BRU_RS_task_struct.ROB_index = ROB_tail_index;
                    end
                end

                BNE:
                begin
                    // fail if BRU RS full
                    if (BRU_RS_full) begin
                        $display("dispatch_unit: FAIL: BRU_RS_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to BRU
                        // incomplete
                        // need rs and rt
                        // non-writing instr
                        // save checkpoint
                    else begin

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rd;
                        prmt_rename_valid = 1'b0;
                        prmt_rename_dest_arch_reg_tag = instr_rd;
                        prmt_save_checkpoint_valid = 1'b1;
                        prfl_dequeue_valid = 1'b0;
                        prfl_save_checkpoint_valid = 1'b1;
                        prrt_dispatch_dest_write = 1'b0;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        ROB_struct_out.dispatched_unit.BRU = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send BRU task
                        BRU_RS_task_valid = 1'b1;
                        // fill in BRU struct
                        BRU_RS_task_struct.op = BRU_BNE;
                        BRU_RS_task_struct.source_0.needed = 1'b1;
                        BRU_RS_task_struct.source_0.ready = prrt_dispatch_source_0_ready;
                        BRU_RS_task_struct.source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        BRU_RS_task_struct.source_1.needed = 1'b1;
                        BRU_RS_task_struct.source_1.ready = prrt_dispatch_source_1_ready;
                        BRU_RS_task_struct.source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        BRU_RS_task_struct.imm14 = imm16[15:2];
                        BRU_RS_task_struct.PC = dispatch_unit_PC;
                        BRU_RS_task_struct.nPC = dispatch_unit_nPC;
                        BRU_RS_task_struct.checkpoint_safe_column = prmt_save_checkpoint_safe_column;
                        BRU_RS_task_struct.ROB_index = ROB_tail_index;
                    end
                end

                ///////////////////////////////////////////////////////////////////////////////////////////
                // ITYPE:

                ADDI:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_ADD;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                ADDIU:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_ADD;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                SLTI:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_SLT;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                SLTIU:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_SLTU;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                ANDI:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_AND;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                ORI:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_OR;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                XORI:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_XOR;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                LUI:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if ALU RS's full 
                    else if (ALU_RS_both_full) begin
                        $display("dispatch_unit: FAIL: ALU_RS_both_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to an ALU RS
                    else begin
                        // incomplete
                        // don't need rs or rt
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        if (ALU_RS_select)  ROB_struct_out.dispatched_unit.ALU_1 = 1'b1;
                        else                ROB_struct_out.dispatched_unit.ALU_0 = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send ALU RS task to selected
                        ALU_RS_task_valid[ALU_RS_select] = 1'b1;
                        // fill in selected ALU RS struct
                        ALU_RS_task_struct[ALU_RS_select].op = ALU_LUI;
                        ALU_RS_task_struct[ALU_RS_select].itype = 1'b1;
                        ALU_RS_task_struct[ALU_RS_select].source_0.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_0.ready = prrt_dispatch_source_0_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.needed = 1'b0;
                        ALU_RS_task_struct[ALU_RS_select].source_1.ready = prrt_dispatch_source_1_ready;
                        ALU_RS_task_struct[ALU_RS_select].source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        ALU_RS_task_struct[ALU_RS_select].dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        ALU_RS_task_struct[ALU_RS_select].imm16 = instr_imm16;
                        ALU_RS_task_struct[ALU_RS_select].ROB_index = ROB_tail_index;
                    end
                end

                ///////////////////////////////////////////////////////////////////////////////////////////
                // LOAD/STORE:

                LW:
                begin
                    // check for dead instr -> write to rt = $0
                    if (instr_rt == 5'd0) begin
                        $display("dispatch_unit: FAIL: instr_rt == 5'd0");
                            
                        // immediately complete
                        // dispatched unit is DEAD

                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b1;
                        ROB_struct_out.dispatched_unit.DEAD = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b0;
                        ROB_struct_out.dest_arch_reg_tag = instr_rd;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                    end

                    // fail if LQ full
                    else if (LQ_full) begin
                        $display("dispatch_unit: FAIL: LQ_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to LQ
                    else begin
                        // incomplete
                        // need rs
                        // writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b1;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b1;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b1;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        ROB_struct_out.dispatched_unit.LQ = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send LQ task
                        LQ_task_valid = 1'b1;
                        // fill in LQ struct
                        LQ_task_struct.op = LQ_LW;
                        LQ_task_struct.source.needed = 1'b1;
                        LQ_task_struct.source.ready = prrt_dispatch_source_0_ready;
                        LQ_task_struct.source.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        LQ_task_struct.dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        LQ_task_struct.imm14 = imm16[15:2];
                        LQ_task_struct.SQ_index = SQ_tail_index;
                        LQ_task_struct.ROB_index = ROB_tail_index;
                    end
                end

                SW:
                begin
                    // fail if SQ full
                    if (SQ_full) begin
                        $display("dispatch_unit: FAIL: SQ_full");
                        core_control_dispatch_failed = 1'b1;
                    end

                    // otherwise, can dispatch to SQ
                    else begin
                        // incomplete
                        // need rs and rt
                        // non-writing instr

                        // internal module control
                        prmt_old_dest_arch_reg_tag = instr_rt;
                        prmt_rename_valid = 1'b0;
                        prmt_rename_dest_arch_reg_tag = instr_rt;
                        prmt_save_checkpoint_valid = 1'b0;
                        prfl_dequeue_valid = 1'b0;
                        prfl_save_checkpoint_valid = 1'b0;
                        prrt_dispatch_dest_write = 1'b0;
                        // no dispatch fail
                        core_control_dispatch_failed = 1'b0;
                        // enqueue ROB
                        ROB_enqueue_valid = 1'b1;
                        // fill in ROB struct
                        ROB_struct_out.valid = 1'b1;
                        ROB_struct_out.complete = 1'b0;
                        ROB_struct_out.dispatched_unit.SQ = 1'b1;
                        ROB_struct_out.restart_PC = dispatch_unit_PC;
                        ROB_struct_out.reg_write = 1'b1;
                        ROB_struct_out.dest_arch_reg_tag = instr_rt;
                        ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                        ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                        // send SQ task
                        SQ_task_valid = 1'b1;
                        // fill in SQ struct
                        SQ_task_struct.op = SQ_SW;
                        SQ_task_struct.source_0.needed = 1'b1;
                        SQ_task_struct.source_0.ready = prrt_dispatch_source_0_ready;
                        SQ_task_struct.source_0.phys_reg_tag = prmt_source_phys_reg_tag_0;
                        SQ_task_struct.source_1.needed = 1'b1;
                        SQ_task_struct.source_1.ready = prrt_dispatch_source_1_ready;
                        SQ_task_struct.source_1.phys_reg_tag = prmt_source_phys_reg_tag_1;
                        SQ_task_struct.imm14 = imm16[15:2];
                        SQ_task_struct.LQ_index = LQ_tail_index;
                        SQ_task_struct.ROB_index = ROB_tail_index;
                    end
                end

                LL:
                begin
                    $display("dispatch_unit: ERROR: LL not handled yet");
                    next_DUT_error = 1'b1;
                end

                SC:
                begin
                    $display("dispatch_unit: ERROR: SC not handled yet");
                    next_DUT_error = 1'b1;
                end

                ///////////////////////////////////////////////////////////////////////////////////////////
                // HALT:

                HALT:
                begin
                    // immediately complete
                    // dispatched unit is HALT

                    // no dispatch fail
                    core_control_dispatch_failed = 1'b0;
                    // enqueue ROB
                    ROB_enqueue_valid = 1'b1;
                    // fill in ROB struct
                    ROB_struct_out.valid = 1'b1;
                    ROB_struct_out.complete = 1'b1;
                    ROB_struct_out.dispatched_unit.HALT = 1'b1;
                    ROB_struct_out.restart_PC = dispatch_unit_PC;
                    ROB_struct_out.reg_write = 1'b0;
                    ROB_struct_out.dest_arch_reg_tag = instr_rd;
                    ROB_struct_out.safe_dest_phys_reg_tag = prmt_old_dest_phys_reg_tag;
                    ROB_struct_out.speculated_dest_phys_reg_tag = prfl_dequeue_phys_reg_tag;
                end

                default:
                begin
                    $display("dispatch_unit: ERROR: unrecognized opcode");
                    next_DUT_error = 1'b1; 
                end
            end
            endcase
        end
    end

endmodule