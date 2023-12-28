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

    // full/empty
        // should be left unused by may want to account for potential functionality externally
        // can use for assertions
    output logic full,
    output logic empty,

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

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // free list FIFO array:

    phys_reg_tag_t [FREE_LIST_DEPTH-1:0] phys_reg_free_list_by_index;
    phys_reg_tag_t [FREE_LIST_DEPTH-1:0] next_phys_reg_free_list_by_index;

    // free list FIFO pointers
        // lower bits for indexing array
        // msb for detecting empty/full
    // typedef logic [LOG_FREE_LIST_DEPTH:0] free_list_ptr_t;
    typedef struct packed {
        logic [LOG_FREE_LIST_DEPTH-1:0] index;
        logic msb;
    } free_list_ptr_t;

    // head
    free_list_ptr_t head_index_ptr;
    free_list_ptr_t next_head_index_ptr;

    // tail
    free_list_ptr_t tail_index_ptr;
    free_list_ptr_t next_tail_index_ptr;

    // FIFO array of checkpoint head pointers
    typedef struct packed {
        logic valid;
        ROB_index_t ROB_index;
        free_list_ptr_t checkpoint_head_index_ptr;
    } free_list_checkpoint_column_t;

    free_list_checkpoint_column_t [CHECKPOINT_COLUMNS-1:0] checkpoint_columns_by_column_index;
    free_list_checkpoint_column_t [CHECKPOINT_COLUMNS-1:0] next_checkpoint_columns_by_column_index;
        // tail column: where next speculated head ptr will be appended to the checkpoint head FIFO
    checkpoint_column_t checkpoint_tail_column;
    checkpoint_column_t next_checkpoint_tail_column;

    // logic:

    // seq
    always_ff @ (posedge CLK, nRST) begin
        if (~nRST) begin
            ///////////////////////////////////////////////////////////////////////////////////////////////
            // phys reg free list:
                // reset free list follows phys reg tags > arch reg tags
            for (int i = 0; i < FREE_LIST_DEPTH; i++) begin
                phys_reg_free_list_by_index[free_list_ptr_t'(i)] <= phys_reg_tag_t'(NUM_ARCH_REGS + i);
            end
            ///////////////////////////////////////////////////////////////////////////////////////////////
            
            // reset with free list full
            head_index_ptr.index <= '0;
            head_index_ptr.msb <= 1'b0;
            tail_index_ptr.index <= '0;
            tail_index_ptr.msb <= 1'b1;

            // start with no checkpoints
            checkpoint_columns_by_column_index <= '0;
            checkpoint_tail_column <= checkpoint_column_t'(0);
        end
        else begin
            phys_reg_free_list_by_index <= next_phys_reg_free_list_by_index;
            head_index_ptr <= next_head_index_ptr;
            tail_index_ptr <= next_head_index_ptr;
            checkpoint_columns_by_column_index <= next_checkpoint_columns_by_column_index;
            checkpoint_tail_column <= next_checkpoint_tail_column;
        end
    end

    // free list array access logic
    always_comb begin

        // constant connections:
        
        // dequeue read
        dequeue_phys_reg_tag = phys_reg_free_list_by_index[head_index_ptr.index];

        // defaults:

        // enqueue logic:

        // dequeue logic
    end

    // free list full/empty
    always_comb begin

        // default: not full/empty
        full = 1'b0;
        empty = 1'b0;

        // check for full/empty
        if (head_index_ptr.index == tail_index_ptr.index) begin

            // check for empty
            if (head_index_ptr.msb == tail_index_ptr.msb) begin
                empty = 1'b1;
            end

            // check for full
            else if (head_index_ptr.msb != tail_index_ptr.msb) begin
                full = 1'b1;
            end

            // otherwise, unexpected
            else begin
                $display("phys_reg_free_list: invalid full/empty case");
                assert(0);
            end
        end
    end

endmodule