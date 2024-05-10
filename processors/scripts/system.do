onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CLK
add wave -noupdate /system_tb/DUT/nRST
add wave -noupdate /system_tb/DUT/halt
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/DUT/count
add wave -noupdate -divider {System Level Signals}
add wave -noupdate -expand -group {Halt's and Flush's} /system_tb/DUT/dcache0_halt
add wave -noupdate -expand -group {Halt's and Flush's} /system_tb/DUT/dcache1_halt
add wave -noupdate -expand -group {Halt's and Flush's} /system_tb/DUT/snoop_dcache0_flushed
add wave -noupdate -expand -group {Halt's and Flush's} /system_tb/DUT/snoop_dcache1_flushed
add wave -noupdate -expand -group {Halt's and Flush's} /system_tb/DUT/dual_mem_controller_flushed
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/core0_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/icache0_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/snoop_dcache0_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/core1_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/icache1_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/snoop_dcache1_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/bus_controller_DUT_error
add wave -noupdate -expand -group {DUT Error's} /system_tb/DUT/dual_mem_controller_DUT_error
add wave -noupdate -expand -group {icache0 interface} /system_tb/DUT/icache0_hit
add wave -noupdate -expand -group {icache0 interface} /system_tb/DUT/icache0_load
add wave -noupdate -expand -group {icache0 interface} /system_tb/DUT/icache0_REN
add wave -noupdate -expand -group {icache0 interface} /system_tb/DUT/icache0_addr
add wave -noupdate -expand -group {icache0 interface} /system_tb/DUT/icache0_halt
add wave -noupdate -expand -group {dcache0 read req interface} /system_tb/DUT/dcache0_read_req_valid
add wave -noupdate -expand -group {dcache0 read req interface} /system_tb/DUT/dcache0_read_req_LQ_index
add wave -noupdate -expand -group {dcache0 read req interface} /system_tb/DUT/dcache0_read_req_addr
add wave -noupdate -expand -group {dcache0 read req interface} /system_tb/DUT/dcache0_read_req_linked
add wave -noupdate -expand -group {dcache0 read req interface} /system_tb/DUT/dcache0_read_req_conditional
add wave -noupdate -expand -group {dcache0 read req interface} /system_tb/DUT/dcache0_read_req_blocked
add wave -noupdate -expand -group {dcache0 read resp interface} /system_tb/DUT/dcache0_read_resp_valid
add wave -noupdate -expand -group {dcache0 read resp interface} /system_tb/DUT/dcache0_read_resp_LQ_index
add wave -noupdate -expand -group {dcache0 read resp interface} /system_tb/DUT/dcache0_read_resp_data
add wave -noupdate -expand -group {dcache0 write req interface} /system_tb/DUT/dcache0_write_req_valid
add wave -noupdate -expand -group {dcache0 write req interface} /system_tb/DUT/dcache0_write_req_addr
add wave -noupdate -expand -group {dcache0 write req interface} /system_tb/DUT/dcache0_write_req_data
add wave -noupdate -expand -group {dcache0 write req interface} /system_tb/DUT/dcache0_write_req_conditional
add wave -noupdate -expand -group {dcache0 write req interface} /system_tb/DUT/dcache0_write_req_blocked
add wave -noupdate -expand -group {dcache0 read kill interface} /system_tb/DUT/dcache0_read_kill_0_valid
add wave -noupdate -expand -group {dcache0 read kill interface} /system_tb/DUT/dcache0_read_kill_0_LQ_index
add wave -noupdate -expand -group {dcache0 read kill interface} /system_tb/DUT/dcache0_read_kill_1_valid
add wave -noupdate -expand -group {dcache0 read kill interface} /system_tb/DUT/dcache0_read_kill_1_LQ_index
add wave -noupdate -expand -group {dcache0 inv interface} /system_tb/DUT/dcache0_inv_valid
add wave -noupdate -expand -group {dcache0 inv interface} /system_tb/DUT/dcache0_inv_block_addr
add wave -noupdate -expand -group {dcache0 inv interface} /system_tb/DUT/dcache0_evict_valid
add wave -noupdate -expand -group {dcache0 inv interface} /system_tb/DUT/dcache0_evict_block_addr
add wave -noupdate -expand -group {imem0 interface} /system_tb/DUT/imem0_REN
add wave -noupdate -expand -group {imem0 interface} /system_tb/DUT/imem0_block_addr
add wave -noupdate -expand -group {imem0 interface} /system_tb/DUT/imem0_hit
add wave -noupdate -expand -group {imem0 interface} /system_tb/DUT/imem0_load
add wave -noupdate -expand -group {dbus0 req interface} /system_tb/DUT/dbus0_req_valid
add wave -noupdate -expand -group {dbus0 req interface} /system_tb/DUT/dbus0_req_block_addr
add wave -noupdate -expand -group {dbus0 req interface} /system_tb/DUT/dbus0_req_exclusive
add wave -noupdate -expand -group {dbus0 req interface} /system_tb/DUT/dbus0_req_curr_state
add wave -noupdate -expand -group {dbus0 resp interface} /system_tb/DUT/dbus0_resp_valid
add wave -noupdate -expand -group {dbus0 resp interface} /system_tb/DUT/dbus0_resp_block_addr
add wave -noupdate -expand -group {dbus0 resp interface} /system_tb/DUT/dbus0_resp_data
add wave -noupdate -expand -group {dbus0 resp interface} /system_tb/DUT/dbus0_resp_need_block
add wave -noupdate -expand -group {dbus0 resp interface} /system_tb/DUT/dbus0_resp_new_state
add wave -noupdate -expand -group {snoop0 req interface} /system_tb/DUT/snoop0_req_valid
add wave -noupdate -expand -group {snoop0 req interface} /system_tb/DUT/snoop0_req_block_addr
add wave -noupdate -expand -group {snoop0 req interface} /system_tb/DUT/snoop0_req_exclusive
add wave -noupdate -expand -group {snoop0 req interface} /system_tb/DUT/snoop0_req_curr_state
add wave -noupdate -expand -group {snoop0 resp interface} /system_tb/DUT/snoop0_resp_valid
add wave -noupdate -expand -group {snoop0 resp interface} /system_tb/DUT/snoop0_resp_block_addr
add wave -noupdate -expand -group {snoop0 resp interface} /system_tb/DUT/snoop0_resp_data
add wave -noupdate -expand -group {snoop0 resp interface} /system_tb/DUT/snoop0_resp_present
add wave -noupdate -expand -group {snoop0 resp interface} /system_tb/DUT/snoop0_resp_need_block
add wave -noupdate -expand -group {snoop0 resp interface} /system_tb/DUT/snoop0_resp_new_state
add wave -noupdate -expand -group {dmem0 read req interface} /system_tb/DUT/dmem0_read_req_valid
add wave -noupdate -expand -group {dmem0 read req interface} /system_tb/DUT/dmem0_read_req_block_addr
add wave -noupdate -expand -group {dmem0 read resp interface} /system_tb/DUT/dmem0_read_resp_valid
add wave -noupdate -expand -group {dmem0 read resp interface} /system_tb/DUT/dmem0_read_resp_data
add wave -noupdate -expand -group {dmem0 write req interface} /system_tb/DUT/dmem0_write_req_valid
add wave -noupdate -expand -group {dmem0 write req interface} /system_tb/DUT/dmem0_write_req_block_addr
add wave -noupdate -expand -group {dmem0 write req interface} /system_tb/DUT/dmem0_write_req_data
add wave -noupdate -expand -group {dmem0 write req interface} /system_tb/DUT/dmem0_write_req_slow_down
add wave -noupdate -expand -group {icache1 interface} /system_tb/DUT/icache1_hit
add wave -noupdate -expand -group {icache1 interface} /system_tb/DUT/icache1_load
add wave -noupdate -expand -group {icache1 interface} /system_tb/DUT/icache1_REN
add wave -noupdate -expand -group {icache1 interface} /system_tb/DUT/icache1_addr
add wave -noupdate -expand -group {icache1 interface} /system_tb/DUT/icache1_halt
add wave -noupdate -expand -group {dcache1 read req interface} /system_tb/DUT/dcache1_read_req_valid
add wave -noupdate -expand -group {dcache1 read req interface} /system_tb/DUT/dcache1_read_req_LQ_index
add wave -noupdate -expand -group {dcache1 read req interface} /system_tb/DUT/dcache1_read_req_addr
add wave -noupdate -expand -group {dcache1 read req interface} /system_tb/DUT/dcache1_read_req_linked
add wave -noupdate -expand -group {dcache1 read req interface} /system_tb/DUT/dcache1_read_req_conditional
add wave -noupdate -expand -group {dcache1 read req interface} /system_tb/DUT/dcache1_read_req_blocked
add wave -noupdate -expand -group {dcache1 read resp interface} /system_tb/DUT/dcache1_read_resp_valid
add wave -noupdate -expand -group {dcache1 read resp interface} /system_tb/DUT/dcache1_read_resp_LQ_index
add wave -noupdate -expand -group {dcache1 read resp interface} /system_tb/DUT/dcache1_read_resp_data
add wave -noupdate -expand -group {dcache1 write req interface} /system_tb/DUT/dcache1_write_req_valid
add wave -noupdate -expand -group {dcache1 write req interface} /system_tb/DUT/dcache1_write_req_addr
add wave -noupdate -expand -group {dcache1 write req interface} /system_tb/DUT/dcache1_write_req_data
add wave -noupdate -expand -group {dcache1 write req interface} /system_tb/DUT/dcache1_write_req_conditional
add wave -noupdate -expand -group {dcache1 write req interface} /system_tb/DUT/dcache1_write_req_blocked
add wave -noupdate -expand -group {dcache1 read kill interface} /system_tb/DUT/dcache1_read_kill_0_valid
add wave -noupdate -expand -group {dcache1 read kill interface} /system_tb/DUT/dcache1_read_kill_0_LQ_index
add wave -noupdate -expand -group {dcache1 read kill interface} /system_tb/DUT/dcache1_read_kill_1_valid
add wave -noupdate -expand -group {dcache1 read kill interface} /system_tb/DUT/dcache1_read_kill_1_LQ_index
add wave -noupdate -expand -group {dcache1 inv interface} /system_tb/DUT/dcache1_inv_valid
add wave -noupdate -expand -group {dcache1 inv interface} /system_tb/DUT/dcache1_inv_block_addr
add wave -noupdate -expand -group {dcache1 inv interface} /system_tb/DUT/dcache1_evict_valid
add wave -noupdate -expand -group {dcache1 inv interface} /system_tb/DUT/dcache1_evict_block_addr
add wave -noupdate -expand -group {imem1 interface} /system_tb/DUT/imem1_REN
add wave -noupdate -expand -group {imem1 interface} /system_tb/DUT/imem1_block_addr
add wave -noupdate -expand -group {imem1 interface} /system_tb/DUT/imem1_hit
add wave -noupdate -expand -group {imem1 interface} /system_tb/DUT/imem1_load
add wave -noupdate -expand -group {dbus1 req interface} /system_tb/DUT/dbus1_req_valid
add wave -noupdate -expand -group {dbus1 req interface} /system_tb/DUT/dbus1_req_block_addr
add wave -noupdate -expand -group {dbus1 req interface} /system_tb/DUT/dbus1_req_exclusive
add wave -noupdate -expand -group {dbus1 req interface} /system_tb/DUT/dbus1_req_curr_state
add wave -noupdate -expand -group {dbus1 resp interface} /system_tb/DUT/dbus1_resp_valid
add wave -noupdate -expand -group {dbus1 resp interface} /system_tb/DUT/dbus1_resp_block_addr
add wave -noupdate -expand -group {dbus1 resp interface} /system_tb/DUT/dbus1_resp_data
add wave -noupdate -expand -group {dbus1 resp interface} /system_tb/DUT/dbus1_resp_need_block
add wave -noupdate -expand -group {dbus1 resp interface} /system_tb/DUT/dbus1_resp_new_state
add wave -noupdate -expand -group {snoop1 req interface} /system_tb/DUT/snoop1_req_valid
add wave -noupdate -expand -group {snoop1 req interface} /system_tb/DUT/snoop1_req_block_addr
add wave -noupdate -expand -group {snoop1 req interface} /system_tb/DUT/snoop1_req_exclusive
add wave -noupdate -expand -group {snoop1 req interface} /system_tb/DUT/snoop1_req_curr_state
add wave -noupdate -expand -group {snoop1 resp interface} /system_tb/DUT/snoop1_resp_valid
add wave -noupdate -expand -group {snoop1 resp interface} /system_tb/DUT/snoop1_resp_block_addr
add wave -noupdate -expand -group {snoop1 resp interface} /system_tb/DUT/snoop1_resp_data
add wave -noupdate -expand -group {snoop1 resp interface} /system_tb/DUT/snoop1_resp_present
add wave -noupdate -expand -group {snoop1 resp interface} /system_tb/DUT/snoop1_resp_need_block
add wave -noupdate -expand -group {snoop1 resp interface} /system_tb/DUT/snoop1_resp_new_state
add wave -noupdate -expand -group {dmem1 read req interface} /system_tb/DUT/dmem1_read_req_valid
add wave -noupdate -expand -group {dmem1 read req interface} /system_tb/DUT/dmem1_read_req_block_addr
add wave -noupdate -expand -group {dmem1 read resp interface} /system_tb/DUT/dmem1_read_resp_valid
add wave -noupdate -expand -group {dmem1 read resp interface} /system_tb/DUT/dmem1_read_resp_data
add wave -noupdate -expand -group {dmem1 write req interface} /system_tb/DUT/dmem1_write_req_valid
add wave -noupdate -expand -group {dmem1 write req interface} /system_tb/DUT/dmem1_write_req_block_addr
add wave -noupdate -expand -group {dmem1 write req interface} /system_tb/DUT/dmem1_write_req_data
add wave -noupdate -expand -group {dmem1 write req interface} /system_tb/DUT/dmem1_write_req_slow_down
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2542727811 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 311
configure wave -valuecolwidth 202
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
WaveRestoreZoom {2542182950 ps} {2543421950 ps}
