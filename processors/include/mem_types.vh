/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: mem_types.vh
    Instantiation Hierarchy: system -> (mem module)
    Description: 
        This file defines types for this implementation's memory hierarchy.

        Includes core_types_pkg.
*/

`ifndef MEM_TYPES_VH
`define MEM_TYPES_VH

`include "core_types.vh"

package mem_types_pkg;

    import core_types_pkg::*;

    /////////////
    // icache: //
    /////////////

    // static num ways: Loop Way and Stream Buffer Way
    parameter ICACHE_NUM_SETS = 8;

    parameter ICACHE_NUM_INDEX_BITS = $clog2(ICACHE_NUM_SETS);
    parameter ICACHE_NUM_TAG_BITS = BLOCK_ADDR_SPACE_WIDTH - ICACHE_NUM_INDEX_BITS;

    /////////////
    // dcache: //
    /////////////

    parameter DCACHE_NUM_WAYS = 2;
    parameter DCACHE_NUM_SETS = 8;

    parameter DCACHE_NUM_INDEX_BITS = $clog2(DCACHE_NUM_SETS);
    parameter DCACHE_NUM_TAG_BITS = BLOCK_ADDR_SPACE_WIDTH - DCACHE_NUM_INDEX_BITS;

    typedef struct packed {
        logic [WORD_ADDR_SPACE_WIDTH-BLOCK_ADDR_SPACE_WIDTH-1:0] block_offset;
        logic [DCACHE_NUM_INDEX_BITS-1:0] index;
        logic [DCACHE_NUM_TAG_BITS-1:0] tag;
    } dcache_addr_t;

endpackage

`endif // MEM_TYPES_VH