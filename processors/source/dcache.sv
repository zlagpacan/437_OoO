/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dcache.sv
    Instantiation Hierarchy: system -> dcache
    Description:

        The dcache interacts with the core and the memory controller, translating core requests
        into responses with memory fetched values (potentially cached). 

        Memory fetches are at block granularity. Core requests are at word granularity.

        Implement as 2-way associative cache with 8 sets.

        Non-blocking, asynchronous interface to core and to mem.

        4 MSHR's, 1 assigned to each LQ index.
*/

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module dcache (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    /////////////////////
    // core interface: //
    /////////////////////
        // asynchronous, non-blocking interface

    // read req interface:
    input logic dcache_read_req_valid,
    input LQ_index_t dcache_read_req_LQ_index,
    input daddr_t dcache_read_req_addr,
    input logic dcache_read_req_linked,
    input logic dcache_read_req_conditional,
    output logic dcache_read_req_blocked,

    // read resp interface:
    output logic dcache_read_resp_valid,
    output LQ_index_t dcache_read_resp_LQ_index,
    output word_t dcache_read_resp_data,

    // write req interface:
    input logic dcache_write_req_valid,
    input daddr_t dcache_write_req_addr,
    input word_t dcache_write_req_data,
    input logic dcache_write_req_conditional,
    output logic dcache_write_req_blocked,

    // read kill interface x2:
        // even though doing bus resp block addr broadcast, still want these to 
    input logic dcache_read_kill_0_valid,
    input LQ_index_t dcache_read_kill_0_LQ_index,
    input logic dcache_read_kill_1_valid,
    input LQ_index_t dcache_read_kill_1_LQ_index,

    // invalidation interface:
        // TODO: implement logic for multicore
            // already implemented eviction inv's, technically don't need for unicore
            // need to add snoop inv's -> potentially need new Q or double this interface to core
    output logic dcache_inv_valid,
    output block_addr_t dcache_inv_block_addr,

    // halt interface:
    input logic dcache_halt,

    ////////////////////
    // mem interface: //
    ////////////////////
        // asynchronous, non-blocking interface
    
    // dmem read req:
    output logic dmem_read_req_valid,
    output block_addr_t dmem_read_req_block_addr,

    // dmem read resp:
    input logic dmem_read_resp_valid,
    input block_addr_t dmem_read_resp_block_addr,
    input word_t [1:0] dmem_read_resp_data,

    // dmem write req:
    output logic dmem_write_req_valid,
    output block_addr_t dmem_write_req_block_addr,
    output word_t [1:0] dmem_write_req_data,

    //////////////
    // flushed: //
    //////////////

    output logic flushed
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
    // dcache logic:

    // // registered dcache read resp interface:
    // logic next_dcache_read_resp_valid;
    // LQ_index_t next_dcache_read_resp_LQ_index;
    // word_t next_dcache_read_resp_data;
        // already reg'ing hit return and miss return Q, just select from reg outputs

    // dcache_*_req_addr -> struct
    typedef struct packed {
        // no upper bits
        logic [DCACHE_NUM_TAG_BITS-1:0] tag;
        logic [DCACHE_NUM_INDEX_BITS-1:0] index;
        logic [WORD_ADDR_SPACE_WIDTH-BLOCK_ADDR_SPACE_WIDTH-1:0] block_offset;
    } dcache_word_addr_t;

    dcache_word_addr_t dcache_read_req_addr_structed;
    dcache_word_addr_t dcache_write_req_addr_structed;

    // MSHR block addr struct
    typedef struct packed {
        logic [DCACHE_NUM_TAG_BITS-1:0] tag;
        logic [DCACHE_NUM_INDEX_BITS-1:0] index;
    } dcache_block_addr_t;

    // dcache frame
        // TODO: update for multicore -> MOESI
    typedef struct packed {
        logic valid;
        logic dirty;
        logic [DCACHE_NUM_TAG_BITS-1:0] tag;
        word_t [1:0] block;
    } dcache_frame_t;

    // create dcache sets
    dcache_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] dcache_frame_by_way_by_set;
    dcache_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] next_dcache_frame_by_way_by_set;

    // dcache set-wise LRU
        // each set has pointer to LRU way
    logic [DCACHE_NUM_SETS-1:0][DCACHE_LOG_NUM_WAYS-1:0] dcache_set_LRU;
    logic [DCACHE_NUM_SETS-1:0][DCACHE_LOG_NUM_WAYS-1:0] next_dcache_set_LRU;

    // load MSHR:
        // 1 per LQ entry
        // need to track data to fill 

    // load MSHR struct
    typedef struct packed {
        logic valid;
        logic fulfilled;
        // logic launched; // guarantee launch same cycle as when fill MSHR
        // logic [DCACHE_LOG_NUM_WAYS-1:0] way; // pick LRU way on return path
        // LQ_index_t LQ_index; // index of this MSHR follows LQ index
        dcache_block_addr_t block_addr;
        logic [DCACHE_NUM_BLOCK_OFFSET_BITS-1:0] block_offset;
        word_t [1:0] read_block; // read data from mem
        // word_t [1:0] write_block; // eviction data // evict on return path
    } dcache_load_MSHR_t;

    // create load MSHR's
    dcache_load_MSHR_t [LQ_DEPTH-1:0] load_MSHR_by_LQ_index;
    dcache_load_MSHR_t [LQ_DEPTH-1:0] next_load_MSHR_by_LQ_index;

    // store MSHR:
        // 1 MSHR with in-order Q access
        // Q full, give dcache_write_req_blocked to core

    // store MSHR struct
    typedef struct packed {
        logic valid;
        logic fulfilled;
        // logic launched; // guarantee launch same cycle as when add to store MSHR Q
        // logic [DCACHE_LOG_NUM_WAYS-1:0] way; // pick LRU way on return path
        dcache_block_addr_t block_addr;
        logic [DCACHE_NUM_BLOCK_OFFSET_BITS-1:0] block_offset;
            // block offset can tell immediately store word 0 or word 1 to block when place in cache frame
        word_t store_word; // store data from core
        word_t [1:0] read_block; // read data from mem
        // word_t [1:0] write_block; // eviction data // evict on return path
    } dcache_store_MSHR_t;

    // create store MSHR
    dcache_store_MSHR_t store_MSHR;
    dcache_store_MSHR_t next_store_MSHR;

    // store MSHR Q entries
    typedef struct packed {
        logic valid;
        dcache_block_addr_t block_addr;
        logic [DCACHE_NUM_BLOCK_OFFSET_BITS-1:0] block_offset;
        word_t store_word;
    } dcache_store_MSHR_Q_entry_t;

    // create store MSHR Q
    dcache_store_MSHR_Q_entry_t [DCACHE_STORE_MSHR_Q_DEPTH-1:0] store_MSHR_Q;
    dcache_store_MSHR_Q_entry_t [DCACHE_STORE_MSHR_Q_DEPTH-1:0] next_store_MSHR_Q;

    // store MSHR Q head and tail pointers
    typedef struct packed {
        logic msb;
        logic [DCACHE_LOG_STORE_MSHR_Q_DEPTH-1:0] index;
    } dcache_store_MSHR_Q_ptr_t;

    dcache_store_MSHR_Q_ptr_t store_MSHR_Q_head_ptr;
    dcache_store_MSHR_Q_ptr_t next_store_MSHR_Q_head_ptr;
    dcache_store_MSHR_Q_ptr_t store_MSHR_Q_tail_ptr;
    dcache_store_MSHR_Q_ptr_t next_store_MSHR_Q_tail_ptr;

    // dcache state
    typedef enum logic [1:0] {
        DCACHE_IDLE,
        DCACHE_DRAIN_STORE_MSHR_Q,
        DCACHE_FLUSH,
        DCACHE_HALT
    } dcache_state_t;

    dcache_state_t dcache_state;
    dcache_state_t next_dcache_state;

    // flush counter
        // value for each block in dcache
        // writes are taken at block granularity
    typedef struct packed {
        logic msb;
        logic [DCACHE_LOG_NUM_WAYS-1:0] way;
        logic [DCACHE_NUM_INDEX_BITS-1:0] index;
    } flush_counter_t;

    flush_counter_t flush_counter;
    flush_counter_t next_flush_counter;

    // bus read req arbitration:

    // load miss reg
    typedef struct packed {
        logic valid;
        LQ_index_t LQ_index;
        dcache_block_addr_t block_addr;
        logic [DCACHE_NUM_BLOCK_OFFSET_BITS-1:0] block_offset;
    } dcache_new_load_miss_reg_t;

    dcache_new_load_miss_reg_t new_load_miss_reg;
    dcache_new_load_miss_reg_t next_new_load_miss_reg;

    // store miss reg
        // can reuse MSHR Q entry type

    dcache_store_MSHR_Q_entry_t new_store_miss_reg;
    dcache_store_MSHR_Q_entry_t next_new_store_miss_reg;

    // general bus read req
    typedef struct packed {
        logic valid;
        dcache_block_addr_t block_addr;
    } dcache_general_bus_read_req_t;

    // backlog Q bus read req
    dcache_general_bus_read_req_t [DCACHE_BUS_READ_REQ_BACKLOG_Q_DEPTH-1:0] backlog_Q_bus_read_req_by_entry;
    dcache_general_bus_read_req_t [DCACHE_BUS_READ_REQ_BACKLOG_Q_DEPTH-1:0] next_backlog_Q_bus_read_req_by_entry;

    // backlog Q bus read req pointers
    typedef struct packed {
        logic msb;
        logic [DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH-1:0] index;
    } dcache_backlog_Q_bus_read_req_ptr_t;

    dcache_backlog_Q_bus_read_req_ptr_t backlog_Q_bus_read_req_head_ptr;
    dcache_backlog_Q_bus_read_req_ptr_t next_backlog_Q_bus_read_req_head_ptr;
    dcache_backlog_Q_bus_read_req_ptr_t backlog_Q_bus_read_req_tail_ptr;
    dcache_backlog_Q_bus_read_req_ptr_t next_backlog_Q_bus_read_req_tail_ptr;

    // load hit signal
    logic load_hit_this_cycle;

    // store hit signal
    logic store_hit_this_cycle;

    // found valid load MSHR
    logic found_load_MSHR_fulfilled;
    LQ_index_t found_load_MSHR_LQ_index;

    // found empty way
    logic found_empty_way;
    logic [DCACHE_LOG_NUM_WAYS-1:0] empty_way;

    // load return:
    typedef struct packed {
        logic valid;
        LQ_index_t LQ_index;
        word_t data;
    } dcache_load_return_t;

    // load hit return reg
    dcache_load_return_t load_hit_return;
    dcache_load_return_t next_load_hit_return;

    // load miss return Q
    dcache_load_return_t [DCACHE_LOAD_MISS_RETURN_Q_DEPTH-1:0] load_miss_return_Q;
    dcache_load_return_t [DCACHE_LOAD_MISS_RETURN_Q_DEPTH-1:0] next_load_miss_return_Q;

    // load miss return ptr's
    typedef struct packed {
        logic msb;
        logic [DCACHE_LOG_LOAD_MISS_RETURN_Q_DEPTH-1:0] index;
    } dcache_load_miss_return_Q_ptr_t;

    dcache_load_miss_return_Q_ptr_t load_miss_return_Q_head_ptr;
    dcache_load_miss_return_Q_ptr_t next_load_miss_return_Q_head_ptr;
    dcache_load_miss_return_Q_ptr_t load_miss_return_Q_tail_ptr;
    dcache_load_miss_return_Q_ptr_t next_load_miss_return_Q_tail_ptr;

    // hit counter for perf
    word_t hit_counter;
    word_t next_hit_counter;

    // store MSHR Q not all inv's
    logic found_store_MSHR_Q_valid_entry;

    // flushed reg
    logic next_flushed;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            // dcache_read_resp_valid <= 1'b0;
            // dcache_read_resp_LQ_index <= LQ_index_t'(0);
            // dcache_read_resp_data <= 32'h0;
            dcache_frame_by_way_by_set <= '0;
            dcache_set_LRU <= '0;
            load_MSHR_by_LQ_index <= '0;
            store_MSHR <= '0;
            store_MSHR_Q <= '0;
            store_MSHR_Q_head_ptr <= '0;
            store_MSHR_Q_tail_ptr <= '0;
            dcache_state <= DCACHE_IDLE;
            flush_counter <= '0;
            new_load_miss_reg <= '0;
            new_store_miss_reg <= '0;
            backlog_Q_bus_read_req_by_entry <= '0;
            backlog_Q_bus_read_req_head_ptr <= '0;
            backlog_Q_bus_read_req_tail_ptr <= '0;
            load_hit_return <= '0;
            load_miss_return_Q <= '0;
            load_miss_return_Q_head_ptr <= '0;
            load_miss_return_Q_tail_ptr <= '0;
            hit_counter <= '0;
            flushed <= 1'b0;
        end
        else begin
            // dcache_read_resp_valid <= next_dcache_read_resp_valid;
            // dcache_read_resp_LQ_index <= next_dcache_read_resp_LQ_index;
            // dcache_read_resp_data <= next_dcache_read_resp_data;
            dcache_frame_by_way_by_set <= next_dcache_frame_by_way_by_set;
            dcache_set_LRU <= next_dcache_set_LRU;
            load_MSHR_by_LQ_index <= next_load_MSHR_by_LQ_index;
            store_MSHR <= next_store_MSHR;
            store_MSHR_Q <= next_store_MSHR_Q;
            store_MSHR_Q_head_ptr <= next_store_MSHR_Q_head_ptr;
            store_MSHR_Q_tail_ptr <= next_store_MSHR_Q_tail_ptr;
            dcache_state <= next_dcache_state;
            flush_counter <= next_flush_counter;
            new_load_miss_reg <= next_new_load_miss_reg;
            new_store_miss_reg <= next_new_store_miss_reg;
            backlog_Q_bus_read_req_by_entry <= next_backlog_Q_bus_read_req_by_entry;
            backlog_Q_bus_read_req_head_ptr <= next_backlog_Q_bus_read_req_head_ptr;
            backlog_Q_bus_read_req_tail_ptr <= next_backlog_Q_bus_read_req_tail_ptr;
            load_hit_return <= next_load_hit_return;
            load_miss_return_Q <= next_load_miss_return_Q;
            load_miss_return_Q_head_ptr <= next_load_miss_return_Q_head_ptr;
            load_miss_return_Q_tail_ptr <= next_load_miss_return_Q_tail_ptr;
            hit_counter <= next_hit_counter;
            flushed <= next_flushed;
        end
    end

    // comb logic
    always_comb begin

        //////////////////////
        // default outputs: //
        //////////////////////

        ////////////////
        // DUT error: 

        next_DUT_error = 1'b0;

        /////////////////////
        // core interface:

        // read req interface:
        dcache_read_req_blocked = 1'b0; // effectively LQ full for dispatch, don't think have use for this
        
        // read resp interface:

        // write req interface: 
            // block if store MSHR Q full
        dcache_write_req_blocked = 
            store_MSHR_Q_head_ptr.msb != store_MSHR_Q_tail_ptr.msb
            &
            store_MSHR_Q_head_ptr.index == store_MSHR_Q_tail_ptr.index
        ;

        // read kill interface x2:
        
        // invalidation interface:
            // for now, just have inv from eviction
            // TODO: implement logic for multicore
            // may want Q of sorts since can get inv from eviction and snoop inv
        dcache_inv_valid = 1'b0;
        dcache_inv_block_addr = 13'h0;

        // halt interface:

        ////////////////////
        // mem interface: 

        // dmem read req:
        dmem_read_req_valid = 1'b0;
        dmem_read_req_block_addr = 13'h0;

        // dmem read resp:

        // dmem write req:
            // invalid store MSHR req
                // can't default to load MSHR req as need CAM search info
        dmem_write_req_valid = 1'b0;
        dmem_write_req_block_addr = {
            // tag in frame:
            dcache_frame_by_way_by_set
            // select way following LRU @ store MSHR index
            [
                dcache_set_LRU
                [store_MSHR.block_addr.index]
            ] 
            // select set following store MSHR index
            [store_MSHR.block_addr.index]
            .tag
            ,
            // MSHR index:
            store_MSHR.block_addr.index
        };
        dmem_write_req_data = 
            dcache_frame_by_way_by_set
            // select way following LRU @ store MSHR index
            [
                dcache_set_LRU
                [store_MSHR.block_addr.index]
            ] 
            // select set following store MSHR index
            [store_MSHR.block_addr.index]
            .block
        ;

        //////////////
        // flushed: 

        next_flushed = 1'b0;

        ///////////////////////
        // internal signals: 

        // registered dcache read resp interface:
            // invalid from hit return
        dcache_read_resp_valid = 1'b0;
        dcache_read_resp_LQ_index = load_hit_return.LQ_index;
        dcache_read_resp_data = load_hit_return.data;
        
        // dcache_*_req_addr -> struct
        dcache_read_req_addr_structed = dcache_read_req_addr;
        dcache_write_req_addr_structed = dcache_write_req_addr;

        // dcache frame
        next_dcache_frame_by_way_by_set = dcache_frame_by_way_by_set;

        // dcache set-wise LRU
        next_dcache_set_LRU = dcache_set_LRU;

        // load MSHR
        next_load_MSHR_by_LQ_index = load_MSHR_by_LQ_index;

        // store MSHR
        next_store_MSHR = store_MSHR;

        // store MSHR Q
        next_store_MSHR_Q = store_MSHR_Q;

        // store MSHR Q head and tail pointers
        next_store_MSHR_Q_head_ptr = store_MSHR_Q_head_ptr;
        next_store_MSHR_Q_tail_ptr = store_MSHR_Q_tail_ptr;

        // dcache state
        next_dcache_state = dcache_state;

        // flush counter
        next_flush_counter = flush_counter;

        // load miss reg
            // invalid from dcache read req interface
        next_new_load_miss_reg.valid = 1'b0;
        next_new_load_miss_reg.LQ_index = dcache_read_req_LQ_index;
        next_new_load_miss_reg.block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};
        next_new_load_miss_reg.block_offset = dcache_read_req_addr_structed.block_offset;

        // store miss reg
            // invalid from dcache write req interface
        next_new_store_miss_reg.valid = 1'b0;
        next_new_store_miss_reg.block_addr = {dcache_write_req_addr_structed.tag, dcache_write_req_addr_structed.index};
        next_new_store_miss_reg.block_offset = dcache_write_req_addr_structed.block_offset;
        next_new_store_miss_reg.store_word = dcache_write_req_data;

        // backlog Q bus read req
        next_backlog_Q_bus_read_req_by_entry = backlog_Q_bus_read_req_by_entry;

        // backlog Q bus read req pointers
        next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr;
        next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr;

        // load hit return reg
            // inv from dcache read req, way 0
        next_load_hit_return.valid = 1'b0;
        next_load_hit_return.LQ_index = dcache_read_req_LQ_index;
        next_load_hit_return.data = 
            dcache_frame_by_way_by_set
            [0]
            [dcache_read_req_addr_structed.index]
            .block
            [dcache_read_req_addr_structed.block_offset]
        ;

        // load miss return Q
        next_load_miss_return_Q = load_miss_return_Q;

        // load miss return ptr's
        next_load_miss_return_Q_head_ptr = load_miss_return_Q_head_ptr;
        next_load_miss_return_Q_tail_ptr = load_miss_return_Q_tail_ptr;

        // hit counter for perf
        next_hit_counter = hit_counter;

        //////////////////////////
        // load hit path logic: //
        //////////////////////////

        // no load hit
        load_hit_this_cycle = 1'b0;

        // check have dcache read req
        if (dcache_read_req_valid) begin

            // iterate over ways
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check VTM
                if (
                    dcache_frame_by_way_by_set[i][dcache_read_req_addr_structed.index].valid
                    &
                    (
                        dcache_frame_by_way_by_set[i][dcache_read_req_addr_structed.index].tag
                        ==
                        dcache_read_req_addr_structed.tag
                    )
                ) begin

                    // have hit
                    load_hit_this_cycle = 1'b1;

                    // set hit return
                    next_load_hit_return.valid = 1'b1;
                    next_load_hit_return.LQ_index = dcache_read_req_LQ_index;
                    next_load_hit_return.data = 
                        dcache_frame_by_way_by_set
                        [i]
                        [dcache_read_req_addr_structed.index]
                        .block
                        [dcache_read_req_addr_structed.block_offset]
                    ;

                    // // set LRU opposite this way
                    //     // this part assumes 2-way assoc, otherwise "LRU" is just not the last way touched
                    //     // NMRU -> Not Most Recently Used
                    // next_dcache_set_LRU[dcache_read_req_addr_structed.index] = ~i;
                    // set LRU next way
                        // still NMRU but at least don't just toggle between opposite ways
                    next_dcache_set_LRU[dcache_read_req_addr_structed.index] = i + 1;

                    // add hit for perf counter
                        // do next in case load and store both hit
                    next_hit_counter = next_hit_counter + 1;
                    $display("dcache: hit #%d", next_hit_counter);
                end
            end

            // check no hit after iter through ways
            if (~load_hit_this_cycle) begin

                // set load miss reg
                next_new_load_miss_reg.valid = 1'b1;
                next_new_load_miss_reg.LQ_index = dcache_read_req_LQ_index;
                next_new_load_miss_reg.block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};
                next_new_load_miss_reg.block_offset = dcache_read_req_addr_structed.block_offset;
            end
        end

        ///////////////////////////
        // store hit path logic: //
        ///////////////////////////

        // no store hit
        store_hit_this_cycle = 1'b0;

        // check have dcache read req
        if (dcache_write_req_valid) begin

            // iterate over ways
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check VTM
                if (
                    dcache_frame_by_way_by_set[i][dcache_write_req_addr_structed.index].valid
                    &
                    (
                        dcache_frame_by_way_by_set[i][dcache_write_req_addr_structed.index].tag
                        ==
                        dcache_write_req_addr_structed.tag
                    )
                ) begin

                    // have hit
                    store_hit_this_cycle = 1'b1;

                    // perform write in dcache frame
                    next_dcache_frame_by_way_by_set
                    [i]
                    [dcache_write_req_addr_structed.index]
                    .block
                    [dcache_write_req_addr_structed.block_offset]
                        = dcache_write_req_data;

                    // mark dcache frame dirty
                    next_dcache_frame_by_way_by_set
                    [i]
                    [dcache_write_req_addr_structed.index]
                    .dirty
                        = 1'b1;

                    // // set LRU opposite this way
                    //     // this part assumes 2-way assoc, otherwise "LRU" is just not the last way touched
                    //     // NMRU -> Not Most Recently Used
                    // next_dcache_set_LRU[dcache_write_req_addr_structed.index] = ~i;
                    // set LRU next way
                        // still NMRU but at least don't just toggle between opposite ways
                    next_dcache_set_LRU[dcache_write_req_addr_structed.index] = i + 1;

                    // add hit for perf counter
                        // do next in case load and store both hit
                    next_hit_counter = next_hit_counter + 1;
                    $display("dcache: hit #%d", next_hit_counter);
                end
            end

            // check no hit after iter through ways
            if (~store_hit_this_cycle) begin

                // set store miss reg
                next_new_store_miss_reg.valid = 1'b1;
                next_new_store_miss_reg.block_addr = {dcache_write_req_addr_structed.tag, dcache_write_req_addr_structed.index};
                next_new_store_miss_reg.block_offset = dcache_write_req_addr_structed.block_offset;
                next_new_store_miss_reg.store_word = dcache_write_req_data;
            end
        end

        //////////////////////////////
        // load miss process logic: //
        //////////////////////////////

        // check have load miss
        if (new_load_miss_reg.valid) begin

            // allocate load MSHR @ LQ_index
            next_load_MSHR_by_LQ_index[new_load_miss_reg.LQ_index].valid = 1'b1;
            next_load_MSHR_by_LQ_index[new_load_miss_reg.LQ_index].fulfilled = 1'b0;
            next_load_MSHR_by_LQ_index[new_load_miss_reg.LQ_index].block_addr = new_load_miss_reg.block_addr;
            next_load_MSHR_by_LQ_index[new_load_miss_reg.LQ_index].block_offset = new_load_miss_reg.block_offset;

            // will check competing bus read req's later
        end

        ///////////////////////////////
        // store miss process logic: //
        ///////////////////////////////

        // check have store miss
        if (new_store_miss_reg.valid) begin

            // enQ to store MSHR Q
                // can directly set to new_store_miss_reg values
            next_store_MSHR_Q[store_MSHR_Q_tail_ptr.index] = new_store_miss_reg;

            // increment store MSHR Q tail
            next_store_MSHR_Q_tail_ptr = store_MSHR_Q_tail_ptr + dcache_store_MSHR_Q_ptr_t'(1);

            // will check competing bus read req's later
        end

        ///////////////////////////////
        // bus read req arbitration: //
        ///////////////////////////////
            // case combos on {head of backlog, new load miss, new store miss}
            // 2^3 = 8 cases
        
        case ({
            backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr].valid,
            new_load_miss_reg.valid,
            new_store_miss_reg.valid
        })

            3'b111:
            begin
                // service backlog
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].block_addr
                ;

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].valid = 1'b0;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;

                // enQ load miss @ backlog tail
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].valid = 1'b1;
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].block_addr =
                    new_load_miss_reg.block_addr
                ;

                // enQ store miss @ backlog tail + 1
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index + 1].valid = 1'b1;
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index + 1].block_addr =
                    new_store_miss_reg.block_addr
                ;

                // increment backlog tail + 2
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;

                // check if tail surpasses head
                    // tail msb != head msb
                    // next_tail index == next_head index + 1 -> tail index + 2 == head index + 2
                    // tail index == head index
                if (
                    backlog_Q_bus_read_req_tail_ptr.msb != backlog_Q_bus_read_req_head_ptr.msb
                    &
                    backlog_Q_bus_read_req_tail_ptr.index == backlog_Q_bus_read_req_head_ptr.index
                ) begin
                    $display("dcache: ERROR: backlog Q tail surpasses head: 3'b111");
                    $display("\t@: %0t",$realtime);
                    next_DUT_error = 1'b1;
                end
            end

            3'b110:
            begin
                // service backlog
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].block_addr
                ;

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].valid = 1'b0;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;

                // enQ load miss @ backlog tail
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].valid = 1'b1;
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].block_addr =
                    new_load_miss_reg.block_addr
                ;

                // increment backlog tail + 1
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;
            end

            3'b101:
            begin
                // service backlog
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].block_addr
                ;

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].valid = 1'b0;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;

                // enQ store miss @ backlog tail
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].valid = 1'b1;
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].block_addr =
                    new_store_miss_reg.block_addr
                ;

                // increment backlog tail + 1
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;
            end
            
            3'b100:
            begin
                // service backlog
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].block_addr
                ;

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].valid = 1'b0;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;
            end

            3'b011:
            begin
                // service load miss
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = new_load_miss_reg.block_addr;

                // enQ store miss @ backlog tail
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].valid = 1'b1;
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_tail_ptr.index].block_addr =
                    new_store_miss_reg.block_addr
                ;

                // increment backlog tail + 1
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;
            end

            3'b010:
            begin
                // service load miss
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = new_load_miss_reg.block_addr;
            end

            3'b001:
            begin
                // service store miss
                dmem_read_req_valid = 1'b1;
                dmem_read_req_block_addr = new_store_miss_reg.block_addr;
            end

            default:
            begin
                // no service
            end

        endcase

        //////////////////////
        // load MSHR logic: //
        //////////////////////
        
        // kill bus 0
        if (dcache_read_kill_0_valid) begin

            // invalidate MSHR
                // don't need to check anything else?
            next_load_MSHR_by_LQ_index[dcache_read_kill_0_LQ_index].valid = 1'b0;
        end

        // kill bus 1
        if (dcache_read_kill_1_valid) begin

            // invalidate MSHR
                // don't need to check anything else?
            next_load_MSHR_by_LQ_index[dcache_read_kill_1_LQ_index].valid = 1'b0;
        end

        ///////////////////////
        // store MSHR logic: //
        ///////////////////////

        // check deQ
            // have store MSHR Q entry valid and MSHR invalid
        if (
            store_MSHR_Q[store_MSHR_Q_head_ptr.index].valid
            &
            ~store_MSHR.valid
        ) begin

            // fill in MSHR
            next_store_MSHR.valid = 1'b1;
            next_store_MSHR.fulfilled = 1'b0;
            next_store_MSHR.block_addr = store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr;
            next_store_MSHR.block_offset = store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_offset;
            next_store_MSHR.store_word = store_MSHR_Q[store_MSHR_Q_head_ptr.index].store_word;

            // invalidate store MSHR Q head entry
            next_store_MSHR_Q[store_MSHR_Q_head_ptr.index].valid = 1'b0;

            // increment store MSHR Q head
            next_store_MSHR_Q_head_ptr = store_MSHR_Q_head_ptr + 1;
        end

        // otherwise, check if tail surpasses head
            // next tail msb != next head msb
            // next_tail index == next_head index + 1
        else if (
            next_store_MSHR_Q_tail_ptr.msb != next_store_MSHR_Q_head_ptr.msb
            &
            next_store_MSHR_Q_tail_ptr.index == next_store_MSHR_Q_head_ptr.index + 1
        ) begin
            $display("dcache: ERROR: store MSHR Q tail surpasses head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

        //////////////////////////////
        // miss resp process logic: //
        //////////////////////////////
            // block addr broadcasted
            // service all relevant MSHR's

        // check have dmem read resp
        if (dmem_read_resp_valid) begin

            // check all load MSHR's
            for (int i = 0; i < LQ_DEPTH; i++) begin

                // check block addr match
                    // can safely bring in load val regardless of if valid as long as block addr matches
                if (
                    load_MSHR_by_LQ_index[i].block_addr
                    ==
                    dmem_read_resp_block_addr
                ) begin

                    // mark MSHR fulfilled
                    next_load_MSHR_by_LQ_index[i].fulfilled = 1'b1;
                    
                    // fill in read block
                    next_load_MSHR_by_LQ_index[i].read_block = dmem_read_resp_data;
                end
            end

            // check store MSHR
                // can safely bring in load val regardless of if valid
            if (
                store_MSHR.block_addr
                ==
                dmem_read_resp_block_addr
            ) begin

                // mark MSHR fulfilled
                next_store_MSHR.fulfilled = 1'b1;

                // fill in read block w/ written word
                next_store_MSHR.read_block[store_MSHR.block_offset] = store_MSHR.store_word;
                next_store_MSHR.read_block[~store_MSHR.block_offset] = dmem_read_resp_data[~store_MSHR.block_offset];
            end
        end

        ///////////////////////////
        // miss resp fill logic: //
        ///////////////////////////
            // choose MSHR to fill cache
            // if load, return value
            // deal with evictions

        // find winning MSHR on 4x load MSHR's, 1x store MSHR
        
        // iterate through load MSHR's, picking one if exists
        found_load_MSHR_fulfilled = 1'b0;
        found_load_MSHR_LQ_index = LQ_index_t'(0);
        for (int i = LQ_DEPTH-1; i >= 0; i--) begin
                // iterate through i's in reverse order so prioritize earlier index

            // check MSHR valid and fulfilled
            if (load_MSHR_by_LQ_index[i].valid & load_MSHR_by_LQ_index[i].fulfilled) begin

                // found valid load MSHR
                found_load_MSHR_fulfilled = 1'b1;

                // mark miss return LQ index
                found_load_MSHR_LQ_index = LQ_index_t'(i);
            end
        end

        // check found MSHR, enQ single load MSHR chosen
        found_empty_way = 1'b0;
        empty_way = '0;
        if (found_load_MSHR_fulfilled) begin

            // search for empty way
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check this entry invalid
                if (
                    ~dcache_frame_by_way_by_set
                    // select way following CAM loop
                    [i]
                    // select set following LQ index MSHR index
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .valid
                ) begin

                    // save empty way
                    found_empty_way = 1'b1;
                    empty_way = i;
                end
            end

            // have empty way
            if (found_empty_way) begin

                // no eviction

                // fill empty way frame
                    // valid
                    // not dirty
                    // tag from MSHR
                    // block from MSHR
                next_dcache_frame_by_way_by_set
                [empty_way]
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .valid
                    = 1'b1;

                next_dcache_frame_by_way_by_set
                [empty_way]
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .dirty
                    = 1'b0;

                next_dcache_frame_by_way_by_set
                [empty_way]
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .tag
                    = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.tag;
                
                next_dcache_frame_by_way_by_set
                [empty_way]
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .block
                    = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].read_block;

                // update LRU
                    // this found way + 1
                next_dcache_set_LRU
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    = empty_way + 1;
            end

            // otherwise, use LRU way
            else begin

                // evict LRU @ found LQ index MSHR index if frame dirty
                if (
                    dcache_frame_by_way_by_set
                    // select way following LRU @ LQ index MSHR index
                    [
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                    ] 
                    // select set following LQ index MSHR index
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .dirty
                ) begin

                    // send dmem write req
                        // valid
                        // block addr follows (tag in frame, MSHR index)
                        // data follows frame
                    dmem_write_req_valid = 1'b1;
                    dmem_write_req_block_addr = {
                        // tag in frame:
                        dcache_frame_by_way_by_set
                        // select way following LRU @ LQ index MSHR index
                        [
                            dcache_set_LRU
                            [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                        ] 
                        // select set following LQ index MSHR index
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                        .tag
                        ,
                        // MSHR index:
                        load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index
                    };
                    dmem_write_req_data = 
                        dcache_frame_by_way_by_set
                        // select way following LRU @ LQ index MSHR index
                        [
                            dcache_set_LRU
                            [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                        ] 
                        // select set following LQ index MSHR index
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                        .block
                    ;

                    // send evict to core
                        // valid
                        // block addr follows (tag in frame, MSHR index)
                    dcache_inv_valid = 1'b1;
                    dcache_inv_block_addr = {
                        // tag in frame:
                        dcache_frame_by_way_by_set
                        // select way following LRU @ LQ index MSHR index
                        [
                            dcache_set_LRU
                            [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                        ] 
                        // select set following LQ index MSHR index
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                        .tag
                        ,
                        // MSHR index:
                        load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index
                    };
                end

                // fill LRU frame
                    // valid
                    // not dirty
                    // tag from MSHR
                    // block from MSHR
                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                ] 
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .valid
                    = 1'b1;

                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                ] 
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .dirty
                    = 1'b0;

                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                ] 
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .tag
                    = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.tag;
                
                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                ] 
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                .block
                    = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].read_block;

                // update LRU
                    // LRU + 1
                next_dcache_set_LRU
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                =
                dcache_set_LRU
                [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                + 1;
            end

            // invalidate MSHR
            next_load_MSHR_by_LQ_index
            [found_load_MSHR_LQ_index]
            .valid
                = 1'b0;

            // return data to core:

            // append load miss return Q
                // valid
                // selected found load MSHR LQ index
                // data
            next_load_miss_return_Q
            [load_miss_return_Q_tail_ptr.index]
            .valid 
                = 1'b1;

            next_load_miss_return_Q
            [load_miss_return_Q_tail_ptr.index]
            .LQ_index 
                = found_load_MSHR_LQ_index;

            next_load_miss_return_Q
            [load_miss_return_Q_tail_ptr.index]
            .data
                = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].read_block;

            // increment load miss return Q tail
            next_load_miss_return_Q_tail_ptr = load_miss_return_Q_tail_ptr + 1;
        end

        // otherwise, can service store MSHR if valid and fulfilled
        else if (store_MSHR.valid & store_MSHR.fulfilled) begin

            // search for empty way
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check this entry invalid
                if (
                    ~dcache_frame_by_way_by_set
                    // select way following CAM loop
                    [i]
                    // select set following store MSHR index
                    [store_MSHR.block_addr.index]
                    .valid
                ) begin

                    // save empty way
                    found_empty_way = 1'b1;
                    empty_way = i;
                end
            end

            // have empty way
            if (found_empty_way) begin

                // no eviction

                // fill empty way frame
                    // valid
                    // dirty
                    // tag from MSHR
                    // block from MSHR
                next_dcache_frame_by_way_by_set
                [empty_way]
                [store_MSHR.block_addr.index]
                .valid
                    = 1'b1;

                next_dcache_frame_by_way_by_set
                [empty_way]
                [store_MSHR.block_addr.index]
                .dirty
                    = 1'b1;

                next_dcache_frame_by_way_by_set
                [empty_way]
                [store_MSHR.block_addr.index]
                .tag
                    = store_MSHR.block_addr.tag;
                
                next_dcache_frame_by_way_by_set
                [empty_way]
                [store_MSHR.block_addr.index]
                .block
                    = store_MSHR.read_block;

                // update LRU
                    // this found way + 1
                next_dcache_set_LRU
                [store_MSHR.block_addr.index]
                    = empty_way + 1;
            end

            // otherwise, use LRU way
            else begin

                // evict LRU @ found store MSHR index if frame dirty
                if (
                    dcache_frame_by_way_by_set
                    // select way following LRU @ store MSHR index
                    [
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ] 
                    // select set following store MSHR index
                    [store_MSHR.block_addr.index]
                    .dirty
                ) begin

                    // send dmem write req
                        // valid
                        // block addr follows (tag in frame, MSHR index)
                        // data follows frame
                    dmem_write_req_valid = 1'b1;
                    dmem_write_req_block_addr = {
                        // tag in frame:
                        dcache_frame_by_way_by_set
                        // select way following LRU @ store MSHR index
                        [
                            dcache_set_LRU
                            [store_MSHR.block_addr.index]
                        ] 
                        // select set following store MSHR index
                        [store_MSHR.block_addr.index]
                        .tag
                        ,
                        // MSHR index:
                        store_MSHR.block_addr.index
                    };
                    dmem_write_req_data = 
                        dcache_frame_by_way_by_set
                        // select way following LRU @ store MSHR index
                        [
                            dcache_set_LRU
                            [store_MSHR.block_addr.index]
                        ] 
                        // select set following store MSHR index
                        [store_MSHR.block_addr.index]
                        .block
                    ;

                    // send evict to core
                        // valid
                        // block addr follows (tag in frame, MSHR index)
                    dcache_inv_valid = 1'b1;
                    dcache_inv_block_addr = {
                        // tag in frame:
                        dcache_frame_by_way_by_set
                        // select way following LRU @ LQ index MSHR index
                        [
                            dcache_set_LRU
                            [store_MSHR.block_addr.index]
                        ] 
                        // select set following LQ index MSHR index
                        [store_MSHR.block_addr.index]
                        .tag
                        ,
                        // MSHR index:
                        store_MSHR.block_addr.index
                    };
                end

                // fill LRU frame
                    // valid
                    // dirty
                    // tag from MSHR
                    // block from MSHR
                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [store_MSHR.block_addr.index]
                ] 
                [store_MSHR.block_addr.index]
                .valid
                    = 1'b1;

                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [store_MSHR.block_addr.index]
                ] 
                [store_MSHR.block_addr.index]
                .dirty
                    = 1'b1;

                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [store_MSHR.block_addr.index]
                ] 
                [store_MSHR.block_addr.index]
                .tag
                    = store_MSHR.block_addr.tag;
                
                next_dcache_frame_by_way_by_set
                [
                    dcache_set_LRU
                    [store_MSHR.block_addr.index]
                ] 
                [store_MSHR.block_addr.index]
                .block
                    = store_MSHR.read_block;

                // update LRU
                    // LRU + 1
                next_dcache_set_LRU
                [store_MSHR.block_addr.index]
                =
                dcache_set_LRU
                [store_MSHR.block_addr.index]
                + 1;
            end

            // invalidate MSHR
            next_store_MSHR
            .valid
                = 1'b0;
        end

        ////////////////////////
        // load return logic: //
        ////////////////////////
            // pick hit return or miss return Q
            // must prioritize hit return or will be lost

        // check for load hit
        if (load_hit_return.valid) begin

            // valid from hit return
            dcache_read_resp_valid = 1'b1;
            dcache_read_resp_LQ_index = load_hit_return.LQ_index;
            dcache_read_resp_data = load_hit_return.data;
        end

        // otherwise, check for load miss return
        else if (load_miss_return_Q[load_miss_return_Q_head_ptr.index].valid) begin

            // valid from miss return
            dcache_read_resp_valid = 1'b1;
            dcache_read_resp_LQ_index = 
                load_miss_return_Q[load_miss_return_Q_head_ptr.index].LQ_index
            ;
            dcache_read_resp_data = 
                load_miss_return_Q[load_miss_return_Q_head_ptr.index].data
            ;

            // invalidate miss return Q head
            next_load_miss_return_Q[load_miss_return_Q_head_ptr.index].valid = 1'b0;

            // increment miss return Q
            next_load_miss_return_Q_head_ptr = load_miss_return_Q_head_ptr + 1;
        end

        // check load miss return Q tail surpasses head
            // next tail msb != next head msb
            // next tail index == next head index + 1
        if (
            next_load_miss_return_Q_tail_ptr.msb != next_load_miss_return_Q_head_ptr.msb
            &
            next_load_miss_return_Q_tail_ptr.index == next_load_miss_return_Q_head_ptr.index + 1
        ) begin
            $display("dcache: ERROR: load miss return Q tail surpasses head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

        /////////////////////////
        // dcache state logic: //
        /////////////////////////

        found_store_MSHR_Q_valid_entry = 1'b0;

        case (dcache_state) 

            DCACHE_IDLE:
            begin
                // check for core halt
                if (dcache_halt) begin

                    // goto drain state
                    next_dcache_state = DCACHE_DRAIN_STORE_MSHR_Q;

                    // invalidate load MSHR's
                    for (int i = 0; i < LQ_DEPTH; i++) begin
                        next_load_MSHR_by_LQ_index[i].valid = 1'b0;
                    end
                end
            end

            DCACHE_DRAIN_STORE_MSHR_Q:
            begin
                // invalidate load MSHR's
                for (int i = 0; i < LQ_DEPTH; i++) begin
                    next_load_MSHR_by_LQ_index[i].valid = 1'b0;
                end

                // search store MSHR Q for valid entry
                found_store_MSHR_Q_valid_entry = 1'b0;
                for (int i = 0; i < DCACHE_STORE_MSHR_Q_DEPTH; i++) begin

                    // check for valid entr
                    if (store_MSHR_Q[i].valid) begin

                        // mark found valid entry
                        found_store_MSHR_Q_valid_entry = 1'b1;
                    end
                end

                // check store MSHR Q all inv's and store MSHR inv
                if (
                    ~found_store_MSHR_Q_valid_entry
                    &
                    ~store_MSHR.valid
                ) begin

                    // goto flush state
                    next_dcache_state = DCACHE_FLUSH;
                end
            end

            DCACHE_FLUSH:
            begin
                // invalidate load MSHR's
                for (int i = 0; i < LQ_DEPTH; i++) begin
                    next_load_MSHR_by_LQ_index[i].valid = 1'b0;
                end

                // if counter msb == 1, goto halt state
                    // shouldn't double write index 0 since should have been invalidated
                if (flush_counter.msb) begin
                    next_dcache_state = DCACHE_HALT;
                end

                // otherwise, send dmem write req for this counter value if entry valid and dirty
                if (
                    dcache_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .valid
                    &
                    dcache_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .dirty
                ) begin
                    
                    // send dmem write req
                        // valid
                        // block addr follows (tag in frame, counter index)
                        // data follows frame
                    dmem_write_req_valid = 1'b1;
                    dmem_write_req_block_addr = {
                        // tag in frame
                        dcache_frame_by_way_by_set
                        [flush_counter.way]
                        [flush_counter.index]
                        .tag
                        ,
                        // counter index
                        flush_counter.index
                    };
                    dmem_write_req_data = 
                        dcache_frame_by_way_by_set
                        [flush_counter.way]
                        [flush_counter.index]
                        .block
                    ;

                    // invalidate frame
                    next_dcache_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .valid
                        = 1'b0;
                end

                // increment counter
                next_flush_counter = flush_counter + 1;
            end

            DCACHE_HALT:
            begin
                // invalidate load MSHR's
                for (int i = 0; i < LQ_DEPTH; i++) begin
                    next_load_MSHR_by_LQ_index[i].valid = 1'b0;
                end

                // send flushed to system
                next_flushed = 1'b1;
            end

        endcase

    end

endmodule