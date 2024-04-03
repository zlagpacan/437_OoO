onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /lsq_tb/CLK
add wave -noupdate -expand -group {TB Signals} /lsq_tb/nRST
add wave -noupdate -expand -group {TB Signals} /lsq_tb/test_num
add wave -noupdate -expand -group {TB Signals} /lsq_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /lsq_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dispatch_unit_LQ_tail_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dispatch_unit_LQ_tail_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dispatch_unit_LQ_full
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dispatch_unit_LQ_full
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dispatch_unit_LQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dispatch_unit_LQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dispatch_unit_SQ_tail_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dispatch_unit_SQ_tail_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dispatch_unit_SQ_full
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dispatch_unit_SQ_full
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dispatch_unit_SQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dispatch_unit_SQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_kill_bus_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_kill_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_core_control_halt
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_ROB_LQ_restart_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_ROB_LQ_restart_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_ROB_LQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_ROB_LQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_ROB_LQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_ROB_LQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_ROB_SQ_complete_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_ROB_SQ_complete_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_ROB_SQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_ROB_SQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_ROB_SQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_ROB_SQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_LQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_LQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_LQ_reg_read_req_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_LQ_reg_read_req_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_LQ_reg_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_LQ_reg_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_SQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_SQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_SQ_reg_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_SQ_reg_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_SQ_reg_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_SQ_reg_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_SQ_reg_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_SQ_reg_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_SQ_reg_read_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_this_complete_bus_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_this_complete_bus_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_this_complete_bus_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_this_complete_bus_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_this_complete_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_this_complete_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_this_complete_bus_data_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_this_complete_bus_data_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_this_complete_bus_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_this_complete_bus_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_req_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_req_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_req_addr
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_req_addr
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_req_linked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_req_linked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_req_conditional
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_req_conditional
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_read_req_blocked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_read_resp_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_read_resp_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_read_resp_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_write_req_addr
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_write_req_addr
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_write_req_conditional
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_write_req_conditional
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_write_req_blocked
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_kill_valid_0
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_kill_valid_0
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_kill_LQ_index_0
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_kill_LQ_index_0
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_kill_valid_1
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_kill_valid_1
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_read_kill_LQ_index_1
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_read_kill_LQ_index_1
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_inv_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_dcache_inv_block_addr
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/DUT_dcache_halt
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/expected_dcache_halt
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_0_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_0_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_1_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_1_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_2_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_2_tag
add wave -noupdate -expand -group {Top Level Signals} /lsq_tb/tb_complete_bus_2_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/DUT_error
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_LQ_tail_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_LQ_full
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_LQ_task_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_LQ_task_struct
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_SQ_tail_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_SQ_full
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_SQ_task_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dispatch_unit_SQ_task_struct
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/kill_bus_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/kill_bus_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/core_control_halt
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_LQ_restart_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_LQ_retire_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_LQ_retire_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_LQ_retire_blocked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_SQ_complete_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_SQ_retire_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_SQ_retire_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/ROB_SQ_retire_blocked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_req_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_req_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_req_serviced
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_bus_0_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_req_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_req_0_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_req_1_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_req_serviced
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_bus_0_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_bus_1_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/this_complete_bus_tag_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/this_complete_bus_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/this_complete_bus_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/this_complete_bus_data_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/this_complete_bus_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_req_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_req_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_req_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_req_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_req_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_req_blocked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_resp_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_resp_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_resp_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_write_req_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_write_req_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_write_req_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_write_req_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_write_req_blocked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_kill_valid_0
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_kill_LQ_index_0
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_kill_valid_1
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_read_kill_LQ_index_1
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_inv_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_inv_block_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/dcache_halt
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_0_tag_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_0_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_0_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_1_tag_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_1_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_1_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_2_tag_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_2_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/complete_bus_2_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_pipeline_DUT_error
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_pipeline_DUT_error
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/central_LSQ_DUT_error
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_busy
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_source_0_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_source_1_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_task_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_source_0_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_source_0_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_source_1_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_source_1_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_reg_file_write_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_reg_file_write_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_reg_read_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_forwarded_write_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_write_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_addr_calc_stage_forwarded_write_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_update_stage_write_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_operand_update_stage_write_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_update_stage_write_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_operand_update_stage_write_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_operand_update_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_operand_update_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_busy
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_source_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_task_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_source_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_source_ready
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_reg_file_read_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_operand_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_operand_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_reg_read_stage_operand_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_forwarded_read_base_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_addr_calc_stage_read_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_update_stage_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_operand_update_stage_linked
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_update_stage_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_operand_update_stage_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_update_stage_read_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_operand_update_stage_read_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_operand_update_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_operand_update_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_array
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_array
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_SQ_search_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_SQ_search_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_full
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_full
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_empty
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_LQ_empty
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_array
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_array
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_full
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_full
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_empty
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_empty
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_dcache_write_req_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_dcache_write_req_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_dcache_write_req_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_dcache_write_req_conditional
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_req_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_req_read_addr
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_req_SQ_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_CAM_ambiguous
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_CAM_present
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_CAM_youngest_older_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_CAM_youngest_older_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_resp_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_search_resp_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_resp_present
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_search_resp_present
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/SQ_search_resp_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_SQ_search_resp_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_this_complete_bus_data_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/next_this_complete_bus_data
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_restart_missed_SQ_forward_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_restart_missed_SQ_forward_ROB_index
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_restart_dcache_inv_valid
add wave -noupdate -expand -group {Internal Signals} /lsq_tb/DUT/LQ_restart_dcache_inv_ROB_index
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {57100 ps}
