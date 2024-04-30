onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/nRST
add wave -noupdate -expand -group {RAM Signals} /system_tb/DUT/prif/ramREN
add wave -noupdate -expand -group {RAM Signals} /system_tb/DUT/prif/ramWEN
add wave -noupdate -expand -group {RAM Signals} /system_tb/DUT/prif/ramaddr
add wave -noupdate -expand -group {RAM Signals} /system_tb/DUT/prif/ramstore
add wave -noupdate -expand -group {RAM Signals} /system_tb/DUT/prif/ramload
add wave -noupdate -expand -group {RAM Signals} /system_tb/DUT/prif/ramstate
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/core_DUT_error
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/icache_DUT_error
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_DUT_error
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/mem_controller_DUT_error
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/icache_hit
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/icache_load
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/icache_REN
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/icache_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/icache_halt
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_req_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_req_LQ_index
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_req_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_req_linked
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_req_conditional
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_req_blocked
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_resp_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_resp_LQ_index
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_resp_data
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_write_req_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_write_req_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_write_req_data
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_write_req_conditional
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_write_req_blocked
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_kill_0_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_kill_0_LQ_index
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_kill_1_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_read_kill_1_LQ_index
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_inv_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_inv_block_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_halt
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/imem_REN
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/imem_block_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/imem_hit
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/imem_load
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_read_req_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_read_req_block_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_read_resp_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_read_resp_block_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_read_resp_data
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_write_req_valid
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_write_req_block_addr
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_write_req_data
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dmem_write_req_slow_down
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/dcache_flushed
add wave -noupdate -expand -group {SYSTEM Signals} /system_tb/DUT/mem_controller_flushed
add wave -noupdate -divider {CORE0 Signals}
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/DUT_error
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/from_pipeline_BTB_DIRP_update
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/from_pipeline_BTB_DIRP_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/from_pipeline_BTB_target
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/from_pipeline_DIRP_taken
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/from_pipeline_take_resolved
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/from_pipeline_resolved_PC
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/icache_hit
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/icache_load
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/icache_REN
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/icache_addr
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/icache_halt
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/core_control_stall_fetch_unit
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/core_control_halt
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/to_pipeline_instr
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/to_pipeline_ivalid
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/to_pipeline_PC
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/to_pipeline_nPC
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/FU_state_out
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_DUT_error
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/PC
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/nPC
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/PC_plus_4
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/jPC
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/RAS_pop_val
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/BTB_target
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/FU_state
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_FU_state
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/BTB_DIRP_entry_by_frame_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_BTB_DIRP_entry_by_frame_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/BTB_DIRP_frame_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/DIRP_state
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/RAS_entry_by_top_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_RAS_entry_by_top_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/RAS_top_write_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_RAS_top_write_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/RAS_top_read_index
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/RAS_push_val
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/instr
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/is_beq_bne
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/is_j
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/is_jal
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/is_jr
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/is_ra
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/is_halt
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_icache_REN
add wave -noupdate -group {Fetch Unit Signals} /system_tb/DUT/CORE0/FU/next_icache_halt
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/DUT_error
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/core_control_stall_dispatch_unit
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/core_control_flush_dispatch_unit
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/core_control_halt
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/core_control_dispatch_failed
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/fetch_unit_instr
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/fetch_unit_ivalid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/fetch_unit_PC
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/fetch_unit_nPC
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/restore_checkpoint_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/restore_checkpoint_speculate_failed
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/restore_checkpoint_ROB_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/restore_checkpoint_safe_column
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/restore_checkpoint_success
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/kill_bus_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/kill_bus_ROB_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/kill_bus_arch_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/kill_bus_speculated_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/kill_bus_safe_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/complete_bus_0_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/complete_bus_1_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/complete_bus_2_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ROB_full
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ROB_tail_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ROB_enqueue_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ROB_struct_out
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ROB_retire_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ROB_retire_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ALU_RS_full
add wave -noupdate -group {Dispatch Unit Signals} -expand /system_tb/DUT/CORE0/DU/ALU_RS_task_valid
add wave -noupdate -group {Dispatch Unit Signals} -expand -subitemconfig {{/system_tb/DUT/CORE0/DU/ALU_RS_task_struct[1]} -expand {/system_tb/DUT/CORE0/DU/ALU_RS_task_struct[0]} -expand} /system_tb/DUT/CORE0/DU/ALU_RS_task_struct
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/LQ_full
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/LQ_task_valid
add wave -noupdate -group {Dispatch Unit Signals} -expand /system_tb/DUT/CORE0/DU/LQ_task_struct
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/SQ_full
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/SQ_task_valid
add wave -noupdate -group {Dispatch Unit Signals} -expand /system_tb/DUT/CORE0/DU/SQ_task_struct
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/BRU_RS_full
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/BRU_RS_task_valid
add wave -noupdate -group {Dispatch Unit Signals} -expand /system_tb/DUT/CORE0/DU/BRU_RS_task_struct
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/next_DUT_error
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_DUT_error
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_source_arch_reg_tag_0
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_source_phys_reg_tag_0
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_source_arch_reg_tag_1
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_source_phys_reg_tag_1
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_old_dest_arch_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_old_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_rename_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_rename_dest_arch_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_rename_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_revert_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_revert_dest_arch_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_revert_safe_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_revert_speculated_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_save_checkpoint_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_save_checkpoint_ROB_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_save_checkpoint_safe_column
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_restore_checkpoint_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_restore_checkpoint_speculate_failed
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_restore_checkpoint_ROB_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_restore_checkpoint_safe_column
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prmt_restore_checkpoint_success
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_DUT_error
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_dequeue_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_dequeue_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_enqueue_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_enqueue_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_full
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_empty
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_revert_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_revert_speculated_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_save_checkpoint_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_save_checkpoint_ROB_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_save_checkpoint_safe_column
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_restore_checkpoint_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_restore_checkpoint_speculate_failed
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_restore_checkpoint_ROB_index
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_restore_checkpoint_safe_column
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prfl_restore_checkpoint_success
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_DUT_error
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_dispatch_source_0_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_dispatch_source_0_ready
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_dispatch_source_1_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_dispatch_source_1_ready
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_dispatch_dest_write
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_dispatch_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_complete_bus_0_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_complete_bus_1_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_complete_bus_2_valid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/prrt_complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/dispatch_unit_instr
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/dispatch_unit_ivalid
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/dispatch_unit_PC
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/dispatch_unit_nPC
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_rtype
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_itype
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_jtype
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_opcode
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_rs
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_rt
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_rd
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_imm16
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/instr_funct
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ALU_RS_select
add wave -noupdate -group {Dispatch Unit Signals} /system_tb/DUT/CORE0/DU/ALU_RS_both_full
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/DUT_error
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/source_arch_reg_tag_0
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/source_phys_reg_tag_0
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/source_arch_reg_tag_1
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/source_phys_reg_tag_1
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/old_dest_arch_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/old_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/rename_valid
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/rename_dest_arch_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/rename_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/revert_valid
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/revert_dest_arch_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/revert_safe_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/revert_speculated_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/save_checkpoint_valid
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/save_checkpoint_ROB_index
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/save_checkpoint_safe_column
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/restore_checkpoint_valid
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/restore_checkpoint_speculate_failed
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/restore_checkpoint_ROB_index
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/restore_checkpoint_safe_column
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/restore_checkpoint_success
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/next_DUT_error
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/phys_reg_map_table_columns_by_column_index
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/next_phys_reg_map_table_columns_by_column_index
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/phys_reg_map_table_working_column
add wave -noupdate -group {Phys Reg Map Table Signals} /system_tb/DUT/CORE0/DU/prmt/next_phys_reg_map_table_working_column
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/DUT_error
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/dequeue_valid
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/dequeue_phys_reg_tag
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/enqueue_valid
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/enqueue_phys_reg_tag
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/full
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/empty
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/revert_valid
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/revert_speculated_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/save_checkpoint_valid
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/save_checkpoint_ROB_index
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/save_checkpoint_safe_column
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/restore_checkpoint_valid
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/restore_checkpoint_speculate_failed
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/restore_checkpoint_ROB_index
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/restore_checkpoint_safe_column
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/restore_checkpoint_success
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_DUT_error
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/phys_reg_free_list_by_index
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_phys_reg_free_list_by_index
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/head_index_ptr
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_head_index_ptr
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/prev_head_index_ptr
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/tail_index_ptr
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_tail_index_ptr
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/checkpoint_columns_by_column_index
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_checkpoint_columns_by_column_index
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/checkpoint_tail_column
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_checkpoint_tail_column
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_full
add wave -noupdate -group {Phys Reg Free List Signals} /system_tb/DUT/CORE0/DU/prfl/next_empty
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/DUT_error
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/dispatch_source_0_phys_reg_tag
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/dispatch_source_0_ready
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/dispatch_source_1_phys_reg_tag
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/dispatch_source_1_ready
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/dispatch_dest_write
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/dispatch_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/complete_bus_0_valid
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/complete_bus_1_valid
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/complete_bus_2_valid
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/next_DUT_error
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/ready_table_by_phys_reg_tag_index
add wave -noupdate -group {Phys Reg Ready Table Signals} /system_tb/DUT/CORE0/DU/prrt/next_ready_table_by_phys_reg_tag_index
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/DUT_error
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/read_overload
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_read_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_read_req_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_read_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_read_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_read_req_0_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_read_req_1_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_read_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_read_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_read_req_0_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_read_req_1_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_read_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/BRU_read_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/BRU_read_req_0_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/BRU_read_req_1_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/BRU_read_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/SQ_read_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/SQ_read_req_0_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/SQ_read_req_1_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/SQ_read_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/read_bus_0_data
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/read_bus_1_data
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_write_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_write_req_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_write_req_data
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/LQ_write_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_write_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_write_req_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_write_req_data
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_0_write_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_write_req_valid
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_write_req_tag
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_write_req_data
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/ALU_1_write_req_serviced
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/next_DUT_error
add wave -noupdate -group {Phys Reg File Signals} -expand /system_tb/DUT/CORE0/PRF/phys_reg_file
add wave -noupdate -group {Phys Reg File Signals} /system_tb/DUT/CORE0/PRF/next_phys_reg_file
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/DUT_error
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/full
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/empty
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/fetch_unit_take_resolved
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/fetch_unit_resolved_PC
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_ROB_tail_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_enqueue_valid
add wave -noupdate -group {ROB Signals} -expand /system_tb/DUT/CORE0/ROB/dispatch_unit_enqueue_struct
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_retire_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/dispatch_unit_retire_phys_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_0_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_0_dest_phys_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_0_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_1_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_1_dest_phys_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_1_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_2_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_2_dest_phys_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/complete_bus_2_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_complete_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_PC
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/BRU_restart_safe_column
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_restart_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_restart_after_instr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_restart_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_retire_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_retire_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/LQ_retire_blocked
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_complete_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_complete_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_retire_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_retire_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/SQ_retire_blocked
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_speculate_failed
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_safe_column
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restore_checkpoint_success
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/revert_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/revert_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/revert_arch_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/revert_safe_phys_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/revert_speculated_phys_reg_tag
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/kill_bus_valid
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/kill_bus_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/core_control_restore_flush
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/core_control_revert_stall
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/core_control_halt_assert
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_state_out
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/invalid_complete
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_capacity
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_DUT_error
add wave -noupdate -group {ROB Signals} -expand /system_tb/DUT/CORE0/ROB/ROB_array_by_entry
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_ROB_array_by_entry
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/head_index_ptr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_head_index_ptr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/tail_index_ptr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_tail_index_ptr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restart_ROB_index_ptr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_restart_ROB_index_ptr
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/restart_column
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_restart_column
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/inorder_kill_start_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_inorder_kill_start_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/inorder_kill_end_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_inorder_kill_end_ROB_index
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_full
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_empty
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/ROB_state
add wave -noupdate -group {ROB Signals} /system_tb/DUT/CORE0/ROB/next_ROB_state
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/DUT_error
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/ALU_RS_full
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/dispatch_unit_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} -expand /system_tb/DUT/CORE0/AP0/dispatch_unit_task_struct
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/reg_file_read_req_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/reg_file_read_req_0_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/reg_file_read_req_1_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/reg_file_read_req_serviced
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/reg_file_read_bus_0_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/reg_file_read_bus_1_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/kill_bus_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/kill_bus_ROB_index
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_0_tag_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_0_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_0_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_1_tag_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_1_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_1_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_2_tag_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_2_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/complete_bus_2_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/this_complete_bus_tag_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/this_complete_bus_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/this_complete_bus_ROB_index
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/this_complete_bus_data_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/this_complete_bus_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_DUT_error
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_RS_stage_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_task_struct
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_RS_stage_task_struct
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_op
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_op
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_operand_0
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_operand_0
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_operand_1
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_operand_1
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_operand_0_bus_select
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_operand_0_bus_select
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_operand_1_bus_select
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_operand_1_bus_select
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_tag
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_ROB_index
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_EX_stage_ROB_index
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/DATA_stage_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_DATA_stage_task_valid
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/DATA_stage_output_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/next_DATA_stage_output_data
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_1_imm32
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/RS_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_A
add wave -noupdate -group {ALU Pipeline 0 Signals} /system_tb/DUT/CORE0/AP0/EX_stage_B
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/DUT_error
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/ALU_RS_full
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/dispatch_unit_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/dispatch_unit_task_struct
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/reg_file_read_req_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/reg_file_read_req_0_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/reg_file_read_req_1_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/reg_file_read_req_serviced
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/reg_file_read_bus_0_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/reg_file_read_bus_1_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/kill_bus_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/kill_bus_ROB_index
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_0_tag_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_0_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_0_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_1_tag_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_1_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_1_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_2_tag_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_2_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/complete_bus_2_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/this_complete_bus_tag_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/this_complete_bus_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/this_complete_bus_ROB_index
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/this_complete_bus_data_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/this_complete_bus_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_DUT_error
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_RS_stage_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_task_struct
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_RS_stage_task_struct
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_op
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_op
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_operand_0
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_operand_0
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_operand_1
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_operand_1
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_operand_0_bus_select
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_operand_0_bus_select
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_operand_1_bus_select
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_operand_1_bus_select
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_tag
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_ROB_index
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_EX_stage_ROB_index
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/DATA_stage_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_DATA_stage_task_valid
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/DATA_stage_output_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/next_DATA_stage_output_data
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_1_imm32
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/RS_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_A
add wave -noupdate -group {ALU Pipeline 1 Signals} /system_tb/DUT/CORE0/AP1/EX_stage_B
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/DUT_error
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/BRU_RS_full
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/dispatch_unit_task_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/dispatch_unit_task_struct
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/reg_file_read_req_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/reg_file_read_req_0_tag
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/reg_file_read_req_1_tag
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/reg_file_read_req_serviced
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/reg_file_read_bus_0_data
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/reg_file_read_bus_1_data
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/kill_bus_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/kill_bus_ROB_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_0_tag_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_0_tag
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_0_data
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_1_tag_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_1_tag
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_1_data
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_2_tag_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_2_tag
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/complete_bus_2_data
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_complete_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_restart_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_restart_ROB_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_restart_PC
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_restart_safe_column
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_BTB_DIRP_update
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_BTB_DIRP_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_BTB_target
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/this_DIRP_taken
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_DUT_error
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_task_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_RS_stage_task_valid
add wave -noupdate -group {BRU Pipeline Signals} -expand /system_tb/DUT/CORE0/BP/RS_stage_task_struct
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_RS_stage_task_struct
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_task_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_task_valid
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_op
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_op
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_operand_0
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_operand_0
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_operand_1
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_operand_1
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_operand_0_bus_select
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_operand_0_bus_select
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_operand_1_bus_select
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_operand_1_bus_select
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_BTB_DIRP_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_BTB_DIRP_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_branch_PC
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_branch_PC
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_PC_plus_4
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_PC_plus_4
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_nPC
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_nPC
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_checkpoint_safe_column
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_checkpoint_safe_column
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_ROB_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/next_EX_stage_ROB_index
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/RS_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_A
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/EX_stage_B
add wave -noupdate -group {BRU Pipeline Signals} /system_tb/DUT/CORE0/BP/flush_BP
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/DUT_error
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_LQ_full
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_LQ_task_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_LQ_task_struct
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_SQ_full
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_SQ_task_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dispatch_unit_SQ_task_struct
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/kill_bus_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/kill_bus_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/core_control_halt
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_restart_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_restart_after_instr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_restart_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_retire_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_retire_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_LQ_retire_blocked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_complete_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_complete_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_retire_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_retire_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/ROB_SQ_retire_blocked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_req_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_req_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_req_serviced
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_bus_0_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_0_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_1_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_req_serviced
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_bus_0_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_bus_1_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_tag_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_data_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/this_complete_bus_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_req_blocked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_resp_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_resp_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_resp_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_write_req_blocked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_0_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_0_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_1_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_read_kill_1_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_inv_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_inv_block_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/dcache_halt
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_0_tag_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_0_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_0_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_1_tag_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_1_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_1_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_2_tag_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_2_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/complete_bus_2_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_DUT_error
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_pipeline_DUT_error
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_pipeline_DUT_error
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/central_LSQ_DUT_error
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_busy
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_head_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_head_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_tail_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_tail_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_head_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_head_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_tail_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_tail_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_SQ_search_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_SQ_search_ptr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_0_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_0_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_1_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_source_1_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_task_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_0_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_0_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_0_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_1_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_1_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_source_1_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_reg_read_stage_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_reg_file_write_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_reg_file_write_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_0_complete_bus_0_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_0_complete_bus_1_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_0_complete_bus_2_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_1_complete_bus_0_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_1_complete_bus_1_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_reg_read_stage_operand_1_complete_bus_2_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_reg_file_write_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_reg_file_write_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_operand_0_bus_select
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_addr_calc_stage_operand_1_bus_select
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_forwarded_write_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_write_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_addr_calc_stage_forwarded_write_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_write_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_write_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_write_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_write_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_operand_update_stage_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_operand_update_stage_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_busy
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_source_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_source_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_task_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_source_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_source_ready
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_source_phys_reg_tag
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_reg_read_stage_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_reg_file_read_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_operand_complete_bus_0_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_operand_complete_bus_1_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_reg_read_stage_operand_complete_bus_2_VTM
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_reg_file_read_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_imm14
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_addr_calc_stage_operand_bus_select
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_forwarded_read_base_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_addr_calc_stage_read_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_linked
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_read_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_read_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_operand_update_stage_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_operand_update_stage_LQ_index
add wave -noupdate -group {LSQ Signals} -expand -subitemconfig {{/system_tb/DUT/CORE0/LSQ/LQ_array[3]} -expand} /system_tb/DUT/CORE0/LSQ/LQ_array
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_array
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_full
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_full
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_empty
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_LQ_empty
add wave -noupdate -group {LSQ Signals} -expand -subitemconfig {{/system_tb/DUT/CORE0/LSQ/SQ_array[0]} -expand} /system_tb/DUT/CORE0/LSQ/SQ_array
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_array
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_full
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_full
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_empty
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_empty
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_dcache_write_req_conditional
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_req_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_req_read_addr
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_req_SQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_CAM_ambiguous
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_resp_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_search_resp_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_resp_present
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_search_resp_present
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/SQ_search_resp_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_SQ_search_resp_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_data_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/next_this_complete_bus_data
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_missed_SQ_forward_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_missed_SQ_forward_ROB_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_inv_valid
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_inv_LQ_index
add wave -noupdate -group {LSQ Signals} /system_tb/DUT/CORE0/LSQ/LQ_restart_dcache_inv_ROB_index
add wave -noupdate -divider {ICACHE0 Signals}
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/DUT_error
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/icache_REN
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/icache_addr
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/icache_halt
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/icache_hit
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/icache_load
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/imem_REN
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/imem_block_addr
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/imem_hit
add wave -noupdate -expand -group {ICACHE0 Top Level Signals} /system_tb/DUT/ICACHE0/imem_load
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/next_DUT_error
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/loop_way
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/next_loop_way
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/stream_buffer
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/next_stream_buffer
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/stream_state
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/next_stream_state
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/stream_counter
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/next_stream_counter
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/missing_block_addr
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/next_missing_block_addr
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/missing_plus_counter_block_addr
add wave -noupdate -expand -group {ICACHE0 Internal Signals} /system_tb/DUT/ICACHE0/icache_addr_structed
add wave -noupdate -divider {DCACHE0 Signals}
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/DUT_error
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_req_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_req_LQ_index
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_req_addr
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_req_linked
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_req_conditional
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_req_blocked
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_resp_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_resp_LQ_index
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_resp_data
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_write_req_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_write_req_addr
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_write_req_data
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_write_req_conditional
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_write_req_blocked
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_kill_0_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_kill_0_LQ_index
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_kill_1_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_read_kill_1_LQ_index
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_inv_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_inv_block_addr
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dcache_halt
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_read_req_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_read_req_block_addr
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_read_resp_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_read_resp_block_addr
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_read_resp_data
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_write_req_valid
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_write_req_block_addr
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_write_req_data
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/dmem_write_req_slow_down
add wave -noupdate -expand -group {DCACHE0 Top Level Signals} /system_tb/DUT/DCACHE0/flushed
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_DUT_error
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/dcache_read_req_addr_structed
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/dcache_write_req_addr_structed
add wave -noupdate -expand -group {DCACHE0 Internal Signals} -expand -subitemconfig {{/system_tb/DUT/DCACHE0/dcache_frame_by_way_by_set[1]} -expand {/system_tb/DUT/DCACHE0/dcache_frame_by_way_by_set[0]} -expand} /system_tb/DUT/DCACHE0/dcache_frame_by_way_by_set
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_dcache_frame_by_way_by_set
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/dcache_set_LRU
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_dcache_set_LRU
add wave -noupdate -expand -group {DCACHE0 Internal Signals} -expand /system_tb/DUT/DCACHE0/load_MSHR_by_LQ_index
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_load_MSHR_by_LQ_index
add wave -noupdate -expand -group {DCACHE0 Internal Signals} -expand /system_tb/DUT/DCACHE0/store_MSHR
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_store_MSHR
add wave -noupdate -expand -group {DCACHE0 Internal Signals} -expand /system_tb/DUT/DCACHE0/store_MSHR_Q
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_store_MSHR_Q
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/store_MSHR_Q_head_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_store_MSHR_Q_head_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/store_MSHR_Q_tail_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_store_MSHR_Q_tail_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/dcache_state
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_dcache_state
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/flush_counter
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_flush_counter
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/new_load_miss_reg
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_new_load_miss_reg
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/new_store_miss_reg
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_new_store_miss_reg
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/backlog_Q_bus_read_req_by_entry
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_backlog_Q_bus_read_req_by_entry
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/backlog_Q_bus_read_req_head_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_backlog_Q_bus_read_req_head_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_backlog_Q_bus_read_req_tail_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/load_hit_this_cycle
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/store_hit_this_cycle
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/found_load_MSHR_fulfilled
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/found_load_MSHR_LQ_index
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/found_empty_way
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/empty_way
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/load_hit_return
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_load_hit_return
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/load_miss_return_Q
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_load_miss_return_Q
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/load_miss_return_Q_head_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_load_miss_return_Q_head_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/load_miss_return_Q_tail_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_load_miss_return_Q_tail_ptr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/hit_counter
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_hit_counter
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/found_store_MSHR_Q_valid_entry
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/next_flushed
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/piggyback_bus_valid
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/piggyback_bus_block_addr
add wave -noupdate -expand -group {DCACHE0 Internal Signals} /system_tb/DUT/DCACHE0/piggyback_bus_way
add wave -noupdate -divider {MEM_CONTROLLER Signals}
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/DUT_error
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/imem_REN
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/imem_block_addr
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/imem_hit
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/imem_load
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_read_req_valid
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_read_req_block_addr
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_read_resp_valid
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_read_resp_block_addr
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_read_resp_data
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_write_req_valid
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_write_req_block_addr
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_write_req_data
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dmem_write_req_slow_down
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/dcache_flushed
add wave -noupdate -expand -group {MEM_CONTROLLER Top Level Signals} /system_tb/DUT/MEM_CONTROLLER/mem_controller_flushed
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_DUT_error
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/mem_controller_state
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_mem_controller_state
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/read_buffer
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_read_buffer
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/read_buffer_head_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_read_buffer_head_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/read_buffer_tail_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_read_buffer_tail_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_write_buffer
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer_head_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_write_buffer_head_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer_tail_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_write_buffer_tail_ptr
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/working_req
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_working_req
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_dmem_read_resp_valid
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_mem_controller_flushed
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer_search_found
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer_search_youngest_found_index
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer_search_first_half_youngest_found_index
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/next_write_buffer_search_first_half_youngest_found_index
add wave -noupdate -expand -group {MEM_CONTROLLER Internal Signals} /system_tb/DUT/MEM_CONTROLLER/write_buffer_search_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4377457 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {4175 ns} {5414 ns}
