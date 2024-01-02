onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/CLK
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/nRST
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/test_num
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /phys_reg_free_list_tb/error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_dequeue_valid
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_free_list_tb/DUT_dequeue_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_free_list_tb/expected_dequeue_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_enqueue_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_enqueue_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/DUT_full
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/expected_full
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/DUT_empty
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/expected_empty
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_revert_valid
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_free_list_tb/tb_revert_speculated_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_save_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_free_list_tb/tb_save_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/DUT_save_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/expected_save_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_restore_checkpoint_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/tb_restore_checkpoint_safe_column
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/DUT_restore_checkpoint_success
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_free_list_tb/expected_restore_checkpoint_success
add wave -noupdate -expand -group {Internal Signals} -radix unsigned -childformat {{{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[31]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[30]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[29]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[28]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[27]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[26]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[25]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[24]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[23]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[22]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[21]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[20]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[19]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[18]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[17]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[16]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[15]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[14]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[13]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[12]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[11]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[10]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[9]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[8]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[7]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[6]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[5]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[4]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[3]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[2]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[1]} -radix unsigned} {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[0]} -radix unsigned}} -expand -subitemconfig {{/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[31]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[30]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[29]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[28]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[27]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[26]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[25]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[24]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[23]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[22]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[21]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[20]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[19]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[18]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[17]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[16]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[15]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[14]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[13]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[12]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[11]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[10]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[9]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[8]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[7]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[6]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[5]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[4]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[3]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[2]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[1]} {-height 16 -radix unsigned} {/phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index[0]} {-height 16 -radix unsigned}} /phys_reg_free_list_tb/DUT/phys_reg_free_list_by_index
add wave -noupdate -expand -group {Internal Signals} -radix unsigned /phys_reg_free_list_tb/DUT/next_phys_reg_free_list_by_index
add wave -noupdate -expand -group {Internal Signals} -radix unsigned /phys_reg_free_list_tb/DUT/head_index_ptr
add wave -noupdate -expand -group {Internal Signals} -radix unsigned /phys_reg_free_list_tb/DUT/next_head_index_ptr
add wave -noupdate -expand -group {Internal Signals} -radix unsigned /phys_reg_free_list_tb/DUT/prev_head_index_ptr
add wave -noupdate -expand -group {Internal Signals} -radix unsigned /phys_reg_free_list_tb/DUT/tail_index_ptr
add wave -noupdate -expand -group {Internal Signals} -radix unsigned /phys_reg_free_list_tb/DUT/next_tail_index_ptr
add wave -noupdate -expand -group {Internal Signals} /phys_reg_free_list_tb/DUT/checkpoint_columns_by_column_index
add wave -noupdate -expand -group {Internal Signals} /phys_reg_free_list_tb/DUT/next_checkpoint_columns_by_column_index
add wave -noupdate -expand -group {Internal Signals} /phys_reg_free_list_tb/DUT/checkpoint_tail_column
add wave -noupdate -expand -group {Internal Signals} /phys_reg_free_list_tb/DUT/next_checkpoint_tail_column
add wave -noupdate -expand -group {Internal Signals} /phys_reg_free_list_tb/DUT/next_full
add wave -noupdate -expand -group {Internal Signals} /phys_reg_free_list_tb/DUT/next_empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {716200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 294
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
WaveRestoreZoom {664700 ps} {728300 ps}
