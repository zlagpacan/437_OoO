/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: phys_reg_file.sv
    Instantiation Hierarchy: system -> core -> phys_reg_file
    Description: 
        The Dispatch Unit handles decoding, register renaming, and demuxing an input instruction to an
        execution unit. This module instantiates the phys_reg_map_table, phys_reg_free_list, and 
        phys_reg_ready_table modules.
        
        The Physical Register File is a typical register file for the renamed physical registers assigned
        during dispatch. 
        
        The Phys Reg File must balance multiple read and write requests (potentially more than can be
        physically supported)
            - read requests: 9x (or 8x)
                - ALU RS 0: 2x
                - ALU RS 1: 2x
                - SQ: 2x (or 1x if time multiplex SQ reg inputs)
                - LQ: 1x
                - BRU RS: 2x
            - write requests: 3x
                - ALU 0: 1x
                - ALU 1: 1x
                - LQ: 1x

            - potential read configs:

                - single read occurs at pair granularity
                    - should guarantee for given cycle, only the last dispatched instr reads from reg file
                    - priority order:
                        - LQ
                        - ALU 0
                        - ALU 1
                        - BRU
                        - SQ
                    - don't need any fancier logic since not doing superscalar
                        - should be reasonable enough for negedge reg file write

                - 9->N PQ
                    - probably N = 2 or 3
                    - PQ logic annoying, messy, potentially large and slow

            - all write ports supported
                - never stop a completion
                    - rare case but only have 3 writers anyway so okay
                        - 4:1 mux at each bit -> reg, ALU 0, ALU 1, LQ

        The Phys Reg File supports forwarded write values.

        It is responsibility of external control to avoid overwriting phys reg 0.

        Current version forwards the written values, can change to negedge write.
*/

