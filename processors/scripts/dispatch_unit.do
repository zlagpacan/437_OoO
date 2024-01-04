onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/CLK
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/nRST
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/test_case
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/test_num
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /dispatch_unit_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_core_control_stall_dispatch_unit
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_core_control_flush_dispatch_unit
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_core_control_halt
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_core_control_dispatch_failed
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_core_control_dispatch_failed
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_fetch_unit_instr
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_fetch_unit_ivalid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_fetch_unit_PC
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_fetch_unit_nPC
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_restore_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_restore_checkpoint_success
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_restore_checkpoint_success
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_kill_bus_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_kill_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_kill_bus_arch_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_kill_bus_speculated_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_kill_bus_safe_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_complete_bus_0_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_complete_bus_1_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_ROB_full
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_ROB_tail_index
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_ROB_enqueue_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_ROB_enqueue_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_ROB_struct_out
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_ROB_struct_out
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_ROB_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_ROB_retire_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_ALU_RS_full
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_ALU_RS_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_ALU_RS_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_ALU_RS_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_ALU_RS_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_SQ_tail_index
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_SQ_full
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_SQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_SQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_SQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_SQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_LQ_tail_index
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_LQ_full
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_LQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_LQ_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_LQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_LQ_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/tb_BRU_RS_full
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_BRU_RS_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_BRU_RS_task_valid
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/DUT_BRU_RS_task_struct
add wave -noupdate -expand -group {Top Level Signals} /dispatch_unit_tb/expected_BRU_RS_task_struct
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_DUT_error
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_source_arch_reg_tag_0
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_source_phys_reg_tag_0
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_source_arch_reg_tag_1
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_source_phys_reg_tag_1
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_old_dest_arch_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_old_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_rename_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_rename_dest_arch_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_rename_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_revert_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_revert_dest_arch_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_revert_safe_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_revert_speculated_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_save_checkpoint_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_save_checkpoint_ROB_index
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_save_checkpoint_safe_column
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_restore_checkpoint_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prmt_restore_checkpoint_success
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_DUT_error
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_dequeue_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_dequeue_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_enqueue_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_enqueue_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_full
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_empty
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_revert_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_revert_speculated_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_save_checkpoint_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_save_checkpoint_ROB_index
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_save_checkpoint_safe_column
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_restore_checkpoint_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prfl_restore_checkpoint_success
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_DUT_error
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_dispatch_source_0_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_dispatch_source_0_ready
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_dispatch_source_1_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_dispatch_source_1_ready
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_dispatch_dest_write
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_dispatch_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_complete_bus_0_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_complete_bus_1_valid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/prrt_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/dispatch_unit_instr
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/dispatch_unit_ivalid
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/dispatch_unit_PC
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/dispatch_unit_nPC
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_rtype
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_itype
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_jtype
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_opcode
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_rs
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_rt
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_rd
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_imm16
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/instr_funct
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/ALU_RS_select
add wave -noupdate -expand -group {Internal Signals} /dispatch_unit_tb/DUT/ALU_RS_both_full
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 274
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
WaveRestoreZoom {0 ps} {1183100 ps}
