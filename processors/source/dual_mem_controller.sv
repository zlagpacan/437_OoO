/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dual_mem_controller.sv
    Instantiation Hierarchy: system -> dual_mem_controller
    Description:

        The memory controller arbitrates between imem read, dmem read, and dmem write requests, 
        servicing them one at a time, interfacing directly with ram.  

        imem reads are synchronous, blocking. They can change in the middle of being serviced,
        so must check returning value for current imem read req block addr.

        dmem reads and writes are asynchronous, non-blocking. 

        The memory controller must forward write buffer values to a current working dmem read on 
        block addr match.
            - youngest write (all writes are before the read as far as coherence goes, so just need
                youngest write)

        multicore updates:
            - choose between 2x imem read, dmem read Q, dmem write Q
            - 2x dmem read ports can simultaneously enQ to single dmem read Q
                - now do in-order responses for individual port, only need to give valid and data
                - need to track which port came from, broadcast read resp to that port
            - 2x dmem write ports can simultaneously enQ to single dmem write Q
*/

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

`include "cpu_ram_if.vh"

module dual_mem_controller (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    ////////////////////////
    // CPU RAM interface: //
    ////////////////////////

    cpu_ram_if.cpu prif,
        // // cpu ports
        // modport cpu (
        //     input   ramstate, ramload,
        //     output  memaddr, memREN, memWEN, memstore
        // );

    //////////////////////
    // imem interfaces: //
    //////////////////////
        // synchronous, blocking interface
        // essentially same as 437
        // multicore: 2x

    // imem0:
    input logic imem0_REN,
    input block_addr_t imem0_block_addr,
    output logic imem0_hit,
    output word_t [1:0] imem0_load,

    // imem1:
    input logic imem1_REN,
    input block_addr_t imem1_block_addr,
    output logic imem1_hit,
    output word_t [1:0] imem1_load,
    
    ///////////////////////////////
    // dmem read req interfaces: //
    ///////////////////////////////
        // asynchronous, non-blocking interface

    // dmem0 read req:
    input logic dmem0_read_req_valid,
    input block_addr_t dmem0_read_req_block_addr,
    
    // dmem1 read req:
    input logic dmem1_read_req_valid,
    input block_addr_t dmem1_read_req_block_addr,
    
    ////////////////////////////////
    // dmem read resp interfaces: //
    ////////////////////////////////
        // asynchronous, non-blocking interface

    // dmem0 read resp:
    output logic dmem0_read_resp_valid,
    output word_t [1:0] dmem0_read_resp_data,

    // dmem1 read resp:
    output logic dmem1_read_resp_valid,
    // output word_t [1:0] dmem1_read_resp_data,
    output logic dmem1_read_resp_data,
    
    ////////////////////////////////
    // dmem write req interfaces: //
    ////////////////////////////////
        // asynchronous, non-blocking interface

    // dmem0 write req:
    input logic dmem0_write_req_valid,
    input block_addr_t dmem0_write_req_block_addr,
    input word_t [1:0] dmem0_write_req_data,
    output logic dmem0_write_req_slow_down,

    // dmem1 write req:
    input logic dmem1_write_req_valid,
    input block_addr_t dmem1_write_req_block_addr,
    input word_t [1:0] dmem1_write_req_data,
    output logic dmem1_write_req_slow_down,

    //////////////
    // flushed: //
    //////////////

    input logic dcache0_flushed,
    input logic dcache1_flushed,
    output logic mem_controller_flushed
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
    // mem controller logic: 

    ///////////////////////
    // internal signals: //
    ///////////////////////

    // mem controller state
    typedef enum logic [1:0] {
        MEM_CONTROLLER_ARBITRATE,
        MEM_CONTROLLER_ACCESS_0,
        MEM_CONTROLLER_ACCESS_1,
        MEM_CONTROLLER_HALT
    } mem_controller_state_t;

    mem_controller_state_t mem_controller_state;
    mem_controller_state_t next_mem_controller_state;

    // dmem read buffer
    typedef struct packed {
        logic valid;
        block_addr_t block_addr;
        logic which;
    } read_buffer_entry_t;

    read_buffer_entry_t [MEM_CONTROLLER_READ_BUFFER_DEPTH-1:0] read_buffer;
    read_buffer_entry_t [MEM_CONTROLLER_READ_BUFFER_DEPTH-1:0] next_read_buffer;

    // dmem read buffer ptr's
    typedef struct packed {
        logic msb;
        logic [MEM_CONTROLLER_LOG_READ_BUFFER_DEPTH-1:0] index;
    } read_buffer_ptr_t;

    read_buffer_ptr_t read_buffer_head_ptr;
    read_buffer_ptr_t next_read_buffer_head_ptr;
    read_buffer_ptr_t read_buffer_tail_ptr;
    read_buffer_ptr_t next_read_buffer_tail_ptr;

    // dmem write buffer
    typedef struct packed {
        logic valid;
        block_addr_t block_addr;
        word_t [1:0] data;
    } write_buffer_entry_t;

    write_buffer_entry_t [MEM_CONTROLLER_WRITE_BUFFER_DEPTH-1:0] write_buffer;
    write_buffer_entry_t [MEM_CONTROLLER_WRITE_BUFFER_DEPTH-1:0] next_write_buffer;

    // dmem write buffer ptr's
    typedef struct packed {
        logic msb;
        logic [MEM_CONTROLLER_LOG_WRITE_BUFFER_DEPTH-1:0] index;
    } write_buffer_ptr_t;

    write_buffer_ptr_t write_buffer_head_ptr;
    write_buffer_ptr_t next_write_buffer_head_ptr;
    write_buffer_ptr_t write_buffer_tail_ptr;
    write_buffer_ptr_t next_write_buffer_tail_ptr;

    // working req
    typedef struct packed {
        logic imem0_read;
        logic imem1_read;
        logic dmem0_read;
        logic dmem1_read;
        logic dmem_write;
        block_addr_t block_addr;
        word_t [1:0] read_data;
        word_t [1:0] write_data;
        // word_t [1:0] write_buffer_forward_data;
            // just directly put the data in read_data so dcache can always read same
    } working_req_t;

    working_req_t working_req;
    working_req_t next_working_req;

    // // dmem read return
    //     // use next_ values for reg'd dmem read resp
    // logic next_dmem_read_resp_valid;
    // // block_addr_t next_dmem_read_resp_block_addr;
    // // word_t [1:0] next_dmem_read_resp_data;
        // these can come from working_req reg

    // latched dmem0 read return
    logic next_dmem0_read_resp_valid;

    // latched dmem1 read return
    logic next_dmem1_read_resp_valid;

    // imem read return
        // use next_ values for reg'd imem hit, load
        // NO:
            // want check that returning imem addr matches current before giving hit
            // instead, have separate reg which drives imem_hit high if returning matches curr
    // logic returning_imem_hit;
    // logic next_returning_imem_hit;
    // block_addr_t returning_imem_block_addr;
    // block_addr_t next_returning_imem_block_addr;
        // these can come from working_req reg

        // NEVERMIND ALL OF ^
            // can do checks inside of ACCESS 1, want to give ihit early so icache can update block addr
                // for next in stream

    // reg'd flushed
    logic next_mem_controller_flushed;

    // write buffer search:
    logic write_buffer_search_found;
    logic [MEM_CONTROLLER_LOG_WRITE_BUFFER_DEPTH-1:0] write_buffer_search_youngest_found_index;
    logic [MEM_CONTROLLER_LOG_WRITE_BUFFER_DEPTH-1:0] write_buffer_search_first_half_youngest_found_index;
    logic [MEM_CONTROLLER_LOG_WRITE_BUFFER_DEPTH-1:0] next_write_buffer_search_first_half_youngest_found_index;
    word_t [1:0] write_buffer_search_data;

    // imem LRU
    logic imem_LRU;
    logic next_imem_LRU;

    //////////
    // seq: //
    //////////

    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            mem_controller_state <= MEM_CONTROLLER_ARBITRATE;

            read_buffer <= '0;

            read_buffer_head_ptr <= '0;
            read_buffer_tail_ptr <= '0;

            write_buffer <= '0;

            write_buffer_head_ptr <= '0;
            write_buffer_tail_ptr <= '0;

            working_req <= '0;

            dmem0_read_resp_valid <= 1'b0;
            dmem1_read_resp_valid <= 1'b0;

            mem_controller_flushed <= 1'b0;

            write_buffer_search_first_half_youngest_found_index <= '0;

            imem_LRU <= 1'b0;
        end
        else begin
            mem_controller_state <= next_mem_controller_state;

            read_buffer <= next_read_buffer;

            read_buffer_head_ptr <= next_read_buffer_head_ptr;
            read_buffer_tail_ptr <= next_read_buffer_tail_ptr;

            write_buffer <= next_write_buffer;

            write_buffer_head_ptr <= next_write_buffer_head_ptr;
            write_buffer_tail_ptr <= next_write_buffer_tail_ptr;

            working_req <= next_working_req;

            dmem0_read_resp_valid <= next_dmem0_read_resp_valid;
            dmem1_read_resp_valid <= next_dmem1_read_resp_valid;

            mem_controller_flushed <= next_mem_controller_flushed;

            write_buffer_search_first_half_youngest_found_index <= next_write_buffer_search_first_half_youngest_found_index;
        
            imem_LRU <= next_imem_LRU;
        end
    end

    /////////////////
    // comb logic: //
    /////////////////

    always_comb begin

        //////////////////////
        // default outputs: //
        //////////////////////

        ////////////////////////
        // Top Level Signals: 

        // no DUT error
        next_DUT_error = 1'b0;

        ////////////////////////
        // CPU RAM interface:
            // no REN, no WEN
            // addr, data from working req [0]
        prif.memREN = 1'b0;
        prif.memWEN = 1'b0;
        prif.memaddr = {16'h0, working_req.block_addr, 1'b0, 2'b00};
        prif.memstore = working_req.write_data[0];

        //////////////////////
        // imem interfaces: 
            // no mem hit
            // load from working req
        
        // imem0:
        imem0_hit = 1'b0;
        imem0_load = working_req.read_data;

        // imem1:
        imem1_hit = 1'b0;
        imem1_load = working_req.read_data;

        ///////////////////////////////
        // dmem read req interfaces:

        // dmem0 read req:

        // dmem1 read req:

        ////////////////////////////////
        // dmem read resp interfaces: 

        // dmem0 read resp:
        next_dmem0_read_resp_valid = 1'b0;
        dmem0_read_resp_data = working_req.read_data;

        // dmem1 read resp:
        next_dmem1_read_resp_valid = 1'b0;
        dmem1_read_resp_data = working_req.read_data;

        ////////////////////////////////
        // dmem write req interfaces:

        // dmem0 write req:
        dmem0_write_req_slow_down = 1'b0;

        // dmem1 write req:
        dmem1_write_req_slow_down = 1'b0;
        
        //////////////
        // flushed:

        ///////////////////////
        // Internal Signals: 

        // mem controller state
        next_mem_controller_state = mem_controller_state;

        // dmem read buffer
        next_read_buffer = read_buffer;
        
        // dmem read buffer ptr's
        next_read_buffer_head_ptr = read_buffer_head_ptr;
        next_read_buffer_tail_ptr = read_buffer_tail_ptr;

        // dmem write buffer
        next_write_buffer = write_buffer;

        // dmem write buffer ptr's
        next_write_buffer_head_ptr = write_buffer_head_ptr;
        next_write_buffer_tail_ptr = write_buffer_tail_ptr;

        // working req
        next_working_req = working_req;

        // reg'd flushed
        next_mem_controller_flushed = 1'b0;

        // write buffer search
        write_buffer_search_found = 1'b0;;
        write_buffer_search_youngest_found_index = write_buffer_head_ptr.index;
        next_write_buffer_search_first_half_youngest_found_index = write_buffer_search_youngest_found_index;
        write_buffer_search_data = {32'h0, 32'h0};

        // imem LRU
        next_imem_LRU = imem_LRU;

        /////////////////////////////////
        // state independent behavior: //
        /////////////////////////////////

        // enQ dmem read buffer
            // dmem0 and dmem1 simultaneous enQ allowed
                // dmem0 first in line

        // check dmem0 and dmem1 simultaneous
        if (dmem0_read_req_valid & dmem1_read_req_valid) begin

            // dmem0 @ tail
            next_read_buffer[read_buffer_tail_ptr.index].valid = 1'b1;
            next_read_buffer[read_buffer_tail_ptr.index].block_addr =
                dmem0_read_req_block_addr
            ;
            next_read_buffer[read_buffer_tail_ptr.index].which = 1'b0;

            // dmem1 @ tail + 1
            next_read_buffer[read_buffer_tail_ptr.index + 1].valid = 1'b1;
            next_read_buffer[read_buffer_tail_ptr.index + 1].block_addr =
                dmem1_read_req_block_addr
            ;
            next_read_buffer[read_buffer_tail_ptr.index + 1].which = 1'b1;

            // increment tail + 2
            next_read_buffer_tail_ptr = read_buffer_tail_ptr + 2;
        end

        // otherwise, check solo dmem0
        else if (dmem0_read_req_valid) begin

            // dmem0 @ tail
            next_read_buffer[read_buffer_tail_ptr.index].valid = 1'b1;
            next_read_buffer[read_buffer_tail_ptr.index].block_addr =
                dmem0_read_req_block_addr
            ;
            next_read_buffer[read_buffer_tail_ptr.index].which = 1'b0;

            // increment tail + 1
            next_read_buffer_tail_ptr = read_buffer_tail_ptr + 1;
        end

        // otherwise, check solo dmem1
        else if (dmem1_read_req_valid) begin

            // dmem1 @ tail
            next_read_buffer[read_buffer_tail_ptr.index].valid = 1'b1;
            next_read_buffer[read_buffer_tail_ptr.index].block_addr =
                dmem1_read_req_block_addr
            ;
            next_read_buffer[read_buffer_tail_ptr.index].which = 1'b1;

            // increment tail + 1
            next_read_buffer_tail_ptr = read_buffer_tail_ptr + 1;
        end

        // enQ dmem write buffer
            // dmem0 and dmem1 simultaneous enQ allowed
                // dmem0 first in line

        // check dmem0 and dmem1 simultaneous
        if (dmem0_write_req_valid & dmem1_write_req_valid) begin

            // dmem0 @ tail
            next_write_buffer[write_buffer_tail_ptr.index].valid = 1'b1;
            next_write_buffer[write_buffer_tail_ptr.index].block_addr =
                dmem0_write_req_block_addr
            ;
            next_write_buffer[write_buffer_tail_ptr.index].data =
                dmem0_write_req_data
            ;

            // dmem1 @ tail + 1
            next_write_buffer[write_buffer_tail_ptr.index + 1].valid = 1'b1;
            next_write_buffer[write_buffer_tail_ptr.index + 1].block_addr =
                dmem1_write_req_block_addr
            ;
            next_write_buffer[write_buffer_tail_ptr.index + 1].data =
                dmem1_write_req_data
            ;

            // increment tail + 2
            next_write_buffer_tail_ptr = write_buffer_tail_ptr + 2;
        end

        // otherwise, check solo dmem0
        else if (dmem0_write_req_valid) begin

            // dmem0 @ tail
            next_write_buffer[write_buffer_tail_ptr.index].valid = 1'b1;
            next_write_buffer[write_buffer_tail_ptr.index].block_addr =
                dmem0_write_req_block_addr
            ;
            next_write_buffer[write_buffer_tail_ptr.index].data =
                dmem0_write_req_data
            ;

            // increment tail + 1
            next_write_buffer_tail_ptr = write_buffer_tail_ptr + 1;
        end
        
        // otherwise, check solo dmem1
        else if (dmem1_write_req_valid) begin

            // dmem1 @ tail
            next_write_buffer[write_buffer_tail_ptr.index].valid = 1'b1;
            next_write_buffer[write_buffer_tail_ptr.index].block_addr =
                dmem1_write_req_block_addr
            ;
            next_write_buffer[write_buffer_tail_ptr.index].data =
                dmem1_write_req_data
            ;

            // increment tail + 1
            next_write_buffer_tail_ptr = write_buffer_tail_ptr + 1;
        end

        // check to give slow down to dcache
            // write buffer tail - write buffer head > 1/2 capacity
        if (
            write_buffer_tail_ptr - write_buffer_head_ptr 
            > 
            (MEM_CONTROLLER_WRITE_BUFFER_DEPTH / 2)
        ) begin
            dmem0_write_req_slow_down = 1'b1;
            dmem1_write_req_slow_down = 1'b1;
        end

        ///////////////////////////////
        // state dependent behavior: //
        ///////////////////////////////

        case (mem_controller_state) 

            MEM_CONTROLLER_ARBITRATE:
            begin

                // pick a mem req to service
                    // dmem read > dmem write > imem read
                    // imem read follows imem LRU

                // check have dmem read
                if (read_buffer[read_buffer_head_ptr.index].valid) begin

                    // update working req
                    next_working_req.imem0_read = 1'b0;
                    next_working_req.imem1_read = 1'b0;
                    if (read_buffer[read_buffer_head_ptr.index].which) begin
                        next_working_req.dmem0_read = 1'b0;
                        next_working_req.dmem1_read = 1'b1;
                    end
                    else begin
                        next_working_req.dmem0_read = 1'b1;
                        next_working_req.dmem1_read = 1'b0;
                    end
                    next_working_req.dmem_write = 1'b0;
                    next_working_req.block_addr = read_buffer[read_buffer_head_ptr.index].block_addr;

                    // deQ dmem read buffer
                        // invalidate head entry
                        // increment head
                    next_read_buffer[read_buffer_head_ptr.index].valid = 1'b0;
                    next_read_buffer_head_ptr = read_buffer_head_ptr + 1;

                    // goto ACCESS 0
                    next_mem_controller_state = MEM_CONTROLLER_ACCESS_0;
                end

                // check have dmem write
                else if (write_buffer[write_buffer_head_ptr.index].valid) begin

                    // update working req
                    next_working_req.imem0_read = 1'b0;
                    next_working_req.imem1_read = 1'b0;
                    next_working_req.dmem0_read = 1'b0;
                    next_working_req.dmem1_read = 1'b0;
                    next_working_req.dmem_write = 1'b1;
                    next_working_req.block_addr = write_buffer[write_buffer_head_ptr.index].block_addr;
                    next_working_req.write_data = write_buffer[write_buffer_head_ptr.index].data;

                    // deQ dmem write buffer
                        // invalidate head entry
                        // increment head
                    next_write_buffer[write_buffer_head_ptr.index].valid = 1'b0;
                    next_write_buffer_head_ptr = write_buffer_head_ptr + 1;

                    // goto ACCESS 0
                    next_mem_controller_state = MEM_CONTROLLER_ACCESS_0;
                end

                // check have simultaneous imem0 and imem1 read
                else if (imem0_REN & imem1_REN) begin

                    // update working req
                    if (imem_LRU) begin
                        next_working_req.imem0_read = 1'b0;
                        next_working_req.imem1_read = 1'b1;
                        next_working_req.block_addr = imem1_block_addr;
                    end
                    else begin
                        next_working_req.imem0_read = 1'b1;
                        next_working_req.imem1_read = 1'b0;
                        next_working_req.block_addr = imem0_block_addr;
                    end
                    next_working_req.dmem0_read = 1'b0;
                    next_working_req.dmem1_read = 1'b0;
                    next_working_req.dmem_write = 1'b0;

                    // goto ACCESS 0
                    next_mem_controller_state = MEM_CONTROLLER_ACCESS_0;
                end

                // check have solo imem0 read
                else if (imem0_REN) begin

                    // update working req
                    next_working_req.imem0_read = 1'b1;
                    next_working_req.imem1_read = 1'b0;
                    next_working_req.block_addr = imem0_block_addr;
                    next_working_req.dmem0_read = 1'b0;
                    next_working_req.dmem1_read = 1'b0;
                    next_working_req.dmem_write = 1'b0;

                    // goto ACCESS 0
                    next_mem_controller_state = MEM_CONTROLLER_ACCESS_0;
                end

                // check have solo imem1 read
                else if (imem1_REN) begin

                    // update working req
                    next_working_req.imem0_read = 1'b0;
                    next_working_req.imem1_read = 1'b1;
                    next_working_req.block_addr = imem1_block_addr;
                    next_working_req.dmem0_read = 1'b0;
                    next_working_req.dmem1_read = 1'b0;
                    next_working_req.dmem_write = 1'b0;

                    // goto ACCESS 0
                    next_mem_controller_state = MEM_CONTROLLER_ACCESS_0;
                end

                // check dcache0 flushed and dcache1 flushed and write buffer empty 
                    // also check read buffer empty?
                        // could be preventing BusRdX store from happening
                        // NO: dcache wouldn't have been flushed if this true
                    // head == tail
                if (
                    dcache0_flushed
                    &
                    dcache1_flushed
                    &
                    (
                        write_buffer_head_ptr
                        ==
                        write_buffer_tail_ptr
                    )
                    // &
                    // (
                    //     read_buffer_head_ptr
                    //     ==
                    //     read_buffer_tail_ptr
                    // )
                    
                ) begin

                    // goto HALT
                    next_mem_controller_state = MEM_CONTROLLER_HALT;
                end
            end

            MEM_CONTROLLER_ACCESS_0:
            begin
                // prif follows working req @ block offset = 0
                prif.memREN = 1'b0;
                prif.memWEN = 1'b0;
                prif.memaddr = {16'h0, working_req.block_addr, 1'b0, 2'b00};
                prif.memstore = working_req.write_data[0];

                // write word 0 if dmem write
                if (working_req.dmem_write) begin
                    prif.memWEN = 1'b1;
                end

                // otherwise, read word 0
                else begin
                    prif.memREN = 1'b1;
                end

                // always update word 0 read value
                next_working_req.read_data[0] = prif.ramload;

                // if access, go to ACCESS 1
                if (prif.ramstate == ACCESS) begin
                    next_mem_controller_state = MEM_CONTROLLER_ACCESS_1;
                end

                // if doing dmem0_read or dmem1_read, need to search through write buffer
                if (working_req.dmem0_read | working_req.dmem1_read) begin

                    // search through write buffer for youngest matching block addr
                    write_buffer_search_found = 1'b0;
                    write_buffer_search_youngest_found_index = write_buffer_head_ptr.index;
                    write_buffer_search_data = {32'h0, 32'h0};
                    // for (int i = 0; i < MEM_CONTROLLER_WRITE_BUFFER_DEPTH; i++) begin

                    // ONLY SEARCH THROUGH FIRST HALF
                    for (int i = 0; i < (MEM_CONTROLLER_WRITE_BUFFER_DEPTH / 2); i++) begin

                        // check for entry valid and block addr match
                        if (
                            write_buffer[i].valid
                            &
                            (
                                write_buffer[i].block_addr
                                ==
                                working_req.block_addr
                            )
                        ) begin

                            // search successful
                            write_buffer_search_found = 1'b1;

                            // check new youngest
                                // younger -> greater than
                                // subtract from current head
                                // check == since can be taking from oldest possible write == head
                                    // init value of write_buffer_search_youngest_found_index
                            if (
                                i - write_buffer_head_ptr.index
                                >=
                                write_buffer_search_youngest_found_index - write_buffer_head_ptr.index
                            ) begin

                                // update youngest
                                write_buffer_search_youngest_found_index = i;
                                next_write_buffer_search_first_half_youngest_found_index = write_buffer_search_youngest_found_index;

                                // update youngest data
                                write_buffer_search_data = write_buffer[i].data;
                            end
                        end
                    end

                    // // do write buffer forward if search successful
                    // if (write_buffer_search_found) begin

                    //     // save forward val in working req
                    //     next_working_req.read_data = write_buffer_search_data;

                    //     // send dmem read resp
                    //     next_dmem_read_resp_valid = 1'b1;

                    //     // return to ARBITRATE
                    //     next_mem_controller_state = MEM_CONTROLLER_ARBITRATE;
                    // end

                    // otherwise, read seemessly continues trying to get val from mem
                end
            end

            MEM_CONTROLLER_ACCESS_1:
            begin
                // prif follows working req @ block offset = 1
                prif.memREN = 1'b0;
                prif.memWEN = 1'b0;
                prif.memaddr = {16'h0, working_req.block_addr, 1'b1, 2'b00};
                prif.memstore = working_req.write_data[1];

                // write word 0 if dmem write
                if (working_req.dmem_write) begin
                    prif.memWEN = 1'b1;
                end

                // otherwise, read word 0
                else begin
                    prif.memREN = 1'b1;
                end

                // always update word 1 read value
                next_working_req.read_data[1] = prif.ramload;

                // if access, go to ARBITRATE
                if (prif.ramstate == ACCESS) begin
                    next_mem_controller_state = MEM_CONTROLLER_ARBITRATE;

                    // give associated response if applicable
                    
                    // check for dmem0 read
                    if (working_req.dmem0_read) begin
                        next_dmem0_read_resp_valid = 1'b1;
                    end

                    // check for dmem1 read
                    if (working_req.dmem1_read) begin
                        next_dmem1_read_resp_valid = 1'b1;
                    end

                    // check serviced imem0 req matches current imem0 req
                    if (
                        working_req.imem0_read
                        &
                        imem0_REN
                        &
                        working_req.block_addr == imem0_block_addr
                    ) begin
                        
                        // give imem hit
                        imem0_hit = 1'b1;
                        imem0_load = {
                            prif.ramload,
                            working_req.read_data[0]
                        };
                    end

                    // check serviced imem1 req matches current imem1 req
                    if (
                        working_req.imem1_read
                        &
                        imem1_REN
                        &
                        working_req.block_addr == imem1_block_addr
                    ) begin
                        
                        // give imem hit
                        imem1_hit = 1'b1;
                        imem1_load = {
                            prif.ramload,
                            working_req.read_data[0]
                        };
                    end
                end

                // if doing dmem0_read or dmem1_read, need to search through write buffer
                if (working_req.dmem0_read | working_req.dmem1_read) begin

                    // search through write buffer for youngest matching block addr
                    write_buffer_search_found = 1'b0;
                    // write_buffer_search_youngest_found_index = write_buffer_head_ptr.index;
                    // THIS TIME, START FROM YOUNGEST THAT FIRST HALF OF SEARCH FOUND
                    write_buffer_search_youngest_found_index = write_buffer_search_first_half_youngest_found_index;

                    write_buffer_search_data = {32'h0, 32'h0};
                    // for (int i = 0; i < MEM_CONTROLLER_WRITE_BUFFER_DEPTH; i++) begin

                    // ONLY SEARCH THROUGH SECOND HALF
                    for (int i = (MEM_CONTROLLER_WRITE_BUFFER_DEPTH / 2); i < MEM_CONTROLLER_WRITE_BUFFER_DEPTH; i++) begin

                        // check for entry valid and block addr match
                        if (
                            write_buffer[i].valid
                            &
                            (
                                write_buffer[i].block_addr
                                ==
                                working_req.block_addr
                            )
                        ) begin

                            // search successful
                            write_buffer_search_found = 1'b1;

                            // check new youngest
                                // younger -> greater than
                                // subtract from current head
                                // check == since can be taking from oldest possible write == head
                                    // init value of write_buffer_search_youngest_found_index
                            if (
                                i - write_buffer_head_ptr.index
                                >=
                                write_buffer_search_youngest_found_index - write_buffer_head_ptr.index
                            ) begin

                                // update youngest
                                write_buffer_search_youngest_found_index = i;

                                // update youngest data
                                write_buffer_search_data = write_buffer[i].data;
                            end
                        end
                    end

                    // do write buffer forward if search successful
                    if (write_buffer_search_found) begin

                        // save forward val in working req
                        next_working_req.read_data = write_buffer_search_data;

                        // send dmem read resp
                        // next_dmem_read_resp_valid = 1'b1;
                        if (working_req.dmem0_read) begin
                            next_dmem0_read_resp_valid = 1'b1;
                        end
                        if (working_req.dmem1_read) begin
                            next_dmem1_read_resp_valid = 1'b1;
                        end

                        // return to ARBITRATE
                        next_mem_controller_state = MEM_CONTROLLER_ARBITRATE;
                    end

                    // otherwise, read seemessly continues trying to get val from mem
                end
            end

            MEM_CONTROLLER_HALT:
            begin
                // convergent state
                next_mem_controller_state = MEM_CONTROLLER_HALT;
                
                // assert flush
                next_mem_controller_flushed = 1'b1;
            end

        endcase

        // check any Q tails surpassed head:
            // next tail msb != next head msb
            // next tail index == next head index + 1
                // OR next tail index == next head inex + 2 because can double enQ

        // dmem read buffer
        if (
            next_read_buffer_tail_ptr.msb != next_read_buffer_head_ptr.msb
            &
            (
                next_read_buffer_tail_ptr.index == read_buffer_head_ptr + 1
                |
                next_read_buffer_tail_ptr.index == read_buffer_head_ptr + 2
            )
        ) begin
            $display("mem_controller: ERROR: dmem read buffer tail surpassed head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

        // dmem write buffer
        if (
            next_write_buffer_tail_ptr.msb != next_write_buffer_head_ptr.msb
            &
            (
                next_write_buffer_tail_ptr.index == write_buffer_head_ptr + 1
                |
                next_write_buffer_tail_ptr.index == write_buffer_head_ptr + 2
            )
        ) begin
            $display("mem_controller: ERROR: dmem write buffer tail surpassed head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

    end

endmodule