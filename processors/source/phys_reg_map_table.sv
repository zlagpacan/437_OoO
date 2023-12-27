/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_map_table.sv
    Instantiation Hierarchy: system -> core -> phys_reg_map_table
    Description: 
        The Physical Register Map Table gives the current mapping for architectural registers to physical
        registers. The table also checkpoints mappings which can be restored using a FIFO of map tables.
*/

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_map_table #(
    
) (
    // seq
    input logic CLK, nRST,

    // reg map reading
    input arch_reg_tag_t source_arch_reg_tag_0,
    output phys_reg_tag_t source_phys_reg_tag_0,
    input arch_reg_tag_t source_arch_reg_tag_1,
    output phys_reg_tag_t source_phys_reg_tag_1,

    // reg map rename
    input logic rename_valid,
    input arch_reg_tag_t rename_dest_arch_reg_tag,
    input phys_reg_tag_t rename_dest_phys_reg_tag,

    // reg map revert
    input logic revert_valid,
    input arch_reg_tag_t revert_dest_arch_reg_tag,
    input phys_reg_tag_t revert_safe_dest_phys_reg_tag,
    input phys_reg_tag_t revert_speculated_dest_phys_reg_tag,
        // can use for assertion but otherwise don't need

    // reg map checkpoint save
    input logic save_checkpoint_valid,
    output logic save_checkpoint_success,
    input ROB_index_t save_checkpoint_ROB_index,    // from ROB, write tag val
    output checkpoint_column_t save_checkpoint_safe_column,

    // reg map checkpoint restore
    input logic restore_checkpoint_valid,
    input logic restore_checkpoint_speculate_failed,
    output logic restore_checkpoint_success,
    input ROB_index_t restore_checkpoint_ROB_index,  // from restore system, check tag val
    input checkpoint_column_t restore_checkpoint_safe_column
);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // map table array:
        // (arch reg tag -> phys reg tag)
    
    // signals:

    // map table column, array structure
        // valid, tag (ROB index), value (map table array)
    typedef struct packed {
        logic valid;
        ROB_index_t ROB_index;
        phys_reg_tag_t [NUM_ARCH_REGS-1:0] array;
    } phys_reg_map_table_column_t;

    phys_reg_map_table_column_t [CHECKPOINT_COLUMNS-1:0] phys_reg_map_table_columns_by_column_index;
    phys_reg_map_table_column_t [CHECKPOINT_COLUMNS-1:0] next_phys_reg_map_table_columns_by_column_index;

    // map table pointers
        // working column
            // youngest speculated column, receives map table writes 
        // tail column
            // column where next speculated column will be copied to
            // = working column + 1
    checkpoint_column_t phys_reg_map_table_working_column;
    checkpoint_column_t next_phys_reg_map_table_working_column;
    // checkpoint_column_t phys_reg_map_table_tail_column;

    // logic:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            ///////////////////////////////////////////////////////////////////////////////////////////////
            // phys_reg_map_table_columns_by_column_index:
                // column == 0: reset to first phys reg mappings, valid
                // columns != 0: reset to 0's

            // column == 0
            phys_reg_map_table_columns_by_column_index[0].valid <= 1'b1;
            phys_reg_map_table_columns_by_column_index[0].ROB_index <= ROB_index_t'(0);
            for (int i = 0; i < NUM_ARCH_REGS; i++) begin
                phys_reg_map_table_columns_by_column_index[0].array[i] <= phys_reg_tag_t'(i);
            end

            // column != 0
            for (int i = 1; i < CHECKPOINT_COLUMNS; i++) begin
                phys_reg_map_table_columns_by_column_index[i].valid <= 1'b0;
                phys_reg_map_table_columns_by_column_index[i].ROB_index <= ROB_index_t'(0);
                phys_reg_map_table_columns_by_column_index[i].array <= '0;
            end
            ///////////////////////////////////////////////////////////////////////////////////////////////

            phys_reg_map_table_working_column <= checkpoint_column_t'(0);
        end
        else begin
            phys_reg_map_table_columns_by_column_index <= next_phys_reg_map_table_columns_by_column_index;
            phys_reg_map_table_working_column <= next_phys_reg_map_table_working_column;
        end
    end

    // map table array accesses
    always_comb begin

        // make sure working column valid
            // early reset seems to fail this
        if (~phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column].valid & nRST) 
        begin
            $display("ERROR: phys_reg_map_table: working column not valid");
            $display("\t\tworking column = %h", phys_reg_map_table_working_column);
            assert(0);
        end

        // default outputs:
        
        // provide successes to pipeline
        save_checkpoint_success = 1'b0;
        restore_checkpoint_success = 1'b0;

        // map table reads:

        // source reg 0
        source_phys_reg_tag_0 = phys_reg_map_table_columns_by_column_index
            [phys_reg_map_table_working_column].array[source_arch_reg_tag_0];

        // source reg 1
        source_phys_reg_tag_1 = phys_reg_map_table_columns_by_column_index
            [phys_reg_map_table_working_column].array[source_arch_reg_tag_1];

        // map table writes:

        // hold state by default
        next_phys_reg_map_table_columns_by_column_index = phys_reg_map_table_columns_by_column_index;
        next_phys_reg_map_table_working_column = phys_reg_map_table_working_column;

        // revert
            // dispatch (and therefore rename) should not be allowed during restore
        if (revert_valid) begin

            // check currently have speculated mapping
            assert(phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column]
                .array[revert_dest_arch_reg_tag] ==
                revert_speculated_dest_phys_reg_tag)
            else begin
                $display("ERROR: phys_reg_map_table: revert -> speculated phys reg mapping not the current mapping");
                $display("\t\trevert_speculated_set_phys_reg_tag = 0x%h", 
                    revert_speculated_dest_phys_reg_tag);
                $display("\t\tmap table value = 0x%h",
                    phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column]
                    .array[revert_dest_arch_reg_tag]);
            end

            // write safe mapping (undo rename)
            next_phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column]
                .array[revert_dest_arch_reg_tag] = 
                revert_safe_dest_phys_reg_tag;

            // invalidate non-working columns
            for (int i = 0; i < CHECKPOINT_COLUMNS; i++) begin
                if (checkpoint_column_t'(i) != phys_reg_map_table_working_column) begin
                    next_phys_reg_map_table_columns_by_column_index[checkpoint_column_t'(i)]
                        .valid = 1'b0;
                end
            end
        end

        // restore
            // dispatch (and therefore rename) should not be allowed during restore
        else if (restore_checkpoint_valid) begin

            // check speculation failed
                // restore to safe col
            if (restore_checkpoint_speculate_failed) begin

                // check for VTM on restore col
                if (phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column].valid &
                    phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column].ROB_index ==
                    restore_checkpoint_ROB_index
                ) begin
                    // revert to safe column
                    next_phys_reg_map_table_working_column = restore_checkpoint_safe_column;

                    // invalidate all other columns
                    for (int i = 0; i < CHECKPOINT_COLUMNS; i++) begin
                        if (checkpoint_column_t'(i) != restore_checkpoint_safe_column) begin
                            next_phys_reg_map_table_columns_by_column_index[checkpoint_column_t'(i)]
                                .valid = 1'b0;
                        end
                    end

                    // give successful
                    restore_checkpoint_success = 1'b1;
                end

                // otherwise, give unsuccessful
                else begin
                    restore_checkpoint_success = 1'b0;
                end
            end

            // otherwise, speculation succeeded
                // invalidate safe col
            else begin

                // invalidate safe column
                next_phys_reg_map_table_columns_by_column_index[restore_checkpoint_safe_column]
                    .valid = 1'b0;

                // give successful
                restore_checkpoint_success = 1'b1;
            end
        end

        // save
            // rename should not be happening during save if only save on branches
        else if (save_checkpoint_valid) begin

            // write new working column (working column + 1)
                // valid
                // given ROB index
                // copy array working column to working column + 1
            next_phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column + 1]
                .valid = 1'b1;
            next_phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column + 1]
                .ROB_index = save_checkpoint_ROB_index;
            next_phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column + 1]
                .array = phys_reg_map_table_columns_by_column_index[phys_reg_map_table_working_column]
                .array;

            // increment working column pointer
            next_phys_reg_map_table_working_column = phys_reg_map_table_working_column + 1;
        end

        // rename
            // core controller knows renames will fail during revert/checkpoint restore, don't allow
            // dispatch to move on until have cycle where not reverting or checkpoint restoring
        else if (rename_valid) begin

            // write new mapping
            next_phys_reg_map_table_columns_by_column_index[rename_dest_arch_reg_tag] = 
                rename_dest_phys_reg_tag;
        end
    end

    // wires:

    // provide column pointers to pipeline
    assign save_checkpoint_safe_column = phys_reg_map_table_working_column;

endmodule