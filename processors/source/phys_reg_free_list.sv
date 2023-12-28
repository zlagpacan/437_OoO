/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_free_list.sv
    Instantiation Hierarchy: system -> core -> phys_reg_free_list
    Description: 
        The Physical Register Free List is a FIFO providing the next free physical register which a new
        register writing instruction can rename an architectural register to. The table can also checkpoint
        a free list which can be restored using a FIFO of free list head pointers.
*/

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_free_list #(

) (
    // seq
    input logic CLK, nRST,

    // dequeue
    input logic dequeue_valid,
    output phys_reg_tag_t dequeue_phys_reg_tag,

    // enqueue
    input logic enqueue_valid,
    input phys_reg_tag_t enqueue_phys_reg_tag,

    // free list checkpoint save
    input logic save_checkpoint_valid,
    input ROB_index_t save_checkpoint_ROB_index,    // from ROB, write tag val
    output checkpoint_column_t save_checkpoint_safe_column,

    // free list checkpoint restore
    input logic restore_checkpoint_valid,
    input logic restore_checkpoint_speculate_failed,
    input ROB_index_t restore_checkpoint_ROB_index,  // from restore system, check tag val
    input checkpoint_column_t restore_checkpoint_safe_column,
    output logic restore_checkpoint_success
);

endmodule