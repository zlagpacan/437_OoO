onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/CLK
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/nRST
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/test_num
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /phys_reg_map_table_tb/error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_source_arch_reg_tag_0
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/prmt_source_phys_reg_tag_0
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/expected_source_phys_reg_tag_0
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_source_arch_reg_tag_1
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/prmt_source_phys_reg_tag_1
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/expected_source_phys_reg_tag_1
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_old_dest_arch_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/prmt_old_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/expected_old_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_rename_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_rename_dest_arch_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_rename_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_revert_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_revert_dest_arch_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_revert_safe_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_revert_speculated_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_save_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_save_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/prmt_save_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/expected_save_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_restore_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/prmt_restore_checkpoint_success
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/expected_restore_checkpoint_success
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_map_table_tb/tb_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Internal Signals} /phys_reg_map_table_tb/DUT/phys_reg_map_table_columns_by_column_index
add wave -noupdate -expand -group {Internal Signals} /phys_reg_map_table_tb/DUT/next_phys_reg_map_table_columns_by_column_index
add wave -noupdate -expand -group {Internal Signals} /phys_reg_map_table_tb/DUT/phys_reg_map_table_working_column
add wave -noupdate -expand -group {Internal Signals} /phys_reg_map_table_tb/DUT/next_phys_reg_map_table_working_column
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {576700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 254
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
WaveRestoreZoom {0 ps} {2583 ns}
