/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: core.sv
    Instantiation Hierarchy: system -> core
    Description:

        The core interacts with the i$ and d$, reading and executing instructions and making data memory
        accesses. 

        The core includes the following sub-modules:
            - fetch_unit
            - dispatch_unit
                - phys_reg_map_table
                - phys_reg_ready_table
                - phys_reg_free_list
            - rob
            - phys_reg_file
            - alu_pipeline x 2
            - bru_pipeline
            - lsq

        The fetch_unit is the only sub-module that talks to the i$.
        The lsq is the only sub-module that talks to the d$.

        There is very little functionality in the core other than connecting the sub-modules. Any hazard
        handling and control flow handling is largely handled by the rob getting information from the 
        the bru_pipeline and lsq and communicating that back to the fetch_unit and dispatch_unit, and 
        the execution pipelines as required. 

		multicore updates:
			- d$ inv port + evict port
*/

`include "core_types.vh"
import core_types_pkg::*;

module core #(
    parameter PC_RESET_VAL = 16'h0
) (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    ///////////////////
    // i$ interface: //
    ///////////////////
        // synchronous, blocking interface
        // essentially same as 437
    input logic icache_hit,
    input word_t icache_load,
    output logic icache_REN,
    output word_t icache_addr,
    output logic icache_halt,

    ///////////////////
    // d$ interface: //
    ///////////////////
        // asynchronous, non-blocking interface

    // read req interface:
    output logic dcache_read_req_valid,
    output LQ_index_t dcache_read_req_LQ_index,
    output daddr_t dcache_read_req_addr,
    output logic dcache_read_req_linked,
    output logic dcache_read_req_conditional,
    input logic dcache_read_req_blocked,

    // read resp interface:
    input logic dcache_read_resp_valid,
    input LQ_index_t dcache_read_resp_LQ_index,
    input word_t dcache_read_resp_data,

    // write req interface:
    output logic dcache_write_req_valid,
    output daddr_t dcache_write_req_addr,
    output word_t dcache_write_req_data,
    output logic dcache_write_req_conditional,
    input logic dcache_write_req_blocked,

    // read kill interface x2:
    output logic dcache_read_kill_0_valid,
    output LQ_index_t dcache_read_kill_0_LQ_index,
    output logic dcache_read_kill_1_valid,
    output LQ_index_t dcache_read_kill_1_LQ_index,

    // invalidation interface:
    input logic dcache_inv_valid,
    input block_addr_t dcache_inv_block_addr,
    input logic dcache_evict_valid,
    input block_addr_t dcache_evict_block_addr,

    // halt interface:
    output logic dcache_halt
);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // sub-module instantiation:

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // fetch_unit: 

    // inputs: 

    // BTB/DIRP inputs from pipeline
    logic FU_from_pipeline_BTB_DIRP_update;
    logic [LOG_BTB_FRAMES-1:0] FU_from_pipeline_BTB_DIRP_index;
    pc_t FU_from_pipeline_BTB_target;
    logic FU_from_pipeline_DIRP_taken;

    // resolved target from pipepline
    logic FU_from_pipeline_take_resolved;
    pc_t FU_from_pipeline_resolved_PC;

    // I$
    logic FU_icache_hit;
    word_t FU_icache_load;

    // core controller
    logic FU_core_control_stall_fetch_unit;
    logic FU_core_control_halt;

    // outputs:

    // DUT error
    logic FU_DUT_error;

    // I$
    logic FU_icache_REN;
    word_t FU_icache_addr;
    logic FU_icache_halt;

    // to pipeline
    word_t FU_to_pipeline_instr;
    logic FU_to_pipeline_ivalid;
    pc_t FU_to_pipeline_PC;
    pc_t FU_to_pipeline_nPC;

    // // fetch unit state
    // fetch_unit_state_t FU_FU_state_out;

    // instantiation:
    fetch_unit #(
        .PC_RESET_VAL(PC_RESET_VAL)
    ) FU (
        // seq
        .CLK(CLK),
        .nRST(nRST),

        // DUT error
        .DUT_error(FU_DUT_error),

        // inputs
        .from_pipeline_BTB_DIRP_update(FU_from_pipeline_BTB_DIRP_update),
        .from_pipeline_BTB_DIRP_index(FU_from_pipeline_BTB_DIRP_index),
        .from_pipeline_BTB_target(FU_from_pipeline_BTB_target),
        .from_pipeline_DIRP_taken(FU_from_pipeline_DIRP_taken),
        
        .from_pipeline_take_resolved(FU_from_pipeline_take_resolved),
        .from_pipeline_resolved_PC(FU_from_pipeline_resolved_PC),
        
        .icache_hit(FU_icache_hit),
        .icache_load(FU_icache_load),

        .core_control_stall_fetch_unit(FU_core_control_stall_fetch_unit),
        .core_control_halt(FU_core_control_halt),

        // outputs
        .icache_REN(FU_icache_REN),
        .icache_addr(FU_icache_addr),
        .icache_halt(FU_icache_halt),

        .to_pipeline_instr(FU_to_pipeline_instr),
        .to_pipeline_ivalid(FU_to_pipeline_ivalid),
        .to_pipeline_PC(FU_to_pipeline_PC),
        .to_pipeline_nPC(FU_to_pipeline_nPC)

        // .FU_state_out(FU_FU_state_out)
    );

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // dispatch_unit: 

    // signals:

    // DUT error
	logic DU_DUT_error;

    // core control interface
	logic DU_core_control_stall_dispatch_unit;
	logic DU_core_control_flush_dispatch_unit;
	logic DU_core_control_halt;
	logic DU_core_control_dispatch_failed;

    // fetch_unit interface
	word_t DU_fetch_unit_instr;
	logic DU_fetch_unit_ivalid;
	pc_t DU_fetch_unit_PC;
	pc_t DU_fetch_unit_nPC;

    // restore interface
	logic DU_restore_checkpoint_valid;
	logic DU_restore_checkpoint_speculate_failed;
	ROB_index_t DU_restore_checkpoint_ROB_index;
	checkpoint_column_t DU_restore_checkpoint_safe_column;
	logic DU_restore_checkpoint_success;

    // kill bus interface
        // kill for ROB_index, T, T_old
	logic DU_kill_bus_valid;
	ROB_index_t DU_kill_bus_ROB_index;
        // actually don't need this, only need ROB index for execution unit kills
	arch_reg_tag_t DU_kill_bus_arch_reg_tag;
	phys_reg_tag_t DU_kill_bus_speculated_phys_reg_tag;
	phys_reg_tag_t DU_kill_bus_safe_phys_reg_tag;

    // complete bus interface
        // 2x ready @ T
	logic DU_complete_bus_0_valid;
	phys_reg_tag_t DU_complete_bus_0_dest_phys_reg_tag;
	logic DU_complete_bus_1_valid;
	phys_reg_tag_t DU_complete_bus_1_dest_phys_reg_tag;
	logic DU_complete_bus_2_valid;
	phys_reg_tag_t DU_complete_bus_2_dest_phys_reg_tag;

    // ROB interface
    // dispatch @ tail
	logic DU_ROB_full;
	ROB_index_t DU_ROB_tail_index;
	logic DU_ROB_enqueue_valid;
	ROB_entry_t DU_ROB_struct_out;
    // retire from head
	logic DU_ROB_retire_valid;
	phys_reg_tag_t DU_ROB_retire_phys_reg_tag;

    // 2x ALU RS interface
	logic [1:0] DU_ALU_RS_full;
	logic [1:0] DU_ALU_RS_task_valid;
	ALU_RS_input_struct_t [1:0] DU_ALU_RS_task_struct;

    // LQ interface
	// LQ_index_t DU_LQ_tail_index;
	logic DU_LQ_full;
	logic DU_LQ_task_valid;
	LQ_enqueue_struct_t DU_LQ_task_struct;

    // SQ interface
	// SQ_index_t DU_SQ_tail_index;
	logic DU_SQ_full;
	logic DU_SQ_task_valid;
	SQ_enqueue_struct_t DU_SQ_task_struct;

    // BRU RS interface
	logic DU_BRU_RS_full;
	logic DU_BRU_RS_task_valid;
	BRU_RS_input_struct_t DU_BRU_RS_task_struct;

    // instantiation:
    dispatch_unit DU (
		
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(DU_DUT_error),

	    // core control interface
		.core_control_stall_dispatch_unit(DU_core_control_stall_dispatch_unit),
		.core_control_flush_dispatch_unit(DU_core_control_flush_dispatch_unit),
		.core_control_halt(DU_core_control_halt),
		.core_control_dispatch_failed(DU_core_control_dispatch_failed),

	    // fetch_unit interface
		.fetch_unit_instr(DU_fetch_unit_instr),
		.fetch_unit_ivalid(DU_fetch_unit_ivalid),
		.fetch_unit_PC(DU_fetch_unit_PC),
		.fetch_unit_nPC(DU_fetch_unit_nPC),

	    // restore interface
		.restore_checkpoint_valid(DU_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(DU_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(DU_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(DU_restore_checkpoint_safe_column),
		.restore_checkpoint_success(DU_restore_checkpoint_success),

	    // kill bus interface
	        // kill for ROB_index, T, T_old
		.kill_bus_valid(DU_kill_bus_valid),
		.kill_bus_ROB_index(DU_kill_bus_ROB_index),
	        // actually don't need this, only need ROB index for execution unit kills
		.kill_bus_arch_reg_tag(DU_kill_bus_arch_reg_tag),
		.kill_bus_speculated_phys_reg_tag(DU_kill_bus_speculated_phys_reg_tag),
		.kill_bus_safe_phys_reg_tag(DU_kill_bus_safe_phys_reg_tag),

	    // complete bus interface
	        // 2x ready @ T
		.complete_bus_0_valid(DU_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(DU_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_1_valid(DU_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(DU_complete_bus_1_dest_phys_reg_tag),
		.complete_bus_2_valid(DU_complete_bus_2_valid),
		.complete_bus_2_dest_phys_reg_tag(DU_complete_bus_2_dest_phys_reg_tag),

	    // ROB interface
	    // dispatch @ tail
		.ROB_full(DU_ROB_full),
		.ROB_tail_index(DU_ROB_tail_index),
		.ROB_enqueue_valid(DU_ROB_enqueue_valid),
		.ROB_struct_out(DU_ROB_struct_out),
	    // retire from head
		.ROB_retire_valid(DU_ROB_retire_valid),
		.ROB_retire_phys_reg_tag(DU_ROB_retire_phys_reg_tag),

	    // 2x ALU RS interface
		.ALU_RS_full(DU_ALU_RS_full),
		.ALU_RS_task_valid(DU_ALU_RS_task_valid),
		.ALU_RS_task_struct(DU_ALU_RS_task_struct),

	    // SQ interface
		// .SQ_tail_index(DU_SQ_tail_index),
		.SQ_full(DU_SQ_full),
		.SQ_task_valid(DU_SQ_task_valid),
		.SQ_task_struct(DU_SQ_task_struct),

	    // LQ interface
		// .LQ_tail_index(DU_LQ_tail_index),
		.LQ_full(DU_LQ_full),
		.LQ_task_valid(DU_LQ_task_valid),
		.LQ_task_struct(DU_LQ_task_struct),

	    // BRU RS interface
		.BRU_RS_full(DU_BRU_RS_full),
		.BRU_RS_task_valid(DU_BRU_RS_task_valid),
		.BRU_RS_task_struct(DU_BRU_RS_task_struct)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // rob:

    // signals:

    // DUT error
	logic ROB_DUT_error;

    // full/empty
	logic ROB_full;
	logic ROB_empty;

    // fetch unit interface
	logic ROB_fetch_unit_take_resolved;
	pc_t ROB_fetch_unit_resolved_PC;

    // dispatch unit interface
    // dispatch @ tail
	ROB_index_t ROB_dispatch_unit_ROB_tail_index;
	logic ROB_dispatch_unit_enqueue_valid;
	ROB_entry_t ROB_dispatch_unit_enqueue_struct;
    // retire from head
	logic ROB_dispatch_unit_retire_valid;
	phys_reg_tag_t ROB_dispatch_unit_retire_phys_reg_tag;

    // complete bus interfaces
        // want ROB index for complete write
        // ROB doesn't need write tag but can use for assertion
	logic ROB_complete_bus_0_valid;
	phys_reg_tag_t ROB_complete_bus_0_dest_phys_reg_tag;
	ROB_index_t ROB_complete_bus_0_ROB_index;
	logic ROB_complete_bus_1_valid;
	phys_reg_tag_t ROB_complete_bus_1_dest_phys_reg_tag;
	ROB_index_t ROB_complete_bus_1_ROB_index;
	logic ROB_complete_bus_2_valid;
	phys_reg_tag_t ROB_complete_bus_2_dest_phys_reg_tag;
	ROB_index_t ROB_complete_bus_2_ROB_index;

    // BRU interface
    // complete
	logic ROB_BRU_complete_valid;
	// ROB_index_t tb_BRU_complete_ROB_index;
    // restart info
	logic ROB_BRU_restart_valid;
	ROB_index_t ROB_BRU_restart_ROB_index;
	pc_t ROB_BRU_restart_PC;
	checkpoint_column_t ROB_BRU_restart_safe_column;

    // LQ interface
    // restart info
	logic ROB_LQ_restart_valid;
	logic ROB_LQ_restart_after_instr;
	ROB_index_t ROB_LQ_restart_ROB_index;
    // retire
	logic ROB_LQ_retire_valid;
	ROB_index_t ROB_LQ_retire_ROB_index;
	logic ROB_LQ_retire_blocked;

    // SQ interface
    // complete
	logic ROB_SQ_complete_valid;
	ROB_index_t ROB_SQ_complete_ROB_index;
    // retire
	logic ROB_SQ_retire_valid;
	ROB_index_t ROB_SQ_retire_ROB_index;
	logic ROB_SQ_retire_blocked;

    // restore interface
        // send restore command and check for success
	logic ROB_restore_checkpoint_valid;
	logic ROB_restore_checkpoint_speculate_failed;
	ROB_index_t ROB_restore_checkpoint_ROB_index;
	checkpoint_column_t ROB_restore_checkpoint_safe_column;
	logic ROB_restore_checkpoint_success;

    // revert interface
        // send revert command to dispatch unit
	logic ROB_revert_valid;
	ROB_index_t ROB_revert_ROB_index;
	arch_reg_tag_t ROB_revert_arch_reg_tag;
	phys_reg_tag_t ROB_revert_safe_phys_reg_tag;
	phys_reg_tag_t ROB_revert_speculated_phys_reg_tag;

    // kill bus interface
        // send kill command to execution units
	logic ROB_kill_bus_valid;
	ROB_index_t ROB_kill_bus_ROB_index;

    // core control interface
	logic ROB_core_control_restore_flush;
	logic ROB_core_control_revert_stall;
	logic ROB_core_control_halt_assert;
        // for when halt instr retires

    // // optional outputs:

    // // ROB state
	// ROB_state_t DUT_ROB_state_out, expected_ROB_state_out;

    // // if complete is invalid
	// logic DUT_invalid_complete, expected_invalid_complete;

    // // current ROB capacity
	// logic [LOG_ROB_DEPTH:0] DUT_ROB_capacity, expected_ROB_capacity;

    // instantiation:
	rob ROB (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(ROB_DUT_error),

	    // full/empty
		.full(ROB_full),
		.empty(ROB_empty),

	    // fetch unit interface
		.fetch_unit_take_resolved(ROB_fetch_unit_take_resolved),
		.fetch_unit_resolved_PC(ROB_fetch_unit_resolved_PC),

	    // dispatch unit interface
	    // dispatch @ tail
		.dispatch_unit_ROB_tail_index(ROB_dispatch_unit_ROB_tail_index),
		.dispatch_unit_enqueue_valid(ROB_dispatch_unit_enqueue_valid),
		.dispatch_unit_enqueue_struct(ROB_dispatch_unit_enqueue_struct),
	    // retire from head
		.dispatch_unit_retire_valid(ROB_dispatch_unit_retire_valid),
		.dispatch_unit_retire_phys_reg_tag(ROB_dispatch_unit_retire_phys_reg_tag),

	    // complete bus interfaces
	        // want ROB index for complete write
	        // ROB doesn't need write tag but can use for assertion
		.complete_bus_0_valid(ROB_complete_bus_0_valid),
		.complete_bus_0_dest_phys_reg_tag(ROB_complete_bus_0_dest_phys_reg_tag),
		.complete_bus_0_ROB_index(ROB_complete_bus_0_ROB_index),
		.complete_bus_1_valid(ROB_complete_bus_1_valid),
		.complete_bus_1_dest_phys_reg_tag(ROB_complete_bus_1_dest_phys_reg_tag),
		.complete_bus_1_ROB_index(ROB_complete_bus_1_ROB_index),
		.complete_bus_2_valid(ROB_complete_bus_2_valid),
		.complete_bus_2_dest_phys_reg_tag(ROB_complete_bus_2_dest_phys_reg_tag),
		.complete_bus_2_ROB_index(ROB_complete_bus_2_ROB_index),

	    // BRU interface
	    // complete
		.BRU_complete_valid(ROB_BRU_complete_valid),
		// .BRU_complete_ROB_index(tb_BRU_complete_ROB_index),
	    // restart info
		.BRU_restart_valid(ROB_BRU_restart_valid),
		.BRU_restart_ROB_index(ROB_BRU_restart_ROB_index),
		.BRU_restart_PC(ROB_BRU_restart_PC),
		.BRU_restart_safe_column(ROB_BRU_restart_safe_column),

	    // LQ interface
	    // restart info
		.LQ_restart_valid(ROB_LQ_restart_valid),
		.LQ_restart_after_instr(ROB_LQ_restart_after_instr),
		.LQ_restart_ROB_index(ROB_LQ_restart_ROB_index),
	    // retire
		.LQ_retire_valid(ROB_LQ_retire_valid),
		.LQ_retire_ROB_index(ROB_LQ_retire_ROB_index),
		.LQ_retire_blocked(ROB_LQ_retire_blocked),

	    // SQ interface
	    // complete
		.SQ_complete_valid(ROB_SQ_complete_valid),
		.SQ_complete_ROB_index(ROB_SQ_complete_ROB_index),
	    // retire
		.SQ_retire_valid(ROB_SQ_retire_valid),
		.SQ_retire_ROB_index(ROB_SQ_retire_ROB_index),
		.SQ_retire_blocked(ROB_SQ_retire_blocked),

	    // restore interface
	        // send restore command and check for success
		.restore_checkpoint_valid(ROB_restore_checkpoint_valid),
		.restore_checkpoint_speculate_failed(ROB_restore_checkpoint_speculate_failed),
		.restore_checkpoint_ROB_index(ROB_restore_checkpoint_ROB_index),
		.restore_checkpoint_safe_column(ROB_restore_checkpoint_safe_column),
		.restore_checkpoint_success(ROB_restore_checkpoint_success),

	    // revert interface
	        // send revert command to dispatch unit
		.revert_valid(ROB_revert_valid),
		.revert_ROB_index(ROB_revert_ROB_index),
		.revert_arch_reg_tag(ROB_revert_arch_reg_tag),
		.revert_safe_phys_reg_tag(ROB_revert_safe_phys_reg_tag),
		.revert_speculated_phys_reg_tag(ROB_revert_speculated_phys_reg_tag),

	    // kill bus interface
	        // send kill command to execution units
		.kill_bus_valid(ROB_kill_bus_valid),
		.kill_bus_ROB_index(ROB_kill_bus_ROB_index),

	    // core control interface
		.core_control_restore_flush(ROB_core_control_restore_flush),
		.core_control_revert_stall(ROB_core_control_revert_stall),
		.core_control_halt_assert(ROB_core_control_halt_assert)
	        // for when halt instr retires

	    // // optional outputs:

	    // // ROB state
		// .ROB_state_out(DUT_ROB_state_out),

	    // // if complete is invalid
		// .invalid_complete(DUT_invalid_complete),

	    // // current ROB capacity
		// .ROB_capacity(DUT_ROB_capacity)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // phys_reg_file: 

    // DUT error
	logic PRF_DUT_error;

    // overloaded read flag
	logic PRF_read_overload;

    // read reqs:

    // LQ read req
	logic PRF_LQ_read_req_valid;
	phys_reg_tag_t PRF_LQ_read_req_tag;
	logic PRF_LQ_read_req_serviced;

    // ALU 0 read req
	logic PRF_ALU_0_read_req_valid;
	phys_reg_tag_t PRF_ALU_0_read_req_0_tag;
	phys_reg_tag_t PRF_ALU_0_read_req_1_tag;
	logic PRF_ALU_0_read_req_serviced;

    // ALU 1 read req 0
	logic PRF_ALU_1_read_req_valid;
	phys_reg_tag_t PRF_ALU_1_read_req_0_tag;
	phys_reg_tag_t PRF_ALU_1_read_req_1_tag;
	logic PRF_ALU_1_read_req_serviced;

    // BRU read req 0
	logic PRF_BRU_read_req_valid;
	phys_reg_tag_t PRF_BRU_read_req_0_tag;
	phys_reg_tag_t PRF_BRU_read_req_1_tag;
	logic PRF_BRU_read_req_serviced;

    // SQ read req 0
	logic PRF_SQ_read_req_valid;
	phys_reg_tag_t PRF_SQ_read_req_0_tag;
	phys_reg_tag_t PRF_SQ_read_req_1_tag;
	logic PRF_SQ_read_req_serviced;

    // read bus:
	word_t PRF_read_bus_0_data;
	word_t PRF_read_bus_1_data;

    // write reqs:

    // LQ write req
	logic PRF_LQ_write_req_valid;
	phys_reg_tag_t PRF_LQ_write_req_tag;
	word_t PRF_LQ_write_req_data;
	logic PRF_LQ_write_req_serviced;

    // ALU 0 write req
	logic PRF_ALU_0_write_req_valid;
	phys_reg_tag_t PRF_ALU_0_write_req_tag;
	word_t PRF_ALU_0_write_req_data;
	logic PRF_ALU_0_write_req_serviced;

    // ALU 1 write req
	logic PRF_ALU_1_write_req_valid;
	phys_reg_tag_t PRF_ALU_1_write_req_tag;
	word_t PRF_ALU_1_write_req_data;
	logic PRF_ALU_1_write_req_serviced;

    // instantiation:
	phys_reg_file PRF (

		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(PRF_DUT_error),

	    // overloaded read flag
		.read_overload(PRF_read_overload),

	    // read reqs:

	    // LQ read req
		.LQ_read_req_valid(PRF_LQ_read_req_valid),
		.LQ_read_req_tag(PRF_LQ_read_req_tag),
		.LQ_read_req_serviced(PRF_LQ_read_req_serviced),

	    // ALU 0 read req
		.ALU_0_read_req_valid(PRF_ALU_0_read_req_valid),
		.ALU_0_read_req_0_tag(PRF_ALU_0_read_req_0_tag),
		.ALU_0_read_req_1_tag(PRF_ALU_0_read_req_1_tag),
		.ALU_0_read_req_serviced(PRF_ALU_0_read_req_serviced),

	    // ALU 1 read req 0
		.ALU_1_read_req_valid(PRF_ALU_1_read_req_valid),
		.ALU_1_read_req_0_tag(PRF_ALU_1_read_req_0_tag),
		.ALU_1_read_req_1_tag(PRF_ALU_1_read_req_1_tag),
		.ALU_1_read_req_serviced(PRF_ALU_1_read_req_serviced),

	    // BRU read req 0
		.BRU_read_req_valid(PRF_BRU_read_req_valid),
		.BRU_read_req_0_tag(PRF_BRU_read_req_0_tag),
		.BRU_read_req_1_tag(PRF_BRU_read_req_1_tag),
		.BRU_read_req_serviced(PRF_BRU_read_req_serviced),

	    // SQ read req 0
		.SQ_read_req_valid(PRF_SQ_read_req_valid),
		.SQ_read_req_0_tag(PRF_SQ_read_req_0_tag),
		.SQ_read_req_1_tag(PRF_SQ_read_req_1_tag),
		.SQ_read_req_serviced(PRF_SQ_read_req_serviced),

	    // read bus:
		.read_bus_0_data(PRF_read_bus_0_data),
		.read_bus_1_data(PRF_read_bus_1_data),

	    // write reqs:

	    // LQ write req
		.LQ_write_req_valid(PRF_LQ_write_req_valid),
		.LQ_write_req_tag(PRF_LQ_write_req_tag),
		.LQ_write_req_data(PRF_LQ_write_req_data),
		.LQ_write_req_serviced(PRF_LQ_write_req_serviced),

	    // ALU 0 write req
		.ALU_0_write_req_valid(PRF_ALU_0_write_req_valid),
		.ALU_0_write_req_tag(PRF_ALU_0_write_req_tag),
		.ALU_0_write_req_data(PRF_ALU_0_write_req_data),
		.ALU_0_write_req_serviced(PRF_ALU_0_write_req_serviced),

	    // ALU 1 write req
		.ALU_1_write_req_valid(PRF_ALU_1_write_req_valid),
		.ALU_1_write_req_tag(PRF_ALU_1_write_req_tag),
		.ALU_1_write_req_data(PRF_ALU_1_write_req_data),
		.ALU_1_write_req_serviced(PRF_ALU_1_write_req_serviced)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // alu_pipeline 0: 

    // DUT error
	logic AP0_DUT_error;

    // full
	logic AP0_ALU_RS_full;

    // dispatch unit interface
	logic AP0_dispatch_unit_task_valid;
	ALU_RS_input_struct_t AP0_dispatch_unit_task_struct;
        // typedef struct packed {
        //     // ALU needs
        //     ALU_op_t op;
        //     logic itype;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     phys_reg_tag_t dest_phys_reg_tag;
        //     imm16_t imm16;
        //     // ROB needs
        //     ROB_index_t ROB_index;
        // } ALU_RS_input_struct_t;

    // reg file read req interface
	logic AP0_reg_file_read_req_valid;
	phys_reg_tag_t AP0_reg_file_read_req_0_tag;
	phys_reg_tag_t AP0_reg_file_read_req_1_tag;
	logic AP0_reg_file_read_req_serviced;
	word_t AP0_reg_file_read_bus_0_data;
	word_t AP0_reg_file_read_bus_1_data;

    // kill bus interface
	logic AP0_kill_bus_valid;
	ROB_index_t AP0_kill_bus_ROB_index;

    // complete bus interface:

    // input side (take from any 3 buses):

    // complete bus 0 (ALU 0)
	logic AP0_complete_bus_0_tag_valid;
	phys_reg_tag_t AP0_complete_bus_0_tag;
	word_t AP0_complete_bus_0_data;

    // complete bus 1 (ALU 1)
	logic AP0_complete_bus_1_tag_valid;
	phys_reg_tag_t AP0_complete_bus_1_tag;
	word_t AP0_complete_bus_1_data;

    // complete bus 2 (LQ)
	logic AP0_complete_bus_2_tag_valid;
	phys_reg_tag_t AP0_complete_bus_2_tag;
	word_t AP0_complete_bus_2_data;

    // output side (output to this ALU Pipeline's associated bus)
	logic AP0_this_complete_bus_tag_valid;
	phys_reg_tag_t AP0_this_complete_bus_tag;
	ROB_index_t AP0_this_complete_bus_ROB_index;
	logic AP0_this_complete_bus_data_valid;
	word_t AP0_this_complete_bus_data;

    // instantiation
	alu_pipeline AP0 (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(AP0_DUT_error),

	    // full
		.ALU_RS_full(AP0_ALU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(AP0_dispatch_unit_task_valid),
		.dispatch_unit_task_struct(AP0_dispatch_unit_task_struct),
	        // typedef struct packed {
	        //     // ALU needs
	        //     ALU_op_t op;
	        //     logic itype;
	        //     source_reg_status_t source_0;
	        //     source_reg_status_t source_1;
	        //     phys_reg_tag_t dest_phys_reg_tag;
	        //     imm16_t imm16;
	        //     // ROB needs
	        //     ROB_index_t ROB_index;
	        // } ALU_RS_input_struct_t;

	    // reg file read req interface
		.reg_file_read_req_valid(AP0_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(AP0_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(AP0_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(AP0_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(AP0_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(AP0_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(AP0_kill_bus_valid),
		.kill_bus_ROB_index(AP0_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(AP0_complete_bus_0_tag_valid),
		.complete_bus_0_tag(AP0_complete_bus_0_tag),
		.complete_bus_0_data(AP0_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(AP0_complete_bus_1_tag_valid),
		.complete_bus_1_tag(AP0_complete_bus_1_tag),
		.complete_bus_1_data(AP0_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(AP0_complete_bus_2_tag_valid),
		.complete_bus_2_tag(AP0_complete_bus_2_tag),
		.complete_bus_2_data(AP0_complete_bus_2_data),

	    // output side (output to this ALU Pipeline's associated bus)
		.this_complete_bus_tag_valid(AP0_this_complete_bus_tag_valid),
		.this_complete_bus_tag(AP0_this_complete_bus_tag),
		.this_complete_bus_ROB_index(AP0_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(AP0_this_complete_bus_data_valid),
		.this_complete_bus_data(AP0_this_complete_bus_data)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // alu_pipeline 1: 

    // DUT error
	logic AP1_DUT_error;

    // full
	logic AP1_ALU_RS_full;

    // dispatch unit interface
	logic AP1_dispatch_unit_task_valid;
	ALU_RS_input_struct_t AP1_dispatch_unit_task_struct;
        // typedef struct packed {
        //     // ALU needs
        //     ALU_op_t op;
        //     logic itype;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     phys_reg_tag_t dest_phys_reg_tag;
        //     imm16_t imm16;
        //     // ROB needs
        //     ROB_index_t ROB_index;
        // } ALU_RS_input_struct_t;

    // reg file read req interface
	logic AP1_reg_file_read_req_valid;
	phys_reg_tag_t AP1_reg_file_read_req_0_tag;
	phys_reg_tag_t AP1_reg_file_read_req_1_tag;
	logic AP1_reg_file_read_req_serviced;
	word_t AP1_reg_file_read_bus_0_data;
	word_t AP1_reg_file_read_bus_1_data;

    // kill bus interface
	logic AP1_kill_bus_valid;
	ROB_index_t AP1_kill_bus_ROB_index;

    // complete bus interface:

    // input side (take from any 3 buses):

    // complete bus 0 (ALU 0)
	logic AP1_complete_bus_0_tag_valid;
	phys_reg_tag_t AP1_complete_bus_0_tag;
	word_t AP1_complete_bus_0_data;

    // complete bus 1 (ALU 1)
	logic AP1_complete_bus_1_tag_valid;
	phys_reg_tag_t AP1_complete_bus_1_tag;
	word_t AP1_complete_bus_1_data;

    // complete bus 2 (LQ)
	logic AP1_complete_bus_2_tag_valid;
	phys_reg_tag_t AP1_complete_bus_2_tag;
	word_t AP1_complete_bus_2_data;

    // output side (output to this ALU Pipeline's associated bus)
	logic AP1_this_complete_bus_tag_valid;
	phys_reg_tag_t AP1_this_complete_bus_tag;
	ROB_index_t AP1_this_complete_bus_ROB_index;
	logic AP1_this_complete_bus_data_valid;
	word_t AP1_this_complete_bus_data;

    // instantiation
	alu_pipeline AP1 (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(AP1_DUT_error),

	    // full
		.ALU_RS_full(AP1_ALU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(AP1_dispatch_unit_task_valid),
		.dispatch_unit_task_struct(AP1_dispatch_unit_task_struct),
	        // typedef struct packed {
	        //     // ALU needs
	        //     ALU_op_t op;
	        //     logic itype;
	        //     source_reg_status_t source_0;
	        //     source_reg_status_t source_1;
	        //     phys_reg_tag_t dest_phys_reg_tag;
	        //     imm16_t imm16;
	        //     // ROB needs
	        //     ROB_index_t ROB_index;
	        // } ALU_RS_input_struct_t;

	    // reg file read req interface
		.reg_file_read_req_valid(AP1_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(AP1_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(AP1_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(AP1_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(AP1_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(AP1_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(AP1_kill_bus_valid),
		.kill_bus_ROB_index(AP1_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(AP1_complete_bus_0_tag_valid),
		.complete_bus_0_tag(AP1_complete_bus_0_tag),
		.complete_bus_0_data(AP1_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(AP1_complete_bus_1_tag_valid),
		.complete_bus_1_tag(AP1_complete_bus_1_tag),
		.complete_bus_1_data(AP1_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(AP1_complete_bus_2_tag_valid),
		.complete_bus_2_tag(AP1_complete_bus_2_tag),
		.complete_bus_2_data(AP1_complete_bus_2_data),

	    // output side (output to this ALU Pipeline's associated bus)
		.this_complete_bus_tag_valid(AP1_this_complete_bus_tag_valid),
		.this_complete_bus_tag(AP1_this_complete_bus_tag),
		.this_complete_bus_ROB_index(AP1_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(AP1_this_complete_bus_data_valid),
		.this_complete_bus_data(AP1_this_complete_bus_data)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // bru_pipeline: 

    // DUT error
	logic BP_DUT_error;

    // full
	logic BP_BRU_RS_full;

    // dispatch unit interface
	logic BP_dispatch_unit_task_valid;
	BRU_RS_input_struct_t BP_dispatch_unit_task_struct;
        // typedef struct packed {
        //     // BRU needs
        //     BRU_op_t op;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     pc_t imm14;
        //     pc_t PC;    // will use to grab PC bits for BTB/DIRP index and do branch add ((PC + 4) + imm16)
        //     pc_t nPC;   // PC taken to check against
        //     // save/restore info
        //     checkpoint_column_t checkpoint_safe_column;
        //     // admin
        //     ROB_index_t ROB_index;
        // } BRU_RS_input_struct_t;

    // reg file read req interface
	logic BP_reg_file_read_req_valid;
	phys_reg_tag_t BP_reg_file_read_req_0_tag;
	phys_reg_tag_t BP_reg_file_read_req_1_tag;
	logic BP_reg_file_read_req_serviced;
	word_t BP_reg_file_read_bus_0_data;
	word_t BP_reg_file_read_bus_1_data;

    // kill bus interface
	logic BP_kill_bus_valid;
	ROB_index_t BP_kill_bus_ROB_index;

    // complete bus interface:

    // input side (take from any 3 buses):

    // complete bus 0 (ALU 0)
	logic BP_complete_bus_0_tag_valid;
	phys_reg_tag_t BP_complete_bus_0_tag;
	word_t BP_complete_bus_0_data;

    // complete bus 1 (ALU 1)
	logic BP_complete_bus_1_tag_valid;
	phys_reg_tag_t BP_complete_bus_1_tag;
	word_t BP_complete_bus_1_data;

    // complete bus 2 (LQ)
	logic BP_complete_bus_2_tag_valid;
	phys_reg_tag_t BP_complete_bus_2_tag;
	word_t BP_complete_bus_2_data;

    // complete output to ROB
	logic BP_this_complete_valid;

    // restart output to ROB
	logic BP_this_restart_valid;
	ROB_index_t BP_this_restart_ROB_index;
	pc_t BP_this_restart_PC;
	checkpoint_column_t BP_this_restart_safe_column;

    // BTB/DIRP updates to fetch_unit
	logic BP_this_BTB_DIRP_update;
	BTB_DIRP_index_t BP_this_BTB_DIRP_index;
	pc_t BP_this_BTB_target;
	logic BP_this_DIRP_taken;

    // instantiation
	bru_pipeline BP (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(BP_DUT_error),

	    // full
		.BRU_RS_full(BP_BRU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(BP_dispatch_unit_task_valid),
		.dispatch_unit_task_struct(BP_dispatch_unit_task_struct),
	        // typedef struct packed {
	        //     // BRU needs
	        //     BRU_op_t op;
	        //     source_reg_status_t source_0;
	        //     source_reg_status_t source_1;
	        //     pc_t imm14;
	        //     pc_t PC;    // will use to grab PC bits for BTB/DIRP index and do branch add ((PC + 4) + imm16)
	        //     pc_t nPC;   // PC taken to check against
	        //     // save/restore info
	        //     checkpoint_column_t checkpoint_safe_column;
	        //     // admin
	        //     ROB_index_t ROB_index;
	        // } BRU_RS_input_struct_t;

	    // reg file read req interface
		.reg_file_read_req_valid(BP_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(BP_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(BP_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(BP_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(BP_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(BP_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(BP_kill_bus_valid),
		.kill_bus_ROB_index(BP_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(BP_complete_bus_0_tag_valid),
		.complete_bus_0_tag(BP_complete_bus_0_tag),
		.complete_bus_0_data(BP_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(BP_complete_bus_1_tag_valid),
		.complete_bus_1_tag(BP_complete_bus_1_tag),
		.complete_bus_1_data(BP_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(BP_complete_bus_2_tag_valid),
		.complete_bus_2_tag(BP_complete_bus_2_tag),
		.complete_bus_2_data(BP_complete_bus_2_data),

	    // complete output to ROB
		.this_complete_valid(BP_this_complete_valid),

	    // restart output to ROB
		.this_restart_valid(BP_this_restart_valid),
		.this_restart_ROB_index(BP_this_restart_ROB_index),
		.this_restart_PC(BP_this_restart_PC),
		.this_restart_safe_column(BP_this_restart_safe_column),

	    // BTB/DIRP updates to fetch_unit
		.this_BTB_DIRP_update(BP_this_BTB_DIRP_update),
		.this_BTB_DIRP_index(BP_this_BTB_DIRP_index),
		.this_BTB_target(BP_this_BTB_target),
		.this_DIRP_taken(BP_this_DIRP_taken)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // lsq: 

    // DUT error
	logic LSQ_DUT_error;

    ////////////////////
    // dispatch unit: //
    ////////////////////

    // // LQ interface
    // input LQ_index_t dispatch_unit_LQ_tail_index,
    // input logic dispatch_unit_LQ_full,
    // output logic dispatch_unit_LQ_task_valid,
    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,

	// LQ_index_t LSQ_dispatch_unit_LQ_tail_index;
	logic LSQ_dispatch_unit_LQ_full;
	logic LSQ_dispatch_unit_LQ_task_valid;
	LQ_enqueue_struct_t LSQ_dispatch_unit_LQ_task_struct;
        // typedef struct packed {
        //     // LQ needs
        //     LQ_op_t op;
        //     source_reg_status_t source;
        //     phys_reg_tag_t dest_phys_reg_tag;
        //     daddr_t imm14;
        //     SQ_index_t SQ_index;   // for SC, doubles as SQ index for store part of SC to track
        //         // may want separate counter tag to link the store and load parts of SC
        //             // or ROB_index serves this role
        //     // admin
        //     ROB_index_t ROB_index;
        // } LQ_enqueue_struct_t;

    // // SQ interface
    // input SQ_index_t dispatch_unit_SQ_tail_index,
    // input logic dispatch_unit_SQ_full,
    // output logic dispatch_unit_SQ_task_valid,
    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,

	// SQ_index_t LSQ_dispatch_unit_SQ_tail_index;
	logic LSQ_dispatch_unit_SQ_full;
	logic LSQ_dispatch_unit_SQ_task_valid;
	SQ_enqueue_struct_t LSQ_dispatch_unit_SQ_task_struct;
        // typedef struct packed {
        //     // SQ needs
        //     SQ_op_t op;
        //     source_reg_status_t source_0;
        //     source_reg_status_t source_1;
        //     daddr_t imm14;
        //     LQ_index_t LQ_index;
        //         // may want separate counter tag to link the store and load parts of SC
        //             // or ROB_index serves this role
        //     // admin
        //     ROB_index_t ROB_index;
        // } SQ_enqueue_struct_t;

    //////////
    // ROB: //
    //////////

    // // kill bus interface
    //     // send kill command to execution units
    // output logic kill_bus_valid,
    // output ROB_index_t kill_bus_ROB_index,

	logic LSQ_kill_bus_valid;
	ROB_index_t LSQ_kill_bus_ROB_index;

    // // core control interface
    // output logic core_control_restore_flush,
    // output logic core_control_revert_stall,
    // output logic core_control_halt_assert,
    //     // for when halt instr retires

	logic LSQ_core_control_halt;

    // // LQ interface
    // // restart info
    // input logic ROB_LQ_restart_valid,
    // input ROB_index_t ROB_LQ_restart_ROB_index,
    // // retire
    // output logic ROB_LQ_retire_valid,
    // output ROB_index_t ROB_LQ_retire_ROB_index,
    // input logic ROB_LQ_retire_blocked,

	logic LSQ_ROB_LQ_restart_valid;
	logic LSQ_ROB_LQ_restart_after_instr;
	ROB_index_t LSQ_ROB_LQ_restart_ROB_index;

	logic LSQ_ROB_LQ_retire_valid;
	ROB_index_t LSQ_ROB_LQ_retire_ROB_index;
	logic LSQ_ROB_LQ_retire_blocked;

    // // SQ interface
    // // complete
    // input logic ROB_SQ_complete_valid,
    // input ROB_index_t ROB_SQ_complete_ROB_index,
    // // retire
    // output logic ROB_SQ_retire_valid,
    // output ROB_index_t ROB_SQ_retire_ROB_index,
    // input logic ROB_SQ_retire_blocked,

	logic LSQ_ROB_SQ_complete_valid;
	ROB_index_t LSQ_ROB_SQ_complete_ROB_index;

	logic LSQ_ROB_SQ_retire_valid;
	ROB_index_t LSQ_ROB_SQ_retire_ROB_index;
	logic LSQ_ROB_SQ_retire_blocked;

    ////////////////////
    // phys reg file: //
    ////////////////////

    // // LQ read req
    // input logic LQ_read_req_valid,
    // input phys_reg_tag_t LQ_read_req_tag,
    // output logic LQ_read_req_serviced,

	logic LSQ_LQ_reg_read_req_valid;
	phys_reg_tag_t LSQ_LQ_reg_read_req_tag;
	logic LSQ_LQ_reg_read_req_serviced;
	word_t LSQ_LQ_reg_read_bus_0_data;

    // // SQ read req
    // input logic SQ_read_req_valid,
    // input phys_reg_tag_t SQ_read_req_0_tag,
    // input phys_reg_tag_t SQ_read_req_1_tag,
    // output logic SQ_read_req_serviced,

	logic LSQ_SQ_reg_read_req_valid;
	phys_reg_tag_t LSQ_SQ_reg_read_req_0_tag;
	phys_reg_tag_t LSQ_SQ_reg_read_req_1_tag;
	logic LSQ_SQ_reg_read_req_serviced;
	word_t LSQ_SQ_reg_read_bus_0_data;
	word_t LSQ_SQ_reg_read_bus_1_data;

    ///////////////////
    // complete bus: //
    ///////////////////

    // // output side (output to this ALU Pipeline's associated bus)
    // output logic this_complete_bus_tag_valid,
    // output phys_reg_tag_t this_complete_bus_tag,
    // output ROB_index_t this_complete_bus_ROB_index,
    // output logic this_complete_bus_data_valid, // only needs to go to reg file
    // output word_t this_complete_bus_data

	logic LSQ_this_complete_bus_tag_valid;
	phys_reg_tag_t LSQ_this_complete_bus_tag;
	ROB_index_t LSQ_this_complete_bus_ROB_index;
	logic LSQ_this_complete_bus_data_valid;
	word_t LSQ_this_complete_bus_data;

    /////////////
    // dcache: //
    /////////////

    // read req interface:
    //      - valid
    //      - LQ index
    //      - addr
    //      - linked
    //      - conditional
    //      - blocked

	logic LSQ_dcache_read_req_valid;
	LQ_index_t LSQ_dcache_read_req_LQ_index;
	daddr_t LSQ_dcache_read_req_addr;
	logic LSQ_dcache_read_req_linked;
	logic LSQ_dcache_read_req_conditional;
	logic LSQ_dcache_read_req_blocked;

    // read resp interface:
    //      - valid
    //      - LQ index
    //      - read data

	logic LSQ_dcache_read_resp_valid;
	LQ_index_t LSQ_dcache_read_resp_LQ_index;
	word_t LSQ_dcache_read_resp_data;

    // write req interface:
    //      - valid
    //      - addr
    //      - write data
    //      - conditional
    //      - blocked

	logic LSQ_dcache_write_req_valid;
	daddr_t LSQ_dcache_write_req_addr;
	word_t LSQ_dcache_write_req_data;
	logic LSQ_dcache_write_req_conditional;
	logic LSQ_dcache_write_req_blocked;

    // read kill interface x2:
    //      - valid
    //      - LQ index
        // just means cancel response to datapath so don't mix up with later request at same LQ index
            // d$'s job to figure out how to cancel
                // e.g. MSHR can get response but don't propagate upward into datapath
            // may also get cancel soon enough that can prevent MSHR bus request
        // 0: datapath ROB index kill load, kill dcache read req
        // 1: SQ forward, kill unneeded dcache read req

	logic LSQ_dcache_read_kill_0_valid;
	LQ_index_t LSQ_dcache_read_kill_0_LQ_index;
	logic LSQ_dcache_read_kill_1_valid;
	LQ_index_t LSQ_dcache_read_kill_1_LQ_index;

    // invalidation interface:
    //      - valid
    //      - inv address

	logic LSQ_dcache_inv_valid;
	block_addr_t LSQ_dcache_inv_block_addr;
	logic LSQ_dcache_evict_valid;
	block_addr_t LSQ_dcache_evict_block_addr;

    // halt interface:
    //      - halt

	logic LSQ_dcache_halt;

    ///////////////////
    // shared buses: //
    ///////////////////

    // complete bus 0 (ALU 0)
	logic LSQ_complete_bus_0_tag_valid;
	phys_reg_tag_t LSQ_complete_bus_0_tag;
	word_t LSQ_complete_bus_0_data;

    // complete bus 1 (ALU 1)
	logic LSQ_complete_bus_1_tag_valid;
	phys_reg_tag_t LSQ_complete_bus_1_tag;
	word_t LSQ_complete_bus_1_data;

    // complete bus 2 (LQ)
	logic LSQ_complete_bus_2_tag_valid;
	phys_reg_tag_t LSQ_complete_bus_2_tag;
	word_t LSQ_complete_bus_2_data;

    // instantiation:
	lsq LSQ (
		// seq
		.CLK(CLK),
		.nRST(nRST),

	    // DUT error
		.DUT_error(LSQ_DUT_error),

	    ////////////////////
	    // dispatch unit: //
	    ////////////////////

	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,

		// .dispatch_unit_LQ_tail_index(LSQ_dispatch_unit_LQ_tail_index),
		.dispatch_unit_LQ_full(LSQ_dispatch_unit_LQ_full),
		.dispatch_unit_LQ_task_valid(LSQ_dispatch_unit_LQ_task_valid),
		.dispatch_unit_LQ_task_struct(LSQ_dispatch_unit_LQ_task_struct),
	        // typedef struct packed {
	        //     // LQ needs
	        //     LQ_op_t op;
	        //     source_reg_status_t source;
	        //     phys_reg_tag_t dest_phys_reg_tag;
	        //     daddr_t imm14;
	        //     SQ_index_t SQ_index;   // for SC, doubles as SQ index for store part of SC to track
	        //         // may want separate counter tag to link the store and load parts of SC
	        //             // or ROB_index serves this role
	        //     // admin
	        //     ROB_index_t ROB_index;
	        // } LQ_enqueue_struct_t;

	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,

		// .dispatch_unit_SQ_tail_index(LSQ_dispatch_unit_SQ_tail_index),
		.dispatch_unit_SQ_full(LSQ_dispatch_unit_SQ_full),
		.dispatch_unit_SQ_task_valid(LSQ_dispatch_unit_SQ_task_valid),
		.dispatch_unit_SQ_task_struct(LSQ_dispatch_unit_SQ_task_struct),
	        // typedef struct packed {
	        //     // SQ needs
	        //     SQ_op_t op;
	        //     source_reg_status_t source_0;
	        //     source_reg_status_t source_1;
	        //     daddr_t imm14;
	        //     LQ_index_t LQ_index;
	        //         // may want separate counter tag to link the store and load parts of SC
	        //             // or ROB_index serves this role
	        //     // admin
	        //     ROB_index_t ROB_index;
	        // } SQ_enqueue_struct_t;

	    //////////
	    // ROB: //
	    //////////

	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,

		.kill_bus_valid(LSQ_kill_bus_valid),
		.kill_bus_ROB_index(LSQ_kill_bus_ROB_index),

	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires

		.core_control_halt(LSQ_core_control_halt),

	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,

		.ROB_LQ_restart_valid(LSQ_ROB_LQ_restart_valid),
		.ROB_LQ_restart_after_instr(LSQ_ROB_LQ_restart_after_instr),
		.ROB_LQ_restart_ROB_index(LSQ_ROB_LQ_restart_ROB_index),

		.ROB_LQ_retire_valid(LSQ_ROB_LQ_retire_valid),
		.ROB_LQ_retire_ROB_index(LSQ_ROB_LQ_retire_ROB_index),
		.ROB_LQ_retire_blocked(LSQ_ROB_LQ_retire_blocked),

	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,

		.ROB_SQ_complete_valid(LSQ_ROB_SQ_complete_valid),
		.ROB_SQ_complete_ROB_index(LSQ_ROB_SQ_complete_ROB_index),

		.ROB_SQ_retire_valid(LSQ_ROB_SQ_retire_valid),
		.ROB_SQ_retire_ROB_index(LSQ_ROB_SQ_retire_ROB_index),
		.ROB_SQ_retire_blocked(LSQ_ROB_SQ_retire_blocked),

	    ////////////////////
	    // phys reg file: //
	    ////////////////////

	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,

		.LQ_reg_read_req_valid(LSQ_LQ_reg_read_req_valid),
		.LQ_reg_read_req_tag(LSQ_LQ_reg_read_req_tag),
		.LQ_reg_read_req_serviced(LSQ_LQ_reg_read_req_serviced),
		.LQ_reg_read_bus_0_data(LSQ_LQ_reg_read_bus_0_data),

	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,

		.SQ_reg_read_req_valid(LSQ_SQ_reg_read_req_valid),
		.SQ_reg_read_req_0_tag(LSQ_SQ_reg_read_req_0_tag),
		.SQ_reg_read_req_1_tag(LSQ_SQ_reg_read_req_1_tag),
		.SQ_reg_read_req_serviced(LSQ_SQ_reg_read_req_serviced),
		.SQ_reg_read_bus_0_data(LSQ_SQ_reg_read_bus_0_data),
		.SQ_reg_read_bus_1_data(LSQ_SQ_reg_read_bus_1_data),

	    ///////////////////
	    // complete bus: //
	    ///////////////////

	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data

		.this_complete_bus_tag_valid(LSQ_this_complete_bus_tag_valid),
		.this_complete_bus_tag(LSQ_this_complete_bus_tag),
		.this_complete_bus_ROB_index(LSQ_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(LSQ_this_complete_bus_data_valid),
		.this_complete_bus_data(LSQ_this_complete_bus_data),

	    /////////////
	    // dcache: //
	    /////////////

	    // read req interface:
	    //      - valid
	    //      - LQ index
	    //      - addr
	    //      - linked
	    //      - conditional
	    //      - blocked

		.dcache_read_req_valid(LSQ_dcache_read_req_valid),
		.dcache_read_req_LQ_index(LSQ_dcache_read_req_LQ_index),
		.dcache_read_req_addr(LSQ_dcache_read_req_addr),
		.dcache_read_req_linked(LSQ_dcache_read_req_linked),
		.dcache_read_req_conditional(LSQ_dcache_read_req_conditional),
		.dcache_read_req_blocked(LSQ_dcache_read_req_blocked),

	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data

		.dcache_read_resp_valid(LSQ_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(LSQ_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(LSQ_dcache_read_resp_data),

	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked

		.dcache_write_req_valid(LSQ_dcache_write_req_valid),
		.dcache_write_req_addr(LSQ_dcache_write_req_addr),
		.dcache_write_req_data(LSQ_dcache_write_req_data),
		.dcache_write_req_conditional(LSQ_dcache_write_req_conditional),
		.dcache_write_req_blocked(LSQ_dcache_write_req_blocked),

	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	        // just means cancel response to datapath so don't mix up with later request at same LQ index
	            // d$'s job to figure out how to cancel
	                // e.g. MSHR can get response but don't propagate upward into datapath
	            // may also get cancel soon enough that can prevent MSHR bus request
	        // 0: datapath ROB index kill load, kill dcache read req
	        // 1: SQ forward, kill unneeded dcache read req

		.dcache_read_kill_0_valid(LSQ_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(LSQ_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(LSQ_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(LSQ_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
	    //      - valid
	    //      - inv address

		.dcache_inv_valid(LSQ_dcache_inv_valid),
		.dcache_inv_block_addr(LSQ_dcache_inv_block_addr),
		.dcache_evict_valid(LSQ_dcache_evict_valid),
		.dcache_evict_block_addr(LSQ_dcache_evict_block_addr),

	    // halt interface:
	    //      - halt

		.dcache_halt(LSQ_dcache_halt),

	    ///////////////////
	    // shared buses: //
	    ///////////////////

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(LSQ_complete_bus_0_tag_valid),
		.complete_bus_0_tag(LSQ_complete_bus_0_tag),
		.complete_bus_0_data(LSQ_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(LSQ_complete_bus_1_tag_valid),
		.complete_bus_1_tag(LSQ_complete_bus_1_tag),
		.complete_bus_1_data(LSQ_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(LSQ_complete_bus_2_tag_valid),
		.complete_bus_2_tag(LSQ_complete_bus_2_tag),
		.complete_bus_2_data(LSQ_complete_bus_2_data)
	);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // sub-module connections:
        // go module-by-module making all the relevant connections for inputs until all covered
    
    ////////////////////////
    // fetch_unit inputs: //
    ////////////////////////

    always_comb begin

		// from pipeline interface:
        FU_from_pipeline_BTB_DIRP_update = BP_this_BTB_DIRP_update;
        FU_from_pipeline_BTB_DIRP_index = BP_this_BTB_DIRP_index;
        FU_from_pipeline_BTB_target = BP_this_BTB_target;
        FU_from_pipeline_DIRP_taken = BP_this_DIRP_taken;

		// from ROB interface:
        FU_from_pipeline_take_resolved = ROB_fetch_unit_take_resolved;
        FU_from_pipeline_resolved_PC = ROB_fetch_unit_resolved_PC;

        FU_core_control_stall_fetch_unit = | {
			ROB_core_control_revert_stall, 
			DU_core_control_dispatch_failed,
			ROB_core_control_restore_flush
		};
            // NOT SURE ON THIS ONE, NOT DOCUMENTED

        FU_core_control_halt = ROB_core_control_halt_assert;
    end

    ///////////////////////////
    // dispatch_unit inputs: //
    ///////////////////////////

    always_comb begin

		// core control interface
        DU_core_control_stall_dispatch_unit = ROB_core_control_revert_stall;
        DU_core_control_flush_dispatch_unit = ROB_core_control_restore_flush;
        DU_core_control_halt = ROB_core_control_halt_assert;

		// fetch_unit interface
        DU_fetch_unit_instr = FU_to_pipeline_instr;
        DU_fetch_unit_ivalid = FU_to_pipeline_ivalid;
        DU_fetch_unit_PC = FU_to_pipeline_PC;
        DU_fetch_unit_nPC = FU_to_pipeline_nPC;

		// restore interface
        DU_restore_checkpoint_valid = ROB_restore_checkpoint_valid;
        DU_restore_checkpoint_speculate_failed = ROB_restore_checkpoint_speculate_failed;
        DU_restore_checkpoint_ROB_index = ROB_restore_checkpoint_ROB_index;
        DU_restore_checkpoint_safe_column = ROB_restore_checkpoint_safe_column;

		// revert bus interface
        DU_kill_bus_valid = ROB_revert_valid;
        DU_kill_bus_ROB_index = ROB_revert_ROB_index;
        DU_kill_bus_arch_reg_tag = ROB_revert_arch_reg_tag;
		DU_kill_bus_speculated_phys_reg_tag = ROB_revert_speculated_phys_reg_tag;
		DU_kill_bus_safe_phys_reg_tag = ROB_revert_safe_phys_reg_tag;

		// complete bus interface
		DU_complete_bus_0_valid = AP0_this_complete_bus_tag_valid;
		DU_complete_bus_0_dest_phys_reg_tag = AP0_this_complete_bus_tag;
		DU_complete_bus_1_valid = AP1_this_complete_bus_tag_valid;
		DU_complete_bus_1_dest_phys_reg_tag = AP1_this_complete_bus_tag;
		DU_complete_bus_2_valid = LSQ_this_complete_bus_tag_valid;
		DU_complete_bus_2_dest_phys_reg_tag = LSQ_this_complete_bus_tag;

		// ROB interface
		DU_ROB_full = ROB_full;
		DU_ROB_tail_index = ROB_dispatch_unit_ROB_tail_index;
		DU_ROB_retire_valid = ROB_dispatch_unit_retire_valid;
		DU_ROB_retire_phys_reg_tag = ROB_dispatch_unit_retire_phys_reg_tag;

		// 2x ALU RS interface
		DU_ALU_RS_full[0] = AP0_ALU_RS_full;
		DU_ALU_RS_full[1] = AP1_ALU_RS_full;

		// LQ interface
		// DU_LQ_tail_index = LSQ_dispatch_unit_LQ_tail_index;
		DU_LQ_full = LSQ_dispatch_unit_LQ_full;

		// SQ interface
		// DU_SQ_tail_index = LSQ_dispatch_unit_SQ_tail_index;
		DU_SQ_full = LSQ_dispatch_unit_SQ_full;

		// BRU RS interface
		DU_BRU_RS_full = BP_BRU_RS_full; 
    end

	/////////////////
	// rob inputs: //
	/////////////////

	always_comb begin

		// dispatch unit interface
		ROB_dispatch_unit_enqueue_valid = DU_ROB_enqueue_valid;
		ROB_dispatch_unit_enqueue_struct = DU_ROB_struct_out;

		// complete bus interfaces
		ROB_complete_bus_0_valid = AP0_this_complete_bus_tag_valid;
		ROB_complete_bus_0_dest_phys_reg_tag = AP0_this_complete_bus_tag;
		ROB_complete_bus_0_ROB_index = AP0_this_complete_bus_ROB_index;
		ROB_complete_bus_1_valid = AP1_this_complete_bus_tag_valid;
		ROB_complete_bus_1_dest_phys_reg_tag = AP1_this_complete_bus_tag;
		ROB_complete_bus_1_ROB_index = AP1_this_complete_bus_ROB_index;
		ROB_complete_bus_2_valid = LSQ_this_complete_bus_tag_valid;
		ROB_complete_bus_2_dest_phys_reg_tag = LSQ_this_complete_bus_tag;
		ROB_complete_bus_2_ROB_index = LSQ_this_complete_bus_ROB_index;

		// BRU interface
		ROB_BRU_complete_valid = BP_this_complete_valid;
		ROB_BRU_restart_valid = BP_this_restart_valid;
		ROB_BRU_restart_ROB_index = BP_this_restart_ROB_index;
		ROB_BRU_restart_PC = BP_this_restart_PC;
		ROB_BRU_restart_safe_column = BP_this_restart_safe_column;
		
		// LQ interface
		ROB_LQ_restart_valid = LSQ_ROB_LQ_restart_valid;
		ROB_LQ_restart_after_instr = LSQ_ROB_LQ_restart_after_instr;
		ROB_LQ_restart_ROB_index = LSQ_ROB_LQ_restart_ROB_index;
		ROB_LQ_retire_blocked = LSQ_ROB_LQ_retire_blocked;

		// SQ interface
		ROB_SQ_complete_valid = LSQ_ROB_SQ_complete_valid;
		ROB_SQ_complete_ROB_index = LSQ_ROB_SQ_complete_ROB_index;
		ROB_SQ_retire_blocked = LSQ_ROB_SQ_retire_blocked;

		// restore interface
		ROB_restore_checkpoint_success = DU_restore_checkpoint_success;	
	end

	///////////////////////////
	// phys_reg_file inputs: //
	///////////////////////////
		// need to register the tag from the complete write buses
		// all other parts of data exist already (data valid, data)
		// the writers don't use the serviced signal 
			// they are guaranteed to complete
			// have all 3 write ports

	always_ff @ (posedge CLK, negedge nRST) begin
		if (~nRST) begin
			PRF_LQ_write_req_tag <= phys_reg_tag_t'(0);
			PRF_ALU_0_write_req_tag <= phys_reg_tag_t'(0);
			PRF_ALU_1_write_req_tag <= phys_reg_tag_t'(0);
		end
		else begin
			PRF_LQ_write_req_tag <= LSQ_this_complete_bus_tag;
			PRF_ALU_0_write_req_tag <= AP0_this_complete_bus_tag;
			PRF_ALU_1_write_req_tag <= AP1_this_complete_bus_tag;
		end	
	end

	always_comb begin

		// LQ read req
		PRF_LQ_read_req_valid = LSQ_LQ_reg_read_req_valid;
		PRF_LQ_read_req_tag = LSQ_LQ_reg_read_req_tag;

		// ALU 0 read req
		PRF_ALU_0_read_req_valid = AP0_reg_file_read_req_valid;
		PRF_ALU_0_read_req_0_tag = AP0_reg_file_read_req_0_tag;
		PRF_ALU_0_read_req_1_tag = AP0_reg_file_read_req_1_tag;

		// ALU 1 read req
		PRF_ALU_1_read_req_valid = AP1_reg_file_read_req_valid;
		PRF_ALU_1_read_req_0_tag = AP1_reg_file_read_req_0_tag;
		PRF_ALU_1_read_req_1_tag = AP1_reg_file_read_req_1_tag;

		// BRU read req
		PRF_BRU_read_req_valid = BP_reg_file_read_req_valid;
		PRF_BRU_read_req_0_tag = BP_reg_file_read_req_0_tag;
		PRF_BRU_read_req_1_tag = BP_reg_file_read_req_1_tag;

		// SQ read req
		PRF_SQ_read_req_valid = LSQ_SQ_reg_read_req_valid;
		PRF_SQ_read_req_0_tag = LSQ_SQ_reg_read_req_0_tag;
		PRF_SQ_read_req_1_tag = LSQ_SQ_reg_read_req_1_tag;

		// LQ write req
		PRF_LQ_write_req_valid = LSQ_this_complete_bus_data_valid;
		// PRF_LQ_write_req_tag
			// handled by reg ^
		PRF_LQ_write_req_data = LSQ_this_complete_bus_data;

		// ALU 0 write req
		PRF_ALU_0_write_req_valid = AP0_this_complete_bus_data_valid;
		// PRF_ALU_0_write_req_tag
			// handled by reg ^
		PRF_ALU_0_write_req_data = AP0_this_complete_bus_data;

		// ALU 1 write req
		PRF_ALU_1_write_req_valid = AP1_this_complete_bus_data_valid;
		// PRF_ALU_1_write_req_tag
			// handled by reg ^
		PRF_ALU_1_write_req_data = AP1_this_complete_bus_data;
	end

	////////////////////////////
	// alu_pipeline 0 inputs: //
	////////////////////////////

	always_comb begin

		// dispatch unit interface
		AP0_dispatch_unit_task_valid = DU_ALU_RS_task_valid[0];
		AP0_dispatch_unit_task_struct = DU_ALU_RS_task_struct[0];

		// reg file read req interface
		AP0_reg_file_read_req_serviced = PRF_ALU_0_read_req_serviced;
		AP0_reg_file_read_bus_0_data = PRF_read_bus_0_data;
		AP0_reg_file_read_bus_1_data = PRF_read_bus_1_data;

		// kill bus interface
		AP0_kill_bus_valid = ROB_kill_bus_valid;
		AP0_kill_bus_ROB_index = ROB_kill_bus_ROB_index;

		// complete bus 0 (ALU 0)
		AP0_complete_bus_0_tag_valid = AP0_this_complete_bus_tag_valid;
		AP0_complete_bus_0_tag = AP0_this_complete_bus_tag;
		AP0_complete_bus_0_data = AP0_this_complete_bus_data;

		// complete bus 1 (ALU 1)
		AP0_complete_bus_1_tag_valid = AP1_this_complete_bus_tag_valid;
		AP0_complete_bus_1_tag = AP1_this_complete_bus_tag;
		AP0_complete_bus_1_data = AP1_this_complete_bus_data;

		// complete bus 2 (LQ)
		AP0_complete_bus_2_tag_valid = LSQ_this_complete_bus_tag_valid;
		AP0_complete_bus_2_tag = LSQ_this_complete_bus_tag;
		AP0_complete_bus_2_data = LSQ_this_complete_bus_data;
	end

	////////////////////////////
	// alu_pipeline 1 inputs: //
	////////////////////////////

	always_comb begin

		// dispatch unit interface
		AP1_dispatch_unit_task_valid = DU_ALU_RS_task_valid[1];
		AP1_dispatch_unit_task_struct = DU_ALU_RS_task_struct[1];

		// reg file read req interface
		AP1_reg_file_read_req_serviced = PRF_ALU_1_read_req_serviced;
		AP1_reg_file_read_bus_0_data = PRF_read_bus_0_data;
		AP1_reg_file_read_bus_1_data = PRF_read_bus_1_data;

		// kill bus interface
		AP1_kill_bus_valid = ROB_kill_bus_valid;
		AP1_kill_bus_ROB_index = ROB_kill_bus_ROB_index;

		// complete bus 0 (ALU 0)
		AP1_complete_bus_0_tag_valid = AP0_this_complete_bus_tag_valid;
		AP1_complete_bus_0_tag = AP0_this_complete_bus_tag;
		AP1_complete_bus_0_data = AP0_this_complete_bus_data;

		// complete bus 1 (ALU 1)
		AP1_complete_bus_1_tag_valid = AP1_this_complete_bus_tag_valid;
		AP1_complete_bus_1_tag = AP1_this_complete_bus_tag;
		AP1_complete_bus_1_data = AP1_this_complete_bus_data;

		// complete bus 2 (LQ)
		AP1_complete_bus_2_tag_valid = LSQ_this_complete_bus_tag_valid;
		AP1_complete_bus_2_tag = LSQ_this_complete_bus_tag;
		AP1_complete_bus_2_data = LSQ_this_complete_bus_data;
	end

	//////////////////////////
	// bru_pipeline inputs: //
	//////////////////////////

	always_comb begin

		// dispatch_unit interface
		BP_dispatch_unit_task_valid = DU_BRU_RS_task_valid;
		BP_dispatch_unit_task_struct = DU_BRU_RS_task_struct;

		// reg file read req interface
		BP_reg_file_read_req_serviced = PRF_BRU_read_req_serviced;
		BP_reg_file_read_bus_0_data = PRF_read_bus_0_data;
		BP_reg_file_read_bus_1_data = PRF_read_bus_1_data;

		// kill bus interface
		BP_kill_bus_valid = ROB_kill_bus_valid;
		BP_kill_bus_ROB_index = ROB_kill_bus_ROB_index;

		// complete bus 0 (ALU 0)
		BP_complete_bus_0_tag_valid = AP0_this_complete_bus_tag_valid;
		BP_complete_bus_0_tag = AP0_this_complete_bus_tag;
		BP_complete_bus_0_data = AP0_this_complete_bus_data;

		// complete bus 1 (ALU 1)
		BP_complete_bus_1_tag_valid = AP1_this_complete_bus_tag_valid;
		BP_complete_bus_1_tag = AP1_this_complete_bus_tag;
		BP_complete_bus_1_data = AP1_this_complete_bus_data;

		// complete bus 2 (LQ)
		BP_complete_bus_2_tag_valid = LSQ_this_complete_bus_tag_valid;
		BP_complete_bus_2_tag = LSQ_this_complete_bus_tag;
		BP_complete_bus_2_data = LSQ_this_complete_bus_data;
	end

	/////////////////
	// lsq inputs: //
	/////////////////

	always_comb begin

		// dispatch_unit interface:
		LSQ_dispatch_unit_LQ_task_valid = DU_LQ_task_valid;
		LSQ_dispatch_unit_LQ_task_struct = DU_LQ_task_struct;

		LSQ_dispatch_unit_SQ_task_valid = DU_SQ_task_valid;
		LSQ_dispatch_unit_SQ_task_struct = DU_SQ_task_struct;

		// rob interface:
		LSQ_kill_bus_valid = ROB_kill_bus_valid;
		LSQ_kill_bus_ROB_index = ROB_kill_bus_ROB_index;

		LSQ_core_control_halt = ROB_core_control_halt_assert;

		LSQ_ROB_LQ_retire_valid = ROB_LQ_retire_valid;
		LSQ_ROB_LQ_retire_ROB_index = ROB_LQ_retire_ROB_index;

		LSQ_ROB_SQ_retire_valid = ROB_SQ_retire_valid;
		LSQ_ROB_SQ_retire_ROB_index = ROB_SQ_retire_ROB_index;

		// phys_reg_file interface:
		LSQ_LQ_reg_read_req_serviced = PRF_LQ_read_req_serviced;
		LSQ_LQ_reg_read_bus_0_data = PRF_read_bus_0_data;

		LSQ_SQ_reg_read_req_serviced = PRF_SQ_read_req_serviced;
		LSQ_SQ_reg_read_bus_0_data = PRF_read_bus_0_data;
		LSQ_SQ_reg_read_bus_1_data = PRF_read_bus_1_data;

		// complete bus 0 (ALU 0)
		LSQ_complete_bus_0_tag_valid = AP0_this_complete_bus_tag_valid;
		LSQ_complete_bus_0_tag = AP0_this_complete_bus_tag;
		LSQ_complete_bus_0_data = AP0_this_complete_bus_data;

		// complete bus 1 (ALU 1)
		LSQ_complete_bus_1_tag_valid = AP1_this_complete_bus_tag_valid;
		LSQ_complete_bus_1_tag = AP1_this_complete_bus_tag;
		LSQ_complete_bus_1_data = AP1_this_complete_bus_data;

		// complete bus 2 (LQ)
		LSQ_complete_bus_2_tag_valid = LSQ_this_complete_bus_tag_valid;
		LSQ_complete_bus_2_tag = LSQ_this_complete_bus_tag;
		LSQ_complete_bus_2_data = LSQ_this_complete_bus_data;
	end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // i$ interface:

	always_comb begin
		FU_icache_hit = icache_hit;
		FU_icache_load = icache_load;
		icache_REN = FU_icache_REN;
		icache_addr = FU_icache_addr;
		icache_halt = FU_icache_halt;
	end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // d$ interface:

	always_comb begin

		// read req interface:
		dcache_read_req_valid = LSQ_dcache_read_req_valid;
		dcache_read_req_LQ_index = LSQ_dcache_read_req_LQ_index;
		dcache_read_req_addr = LSQ_dcache_read_req_addr;
		dcache_read_req_linked = LSQ_dcache_read_req_linked;
		dcache_read_req_conditional = LSQ_dcache_read_req_conditional;
		LSQ_dcache_read_req_blocked = dcache_read_req_blocked;

		// read resp interface:
		LSQ_dcache_read_resp_valid = dcache_read_resp_valid;
		LSQ_dcache_read_resp_LQ_index = dcache_read_resp_LQ_index;
		LSQ_dcache_read_resp_data = dcache_read_resp_data;

		// write req interface:
		dcache_write_req_valid = LSQ_dcache_write_req_valid;
		dcache_write_req_addr = LSQ_dcache_write_req_addr;
		dcache_write_req_data = LSQ_dcache_write_req_data;
		dcache_write_req_conditional = LSQ_dcache_write_req_conditional;
		LSQ_dcache_write_req_blocked = dcache_write_req_blocked;

		// read kill interface x2:
		dcache_read_kill_0_valid = LSQ_dcache_read_kill_0_valid;
		dcache_read_kill_0_LQ_index = LSQ_dcache_read_kill_0_LQ_index;
		dcache_read_kill_1_valid = LSQ_dcache_read_kill_1_valid;
		dcache_read_kill_1_LQ_index = LSQ_dcache_read_kill_1_LQ_index;

		// invalidation interface:
		LSQ_dcache_inv_valid = dcache_inv_valid;
		LSQ_dcache_inv_block_addr = dcache_inv_block_addr;
		LSQ_dcache_evict_valid = dcache_evict_valid;
		LSQ_dcache_evict_block_addr = dcache_evict_block_addr;

		// halt interface:
		dcache_halt = LSQ_dcache_halt;
	end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT errors:

    // accumulate sub-module DUT_error's
	assign DUT_error = | {
		FU_DUT_error,
		DU_DUT_error,
		ROB_DUT_error,
		PRF_DUT_error,
		AP0_DUT_error,
		AP1_DUT_error,
		BP_DUT_error,
		LSQ_DUT_error
	};

endmodule