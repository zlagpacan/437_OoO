onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /rob_tb/CLK
add wave -noupdate -expand -group {TB Signals} /rob_tb/nRST
add wave -noupdate -expand -group {TB Signals} /rob_tb/test_case
add wave -noupdate -expand -group {TB Signals} /rob_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /rob_tb/test_num
add wave -noupdate -expand -group {TB Signals} /rob_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /rob_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_full
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_full
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_empty
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_empty
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_fetch_unit_take_resolved
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_fetch_unit_take_resolved
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_fetch_unit_resolved_PC
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_fetch_unit_resolved_PC
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_dispatch_unit_ROB_tail_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_dispatch_unit_ROB_tail_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_dispatch_unit_enqueue_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_dispatch_unit_enqueue_struct
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_dispatch_unit_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_dispatch_unit_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_dispatch_unit_retire_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_dispatch_unit_retire_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_0_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_0_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_1_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_1_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_2_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_2_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_complete_bus_2_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_BRU_complete_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_BRU_complete_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_BRU_restart_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_BRU_restart_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_BRU_restart_PC
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_BRU_restart_safe_column
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_LQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_LQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_LQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_LQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_LQ_restart_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_LQ_restart_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_SQ_complete_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_SQ_complete_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_SQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_SQ_retire_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_SQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_SQ_retire_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_restore_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_restore_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/tb_restore_checkpoint_success
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_revert_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_revert_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_revert_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_revert_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_revert_arch_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_revert_arch_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_revert_safe_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_revert_safe_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_revert_speculated_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_revert_speculated_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_kill_bus_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_kill_bus_valid
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_kill_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_kill_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_core_control_restore_flush
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_core_control_restore_flush
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_core_control_revert_stall
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_core_control_revert_stall
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_core_control_halt_assert
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_core_control_halt_assert
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_ROB_state_out
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_ROB_state_out
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_invalid_complete
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_invalid_complete
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/DUT_ROB_capacity
add wave -noupdate -expand -group {Top Level Signals} /rob_tb/expected_ROB_capacity
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand /rob_tb/DUT/ROB_array_by_entry
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_ROB_array_by_entry
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/head_index_ptr
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_head_index_ptr
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/tail_index_ptr
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_tail_index_ptr
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/restart_ROB_index_ptr
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_restart_ROB_index_ptr
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/restart_column
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_restart_column
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/inorder_kill_start_ROB_index
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_inorder_kill_start_ROB_index
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/inorder_kill_end_ROB_index
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_inorder_kill_end_ROB_index
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_full
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_empty
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/ROB_state
add wave -noupdate -expand -group {Internal Signals} /rob_tb/DUT/next_ROB_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {113700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
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
WaveRestoreZoom {89900 ps} {130900 ps}
