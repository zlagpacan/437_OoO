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

    //////////////
    // general: //
    //////////////
        // a lot (like mem addr space bit widths) are already in core_types_package

    // ramstate
    typedef enum logic [1:0] {
        FREE,
        BUSY,
        ACCESS,
        ERROR
    } ramstate_t;

    /////////////
    // icache: //
    /////////////

    // static num ways: Loop Way and Stream Buffer Way

    parameter ICACHE_NUM_SETS = 8;

    parameter ICACHE_NUM_INDEX_BITS = $clog2(ICACHE_NUM_SETS);
    parameter ICACHE_NUM_TAG_BITS = BLOCK_ADDR_SPACE_WIDTH - ICACHE_NUM_INDEX_BITS;
    parameter ICACHE_NUM_BLOCK_OFFSET_BITS = WORD_ADDR_SPACE_WIDTH - BLOCK_ADDR_SPACE_WIDTH;

    /////////////
    // dcache: //
    /////////////

    parameter DCACHE_NUM_WAYS = 2;
    parameter DCACHE_LOG_NUM_WAYS = $clog2(DCACHE_NUM_WAYS);

    parameter DCACHE_NUM_SETS = 8;

    parameter DCACHE_NUM_INDEX_BITS = $clog2(DCACHE_NUM_SETS);
    parameter DCACHE_NUM_TAG_BITS = BLOCK_ADDR_SPACE_WIDTH - DCACHE_NUM_INDEX_BITS;
    parameter DCACHE_NUM_BLOCK_OFFSET_BITS = WORD_ADDR_SPACE_WIDTH - BLOCK_ADDR_SPACE_WIDTH;

    parameter DCACHE_STORE_MSHR_Q_DEPTH = 4;
    parameter DCACHE_LOG_STORE_MSHR_Q_DEPTH = $clog2(DCACHE_STORE_MSHR_Q_DEPTH);

    parameter DCACHE_BUS_READ_REQ_BACKLOG_Q_DEPTH = 4;
    parameter DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH = $clog2(DCACHE_BUS_READ_REQ_BACKLOG_Q_DEPTH);

    parameter DCACHE_LOAD_MISS_RETURN_Q_DEPTH = 2;
    parameter DCACHE_LOG_LOAD_MISS_RETURN_Q_DEPTH = $clog2(DCACHE_LOAD_MISS_RETURN_Q_DEPTH);

    /////////////////////
    // mem controller: //
    /////////////////////

    parameter MEM_CONTROLLER_READ_BUFFER_DEPTH = 4;
    parameter MEM_CONTROLLER_LOG_READ_BUFFER_DEPTH = $clog2(MEM_CONTROLLER_READ_BUFFER_DEPTH);

    parameter MEM_CONTROLLER_WRITE_BUFFER_DEPTH = 8;
    parameter MEM_CONTROLLER_LOG_WRITE_BUFFER_DEPTH = $clog2(MEM_CONTROLLER_WRITE_BUFFER_DEPTH);

    // for unicore
    typedef enum logic {
        MEM_RD,
        MEM_WB
    } mem_req_t;

    // for multicore
    typedef enum logic [1:0] {
        BUS_RD,
        BUS_RD_X,
        BUS_UPGRADE,
        BUS_WB
    } bus_req_t;

endpackage

`endif // MEM_TYPES_VH