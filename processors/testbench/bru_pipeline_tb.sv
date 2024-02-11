/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: bru_pipeline_tb.sv
    Description: 
       Testbench for bru_pipeline module. 
*/

`timescale 1ns/100ps

`include "core_types.vh"
import core_types_pkg::*;

module bru_pipeline_tb ();

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

    // full
	logic DUT_BRU_RS_full, expected_BRU_RS_full;

    // dispatch unit interface
	logic tb_dispatch_unit_task_valid;
	BRU_RS_input_struct_t tb_dispatch_unit_task_struct;
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
	logic DUT_reg_file_read_req_valid, expected_reg_file_read_req_valid;
	phys_reg_tag_t DUT_reg_file_read_req_0_tag, expected_reg_file_read_req_0_tag;
	phys_reg_tag_t DUT_reg_file_read_req_1_tag, expected_reg_file_read_req_1_tag;
	logic tb_reg_file_read_req_serviced;
	word_t tb_reg_file_read_bus_0_data;
	word_t tb_reg_file_read_bus_1_data;

    // kill bus interface
	logic tb_kill_bus_valid;
	ROB_index_t tb_kill_bus_ROB_index;

    // complete bus interface:

    // input side (take from any 3 buses):

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

    // complete output to ROB
	logic DUT_this_complete_valid, expected_this_complete_valid;

    // restart output to ROB
	logic DUT_this_restart_valid, expected_this_restart_valid;
	ROB_index_t DUT_this_restart_ROB_index, expected_this_restart_ROB_index;
	pc_t DUT_this_restart_PC, expected_this_restart_PC;
	checkpoint_column_t DUT_this_restart_safe_column, expected_this_restart_safe_column;

    // BTB/DIRP updates to fetch_unit
	logic DUT_this_BTB_DIRP_update, expected_this_BTB_DIRP_update;
	BTB_DIRP_index_t DUT_this_BTB_DIRP_index, expected_this_BTB_DIRP_index;
	pc_t DUT_this_BTB_target, expected_this_BTB_target;
	logic DUT_this_DIRP_taken, expected_this_DIRP_taken;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT instantiation:

	`ifndef MAPPED
	bru_pipeline DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),


	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // full
		.BRU_RS_full(DUT_BRU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(tb_dispatch_unit_task_valid),
		.dispatch_unit_task_struct(tb_dispatch_unit_task_struct),
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
		.reg_file_read_req_valid(DUT_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(DUT_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(DUT_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(tb_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(tb_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(tb_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

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
		.complete_bus_2_data(tb_complete_bus_2_data),

	    // complete output to ROB
		.this_complete_valid(DUT_this_complete_valid),

	    // restart output to ROB
		.this_restart_valid(DUT_this_restart_valid),
		.this_restart_ROB_index(DUT_this_restart_ROB_index),
		.this_restart_PC(DUT_this_restart_PC),
		.this_restart_safe_column(DUT_this_restart_safe_column),

	    // BTB/DIRP updates to fetch_unit
		.this_BTB_DIRP_update(DUT_this_BTB_DIRP_update),
		.this_BTB_DIRP_index(DUT_this_BTB_DIRP_index),
		.this_BTB_target(DUT_this_BTB_target),
		.this_DIRP_taken(DUT_this_DIRP_taken)
	);

	`else
	bru_pipeline DUT (
		// seq
		.CLK(CLK),
		.nRST(nRST),


	    // DUT error
		.DUT_error(DUT_DUT_error),

	    // full
		.BRU_RS_full(DUT_BRU_RS_full),

	    // dispatch unit interface
		.dispatch_unit_task_valid(tb_dispatch_unit_task_valid),
		// .dispatch_unit_task_struct(tb_dispatch_unit_task_struct),
			// typedef struct packed {
			//     // BRU needs
			//     BRU_op_t op;
			//     source_reg_status_t source_0;
			//     source_reg_status_t source_1;
			//     logic [15:0] imm16;
			//     pc_t PC;    // will use to grab PC bits for BTB/DIRP index and do branch add ((PC + 4) + imm16)
			//     pc_t nPC;   // PC taken to check against
			//     // save/restore info
			//     checkpoint_column_t checkpoint_safe_column;
			//     // admin
			//     ROB_index_t ROB_index;
			// } BRU_RS_input_struct_t;

		.\dispatch_unit_task_struct.op (tb_dispatch_unit_task_struct.op),
		.\dispatch_unit_task_struct.source_0.needed (tb_dispatch_unit_task_struct.source_0.needed),
		.\dispatch_unit_task_struct.source_0.ready (tb_dispatch_unit_task_struct.source_0.ready),
		.\dispatch_unit_task_struct.source_0.phys_reg_tag (tb_dispatch_unit_task_struct.source_0.phys_reg_tag),
		.\dispatch_unit_task_struct.source_1.needed (tb_dispatch_unit_task_struct.source_1.needed),
		.\dispatch_unit_task_struct.source_1.ready (tb_dispatch_unit_task_struct.source_1.ready),
		.\dispatch_unit_task_struct.source_1.phys_reg_tag (tb_dispatch_unit_task_struct.source_1.phys_reg_tag),
		.\dispatch_unit_task_struct.imm16 (tb_dispatch_unit_task_struct.imm16),
		.\dispatch_unit_task_struct.PC (tb_dispatch_unit_task_struct.PC),
		.\dispatch_unit_task_struct.nPC (tb_dispatch_unit_task_struct.nPC),
		.\dispatch_unit_task_struct.checkpoint_safe_column (tb_dispatch_unit_task_struct.checkpoint_safe_column),
		.\dispatch_unit_task_struct.ROB_index (tb_dispatch_unit_task_struct.ROB_index),

	    // reg file read req interface
		.reg_file_read_req_valid(DUT_reg_file_read_req_valid),
		.reg_file_read_req_0_tag(DUT_reg_file_read_req_0_tag),
		.reg_file_read_req_1_tag(DUT_reg_file_read_req_1_tag),
		.reg_file_read_req_serviced(tb_reg_file_read_req_serviced),
		.reg_file_read_bus_0_data(tb_reg_file_read_bus_0_data),
		.reg_file_read_bus_1_data(tb_reg_file_read_bus_1_data),

	    // kill bus interface
		.kill_bus_valid(tb_kill_bus_valid),
		.kill_bus_ROB_index(tb_kill_bus_ROB_index),

	    // complete bus interface:

	    // input side (take from any 3 buses):

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
		.complete_bus_2_data(tb_complete_bus_2_data),

	    // complete output to ROB
		.this_complete_valid(DUT_this_complete_valid),

	    // restart output to ROB
		.this_restart_valid(DUT_this_restart_valid),
		.this_restart_ROB_index(DUT_this_restart_ROB_index),
		.this_restart_PC(DUT_this_restart_PC),
		.this_restart_safe_column(DUT_this_restart_safe_column),

	    // BTB/DIRP updates to fetch_unit
		.this_BTB_DIRP_update(DUT_this_BTB_DIRP_update),
		.this_BTB_DIRP_index(DUT_this_BTB_DIRP_index),
		.this_BTB_target(DUT_this_BTB_target),
		.this_DIRP_taken(DUT_this_DIRP_taken)
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

		if (expected_BRU_RS_full !== DUT_BRU_RS_full) begin
			$display("TB ERROR: expected_BRU_RS_full (%h) != DUT_BRU_RS_full (%h)",
				expected_BRU_RS_full, DUT_BRU_RS_full);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_valid !== DUT_reg_file_read_req_valid) begin
			$display("TB ERROR: expected_reg_file_read_req_valid (%h) != DUT_reg_file_read_req_valid (%h)",
				expected_reg_file_read_req_valid, DUT_reg_file_read_req_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_0_tag !== DUT_reg_file_read_req_0_tag) begin
			$display("TB ERROR: expected_reg_file_read_req_0_tag (%d) != DUT_reg_file_read_req_0_tag (%d)",
				expected_reg_file_read_req_0_tag, DUT_reg_file_read_req_0_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_reg_file_read_req_1_tag !== DUT_reg_file_read_req_1_tag) begin
			$display("TB ERROR: expected_reg_file_read_req_1_tag (%d) != DUT_reg_file_read_req_1_tag (%d)",
				expected_reg_file_read_req_1_tag, DUT_reg_file_read_req_1_tag);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_complete_valid !== DUT_this_complete_valid) begin
			$display("TB ERROR: expected_this_complete_valid (%h) != DUT_this_complete_valid (%h)",
				expected_this_complete_valid, DUT_this_complete_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_restart_valid !== DUT_this_restart_valid) begin
			$display("TB ERROR: expected_this_restart_valid (%h) != DUT_this_restart_valid (%h)",
				expected_this_restart_valid, DUT_this_restart_valid);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_restart_ROB_index !== DUT_this_restart_ROB_index) begin
			$display("TB ERROR: expected_this_restart_ROB_index (%d) != DUT_this_restart_ROB_index (%d)",
				expected_this_restart_ROB_index, DUT_this_restart_ROB_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_restart_PC !== DUT_this_restart_PC) begin
			$display("TB ERROR: expected_this_restart_PC (0x%h) != DUT_this_restart_PC (0x%h)",
				expected_this_restart_PC, DUT_this_restart_PC);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_restart_safe_column !== DUT_this_restart_safe_column) begin
			$display("TB ERROR: expected_this_restart_safe_column (%h) != DUT_this_restart_safe_column (%h)",
				expected_this_restart_safe_column, DUT_this_restart_safe_column);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_BTB_DIRP_update !== DUT_this_BTB_DIRP_update) begin
			$display("TB ERROR: expected_this_BTB_DIRP_update (%h) != DUT_this_BTB_DIRP_update (%h)",
				expected_this_BTB_DIRP_update, DUT_this_BTB_DIRP_update);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_BTB_DIRP_index !== DUT_this_BTB_DIRP_index) begin
			$display("TB ERROR: expected_this_BTB_DIRP_index (0x%h) != DUT_this_BTB_DIRP_index (0x%h)",
				expected_this_BTB_DIRP_index, DUT_this_BTB_DIRP_index);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_BTB_target !== DUT_this_BTB_target) begin
			$display("TB ERROR: expected_this_BTB_target (0x%h) != DUT_this_BTB_target (0x%h)",
				expected_this_BTB_target, DUT_this_BTB_target);
			num_errors++;
			tb_error = 1'b1;
		end

		if (expected_this_DIRP_taken !== DUT_this_DIRP_taken) begin
			$display("TB ERROR: expected_this_DIRP_taken (%h) != DUT_this_DIRP_taken (%h)",
				expected_this_DIRP_taken, DUT_this_DIRP_taken);
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
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(0);
        tb_dispatch_unit_task_struct.nPC = pc_t'(0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(0);
		expected_this_restart_PC = pc_t'(1); // default is PC + 4
		expected_this_restart_safe_column = checkpoint_column_t'(0);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(0);
		expected_this_BTB_target = pc_t'(1); // default is PC + 4
		expected_this_DIRP_taken = 1'b1; // nop is 1

		check_outputs();

        // inputs:
        sub_test_case = "deassert reset";
        $display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(0);
        tb_dispatch_unit_task_struct.nPC = pc_t'(0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(posedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(0);
		expected_this_restart_PC = pc_t'(1); // default is PC + 4
		expected_this_restart_safe_column = checkpoint_column_t'(0);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(0);
		expected_this_BTB_target = pc_t'(1); // default is PC + 4
		expected_this_DIRP_taken = 1'b1; // nop is 1

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
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(0);
        tb_dispatch_unit_task_struct.nPC = pc_t'(0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(0);
		expected_this_restart_PC = pc_t'(1); // default is PC + 4
		expected_this_restart_safe_column = checkpoint_column_t'(0);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(0);
		expected_this_BTB_target = pc_t'(1); // default is PC + 4
		expected_this_DIRP_taken = 1'b1; // nop is 1

		check_outputs();

		///////////////////////////////////////////////////////////////////////////////////////////////////
        // instr stream:
        test_case = "instr stream";
        $display("\ntest %d: %s", test_num, test_case);
        test_num++;

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 0|0: BEQ 0 ready, 1 ready [taken, should take] (0, 1, 0x0123)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(0);
        tb_dispatch_unit_task_struct.nPC = pc_t'(0 + 1 + 16'h0123);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(0);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(0);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(0);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(0);
		expected_this_restart_PC = pc_t'(1); // default is PC + 4
		expected_this_restart_safe_column = checkpoint_column_t'(0);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(0);
		expected_this_BTB_target = pc_t'(1); // default is PC + 4
		expected_this_DIRP_taken = 1'b1; // nop is 1

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 1|0123: BEQ 0 ready, 1 on bus [taken, should not take] (1, 2, 0x1234)", "\n\t\t",
			" | RS: 0|0: BEQ 0 ready, 1 ready [taken, should take] (0, 1, 0x0123)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0123);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0123 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(1);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'habababab;
		tb_reg_file_read_bus_1_data = 32'habababab;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(1);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(0);
		expected_this_restart_PC = pc_t'(1); // default is PC + 4
		expected_this_restart_safe_column = checkpoint_column_t'(0);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(0);
		expected_this_BTB_target = pc_t'(1); // default is PC + 4
		expected_this_DIRP_taken = 1'b1; // nop is 1

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 1|0123: BEQ 0 ready, 1 on bus [taken, should not take] (1, 2, 0x1234)", "\n\t\t",
			" | EX: 0|0: BEQ 0 ready, 1 ready [taken, should take] (0, 1, 0x0123)", "\n\t\t",
			" | complete: reg 2 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0123);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0123 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(1);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(1);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'hddddcccc;
		tb_reg_file_read_bus_1_data = 32'hccccdddd;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(2);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(1);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(2);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(0);
		expected_this_restart_PC = pc_t'(0 + 1 + 16'h0123);
		expected_this_restart_safe_column = checkpoint_column_t'(0);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(0);
		expected_this_BTB_target = pc_t'(0 + 1 + 16'h0123); // default is PC + 4
		expected_this_DIRP_taken = 1'b1; // nop is 1

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 3|1234: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 1|0123: BEQ 0 ready, 1 on bus [taken, should not take] (1, 2, 0x1234)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'hdead;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h1234);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hccccdddd;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(1);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(2);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(1);
		expected_this_restart_PC = pc_t'(0 + 1 + 16'h0123);
		expected_this_restart_safe_column = checkpoint_column_t'(1);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0123);
		expected_this_BTB_target = pc_t'(16'h0123 + 1 + 16'h1234);
		expected_this_DIRP_taken = 1'b0; // nop is 1

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 3|1234: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: 2"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'hdead;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h1234);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(2);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(40);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(1);
		expected_this_restart_PC = pc_t'(16'h0123 + 1 + 16'h1234);
		expected_this_restart_safe_column = checkpoint_column_t'(1);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0123);
		expected_this_BTB_target = pc_t'(16'h0123 + 1 + 16'h1234);
		expected_this_DIRP_taken = 1'b1; // nop is 1

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 2|0124: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | RS: 3|1234: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 40 on bus 1", "\n\t\t",
			" | kill: 3"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.imm16 = 16'h2345;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0124);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0125);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(2);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(2);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(3);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;	// random
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(40);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;	// random
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(40);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(3);
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(3);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h34); // given
		expected_this_BTB_target = pc_t'(16'h30e2);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 3|0125: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | RS: (STALL) 2|0124: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: 4"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0125);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0126);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1; // random
		tb_kill_bus_ROB_index = ROB_index_t'(4);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hffffffff;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(3);
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(3);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h34); // given
		expected_this_BTB_target = pc_t'(16'h30e2);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 3|0125: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | RS: FAIL READ 2|0124: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 3 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0125);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0126);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hffffffff;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(3);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(2); // given
		expected_this_restart_PC = pc_t'(16'h0124 + 1 + 16'h2345); // given
		expected_this_restart_safe_column = checkpoint_column_t'(2);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0124); // given
		expected_this_BTB_target = pc_t'(16'h0124 + 1 + 16'h2345);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 3|0125: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | RS: 2|0124: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0125);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0126);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'habcdef01;
		tb_reg_file_read_bus_1_data = 32'habcdef01;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_data = 32'habcdef01;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(2); // given
		expected_this_restart_PC = pc_t'(16'h0124 + 1 + 16'h2345); // given
		expected_this_restart_safe_column = checkpoint_column_t'(2);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0124); // given
		expected_this_BTB_target = pc_t'(16'h0124 + 1 + 16'h2345);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 3|0125: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | EX: 2|0124: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | complete: 20 on bus 2", "\n\t\t",
			" | kill: 3"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0125);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0126);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'habcdef01;
		tb_reg_file_read_bus_1_data = 32'habcdef01;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(3);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(20);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(2); // given
		expected_this_restart_PC = pc_t'(16'h0124 + 1 + 16'h2345); // given
		expected_this_restart_safe_column = checkpoint_column_t'(2);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0124); // given
		expected_this_BTB_target = pc_t'(16'h0124 + 1 + 16'h2345);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 3|2345: BEQ 0 on bus, 1 ready [not taken, should not take] (3, 4, 0x3456)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_task_struct.imm16 = 16'h3456;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h2345);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h2346);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_data = 32'ha5a55a5a;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(20);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(3); // given
		expected_this_restart_PC = pc_t'(16'h3bc0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(3);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0125); // given
		expected_this_BTB_target = pc_t'(16'h0125 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 3|2345: BEQ 0 on bus, 1 ready [not taken, should not take] (3, 4, 0x3456)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 0 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_task_struct.imm16 = 16'h3456;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h2345);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h2346);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(3);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(3);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h0;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(3);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(3);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(4);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(3); // given
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(3);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h0125); // given
		expected_this_BTB_target = pc_t'(16'h0125 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 5|2346: BEQ 0 stall then on bus, 1 ready [taken, should take] (4, 5, 0x4567)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 3|2345: BEQ 0 on bus, 1 ready [not taken, should not take] (3, 4, 0x3456)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.imm16 = 16'h4567;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h2346);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h2346 + 1 + 16'h4567);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(5);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(5);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h1;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(3);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(4);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(3); // given
		expected_this_restart_PC = pc_t'(16'h2346); // given
		expected_this_restart_safe_column = checkpoint_column_t'(3);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h2345); // given
		expected_this_BTB_target = pc_t'(16'h2345 + 1 + 16'h3456);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 6|4567: BEQ 0 on bus, 1 on bus [taken, should not take] (5, 6, 0x5678)", "\n\t\t",
			" | RS: (STALL) 5|2346: BEQ 0 stall then on bus, 1 ready [taken, should take] (4, 5, 0x4567)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_task_struct.imm16 = 16'h5678;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4567);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4567 + 1 + 16'h5678);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(6);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(6);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(4);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(5);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(3); // given
		expected_this_restart_PC = pc_t'(16'h2345 + 1 + 16'h3456); // given
		expected_this_restart_safe_column = checkpoint_column_t'(3);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h2345); // given
		expected_this_BTB_target = pc_t'(16'h2345 + 1 + 16'h3456);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 6|4567: BEQ 0 on bus, 1 on bus [taken, should not take] (5, 6, 0x5678)", "\n\t\t",
			" | RS: 5|2346: BEQ 0 stall then on bus, 1 ready [taken, should take] (4, 5, 0x4567)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 4 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(5);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_task_struct.imm16 = 16'h5678;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4567);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4567 + 1 + 16'h5678);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(6);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(6);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'h1;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(4);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(4);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(5);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(5); // given
		expected_this_restart_PC = pc_t'(16'h2346 + 1 + 16'h4567); // given
		expected_this_restart_safe_column = checkpoint_column_t'(5);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h2346); // given
		expected_this_BTB_target = pc_t'(16'h2346 + 1 + 16'h4567);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 7|5678: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | RS: 6|4567: BEQ 0 on bus, 1 on bus [taken, should not take] (5, 6, 0x5678)", "\n\t\t",
			" | EX: 5|2346: BEQ 0 stall then on bus, 1 ready [taken, should take] (4, 5, 0x4567)", "\n\t\t",
			" | complete: 5 on bus 2, 6 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5678);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hbeef);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(7);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(6);
		tb_complete_bus_0_data = 32'h1;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(5);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(5);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(6);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(5); // given
		expected_this_restart_PC = pc_t'(16'h2346 + 1 + 16'h4567); // given
		expected_this_restart_safe_column = checkpoint_column_t'(5);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h2346); // given
		expected_this_BTB_target = pc_t'(16'h2346 + 1 + 16'h4567);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 7|5678: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | EX: 6|4567: BEQ 0 on bus, 1 on bus [taken, should not take] (5, 6, 0x5678)", "\n\t\t",
			" | complete: 5 on bus 2, 6 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5678);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hbeef);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(7);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h0;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h1;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(6); // given
		expected_this_restart_PC = pc_t'(16'h4567 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(6);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h4567); // given
		expected_this_BTB_target = pc_t'(16'h4567 + 1 + 16'h5678);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 7|4568: BEQ 0 on bus, 1 stall then on bus [not taken, should take] (6, 7, 0x6789)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 7|5678: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: kill 7 (too late)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(6);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(7);
        tb_dispatch_unit_task_struct.imm16 = 16'h6789;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4568);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4569);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(7);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(7);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(7); // given
		expected_this_restart_PC = pc_t'(16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(7);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h5678); // given
		expected_this_BTB_target = pc_t'(16'h5678 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 8|4569: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | RS: (STALL) 7|4568: BEQ 0 on bus, 1 stall then on bus [not taken, should take] (6, 7, 0x6789)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 6 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4569);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4569 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(8);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(8);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(6);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(6);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(7);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(7); // given
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(7);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h5678); // given
		expected_this_BTB_target = pc_t'(16'h5678 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 8|4569: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | RS: 7|4568: BEQ 0 on bus, 1 stall then on bus [not taken, should take] (6, 7, 0x6789)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 7 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4569);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4569 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(8);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(8);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h66666666;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(7);
		tb_complete_bus_1_data = 32'h66666666;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(6);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(7);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(7); // given
		expected_this_restart_PC = pc_t'(16'h4568 + 1 + 16'h6789); // given
		expected_this_restart_safe_column = checkpoint_column_t'(7);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h4568); // given
		expected_this_BTB_target = pc_t'(16'h4568 + 1 + 16'h6789);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 8|4569: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | EX: 7|4568: BEQ 0 on bus, 1 stall then on bus [not taken, should take] (6, 7, 0x6789)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4569);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4569 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(8);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(8);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h66666666;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(17);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(18);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(7); // given
		expected_this_restart_PC = pc_t'(16'h4568 + 1 + 16'h6789); // given
		expected_this_restart_safe_column = checkpoint_column_t'(7);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h4568); // given
		expected_this_BTB_target = pc_t'(16'h4568 + 1 + 16'h6789);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 8|4569: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 18 on bus 0, 17 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h4569);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h4569 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(8);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(8);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(18);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(17);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(17);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(18);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(8); // given
		expected_this_restart_PC = pc_t'(16'h4569 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(8);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h4569); // given
		expected_this_BTB_target = pc_t'(16'h4569 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 10|6789: BEQ 0 stall then on bus, 1 on bus [not taken, should not take] (7, 8, 0x789A)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 8|4569: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: 8 (too late)"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(7);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_task_struct.imm16 = 16'h789A;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h6789);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h6789 + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(10);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(10);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(8);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h10101010;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h02020202;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(17);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(18);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(8); // given
		expected_this_restart_PC = pc_t'(16'h4569 + 1 + 16'h1234); // given
		expected_this_restart_safe_column = checkpoint_column_t'(8);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h4569); // given
		expected_this_BTB_target = pc_t'(16'h4569 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 11|678A: BEQ 0 stall then on bus, 1 stall then on bus [taken, should take] (8, 9, 0x89AB)", "\n\t\t",
			" | RS: (STALL) 10|6789: BEQ 0 stall then on bus, 1 on bus [not taken, should not take] (7, 8, 0x789A)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 8 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(9);
        tb_dispatch_unit_task_struct.imm16 = 16'h678A;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h678A);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h678A + 1 + 16'h89AB);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(11);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(11);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_tag = phys_reg_tag_t'(8);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(7);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(8);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(8); // given
		expected_this_restart_PC = pc_t'(16'h056A); // given
		expected_this_restart_safe_column = checkpoint_column_t'(8);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h4569); // given
		expected_this_BTB_target = pc_t'(16'h4569 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 11|678A: BEQ 0 stall then on bus, 1 stall then on bus [taken, should take] (8, 9, 0x89AB)", "\n\t\t",
			" | RS: 10|6789: BEQ 0 stall then on bus, 1 on bus [not taken, should not take] (7, 8, 0x789A)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 7 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(8);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(9);
        tb_dispatch_unit_task_struct.imm16 = 16'h89AB;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h678A);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h678A + 1 + 16'h89AB);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(11);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(11);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h01010101;
		tb_reg_file_read_bus_1_data = 32'h01010101;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_data = 32'h01010101;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(7);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(8);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(10); // given
		expected_this_restart_PC = pc_t'(16'h6789 + 1 + 16'h789A); // given
		expected_this_restart_safe_column = checkpoint_column_t'(10);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h6789); // given
		expected_this_BTB_target = pc_t'(16'h6789 + 1 + 16'h789A);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 12|89AB: BNE 0 ready, 1 ready [taken, should take] (9, 10, 0x9ABC)", "\n\t\t",
			" | RS: (STALL) 11|678A: BEQ 0 stall then on bus, 1 stall then on bus [taken, should take] (8, 9, 0x89AB)", "\n\t\t",
			" | EX: 10|6789: BEQ 0 stall then on bus, 1 on bus [not taken, should not take] (7, 8, 0x789A)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(9);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(10);
        tb_dispatch_unit_task_struct.imm16 = 16'h9ABC;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h89AB);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h89AB + 1 + 16'h9ABC);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(12);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(12);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h10101010;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(8);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(9);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(10); // given
		expected_this_restart_PC = pc_t'(16'h6789 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(10);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h6789); // given
		expected_this_BTB_target = pc_t'(16'h6789 + 1 + 16'h789A);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 12|89AB: BNE 0 ready, 1 ready [taken, should take] (9, 10, 0x9ABC)", "\n\t\t",
			" | RS: 11|678A: BEQ 0 stall then on bus, 1 stall then on bus [taken, should take] (8, 9, 0x89AB)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 8 on bus 1, 9 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(9);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(10);
        tb_dispatch_unit_task_struct.imm16 = 16'h9ABC;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h89AB);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h89AB + 1 + 16'h9ABC);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(12);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(12);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(8);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(9);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(8);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(9);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(11); // given
		expected_this_restart_PC = pc_t'(16'h678A + 1 + 16'h89AB); // given
		expected_this_restart_safe_column = checkpoint_column_t'(11);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h678A); // given
		expected_this_BTB_target = pc_t'(16'h678A + 1 + 16'h89AB);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 13|9ABC: BNE 0 ready, 1 on bus [taken, should not take] (10, 11, 0xABCD)", "\n\t\t",
			" | RS: 12|89AB: BNE 0 ready, 1 ready [taken, should take] (9, 10, 0x9ABC)", "\n\t\t",
			" | EX: 11|678A: BEQ 0 stall then on bus, 1 stall then on bus [taken, should take] (8, 9, 0x89AB)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(10);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(11);
        tb_dispatch_unit_task_struct.imm16 = 16'hABCD;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h9ABC);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h9ABC + 1 + 16'hABCD);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(13);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(13);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'hffffffff;
		tb_reg_file_read_bus_1_data = 32'h00000000;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h01234567;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h01234567;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(9);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(10);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(11); // given
		expected_this_restart_PC = pc_t'(16'h678A + 1 + 16'h89AB); // given
		expected_this_restart_safe_column = checkpoint_column_t'(11);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h678A); // given
		expected_this_BTB_target = pc_t'(16'h678A + 1 + 16'h89AB);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 14|ABCD: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | RS: 13|9ABC: BNE 0 ready, 1 on bus [taken, should not take] (10, 11, 0xABCD)", "\n\t\t",
			" | EX: 12|89AB: BNE 0 ready, 1 ready [taken, should take] (9, 10, 0x9ABC)", "\n\t\t",
			" | complete: 11 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hABCD);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hABCD + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(14);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(14);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h89ABCDEF;
		tb_reg_file_read_bus_1_data = 32'h01234567;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(11);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h89ABCDEF;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h01234567;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(10);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(11);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(12); // given
		expected_this_restart_PC = pc_t'(16'h89AB + 1 + 16'h9ABC); // given
		expected_this_restart_safe_column = checkpoint_column_t'(12);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h89AB); // given
		expected_this_BTB_target = pc_t'(16'h89AB + 1 + 16'h9ABC);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: (STALL) 14|ABCD: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | EX: 13|9ABC: BNE 0 ready, 1 on bus [taken, should not take] (10, 11, 0xABCD)", "\n\t\t",
			" | complete: 17 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hABCD);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hABCD + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(14);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(14);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h89ABCDEF;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(17);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(16);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(17);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(13); // given
		expected_this_restart_PC = pc_t'(16'h9ABC + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(13);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h9ABC); // given
		expected_this_BTB_target = pc_t'(16'h9ABC + 1 + 16'hABCD);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 14|9ABD: BNE 0 ready, 1 stall then on bus [not taken, should take] (11, 12, 0xBCDE)", "\n\t\t",
			" | RS: 14|ABCD: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 16 on bus 0", "\n\t\t",
			" | kill: 14"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(11);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(12);
        tb_dispatch_unit_task_struct.imm16 = 16'hBCDE;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h9ABD);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h9ABD + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(14);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(14);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(14);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h00002222;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(16);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(17);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(14); // given
		expected_this_restart_PC = pc_t'(16'hABCD + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(14);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hABCD); // given
		expected_this_BTB_target = pc_t'(16'hABCD + 1 + 16'h0123);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 15|9ABE: BEQ 0 ready, 1 ready [taken, should take] (0, 1, 0x0123)", "\n\t\t",
			" | RS: (STALL) 14|9ABD: BNE 0 ready, 1 stall then on bus [not taken, should take] (11, 12, 0xBCDE)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h9ABE);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h9ABE + 1 + 16'h0123);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(15);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(15);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(11);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(12);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(14); // given
		expected_this_restart_PC = pc_t'(16'hABCD + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(14);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hABCD); // given
		expected_this_BTB_target = pc_t'(16'hABCD + 1 + 16'h0123);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 15|9ABE: BEQ 0 ready, 1 ready [taken, should take] (0, 1, 0x0123)", "\n\t\t",
			" | RS: 14|9ABD: BNE 0 ready, 1 stall then on bus [not taken, should take] (11, 12, 0xBCDE)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 12 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h9ABE);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h9ABE + 1 + 16'h0123);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(15);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(15);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h11111111;
		tb_reg_file_read_bus_1_data = 32'h11111111;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_tag = phys_reg_tag_t'(12);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(11);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(12);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(14); // given
		expected_this_restart_PC = pc_t'(16'h9ABD + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(14);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h9ABD); // given
		expected_this_BTB_target = pc_t'(16'h9ABD + 1 + 16'hBCDE);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 15|9ABE: BEQ 0 ready, 1 ready [taken, should take] (0, 1, 0x0123)", "\n\t\t",
			" | EX: 14|9ABD: BNE 0 ready, 1 stall then on bus [not taken, should take] (11, 12, 0xBCDE)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: 15"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h9ABE);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h9ABE + 1 + 16'h0123);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(15);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(15);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(15);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_data = 32'h22222222;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(1);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(14); // given
		expected_this_restart_PC = pc_t'(16'h9ABD + 1 + 16'hBCDE); // given
		expected_this_restart_safe_column = checkpoint_column_t'(14);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h9ABD); // given
		expected_this_BTB_target = pc_t'(16'h9ABD + 1 + 16'hBCDE);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 15|BCDE: BNE 0 on bus, 1 ready [not taken, should not take] (12, 13, 0xCDEF)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(12);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_task_struct.imm16 = 16'hCDEF;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hBCDE);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hBCDE + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(15);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(15);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(1);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(15); // given
		expected_this_restart_PC = pc_t'(16'h9ABE + 1 + 16'h0123); // given
		expected_this_restart_safe_column = checkpoint_column_t'(15);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h9ABE); // given
		expected_this_BTB_target = pc_t'(16'h9ABE + 1 + 16'h0123);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 15|BCDE: BNE 0 on bus, 1 ready [not taken, should not take] (12, 13, 0xCDEF)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 12 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(12);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_task_struct.imm16 = 16'hCDEF;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hBCDE);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hBCDE + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(15);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(15);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h05050505;
		tb_reg_file_read_bus_1_data = 32'h05050505;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(12);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(12);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(13);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(15); // given
		expected_this_restart_PC = pc_t'(16'h9ABE + 1 + 16'h0123); // given
		expected_this_restart_safe_column = checkpoint_column_t'(15);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h9ABE); // given
		expected_this_BTB_target = pc_t'(16'h9ABE + 1 + 16'h0123);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 18|BCDF: BNE 0 stall then on bus, 1 ready [take, should take] (13, 14, 0xDEF0)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 15|BCDE: BNE 0 on bus, 1 ready [not taken, should not take] (12, 13, 0xCDEF)", "\n\t\t",
			" | complete: 99 on bus 1 (misc)", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_task_struct.imm16 = 16'hDEF0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hBCDF);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hBCDF + 1 + 16'hDEF0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(18);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(18);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1; // misc complete
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h05050505;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(12);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(13);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(15); // given
		expected_this_restart_PC = pc_t'(16'hBCDE + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(15);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hBCDE); // given
		expected_this_BTB_target = pc_t'(16'hBCDE + 1 + 16'hCDEF);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: (STALL) 18|BCDF: BNE 0 stall then on bus, 1 ready [take, should take] (13, 14, 0xDEF0)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(13);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_task_struct.imm16 = 16'hDEF0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hBCDF);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hBCDF + 1 + 16'hDEF0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(18);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(18);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(13);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(14);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(15); // given
		expected_this_restart_PC = pc_t'(16'hBCDE + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(15);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hBCDE); // given
		expected_this_BTB_target = pc_t'(16'hBCDE + 1 + 16'hCDEF);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 20|DEF0: BNE 0 on bus, 1 on bus [taken, should not take] (14, 15, 0xEF01)", "\n\t\t",
			" | RS: 18|BCDF: BNE 0 stall then on bus, 1 ready [take, should take] (13, 14, 0xDEF0)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 13 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(15);
        tb_dispatch_unit_task_struct.imm16 = 16'hEF01;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hDEF0);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hDEF0 + 1 + 16'hEF01);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(20);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(20);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h77777777;
		tb_reg_file_read_bus_1_data = 32'h77777777;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(13);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(13);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(14);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(18); // given
		expected_this_restart_PC = pc_t'(16'hBCDF + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(18);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hBCDF); // given
		expected_this_BTB_target = pc_t'(16'hBCDF + 1 + 16'hDEF0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 20|DEF0: BNE 0 on bus, 1 on bus [taken, should not take] (14, 15, 0xEF01)", "\n\t\t",
			" | EX: 18|BCDF: BNE 0 stall then on bus, 1 ready [take, should take] (13, 14, 0xDEF0)", "\n\t\t",
			" | complete: 15 on bus 1, 14 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(14);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(15);
        tb_dispatch_unit_task_struct.imm16 = 16'hEF01;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hDEF0);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hDEF0 + 1 + 16'hEF01);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(20);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(20);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h88888888;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(15);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(14);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(14);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(15);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(18); // given
		expected_this_restart_PC = pc_t'(16'hBCDF + 1 + 16'hDEF0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(18);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hBCDF); // given
		expected_this_BTB_target = pc_t'(16'hBCDF + 1 + 16'hDEF0);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 22|EF01: BEQ 0 ready, 1 on bus [taken, should not take] (1, 2, 0x1234)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 20|DEF0: BNE 0 on bus, 1 on bus [taken, should not take] (14, 15, 0xEF01)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hEF01);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hEF01 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(22);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(22);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h01928374;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h01928374;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(14);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(15);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(20); // given
		expected_this_restart_PC = pc_t'(16'hDEF0 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(20);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hDEF0); // given
		expected_this_BTB_target = pc_t'(16'hDEF0 + 1 + 16'hEF01);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 22|EF01: BEQ 0 ready, 1 on bus [taken, should not take] (1, 2, 0x1234)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 2 on bus 1", "\n\t\t",
			" | kill: 22"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hEF01);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hEF01 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(22);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(22);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h1;
		tb_reg_file_read_bus_1_data = 32'h1;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(22);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(2);
		tb_complete_bus_1_data = 32'h1;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(1);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(2);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(20); // given
		expected_this_restart_PC = pc_t'(16'hDEF0 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(20);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hDEF0); // given
		expected_this_BTB_target = pc_t'(16'hDEF0 + 1 + 16'hEF01);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(1);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hEF01);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hEF01 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(22);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(22);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(22);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h0;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(1);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(2);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(22); // given
		expected_this_restart_PC = pc_t'(16'hEF01 + 1 + 16'h1234); // given
		expected_this_restart_safe_column = checkpoint_column_t'(22);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hEF01); // given
		expected_this_BTB_target = pc_t'(16'hEF01 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 23|DEF1: BNE 0 on bus, 1 stall then on bus [not taken, should take] (15, 16, 0xF012)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(15);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_task_struct.imm16 = 16'hF012;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hDEF1);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hDEF1 + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(23);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(23);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(23);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(1);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(2);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(22); // given
		expected_this_restart_PC = pc_t'(16'hEF01 + 1 + 16'h1234); // given
		expected_this_restart_safe_column = checkpoint_column_t'(22);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hEF01); // given
		expected_this_BTB_target = pc_t'(16'hEF01 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 24|DEF2: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | RS: (STALL) 23|DEF1: BNE 0 on bus, 1 stall then on bus [not taken, should take] (15, 16, 0xF012)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 15 on bus 1", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.imm16 = 16'h2345;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hDEF2);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hDEF2 + 1 + 16'h2345);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(24);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(24);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(23);	// hesi
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(15);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(16);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(22); // given
		expected_this_restart_PC = pc_t'(16'hEF01 + 1 + 16'h1234); // given
		expected_this_restart_safe_column = checkpoint_column_t'(22);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hEF01); // given
		expected_this_BTB_target = pc_t'(16'hEF01 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 24|DEF2: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | RS: 23|DEF1: BNE 0 on bus, 1 stall then on bus [not taken, should take] (15, 16, 0xF012)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 16 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.imm16 = 16'h2345;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hDEF2);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hDEF2 + 1 + 16'h2345);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(24);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(24);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0000dead;
		tb_reg_file_read_bus_1_data = 32'h0000dead;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(23);	// hesi
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(16);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h0000dead;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(15);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(16);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(23); // given
		expected_this_restart_PC = pc_t'(16'hDEF1 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(23);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hDEF1); // given
		expected_this_BTB_target = pc_t'(16'hDEF1 + 1 + 16'hF012);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 24|DEF2: (STALL) BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | EX: 23|DEF1: BNE 0 on bus, 1 stall then on bus [not taken, should take] (15, 16, 0xF012)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(2);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.imm16 = 16'h2345;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hDEF2);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hDEF2 + 1 + 16'h2345);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(24);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(24);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(23);	// hesi
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h0000beef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(23); // given
		expected_this_restart_PC = pc_t'(16'hDEF1 + 1 + 16'hF012); // given
		expected_this_restart_safe_column = checkpoint_column_t'(23);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hDEF1); // given
		expected_this_BTB_target = pc_t'(16'hDEF1 + 1 + 16'hF012);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 24|F012: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | RS: 24|DEF2: BEQ 0 ready, 1 stall then on bus [not taken, should take] (2, 3, 0x2345)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: 24"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(16);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.imm16 = 16'h0123;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hF012);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hF012 + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(24);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(24);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(24);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(2);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(3);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(24); // given
		expected_this_restart_PC = pc_t'(16'hDEF2 + 1 + 16'h2345); // given
		expected_this_restart_safe_column = checkpoint_column_t'(24);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hDEF2); // given
		expected_this_BTB_target = pc_t'(16'hDEF2 + 1 + 16'h2345);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 25|F013: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | RS: (STALL) 24|F012: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 17 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hF013);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hF013 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(25);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(25);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(24); // hesi
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(17);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(16);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(17);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(24); // given
		expected_this_restart_PC = pc_t'(16'hDEF2 + 1 + 16'h2345); // given
		expected_this_restart_safe_column = checkpoint_column_t'(24);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hDEF2); // given
		expected_this_BTB_target = pc_t'(16'hDEF2 + 1 + 16'h2345);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 25|F013: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | RS: 24|F012: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 16 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BNE);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(17);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(18);
        tb_dispatch_unit_task_struct.imm16 = 16'h1234;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'hF013);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hF013 + 1 + 16'h1234);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(25);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(25);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0B0B0B0B;
		tb_reg_file_read_bus_1_data = 32'h0A0A0A0A;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(16);
		tb_complete_bus_0_data = 32'h0A0A0A0A;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(16);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(17);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(24); // given
		expected_this_restart_PC = pc_t'(16'hF012 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(24);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hF012); // given
		expected_this_BTB_target = pc_t'(16'hF012 + 1 + 16'h0123);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: (FAIL ENQUEUE) 26|1234: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | RS: (STALL) 25|F013: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | EX: 24|F012: BNE 0 stall then on bus, 1 on bus [not taken, should not take] (16, 17, 0x0123)", "\n\t\t",
			" | complete: 16 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h1234);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(26);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'h0A0A0A0A;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(17);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(18);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(24); // given
		expected_this_restart_PC = pc_t'(16'hF012 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(24);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hF012); // given
		expected_this_BTB_target = pc_t'(16'hF012 + 1 + 16'h0123);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 26|1234: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | RS: 25|F013: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 17 on bus 1, 18 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h1234);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(26);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b1;
		tb_complete_bus_1_tag = phys_reg_tag_t'(17);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(18);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(17);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(18);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(25); // given
		expected_this_restart_PC = pc_t'(16'hF013 + 1 + 16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(25);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hF013); // given
		expected_this_BTB_target = pc_t'(16'hF013 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 26|1234: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | EX: 25|F013: BNE 0 stall then on bus, 1 stall then on bus [taken, should take] (17, 18, 0x1234)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(0);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h1234);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(26);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(26);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b1;
		tb_reg_file_read_bus_0_data = 32'h0;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'h00000001;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'h00000002;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b1;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(25); // given
		expected_this_restart_PC = pc_t'(16'hF013 + 1 + 16'h1234); // given
		expected_this_restart_safe_column = checkpoint_column_t'(25);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b1;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'hF013); // given
		expected_this_BTB_target = pc_t'(16'hF013 + 1 + 16'h1234);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 28|0001: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 26|1234: JR 0 ready [correct addr] (0, 0x0000)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(20);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h0001);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h2222);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(28);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(28);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(0);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(26); // given
		expected_this_restart_PC = pc_t'(16'h0); // given
		expected_this_restart_safe_column = checkpoint_column_t'(26);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h1234); // given
		expected_this_BTB_target = pc_t'(16'h1234 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 29|2222: BEQ 0 on bus, 1 ready [not taken, should not take] (3, 4, 0x3456)", "\n\t\t",
			" | RS: 28|0001: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 20 on bus 0", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_BEQ);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(3);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(4);
        tb_dispatch_unit_task_struct.imm16 = 16'h3456;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h2222);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'h2222 + 1 + 16'h0);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(29);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(29);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b1;
		tb_complete_bus_0_tag = phys_reg_tag_t'(20);
		tb_complete_bus_0_data = 32'hdeadbeef;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b0;
		tb_complete_bus_2_tag = phys_reg_tag_t'(99);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(20);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(26); // given
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(26);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h1234); // given
		expected_this_BTB_target = pc_t'(16'h1234 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: 29|5a5a: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | RS: 29|2222: BEQ 0 on bus, 1 ready [not taken, should not take] (3, 4, 0x3456)", "\n\t\t",
			" | EX: 28|0001: JR 0 on bus [incorrect addr] (20, 0xa5a55a5a)", "\n\t\t",
			" | complete: 3 on bus 2", "\n\t\t",
			" | kill: 29"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b1;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5a5a);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(29);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(29);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b1;
		tb_kill_bus_ROB_index = ROB_index_t'(29);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'ha5a55a5a;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(3);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(3);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(4);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b1;
		expected_this_restart_ROB_index = ROB_index_t'(28); // given
		expected_this_restart_PC = pc_t'(16'h5a5a >> 2); // given
		expected_this_restart_safe_column = checkpoint_column_t'(28);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h01); // given
		expected_this_BTB_target = pc_t'(16'h01 + 1 + 16'h0);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: (STALL) 29|5a5a: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 3 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5a5a);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(29);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(29);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
		tb_complete_bus_0_tag_valid = 1'b0;
		tb_complete_bus_0_tag = phys_reg_tag_t'(99);
		tb_complete_bus_0_data = 32'ha5a55a5a;
	    // complete bus 1 (ALU 1)
		tb_complete_bus_1_tag_valid = 1'b0;
		tb_complete_bus_1_tag = phys_reg_tag_t'(99);
		tb_complete_bus_1_data = 32'hdeadbeef;
	    // complete bus 2 (LQ)
		tb_complete_bus_2_tag_valid = 1'b1;
		tb_complete_bus_2_tag = phys_reg_tag_t'(3);
		tb_complete_bus_2_data = 32'hdeadbeef;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b1;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(40);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(29); // given
		expected_this_restart_PC = pc_t'(16'h1679); // given
		expected_this_restart_safe_column = checkpoint_column_t'(29);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h22); // given
		expected_this_BTB_target = pc_t'(16'h1679);	// given
		expected_this_DIRP_taken = 1'b1; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: 29|5a5a: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: 40 on bus 2", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5a5a);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(29);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(29);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_tag = phys_reg_tag_t'(40);
		tb_complete_bus_2_data = 32'h01010101;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(40);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(29); // given
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(29);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h5a); // given
		expected_this_BTB_target = pc_t'(16'h1a5b);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: 29|5a5a: JR 0 stall then on bus [correct addr] (40, 0xffffffff)", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5a5a);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(29);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(29);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_data = 32'hffffffff;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(40);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b1;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(29); // given
		expected_this_restart_PC = pc_t'(16'hffff); // given
		expected_this_restart_safe_column = checkpoint_column_t'(29);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h5a); // given
		expected_this_BTB_target = pc_t'(16'h1a5b);	// given
		expected_this_DIRP_taken = 1'b0; // given

		check_outputs();

		@(posedge CLK);

		// inputs
		sub_test_case = {"\n\t\t",
			" | dispatch: nop", "\n\t\t",
			" | RS: nop", "\n\t\t",
			" | EX: nop", "\n\t\t",
			" | complete: none", "\n\t\t",
			" | kill: none"
		};
		$display("\t- sub_test: %s", sub_test_case);

		// reset
		nRST = 1'b1;
	    // DUT error
	    // full
	    // dispatch unit interface
		tb_dispatch_unit_task_valid = 1'b0;
		tb_dispatch_unit_task_struct.op = BRU_op_t'(BRU_JR);
        tb_dispatch_unit_task_struct.source_0.needed = 1'b1;
        tb_dispatch_unit_task_struct.source_0.ready = 1'b0;
        tb_dispatch_unit_task_struct.source_0.phys_reg_tag = phys_reg_tag_t'(40);
        tb_dispatch_unit_task_struct.source_1.needed = 1'b0;
        tb_dispatch_unit_task_struct.source_1.ready = 1'b1;
        tb_dispatch_unit_task_struct.source_1.phys_reg_tag = phys_reg_tag_t'(99);
        tb_dispatch_unit_task_struct.imm16 = 16'h0;
        tb_dispatch_unit_task_struct.PC = pc_t'(16'h5a5a);
        tb_dispatch_unit_task_struct.nPC = pc_t'(16'hffff);
        tb_dispatch_unit_task_struct.checkpoint_safe_column = checkpoint_column_t'(29);
        tb_dispatch_unit_task_struct.ROB_index = ROB_index_t'(29);
	    // reg file read req interface
		tb_reg_file_read_req_serviced = 1'b0;
		tb_reg_file_read_bus_0_data = 32'hdeadbeef;
		tb_reg_file_read_bus_1_data = 32'hdeadbeef;
	    // kill bus interface
		tb_kill_bus_valid = 1'b0;
		tb_kill_bus_ROB_index = ROB_index_t'(99);
	    // complete bus interface:
	    // input side (take from any 3 buses):
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
		tb_complete_bus_2_data = 32'hffffffff;
	    // complete output to ROB
	    // restart output to ROB
	    // BTB/DIRP updates to fetch_unit

		@(negedge CLK);

		// outputs:

	    // DUT error
		expected_DUT_error = 1'b0;
	    // full
		expected_BRU_RS_full = 1'b0;
	    // dispatch unit interface
	    // reg file read req interface
		expected_reg_file_read_req_valid = 1'b0;
		expected_reg_file_read_req_0_tag = phys_reg_tag_t'(40);
		expected_reg_file_read_req_1_tag = phys_reg_tag_t'(99);
	    // kill bus interface
	    // complete bus interface:
	    // input side (take from any 3 buses):
	    // complete bus 0 (ALU 0)
	    // complete bus 1 (ALU 1)
	    // complete bus 2 (LQ)
	    // complete output to ROB
		expected_this_complete_valid = 1'b0;
	    // restart output to ROB
		expected_this_restart_valid = 1'b0;
		expected_this_restart_ROB_index = ROB_index_t'(29); // given
		expected_this_restart_PC = pc_t'(16'h2fbb); // given
		expected_this_restart_safe_column = checkpoint_column_t'(29);
	    // BTB/DIRP updates to fetch_unit
		expected_this_BTB_DIRP_update = 1'b0;
		expected_this_BTB_DIRP_index = BTB_DIRP_index_t'(16'h5a); // given
		expected_this_BTB_target = pc_t'(16'h1a5b);	// given
		expected_this_DIRP_taken = 1'b0; // given

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

