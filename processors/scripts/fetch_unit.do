onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fetch_unit_tb/CLK
add wave -noupdate /fetch_unit_tb/nRST
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/test_case
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/sub_test_case
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/test_num
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/num_errors
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/error
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_BTB_DIRP_update
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_BTB_DIRP_index
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_BTB_target
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_DIRP_taken
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_take_resolved
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_resolved_PC
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_icache_hit
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_icache_load
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_stall_fetch_unit
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/tb_pipeline_halt
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_icache_REN
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_icache_REN
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_icache_addr
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_icache_addr
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_icache_halt
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_icache_halt
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_pipeline_instr
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_pipeline_instr
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_pipeline_ivalid
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_pipeline_ivalid
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_pipeline_PC
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_pipeline_PC
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/fu_pipeline_nPC
add wave -noupdate -expand -group {Top Level Signals} /fetch_unit_tb/expected_pipeline_nPC
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/PC
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/nPC
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/PC_plus_4
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/jPC
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/RAS_pop_val
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/BTB_target
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/DIRP_state
add wave -noupdate -expand -group {Internal Signals} -subitemconfig {{/fetch_unit_tb/DUT/BTB_DIRP_entry_by_frame_index[176]} -expand} /fetch_unit_tb/DUT/BTB_DIRP_entry_by_frame_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/next_BTB_DIRP_entry_by_frame_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/BTB_DIRP_frame_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/RAS_entry_by_top_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/next_RAS_entry_by_top_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/RAS_top_write_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/next_RAS_top_write_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/RAS_top_read_index
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/RAS_push_val
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/instr
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/instr_opcode
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/is_beq_bne
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/is_j
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/is_jal
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/is_jr
add wave -noupdate -expand -group {Internal Signals} /fetch_unit_tb/DUT/next_icache_REN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {318800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {346500 ps}
