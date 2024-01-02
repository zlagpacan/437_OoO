onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/CLK
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/nRST
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/test_num
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /phys_reg_ready_table_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_ready_table_tb/tb_dispatch_source_0_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/DUT_dispatch_source_0_ready
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/expected_dispatch_source_0_ready
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_ready_table_tb/tb_dispatch_source_1_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/DUT_dispatch_source_1_ready
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/expected_dispatch_source_1_ready
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/tb_dispatch_dest_write
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_ready_table_tb/tb_dispatch_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/tb_complete_bus_0_valid
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_ready_table_tb/tb_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_ready_table_tb/tb_complete_bus_1_valid
add wave -noupdate -expand -group {Top Level Signals} -radix unsigned /phys_reg_ready_table_tb/tb_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -expand -group {Internal Signals} /phys_reg_ready_table_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand /phys_reg_ready_table_tb/DUT/ready_table_by_phys_reg_tag_index
add wave -noupdate -expand -group {Internal Signals} /phys_reg_ready_table_tb/DUT/next_ready_table_by_phys_reg_tag_index
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3214800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 260
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
WaveRestoreZoom {3166900 ps} {3254400 ps}
