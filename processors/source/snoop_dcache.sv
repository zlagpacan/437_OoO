/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: snoop_dcache.sv
    Instantiation Hierarchy: system -> snoop_dcache
    Description:

        The snoop_dcache interacts with the core and the bus controller, translating core requests
        into responses with memory fetched values (potentially cached). 

        Memory fetches are at block granularity. Core requests are at word granularity.

        Implement as 2-way associative cache with 8 sets.

        Non-blocking, asynchronous interface to core and to mem.

        4 MSHR's, 1 assigned to each LQ index.

        Snoop Additions:

            - MOESI block state
                - read hits on MOES
                    - no state change
                - write hits on ME
                    - E -> M
                    - write misses require more store MSHR logic to make sure return upgrading way 
            
            - duplicate tag array for snoop access
                - snoop tag array writes when no store MSHR deQ, store miss return,
                    or load miss return
                    - also be careful with giving dbus req, don't want to allow snoop during,
                        else could give old curr_state value
                        - means need to drain backlog Q and no current dbus req's?
                        - curr_state must always be somewhere where can get all updates
                        - need to read latest curr state value in tag array until req succeeds?
                - snoop req Q to work on if don't need to write tag array or 
                    need to write and none of ^ true

        TODO: implement LL-SC
*/

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module snoop_dcache (
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
        // doubled the interface at LSQ for eviction invalidations and snoop invalidations
        // latch so LSQ CAM can begin at beginning of cycle
    output logic dcache_inv_valid,
    output block_addr_t dcache_inv_block_addr,
    output logic dcache_evict_valid,
    output block_addr_t dcache_evict_block_addr,

    // halt interface:
    input logic dcache_halt,

    ///////////////////////////////
    // bus controller interface: //
    ///////////////////////////////
        // asynchronous, non-blocking interface
    
    // dbus req:
    output logic dbus_req_valid,
    output block_addr_t dbus_req_block_addr,
    output logic dbus_req_exclusive,
    output MOESI_state_t dbus_req_curr_state,

    // dbus resp:
    input logic dbus_resp_valid,
    input block_addr_t dbus_resp_block_addr,
    input word_t [1:0] dbus_resp_data,
    input logic dbus_resp_need_block,
    input MOESI_state_t dbus_resp_new_state,

    // snoop req:
    input logic snoop_req_valid,
    input block_addr_t snoop_req_block_addr,
    input logic snoop_req_exclusive,
    input MOESI_state_t snoop_req_curr_state,

    // snoop resp:
    output logic snoop_resp_valid,
    output block_addr_t snoop_resp_block_addr,
    output word_t [1:0] snoop_resp_data,
    output logic snoop_resp_present,
    output logic snoop_resp_need_block,
    output MOESI_state_t snoop_resp_new_state,

    ///////////////////////////////
    // mem controller interface: //
    ///////////////////////////////

    // dmem write req:
    output logic dmem_write_req_valid,
    output block_addr_t dmem_write_req_block_addr,
    output word_t [1:0] dmem_write_req_data,
    input logic dmem_write_req_slow_down,

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

    // // dcache frame
    //     // TODO: update for multicore -> MOESI
    // typedef struct packed {
    //     logic valid;
    //     logic dirty;
    //     logic [DCACHE_NUM_TAG_BITS-1:0] tag;
    //     word_t [1:0] block;
    // } dcache_frame_t;

    // separate tag array and block array of frames
    typedef struct packed {
        MOESI_state_t state;
        logic [DCACHE_NUM_TAG_BITS-1:0] tag;
    } dcache_tag_frame_t;

    typedef struct packed {
        word_t [1:0] block;
    } dcache_data_frame_t;

    // create dcache sets:

    // dcache tag array
    dcache_tag_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] dcache_tag_frame_by_way_by_set;
    dcache_tag_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] next_dcache_tag_frame_by_way_by_set;
    
    // dcache data array
    dcache_data_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] dcache_data_frame_by_way_by_set;
    dcache_data_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] next_dcache_data_frame_by_way_by_set;
        
    // snoop tag array
    dcache_tag_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] snoop_tag_frame_by_way_by_set;
    dcache_tag_frame_t [DCACHE_NUM_WAYS-1:0][DCACHE_NUM_SETS-1:0] next_snoop_tag_frame_by_way_by_set;

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

        logic piggybacking;
        logic [DCACHE_LOG_NUM_WAYS-1:0] piggybacking_way;

        dcache_block_addr_t block_addr;
        logic [DCACHE_NUM_BLOCK_OFFSET_BITS-1:0] block_offset;

        word_t [1:0] read_block;

        // multicore:
            // guaranteed not exclusive
            // guaranteed curr state I
            // guaranteed need block
            // new state can be E or S
        MOESI_state_t new_state;

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

        logic piggybacking;
        logic [DCACHE_LOG_NUM_WAYS-1:0] piggybacking_way;

        dcache_block_addr_t block_addr;
        logic [DCACHE_NUM_BLOCK_OFFSET_BITS-1:0] block_offset;
            // block offset can tell immediately store word 0 or word 1 to block when place in cache frame

        word_t store_word; // store data from core
        word_t [1:0] read_block; // read data from mem
            // read_block takes in current block @ time of miss in case evict before upgrade

        // multicore:
            // guaranteed exclusive
            // curr state can be OESI
            // need block can be 1 (I) or 0 (OES)
                // will be received with dbus resp
                // need block = 0 -> use local store MSHR value (don't update read_block)
                // need block = 1 -> use dbus resp value (update read_block)
            // guaranteed new state M
            // upgrading: 
                // simple: always replace upgrading way, regardless of if still there
                    // may get non-LRU replacement in high set contention
                        // whatever, more important to prevent need to check tags
        logic upgrading;
        logic [DCACHE_LOG_NUM_WAYS-1:0] upgrading_way;
        
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
        
        // multicore:
            // no updates, only need to hold store information
            // will get tag info when get to head of Q

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

    // multicore:
        // don't different types for load and store, use general bus req interface

    // simple bus req
    typedef struct packed {
        logic valid;
        dcache_block_addr_t block_addr;
    } dcache_simple_bus_req_t;

    // upgradable bus req
    typedef struct packed {
        logic valid;
        dcache_block_addr_t block_addr;
        logic upgrading;
        logic [DCACHE_LOG_NUM_WAYS-1:0] upgrading_way;
            // upgrading: 
                // simple: always replace upgrading way, regardless of if still there
                    // may get non-LRU replacement in high set contention
                        // whatever, more important to prevent need to check tags
    } dcache_upgradable_bus_req_t;

    // bus req
    typedef struct packed {

        logic valid;
        dcache_block_addr_t block_addr;

        logic exclusive;
            // load: 0
            // store: 1

        logic upgrading;
        logic [DCACHE_LOG_NUM_WAYS-1:0] upgrading_way;
            // upgrading: 
                // simple: always replace upgrading way, regardless of if still there
                    // may get non-LRU replacement in high set contention
                        // whatever, more important to prevent need to check tags
    } dcache_bus_req_t;

    // load miss reg
    dcache_simple_bus_req_t new_load_miss_reg;
    dcache_simple_bus_req_t next_new_load_miss_reg;

    // store miss reg
    dcache_upgradable_bus_req_t new_store_miss_reg;
    dcache_upgradable_bus_req_t next_new_store_miss_reg;

    // backlog Q bus read req
    dcache_bus_req_t [DCACHE_BUS_READ_REQ_BACKLOG_Q_DEPTH-1:0] backlog_Q_bus_read_req_by_entry;
    dcache_bus_req_t [DCACHE_BUS_READ_REQ_BACKLOG_Q_DEPTH-1:0] next_backlog_Q_bus_read_req_by_entry;

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

    // fill block addr broadcast
        // should be rare case where need to piggyback else incorrect
            // maybe load then store to same block, one has store val other doesn't?
            // also load then load to same block, should only have one copy in cache
            // can get ugly for snooping have have more than one copy of block in cache
        // when MSHR is serviced, broadcast block addr and way to other MSHR's
            // matching block addr piggybacking MSHR's set their piggybacking bits and if store it sets way
            // when piggybacking MSHR's are serviced:
                // load: just send resp to core, don't fill block
                // store: write only this storing word to block, don't fill whole block
    logic piggyback_bus_valid;
    dcache_block_addr_t piggyback_bus_block_addr;
    logic [DCACHE_LOG_NUM_WAYS-1:0] piggyback_bus_way;
    // multicore:
        // need state to see if store can piggyback
    MOESI_state_t piggyback_bus_new_state;

    // upgrading store way
    logic store_miss_upgrading;
    logic [DCACHE_LOG_NUM_WAYS-1:0] store_miss_upgrading_way;

    // snoop access allowed
        // prevent same-cycle write and snoop hit which can new write value lost
    logic snoop_access_allowed;

    // snoop tag search results
    logic snoop_search_VTM_success;
    logic [DCACHE_LOG_NUM_WAYS-1:0] snoop_search_VTM_way;
    logic snoop_search_VTM_state;

    // snoop req Q:
    typedef struct packed {
        logic valid;
        dcache_block_addr_t block_addr;
        logic exclusive;
        MOESI_state_t curr_state;
    } snoop_req_Q_entry_t;

    snoop_req_Q_entry_t [DCACHE_SNOOP_REQ_Q_DEPTH-1:0] snoop_req_Q;
    snoop_req_Q_entry_t [DCACHE_SNOOP_REQ_Q_DEPTH-1:0] next_snoop_req_Q;

    // snoop req Q ptr's:
    typedef struct packed {
        logic msb;
        logic [DCACHE_LOG_SNOOP_REQ_Q_DEPTH-1:0] index;
    } snoop_req_Q_ptr_t;

    snoop_req_Q_ptr_t snoop_req_Q_head_ptr;
    snoop_req_Q_ptr_t next_snoop_req_Q_head_ptr;
    snoop_req_Q_ptr_t snoop_req_Q_tail_ptr;
    snoop_req_Q_ptr_t next_snoop_req_Q_tail_ptr;

    // reg'd snoop resp
    logic next_snoop_resp_valid;
    block_addr_t next_snoop_resp_block_addr;
    word_t [1:0] next_snoop_resp_data;
    logic next_snoop_resp_present;
    logic next_snoop_resp_need_block;
    MOESI_state_t next_snoop_resp_new_state;

    // reg'd dcache inv and evict
    logic next_dcache_inv_valid;
    block_addr_t next_dcache_inv_block_addr;
    logic next_dcache_evict_valid;
    block_addr_t next_dcache_evict_block_addr;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            dcache_tag_frame_by_way_by_set <= '0;
            dcache_data_frame_by_way_by_set <= '0;
            snoop_tag_frame_by_way_by_set <= '0;

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

            snoop_req_Q <= '0;
            snoop_req_Q_head_ptr <= '0;
            snoop_req_Q_tail_ptr <= '0;

            snoop_resp_valid <= 1'b0;
            snoop_resp_block_addr <= 13'h0;
            snoop_resp_data <= {32'h0, 32'h0};
            snoop_resp_present <= 1'b0;
            snoop_resp_need_block <= 1'b0;
            snoop_resp_new_state <= MOESI_I;

            dcache_inv_valid <= 1'b0;
            dcache_inv_block_addr <= 13'h0;
            dcache_evict_valid <= 1'b0;
            dcache_evict_block_addr <= 13'h0;
        end
        else begin
            dcache_tag_frame_by_way_by_set <= next_dcache_tag_frame_by_way_by_set;
            dcache_data_frame_by_way_by_set <= next_dcache_data_frame_by_way_by_set;
            snoop_tag_frame_by_way_by_set <= next_snoop_tag_frame_by_way_by_set;

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

            snoop_req_Q <= next_snoop_req_Q;
            snoop_req_Q_head_ptr <= next_snoop_req_Q_head_ptr;
            snoop_req_Q_tail_ptr <= next_snoop_req_Q_tail_ptr;

            snoop_resp_valid <= next_snoop_resp_valid;
            snoop_resp_block_addr <= next_snoop_resp_block_addr;
            snoop_resp_data <= next_snoop_resp_data;
            snoop_resp_present <= next_snoop_resp_present;
            snoop_resp_need_block <= next_snoop_resp_need_block;
            snoop_resp_new_state <= next_snoop_resp_new_state;

            dcache_inv_valid <= next_dcache_inv_valid;
            dcache_inv_block_addr <= next_dcache_inv_block_addr;
            dcache_evict_valid <= next_dcache_evict_valid;
            dcache_evict_block_addr <= next_dcache_evict_block_addr;
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

        // // write req interface: 
        //     // block if store MSHR Q (going to be) full
        // dcache_write_req_blocked = 
        //     next_store_MSHR_Q_head_ptr.msb != next_store_MSHR_Q_tail_ptr.msb
        //     &
        //     next_store_MSHR_Q_head_ptr.index == next_store_MSHR_Q_tail_ptr.index
        // ;
            // need to set this at end of always_comb

        // read kill interface x2:
        
        // invalidation interface:
            // doubled the interface at LSQ for eviction invalidations and snoop invalidations
        next_dcache_inv_valid = 1'b0;
        next_dcache_inv_block_addr = 13'h0;
        next_dcache_evict_valid = 1'b0;
        next_dcache_evict_block_addr = 13'h0;

        // halt interface:

        ///////////////////////////////
        // bus controller interface:

        // dbus req:
            // invalid from load miss reg
        dbus_req_valid = 1'b0;
        dbus_req_block_addr = new_load_miss_reg.block_addr;
        dbus_req_exclusive = 1'b0;
        dbus_req_curr_state = MOESI_I;

        // dbus resp:

        // snoop req:

        // snoop resp:
            // invalid based on snoop req Q head for way 0
        next_snoop_resp_valid = 1'b0;
        next_snoop_resp_block_addr = snoop_req_Q[snoop_req_Q_head_ptr.index].block_addr;
        next_snoop_resp_data = {32'h0, 32'h0};
        next_snoop_resp_present = 1'b0;
        next_snoop_resp_need_block = 1'b0;
        next_snoop_resp_new_state = MOESI_I;

        ///////////////////////////////
        // mem controller interface: 

        // dmem write req:
            // invalid store MSHR req
                // can't default to load MSHR req as need CAM search info
        dmem_write_req_valid = 1'b0;
        dmem_write_req_block_addr = 13'h0;
        dmem_write_req_data = {32'h0, 32'h0};

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

        // dcache tag array
        next_dcache_tag_frame_by_way_by_set = dcache_tag_frame_by_way_by_set;

        // dcache data array
        next_dcache_data_frame_by_way_by_set = dcache_data_frame_by_way_by_set;

        // snoop tag array
        next_snoop_tag_frame_by_way_by_set = snoop_tag_frame_by_way_by_set;

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
        next_new_load_miss_reg.block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};

        // store miss reg
            // invalid from dcache write req interface, not upgrading
            // NO: want invalid from store MSHR Q head
        next_new_store_miss_reg.valid = 1'b0;
        // next_new_store_miss_reg.block_addr = {store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.tag, store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index};
            // idk why this split the struct, should just be able to combine tag and index
                // maybe back when needed offset?
        next_new_store_miss_reg.block_addr = store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr;
        next_new_store_miss_reg.upgrading = 1'b0;
        next_new_store_miss_reg.upgrading_way = 0;

        // backlog Q bus read req
        next_backlog_Q_bus_read_req_by_entry = backlog_Q_bus_read_req_by_entry;

        // backlog Q bus read req pointers
        next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr;
        next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr;

        // load hit return reg
            // inv from dcache read req, way 0
        next_load_hit_return.valid = 1'b0;
        next_load_hit_return.LQ_index = dcache_read_req_LQ_index;
        next_load_hit_return.data = 32'h0;

        // load miss return Q
        next_load_miss_return_Q = load_miss_return_Q;

        // load miss return ptr's
        next_load_miss_return_Q_head_ptr = load_miss_return_Q_head_ptr;
        next_load_miss_return_Q_tail_ptr = load_miss_return_Q_tail_ptr;

        // hit counter for perf
        next_hit_counter = hit_counter;

        // snoop resp dcache access allowed
            // atomic edits to tag array, don't miss new store value
            // set here, can be cleared throughout d$ logic
            // check at end of d$ logic to see if can perform snoop resp
        snoop_access_allowed = 1'b1;

        // snoop req Q
        next_snoop_req_Q = snoop_req_Q;
        
        // snoop req Q ptr's
        next_snoop_req_Q_head_ptr = snoop_req_Q_head_ptr;
        next_snoop_req_Q_tail_ptr = snoop_req_Q_tail_ptr;

        // //////////////////////////
        // // load hit path logic: //
        // //////////////////////////

        // // no load hit
        // load_hit_this_cycle = 1'b0;

        // // check have dcache read req
        // if (dcache_read_req_valid) begin

        //     // iterate over ways
        //     for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

        //         // check VTM
        //         if (
        //             dcache_frame_by_way_by_set[i][dcache_read_req_addr_structed.index].valid
        //             &
        //             (
        //                 dcache_frame_by_way_by_set[i][dcache_read_req_addr_structed.index].tag
        //                 ==
        //                 dcache_read_req_addr_structed.tag
        //             )
        //         ) begin

        //             // have hit
        //             load_hit_this_cycle = 1'b1;

        //             // set hit return
        //             next_load_hit_return.valid = 1'b1;
        //             next_load_hit_return.LQ_index = dcache_read_req_LQ_index;
        //             next_load_hit_return.data = 
        //                 dcache_frame_by_way_by_set
        //                 [i]
        //                 [dcache_read_req_addr_structed.index]
        //                 .block
        //                 [dcache_read_req_addr_structed.block_offset]
        //             ;

        //             // // set LRU opposite this way
        //             //     // this part assumes 2-way assoc, otherwise "LRU" is just not the last way touched
        //             //     // NMRU -> Not Most Recently Used
        //             // next_dcache_set_LRU[dcache_read_req_addr_structed.index] = ~i;
        //             // set LRU next way
        //                 // still NMRU but at least don't just toggle between opposite ways
        //             next_dcache_set_LRU[dcache_read_req_addr_structed.index] = i + 1;

        //             // add hit for perf counter
        //                 // do next in case load and store both hit
        //             next_hit_counter = next_hit_counter + 1;
        //             $display("dcache: hit #%d", next_hit_counter);
        //         end
        //     end

        //     // check no hit after iter through ways
        //     if (~load_hit_this_cycle) begin

        //         // set load miss reg
        //         next_new_load_miss_reg.valid = 1'b1;
        //         next_new_load_miss_reg.LQ_index = dcache_read_req_LQ_index;
        //         next_new_load_miss_reg.block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};
        //         next_new_load_miss_reg.block_offset = dcache_read_req_addr_structed.block_offset;

        //         // allocate load MSHR @ LQ_index
        //         next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].valid = 1'b1;
        //         next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].fulfilled = 1'b0;
        //         // next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b0;
        //         next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};
        //         next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].block_offset = dcache_read_req_addr_structed.block_offset;

        //         // special case: missing right when would be filling
        //             // set as piggybacking if current piggyback broadcast matches block addr
        //         if (
        //             piggyback_bus_block_addr
        //             ==
        //             {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index}
        //         ) begin
        //             next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b1;
        //         end

        //         // otherwise, not piggybacking
        //         else begin
        //             next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b0;
        //         end
        //     end
        // end
            // need to put at end now because of piggybacking

        ///////////////////////////
        // store hit path logic: //
        ///////////////////////////
            // actual store hit should happen when store gets to front of store MSHR Q
                // this way previous loads or stores that could have given hit before this
                // store is serviced can finish, then official miss check can happen
                // this specific ordering not important for loads since have separate MSHR's that can
                // share return data from mem

        // // no store hit
        // store_hit_this_cycle = 1'b0;

        // // check have dcache read req
        // if (dcache_write_req_valid) begin

        //     // iterate over ways
        //     for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

        //         // check VTM
        //         if (
        //             dcache_frame_by_way_by_set[i][dcache_write_req_addr_structed.index].valid
        //             &
        //             (
        //                 dcache_frame_by_way_by_set[i][dcache_write_req_addr_structed.index].tag
        //                 ==
        //                 dcache_write_req_addr_structed.tag
        //             )
        //         ) begin

        //             // have hit
        //             store_hit_this_cycle = 1'b1;

        //             // perform write in dcache frame
        //             next_dcache_frame_by_way_by_set
        //             [i]
        //             [dcache_write_req_addr_structed.index]
        //             .block
        //             [dcache_write_req_addr_structed.block_offset]
        //                 = dcache_write_req_data;

        //             // mark dcache frame dirty
        //             next_dcache_frame_by_way_by_set
        //             [i]
        //             [dcache_write_req_addr_structed.index]
        //             .dirty
        //                 = 1'b1;

        //             // // set LRU opposite this way
        //             //     // this part assumes 2-way assoc, otherwise "LRU" is just not the last way touched
        //             //     // NMRU -> Not Most Recently Used
        //             // next_dcache_set_LRU[dcache_write_req_addr_structed.index] = ~i;
        //             // set LRU next way
        //                 // still NMRU but at least don't just toggle between opposite ways
        //             next_dcache_set_LRU[dcache_write_req_addr_structed.index] = i + 1;

        //             // add hit for perf counter
        //                 // do next in case load and store both hit
        //             next_hit_counter = next_hit_counter + 1;
        //             $display("dcache: hit #%d", next_hit_counter);
        //         end
        //     end

        //     // check no hit after iter through ways
        //     if (~store_hit_this_cycle) begin

        //         // set store miss reg
        //         next_new_store_miss_reg.valid = 1'b1;
        //         next_new_store_miss_reg.block_addr = {dcache_write_req_addr_structed.tag, dcache_write_req_addr_structed.index};
        //         next_new_store_miss_reg.block_offset = dcache_write_req_addr_structed.block_offset;
        //         next_new_store_miss_reg.store_word = dcache_write_req_data;
        //     end
        // end

        //////////////////////////////
        // load miss process logic: //
        //////////////////////////////

        // // check have load miss
        // if (new_load_miss_reg.valid) begin

        //     // allocate load MSHR @ LQ_index
        //     next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].valid = 1'b1;
        //     next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].fulfilled = 1'b0;
        //     next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b0;
        //     next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};
        //     next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].block_offset = dcache_read_req_addr_structed.block_offset;

        //     // will check competing bus read req's later
        // end
            // can immediately alloc load miss
                // prevents 1 cycle in-between where don't have MSHR to scoop up bus resp and already missed

        ///////////////////////////////
        // store miss process logic: //
        ///////////////////////////////
            // processing now part of deQ

        // // check have store miss
        // if (new_store_miss_reg.valid) begin

        //     // enQ to store MSHR Q
        //         // can directly set to new_store_miss_reg values
        //     next_store_MSHR_Q[store_MSHR_Q_tail_ptr.index] = new_store_miss_reg;

        //     // increment store MSHR Q tail
        //     next_store_MSHR_Q_tail_ptr = store_MSHR_Q_tail_ptr + dcache_store_MSHR_Q_ptr_t'(1);

        //     // will check competing bus read req's later
        // end

        //////////////////////////////
        // store req process logic: //
        //////////////////////////////
            // directly enQ dcache write req into store MSHR Q
            // multicore:
                // no updates, only need to hold store information
                // will get tag info when get to head of Q

        // check for dcache write req
        if (dcache_write_req_valid) begin

            // enQ into store MSHR Q
            next_store_MSHR_Q[store_MSHR_Q_tail_ptr.index].valid = 1'b1;
            next_store_MSHR_Q[store_MSHR_Q_tail_ptr.index].block_addr = {
                dcache_write_req_addr_structed.tag,
                dcache_write_req_addr_structed.index
            };
            next_store_MSHR_Q[store_MSHR_Q_tail_ptr.index].block_offset = 
                dcache_write_req_addr_structed.block_offset
            ;
            next_store_MSHR_Q[store_MSHR_Q_tail_ptr.index].store_word =
                dcache_write_req_data
            ;

            // increment store MSHR Q tail
            next_store_MSHR_Q_tail_ptr = store_MSHR_Q_tail_ptr + 1;
        end

        ///////////////////////////////
        // bus read req arbitration: //
        ///////////////////////////////
            // case combos on {head of backlog, new load miss, new store miss}
            // 2^3 = 8 cases
            // multicore:
                // also set dmem read req exclusive and curr_state fields
                    // these can depend on if upgrading
                    // for store, upgrade means should read until as late as possible
                        // to make sure no tag update since this time
            // multicore:
                // no snoops while actively doing tag read for store
        
        case ({
            backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].valid,
            new_load_miss_reg.valid,
            new_store_miss_reg.valid
        })

            3'b111:
            begin
                // service backlog
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .block_addr
                ;
                dbus_req_exclusive = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .exclusive
                ;
                // if upgrading, do tag array read for state
                if (
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .upgrading
                ) begin
                    // accessing frames
                    snoop_access_allowed = 1'b0;

                    // check no block addr match
                    if (
                        snoop_tag_frame_by_way_by_set
                        // select way
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .upgrading_way
                        ]
                        // select set
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                        !=
                        backlog_Q_bus_read_req_by_entry
                        [backlog_Q_bus_read_req_head_ptr.index]
                        .block_addr
                        .tag
                    ) begin
                        // guaranteed state = I
                        dbus_req_curr_state = MOESI_I;
                    end
                    // otherwise, follow state in tag array
                    else begin
                        dbus_req_curr_state =
                            snoop_tag_frame_by_way_by_set
                            // select way
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                                .upgrading_way
                            ]
                            // select set
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                            ]
                            .state
                        ;
                    end
                end
                // otherwise, guaranteed state = I
                else begin
                    dbus_req_curr_state = MOESI_I;
                end

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_head_ptr.index]
                .valid = 
                    1'b0
                ;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;

                // enQ load miss @ backlog tail
                    // guaranteed not exclusive
                    // guaranteed not upgrading
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .valid = 
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .block_addr =
                    new_load_miss_reg.block_addr
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .exclusive =
                    1'b0
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading = 
                    1'b0
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading_way = 
                    0
                ;

                // enQ store miss @ backlog tail + 1
                    // guaranteed exclusive
                    // follow store miss upgradding
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index + DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH'(1)]
                .valid = 
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index + DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH'(1)]
                .block_addr =
                    new_store_miss_reg.block_addr
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index + DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH'(1)]
                .exclusive =
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index + DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH'(1)]
                .upgrading =
                    new_store_miss_reg.upgrading
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index + DCACHE_LOG_BUS_READ_REQ_BACKLOG_Q_DEPTH'(1)]
                .upgrading_way =
                    new_store_miss_reg.upgrading_way
                ;

                // increment backlog tail + 2
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;

                // check if tail surpasses head
                    // tail msb != head msb
                    // next_tail index == next_head index + 1 -> tail index + 2 == head index + 2
                    // -> tail index == head index
                    // OR 
                    // next_tail index == next_head index + 2 -> tail index + 2 == head index + 3
                    // -> tail index == head index + 1
                if (
                    backlog_Q_bus_read_req_tail_ptr.msb != backlog_Q_bus_read_req_head_ptr.msb
                    &
                    (
                        backlog_Q_bus_read_req_tail_ptr.index == backlog_Q_bus_read_req_head_ptr.index
                        |
                        backlog_Q_bus_read_req_tail_ptr.index == backlog_Q_bus_read_req_head_ptr.index + 1
                    )
                ) begin
                    $display("dcache: ERROR: backlog Q tail surpasses head: 3'b111");
                    $display("\t@: %0t",$realtime);
                    next_DUT_error = 1'b1;
                end
            end

            3'b110:
            begin
                // service backlog
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .block_addr
                ;
                dbus_req_exclusive = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .exclusive
                ;
                // if upgrading, do tag array read for state
                if (
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .upgrading
                ) begin
                    // accessing frames
                    snoop_access_allowed = 1'b0;
                    
                    // check no block addr match
                    if (
                        snoop_tag_frame_by_way_by_set
                        // select way
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .upgrading_way
                        ]
                        // select set
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                        !=
                        backlog_Q_bus_read_req_by_entry
                        [backlog_Q_bus_read_req_head_ptr.index]
                        .block_addr
                        .tag
                    ) begin
                        // guaranteed state = I
                        dbus_req_curr_state = MOESI_I;
                    end
                    // otherwise, follow state in tag array
                    else begin
                        dbus_req_curr_state =
                            snoop_tag_frame_by_way_by_set
                            // select way
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                                .upgrading_way
                            ]
                            // select set
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                            ]
                            .state
                        ;
                    end
                end
                // otherwise, guaranteed state = I
                else begin
                    dbus_req_curr_state = MOESI_I;
                end

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_head_ptr.index]
                .valid = 
                    1'b0
                ;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;

                // enQ load miss @ backlog tail
                    // guaranteed not exclusive
                    // guaranteed not upgrading
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .valid = 
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .block_addr =
                    new_load_miss_reg.block_addr
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .exclusive =
                    1'b0
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading = 
                    1'b0
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading_way = 
                    0
                ;

                // increment backlog tail + 1
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;
            end

            3'b101:
            begin
                // service backlog
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .block_addr
                ;
                dbus_req_exclusive = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .exclusive
                ;
                // if upgrading, do tag array read for state
                if (
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .upgrading
                ) begin
                    // accessing frames
                    snoop_access_allowed = 1'b0;
                    
                    // check no block addr match
                    if (
                        snoop_tag_frame_by_way_by_set
                        // select way
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .upgrading_way
                        ]
                        // select set
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                        !=
                        backlog_Q_bus_read_req_by_entry
                        [backlog_Q_bus_read_req_head_ptr.index]
                        .block_addr
                        .tag
                    ) begin
                        // guaranteed state = I
                        dbus_req_curr_state = MOESI_I;
                    end
                    // otherwise, follow state in tag array
                    else begin
                        dbus_req_curr_state =
                            snoop_tag_frame_by_way_by_set
                            // select way
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                                .upgrading_way
                            ]
                            // select set
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                            ]
                            .state
                        ;
                    end
                end
                // otherwise, guaranteed state = I
                else begin
                    dbus_req_curr_state = MOESI_I;
                end

                // enQ store miss @ backlog tail
                    // guaranteed exclusive
                    // follow store miss upgradding
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .valid = 
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .block_addr =
                    new_store_miss_reg.block_addr
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .exclusive =
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading =
                    new_store_miss_reg.upgrading
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading_way =
                    new_store_miss_reg.upgrading_way
                ;

                // increment backlog tail + 1
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;
            end
            
            3'b100:
            begin
                // service backlog
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .block_addr
                ;
                dbus_req_exclusive = 
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .exclusive
                ;
                // if upgrading, do tag array read for state
                if (
                    backlog_Q_bus_read_req_by_entry
                    [backlog_Q_bus_read_req_head_ptr.index]
                    .upgrading
                ) begin
                    // accessing frames
                    snoop_access_allowed = 1'b0;
                    
                    // check no block addr match
                    if (
                        snoop_tag_frame_by_way_by_set
                        // select way
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .upgrading_way
                        ]
                        // select set
                        [
                            backlog_Q_bus_read_req_by_entry
                            [backlog_Q_bus_read_req_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                        !=
                        backlog_Q_bus_read_req_by_entry
                        [backlog_Q_bus_read_req_head_ptr.index]
                        .block_addr
                        .tag
                    ) begin
                        // guaranteed state = I
                        dbus_req_curr_state = MOESI_I;
                    end
                    // otherwise, follow state in tag array
                    else begin
                        dbus_req_curr_state =
                            snoop_tag_frame_by_way_by_set
                            // select way
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                                .upgrading_way
                            ]
                            // select set
                            [
                                backlog_Q_bus_read_req_by_entry
                                [backlog_Q_bus_read_req_head_ptr.index]
                            ]
                            .state
                        ;
                    end
                end
                // otherwise, guaranteed state = I
                else begin
                    dbus_req_curr_state = MOESI_I;
                end

                // deQ backlog
                    // invalidate head
                    // increment head pointer
                next_backlog_Q_bus_read_req_by_entry[backlog_Q_bus_read_req_head_ptr.index].valid = 1'b0;
                next_backlog_Q_bus_read_req_head_ptr = backlog_Q_bus_read_req_head_ptr + 1;
            end

            3'b011:
            begin
                // service load miss
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = new_load_miss_reg.block_addr;
                dbus_req_exclusive = 1'b0;
                dbus_req_curr_state = MOESI_I;

                // enQ store miss @ backlog tail
                    // guaranteed exclusive
                    // follow store miss upgradding
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .valid = 
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .block_addr =
                    new_store_miss_reg.block_addr
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .exclusive =
                    1'b1
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading =
                    new_store_miss_reg.upgrading
                ;
                next_backlog_Q_bus_read_req_by_entry
                [backlog_Q_bus_read_req_tail_ptr.index]
                .upgrading_way =
                    new_store_miss_reg.upgrading_way
                ;

                // increment backlog tail + 1
                next_backlog_Q_bus_read_req_tail_ptr = backlog_Q_bus_read_req_tail_ptr + 1;
            end

            3'b010:
            begin
                // service load miss
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = new_load_miss_reg.block_addr;
                dbus_req_exclusive = 1'b0;
                dbus_req_curr_state = MOESI_I;
            end

            3'b001:
            begin
                // service store miss
                dbus_req_valid = 1'b1;
                dbus_req_block_addr = new_store_miss_reg.block_addr;
                dbus_req_exclusive = 1'b1;
                // if upgrading, do tag array read for state
                if (new_store_miss_reg.upgrading) begin
                    // accessing frames
                    snoop_access_allowed = 1'b0;
                    // check no block addr match
                    if (
                        snoop_tag_frame_by_way_by_set
                        // select way
                        [
                            new_store_miss_reg.upgrading_way
                        ]
                        // select set
                        [
                            new_store_miss_reg.block_addr.index
                        ]
                        .tag
                        !=
                        new_store_miss_reg.block_addr.tag
                    ) begin
                        // guaranteed state = I
                        dbus_req_curr_state = MOESI_I;
                    end
                    // otherwise, follow state in tag array
                    else begin
                        dbus_req_curr_state =
                            snoop_tag_frame_by_way_by_set
                            // select way
                            [
                                new_store_miss_reg.upgrading_way
                            ]
                            // select set
                            [
                                new_store_miss_reg.block_addr.index
                            ]
                            .state
                        ;
                    end
                end
                // otherwise, guaranteed state = I
                else begin
                    dbus_req_curr_state = MOESI_I;
                end
            end

            default:
            begin
                // no service
            end

        endcase

        // ///////////////////////////
        // // load MSHR kill logic: //
        // ///////////////////////////
        //     // multicore: no change
        
        // // kill bus 0
        // if (dcache_read_kill_0_valid) begin

        //     // invalidate MSHR
        //         // don't need to check anything else?
        //     next_load_MSHR_by_LQ_index[dcache_read_kill_0_LQ_index].valid = 1'b0;
        // end

        // // kill bus 1
        // if (dcache_read_kill_1_valid) begin

        //     // invalidate MSHR
        //         // don't need to check anything else?
        //     next_load_MSHR_by_LQ_index[dcache_read_kill_1_LQ_index].valid = 1'b0;
        // end

            // this is highest priority, can have same-cycle load MSHR alloc and read kill

        ///////////////////////
        // store MSHR logic: //
        ///////////////////////
            // now also does store hit logic
            // multicore: also check for upgrading miss
        
        // reset store hit
        store_hit_this_cycle = 1'b0;

        // reset store miss upgrading
        store_miss_upgrading = 1'b0;
        store_miss_upgrading_way = 0;

        // check deQ
            // have store MSHR Q entry valid and MSHR invalid
        if (
            store_MSHR_Q[store_MSHR_Q_head_ptr.index].valid
            &
            ~store_MSHR.valid
        ) begin

            // accessing frames
            snoop_access_allowed = 1'b0;

            // try to hit in cache:

            // iterate over ways
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check hit
                    // exclusive state: E or M
                        // valid and exclusive
                    // tag match
                if (
                    (
                        dcache_tag_frame_by_way_by_set
                        [i]
                        [
                            store_MSHR_Q
                            [store_MSHR_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .state
                        .valid
                        &
                        dcache_tag_frame_by_way_by_set
                        [i]
                        [
                            store_MSHR_Q
                            [store_MSHR_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .state
                        .exclusive
                    )
                    &
                    (
                        dcache_tag_frame_by_way_by_set
                        [i]
                        [
                            store_MSHR_Q
                            [store_MSHR_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                        ==
                        store_MSHR_Q
                        [store_MSHR_Q_head_ptr.index]
                        .block_addr
                        .tag
                    )
                ) begin

                    // have hit
                    store_hit_this_cycle = 1'b1;

                    // perform write in dcache frame
                    next_dcache_data_frame_by_way_by_set
                    [i]
                    [store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index]
                    .block
                    [store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_offset]
                        = store_MSHR_Q[store_MSHR_Q_head_ptr.index].store_word;

                    // state transition
                        // make dirty: M->M or E->M
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [i]
                    [store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index]
                    .state
                    .dirty
                        = 1'b1;
                    next_snoop_tag_frame_by_way_by_set
                    [i]
                    [store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index]
                    .state
                    .dirty
                        = 1'b1;

                    // // set LRU opposite this way
                    //     // this part assumes 2-way assoc, otherwise "LRU" is just not the last way touched
                    //     // NMRU -> Not Most Recently Used
                    // next_dcache_set_LRU[store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index] = ~i;
                    // set LRU next way
                        // still NMRU but at least don't just toggle between opposite ways
                    next_dcache_set_LRU[store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index] = i + 1;

                    // add hit for perf counter
                        // do next in case load and store both hit
                    next_hit_counter = next_hit_counter + 1;
                    $display("dcache: hit #%d", next_hit_counter);
                end

                // otherwise, check upgrade miss
                    // not exclusive state: S or O
                        // valid and ~exclusive
                    // tag match
                else if (
                    (
                        dcache_tag_frame_by_way_by_set
                        [i]
                        [
                            store_MSHR_Q
                            [store_MSHR_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .state
                        .valid
                        &
                        ~dcache_tag_frame_by_way_by_set
                        [i]
                        [
                            store_MSHR_Q
                            [store_MSHR_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .state
                        .exclusive
                    )
                    &
                    (
                        dcache_tag_frame_by_way_by_set
                        [i]
                        [
                            store_MSHR_Q
                            [store_MSHR_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                        ==
                        store_MSHR_Q
                        [store_MSHR_Q_head_ptr.index]
                        .block_addr
                        .tag
                    )
                ) begin

                    // have upgrade miss
                    store_miss_upgrading = 1'b1;
                    store_miss_upgrading_way = i;
                end
            end

            // check no hit after iter through ways
            if (~store_hit_this_cycle) begin

                // set store miss reg
                next_new_store_miss_reg.valid = 1'b1;
                next_new_store_miss_reg.block_addr = {store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.tag, store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index};
                next_new_store_miss_reg.upgrading = store_miss_upgrading;
                next_new_store_miss_reg.upgrading_way = store_miss_upgrading_way;
                
                // fill in MSHR
                next_store_MSHR.valid = 1'b1;
                next_store_MSHR.fulfilled = 1'b0;
                next_store_MSHR.piggybacking = 1'b0;
                next_store_MSHR.piggybacking_way = 0;
                next_store_MSHR.block_addr = store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr;
                next_store_MSHR.block_offset = store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_offset;
                next_store_MSHR.store_word = store_MSHR_Q[store_MSHR_Q_head_ptr.index].store_word;
                next_store_MSHR.read_block = 
                    dcache_data_frame_by_way_by_set
                    // select way
                    [store_miss_upgrading_way]
                    // select set
                    [store_MSHR_Q[store_MSHR_Q_head_ptr.index].block_addr.index]
                    .block
                ;
                next_store_MSHR.upgrading = store_miss_upgrading;
                next_store_MSHR.upgrading_way = store_miss_upgrading_way;
            end

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
        // dbus resp process logic: //
        //////////////////////////////
            // block addr broadcasted
            // service all relevant MSHR's

        // check have dmem read resp
        if (dbus_resp_valid) begin

            // check all load MSHR's
            for (int i = 0; i < LQ_DEPTH; i++) begin

                // check block addr match
                    // can safely bring in any resp if block addr matches
                if (
                    load_MSHR_by_LQ_index[i].block_addr
                    ==
                    dbus_resp_block_addr
                ) begin

                    // mark MSHR fulfilled
                    next_load_MSHR_by_LQ_index[i].fulfilled = 1'b1;
                    
                    // fill in read block
                    next_load_MSHR_by_LQ_index[i].read_block = dbus_resp_data;

                    // fill in state
                    next_load_MSHR_by_LQ_index[i].new_state = dbus_resp_new_state;
                end
            end

            // check store MSHR
                // can only bring in resp if block is M and block addr matches
                    // piggybacking also allows E
                    // here, we want the exclusive request specifically to come through
                    // NVM: can also take E state
            if (
                (
                    // dbus_resp_new_state
                    // ==
                    // MOESI_M
                    dbus_resp_new_state
                    .exclusive
                )
                &
                (
                    store_MSHR.block_addr
                    ==
                    dbus_resp_block_addr
                )
            ) begin

                // mark MSHR fulfilled
                next_store_MSHR.fulfilled = 1'b1;

                // officially fill in store word on block
                next_store_MSHR.read_block[store_MSHR.block_offset] = store_MSHR.store_word;

                // if need block, fill in with resp block
                if (dbus_resp_need_block) begin
                    next_store_MSHR.read_block[~store_MSHR.block_offset] = 
                        dbus_resp_data[~store_MSHR.block_offset]
                    ;
                end

                // otherwise, keep this local block
                else begin
                    next_store_MSHR.read_block[~store_MSHR.block_offset] = 
                        store_MSHR.read_block[~store_MSHR.block_offset]
                    ;
                end

                // // fill in state
                // next_store_MSHR.new_state = dbus_resp_new_state;
                    // guaranteed new state = M
            end
        end

        ///////////////////////////
        // dbus resp fill logic: //
        ///////////////////////////
            // choose MSHR to fill cache
            // if load, return value
            // deal with evictions

        // init piggyback bus broadcast
        piggyback_bus_valid = 1'b0;
        piggyback_bus_block_addr = 13'h0;
        piggyback_bus_way = 0;
        piggyback_bus_new_state = MOESI_I;

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

        // reset empty way info
        found_empty_way = 1'b0;
        empty_way = 0;

        // safe behavior: can't service MSHR if slowing down
        if (dmem_write_req_slow_down) begin

            // do nothing
        end

        // otherwise, use load MSHR if found
        else if (found_load_MSHR_fulfilled) begin
            
            // accessing frames
            snoop_access_allowed = 1'b0;

            // check if need to fill block (didn't piggyback)
            if (~load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].piggybacking) begin

                // search for empty way
                for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                    // check this entry invalid
                    if (
                        dcache_tag_frame_by_way_by_set
                        // select way following CAM loop
                        [i]
                        // select set following LQ index MSHR index
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                        .state
                        ==
                        MOESI_I
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
                        // state from MSHR
                        // tag from MSHR
                        // block from MSHR
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [empty_way]
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .state
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].new_state
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [empty_way]
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .state
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].new_state
                    ;

                    next_dcache_tag_frame_by_way_by_set
                    [empty_way]
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .tag
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.tag
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [empty_way]
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .tag
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.tag
                    ;
                    
                    next_dcache_data_frame_by_way_by_set
                    [empty_way]
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .block
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].read_block
                    ;

                    // update LRU
                        // this found way + 1
                    next_dcache_set_LRU
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                        = empty_way + 1
                    ;

                    // set piggyback way
                    piggyback_bus_way = empty_way;
                ;
                end

                // otherwise, use LRU way
                else begin

                    // evict LRU @ found LQ index MSHR index if frame dirty
                        // state M or O
                    if (
                        dcache_tag_frame_by_way_by_set
                        // select way following LRU @ LQ index MSHR index
                        [
                            dcache_set_LRU
                            [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                        ] 
                        // select set following LQ index MSHR index
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                        .state
                        .dirty
                    ) begin

                        // send dmem write req
                            // valid
                            // block addr follows (tag in frame, MSHR index)
                            // data follows frame
                        dmem_write_req_valid = 1'b1;
                        dmem_write_req_block_addr = {
                            // tag in frame:
                            dcache_tag_frame_by_way_by_set
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
                            dcache_data_frame_by_way_by_set
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
                        next_dcache_evict_valid = 1'b1;
                        next_dcache_evict_block_addr = {
                            // tag in frame:
                            dcache_tag_frame_by_way_by_set
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
                        // state from MSHR
                        // tag from MSHR
                        // block from MSHR
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                    ] 
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .state
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].new_state
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                    ] 
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .state
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].new_state
                    ;

                    next_dcache_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                    ] 
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .tag
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.tag
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                    ] 
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .tag
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.tag
                    ;
                    
                    next_dcache_data_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                    ] 
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .block
                        = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].read_block
                    ;

                    // update LRU
                        // LRU + 1
                    next_dcache_set_LRU
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    =
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index] 
                        + 1
                    ;

                    // set piggyback way
                    piggyback_bus_way = 
                        dcache_set_LRU
                        [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    ;
                end
            end

            // otherwise, piggybacking, don't need to fill block
            else begin

                // set piggyback way
                piggyback_bus_way
                =
                    load_MSHR_by_LQ_index
                    [found_load_MSHR_LQ_index]
                    .piggybacking_way
                ;
            end

            // regardless of piggyback, inv MSHR and return to core

            // invalidate MSHR
            next_load_MSHR_by_LQ_index
            [found_load_MSHR_LQ_index]
            .valid
                = 1'b0
            ;

            // return data to core:

            // append load miss return Q
                // valid
                // selected found load MSHR LQ index
                // data
            next_load_miss_return_Q
            [load_miss_return_Q_tail_ptr.index]
            .valid 
                = 1'b1
            ;

            next_load_miss_return_Q
            [load_miss_return_Q_tail_ptr.index]
            .LQ_index 
                = found_load_MSHR_LQ_index
            ;

            // if piggybacking, return word from data frame @ piggybacking way
            if (load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].piggybacking) begin
                next_load_miss_return_Q
                [load_miss_return_Q_tail_ptr.index]
                .data
                = 
                    dcache_data_frame_by_way_by_set
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].piggybacking_way]
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr.index]
                    .block
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_offset]
                ;
            end
            // otherwise, return word from MSHR
            else begin
                next_load_miss_return_Q
                [load_miss_return_Q_tail_ptr.index]
                .data
                = 
                    load_MSHR_by_LQ_index[found_load_MSHR_LQ_index]
                    .read_block
                    [load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_offset]
                ;
            end

            // increment load miss return Q tail
            next_load_miss_return_Q_tail_ptr = load_miss_return_Q_tail_ptr + 1;

            // broadcast piggyback
                // way depends on path ^
            piggyback_bus_valid = 1'b1;
            piggyback_bus_block_addr = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].block_addr;
            // piggyback_bus_way = empty_way;
                // set in blocks above for empty vs. LRU vs. saved piggybacking way
            piggyback_bus_new_state = load_MSHR_by_LQ_index[found_load_MSHR_LQ_index].new_state;
        end

        // otherwise, can service store MSHR if valid and fulfilled
        else if (store_MSHR.valid & store_MSHR.fulfilled) begin
            
            // accessing frames
            snoop_access_allowed = 1'b0;

            // check if upgrading and tag match at upgrading way
                // upgrade successful
                // don't care if invalid from eviction or snoop inv
            if (
                store_MSHR.upgrading
                &
                (
                    dcache_tag_frame_by_way_by_set
                    [store_MSHR.upgrading_way]
                    [store_MSHR.block_addr.index]
                    .tag
                    ==
                    store_MSHR.block_addr.tag
                )
            ) begin

                // fill upgrading way frame
                    // state from MSHR
                        // guaranteed to be M
                    // tag from MSHR
                    // block from MSHR
                    // modify dcache tag array and snoop tag array
                next_dcache_tag_frame_by_way_by_set
                [store_MSHR.upgrading_way]
                [store_MSHR.block_addr.index]
                .state
                =
                    MOESI_M
                ;
                next_snoop_tag_frame_by_way_by_set
                [store_MSHR.upgrading_way]
                [store_MSHR.block_addr.index]
                .state
                =
                    MOESI_M
                ;

                next_dcache_tag_frame_by_way_by_set
                [store_MSHR.upgrading_way]
                [store_MSHR.block_addr.index]
                .tag
                = 
                    store_MSHR.block_addr.tag
                ;
                next_snoop_tag_frame_by_way_by_set
                [store_MSHR.upgrading_way]
                [store_MSHR.block_addr.index]
                .tag
                = 
                    store_MSHR.block_addr.tag
                ;
                
                next_dcache_data_frame_by_way_by_set
                [store_MSHR.upgrading_way]
                [store_MSHR.block_addr.index]
                .block
                    = store_MSHR.read_block
                ;

                // update LRU
                    // this found way + 1
                next_dcache_set_LRU
                [store_MSHR.block_addr.index]
                    = store_MSHR.upgrading_way + 1
                ;

                // set piggyback way
                piggyback_bus_way = store_MSHR.upgrading_way;
            end

            // otherwise, check if need to fill block (didn't piggyback)
            else if (~store_MSHR.piggybacking) begin

                // search for empty way
                for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                    // check this entry invalid
                    if (
                        dcache_tag_frame_by_way_by_set
                        // select way following CAM loop
                        [i]
                        // select set following store MSHR index
                        [store_MSHR.block_addr.index]
                        .state
                        ==
                        MOESI_I
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
                        // state from MSHR
                            // guaranteed to be M
                        // tag from MSHR
                        // block from MSHR
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [empty_way]
                    [store_MSHR.block_addr.index]
                    .state
                    =
                        MOESI_M
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [empty_way]
                    [store_MSHR.block_addr.index]
                    .state
                    =
                        MOESI_M
                    ;

                    next_dcache_tag_frame_by_way_by_set
                    [empty_way]
                    [store_MSHR.block_addr.index]
                    .tag
                        = store_MSHR.block_addr.tag
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [empty_way]
                    [store_MSHR.block_addr.index]
                    .tag
                        = store_MSHR.block_addr.tag
                    ;
                    
                    next_dcache_data_frame_by_way_by_set
                    [empty_way]
                    [store_MSHR.block_addr.index]
                    .block
                        = store_MSHR.read_block
                    ;

                    // update LRU
                        // this found way + 1
                    next_dcache_set_LRU
                    [store_MSHR.block_addr.index]
                        = empty_way + 1
                    ;

                    // set piggyback way
                    piggyback_bus_way = empty_way;
                end

                // otherwise, use LRU way
                else begin

                    // evict LRU @ found LQ index MSHR index if frame dirty
                        // state M or O
                    if (
                        dcache_tag_frame_by_way_by_set
                        // select way following LRU @ store MSHR index
                        [
                            dcache_set_LRU
                            [store_MSHR.block_addr.index]
                        ] 
                        // select set following store MSHR index
                        [store_MSHR.block_addr.index]
                        .state
                        .dirty
                    ) begin

                        // send dmem write req
                            // valid
                            // block addr follows (tag in frame, MSHR index)
                            // data follows frame
                        dmem_write_req_valid = 1'b1;
                        dmem_write_req_block_addr = {
                            // tag in frame:
                            dcache_tag_frame_by_way_by_set
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
                            dcache_data_frame_by_way_by_set
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
                        next_dcache_evict_valid = 1'b1;
                        next_dcache_evict_block_addr = {
                            // tag in frame:
                            dcache_tag_frame_by_way_by_set
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
                        // state from MSHR
                            // guaranteed to be M
                        // tag from MSHR
                        // block from MSHR
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ] 
                    [store_MSHR.block_addr.index]
                    .state
                        = MOESI_M
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ] 
                    [store_MSHR.block_addr.index]
                    .state
                        = MOESI_M
                    ;

                    next_dcache_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ] 
                    [store_MSHR.block_addr.index]
                    .tag
                        = store_MSHR.block_addr.tag
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ] 
                    [store_MSHR.block_addr.index]
                    .tag
                        = store_MSHR.block_addr.tag
                    ;
                    
                    next_dcache_data_frame_by_way_by_set
                    [
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ] 
                    [store_MSHR.block_addr.index]
                    .block
                        = store_MSHR.read_block
                    ;

                    // update LRU
                        // LRU + 1
                    next_dcache_set_LRU
                    [store_MSHR.block_addr.index]
                    =
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                        + 1
                    ;

                    // set piggyback way
                    piggyback_bus_way = 
                        dcache_set_LRU
                        [store_MSHR.block_addr.index]
                    ;
                end
            end

            // otherwise if piggybacking, write store word, mark frame dirty
                // E->M or M->M
                // modify dcache tag array and snoop tag array
            else begin

                next_dcache_tag_frame_by_way_by_set
                [store_MSHR.piggybacking_way] 
                [store_MSHR.block_addr.index]
                .state
                .dirty
                    = 1'b1
                ;
                next_snoop_tag_frame_by_way_by_set
                [store_MSHR.piggybacking_way] 
                [store_MSHR.block_addr.index]
                .state
                .dirty
                    = 1'b1
                ;

                next_dcache_data_frame_by_way_by_set
                [store_MSHR.piggybacking_way] 
                [store_MSHR.block_addr.index]
                .block
                [store_MSHR.block_offset]
                    = store_MSHR.store_word
                ;

                // set piggyback way
                piggyback_bus_way = store_MSHR.piggybacking_way;
            end

            // regardless of piggyback, inv MSHR

            // invalidate MSHR
            next_store_MSHR
            .valid
                = 1'b0;

            // broadcast piggyback
                // way depends on path ^
            piggyback_bus_valid = 1'b1;
            piggyback_bus_block_addr = store_MSHR.block_addr;
            // piggyback_bus_way = empty_way;
                // set in blocks above for upgrading vs. empty vs. LRU vs. saved piggybacking way
            piggyback_bus_new_state = MOESI_M;
                // guaranteed to be M
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

                // otherwise, check for slow down
                else if (dmem_write_req_slow_down) begin

                    // don't send dmem write req

                    // keep frame valid

                    // maintain counter
                end

                // otherwise, send dmem write req for this counter value if entry valid and dirty
                    // state M or O
                else if (
                    dcache_tag_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .state
                    .valid
                    &
                    dcache_tag_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .state
                    .dirty
                ) begin
            
                    // accessing frames
                    snoop_access_allowed = 1'b0;
                    
                    // send dmem write req
                        // valid
                        // block addr follows (tag in frame, counter index)
                        // data follows frame
                    dmem_write_req_valid = 1'b1;
                    dmem_write_req_block_addr = {
                        // tag in frame
                        dcache_tag_frame_by_way_by_set
                        [flush_counter.way]
                        [flush_counter.index]
                        .tag
                        ,
                        // counter index
                        flush_counter.index
                    };
                    dmem_write_req_data = 
                        dcache_data_frame_by_way_by_set
                        [flush_counter.way]
                        [flush_counter.index]
                        .block
                    ;

                    // invalidate frame
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .state
                        = MOESI_I
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [flush_counter.way]
                    [flush_counter.index]
                    .state
                        = MOESI_I
                    ;

                    // increment counter
                    next_flush_counter = flush_counter + 1;
                end

                // otherwise, nothing to write, move counter on
                else begin
                    // increment counter
                    next_flush_counter = flush_counter + 1;
                end
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

        //////////////////////////
        // load hit path logic: //
        //////////////////////////
            // has to be down here now since need to know piggyback bus block addr

        // no load hit
        load_hit_this_cycle = 1'b0;

        // check have dcache read req
        if (dcache_read_req_valid) begin

            // iterate over ways
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check VTM
                    // multicore:
                        // read permissions: MOES
                        // all valid states
                        // no state transitions for any MOES
                if (
                    dcache_tag_frame_by_way_by_set
                    [i]
                    [dcache_read_req_addr_structed.index]
                    .state
                    .valid
                    &
                    (
                        dcache_tag_frame_by_way_by_set[i][dcache_read_req_addr_structed.index].tag
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
                        dcache_data_frame_by_way_by_set
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

                // allocate load MSHR @ LQ_index
                    // multicore: 
                        // read block and new state are don't cares
                next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].valid = 1'b1;
                // next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].fulfilled = 1'b0;
                // next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b0;
                // next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking_way = 0;
                next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};
                next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].block_offset = dcache_read_req_addr_structed.block_offset;

                // special case: missing right when would be filling
                    // set as piggybacking if current piggyback broadcast matches block addr
                    // multicore:
                        // load can piggyback on any new state, no need to check
                if (
                    piggyback_bus_valid
                    &
                    (
                        piggyback_bus_block_addr
                        ==
                        {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index}
                    )
                ) begin

                    // if piggybacking now, automatically fulfill MSHR, don't need to send dmem read req
                    next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].fulfilled = 1'b1;
                    next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b1;
                    next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking_way = piggyback_bus_way;
                end

                // otherwise, not piggybacking
                else begin

                    // not piggybacking, need to set load miss reg
                    next_new_load_miss_reg.valid = 1'b1;
                    next_new_load_miss_reg.block_addr = {dcache_read_req_addr_structed.tag, dcache_read_req_addr_structed.index};

                    // not piggybacking, not fulfilled
                    next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].fulfilled = 1'b0;
                    next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking = 1'b0;
                    next_load_MSHR_by_LQ_index[dcache_read_req_LQ_index].piggybacking_way = 0;
                end
            end
        end

        //////////////////////////////////
        // piggyback bus compare logic: //
        //////////////////////////////////
            // multicore:
                // loads can piggyback anything
                // store can only piggyback E and M -> exclusive

        // check have piggyback broadcast
        if (piggyback_bus_valid) begin

            // check all load MSHR's
            for (int i = 0; i < LQ_DEPTH; i++) begin

                // check block addr match
                    // can safely mark piggybacking of if valid as long as block addr matches
                if (
                    load_MSHR_by_LQ_index[i].block_addr
                    ==
                    piggyback_bus_block_addr
                ) begin

                    // mark MSHR piggybacking
                    next_load_MSHR_by_LQ_index[i].piggybacking = 1'b1;

                    // set MSHR piggybacking way
                    next_load_MSHR_by_LQ_index[i].piggybacking_way = piggyback_bus_way;
                end
            end

            // check store MSHR
                // need piggyback E or M and block addr match
                    // exclusive states
                // otherwise, can mark as upgrading
            if (
                store_MSHR.block_addr
                ==
                piggyback_bus_block_addr
            ) begin

                // check piggybackable
                if (
                    piggyback_bus_new_state
                    .exclusive
                ) begin

                    // mark MSHR piggybacking
                    next_store_MSHR.piggybacking = 1'b1;

                    // set MSHR piggybacking way
                    next_store_MSHR.piggybacking_way = piggyback_bus_way;
                end

                // otherwise, can upgrade
                else begin

                    // mark MSHR upgrading
                    next_store_MSHR.upgrading = 1'b1;

                    // set MSHR upgrading way
                    next_store_MSHR.upgrading_way = piggyback_bus_way;
                end
            end
        end

        ///////////////////////////
        // d$ write req blocked: //
        ///////////////////////////

        // write req interface: 
            // block if store MSHR Q (going to be) full
        dcache_write_req_blocked = 
            next_store_MSHR_Q_head_ptr.msb != next_store_MSHR_Q_tail_ptr.msb
            &
            next_store_MSHR_Q_head_ptr.index == next_store_MSHR_Q_tail_ptr.index
        ;

        //////////////////
        // snoop req Q: //
        //////////////////
            // // snoop req:
            // input logic snoop_req_valid,
            // input block_addr_t snoop_req_block_addr,
            // input logic snoop_req_exclusive,
            // input MOESI_state_t snoop_req_curr_state,

            // // snoop resp:
            // output logic snoop_resp_valid,
            // output block_addr_t snoop_resp_block_addr,
            // output word_t [1:0] snoop_resp_data,
            // output logic snoop_resp_present,
            // output logic snoop_resp_need_block,
            // output MOESI_state_t snoop_resp_new_state,

        // snoop req enQ
        if (snoop_req_valid) begin

            // add snoop req @ snoop req Q tail
            next_snoop_req_Q[snoop_req_Q_tail_ptr.index].valid = 1'b1;
            next_snoop_req_Q[snoop_req_Q_tail_ptr.index].block_addr = snoop_req_block_addr;
            next_snoop_req_Q[snoop_req_Q_tail_ptr.index].exclusive = snoop_req_exclusive;
            next_snoop_req_Q[snoop_req_Q_tail_ptr.index].curr_state = snoop_req_curr_state;

            // increment tail
            next_snoop_req_Q_tail_ptr = snoop_req_Q_tail_ptr + 1;
        end

        // check for snoop req deQ
        snoop_search_VTM_success = 1'b0;
        snoop_search_VTM_way = 0;
        snoop_search_VTM_state = MOESI_I;
        if (snoop_req_Q[snoop_req_Q_head_ptr.index].valid) begin

            // search through tag array
            for (int i = 0; i < DCACHE_NUM_WAYS; i++) begin

                // check for VTM
                    // valid: MOES
                        // check this since could have old invalid tag wrongfully winning CAM
                    // TM: block addr match
                if (
                    snoop_tag_frame_by_way_by_set
                    [i]
                    [
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .index
                    ]
                    .state
                    .valid
                    &
                    (
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .tag
                        ==
                        snoop_tag_frame_by_way_by_set
                        [i]
                        [
                            snoop_req_Q
                            [snoop_req_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .tag
                    )
                ) begin

                    // give search success
                    snoop_search_VTM_success = 1'b1;
                    snoop_search_VTM_way = i;
                    snoop_search_VTM_state = 
                        snoop_tag_frame_by_way_by_set
                        [i]
                        [
                            snoop_req_Q
                            [snoop_req_Q_head_ptr.index]
                            .block_addr
                            .index
                        ]
                        .state
                    ;
                end
            end

            // check for search fail
            if (~snoop_search_VTM_success) begin

                // snoop exclusive:
                    // snoopee stay inv
                        // I->I
                    // snooper M
                        // O->M, S->M, I->M
                // snoop ~exclusive:
                    // snoopee stay inv
                        // I->I
                    // snooper E
                        // I->E

                // return snoop not present
                next_snoop_resp_valid = 1'b1;
                next_snoop_resp_block_addr = snoop_req_Q[snoop_req_Q_head_ptr.index].block_addr;
                next_snoop_resp_data = {32'h0, 32'h0};
                next_snoop_resp_present = 1'b0;
                // need block if old state was I
                if (snoop_req_Q[snoop_req_Q_head_ptr.index].curr_state == MOESI_I) begin
                    next_snoop_resp_need_block = 1'b1;
                end
                else begin
                    next_snoop_resp_need_block = 1'b0;
                end
                // give exclusive version of request
                    // store/exclusive req -> M
                    // load/~exclusive req -> E
                if (snoop_req_Q[snoop_req_Q_head_ptr.index].exclusive) begin
                    next_snoop_resp_new_state = MOESI_M;
                end
                else begin
                    next_snoop_resp_new_state = MOESI_E;
                end

                // deQ snoop req Q
                    // invalidate head
                    // increment head ptr
                next_snoop_req_Q[snoop_req_Q_head_ptr.index].valid = 1'b0;
                next_snoop_req_Q_head_ptr = snoop_req_Q_head_ptr + 1;
            end

            // otherwise, need access to dcache to allow atomic edits
            else if (snoop_access_allowed) begin

                // snoop exclusive:
                    // snoopee invalidated
                        // MOES->I
                    // snooper M
                        // O->M, S->M, I->M
                // snoop ~exclusive:
                    // snoopee exclusive cleared
                        // M->O, O->O, E->S, S->S
                    // snooper S
                        // I->S

                // exclusive tag array edit
                if (snoop_req_Q[snoop_req_Q_head_ptr.index].exclusive) begin

                    // MOES->I
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [snoop_search_VTM_way]
                    [
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .index
                    ]
                    .state
                        = MOESI_I
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [snoop_search_VTM_way]
                    [
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .index
                    ]
                    .state
                        = MOESI_I
                    ;

                    // send inv to core
                    next_dcache_inv_valid = 1'b1;
                    next_dcache_inv_block_addr = 
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                    ;
                end

                // otherwise, ~exclusive tag array edit
                else begin

                    // snoopee exclusive cleared
                        // M->O, O->O, E->S, S->S
                        // modify dcache tag array and snoop tag array
                    next_dcache_tag_frame_by_way_by_set
                    [snoop_search_VTM_way]
                    [
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .index
                    ]
                    .state
                    .exclusive
                        = 1'b0
                    ;
                    next_snoop_tag_frame_by_way_by_set
                    [snoop_search_VTM_way]
                    [
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .index
                    ]
                    .state
                    .exclusive
                        = 1'b0
                    ;
                end

                // return snoop present
                next_snoop_resp_valid = 1'b1;
                next_snoop_resp_block_addr = snoop_req_Q[snoop_req_Q_head_ptr.index].block_addr;
                next_snoop_resp_data = 
                    dcache_data_frame_by_way_by_set
                    [snoop_search_VTM_way]
                    [
                        snoop_req_Q
                        [snoop_req_Q_head_ptr.index]
                        .block_addr
                        .index
                    ]
                    .block
                ;
                next_snoop_resp_present = 1'b1;
                // need block if old state was I
                if (snoop_req_Q[snoop_req_Q_head_ptr.index].curr_state == MOESI_I) begin
                    next_snoop_resp_need_block = 1'b1;
                end
                else begin
                    next_snoop_resp_need_block = 1'b0;
                end
                // give non-exclusive version of request
                    // store/exclusive req -> M
                    // load/~exclusive req -> S
                if (snoop_req_Q[snoop_req_Q_head_ptr.index].exclusive) begin
                    next_snoop_resp_new_state = MOESI_M;
                end
                else begin
                    next_snoop_resp_new_state = MOESI_S;
                end

                // deQ snoop req Q
                    // invalidate head
                    // increment head ptr
                next_snoop_req_Q[snoop_req_Q_head_ptr.index].valid = 1'b0;
                next_snoop_req_Q_head_ptr = snoop_req_Q_head_ptr + 1;
            end
        end

        // check if tail surpasses head
            // next tail msb != next head msb
            // next_tail index == next_head index + 1
        if (
            next_snoop_req_Q_tail_ptr.msb != next_snoop_req_Q_head_ptr.msb
            &
            next_snoop_req_Q_tail_ptr.index == next_snoop_req_Q_head_ptr.index + 1
        ) begin
            $display("dcache: ERROR: snoop req Q tail surpasses head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

        // dcache tag array and snoop tag array check
            // only need for debug
            // definitely remove if critical path or hurts area too much
        if (dcache_tag_frame_by_way_by_set != snoop_tag_frame_by_way_by_set) begin
            $display("dcache: ERROR: dcache tag array != snoop tag array");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

        ///////////////////////////
        // load MSHR kill logic: //
        ///////////////////////////
            // multicore: no change
            // this is highest priority, can have same-cycle load MSHR alloc and read kill
        
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
    end

endmodule