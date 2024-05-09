onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/CLK
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/nRST
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/test_case
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/sub_test_case
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/test_num
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/num_errors
add wave -noupdate -expand -group {TB Signals} /snoop_dcache_tb/tb_error
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_DUT_error
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_req_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_req_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_req_linked
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_req_conditional
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_read_req_blocked
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_read_req_blocked
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_read_resp_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_read_resp_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_read_resp_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_read_resp_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_read_resp_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_read_resp_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_write_req_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_write_req_conditional
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_write_req_blocked
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_write_req_blocked
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_kill_0_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_kill_0_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_kill_1_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_read_kill_1_LQ_index
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_inv_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_inv_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_inv_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_inv_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_evict_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_evict_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dcache_evict_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dcache_evict_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dcache_halt
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dbus_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dbus_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dbus_req_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dbus_req_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dbus_req_exclusive
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dbus_req_exclusive
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dbus_req_curr_state
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dbus_req_curr_state
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dbus_resp_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dbus_resp_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dbus_resp_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dbus_resp_need_block
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dbus_resp_new_state
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_snoop_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_snoop_req_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_snoop_req_exclusive
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_snoop_req_curr_state
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_snoop_resp_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_snoop_resp_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_snoop_resp_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_snoop_resp_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_snoop_resp_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_snoop_resp_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_snoop_resp_present
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_snoop_resp_present
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_snoop_resp_need_block
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_snoop_resp_need_block
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_snoop_resp_new_state
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_snoop_resp_new_state
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dmem_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dmem_write_req_valid
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dmem_write_req_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dmem_write_req_block_addr
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_dmem_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_dmem_write_req_data
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/tb_dmem_write_req_slow_down
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/DUT_flushed
add wave -noupdate -expand -group {Top Level Signals} /snoop_dcache_tb/expected_flushed
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_DUT_error
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/dcache_read_req_addr_structed
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/dcache_write_req_addr_structed
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/dcache_tag_frame_by_way_by_set
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_dcache_tag_frame_by_way_by_set
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/dcache_data_frame_by_way_by_set
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_dcache_data_frame_by_way_by_set
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_tag_frame_by_way_by_set
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_tag_frame_by_way_by_set
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/dcache_set_LRU
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_dcache_set_LRU
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/load_MSHR_by_LQ_index
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_load_MSHR_by_LQ_index
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_MSHR
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_store_MSHR
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_MSHR_Q
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_store_MSHR_Q
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_MSHR_Q_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_store_MSHR_Q_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_MSHR_Q_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_store_MSHR_Q_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/dcache_state
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_dcache_state
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/flush_counter
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_flush_counter
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/new_load_miss_reg
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_new_load_miss_reg
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/new_store_miss_reg
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_new_store_miss_reg
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/backlog_Q_bus_read_req_by_entry
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_backlog_Q_bus_read_req_by_entry
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/backlog_Q_bus_read_req_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_backlog_Q_bus_read_req_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/load_hit_this_cycle
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_hit_this_cycle
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/found_load_MSHR_fulfilled
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/found_load_MSHR_LQ_index
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/found_empty_way
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/empty_way
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/load_hit_return
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_load_hit_return
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/load_miss_return_Q
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_load_miss_return_Q
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/load_miss_return_Q_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_load_miss_return_Q_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/load_miss_return_Q_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_load_miss_return_Q_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/hit_counter
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_hit_counter
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/found_store_MSHR_Q_valid_entry
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_flushed
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/piggyback_bus_valid
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/piggyback_bus_block_addr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/piggyback_bus_way
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/piggyback_bus_new_state
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_miss_upgrading
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/store_miss_upgrading_way
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_access_allowed
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_search_VTM_success
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_search_VTM_way
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_search_VTM_state
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_req_Q
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_req_Q
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_req_Q_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_req_Q_head_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/snoop_req_Q_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_req_Q_tail_ptr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_resp_valid
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_resp_block_addr
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_resp_data
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_resp_present
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_resp_need_block
add wave -noupdate -expand -group {Internal Signals} /snoop_dcache_tb/DUT/next_snoop_resp_new_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {52500 ps}
