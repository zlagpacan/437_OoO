onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /lsq_tb/CLK
add wave -noupdate -expand -group {TB Signals} /lsq_tb/nRST
add wave -noupdate -expand -group {TB Signals} /lsq_tb/test_num
add wave -noupdate -expand -group {TB Signals} /lsq_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /lsq_tb/tb_error
add wave -noupdate -expand -group {TB Signals} /lsq_tb/test_case
add wave -noupdate -divider {Top Level Signals}
add wave -noupdate -expand -group {Top Level Signals} -expand -group {DUT error} /lsq_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Top Level Signals} -expand -group {DUT error} /lsq_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} -expand -group {DUT error} /lsq_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/DUT_dispatch_unit_LQ_full
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/expected_dispatch_unit_LQ_full
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/tb_dispatch_unit_LQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/tb_dispatch_unit_LQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/DUT_dispatch_unit_SQ_full
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/expected_dispatch_unit_SQ_full
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/tb_dispatch_unit_SQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} -group {dispatch unit interface} /lsq_tb/tb_dispatch_unit_SQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} -group {kill bus} /lsq_tb/tb_kill_bus_valid
add wave -noupdate -expand -group {Top Level Signals} -group {kill bus} /lsq_tb/tb_kill_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group halt /lsq_tb/tb_core_control_halt
add wave -noupdate -expand -group {Top Level Signals} -group {LQ restart} /lsq_tb/DUT_ROB_LQ_restart_valid
add wave -noupdate -expand -group {Top Level Signals} -group {LQ restart} /lsq_tb/expected_ROB_LQ_restart_valid
add wave -noupdate -expand -group {Top Level Signals} -group {LQ restart} /lsq_tb/DUT_ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {LQ restart} /lsq_tb/expected_ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {LQ retire} /lsq_tb/tb_ROB_LQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} -group {LQ retire} /lsq_tb/tb_ROB_LQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {LQ retire} /lsq_tb/DUT_ROB_LQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} -group {LQ retire} /lsq_tb/expected_ROB_LQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} -group {SQ complete} /lsq_tb/DUT_ROB_SQ_complete_valid
add wave -noupdate -expand -group {Top Level Signals} -group {SQ complete} /lsq_tb/expected_ROB_SQ_complete_valid
add wave -noupdate -expand -group {Top Level Signals} -group {SQ complete} /lsq_tb/DUT_ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {SQ complete} /lsq_tb/expected_ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {SQ retire} /lsq_tb/tb_ROB_SQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} -group {SQ retire} /lsq_tb/tb_ROB_SQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {SQ retire} /lsq_tb/DUT_ROB_SQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} -group {SQ retire} /lsq_tb/expected_ROB_SQ_retire_blocked
add wave -noupdate -expand -group {Top Level Signals} -expand -group {LQ reg read} /lsq_tb/DUT_LQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {LQ reg read} /lsq_tb/expected_LQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {LQ reg read} /lsq_tb/DUT_LQ_reg_read_req_tag
add wave -noupdate -expand -group {Top Level Signals} -expand -group {LQ reg read} /lsq_tb/expected_LQ_reg_read_req_tag
add wave -noupdate -expand -group {Top Level Signals} -expand -group {LQ reg read} /lsq_tb/tb_LQ_reg_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} -expand -group {LQ reg read} /lsq_tb/tb_LQ_reg_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/DUT_SQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/expected_SQ_reg_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/DUT_SQ_reg_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/expected_SQ_reg_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/DUT_SQ_reg_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/expected_SQ_reg_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/tb_SQ_reg_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/tb_SQ_reg_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} -group {SQ reg read} /lsq_tb/tb_SQ_reg_read_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/DUT_this_complete_bus_tag_valid
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/expected_this_complete_bus_tag_valid
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/DUT_this_complete_bus_tag
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/expected_this_complete_bus_tag
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/DUT_this_complete_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/expected_this_complete_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/DUT_this_complete_bus_data_valid
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/expected_this_complete_bus_data_valid
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/DUT_this_complete_bus_data
add wave -noupdate -expand -group {Top Level Signals} -group {this complete bus} /lsq_tb/expected_this_complete_bus_data
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/DUT_dcache_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/expected_dcache_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/DUT_dcache_read_req_LQ_index
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/expected_dcache_read_req_LQ_index
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/DUT_dcache_read_req_addr
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/expected_dcache_read_req_addr
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/DUT_dcache_read_req_linked
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/expected_dcache_read_req_linked
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/DUT_dcache_read_req_conditional
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/expected_dcache_read_req_conditional
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read req} /lsq_tb/tb_dcache_read_req_blocked
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read resp} /lsq_tb/tb_dcache_read_resp_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read resp} /lsq_tb/tb_dcache_read_resp_LQ_index
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ read resp} /lsq_tb/tb_dcache_read_resp_data
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/DUT_dcache_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/expected_dcache_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/DUT_dcache_write_req_addr
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/expected_dcache_write_req_addr
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/DUT_dcache_write_req_data
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/expected_dcache_write_req_data
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/DUT_dcache_write_req_conditional
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/expected_dcache_write_req_conditional
add wave -noupdate -expand -group {Top Level Signals} -group {d$ write req} /lsq_tb/tb_dcache_write_req_blocked
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ inv} /lsq_tb/tb_dcache_inv_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ inv} /lsq_tb/tb_dcache_inv_block_addr
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ inv} /lsq_tb/tb_dcache_evict_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ inv} /lsq_tb/tb_dcache_evict_block_addr
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ halt} /lsq_tb/DUT_dcache_halt
add wave -noupdate -expand -group {Top Level Signals} -expand -group {d$ halt} /lsq_tb/expected_dcache_halt
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_0_tag_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_0_tag
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_1_tag_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_1_tag
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_2_tag_valid
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_2_tag
add wave -noupdate -expand -group {Top Level Signals} -expand -group {complete buses} /lsq_tb/tb_complete_bus_2_data
add wave -noupdate -divider {Internal Signals}
add wave -noupdate -expand -group {Internal Signals} -expand -group {DUT error} /lsq_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand -group {DUT error} /lsq_tb/DUT_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand -group {DUT error} /lsq_tb/expected_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand -group {DUT error} /lsq_tb/DUT/SQ_operand_pipeline_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand -group {DUT error} /lsq_tb/DUT/LQ_operand_pipeline_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand -group {DUT error} /lsq_tb/DUT/central_LSQ_DUT_error
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_source_0_ready
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_source_1_ready
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_imm14
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_SQ_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand task} /lsq_tb/DUT/SQ_operand_task_ROB_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_busy
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_source_0_ready
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_source_0_ready
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_source_1_ready
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_source_1_ready
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/next_SQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_reg_file_write_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_reg_file_write_data
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} -group {SQ reg read stage} /lsq_tb/DUT/SQ_reg_read_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/next_SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_forwarded_write_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_write_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ addr calc stage} /lsq_tb/DUT/SQ_addr_calc_stage_forwarded_write_data
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/SQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/next_SQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/SQ_operand_update_stage_write_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/next_SQ_operand_update_stage_write_addr
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/SQ_operand_update_stage_write_data
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/next_SQ_operand_update_stage_write_data
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/SQ_operand_update_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} -group {SQ operand update stage} /lsq_tb/DUT/next_SQ_operand_update_stage_SQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_linked
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_conditional
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_source_ready
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_source_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_imm14
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ operand task} /lsq_tb/DUT/LQ_operand_task_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_busy
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_linked
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_linked
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_conditional
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_conditional
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_source_ready
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_source_ready
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/next_LQ_reg_read_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_reg_file_read_base_addr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_operand_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_operand_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ reg read stage} /lsq_tb/DUT/LQ_reg_read_stage_operand_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_linked
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_linked
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_conditional
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_conditional
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_imm14
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/next_LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_forwarded_read_base_addr
add wave -noupdate -expand -group {Internal Signals} -group {LQ addr calc stage} /lsq_tb/DUT/LQ_addr_calc_stage_read_addr
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/LQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/next_LQ_operand_update_stage_valid
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/LQ_operand_update_stage_linked
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/next_LQ_operand_update_stage_linked
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/LQ_operand_update_stage_conditional
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/next_LQ_operand_update_stage_conditional
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/LQ_operand_update_stage_read_addr
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/next_LQ_operand_update_stage_read_addr
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/LQ_operand_update_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} -group {LQ operand update stage} /lsq_tb/DUT/next_LQ_operand_update_stage_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ array} -color Gold -expand -subitemconfig {{/lsq_tb/DUT/LQ_array[3]} {-color Gold -height 16} {/lsq_tb/DUT/LQ_array[2]} {-color Gold -height 16} {/lsq_tb/DUT/LQ_array[1]} {-color Gold -height 16} {/lsq_tb/DUT/LQ_array[0]} {-color Gold -height 16}} /lsq_tb/DUT/LQ_array
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ array} -color Gold /lsq_tb/DUT/next_LQ_array
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/LQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/next_LQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/LQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/next_LQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/LQ_SQ_search_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/next_LQ_SQ_search_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/LQ_full
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/next_LQ_full
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/LQ_empty
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ pointers} /lsq_tb/DUT/next_LQ_empty
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ array} /lsq_tb/DUT/dcache_evict_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ array} /lsq_tb/DUT/dcache_evict_block_addr
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ array} -color Gold -expand -subitemconfig {{/lsq_tb/DUT/SQ_array[3]} {-color Gold -height 16 -expand} {/lsq_tb/DUT/SQ_array[3].valid} {-color Gold} {/lsq_tb/DUT/SQ_array[3].ready} {-color Gold} {/lsq_tb/DUT/SQ_array[3].written} {-color Gold} {/lsq_tb/DUT/SQ_array[3].conditional} {-color Gold} {/lsq_tb/DUT/SQ_array[3].ROB_index} {-color Gold} {/lsq_tb/DUT/SQ_array[3].write_addr} {-color Gold} {/lsq_tb/DUT/SQ_array[3].write_data} {-color Gold} {/lsq_tb/DUT/SQ_array[2]} {-color Gold -height 16 -expand} {/lsq_tb/DUT/SQ_array[2].valid} {-color Gold} {/lsq_tb/DUT/SQ_array[2].ready} {-color Gold} {/lsq_tb/DUT/SQ_array[2].written} {-color Gold} {/lsq_tb/DUT/SQ_array[2].conditional} {-color Gold} {/lsq_tb/DUT/SQ_array[2].ROB_index} {-color Gold} {/lsq_tb/DUT/SQ_array[2].write_addr} {-color Gold} {/lsq_tb/DUT/SQ_array[2].write_data} {-color Gold} {/lsq_tb/DUT/SQ_array[1]} {-color Gold -height 16 -expand} {/lsq_tb/DUT/SQ_array[1].valid} {-color Gold} {/lsq_tb/DUT/SQ_array[1].ready} {-color Gold} {/lsq_tb/DUT/SQ_array[1].written} {-color Gold} {/lsq_tb/DUT/SQ_array[1].conditional} {-color Gold} {/lsq_tb/DUT/SQ_array[1].ROB_index} {-color Gold} {/lsq_tb/DUT/SQ_array[1].write_addr} {-color Gold} {/lsq_tb/DUT/SQ_array[1].write_data} {-color Gold} {/lsq_tb/DUT/SQ_array[0]} {-color Gold -height 16 -expand} {/lsq_tb/DUT/SQ_array[0].valid} {-color Gold} {/lsq_tb/DUT/SQ_array[0].ready} {-color Gold} {/lsq_tb/DUT/SQ_array[0].written} {-color Gold} {/lsq_tb/DUT/SQ_array[0].conditional} {-color Gold} {/lsq_tb/DUT/SQ_array[0].ROB_index} {-color Gold} {/lsq_tb/DUT/SQ_array[0].write_addr} {-color Gold} {/lsq_tb/DUT/SQ_array[0].write_data} {-color Gold}} /lsq_tb/DUT/SQ_array
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ array} -color Gold /lsq_tb/DUT/next_SQ_array
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/SQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/next_SQ_head_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/SQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/next_SQ_tail_ptr
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/SQ_full
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/next_SQ_full
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/SQ_empty
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ pointers} /lsq_tb/DUT/next_SQ_empty
add wave -noupdate -expand -group {Internal Signals} -expand -group {d$ write req} /lsq_tb/DUT/next_dcache_write_req_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {d$ write req} /lsq_tb/DUT/next_dcache_write_req_addr
add wave -noupdate -expand -group {Internal Signals} -expand -group {d$ write req} /lsq_tb/DUT/next_dcache_write_req_data
add wave -noupdate -expand -group {Internal Signals} -expand -group {d$ write req} /lsq_tb/DUT/next_dcache_write_req_conditional
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_req_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_req_read_addr
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_req_SQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_CAM_ambiguous
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_resp_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/next_SQ_search_resp_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_resp_present
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/next_SQ_search_resp_present
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/SQ_search_resp_data
add wave -noupdate -expand -group {Internal Signals} -expand -group {SQ search} /lsq_tb/DUT/next_SQ_search_resp_data
add wave -noupdate -expand -group {Internal Signals} -group {this complete bus} /lsq_tb/DUT/next_this_complete_bus_data_valid
add wave -noupdate -expand -group {Internal Signals} -group {this complete bus} /lsq_tb/DUT/next_this_complete_bus_data
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_missed_SQ_forward_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_missed_SQ_forward_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_dcache_inv_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_dcache_inv_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_dcache_inv_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_dcache_evict_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_dcache_evict_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_dcache_evict_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_combined_dcache_inv_evict_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/next_LQ_restart_combined_dcache_inv_evict_valid
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_combined_dcache_inv_evict_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/next_LQ_restart_combined_dcache_inv_evict_LQ_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/LQ_restart_combined_dcache_inv_evict_ROB_index
add wave -noupdate -expand -group {Internal Signals} -expand -group {LQ restart} /lsq_tb/DUT/next_LQ_restart_combined_dcache_inv_evict_ROB_index
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {609800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 370
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
WaveRestoreZoom {0 ps} {777 ns}
