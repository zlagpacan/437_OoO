onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /icache_tb/CLK
add wave -noupdate /icache_tb/nRST
add wave -noupdate /icache_tb/test_case
add wave -noupdate /icache_tb/sub_test_case
add wave -noupdate /icache_tb/test_num
add wave -noupdate /icache_tb/num_errors
add wave -noupdate /icache_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/tb_icache_REN
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/tb_icache_addr
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/tb_icache_halt
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/DUT_icache_hit
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/expected_icache_hit
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/DUT_icache_load
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/expected_icache_load
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/DUT_imem_REN
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/expected_imem_REN
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/DUT_imem_block_addr
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/expected_imem_block_addr
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/tb_imem_hit
add wave -noupdate -expand -group {Top Level Signals} /icache_tb/tb_imem_load
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} -expand /icache_tb/DUT/loop_way
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/next_loop_way
add wave -noupdate -expand -group {Internal Signals} -expand /icache_tb/DUT/stream_buffer
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/next_stream_buffer
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/stream_state
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/next_stream_state
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/stream_counter
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/next_stream_counter
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/missing_block_addr
add wave -noupdate -expand -group {Internal Signals} /icache_tb/DUT/next_missing_block_addr
add wave -noupdate -expand -group {Internal Signals} -expand /icache_tb/DUT/icache_addr_structed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1195800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 204
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
WaveRestoreZoom {1055 ns} {1284 ns}
