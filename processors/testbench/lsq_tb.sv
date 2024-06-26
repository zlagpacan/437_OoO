/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: lsq_tb.sv
    Description: 
        Testbench for lsq module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module lsq_tb ();

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

    ////////////////////
    // dispatch unit: //
    ////////////////////

    // // LQ interface
    // input LQ_index_t dispatch_unit_LQ_tail_index,
    // input logic dispatch_unit_LQ_full,
    // output logic dispatch_unit_LQ_task_valid,
    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,

	// LQ_index_t DUT_dispatch_unit_LQ_tail_index, expected_dispatch_unit_LQ_tail_index;
	logic DUT_dispatch_unit_LQ_full, expected_dispatch_unit_LQ_full;
	logic tb_dispatch_unit_LQ_task_valid;
	LQ_enqueue_struct_t tb_dispatch_unit_LQ_task_struct;
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

	// SQ_index_t DUT_dispatch_unit_SQ_tail_index, expected_dispatch_unit_SQ_tail_index;
	logic DUT_dispatch_unit_SQ_full, expected_dispatch_unit_SQ_full;
	logic tb_dispatch_unit_SQ_task_valid;
	SQ_enqueue_struct_t tb_dispatch_unit_SQ_task_struct;
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

	logic tb_kill_bus_valid;
	ROB_index_t tb_kill_bus_ROB_index;

    // // core control interface
    // output logic core_control_restore_flush,
    // output logic core_control_revert_stall,
    // output logic core_control_halt_assert,
    //     // for when halt instr retires

	logic tb_core_control_halt;

    // // LQ interface
    // // restart info
    // input logic ROB_LQ_restart_valid,
    // input ROB_index_t ROB_LQ_restart_ROB_index,
    // // retire
    // output logic ROB_LQ_retire_valid,
    // output ROB_index_t ROB_LQ_retire_ROB_index,
    // input logic ROB_LQ_retire_blocked,

	logic DUT_ROB_LQ_restart_valid, expected_ROB_LQ_restart_valid;
	logic DUT_ROB_LQ_restart_after_instr, expected_ROB_LQ_restart_after_instr;
	ROB_index_t DUT_ROB_LQ_restart_ROB_index, expected_ROB_LQ_restart_ROB_index;

	logic tb_ROB_LQ_retire_valid;
	ROB_index_t tb_ROB_LQ_retire_ROB_index;
	logic DUT_ROB_LQ_retire_blocked, expected_ROB_LQ_retire_blocked;

    // // SQ interface
    // // complete
    // input logic ROB_SQ_complete_valid,
    // input ROB_index_t ROB_SQ_complete_ROB_index,
    // // retire
    // output logic ROB_SQ_retire_valid,
    // output ROB_index_t ROB_SQ_retire_ROB_index,
    // input logic ROB_SQ_retire_blocked,

	logic DUT_ROB_SQ_complete_valid, expected_ROB_SQ_complete_valid;
	ROB_index_t DUT_ROB_SQ_complete_ROB_index, expected_ROB_SQ_complete_ROB_index;

	logic tb_ROB_SQ_retire_valid;
	ROB_index_t tb_ROB_SQ_retire_ROB_index;
	logic DUT_ROB_SQ_retire_blocked, expected_ROB_SQ_retire_blocked;

    ////////////////////
    // phys reg file: //
    ////////////////////

    // // LQ read req
    // input logic LQ_read_req_valid,
    // input phys_reg_tag_t LQ_read_req_tag,
    // output logic LQ_read_req_serviced,

	logic DUT_LQ_reg_read_req_valid, expected_LQ_reg_read_req_valid;
	phys_reg_tag_t DUT_LQ_reg_read_req_tag, expected_LQ_reg_read_req_tag;
	logic tb_LQ_reg_read_req_serviced;
	word_t tb_LQ_reg_read_bus_0_data;

    // // SQ read req
    // input logic SQ_read_req_valid,
    // input phys_reg_tag_t SQ_read_req_0_tag,
    // input phys_reg_tag_t SQ_read_req_1_tag,
    // output logic SQ_read_req_serviced,

	logic DUT_SQ_reg_read_req_valid, expected_SQ_reg_read_req_valid;
	phys_reg_tag_t DUT_SQ_reg_read_req_0_tag, expected_SQ_reg_read_req_0_tag;
	phys_reg_tag_t DUT_SQ_reg_read_req_1_tag, expected_SQ_reg_read_req_1_tag;
	logic tb_SQ_reg_read_req_serviced;
	word_t tb_SQ_reg_read_bus_0_data;
	word_t tb_SQ_reg_read_bus_1_data;

    ///////////////////
    // complete bus: //
    ///////////////////

    // // output side (output to this ALU Pipeline's associated bus)
    // output logic this_complete_bus_tag_valid,
    // output phys_reg_tag_t this_complete_bus_tag,
    // output ROB_index_t this_complete_bus_ROB_index,
    // output logic this_complete_bus_data_valid, // only needs to go to reg file
    // output word_t this_complete_bus_data

	logic DUT_this_complete_bus_tag_valid, expected_this_complete_bus_tag_valid;
	phys_reg_tag_t DUT_this_complete_bus_tag, expected_this_complete_bus_tag;
	ROB_index_t DUT_this_complete_bus_ROB_index, expected_this_complete_bus_ROB_index;
	logic DUT_this_complete_bus_data_valid, expected_this_complete_bus_data_valid;
	word_t DUT_this_complete_bus_data, expected_this_complete_bus_data;

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

	logic DUT_dcache_read_req_valid, expected_dcache_read_req_valid;
	LQ_index_t DUT_dcache_read_req_LQ_index, expected_dcache_read_req_LQ_index;
	daddr_t DUT_dcache_read_req_addr, expected_dcache_read_req_addr;
	logic DUT_dcache_read_req_linked, expected_dcache_read_req_linked;
	logic DUT_dcache_read_req_conditional, expected_dcache_read_req_conditional;
	logic tb_dcache_read_req_blocked;

    // read resp interface:
    //      - valid
    //      - LQ index
    //      - read data

	logic tb_dcache_read_resp_valid;
	LQ_index_t tb_dcache_read_resp_LQ_index;
	word_t tb_dcache_read_resp_data;

    // write req interface:
    //      - valid
    //      - addr
    //      - write data
    //      - conditional
    //      - blocked

	logic DUT_dcache_write_req_valid, expected_dcache_write_req_valid;
	daddr_t DUT_dcache_write_req_addr, expected_dcache_write_req_addr;
	word_t DUT_dcache_write_req_data, expected_dcache_write_req_data;
	logic DUT_dcache_write_req_conditional, expected_dcache_write_req_conditional;
	logic tb_dcache_write_req_blocked;

    // read kill interface x2:
    //      - valid
    //      - LQ index
        // just means cancel response to datapath so don't mix up with later request at same LQ index
            // d$'s job to figure out how to cancel
                // e.g. MSHR can get response but don't propagate upward into datapath
            // may also get cancel soon enough that can prevent MSHR bus request
        // 0: datapath ROB index kill load, kill dcache read req
        // 1: SQ forward, kill unneeded dcache read req

	logic DUT_dcache_read_kill_0_valid, expected_dcache_read_kill_0_valid;
	LQ_index_t DUT_dcache_read_kill_0_LQ_index, expected_dcache_read_kill_0_LQ_index;
	logic DUT_dcache_read_kill_1_valid, expected_dcache_read_kill_1_valid;
	LQ_index_t DUT_dcache_read_kill_1_LQ_index, expected_dcache_read_kill_1_LQ_index;

    // invalidation interface:
    //      - valid
    //      - inv address

	logic tb_dcache_inv_valid;
	block_addr_t tb_dcache_inv_block_addr;
	
	logic tb_dcache_evict_valid;
	block_addr_t tb_dcache_evict_block_addr;

    // halt interface:
    //      - halt

	logic DUT_dcache_halt, expected_dcache_halt;

    ///////////////////
    // shared buses: //
    ///////////////////

    // complete bus 0 (ALU 0)
	logic tb_complete_bus_0_tag_valid;
	phys_reg_tag_t tb_complete_bus_0_tag;
	word_t tb_complete_bus_0_data;

    // complete bus 1 (ALU 1)
	logic tb_complete_bus_1_tag_valid;
	phys_reg_tag_t tb_complete_bus_1_tag;
	word_t tb_complete_bus_1_data;

    // complete bus 2 (LQ)
	logic tb_complete_bus_2_tag_valid;
	phys_reg_tag_t tb_complete_bus_2_tag;
	word_t tb_complete_bus_2_data;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	`ifndef MAPPED
	lsq DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),


	    // DUT error
		.DUT_error(DUT_DUT_error),

	    ////////////////////
	    // dispatch unit: //
	    ////////////////////

	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,

		// .dispatch_unit_LQ_tail_index(DUT_dispatch_unit_LQ_tail_index),
		.dispatch_unit_LQ_full(DUT_dispatch_unit_LQ_full),
		.dispatch_unit_LQ_task_valid(tb_dispatch_unit_LQ_task_valid),
		.dispatch_unit_LQ_task_struct(tb_dispatch_unit_LQ_task_struct),
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

		// .dispatch_unit_SQ_tail_index(DUT_dispatch_unit_SQ_tail_index),
		.dispatch_unit_SQ_full(DUT_dispatch_unit_SQ_full),
		.dispatch_unit_SQ_task_valid(tb_dispatch_unit_SQ_task_valid),
		.dispatch_unit_SQ_task_struct(tb_dispatch_unit_SQ_task_struct),
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

		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),

	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires

		.core_control_halt(tb_core_control_halt),

	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,

		.ROB_LQ_restart_valid(DUT_ROB_LQ_restart_valid),
		.ROB_LQ_restart_after_instr(DUT_ROB_LQ_restart_after_instr),
		.ROB_LQ_restart_ROB_index(DUT_ROB_LQ_restart_ROB_index),

		.ROB_LQ_retire_valid(tb_ROB_LQ_retire_valid),
		.ROB_LQ_retire_ROB_index(tb_ROB_LQ_retire_ROB_index),
		.ROB_LQ_retire_blocked(DUT_ROB_LQ_retire_blocked),

	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,

		.ROB_SQ_complete_valid(DUT_ROB_SQ_complete_valid),
		.ROB_SQ_complete_ROB_index(DUT_ROB_SQ_complete_ROB_index),

		.ROB_SQ_retire_valid(tb_ROB_SQ_retire_valid),
		.ROB_SQ_retire_ROB_index(tb_ROB_SQ_retire_ROB_index),
		.ROB_SQ_retire_blocked(DUT_ROB_SQ_retire_blocked),

	    ////////////////////
	    // phys reg file: //
	    ////////////////////

	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,

		.LQ_reg_read_req_valid(DUT_LQ_reg_read_req_valid),
		.LQ_reg_read_req_tag(DUT_LQ_reg_read_req_tag),
		.LQ_reg_read_req_serviced(tb_LQ_reg_read_req_serviced),
		.LQ_reg_read_bus_0_data(tb_LQ_reg_read_bus_0_data),

	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,

		.SQ_reg_read_req_valid(DUT_SQ_reg_read_req_valid),
		.SQ_reg_read_req_0_tag(DUT_SQ_reg_read_req_0_tag),
		.SQ_reg_read_req_1_tag(DUT_SQ_reg_read_req_1_tag),
		.SQ_reg_read_req_serviced(tb_SQ_reg_read_req_serviced),
		.SQ_reg_read_bus_0_data(tb_SQ_reg_read_bus_0_data),
		.SQ_reg_read_bus_1_data(tb_SQ_reg_read_bus_1_data),

	    ///////////////////
	    // complete bus: //
	    ///////////////////

	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data

		.this_complete_bus_tag_valid(DUT_this_complete_bus_tag_valid),
		.this_complete_bus_tag(DUT_this_complete_bus_tag),
		.this_complete_bus_ROB_index(DUT_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(DUT_this_complete_bus_data_valid),
		.this_complete_bus_data(DUT_this_complete_bus_data),

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

		.dcache_read_req_valid(DUT_dcache_read_req_valid),
		.dcache_read_req_LQ_index(DUT_dcache_read_req_LQ_index),
		.dcache_read_req_addr(DUT_dcache_read_req_addr),
		.dcache_read_req_linked(DUT_dcache_read_req_linked),
		.dcache_read_req_conditional(DUT_dcache_read_req_conditional),
		.dcache_read_req_blocked(tb_dcache_read_req_blocked),

	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data

		.dcache_read_resp_valid(tb_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(tb_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(tb_dcache_read_resp_data),

	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked

		.dcache_write_req_valid(DUT_dcache_write_req_valid),
		.dcache_write_req_addr(DUT_dcache_write_req_addr),
		.dcache_write_req_data(DUT_dcache_write_req_data),
		.dcache_write_req_conditional(DUT_dcache_write_req_conditional),
		.dcache_write_req_blocked(tb_dcache_write_req_blocked),

	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	        // just means cancel response to datapath so don't mix up with later request at same LQ index
	            // d$'s job to figure out how to cancel
	                // e.g. MSHR can get response but don't propagate upward into datapath
	            // may also get cancel soon enough that can prevent MSHR bus request
	        // 0: datapath ROB index kill load, kill dcache read req
	        // 1: SQ forward, kill unneeded dcache read req

		.dcache_read_kill_0_valid(DUT_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(DUT_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(DUT_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(DUT_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
	    //      - valid
	    //      - inv address

		.dcache_inv_valid(tb_dcache_inv_valid),
		.dcache_inv_block_addr(tb_dcache_inv_block_addr),

		.dcache_evict_valid(tb_dcache_evict_valid),
		.dcache_evict_block_addr(tb_dcache_evict_block_addr),

	    // halt interface:
	    //      - halt

		.dcache_halt(DUT_dcache_halt),

	    ///////////////////
	    // shared buses: //
	    ///////////////////

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(tb_complete_bus_0_tag_valid),
		.complete_bus_0_tag(tb_complete_bus_0_tag),
		.complete_bus_0_data(tb_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(tb_complete_bus_1_tag_valid),
		.complete_bus_1_tag(tb_complete_bus_1_tag),
		.complete_bus_1_data(tb_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(tb_complete_bus_2_tag_valid),
		.complete_bus_2_tag(tb_complete_bus_2_tag),
		.complete_bus_2_data(tb_complete_bus_2_data)
	);
	`else

	// signals for type cast

	// assign enum to pure logic array

	lsq DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),


	    // DUT error
		.DUT_error(DUT_DUT_error),

	    ////////////////////
	    // dispatch unit: //
	    ////////////////////

	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,

		// .dispatch_unit_LQ_tail_index(DUT_dispatch_unit_LQ_tail_index),
		.dispatch_unit_LQ_full(DUT_dispatch_unit_LQ_full),
		.dispatch_unit_LQ_task_valid(tb_dispatch_unit_LQ_task_valid),
		// .dispatch_unit_LQ_task_struct(tb_dispatch_unit_LQ_task_struct),
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

			// struct -> need to enumerate
		.\dispatch_unit_LQ_task_struct.op (tb_dispatch_unit_LQ_task_struct.op),
		.\dispatch_unit_LQ_task_struct.source.needed (tb_dispatch_unit_LQ_task_struct.source.needed),
		.\dispatch_unit_LQ_task_struct.source.ready (tb_dispatch_unit_LQ_task_struct.source.ready),
		.\dispatch_unit_LQ_task_struct.source.phys_reg_tag (tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag),
		.\dispatch_unit_LQ_task_struct.dest_phys_reg_tag (tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag),
		.\dispatch_unit_LQ_task_struct.imm14 (tb_dispatch_unit_LQ_task_struct.imm14),
		.\dispatch_unit_LQ_task_struct.ROB_index (tb_dispatch_unit_LQ_task_struct.ROB_index),

	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,

		// .dispatch_unit_SQ_tail_index(DUT_dispatch_unit_SQ_tail_index),
		.dispatch_unit_SQ_full(DUT_dispatch_unit_SQ_full),
		.dispatch_unit_SQ_task_valid(tb_dispatch_unit_SQ_task_valid),
		// .dispatch_unit_SQ_task_struct(tb_dispatch_unit_SQ_task_struct),
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

			// struct -> need to enumerate
		.\dispatch_unit_SQ_task_struct.op (tb_dispatch_unit_SQ_task_struct.op),
		.\dispatch_unit_SQ_task_struct.source_0.needed (tb_dispatch_unit_SQ_task_struct.source_0.needed),
		.\dispatch_unit_SQ_task_struct.source_0.ready (tb_dispatch_unit_SQ_task_struct.source_0.ready),
		.\dispatch_unit_SQ_task_struct.source_0.phys_reg_tag (tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag),
		.\dispatch_unit_SQ_task_struct.source_1.needed (tb_dispatch_unit_SQ_task_struct.source_1.needed),
		.\dispatch_unit_SQ_task_struct.source_1.ready (tb_dispatch_unit_SQ_task_struct.source_1.ready),
		.\dispatch_unit_SQ_task_struct.source_1.phys_reg_tag (tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag),
		.\dispatch_unit_SQ_task_struct.imm14 (tb_dispatch_unit_SQ_task_struct.imm14),
		// .\dispatch_unit_SQ_task_struct.LQ_index (tb_dispatch_unit_SQ_task_struct.LQ_index),
		.\dispatch_unit_SQ_task_struct.ROB_index (tb_dispatch_unit_SQ_task_struct.ROB_index),

	    //////////
	    // ROB: //
	    //////////

	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,

		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),

	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires

		.core_control_halt(tb_core_control_halt),

	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,

		.ROB_LQ_restart_valid(DUT_ROB_LQ_restart_valid),
		.ROB_LQ_restart_after_instr(DUT_ROB_LQ_restart_after_instr),
		.ROB_LQ_restart_ROB_index(DUT_ROB_LQ_restart_ROB_index),

		.ROB_LQ_retire_valid(tb_ROB_LQ_retire_valid),
		.ROB_LQ_retire_ROB_index(tb_ROB_LQ_retire_ROB_index),
		.ROB_LQ_retire_blocked(DUT_ROB_LQ_retire_blocked),

	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,

		.ROB_SQ_complete_valid(DUT_ROB_SQ_complete_valid),
		.ROB_SQ_complete_ROB_index(DUT_ROB_SQ_complete_ROB_index),

		.ROB_SQ_retire_valid(tb_ROB_SQ_retire_valid),
		.ROB_SQ_retire_ROB_index(tb_ROB_SQ_retire_ROB_index),
		.ROB_SQ_retire_blocked(DUT_ROB_SQ_retire_blocked),

	    ////////////////////
	    // phys reg file: //
	    ////////////////////

	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,

		.LQ_reg_read_req_valid(DUT_LQ_reg_read_req_valid),
		.LQ_reg_read_req_tag(DUT_LQ_reg_read_req_tag),
		.LQ_reg_read_req_serviced(tb_LQ_reg_read_req_serviced),
		.LQ_reg_read_bus_0_data(tb_LQ_reg_read_bus_0_data),

	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,

		.SQ_reg_read_req_valid(DUT_SQ_reg_read_req_valid),
		.SQ_reg_read_req_0_tag(DUT_SQ_reg_read_req_0_tag),
		.SQ_reg_read_req_1_tag(DUT_SQ_reg_read_req_1_tag),
		.SQ_reg_read_req_serviced(tb_SQ_reg_read_req_serviced),
		.SQ_reg_read_bus_0_data(tb_SQ_reg_read_bus_0_data),
		.SQ_reg_read_bus_1_data(tb_SQ_reg_read_bus_1_data),

	    ///////////////////
	    // complete bus: //
	    ///////////////////

	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data

		.this_complete_bus_tag_valid(DUT_this_complete_bus_tag_valid),
		.this_complete_bus_tag(DUT_this_complete_bus_tag),
		.this_complete_bus_ROB_index(DUT_this_complete_bus_ROB_index),
		.this_complete_bus_data_valid(DUT_this_complete_bus_data_valid),
		.this_complete_bus_data(DUT_this_complete_bus_data),

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

		.dcache_read_req_valid(DUT_dcache_read_req_valid),
		.dcache_read_req_LQ_index(DUT_dcache_read_req_LQ_index),
		.dcache_read_req_addr(DUT_dcache_read_req_addr),
		.dcache_read_req_linked(DUT_dcache_read_req_linked),
		.dcache_read_req_conditional(DUT_dcache_read_req_conditional),
		.dcache_read_req_blocked(tb_dcache_read_req_blocked),

	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data

		.dcache_read_resp_valid(tb_dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(tb_dcache_read_resp_LQ_index),
		.dcache_read_resp_data(tb_dcache_read_resp_data),

	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked

		.dcache_write_req_valid(DUT_dcache_write_req_valid),
		.dcache_write_req_addr(DUT_dcache_write_req_addr),
		.dcache_write_req_data(DUT_dcache_write_req_data),
		.dcache_write_req_conditional(DUT_dcache_write_req_conditional),
		.dcache_write_req_blocked(tb_dcache_write_req_blocked),

	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	        // just means cancel response to datapath so don't mix up with later request at same LQ index
	            // d$'s job to figure out how to cancel
	                // e.g. MSHR can get response but don't propagate upward into datapath
	            // may also get cancel soon enough that can prevent MSHR bus request
	        // 0: datapath ROB index kill load, kill dcache read req
	        // 1: SQ forward, kill unneeded dcache read req

		.dcache_read_kill_0_valid(DUT_dcache_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(DUT_dcache_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(DUT_dcache_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(DUT_dcache_read_kill_1_LQ_index),

	    // invalidation interface:
	    //      - valid
	    //      - inv address

		.dcache_inv_valid(tb_dcache_inv_valid),
		.dcache_inv_block_addr(tb_dcache_inv_block_addr),

		.dcache_evict_valid(tb_dcache_evict_valid),
		.dcache_evict_block_addr(tb_dcache_evict_block_addr),

	    // halt interface:
	    //      - halt

		.dcache_halt(DUT_dcache_halt),

	    ///////////////////
	    // shared buses: //
	    ///////////////////

	    // complete bus 0 (ALU 0)
		.complete_bus_0_tag_valid(tb_complete_bus_0_tag_valid),
		.complete_bus_0_tag(tb_complete_bus_0_tag),
		.complete_bus_0_data(tb_complete_bus_0_data),

	    // complete bus 1 (ALU 1)
		.complete_bus_1_tag_valid(tb_complete_bus_1_tag_valid),
		.complete_bus_1_tag(tb_complete_bus_1_tag),
		.complete_bus_1_data(tb_complete_bus_1_data),

	    // complete bus 2 (LQ)
		.complete_bus_2_tag_valid(tb_complete_bus_2_tag_valid),
		.complete_bus_2_tag(tb_complete_bus_2_tag),
		.complete_bus_2_data(tb_complete_bus_2_data)
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

		// if (expected_dispatch_unit_LQ_tail_index !== DUT_dispatch_unit_LQ_tail_index) begin
		// 	$display("TB ERROR: expected_dispatch_unit_LQ_tail_index (%h) != DUT_dispatch_unit_LQ_tail_index (%h)",
		// 		expected_dispatch_unit_LQ_tail_index, DUT_dispatch_unit_LQ_tail_index);
		// 	num_errors++;
		// 	tb_error = 1'b1;
		// end

		if (expected_dispatch_unit_LQ_full !== DUT_dispatch_unit_LQ_full) begin
			$display("TB ERROR: expected_dispatch_unit_LQ_full (%h) != DUT_dispatch_unit_LQ_full (%h)",
				expected_dispatch_unit_LQ_full, DUT_dispatch_unit_LQ_full);
			num_errors++;
			tb_error = 1'b1;
		end

		// if (expected_dispatch_unit_SQ_tail_index !== DUT_dispatch_unit_SQ_tail_index) begin
		// 	$display("TB ERROR: expected_dispatch_unit_SQ_tail_index (%h) != DUT_dispatch_unit_SQ_tail_index (%h)",
		// 		expected_dispatch_unit_SQ_tail_index, DUT_dispatch_unit_SQ_tail_index);
		// 	num_errors++;
		// 	tb_error = 1'b1;
		// end

		if (expected_dispatch_unit_SQ_full !== DUT_dispatch_unit_SQ_full) begin
			$display("TB ERROR: expected_dispatch_unit_SQ_full (%h) != DUT_dispatch_unit_SQ_full (%h)",
				expected_dispatch_unit_SQ_full, DUT_dispatch_unit_SQ_full);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_LQ_restart_valid !== DUT_ROB_LQ_restart_valid) begin
			$display("TB ERROR: expected_ROB_LQ_restart_valid (%h) != DUT_ROB_LQ_restart_valid (%h)",
				expected_ROB_LQ_restart_valid, DUT_ROB_LQ_restart_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_LQ_restart_after_instr !== DUT_ROB_LQ_restart_after_instr) begin
			$display("TB ERROR: expected_ROB_LQ_restart_after_instr (%h) != DUT_ROB_LQ_restart_after_instr (%h)",
				expected_ROB_LQ_restart_after_instr, DUT_ROB_LQ_restart_after_instr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_LQ_restart_ROB_index !== DUT_ROB_LQ_restart_ROB_index) begin
			$display("TB ERROR: expected_ROB_LQ_restart_ROB_index (%d) != DUT_ROB_LQ_restart_ROB_index (%d)",
				expected_ROB_LQ_restart_ROB_index, DUT_ROB_LQ_restart_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_LQ_retire_blocked !== DUT_ROB_LQ_retire_blocked) begin
			$display("TB ERROR: expected_ROB_LQ_retire_blocked (%h) != DUT_ROB_LQ_retire_blocked (%h)",
				expected_ROB_LQ_retire_blocked, DUT_ROB_LQ_retire_blocked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_SQ_complete_valid !== DUT_ROB_SQ_complete_valid) begin
			$display("TB ERROR: expected_ROB_SQ_complete_valid (%h) != DUT_ROB_SQ_complete_valid (%h)",
				expected_ROB_SQ_complete_valid, DUT_ROB_SQ_complete_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_SQ_complete_ROB_index !== DUT_ROB_SQ_complete_ROB_index) begin
			$display("TB ERROR: expected_ROB_SQ_complete_ROB_index (%d) != DUT_ROB_SQ_complete_ROB_index (%d)",
				expected_ROB_SQ_complete_ROB_index, DUT_ROB_SQ_complete_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_ROB_SQ_retire_blocked !== DUT_ROB_SQ_retire_blocked) begin
			$display("TB ERROR: expected_ROB_SQ_retire_blocked (%h) != DUT_ROB_SQ_retire_blocked (%h)",
				expected_ROB_SQ_retire_blocked, DUT_ROB_SQ_retire_blocked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_reg_read_req_valid !== DUT_LQ_reg_read_req_valid) begin
			$display("TB ERROR: expected_LQ_reg_read_req_valid (%h) != DUT_LQ_reg_read_req_valid (%h)",
				expected_LQ_reg_read_req_valid, DUT_LQ_reg_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_LQ_reg_read_req_tag !== DUT_LQ_reg_read_req_tag) begin
			$display("TB ERROR: expected_LQ_reg_read_req_tag (%d) != DUT_LQ_reg_read_req_tag (%d)",
				expected_LQ_reg_read_req_tag, DUT_LQ_reg_read_req_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_reg_read_req_valid !== DUT_SQ_reg_read_req_valid) begin
			$display("TB ERROR: expected_SQ_reg_read_req_valid (%h) != DUT_SQ_reg_read_req_valid (%h)",
				expected_SQ_reg_read_req_valid, DUT_SQ_reg_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_reg_read_req_0_tag !== DUT_SQ_reg_read_req_0_tag) begin
			$display("TB ERROR: expected_SQ_reg_read_req_0_tag (%d) != DUT_SQ_reg_read_req_0_tag (%d)",
				expected_SQ_reg_read_req_0_tag, DUT_SQ_reg_read_req_0_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_SQ_reg_read_req_1_tag !== DUT_SQ_reg_read_req_1_tag) begin
			$display("TB ERROR: expected_SQ_reg_read_req_1_tag (%d) != DUT_SQ_reg_read_req_1_tag (%d)",
				expected_SQ_reg_read_req_1_tag, DUT_SQ_reg_read_req_1_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_tag_valid !== DUT_this_complete_bus_tag_valid) begin
			$display("TB ERROR: expected_this_complete_bus_tag_valid (%h) != DUT_this_complete_bus_tag_valid (%h)",
				expected_this_complete_bus_tag_valid, DUT_this_complete_bus_tag_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_tag !== DUT_this_complete_bus_tag) begin
			$display("TB ERROR: expected_this_complete_bus_tag (%d) != DUT_this_complete_bus_tag (%d)",
				expected_this_complete_bus_tag, DUT_this_complete_bus_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_ROB_index !== DUT_this_complete_bus_ROB_index) begin
			$display("TB ERROR: expected_this_complete_bus_ROB_index (%d) != DUT_this_complete_bus_ROB_index (%d)",
				expected_this_complete_bus_ROB_index, DUT_this_complete_bus_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_data_valid !== DUT_this_complete_bus_data_valid) begin
			$display("TB ERROR: expected_this_complete_bus_data_valid (%h) != DUT_this_complete_bus_data_valid (%h)",
				expected_this_complete_bus_data_valid, DUT_this_complete_bus_data_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_bus_data !== DUT_this_complete_bus_data) begin
			$display("TB ERROR: expected_this_complete_bus_data (%h) != DUT_this_complete_bus_data (%h)",
				expected_this_complete_bus_data, DUT_this_complete_bus_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_valid !== DUT_dcache_read_req_valid) begin
			$display("TB ERROR: expected_dcache_read_req_valid (%h) != DUT_dcache_read_req_valid (%h)",
				expected_dcache_read_req_valid, DUT_dcache_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_LQ_index !== DUT_dcache_read_req_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_req_LQ_index (%h) != DUT_dcache_read_req_LQ_index (%h)",
				expected_dcache_read_req_LQ_index, DUT_dcache_read_req_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_addr !== DUT_dcache_read_req_addr) begin
			$display("TB ERROR: expected_dcache_read_req_addr (%h) != DUT_dcache_read_req_addr (%h)",
				expected_dcache_read_req_addr, DUT_dcache_read_req_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_linked !== DUT_dcache_read_req_linked) begin
			$display("TB ERROR: expected_dcache_read_req_linked (%h) != DUT_dcache_read_req_linked (%h)",
				expected_dcache_read_req_linked, DUT_dcache_read_req_linked);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_req_conditional !== DUT_dcache_read_req_conditional) begin
			$display("TB ERROR: expected_dcache_read_req_conditional (%h) != DUT_dcache_read_req_conditional (%h)",
				expected_dcache_read_req_conditional, DUT_dcache_read_req_conditional);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_valid !== DUT_dcache_write_req_valid) begin
			$display("TB ERROR: expected_dcache_write_req_valid (%h) != DUT_dcache_write_req_valid (%h)",
				expected_dcache_write_req_valid, DUT_dcache_write_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_addr !== DUT_dcache_write_req_addr) begin
			$display("TB ERROR: expected_dcache_write_req_addr (%h) != DUT_dcache_write_req_addr (%h)",
				expected_dcache_write_req_addr, DUT_dcache_write_req_addr);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_data !== DUT_dcache_write_req_data) begin
			$display("TB ERROR: expected_dcache_write_req_data (%h) != DUT_dcache_write_req_data (%h)",
				expected_dcache_write_req_data, DUT_dcache_write_req_data);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_write_req_conditional !== DUT_dcache_write_req_conditional) begin
			$display("TB ERROR: expected_dcache_write_req_conditional (%h) != DUT_dcache_write_req_conditional (%h)",
				expected_dcache_write_req_conditional, DUT_dcache_write_req_conditional);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_0_valid !== DUT_dcache_read_kill_0_valid) begin
			$display("TB ERROR: expected_dcache_read_kill_0_valid (%h) != DUT_dcache_read_kill_0_valid (%h)",
				expected_dcache_read_kill_0_valid, DUT_dcache_read_kill_0_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_0_LQ_index !== DUT_dcache_read_kill_0_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_kill_0_LQ_index (%h) != DUT_dcache_read_kill_0_LQ_index (%h)",
				expected_dcache_read_kill_0_LQ_index, DUT_dcache_read_kill_0_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_1_valid !== DUT_dcache_read_kill_1_valid) begin
			$display("TB ERROR: expected_dcache_read_kill_1_valid (%h) != DUT_dcache_read_kill_1_valid (%h)",
				expected_dcache_read_kill_1_valid, DUT_dcache_read_kill_1_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_read_kill_1_LQ_index !== DUT_dcache_read_kill_1_LQ_index) begin
			$display("TB ERROR: expected_dcache_read_kill_1_LQ_index (%h) != DUT_dcache_read_kill_1_LQ_index (%h)",
				expected_dcache_read_kill_1_LQ_index, DUT_dcache_read_kill_1_LQ_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_dcache_halt !== DUT_dcache_halt) begin
			$display("TB ERROR: expected_dcache_halt (%h) != DUT_dcache_halt (%h)",
				expected_dcache_halt, DUT_dcache_halt);
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
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h0;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
		tb_dcache_evict_valid = 1'b0;
		tb_dcache_evict_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(0);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h0;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(0);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

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
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h0;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(0);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // simple load stream:
        test_case = "simple load stream";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 00: LW p33, 0x001(p1 [ready]) -> LQ0", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(0);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 00: LW p33, 0x001(p1 [ready]) (successful reg read)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h4;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h4;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h0;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h4;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: LQ0 d$ read resp, LQ complete tag", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h4;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h00020002;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: LQ complete data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: LW p33, 0x001(p1 [ready])", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h4;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(33);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h00020002;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: LQ retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: LW p33, 0x001(p1 [ready]) <- head", "\n\t\t",
			" | 		1: nop <- tail, SQ search", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop <- head, tail", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: 00: nop", "\n\t\t",
			" | 		1: nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop <- head, tail", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(33);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 01: LW p34, 0x002(p2 (0x8)) (LQ1, ready reg read fail, d$ miss, search before d$)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: nop", "\n\t\t",
			" | 		1: nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: nop <- head, tail", "\n\t\t",
			" | 		1: nop", "\n\t\t",
			" | 		2: nop", "\n\t\t",
			" | 		3: nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h2;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(1);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(1);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(0);
		expected_this_complete_bus_ROB_index = ROB_index_t'(0);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 01: LW p34, 0x002(p2 (0x8)) (fail)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop", "\n\t\t",
			" | 		1: (n) 01: LW p34, 0x002(p2 (0x8)) <- SQ search, head", "\n\t\t",
			" | 		2: (i) nop <- tail", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(34);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h2;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(1);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h0;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(2);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(2);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 02: LW p35, 0x003(p3 (0xC)) (LQ2, ready next, d$ miss, search before d$)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 01: LW p34, 0x002(p2 (0x8)) (success)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop", "\n\t\t",
			" | 		1: (n) 01: LW p34, 0x002(p2 (0x8)) <- SQ search, head", "\n\t\t",
			" | 		2: (i) nop <- tail", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(35);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h3;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(2);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h8;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(0);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(2);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(2);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 03: LW p36, 0x004(p4 (0x10)) (LQ3, not ready, d$ miss, search before d$)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p3 complete tag", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 02: LW p35, 0x003(p3 (0xC)) (success)", "\n\t\t",
			" | 		addr calc: 01: LW p34, 0x002(p2 (0x8))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop", "\n\t\t",
			" | 		1: (n) 01: LW p34, 0x002(p2 (0x8)) <- SQ search, head", "\n\t\t",
			" | 		2: (n) 02: LW p35, 0x003(p3 (0xC))", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(3);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h2;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(3);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(3);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(1);
		expected_dcache_read_req_addr = 14'h2;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p3 complete data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 03: LW p36, 0x004(p4 (0x10)) (not ready)", "\n\t\t",
			" | 		addr calc: 02: LW p35, 0x003(p3 (0xC))", "\n\t\t",
			" | 		operand update: 01: LW p34, 0x002(p2 (0x8))", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) <- tail", "\n\t\t",
			" | 		1: (n) 01: LW p34, 0x002(p2 (0x8)) <- SQ search (n), head", "\n\t\t",
			" | 		2: (n) 02: LW p35, 0x003(p3 (0xC))", "\n\t\t",
			" | 		3: (n) 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(3);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h2;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(3);
		tb_complete_bus_0_data = 32'hC;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(4);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(1);
		expected_dcache_read_req_addr = 14'h4;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 04: LW p37, 0x005(p5 (0x14)) (LQ0, ready, d$ miss, search before d$)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p4 complete tag", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 03: LW p36, 0x004(p4 (0x10)) (success)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 02: LW p35, 0x003(p3 (0xC))", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) <- tail", "\n\t\t",
			" | 		1: (r) 01: LW p34, 0x002(p2 (0x8)) <- head, SQ search (req)", "\n\t\t",
			" | 		2: (n) 02: LW p35, 0x003(p3 (0xC))", "\n\t\t",
			" | 		3: (n) 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(37);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h5;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h2;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'hC;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(4);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h6;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p4 complete data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 04: LW p37, 0x005(p5 (0x14)) (read success)", "\n\t\t",
			" | 		addr calc: 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (n) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (r) 01: LW p34, 0x002(p2 (0x8)) <- head, SQ search (resp), tail", "\n\t\t",
			" | 		2: (r) 02: LW p35, 0x003(p3 (0xC)) ", "\n\t\t",
			" | 		3: (n) 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(3);
		expected_dcache_read_req_addr = 14'h4;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 04: LW p37, 0x005(p5 (0x14)) (read success)", "\n\t\t",
			" | 		operand update: 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (n) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (r) 01: LW p34, 0x002(p2 (0x8)) <- head, tail", "\n\t\t",
			" | 		2: (r) 02: LW p35, 0x003(p3 (0xC)) <- SQ search (req)", "\n\t\t",
			" | 		3: (n) 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h0;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(35);
		expected_this_complete_bus_ROB_index = ROB_index_t'(2);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(3);
		expected_dcache_read_req_addr = 14'h8;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: LQ3 d$ resp, 03 tag", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (n) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (r) 01: LW p34, 0x002(p2 (0x8)) <- head, tail", "\n\t\t",
			" | 		2: (r) 02: LW p35, 0x003(p3 (0xC)) <- SQ search (resp, blocked by d$)", "\n\t\t",
			" | 		3: (r) 03: LW p36, 0x004(p4 (0x10)) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(3);
		tb_dcache_read_resp_data = 32'h00080008;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(36);
		expected_this_complete_bus_ROB_index = ROB_index_t'(3);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: LQ1 d$ resp, 01 tag, 03 data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (r) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (r) 01: LW p34, 0x002(p2 (0x8)) <- head, tail", "\n\t\t",
			" | 		2: (r) 02: LW p35, 0x003(p3 (0xC)) <- SQ search (resp, blocked by d$)", "\n\t\t",
			" | 		3: (c) 03: LW p36, 0x004(p4 (0x10)) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(0);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(1);
		tb_dcache_read_resp_data = 32'h00040004;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h00080008;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 01 retire, LQ2 d$ resp, 02 tag, 01 data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (r) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (c) 01: LW p34, 0x002(p2 (0x8)) <- head, tail", "\n\t\t",
			" | 		2: (r) 02: LW p35, 0x003(p3 (0xC)) <- SQ search (resp w/ d$)", "\n\t\t",
			" | 		3: (c) 03: LW p36, 0x004(p4 (0x10))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(1);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(2);
		tb_dcache_read_resp_data = 32'h00060006;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(35);
		expected_this_complete_bus_ROB_index = ROB_index_t'(2);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h00040004;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: LQ0 d$ resp, 04 tag, 02 data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (r) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (c) 02: LW p35, 0x003(p3 (0xC)) <- head", "\n\t\t",
			" | 		3: (c) 03: LW p36, 0x004(p4 (0x10)) <- SQ search (req)", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(1);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(4);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h00060006;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 02 retire, 04 data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (c) 04: LW p37, 0x005(p5 (0x14))", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (c) 02: LW p35, 0x003(p3 (0xC)) <- head", "\n\t\t",
			" | 		3: (c) 03: LW p36, 0x004(p4 (0x10)) <- SQ search (resp)", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(2);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(36);
		expected_this_complete_bus_ROB_index = ROB_index_t'(3);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h000A000A;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 03 retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (c) 04: LW p37, 0x005(p5 (0x14)) <- SQ search (req)", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (c) nop ", "\n\t\t",
			" | 		3: (c) 03: LW p36, 0x004(p4 (0x10)) <- head", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(3);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(4);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 04 retire (blocked)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (c) 04: LW p37, 0x005(p5 (0x14)) <- SQ search (resp), head", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (c) nop ", "\n\t\t",
			" | 		3: (c) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b1;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(37);
		expected_this_complete_bus_ROB_index = ROB_index_t'(4);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 04 retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (c) 04: LW p37, 0x005(p5 (0x14)) <- head", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search", "\n\t\t",
			" | 		2: (c) nop ", "\n\t\t",
			" | 		3: (c) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- head, tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h0;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(0);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // simple store stream:
        test_case = "simple store stream";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 05: SW p16 (0x80), 0x010(p10 (0x40)) (SQ0, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail, head", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(10);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h10;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(5);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(0);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(0);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 05: SW p16 (0x80), 0x010(p10 (0x40)) (fail read)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- head", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(10);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h10;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0);
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(5);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b1;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'h0;
		tb_SQ_reg_read_bus_1_data = 32'h0;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(1);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(10);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(16);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 06: SW p17 (0x88), 0x011(p11 (0x44)) (SQ1, ready/next)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity:", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 05: SW p16 (0x80), 0x010(p10 (0x40)) (success read)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- head", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(11);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h11;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(6);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h40;
		tb_SQ_reg_read_bus_1_data = 32'h80;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(1);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(10);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(16);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 07: SW p18 (0x90), 0x012(p12 (0x48)) (SQ2, next/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p17 tag complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		addr calc: 05: SW p16 (0x80), 0x010(p10 (0x40))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- head", "\n\t\t",
			" | 		1: (i) 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		2: (i) nop <- tail", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(12);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h12;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(7);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h44;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'h10;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(17);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(0);
		tb_complete_bus_2_data = 32'h0;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(11);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(17);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 08: SW p19 (0x98), 0x013(p13 (0x4C)) (SQ3, next/next)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p17 data complete, p12 tag complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		addr calc: 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		operand update: 05: SW p16 (0x80), 0x010(p10 (0x40))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- head", "\n\t\t",
			" | 		1: (i) 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		2: (i) 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h13;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(8);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(0);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'h90;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(0);
		tb_complete_bus_1_data = 32'h88;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(12);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(5);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(12);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(18);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 05 retire, p12 data complete, p13 tag complete, p19 tag complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" | 		addr calc: 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		operand update: 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- head, tail", "\n\t\t",
			" | 		1: (n) 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		2: (n) 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		3: (n) 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h13;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(8);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(5);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(13);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(19);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h48;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(6);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(13);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(19);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 05 d$ write req, 06 retire, p13 data complete, p19 data complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" | 		operand update: 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- tail", "\n\t\t",
			" | 		1: (c) 06: SW p17 (0x88), 0x011(p11 (0x44)) <- head", "\n\t\t",
			" | 		2: (n) 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		3: (n) 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h13;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(8);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(6);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(13);
		tb_complete_bus_0_data = 32'h4C;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(19);
		tb_complete_bus_1_data = 32'h98;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(7);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(13);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(19);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h20;
		expected_dcache_write_req_data = 32'h80;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 06 d$ write req, 07 retire (blocked)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- tail", "\n\t\t",
			" | 		1: (i) 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		2: (c) 07: SW p18 (0x90), 0x012(p12 (0x48)) <- head", "\n\t\t",
			" | 		3: (n) 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h13;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(8);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b1;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(8);
		expected_ROB_SQ_retire_blocked = 1'b1;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(13);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(19);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h22;
		expected_dcache_write_req_data = 32'h88;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 09: SW p20 (0x100), 0x014(p14 (0x50)) (SQ0, ready/not)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 07 retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 05: SW p16 (0x80), 0x010(p10 (0x40)) <- tail", "\n\t\t",
			" | 		1: (i) 06: SW p17 (0x88), 0x011(p11 (0x44))", "\n\t\t",
			" | 		2: (c) 07: SW p18 (0x90), 0x012(p12 (0x48)) <- head", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C))", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h14;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(9);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(13);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(19);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 09: SW p20 (0x100), 0x014(p14 (0x50)) (not ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (i) 06: SW p17 (0x88), 0x011(p11 (0x44)) <- tail", "\n\t\t",
			" | 		2: (i) 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h14;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(9);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(1);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(14);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(20);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h24;
		expected_dcache_write_req_data = 32'h90;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 10: SW p21 (0x108), 0x015(p15 (0x54)) (SQ1, not/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p20 tag complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 09: SW p20 (0x100), 0x014(p14 (0x50)) (VTM)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (i) 06: SW p17 (0x88), 0x011(p11 (0x44)) <- tail", "\n\t\t",
			" | 		2: (i) 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(15);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(21);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h15;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(10);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h50;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(20);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(1);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(14);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(20);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p20 data complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 10: SW p21 (0x108), 0x015(p15 (0x54)) (not ready)", "\n\t\t",
			" | 		addr calc: 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (n) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (i) 07: SW p18 (0x90), 0x012(p12 (0x48)) <- tail", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h100;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(15);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(21);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 11: SW p22 (0x110), 0x016(p16 (0x58)) (SQ2, not/not)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p15 tag complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 10: SW p21 (0x108), 0x015(p15 (0x54)) (VTM)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (n) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (i) 07: SW p18 (0x90), 0x012(p12 (0x48)) <- tail", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'h108;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(15);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(9);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(15);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(21);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p16 tag complete, p15 data complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 11: SW p22 (0x110), 0x016(p16 (0x58)) (not ready)", "\n\t\t",
			" | 		addr calc: 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (n) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (n) 07: SW p18 (0x90), 0x012(p12 (0x48))", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head, tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(16);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h54;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p22 tag complete, p16 data complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 11: SW p22 (0x110), 0x016(p16 (0x58)) (VTM)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (n) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (n) 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head, tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(7);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h58;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h58;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(22);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(10);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 08 retire, p22 data complete", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (c) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (n) 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		3: (c) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- head, tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(8);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h58;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h110;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b1;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 09 retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 09: SW p20 (0x100), 0x014(p14 (0x50)) <- head", "\n\t\t",
			" | 		1: (c) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (n) 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		3: (i) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(9);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(11);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h26;
		expected_dcache_write_req_data = 32'h98;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 10 retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (c) 10: SW p21 (0x108), 0x015(p15 (0x54)) <- head", "\n\t\t",
			" | 		2: (c) 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		3: (i) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(10);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h28;
		expected_dcache_write_req_data = 32'h100;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 11 retire", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (i) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (c) 11: SW p22 (0x110), 0x016(p16 (0x58)) <- head", "\n\t\t",
			" | 		3: (i) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- tail", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b1;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h2A;
		expected_dcache_write_req_data = 32'h108;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (i) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (i) 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		3: (i) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- tail, head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b1;
		expected_dcache_write_req_addr = 14'h2C;
		expected_dcache_write_req_data = 32'h110;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) 09: SW p20 (0x100), 0x014(p14 (0x50))", "\n\t\t",
			" | 		1: (i) 10: SW p21 (0x108), 0x015(p15 (0x54))", "\n\t\t",
			" | 		2: (i) 11: SW p22 (0x110), 0x016(p16 (0x58))", "\n\t\t",
			" | 		3: (i) 08: SW p19 (0x98), 0x013(p13 (0x4C)) <- tail, head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(22);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h16;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(11);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // LSQ forwarding:
        test_case = "LSQ forwarding";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 12: SW p23 (0x118), 0x017(p17 (0x5C)) (SQ3, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (i) nop <- tail, head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(36);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h4;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(3);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(16);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(22);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) (d$ read, should've forwarded) (SQ3, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (i) nop <- tail, SQ search, head", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 12: SW p23 (0x118), 0x017(p17 (0x5C))", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (n) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(38);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h18;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(13);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'h14;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h5C;
		tb_SQ_reg_read_bus_1_data = 32'h118;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(5);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(34);
		expected_this_complete_bus_ROB_index = ROB_index_t'(1);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) (no forward, d$ read) (will be killed)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: LW p38, 0x018(p6 (0x58)) (LQ1, ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (n) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (i) nop <- tail", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 12: SW p23 (0x118), 0x017(p17 (0x5C))", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop", "\n\t\t",
			" | 		2: (i) nop", "\n\t\t",
			" | 		3: (n) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h58;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(2);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(6);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready)", "\n\t\t",
			" | 		addr calc: 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready)", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (n) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 12: SW p23 (0x118), 0x017(p17 (0x5C))", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (n) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h58;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(12);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'ha;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: ", "\n\t\t",
			" | 		addr calc: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready)", "\n\t\t",
			" | 		operand update: 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (n) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h000A000A;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(1);
		expected_dcache_read_req_addr = 14'h2E;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 13 d$ read resp", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (r) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(1);
		tb_dcache_read_resp_data = 32'h38383838;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2C;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 14 d$ read resp, SQ search restart (delayed by d$ read resp)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (r) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (r) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(2);
		tb_dcache_read_resp_data = 32'h39393939;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(39);
		expected_this_complete_bus_ROB_index = ROB_index_t'(14);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h38383838;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 13 SQ search restart, tag broadcast", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (r) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (r) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(0);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b1;
		expected_ROB_LQ_restart_after_instr = 1'b1; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(13);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h39393939;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: kill 14, 13 data broadcast", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (r) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (r) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) <- tail", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(14);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(2);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(39);
		expected_this_complete_bus_ROB_index = ROB_index_t'(14);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h118;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b1;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(2);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) (no forward, d$ read)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- SQ search, head", "\n\t\t",
			" | 		2: (i) nop <- tail", "\n\t\t",
			" | 		3: (i) nop ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(23);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h17;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(12);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(2);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(39);
		expected_this_complete_bus_ROB_index = ROB_index_t'(14);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) <- SQ search", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (i) nop ", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(39);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h16;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(14);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(24);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h18;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(15);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h58;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(0);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(17);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(23);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(39);
		expected_this_complete_bus_ROB_index = ROB_index_t'(14);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(2);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) (forward 0x120)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready)", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) <- SQ search", "\n\t\t",
			" | 		3: (i) nop <- tail", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(7);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1A;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(16);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(24);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h18;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(15);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h58;
		tb_SQ_reg_read_bus_1_data = 32'h120;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(3);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(1);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(16);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(18);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(24);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(36);
		expected_this_complete_bus_ROB_index = ROB_index_t'(3);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) (not ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) <- SQ search", "\n\t\t",
			" | 		3: (i) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready)", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (i) nop <- tail", "\n\t\t",
			" | 		2: (i) nop ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(7);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1A;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(16);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b1;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(1);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(7);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(18);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(24);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h16 + (14'h58 >> 2);
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 14 d$ resp", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) (not ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head", "\n\t\t",
			" | 		2: (n) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) <- SQ search", "\n\t\t",
			" | 		3: (i) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (n) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (i) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(7);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1A;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(16);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b1;
		tb_SQ_reg_read_bus_0_data = 32'h54;
		tb_SQ_reg_read_bus_1_data = 32'h124;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(2);
		tb_dcache_read_resp_data = 32'h39393939;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(15);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(7);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b1;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(39);
		expected_this_complete_bus_ROB_index = ROB_index_t'(14);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(2);
		expected_dcache_read_req_addr = 14'h2fd1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) (not ready)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (n) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) <- SQ search", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready)", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (n) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b0;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(7);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h1A;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(16);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(7);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h39393939;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(3);
		expected_dcache_read_req_addr = 14'h2fd5;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) (no forward, d$ read) (d$ inv)", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p7 ready", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) (VTM)", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (n) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) <- SQ search", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready)", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (n) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b1;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h3fff;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(7);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b1;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(17);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(7);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(3);
		expected_dcache_read_req_addr = 14'h2fd5;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: p7 ready", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready)", "\n\t\t",
			" | 		addr calc: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready)", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (n) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (n) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) <- SQ search", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'hAC;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h50;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b1;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(3);
		expected_dcache_read_req_addr = 14'h2fd5;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: early 18 d$ inv", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: ", "\n\t\t",
			" | 		addr calc: 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready)", "\n\t\t",
			" | 		operand update: 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (n) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (n) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) <- SQ search", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h6C;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b1;
		tb_dcache_inv_block_addr = ((13'hAC >> 2) - 13'h1) >> 1;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(3);
		expected_dcache_read_req_addr = 14'h2E;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 16 SQ search req", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready)", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (n) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (c) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) <- SQ search", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b1;
		tb_LQ_reg_read_bus_0_data = 32'h6C;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b1;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = (14'hAC >> 2) - 14'h1;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 16 SQ search resp, 16 d$ resp, 16 complete tag", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (r) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (c) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) <- SQ search", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(3);
		tb_dcache_read_resp_data = 32'h40404040;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(40);
		expected_this_complete_bus_ROB_index = ROB_index_t'(16);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h1A;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(3);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 18 d$ inv (before resp), 16 complete data", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (r) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) <- SQ search", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (c) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b1;
		tb_dcache_inv_block_addr = ((13'hAC >> 2) - 13'h1) >> 1;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(41);
		expected_this_complete_bus_ROB_index = ROB_index_t'(18);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h120;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h1A;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 18 d$ resp", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (r) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail, SQ search", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (c) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b1;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(0);
		tb_dcache_read_resp_data = 32'h00004141;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b1;
		expected_this_complete_bus_tag = phys_reg_tag_t'(41);
		expected_this_complete_bus_ROB_index = ROB_index_t'(18);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2fba;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(0);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: 18 d$ inv + restart", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (c) 18: LW p41, 0x3fff(p8 (0xAC)) (LQ0, ready) ", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, tail, SQ search", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (c) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b1;
		tb_dcache_inv_block_addr = ((13'hAC >> 2) - 13'h1) >> 1;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(1);
		expected_dispatch_unit_LQ_full = 1'b1;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b1;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(18);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b1;
		expected_this_complete_bus_data = 32'h00004141;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2fba;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" T ", "\n\t\t",
			" | dispatch: ", "\n\t\t",
			" | \n\t\t",
			" | 	external activity: ", "\n\t\t",
			" | \n\t\t",
			" | 	LQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	LQ entries:", "\n\t\t",
			" | 		0: (i) nop <- tail", "\n\t\t",
			" | 		1: (c) 13: LW p38, 0x018(p6 (0x58)) (LQ1, ready) <- head, SQ search", "\n\t\t",
			" | 		2: (c) 14: LW p39, 0x016(p16 (0x58)) (LQ2, ready) ", "\n\t\t",
			" | 		3: (c) 16: LW p40, 0x020(p7 (0x50)) (LQ3, not ready) ", "\n\t\t",
			" | \n\t\t",
			" | 	SQ operand pipeline:", "\n\t\t",
			" | 		reg read: nop", "\n\t\t",
			" | 		addr calc: nop", "\n\t\t",
			" | 		operand update: nop", "\n\t\t",
			" | \n\t\t",
			" | 	SQ entries:", "\n\t\t",
			" | 		0: (c) 15: SW p24 (0x120), 0x018(p18 (0x58)) (SQ0, ready/ready) ", "\n\t\t",
			" | 		1: (c) 17: SW p25 (0x124), 0x019(p19 (0x54)) (SQ1, ready/ready) ", "\n\t\t",
			" | 		2: (i) <- tail ", "\n\t\t",
			" | 		3: (c) 12: SW p23 (0x118), 0x017(p17 (0x5C)) <- head", "\n\t\t",
			" L", "\n\t\t"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		tb_dispatch_unit_LQ_task_valid = 1'b0;
		tb_dispatch_unit_LQ_task_struct.op = LQ_LW;
        tb_dispatch_unit_LQ_task_struct.source.needed = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.ready = 1'b1;
        tb_dispatch_unit_LQ_task_struct.source.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_LQ_task_struct.dest_phys_reg_tag = phys_reg_tag_t'(41);
        tb_dispatch_unit_LQ_task_struct.imm14 = 14'h21;
        tb_dispatch_unit_LQ_task_struct.ROB_index = ROB_index_t'(18);
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		tb_dispatch_unit_SQ_task_valid = 1'b0;
        tb_dispatch_unit_SQ_task_struct.op = SQ_SW;
		tb_dispatch_unit_SQ_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(19);
        tb_dispatch_unit_SQ_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_SQ_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(25);
        tb_dispatch_unit_SQ_task_struct.imm14 = 14'h19;
        // tb_dispatch_unit_SQ_task_struct.LQ_index = LQ_index_t'(0); // not using
        tb_dispatch_unit_SQ_task_struct.ROB_index = ROB_index_t'(17);
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
		tb_core_control_halt = 1'b0;
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		tb_ROB_LQ_retire_valid = 1'b0;
		tb_ROB_LQ_retire_ROB_index = ROB_index_t'(4);
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		tb_ROB_SQ_retire_valid = 1'b0;
		tb_ROB_SQ_retire_ROB_index = ROB_index_t'(11);
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		tb_LQ_reg_read_req_serviced = 1'b0;
		tb_LQ_reg_read_bus_0_data = 32'hdeadbeef;
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		tb_SQ_reg_read_req_serviced = 1'b0;
		tb_SQ_reg_read_bus_0_data = 32'hdeadbeef;
		tb_SQ_reg_read_bus_1_data = 32'hdeadbeef;
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
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
		tb_dcache_read_req_blocked = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
		tb_dcache_read_resp_valid = 1'b0;
		tb_dcache_read_resp_LQ_index = LQ_index_t'(99);
		tb_dcache_read_resp_data = 32'hdeadbeef;
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		tb_dcache_write_req_blocked = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
	    // invalidation interface:
	    //      - valid
	    //      - inv address
		tb_dcache_inv_valid = 1'b0;
		tb_dcache_inv_block_addr = 13'h0;
	    // halt interface:
	    //      - halt
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    ////////////////////
	    // dispatch unit: //
	    ////////////////////
	    // // LQ interface
	    // input LQ_index_t dispatch_unit_LQ_tail_index,
	    // input logic dispatch_unit_LQ_full,
	    // output logic dispatch_unit_LQ_task_valid,
	    // output LQ_enqueue_struct_t dispatch_unit_LQ_task_struct,
		// expected_dispatch_unit_LQ_tail_index = LQ_index_t'(0);
		expected_dispatch_unit_LQ_full = 1'b0;
	    // // SQ interface
	    // input SQ_index_t dispatch_unit_SQ_tail_index,
	    // input logic dispatch_unit_SQ_full,
	    // output logic dispatch_unit_SQ_task_valid,
	    // output SQ_enqueue_struct_t dispatch_unit_SQ_task_struct,
		// expected_dispatch_unit_SQ_tail_index = SQ_index_t'(2);
		expected_dispatch_unit_SQ_full = 1'b0;
	    //////////
	    // ROB: //
	    //////////
	    // // kill bus interface
	    //     // send kill command to execution units
	    // output logic kill_bus_valid,
	    // output ROB_index_t kill_bus_ROB_index,
	    // // core control interface
	    // output logic core_control_restore_flush,
	    // output logic core_control_revert_stall,
	    // output logic core_control_halt_assert,
	    //     // for when halt instr retires
	    // // LQ interface
	    // // restart info
	    // input logic ROB_LQ_restart_valid,
	    // input ROB_index_t ROB_LQ_restart_ROB_index,
	    // // retire
	    // output logic ROB_LQ_retire_valid,
	    // output ROB_index_t ROB_LQ_retire_ROB_index,
	    // input logic ROB_LQ_retire_blocked,
		expected_ROB_LQ_restart_valid = 1'b0;
		expected_ROB_LQ_restart_after_instr = 1'b0; // new output
		expected_ROB_LQ_restart_ROB_index = ROB_index_t'(0);
		expected_ROB_LQ_retire_blocked = 1'b0;
	    // // SQ interface
	    // // complete
	    // input logic ROB_SQ_complete_valid,
	    // input ROB_index_t ROB_SQ_complete_ROB_index,
	    // // retire
	    // output logic ROB_SQ_retire_valid,
	    // output ROB_index_t ROB_SQ_retire_ROB_index,
	    // input logic ROB_SQ_retire_blocked,
		expected_ROB_SQ_complete_valid = 1'b0;
		expected_ROB_SQ_complete_ROB_index = ROB_index_t'(0);
		expected_ROB_SQ_retire_blocked = 1'b0;
	    ////////////////////
	    // phys reg file: //
	    ////////////////////
	    // // LQ read req
	    // input logic LQ_read_req_valid,
	    // input phys_reg_tag_t LQ_read_req_tag,
	    // output logic LQ_read_req_serviced,
		expected_LQ_reg_read_req_valid = 1'b0;
		expected_LQ_reg_read_req_tag = phys_reg_tag_t'(8);
	    // // SQ read req
	    // input logic SQ_read_req_valid,
	    // input phys_reg_tag_t SQ_read_req_0_tag,
	    // input phys_reg_tag_t SQ_read_req_1_tag,
	    // output logic SQ_read_req_serviced,
		expected_SQ_reg_read_req_valid = 1'b0;
		expected_SQ_reg_read_req_0_tag = phys_reg_tag_t'(19);
		expected_SQ_reg_read_req_1_tag = phys_reg_tag_t'(25);
	    ///////////////////
	    // complete bus: //
	    ///////////////////
	    // // output side (output to this ALU Pipeline's associated bus)
	    // output logic this_complete_bus_tag_valid,
	    // output phys_reg_tag_t this_complete_bus_tag,
	    // output ROB_index_t this_complete_bus_ROB_index,
	    // output logic this_complete_bus_data_valid, // only needs to go to reg file
	    // output word_t this_complete_bus_data
		expected_this_complete_bus_tag_valid = 1'b0;
		expected_this_complete_bus_tag = phys_reg_tag_t'(38);
		expected_this_complete_bus_ROB_index = ROB_index_t'(13);
		expected_this_complete_bus_data_valid = 1'b0;
		expected_this_complete_bus_data = 32'h0;
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
		expected_dcache_read_req_valid = 1'b0;
		expected_dcache_read_req_LQ_index = LQ_index_t'(0);
		expected_dcache_read_req_addr = 14'h2fba;
		expected_dcache_read_req_linked = 1'b0;
		expected_dcache_read_req_conditional = 1'b0;
	    // read resp interface:
	    //      - valid
	    //      - LQ index
	    //      - read data
	    // write req interface:
	    //      - valid
	    //      - addr
	    //      - write data
	    //      - conditional
	    //      - blocked
		expected_dcache_write_req_valid = 1'b0;
		expected_dcache_write_req_addr = 14'h0;
		expected_dcache_write_req_data = 32'h0;
		expected_dcache_write_req_conditional = 1'b0;
	    // read kill interface x2:
	    //      - valid
	    //      - LQ index
		expected_dcache_read_kill_0_valid = 1'b0;
		expected_dcache_read_kill_0_LQ_index = LQ_index_t'(0);
		expected_dcache_read_kill_1_valid = 1'b0;
		expected_dcache_read_kill_1_LQ_index = LQ_index_t'(1);
	    // invalidation interface:
	    //      - valid
	    //      - inv address
	    // halt interface:
	    //      - halt
		expected_dcache_halt = 1'b0;
	    ///////////////////
	    // shared buses: //
	    ///////////////////
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)

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

