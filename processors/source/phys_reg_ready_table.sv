/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_ready_table.sv
    Instantiation Hierarchy: system -> core -> dispatch_unit -> phys_reg_ready_table
    Description: 
        The Physical Register Ready Table provides whether a physical register value is ready or is yet to
        be computed in the datapath. As far as can tell, this module does not require checkpointing or 
        revert logic since future instr's that use a value will use the most recent dispatch's ready val,
        which may or may not have been completed since. 
        
        It is the external controller's responsibility to prevent the clearing of phys reg 0.
*/

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_ready_table #(

) (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // dispatch
        // read @ source 0
        // read @ source 1
        // clear @ dest
    input phys_reg_tag_t dispatch_source_0_phys_reg_tag,
    output logic dispatch_source_0_ready,
    input phys_reg_tag_t dispatch_source_1_phys_reg_tag,
    output logic dispatch_source_1_ready,
    input logic dispatch_dest_write,
    input phys_reg_tag_t dispatch_dest_phys_reg_tag,

    // complete
        // set @ complete bus 0 dest
        // set @ complete bus 1 dest
    input logic complete_bus_0_valid,
    input phys_reg_tag_t complete_bus_0_dest_phys_reg_tag,
    input logic complete_bus_1_valid,
    input phys_reg_tag_t complete_bus_1_dest_phys_reg_tag
);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // DUT error:

    logic next_DUT_error;

    // seq + logic
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            DUT_error <= 1'b0;
        end
        else begin
            DUT_error <= next_DUT_error;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ready table:

    logic [NUM_PHYS_REGS-1:0] ready_table_by_phys_reg_tag_index;
    logic [NUM_PHYS_REGS-1:0] next_ready_table_by_phys_reg_tag_index;

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // all phys reg's in arch reg range are ready
            for (int i = 0; i < NUM_ARCH_REGS; i++) begin
                ready_table_by_phys_reg_tag_index[phys_reg_tag_t'(i)] <= 1'b1;
            end
            for (int i = NUM_ARCH_REGS; i < NUM_PHYS_REGS; i++) begin
                ready_table_by_phys_reg_tag_index[phys_reg_tag_t'(i)] <= 1'b0;
            end
        end
        else begin
            ready_table_by_phys_reg_tag_index <= next_ready_table_by_phys_reg_tag_index;
        end
    end

    // comb
    always_comb begin

        // write logic:
            // determine writes first so reads can take forwarded write value
            // assume complete bus 0, complete bus 1, and dispatch can all happen at the same time but 
                // will never write to same location (essentially, priority doesn't matter)

        // default outputs:
        
        // no DUT error
        next_DUT_error = 1'b0;

        // hold state
        next_ready_table_by_phys_reg_tag_index = ready_table_by_phys_reg_tag_index;

        // WARNING: no default on reads
            // intend to fully enumerate these in read logic

        // 3 writes: {dispatch, complete bus 0, complete bus 1}

        // DUT error: check for multple writers to same phys reg
        if (
            ((dispatch_dest_phys_reg_tag == complete_bus_0_dest_phys_reg_tag) & dispatch_dest_write & complete_bus_0_valid) |
            ((dispatch_dest_phys_reg_tag == complete_bus_1_dest_phys_reg_tag) & dispatch_dest_write & complete_bus_1_valid) | 
            ((complete_bus_0_dest_phys_reg_tag == complete_bus_1_dest_phys_reg_tag) & complete_bus_0_valid & complete_bus_1_valid)
        ) begin
            $display("phys_reg_ready_table: ERROR: multiple writers to same phys reg");
            next_DUT_error = 1'b1;
        end

        // DUT error: check for write to phys reg 0
        if (
            ((dispatch_dest_phys_reg_tag == phys_reg_tag_t'(0)) & dispatch_dest_write) |
            ((complete_bus_0_dest_phys_reg_tag == phys_reg_tag_t'(0)) & complete_bus_0_valid) |
            ((complete_bus_1_dest_phys_reg_tag == phys_reg_tag_t'(0)) & complete_bus_1_valid)
        ) begin
            $display("phys_reg_ready_table: ERROR: write to phys reg 0");
            next_DUT_error = 1'b1;
        end

        // dispatch 
        if (dispatch_dest_write) begin
            
            // clear ready bit at dispatch phys reg tag
            next_ready_table_by_phys_reg_tag_index[dispatch_dest_phys_reg_tag] = 1'b0;
        end
        
        // complete bus 0
        if (complete_bus_0_valid) begin

            // set ready bit at complete bus 0 phys reg tag
            next_ready_table_by_phys_reg_tag_index[complete_bus_0_dest_phys_reg_tag] = 1'b1;
        end
        
        // complete bus 1
        if (complete_bus_1_valid) begin

            // set ready bit at complete bus 1 phys reg tag
            next_ready_table_by_phys_reg_tag_index[complete_bus_1_dest_phys_reg_tag] = 1'b1;
        end

        // read logic:
            // forward values from any of writes if possible
            // can explicitly tag check OR can read from next_ array
        dispatch_source_0_ready = next_ready_table_by_phys_reg_tag_index[dispatch_source_0_phys_reg_tag];
        dispatch_source_1_ready = next_ready_table_by_phys_reg_tag_index[dispatch_source_1_phys_reg_tag];
    end

endmodule