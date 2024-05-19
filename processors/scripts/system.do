onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CLK
add wave -noupdate /system_tb/DUT/nRST
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate -divider {System Level Signals}
add wave -noupdate -expand -group prif /system_tb/DUT/prif/ramREN
add wave -noupdate -expand -group prif /system_tb/DUT/prif/ramWEN
add wave -noupdate -expand -group prif /system_tb/DUT/prif/ramaddr
add wave -noupdate -expand -group prif /system_tb/DUT/prif/ramstore
add wave -noupdate -expand -group prif /system_tb/DUT/prif/ramload
add wave -noupdate -expand -group prif /system_tb/DUT/prif/ramstate
add wave -noupdate -expand -group prif /system_tb/DUT/prif/memREN
add wave -noupdate -expand -group prif /system_tb/DUT/prif/memWEN
add wave -noupdate -expand -group prif /system_tb/DUT/prif/memaddr
add wave -noupdate -expand -group prif /system_tb/DUT/prif/memstore
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
add wave -noupdate -expand -group {Hang Detector Signals} /system_tb/DUT/hang_detector_count
add wave -noupdate -expand -group {Hang Detector Signals} /system_tb/DUT/next_hang_detector_count
add wave -noupdate -expand -group {Hang Detector Signals} /system_tb/DUT/hang_detected
add wave -noupdate -expand -group {Hang Detector Signals} /system_tb/DUT/next_hang_detected
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
add wave -noupdate -divider {Internal Signals}
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/CLK
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/nRST
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/icache_hit
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/icache_load
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/icache_REN
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/icache_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/icache_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_req_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_req_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_req_linked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_req_conditional
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_req_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_resp_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_resp_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_resp_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_write_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_write_req_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_write_req_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_write_req_conditional
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_write_req_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_kill_0_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_kill_0_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_kill_1_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_read_kill_1_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_inv_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_inv_block_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_evict_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_evict_block_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/dcache_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_from_pipeline_BTB_DIRP_update
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_from_pipeline_BTB_DIRP_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_from_pipeline_BTB_target
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_from_pipeline_DIRP_taken
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_from_pipeline_take_resolved
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_from_pipeline_resolved_PC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_icache_hit
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_icache_load
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_core_control_stall_fetch_unit
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_core_control_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_icache_REN
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_icache_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_icache_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_to_pipeline_instr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_to_pipeline_ivalid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_to_pipeline_PC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/FU_to_pipeline_nPC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_core_control_stall_dispatch_unit
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_core_control_flush_dispatch_unit
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_core_control_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_core_control_dispatch_failed
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_fetch_unit_instr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_fetch_unit_ivalid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_fetch_unit_PC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_fetch_unit_nPC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_restore_checkpoint_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_restore_checkpoint_speculate_failed
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_restore_checkpoint_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_restore_checkpoint_safe_column
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_restore_checkpoint_success
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_kill_bus_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_kill_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_kill_bus_arch_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_kill_bus_speculated_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_kill_bus_safe_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_complete_bus_0_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_complete_bus_1_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_complete_bus_2_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ROB_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ROB_tail_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ROB_enqueue_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ROB_struct_out
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ROB_retire_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ROB_retire_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ALU_RS_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ALU_RS_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_ALU_RS_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_LQ_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_LQ_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_LQ_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_SQ_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_SQ_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_SQ_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_BRU_RS_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_BRU_RS_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/DU_BRU_RS_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_empty
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_fetch_unit_take_resolved
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_fetch_unit_resolved_PC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_dispatch_unit_ROB_tail_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_dispatch_unit_enqueue_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_dispatch_unit_enqueue_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_dispatch_unit_retire_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_dispatch_unit_retire_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_0_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_0_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_1_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_1_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_2_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_complete_bus_2_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_BRU_complete_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_BRU_restart_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_BRU_restart_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_BRU_restart_PC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_BRU_restart_safe_column
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_LQ_restart_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_LQ_restart_after_instr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_LQ_restart_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_LQ_retire_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_LQ_retire_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_LQ_retire_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_SQ_complete_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_SQ_complete_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_SQ_retire_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_SQ_retire_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_SQ_retire_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_restore_checkpoint_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_restore_checkpoint_speculate_failed
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_restore_checkpoint_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_restore_checkpoint_safe_column
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_restore_checkpoint_success
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_revert_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_revert_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_revert_arch_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_revert_safe_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_revert_speculated_phys_reg_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_kill_bus_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_kill_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_core_control_restore_flush
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_core_control_revert_stall
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/ROB_core_control_halt_assert
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_read_overload
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_read_req_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_BRU_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_BRU_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_BRU_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_BRU_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_SQ_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_SQ_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_SQ_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_SQ_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_read_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_read_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_write_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_write_req_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_write_req_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_LQ_write_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_write_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_write_req_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_write_req_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_0_write_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_write_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_write_req_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_write_req_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/PRF_ALU_1_write_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_ALU_RS_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_dispatch_unit_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_dispatch_unit_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_reg_file_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_reg_file_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_reg_file_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_reg_file_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_reg_file_read_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_reg_file_read_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_kill_bus_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_kill_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_0_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_1_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_2_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_2_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_complete_bus_2_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_this_complete_bus_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_this_complete_bus_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_this_complete_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_this_complete_bus_data_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP0_this_complete_bus_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_ALU_RS_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_dispatch_unit_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_dispatch_unit_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_reg_file_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_reg_file_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_reg_file_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_reg_file_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_reg_file_read_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_reg_file_read_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_kill_bus_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_kill_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_0_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_1_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_2_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_2_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_complete_bus_2_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_this_complete_bus_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_this_complete_bus_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_this_complete_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_this_complete_bus_data_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/AP1_this_complete_bus_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_BRU_RS_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_dispatch_unit_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_dispatch_unit_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_reg_file_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_reg_file_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_reg_file_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_reg_file_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_reg_file_read_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_reg_file_read_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_kill_bus_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_kill_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_0_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_1_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_2_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_2_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_complete_bus_2_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_complete_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_restart_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_restart_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_restart_PC
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_restart_safe_column
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_BTB_DIRP_update
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_BTB_DIRP_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_BTB_target
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/BP_this_DIRP_taken
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_DUT_error
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dispatch_unit_LQ_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dispatch_unit_LQ_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dispatch_unit_LQ_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dispatch_unit_SQ_full
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dispatch_unit_SQ_task_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dispatch_unit_SQ_task_struct
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_kill_bus_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_kill_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_core_control_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_LQ_restart_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_LQ_restart_after_instr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_LQ_restart_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_LQ_retire_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_LQ_retire_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_LQ_retire_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_SQ_complete_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_SQ_complete_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_SQ_retire_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_SQ_retire_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_ROB_SQ_retire_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_LQ_reg_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_LQ_reg_read_req_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_LQ_reg_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_LQ_reg_read_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_SQ_reg_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_SQ_reg_read_req_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_SQ_reg_read_req_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_SQ_reg_read_req_serviced
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_SQ_reg_read_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_SQ_reg_read_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_this_complete_bus_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_this_complete_bus_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_this_complete_bus_ROB_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_this_complete_bus_data_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_this_complete_bus_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_req_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_req_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_req_linked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_req_conditional
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_req_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_resp_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_resp_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_resp_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_write_req_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_write_req_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_write_req_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_write_req_conditional
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_write_req_blocked
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_kill_0_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_kill_0_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_kill_1_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_read_kill_1_LQ_index
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_inv_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_inv_block_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_evict_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_evict_block_addr
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_dcache_halt
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_0_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_0_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_0_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_1_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_1_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_1_data
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_2_tag_valid
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_2_tag
add wave -noupdate -group {core0 Signals} /system_tb/DUT/CORE0/LSQ_complete_bus_2_data
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/CLK
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/nRST
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/DUT_error
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/icache_REN
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/icache_addr
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/icache_halt
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/icache_hit
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/icache_load
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/imem_REN
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/imem_block_addr
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/imem_hit
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/imem_load
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/next_DUT_error
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/loop_way
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/next_loop_way
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/stream_buffer
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/next_stream_buffer
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/stream_state
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/next_stream_state
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/stream_counter
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/next_stream_counter
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/missing_block_addr
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/next_missing_block_addr
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/missing_plus_counter_block_addr
add wave -noupdate -group {icache0 Signals} /system_tb/DUT/ICACHE0/icache_addr_structed
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/CLK
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/nRST
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/DUT_error
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_linked
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_conditional
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_blocked
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_resp_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_resp_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_resp_data
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_write_req_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_write_req_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_write_req_data
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_write_req_conditional
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_write_req_blocked
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_kill_0_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_kill_0_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_kill_1_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_kill_1_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_inv_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_inv_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_evict_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_evict_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_halt
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_req_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_req_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_req_exclusive
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_req_curr_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_resp_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_resp_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_resp_data
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_resp_need_block
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dbus_resp_new_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_exclusive
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_curr_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_resp_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_resp_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_resp_data
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_resp_present
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_resp_need_block
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_resp_new_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dmem_write_req_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dmem_write_req_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dmem_write_req_data
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dmem_write_req_slow_down
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/flushed
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_DUT_error
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_read_req_addr_structed
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_write_req_addr_structed
add wave -noupdate -group {snoop_dcache0 Signals} -expand -subitemconfig {{/system_tb/DUT/SNOOP_DCACHE0/dcache_tag_frame_by_way_by_set[1]} -expand {/system_tb/DUT/SNOOP_DCACHE0/dcache_tag_frame_by_way_by_set[0]} -expand} /system_tb/DUT/SNOOP_DCACHE0/dcache_tag_frame_by_way_by_set
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_tag_frame_by_way_by_set
add wave -noupdate -group {snoop_dcache0 Signals} -expand -subitemconfig {{/system_tb/DUT/SNOOP_DCACHE0/dcache_data_frame_by_way_by_set[1]} -expand {/system_tb/DUT/SNOOP_DCACHE0/dcache_data_frame_by_way_by_set[0]} -expand} /system_tb/DUT/SNOOP_DCACHE0/dcache_data_frame_by_way_by_set
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_data_frame_by_way_by_set
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_tag_frame_by_way_by_set
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_tag_frame_by_way_by_set
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_set_LRU
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_set_LRU
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_MSHR_by_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_load_MSHR_by_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_MSHR
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_store_MSHR
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_MSHR_Q
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_store_MSHR_Q
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_MSHR_Q_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_store_MSHR_Q_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_MSHR_Q_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_store_MSHR_Q_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/dcache_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/flush_counter
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_flush_counter
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/new_load_miss_reg
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_new_load_miss_reg
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/new_store_miss_reg
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_new_store_miss_reg
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/backlog_Q_bus_read_req_by_entry
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_backlog_Q_bus_read_req_by_entry
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/backlog_Q_bus_read_req_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_backlog_Q_bus_read_req_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_hit_this_cycle
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_hit_this_cycle
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/found_load_MSHR_fulfilled
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/found_load_MSHR_LQ_index
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/found_empty_way
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/empty_way
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_hit_return
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_load_hit_return
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_miss_return_Q
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_load_miss_return_Q
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_miss_return_Q_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_load_miss_return_Q_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_miss_return_Q_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_load_miss_return_Q_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/hit_counter
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_hit_counter
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/found_store_MSHR_Q_valid_entry
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_flushed
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/piggyback_bus_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/piggyback_bus_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/piggyback_bus_way
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/piggyback_bus_new_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_miss_upgrading
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/store_miss_upgrading_way
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_access_allowed
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_search_VTM_success
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_search_VTM_way
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_search_VTM_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_Q
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_req_Q
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_Q_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_req_Q_head_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/snoop_req_Q_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_req_Q_tail_ptr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_resp_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_resp_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_resp_data
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_resp_present
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_resp_need_block
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_snoop_resp_new_state
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_inv_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_inv_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_evict_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_dcache_evict_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/link_reg
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_link_reg
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/link_reg_self_inv_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_link_reg_self_inv_valid
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/link_reg_self_inv_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_link_reg_self_inv_block_addr
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/load_conditional_return
add wave -noupdate -group {snoop_dcache0 Signals} /system_tb/DUT/SNOOP_DCACHE0/next_load_conditional_return
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PC_RESET_VAL
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/CLK
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/nRST
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/icache_hit
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/icache_load
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/icache_REN
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/icache_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/icache_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_req_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_req_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_req_linked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_req_conditional
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_req_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_resp_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_resp_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_resp_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_write_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_write_req_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_write_req_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_write_req_conditional
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_write_req_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_kill_0_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_kill_0_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_kill_1_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_read_kill_1_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_inv_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_inv_block_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_evict_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_evict_block_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/dcache_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_from_pipeline_BTB_DIRP_update
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_from_pipeline_BTB_DIRP_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_from_pipeline_BTB_target
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_from_pipeline_DIRP_taken
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_from_pipeline_take_resolved
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_from_pipeline_resolved_PC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_icache_hit
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_icache_load
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_core_control_stall_fetch_unit
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_core_control_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_icache_REN
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_icache_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_icache_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_to_pipeline_instr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_to_pipeline_ivalid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_to_pipeline_PC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/FU_to_pipeline_nPC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_core_control_stall_dispatch_unit
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_core_control_flush_dispatch_unit
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_core_control_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_core_control_dispatch_failed
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_fetch_unit_instr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_fetch_unit_ivalid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_fetch_unit_PC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_fetch_unit_nPC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_restore_checkpoint_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_restore_checkpoint_safe_column
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_restore_checkpoint_success
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_kill_bus_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_kill_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_kill_bus_arch_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_kill_bus_speculated_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_kill_bus_safe_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_complete_bus_0_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_complete_bus_1_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_complete_bus_2_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_complete_bus_2_dest_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ROB_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ROB_tail_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ROB_enqueue_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ROB_struct_out
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ROB_retire_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ROB_retire_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ALU_RS_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ALU_RS_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_ALU_RS_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_LQ_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_LQ_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_LQ_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_SQ_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_SQ_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_SQ_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_BRU_RS_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_BRU_RS_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/DU_BRU_RS_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_empty
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_fetch_unit_take_resolved
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_fetch_unit_resolved_PC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_dispatch_unit_ROB_tail_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_dispatch_unit_enqueue_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_dispatch_unit_enqueue_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_dispatch_unit_retire_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_dispatch_unit_retire_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_0_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_0_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_1_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_1_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_2_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_2_dest_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_complete_bus_2_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_BRU_complete_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_BRU_restart_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_BRU_restart_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_BRU_restart_PC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_BRU_restart_safe_column
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_LQ_restart_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_LQ_restart_after_instr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_LQ_retire_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_LQ_retire_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_LQ_retire_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_SQ_complete_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_SQ_retire_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_SQ_retire_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_SQ_retire_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_restore_checkpoint_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_restore_checkpoint_speculate_failed
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_restore_checkpoint_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_restore_checkpoint_safe_column
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_restore_checkpoint_success
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_revert_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_revert_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_revert_arch_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_revert_safe_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_revert_speculated_phys_reg_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_kill_bus_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_kill_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_core_control_restore_flush
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_core_control_revert_stall
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/ROB_core_control_halt_assert
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_read_overload
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_read_req_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_BRU_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_BRU_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_BRU_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_BRU_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_SQ_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_SQ_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_SQ_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_SQ_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_read_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_read_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_write_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_write_req_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_write_req_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_LQ_write_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_write_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_write_req_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_write_req_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_0_write_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_write_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_write_req_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_write_req_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/PRF_ALU_1_write_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_ALU_RS_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_dispatch_unit_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_dispatch_unit_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_reg_file_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_reg_file_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_reg_file_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_reg_file_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_reg_file_read_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_reg_file_read_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_kill_bus_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_kill_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_0_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_1_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_2_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_2_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_complete_bus_2_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_this_complete_bus_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_this_complete_bus_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_this_complete_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_this_complete_bus_data_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP0_this_complete_bus_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_ALU_RS_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_dispatch_unit_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_dispatch_unit_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_reg_file_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_reg_file_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_reg_file_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_reg_file_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_reg_file_read_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_reg_file_read_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_kill_bus_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_kill_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_0_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_1_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_2_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_2_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_complete_bus_2_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_this_complete_bus_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_this_complete_bus_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_this_complete_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_this_complete_bus_data_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/AP1_this_complete_bus_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_BRU_RS_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_dispatch_unit_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_dispatch_unit_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_reg_file_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_reg_file_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_reg_file_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_reg_file_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_reg_file_read_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_reg_file_read_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_kill_bus_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_kill_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_0_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_1_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_2_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_2_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_complete_bus_2_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_complete_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_restart_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_restart_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_restart_PC
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_restart_safe_column
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_BTB_DIRP_update
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_BTB_DIRP_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_BTB_target
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/BP_this_DIRP_taken
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_DUT_error
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dispatch_unit_LQ_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dispatch_unit_LQ_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dispatch_unit_LQ_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dispatch_unit_SQ_full
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dispatch_unit_SQ_task_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dispatch_unit_SQ_task_struct
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_kill_bus_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_kill_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_core_control_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_LQ_restart_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_LQ_restart_after_instr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_LQ_restart_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_LQ_retire_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_LQ_retire_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_LQ_retire_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_SQ_complete_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_SQ_complete_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_SQ_retire_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_SQ_retire_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_ROB_SQ_retire_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_LQ_reg_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_LQ_reg_read_req_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_LQ_reg_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_LQ_reg_read_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_SQ_reg_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_SQ_reg_read_req_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_SQ_reg_read_req_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_SQ_reg_read_req_serviced
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_SQ_reg_read_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_SQ_reg_read_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_this_complete_bus_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_this_complete_bus_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_this_complete_bus_ROB_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_this_complete_bus_data_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_this_complete_bus_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_req_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_req_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_req_linked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_req_conditional
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_req_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_resp_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_resp_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_resp_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_write_req_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_write_req_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_write_req_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_write_req_conditional
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_write_req_blocked
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_kill_0_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_kill_0_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_kill_1_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_read_kill_1_LQ_index
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_inv_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_inv_block_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_evict_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_evict_block_addr
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_dcache_halt
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_0_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_0_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_0_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_1_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_1_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_1_data
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_2_tag_valid
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_2_tag
add wave -noupdate -expand -group {core1 Signals} /system_tb/DUT/CORE1/LSQ_complete_bus_2_data
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/CLK
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/nRST
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/DUT_error
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/icache_REN
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/icache_addr
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/icache_halt
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/icache_hit
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/icache_load
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/imem_REN
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/imem_block_addr
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/imem_hit
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/imem_load
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/next_DUT_error
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/loop_way
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/next_loop_way
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/stream_buffer
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/next_stream_buffer
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/stream_state
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/next_stream_state
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/stream_counter
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/next_stream_counter
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/missing_block_addr
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/next_missing_block_addr
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/missing_plus_counter_block_addr
add wave -noupdate -group {icache1 Signals} /system_tb/DUT/ICACHE1/icache_addr_structed
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/CLK
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/nRST
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/DUT_error
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_linked
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_conditional
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_blocked
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_resp_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_resp_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_resp_data
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_write_req_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_write_req_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_write_req_data
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_write_req_conditional
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_write_req_blocked
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_kill_0_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_kill_0_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_kill_1_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_kill_1_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_inv_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_inv_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_evict_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_evict_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_halt
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_req_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_req_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_req_exclusive
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_req_curr_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_resp_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_resp_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_resp_data
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_resp_need_block
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dbus_resp_new_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_exclusive
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_curr_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_resp_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_resp_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_resp_data
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_resp_present
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_resp_need_block
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_resp_new_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dmem_write_req_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dmem_write_req_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dmem_write_req_data
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dmem_write_req_slow_down
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/flushed
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_DUT_error
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_read_req_addr_structed
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_write_req_addr_structed
add wave -noupdate -expand -group {snoop_dcache1 Signals} -expand -subitemconfig {{/system_tb/DUT/SNOOP_DCACHE1/dcache_tag_frame_by_way_by_set[1]} -expand {/system_tb/DUT/SNOOP_DCACHE1/dcache_tag_frame_by_way_by_set[0]} -expand} /system_tb/DUT/SNOOP_DCACHE1/dcache_tag_frame_by_way_by_set
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_tag_frame_by_way_by_set
add wave -noupdate -expand -group {snoop_dcache1 Signals} -expand -subitemconfig {{/system_tb/DUT/SNOOP_DCACHE1/dcache_data_frame_by_way_by_set[1]} -expand {/system_tb/DUT/SNOOP_DCACHE1/dcache_data_frame_by_way_by_set[0]} -expand} /system_tb/DUT/SNOOP_DCACHE1/dcache_data_frame_by_way_by_set
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_data_frame_by_way_by_set
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_tag_frame_by_way_by_set
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_tag_frame_by_way_by_set
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_set_LRU
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_set_LRU
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_MSHR_by_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_load_MSHR_by_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_MSHR
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_store_MSHR
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_MSHR_Q
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_store_MSHR_Q
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_MSHR_Q_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_store_MSHR_Q_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_MSHR_Q_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_store_MSHR_Q_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/dcache_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/flush_counter
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_flush_counter
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/new_load_miss_reg
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_new_load_miss_reg
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/new_store_miss_reg
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_new_store_miss_reg
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/backlog_Q_bus_read_req_by_entry
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_backlog_Q_bus_read_req_by_entry
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/backlog_Q_bus_read_req_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_backlog_Q_bus_read_req_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_hit_this_cycle
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_hit_this_cycle
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/found_load_MSHR_fulfilled
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/found_load_MSHR_LQ_index
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/found_empty_way
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/empty_way
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_hit_return
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_load_hit_return
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_miss_return_Q
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_load_miss_return_Q
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_miss_return_Q_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_load_miss_return_Q_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_miss_return_Q_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_load_miss_return_Q_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/hit_counter
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_hit_counter
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/found_store_MSHR_Q_valid_entry
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_flushed
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/piggyback_bus_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/piggyback_bus_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/piggyback_bus_way
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/piggyback_bus_new_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_miss_upgrading
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/store_miss_upgrading_way
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_access_allowed
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_search_VTM_success
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_search_VTM_way
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_search_VTM_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_Q
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_req_Q
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_Q_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_req_Q_head_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/snoop_req_Q_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_req_Q_tail_ptr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_resp_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_resp_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_resp_data
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_resp_present
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_resp_need_block
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_snoop_resp_new_state
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_inv_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_inv_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_evict_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_dcache_evict_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/link_reg
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_link_reg
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/link_reg_self_inv_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_link_reg_self_inv_valid
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/link_reg_self_inv_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_link_reg_self_inv_block_addr
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/load_conditional_return
add wave -noupdate -expand -group {snoop_dcache1 Signals} /system_tb/DUT/SNOOP_DCACHE1/next_load_conditional_return
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/CLK
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/nRST
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/DUT_error
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_exclusive
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_curr_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_resp_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_resp_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_resp_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_resp_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_resp_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_exclusive
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_curr_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_resp_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_resp_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_resp_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_resp_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_resp_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_req_exclusive
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_req_curr_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_present
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_req_exclusive
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_req_curr_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_present
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_resp_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_resp_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_resp_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_resp_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_DUT_error
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/grant_DUT_error
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/resp_DUT_error
add wave -noupdate -group {bus_controller Signals} -expand /system_tb/DUT/BUS_CONTROLLER/dbus0_req_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dbus0_req_Q
add wave -noupdate -group {bus_controller Signals} -expand /system_tb/DUT/BUS_CONTROLLER/dbus1_req_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dbus1_req_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_Q_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dbus0_req_Q_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dbus0_req_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_Q_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dbus1_req_Q_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dbus1_req_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} -expand -subitemconfig {{/system_tb/DUT/BUS_CONTROLLER/conflict_table_count_by_way_by_set[1]} -expand {/system_tb/DUT/BUS_CONTROLLER/conflict_table_count_by_way_by_set[0]} -expand} /system_tb/DUT/BUS_CONTROLLER/conflict_table_count_by_way_by_set
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_conflict_table_count_by_way_by_set
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_conflict_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_conflict_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_resp_conflict_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_resp_conflict_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus0_req_conflict
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dbus1_req_conflict
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_req_exclusive
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_req_curr_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_req_valid
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_req_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_req_exclusive
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_req_curr_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_resp_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem0_read_resp_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_resp_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem1_read_resp_Q
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_resp_Q_resp_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem0_read_resp_Q_resp_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_resp_Q_return_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem0_read_resp_Q_return_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem0_read_resp_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem0_read_resp_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_resp_Q_resp_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem1_read_resp_Q_resp_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_resp_Q_return_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem1_read_resp_Q_return_head_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/dmem1_read_resp_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_dmem1_read_resp_Q_tail_ptr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_reg_ready_now
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_resp_reg_ready_now
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_reg_need_mem
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_resp_reg_need_mem
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_reg_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_resp_reg_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_reg_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_resp_reg_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_reg_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_resp_reg_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop0_resp_reg_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop0_resp_reg_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_reg_ready_now
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_resp_reg_ready_now
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_reg_need_mem
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_resp_reg_need_mem
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_reg_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_resp_reg_block_addr
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_reg_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_resp_reg_data
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_reg_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_resp_reg_need_block
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/snoop1_resp_reg_new_state
add wave -noupdate -group {bus_controller Signals} /system_tb/DUT/BUS_CONTROLLER/next_snoop1_resp_reg_new_state
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/CLK
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/nRST
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/DUT_error
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem0_REN
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem0_block_addr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem0_hit
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem0_load
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem1_REN
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem1_block_addr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem1_hit
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem1_load
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_read_req_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_read_req_block_addr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_read_req_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_read_req_block_addr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_read_resp_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_read_resp_data
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_read_resp_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_read_resp_data
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_write_req_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_write_req_block_addr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_write_req_data
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem0_write_req_slow_down
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_write_req_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_write_req_block_addr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_write_req_data
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dmem1_write_req_slow_down
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dcache0_flushed
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/dcache1_flushed
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/mem_controller_flushed
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_DUT_error
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/mem_controller_state
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_mem_controller_state
add wave -noupdate -group {dual_mem_controller Signals} -expand /system_tb/DUT/DUAL_MEM_CONTROLLER/read_buffer
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_read_buffer
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/read_buffer_head_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_read_buffer_head_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/read_buffer_tail_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_read_buffer_tail_ptr
add wave -noupdate -group {dual_mem_controller Signals} -expand /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_write_buffer
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer_head_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_write_buffer_head_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer_tail_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_write_buffer_tail_ptr
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/working_req
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_working_req
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_dmem0_read_resp_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_dmem1_read_resp_valid
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_mem_controller_flushed
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer_search_found
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer_search_youngest_found_index
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer_search_first_half_youngest_found_index
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_write_buffer_search_first_half_youngest_found_index
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/write_buffer_search_data
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/imem_LRU
add wave -noupdate -group {dual_mem_controller Signals} /system_tb/DUT/DUAL_MEM_CONTROLLER/next_imem_LRU
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/CLK
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/nRST
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/DUT_error
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/full
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/empty
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/fetch_unit_take_resolved
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/fetch_unit_resolved_PC
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_ROB_tail_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_enqueue_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_enqueue_struct
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_retire_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_retire_phys_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_0_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_0_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_1_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_1_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_2_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_2_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_complete_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_PC
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_safe_column
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_restart_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_restart_after_instr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_restart_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_retire_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_retire_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_retire_blocked
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_complete_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_complete_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_retire_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_retire_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_retire_blocked
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_speculate_failed
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_safe_column
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_success
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/revert_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/revert_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/revert_arch_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/revert_safe_phys_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/revert_speculated_phys_reg_tag
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/kill_bus_valid
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/kill_bus_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/core_control_restore_flush
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/core_control_revert_stall
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/core_control_halt_assert
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_state_out
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/invalid_complete
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_capacity
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_DUT_error
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_array_by_entry
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_ROB_array_by_entry
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/head_index_ptr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_head_index_ptr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/tail_index_ptr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_tail_index_ptr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restart_ROB_index_ptr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_restart_ROB_index_ptr
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/restart_column
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_restart_column
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/inorder_kill_start_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_inorder_kill_start_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/inorder_kill_end_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_inorder_kill_end_ROB_index
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_full
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_empty
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_state
add wave -noupdate -group {core0 ROB Signals} /system_tb/DUT/CORE0/ROB/next_ROB_state
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/CLK
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/nRST
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/DUT_error
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_LQ_full
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_LQ_task_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_LQ_task_struct
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_SQ_full
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_SQ_task_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_SQ_task_struct
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/kill_bus_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/kill_bus_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/core_control_halt
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_restart_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_restart_after_instr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_restart_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_retire_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_retire_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_retire_blocked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_complete_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_complete_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_retire_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_retire_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_retire_blocked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_req_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_req_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_req_serviced
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_bus_0_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_0_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_1_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_serviced
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_bus_0_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_bus_1_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_tag_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_data_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_blocked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_resp_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_resp_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_resp_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_blocked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_0_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_0_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_1_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_1_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_inv_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_inv_block_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_evict_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_evict_block_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_halt
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_0_tag_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_0_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_0_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_1_tag_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_1_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_1_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_2_tag_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_2_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_2_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_DUT_error
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_pipeline_DUT_error
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_pipeline_DUT_error
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/central_LSQ_DUT_error
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_busy
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_head_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_head_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_tail_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_tail_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_head_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_head_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_tail_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_tail_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_SQ_search_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_SQ_search_ptr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_0_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_0_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_1_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_1_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_0_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_0_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_1_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_1_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_reg_file_write_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_reg_file_write_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_forwarded_write_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_write_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_forwarded_write_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_write_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_write_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_write_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_write_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_busy
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_source_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_source_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_source_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_source_ready
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_reg_file_read_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_operand_complete_bus_0_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_operand_complete_bus_1_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_operand_complete_bus_2_VTM
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_imm14
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_forwarded_read_base_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_read_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_linked
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_read_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_read_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_array
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_array
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_full
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_full
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_empty
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_empty
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_array
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_array
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_full
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_full
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_empty
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_empty
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_conditional
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_req_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_req_read_addr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_req_SQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_ambiguous
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_unwritten_present
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_unwritten_youngest_older_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_unwritten_youngest_older_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_written_present
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_written_youngest_older_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_written_youngest_older_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_resp_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_search_resp_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_resp_present
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_search_resp_present
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_resp_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_search_resp_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_data_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_data
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_missed_SQ_forward_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_missed_SQ_forward_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_inv_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_inv_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_inv_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_evict_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_evict_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_evict_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_combined_dcache_inv_evict_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_restart_combined_dcache_inv_evict_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_combined_dcache_inv_evict_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_restart_combined_dcache_inv_evict_LQ_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_combined_dcache_inv_evict_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_restart_combined_dcache_inv_evict_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_ROB_LQ_restart_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_ROB_LQ_restart_after_instr
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_ROB_LQ_restart_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_tag_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_tag
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_ROB_index
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_next_this_complete_bus_data_valid
add wave -noupdate -group {core0 LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_next_this_complete_bus_data
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/CLK
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/nRST
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/DUT_error
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/full
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/empty
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/fetch_unit_take_resolved
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/fetch_unit_resolved_PC
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/dispatch_unit_ROB_tail_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/dispatch_unit_enqueue_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/dispatch_unit_enqueue_struct
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/dispatch_unit_retire_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/dispatch_unit_retire_phys_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_0_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_0_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_1_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_1_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_2_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/complete_bus_2_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/BRU_complete_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/BRU_restart_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/BRU_restart_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/BRU_restart_PC
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/BRU_restart_safe_column
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/LQ_restart_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/LQ_restart_after_instr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/LQ_restart_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/LQ_retire_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/LQ_retire_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/LQ_retire_blocked
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/SQ_complete_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/SQ_complete_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/SQ_retire_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/SQ_retire_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/SQ_retire_blocked
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restore_checkpoint_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restore_checkpoint_speculate_failed
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restore_checkpoint_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restore_checkpoint_safe_column
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restore_checkpoint_success
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/revert_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/revert_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/revert_arch_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/revert_safe_phys_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/revert_speculated_phys_reg_tag
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/kill_bus_valid
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/kill_bus_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/core_control_restore_flush
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/core_control_revert_stall
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/core_control_halt_assert
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/ROB_state_out
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/invalid_complete
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/ROB_capacity
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_DUT_error
add wave -noupdate -group {core1 ROB Signals} -expand /system_tb/DUT/CORE1/ROB/ROB_array_by_entry
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_ROB_array_by_entry
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/head_index_ptr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_head_index_ptr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/tail_index_ptr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_tail_index_ptr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restart_ROB_index_ptr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_restart_ROB_index_ptr
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/restart_column
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_restart_column
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/inorder_kill_start_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_inorder_kill_start_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/inorder_kill_end_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_inorder_kill_end_ROB_index
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_full
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_empty
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/ROB_state
add wave -noupdate -group {core1 ROB Signals} /system_tb/DUT/CORE1/ROB/next_ROB_state
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/CLK
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/nRST
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/DUT_error
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/dispatch_source_0_phys_reg_tag
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/dispatch_source_0_ready
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/dispatch_source_1_phys_reg_tag
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/dispatch_source_1_ready
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/dispatch_dest_write
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/dispatch_dest_phys_reg_tag
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/complete_bus_0_valid
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/complete_bus_1_valid
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/complete_bus_2_valid
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/next_DUT_error
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/ready_table_by_phys_reg_tag_index
add wave -noupdate -group {core1 PRRT Signals} /system_tb/DUT/CORE1/DU/prrt/next_ready_table_by_phys_reg_tag_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/CLK
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/nRST
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/DUT_error
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dispatch_unit_LQ_full
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dispatch_unit_LQ_task_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dispatch_unit_LQ_task_struct
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dispatch_unit_SQ_full
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dispatch_unit_SQ_task_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dispatch_unit_SQ_task_struct
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/kill_bus_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/kill_bus_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/core_control_halt
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_LQ_restart_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_LQ_restart_after_instr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_LQ_restart_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_LQ_retire_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_LQ_retire_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_LQ_retire_blocked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_SQ_complete_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_SQ_complete_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_SQ_retire_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_SQ_retire_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/ROB_SQ_retire_blocked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_req_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_req_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_req_serviced
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_bus_0_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_req_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_req_0_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_req_1_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_req_serviced
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_bus_0_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_bus_1_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/this_complete_bus_tag_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/this_complete_bus_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/this_complete_bus_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/this_complete_bus_data_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/this_complete_bus_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_req_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_req_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_req_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_req_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_req_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_req_blocked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_resp_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_resp_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_resp_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_write_req_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_write_req_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_write_req_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_write_req_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_write_req_blocked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_kill_0_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_kill_0_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_kill_1_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_read_kill_1_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_inv_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_inv_block_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_evict_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_evict_block_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/dcache_halt
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_0_tag_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_0_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_0_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_1_tag_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_1_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_1_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_2_tag_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_2_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/complete_bus_2_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_DUT_error
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_pipeline_DUT_error
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_pipeline_DUT_error
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/central_LSQ_DUT_error
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_busy
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_head_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_head_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_tail_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_tail_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_head_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_head_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_tail_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_tail_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_SQ_search_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_SQ_search_ptr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_source_0_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_source_0_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_source_1_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_source_1_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_task_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_source_0_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_source_0_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_source_1_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_source_1_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_reg_read_stage_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_reg_file_write_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_reg_file_write_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_reg_read_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_forwarded_write_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_write_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_addr_calc_stage_forwarded_write_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_update_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_operand_update_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_update_stage_write_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_operand_update_stage_write_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_update_stage_write_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_operand_update_stage_write_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_operand_update_stage_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_operand_update_stage_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_busy
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_source_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_source_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_task_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_source_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_source_ready
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_reg_read_stage_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_reg_file_read_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_operand_complete_bus_0_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_operand_complete_bus_1_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_reg_read_stage_operand_complete_bus_2_VTM
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_imm14
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_forwarded_read_base_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_addr_calc_stage_read_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_update_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_operand_update_stage_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_update_stage_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_operand_update_stage_linked
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_update_stage_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_operand_update_stage_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_update_stage_read_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_operand_update_stage_read_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_operand_update_stage_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_operand_update_stage_LQ_index
add wave -noupdate -group {core1 LSQ Signals} -expand -subitemconfig {{/system_tb/DUT/CORE1/LSQ/LQ_array[2]} -expand} /system_tb/DUT/CORE1/LSQ/LQ_array
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_array
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_full
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_full
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_empty
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_empty
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_array
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_array
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_full
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_full
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_empty
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_empty
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_dcache_write_req_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_dcache_write_req_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_dcache_write_req_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_dcache_write_req_conditional
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_req_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_req_read_addr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_req_SQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_ambiguous
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_unwritten_present
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_unwritten_youngest_older_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_unwritten_youngest_older_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_written_present
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_written_youngest_older_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_CAM_written_youngest_older_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_resp_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_search_resp_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_resp_present
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_search_resp_present
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/SQ_search_resp_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_SQ_search_resp_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_this_complete_bus_data_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_this_complete_bus_data
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_missed_SQ_forward_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_missed_SQ_forward_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_dcache_inv_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_dcache_inv_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_dcache_inv_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_dcache_evict_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_dcache_evict_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_dcache_evict_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_combined_dcache_inv_evict_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_restart_combined_dcache_inv_evict_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_combined_dcache_inv_evict_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_restart_combined_dcache_inv_evict_LQ_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/LQ_restart_combined_dcache_inv_evict_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_LQ_restart_combined_dcache_inv_evict_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_ROB_LQ_restart_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_ROB_LQ_restart_after_instr
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_ROB_LQ_restart_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_this_complete_bus_tag_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_this_complete_bus_tag
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_this_complete_bus_ROB_index
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_next_this_complete_bus_data_valid
add wave -noupdate -group {core1 LSQ Signals} /system_tb/DUT/CORE1/LSQ/next_next_this_complete_bus_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3840000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 346
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
WaveRestoreZoom {2537700 ps} {6767206 ps}
