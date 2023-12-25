/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_map_table.sv
    Instantiation Hierarchy: system -> core -> phys_reg_map_table
    Description: 
        The Physical Register Map Table gives the current mapping for architectural registers to physical
        registers. 
*/

`include "instr_types.vh"
import instr_types_pkg::*;

module phys_reg_map_table #(
    
) (
    // seq
    input CLK, nRST,

    // inputs:

    // reg map reading
    input arch_reg_tag_t source_arch_reg_tag_0,
    input arch_reg_tag_t source_arch_reg_tag_1,

    // reg map writing
    input new_map_valid,
    input arch_reg_tag_t new_map_dest_arch_reg_tag,
    input phys_reg_tag_t new_map_dest_phys_reg_tag,

    // reg map killing
    input kill_map_valid,
    input arch_reg_tag_t kill_map_dest_arch_reg_tag,
    input phys_reg_tag_t kill_map_old_dest_phys_reg_tag,
    input phys_reg_tag_t kill_map_new_dest_phys_reg_tag,
        // can use for assertion but otherwise don't need

    // outputs:

    // reg map reading
    output phys_reg_tag_t source_phys_reg_tag_0,
    output phys_reg_tag_t source_phys_reg_tag_1
);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // internal signals:

    // map table array (arch reg tag -> phys reg tag)
    phys_reg_tag_t [NUM_ARCH_REGS-1:0] phys_reg_tag_mapping_by_arch_reg_tag_index;
    phys_reg_tag_t [NUM_ARCH_REGS-1:0] next_phys_reg_tag_mapping_by_arch_reg_tag_index;

    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            for (int i = 0; i < NUM_ARCH_REGS; i++) begin
                phys_reg_tag_mapping_by_arch_reg_tag_index[i] <= phys_reg_tag_t'(i);
            end
        end
        else begin
            phys_reg_tag_mapping_by_arch_reg_tag_index <= next_phys_reg_tag_mapping_by_arch_reg_tag_index;
        end
    end

    // map table array accesses
    always_comb begin

        // map table reads
        source_phys_reg_tag_0 = phys_reg_tag_mapping_by_arch_reg_tag_index[source_arch_reg_tag_0];
        source_phys_reg_tag_1 = phys_reg_tag_mapping_by_arch_reg_tag_index[source_arch_reg_tag_1];

        // map table writes:

        // hold state by default
        next_phys_reg_tag_mapping_by_arch_reg_tag_index = phys_reg_tag_mapping_by_arch_reg_tag_index;

        // new reg map write
        if (new_map_valid) begin

            // write new mapping
            next_phys_reg_tag_mapping_by_arch_reg_tag_index[new_map_dest_arch_reg_tag] = 
                new_map_dest_phys_reg_tag;
        end

        // reg map kill
        if (kill_map_valid) begin

            // check currently have new (youngest) mapping
            assert(phys_reg_tag_mapping_by_arch_reg_tag_index[kill_map_dest_arch_reg_tag] ==
                kill_map_new_dest_phys_reg_tag)
            else begin
                $display("ERROR: phys_reg_map_table.sv: new (youngest) phys reg mapping not the current mapping");
            end

            // write old mapping (undo)
            next_phys_reg_tag_mapping_by_arch_reg_tag_index[new_map_dest_arch_reg_tag] = 
                kill_map_old_dest_phys_reg_tag;
        end
    end

endmodule