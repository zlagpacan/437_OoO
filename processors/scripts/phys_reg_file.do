onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/CLK
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/nRST
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/test_num
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /phys_reg_file_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_read_overload
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_read_overload
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_LQ_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_LQ_read_req_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_LQ_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_LQ_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_0_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_0_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_0_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_ALU_0_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_ALU_0_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_1_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_1_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_1_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_ALU_1_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_ALU_1_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_BRU_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_BRU_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_BRU_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_BRU_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_BRU_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_SQ_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_SQ_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_SQ_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_SQ_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_SQ_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_read_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_read_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_LQ_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_LQ_write_req_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_LQ_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_LQ_write_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_LQ_write_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_0_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_0_write_req_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_0_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_ALU_0_write_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_ALU_0_write_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_1_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_1_write_req_tag
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/tb_ALU_1_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/DUT_ALU_1_write_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /phys_reg_file_tb/expected_ALU_1_write_req_serviced
add wave -noupdate -expand -group {Internal Signals} /phys_reg_file_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} /phys_reg_file_tb/DUT/phys_reg_file
add wave -noupdate -expand -group {Internal Signals} /phys_reg_file_tb/DUT/next_phys_reg_file
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2273300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 281
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
WaveRestoreZoom {2251900 ps} {2292700 ps}
