/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_file.sv
    Instantiation Hierarchy: system -> core -> rob
    Description: 
        The Reorder Buffer tracks dispatched instructions in a FIFO, checking for their completion so they
        can be retired.
        
        The Reorder Buffer also provides the mechanisms for rolling back mis-speculated instructions. This
        includes sending a checkpoint command to the dispatch_unit, and/or broadcasting to the kill bus.

        The ROB interfaces with:

            - Dispatch Unit
                - ROB receives new instruction struct and valid for struct
                - ROB gives ROB index so on instr completion knows where to write
                - ROB gives retired phys reg tags which can safely be renamed to

            - Complete Buses 0,1,2
                - ROB receives complete @ ROB index
                - assign buses as follows:
                    - complete bus 0: ALU 0
                    - complete bus 1: ALU 1
                    - complete bus 2: LQ

            - Branch Resolution Unit
                - ROB receives complete @ ROB index
                - ROB receives restart info

            - Load Queue
                - ROB receives restart info
                - ROB sends retire to LQ so it can dequeue

            - Store Queue
                - ROB receives complete @ ROB index
                - ROB sends retire to SQ so it can perform the store

            - Restore Bus
                - ROB sends restore command
                - also Core Control

            - Kill Bus
                - ROB sends kill command
                - also Core Control

            - Core Control
                - ROB sends signals intended to flush or stall fetch and dispatch
                - ROB sends halt assertion
                    - when halt instr retires

        ROB depth will only matter if get more cycles in ROB (possible instr dispatches) than instr takes
        to execute. Worst case for 437, get new dispatch each cycle, wait for bus (15 cycles) + long 
        coherent bus (5 cycles) + full mem (10 cycles) + reg read cycle + complete cycle ~= 31 cycles. 
            - 32 should be enough for no delays in worst case.
            - 16 or even 8 should be plenty for common case no ROB stalls
*/

`include "core_types.vh"
import core_types_pkg::*;

module rob (

    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // full/empty
    output logic full,
    output logic empty,

    // dispatch unit interface
    // dispatch @ tail
    output ROB_index_t ROB_tail_index,
    input logic ROB_enqueue_valid,
    input ROB_entry_t ROB_struct_out,
    // retire from head
    output logic ROB_retire_valid,
    output phys_reg_tag_t ROB_retire_phys_reg_tag,
    
    // complete bus interfaces
        // want ROB index for complete write
        // ROB doesn't need write tag but can use for assertion
    input logic complete_bus_0_valid,
    input phys_reg_tag_t complete_bus_0_dest_phys_reg_tag,
    input ROB_index_t complete_bus_0_ROB_index,
    input logic complete_bus_1_valid,
    input phys_reg_tag_t complete_bus_1_dest_phys_reg_tag,
    input ROB_index_t complete_bus_1_ROB_index,
    input logic complete_bus_2_valid,
    input phys_reg_tag_t complete_bus_2_dest_phys_reg_tag,
    input ROB_index_t complete_bus_2_ROB_index,

    // BRU interface
    // complete
    input logic BRU_complete_valid,
    input ROB_index_t BRU_complete_ROB_index,
    // restart info
    input logic BRU_restart_valid,
    input ROB_index_t BRU_restart_ROB_index,
    input pc_t BRU_restart_PC,
    input checkpoint_column_t BRU_restart_safe_column,

    // LQ interface
    // retire
    output logic LQ_retire_valid,
    output ROB_index_t LQ_retire_ROB_index,
    // restart info
    input logic LQ_restart_valid,
    input ROB_index_t LQ_restart_ROB_index,

    // SQ interface
    // complete
    input logic SQ_complete_valid,
    input ROB_index_t SQ_complete_ROB_index,
    // retire
    output logic SQ_retire_valid,
    output ROB_index_t SQ_retire_ROB_index,

    // restore bus interface
        // send restore command and check for success
    output logic restore_checkpoint_valid,
    output logic restore_checkpoint_speculate_failed, // send successful one on BRU complete
    output ROB_index_t restore_checkpoint_ROB_index,
    output checkpoint_column_t restore_checkpoint_safe_column,
    input logic restore_checkpoint_success

    // kill bus interface
        // send kill command
    output logic kill_bus_valid,
    output ROB_index_t kill_bus_ROB_index,
    output arch_reg_tag_t kill_bus_arch_reg_tag,
    output phys_reg_tag_t kill_bus_safe_phys_reg_tag,
    output phys_reg_tag_t kill_bus_speculated_phys_reg_tag,

    // core control interface
    output logic core_control_restore_flush,
    output logic core_control_kill_stall,
    output logic core_control_halt_assert,
        // for when halt instr retires
);

endmodule