`include "core_types.vh"
import core_types_pkg::*;

module phys_reg_file (

    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // overloaded read flag
    output logic read_overload,

    // read reqs:

    // LQ read req
    input logic LQ_read_req_valid,
    input phys_reg_tag_t LQ_read_req_tag,
    output logic LQ_read_req_serviced,

    // ALU 0 read req
    input logic ALU_0_read_req_valid,
    input phys_reg_tag_t ALU_0_read_req_0_tag,
    input phys_reg_tag_t ALU_0_read_req_1_tag,
    output logic ALU_0_read_req_serviced,

    // ALU 1 read req
    input logic ALU_1_read_req_valid,
    input phys_reg_tag_t ALU_1_read_req_0_tag,
    input phys_reg_tag_t ALU_1_read_req_1_tag,
    output logic ALU_1_read_req_serviced,

    // BRU read req
    input logic BRU_read_req_valid,
    input phys_reg_tag_t BRU_read_req_0_tag,
    input phys_reg_tag_t BRU_read_req_1_tag,
    output logic BRU_read_req_serviced,

    // SQ read req
    input logic SQ_read_req_valid,
    input phys_reg_tag_t SQ_read_req_0_tag,
    input phys_reg_tag_t SQ_read_req_1_tag,
    output logic SQ_read_req_serviced,

    // read bus:
    output word_t read_bus_0_data,
    output word_t read_bus_1_data,

    // write reqs:

    // LQ write req
    input logic LQ_write_req_valid,
    input phys_reg_tag_t LQ_write_req_tag,
    input word_t LQ_write_req_data,
    output logic LQ_write_req_serviced,

    // ALU 0 write req
    input logic ALU_0_write_req_valid,
    input phys_reg_tag_t ALU_0_write_req_tag,
    input word_t ALU_0_write_req_data,
    output logic ALU_0_write_req_serviced,

    // ALU 1 write req
    input logic ALU_1_write_req_valid,
    input phys_reg_tag_t ALU_1_write_req_tag,
    input word_t ALU_1_write_req_data,
    output logic ALU_1_write_req_serviced
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
    // internal signals:

    // reg file array
    word_t [NUM_PHYS_REGS-1:0] phys_reg_file, next_phys_reg_file;

    // reg file FF logic
    // always_ff @ (negedge CLK, negedge nRST) begin
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            phys_reg_file <= '0;
        end
        else begin
            phys_reg_file <= next_phys_reg_file;
        end
    end

    // reg file read and write logic
    always_comb begin

        ///////////////
        // defaults: //
        ///////////////

        // reg file holds state
        next_phys_reg_file = phys_reg_file;

        // no read overload
        read_overload = 1'b0;

        // no error
        next_DUT_error = 1'b0;

        // all read reqs not serviced
        LQ_read_req_serviced = 1'b0;
        ALU_0_read_req_serviced = 1'b0;
        ALU_1_read_req_serviced = 1'b0;
        BRU_read_req_serviced = 1'b0;
        SQ_read_req_serviced = 1'b0;

        // all write reqs not serviced
        LQ_write_req_serviced = 1'b0;
        ALU_0_write_req_serviced = 1'b0;
        ALU_1_write_req_serviced = 1'b0;

        // perform writes first:

        // service LQ write req
        if (LQ_write_req_valid) begin
            next_phys_reg_file[LQ_write_req_tag] = LQ_write_req_data;
            LQ_write_req_serviced = 1'b1;
        end

        // service ALU 0 write req
        if (ALU_0_write_req_valid) begin
            next_phys_reg_file[ALU_0_write_req_tag] = ALU_0_write_req_data;
            ALU_0_write_req_serviced = 1'b1;
        end

        // service ALU 1 write req
        if (ALU_1_write_req_valid) begin
            next_phys_reg_file[ALU_1_write_req_tag] = ALU_1_write_req_data;
            ALU_1_write_req_serviced = 1'b1;
        end

        // perform read pair:

        // default: read bus from ALU 0
        // read_bus_0_data = phys_reg_file[ALU_0_read_req_0_tag];
        // read_bus_1_data = phys_reg_file[ALU_0_read_req_1_tag];
        read_bus_0_data = next_phys_reg_file[ALU_0_read_req_0_tag];
        read_bus_1_data = next_phys_reg_file[ALU_0_read_req_1_tag];

        // PQ select
            // LQ > ALU 0 > ALU 1 > BRU > SQ

        // LQ
        if (LQ_read_req_valid) begin

            // LQ read (only need bus 0)
            // read_bus_0_data = phys_reg_file[LQ_read_req_tag];
            read_bus_0_data = next_phys_reg_file[LQ_read_req_tag];

            // LQ serviced
            LQ_read_req_serviced = 1'b1;

            // overload on ALU 0, ALU 1, BRU, or SQ
            read_overload = 
                ALU_0_read_req_valid | 
                ALU_1_read_req_valid | 
                BRU_read_req_valid | 
                SQ_read_req_valid;
        end

        // ALU 0
        else if (ALU_0_read_req_valid) begin

            // ALU 0 read (bus 0 and 1)
            // read_bus_0_data = phys_reg_file[ALU_0_read_req_0_tag];
            // read_bus_1_data = phys_reg_file[ALU_0_read_req_1_tag];
            read_bus_0_data = next_phys_reg_file[ALU_0_read_req_0_tag];
            read_bus_1_data = next_phys_reg_file[ALU_0_read_req_1_tag];

            // ALU 0 serviced
            ALU_0_read_req_serviced = 1'b1;

            // overload on ALU 1, BRU, or SQ
            read_overload = 
                ALU_1_read_req_valid | 
                BRU_read_req_valid | 
                SQ_read_req_valid;
        end

        // ALU 1
        else if (ALU_1_read_req_valid) begin

            // ALU 1 read (bus 0 and 1)
            // read_bus_0_data = phys_reg_file[ALU_1_read_req_0_tag];
            // read_bus_1_data = phys_reg_file[ALU_1_read_req_1_tag];
            read_bus_0_data = next_phys_reg_file[ALU_1_read_req_0_tag];
            read_bus_1_data = next_phys_reg_file[ALU_1_read_req_1_tag];

            // ALU 1 serviced
            ALU_1_read_req_serviced = 1'b1;

            // overload on BRU or SQ
            read_overload = 
                BRU_read_req_valid | 
                SQ_read_req_valid;
        end

        // BRU
        else if (BRU_read_req_valid) begin

            // BRU read (bus 0 and 1)
            // read_bus_0_data = phys_reg_file[BRU_read_req_0_tag];
            // read_bus_1_data = phys_reg_file[BRU_read_req_1_tag];
            read_bus_0_data = next_phys_reg_file[BRU_read_req_0_tag];
            read_bus_1_data = next_phys_reg_file[BRU_read_req_1_tag];

            // BRU serviced
            BRU_read_req_serviced = 1'b1;

            // overload on SQ
            read_overload = SQ_read_req_valid;
        end

        // SQ
        else if (SQ_read_req_valid) begin

            // SQ read (bus 0 and 1)
            // read_bus_0_data = phys_reg_file[SQ_read_req_0_tag];
            // read_bus_1_data = phys_reg_file[SQ_read_req_1_tag];
            read_bus_0_data = next_phys_reg_file[SQ_read_req_0_tag];
            read_bus_1_data = next_phys_reg_file[SQ_read_req_1_tag];

            // SQ serviced
            SQ_read_req_serviced = 1'b1;

            // no overload possible (lowest priority)
        end

        // // also give DUT error for overload
        // next_DUT_error = read_overload;
    end

endmodule