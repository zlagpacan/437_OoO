/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: icache.sv
    Instantiation Hierarchy: system -> icache
    Description:

        The icache interacts with the core and the memory controller, translating core requests
        into responses with memory fetched values (potentially cached). 

        Memory fetches are at block granularity. Core requests are at word granularity.

        Implement as 2-way associative cache with 8 sets
            - Way 0: Loop Way
            - Way 1: Stream Buffer

        The Stream Buffer triggers 8 consecutive block reads when a read misses in the Loop Way
        and Stream Buffer. Hits in the Stream Buffer move the block to the Loop Way. 
            - A block can be in both the Loop Way and the Stream Buffer. The Loop Way is checked
                first, so this value will be taken.  
*/

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module icache (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    /////////////////////
    // core interface: //
    /////////////////////
        // synchronous, blocking interface
        // essentially same as 437
    input logic icache_REN,
    input word_t icache_addr,
    input logic icache_halt,
    output logic icache_hit,
    output word_t icache_load,

    ////////////////////
    // mem interface: //
    ////////////////////
        // synchronous, blocking interface
        // essentially same as 437
    output logic imem_REN,
    output block_addr_t imem_block_addr,
    input logic imem_hit,
    input word_t [1:0] imem_load
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
    // icache logic:

    // icache frame
    typedef struct packed {
        logic valid;
        logic [ICACHE_NUM_TAG_BITS-1:0] tag;
        word_t [1:0] block;
    } icache_frame_t;

    // loop way
    icache_frame_t [ICACHE_NUM_SETS-1:0] loop_way;
    icache_frame_t [ICACHE_NUM_SETS-1:0] next_loop_way;

    // stream buffer
    icache_frame_t [ICACHE_NUM_SETS-1:0] stream_buffer;
    icache_frame_t [ICACHE_NUM_SETS-1:0] next_stream_buffer;

    // stream state
    typedef enum logic [1:0] {
        STREAM_IDLE,
        STREAM_FETCH,
        STREAM_HALT
    } stream_state_t;

    stream_state_t stream_state;
    stream_state_t next_stream_state;

    // stream counter
    logic [ICACHE_NUM_INDEX_BITS-1:0] stream_counter;
    logic [ICACHE_NUM_INDEX_BITS-1:0] next_stream_counter;

    // missing block addr reg
    typedef struct packed {
        logic [ICACHE_NUM_TAG_BITS-1:0] tag;
        logic [ICACHE_NUM_INDEX_BITS-1:0] index;
    } icache_block_addr_t;

    icache_block_addr_t missing_block_addr;
    icache_block_addr_t next_missing_block_addr;

    icache_block_addr_t missing_plus_counter_block_addr;

    // icache_addr -> struct
    typedef struct packed {
        logic [15:0] upper_bits;
        logic [ICACHE_NUM_TAG_BITS-1:0] tag;
        logic [ICACHE_NUM_INDEX_BITS-1:0] index;
        logic [WORD_ADDR_SPACE_WIDTH-BLOCK_ADDR_SPACE_WIDTH-1:0] block_offset;
        logic [1:0] word_offset;
    } icache_word_addr_t;

    icache_word_addr_t icache_addr_structed; 

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            loop_way <= '0;
            stream_buffer <= '0;
            stream_state <= STREAM_IDLE;
            stream_counter <= '0;
            missing_block_addr <= '0;
        end
        else begin
            loop_way <= next_loop_way;
            stream_buffer <= next_stream_buffer;
            stream_state <= next_stream_state;
            stream_counter <= next_stream_counter;
            missing_block_addr <= next_missing_block_addr;
        end
    end

    // comb logic:
    always_comb begin

        // cast structs
        icache_addr_structed = icache_addr;

        missing_plus_counter_block_addr = missing_block_addr + stream_counter;

        ///////////////
        // defaults: //
        ///////////////

        // no error
        next_DUT_error = 1'b0;

        // no core side i$ hit
            // give Loop Way load by default
        icache_hit = 1'b0;
        icache_load = loop_way[icache_addr_structed.index].block[icache_addr_structed.block_offset];

        // no mem side imem req
            // give block addr from missing block addr + counter by default
        imem_REN = 1'b0;
        imem_block_addr = missing_block_addr + stream_counter;

        // hold state
        next_loop_way = loop_way;
        next_stream_buffer = stream_buffer;
        next_stream_state = stream_state;
        next_stream_counter = stream_counter;
        next_missing_block_addr = missing_block_addr;

        //////////////////////////
        // stream buffer logic: //
        //////////////////////////
            // do before hit logic so new miss is prioritized

        case (stream_state) 

            STREAM_IDLE:
            begin
                // no mem side imem req
                    // give block addr from missing block addr + counter by default
                imem_REN = 1'b0;
                imem_block_addr = missing_block_addr + stream_counter;
            end

            STREAM_FETCH:
            begin
                // give mem side imem req
                    // give block addr from missing block addr + counter
                imem_REN = 1'b1;
                imem_block_addr = missing_plus_counter_block_addr;

                // check for imem resp
                if (imem_hit) begin

                    // load in block
                    next_stream_buffer[missing_plus_counter_block_addr.index].valid = 1'b1;
                    next_stream_buffer[missing_plus_counter_block_addr.index].tag = missing_plus_counter_block_addr.tag;
                    next_stream_buffer[missing_plus_counter_block_addr.index].block = imem_load;

                    // increment counter
                    next_stream_counter = stream_counter + 1;

                    // check done all loads
                    if (stream_counter == ICACHE_NUM_SETS-1) begin

                        next_stream_state = STREAM_IDLE;
                    end
                end
            end

        endcase

        ////////////////
        // hit logic: //
        ////////////////
            // can happen if stream in idle or fetch

        // check core side i$ req
        if (icache_REN) begin

            // check VTM in Loop Way
            if (
                loop_way[icache_addr_structed.index].valid
                &
                loop_way[icache_addr_structed.index].tag == icache_addr_structed.tag
            ) begin

                // give hit
                icache_hit = 1'b1;

                // load from Loop Way
                icache_load = loop_way[icache_addr_structed.index].block[icache_addr_structed.block_offset];
            end

            // otherwise, check VTM in Stream Buffer
            else if (
                stream_buffer[icache_addr_structed.index].valid
                &
                stream_buffer[icache_addr_structed.index].tag == icache_addr_structed.tag
            ) begin

                // give hit
                icache_hit = 1'b1;

                // load from Stream Buffer
                icache_load = stream_buffer[icache_addr_structed.index].block[icache_addr_structed.block_offset];

                // copy Stream Buffer block to Loop Way
                next_loop_way[icache_addr_structed.index]
                    = stream_buffer[icache_addr_structed.index];
            end

            // otherwise, check this block addr not in stream fetch
                // start new stream fetch
            else if (
                !(
                    stream_state == STREAM_FETCH
                    &
                    missing_block_addr == {icache_addr_structed.tag, icache_addr_structed.index}
                )
            ) begin

                // go to stream fetch mode
                next_stream_state = STREAM_FETCH;

                // reset counter
                next_stream_counter = 0;

                // save missing block addr
                next_missing_block_addr = {icache_addr_structed.tag, icache_addr_structed.index};
            end
        end

        ///////////////////////
        // halt state logic: //
        ///////////////////////

        // check need to enter stream halt
        if (icache_halt) begin
            next_stream_state = STREAM_HALT;
        end

        // check need to enter stream halt
        if (stream_state == STREAM_HALT) begin

            // stay in stream halt
            next_stream_state = STREAM_HALT;

            // disable mem read
            imem_REN = 1'b0;
        end

    end

endmodule