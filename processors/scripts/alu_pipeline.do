onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /alu_pipeline_tb/CLK
add wave -noupdate -expand -group {TB Signals} /alu_pipeline_tb/nRST
add wave -noupdate -expand -group {TB Signals} /alu_pipeline_tb/test_num
add wave -noupdate -expand -group {TB Signals} /alu_pipeline_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /alu_pipeline_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_ALU_RS_full
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_ALU_RS_full
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_dispatch_unit_task_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_dispatch_unit_task_struct
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_reg_file_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_reg_file_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_reg_file_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_reg_file_read_req_0_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_reg_file_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_reg_file_read_req_1_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_reg_file_read_req_serviced
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_reg_file_read_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_reg_file_read_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_kill_bus_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_kill_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_0_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_0_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_0_data
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_1_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_1_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_1_data
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_2_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_2_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/tb_complete_bus_2_data
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_this_complete_bus_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_this_complete_bus_tag_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_this_complete_bus_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_this_complete_bus_tag
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_this_complete_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_this_complete_bus_ROB_index
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_this_complete_bus_data_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_this_complete_bus_data_valid
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/DUT_this_complete_bus_data
add wave -noupdate -expand -group {Top Level Signals} /alu_pipeline_tb/expected_this_complete_bus_data
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_task_valid
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_RS_stage_task_valid
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_task_struct
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_RS_stage_task_struct
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_task_valid
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_task_valid
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_op
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_op
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_operand_0
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_operand_0
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_operand_1
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_operand_1
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_operand_0_bus_select
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_operand_0_bus_select
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_operand_1_bus_select
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_operand_1_bus_select
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_tag
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_tag
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_EX_stage_ROB_index
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/DATA_stage_task_valid
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_DATA_stage_task_valid
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/DATA_stage_output_data
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/next_DATA_stage_output_data
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_1_imm32
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/RS_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_A
add wave -noupdate -expand -group {Internal Signals} /alu_pipeline_tb/DUT/EX_stage_B
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39600 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 291
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
WaveRestoreZoom {0 ps} {45600 ps}
