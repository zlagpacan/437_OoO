/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: bus_controller.sv
    Instantiation Hierarchy: system -> bus_controller
    Description:

        The bus controller arbitrates between multiple data bus requests from multiple cores' dcaches,
        making the associated snoop requests, receiving the associated snoop responses, and making the
        associated memory read requests, and receiving the associated memory responses, giving the final
        data bus responses back to the dcaches. 

        The bus controller supports snoopy bus requests with the MOESI protocol. 

        This bus controller is designed for a 2-core system, and makes associated protocol assumptions
        that are implied by a 2-core system. 

        2x major parts of pipeline, separated by snoop req -> snoop resp

            1) dbus req Q's + conflict table + grant logic
                - includes snooping of snoop resp's
                - includes snoop req generation, put into FF to be output next cycle

            2) snoop resp handling + dmem read resp Q + dbus resp logic
                - takes input snoop resp and latches path to take 
                    - direct to dbus resp or dmem read req + dmem read resp Q
                - return dbus resp or dmem read resp @ dmem read resp Q resp head
                - accept dmem read resp @ dmem resp Q return head
*/

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module bus_controller (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    //////////////////////////////////////////
    // data bus request/response interface: //
    //////////////////////////////////////////
        // asynchronous, non-blocking interface
    
    // dbus0 req:
    input logic dbus0_req_valid,
    input block_addr_t dbus0_req_block_addr,
    input logic dbus0_req_exclusive,
    input MOESI_state_t dbus0_req_curr_state,

    // dbus0 resp:
    output logic dbus0_resp_valid,
    output block_addr_t dbus0_resp_block_addr,
    output word_t [1:0] dbus0_resp_data,
    output logic dbus0_resp_need_block,
    output MOESI_state_t dbus0_resp_new_state,

    // dbus1 req:
    input logic dbus1_req_valid,
    input block_addr_t dbus1_req_block_addr,
    input logic dbus1_req_exclusive,
    input MOESI_state_t dbus1_req_curr_state,

    // dbus1 resp:
    output logic dbus1_resp_valid,
    output block_addr_t dbus1_resp_block_addr,
    output word_t [1:0] dbus1_resp_data,
    output logic dbus1_resp_need_block,
    output MOESI_state_t dbus1_resp_new_state,

    ///////////////////////////////////////
    // snoop request/response interface: //
    ///////////////////////////////////////

    // snoop0 req:
    output logic snoop0_req_valid,
    output block_addr_t snoop0_req_block_addr,
    output logic snoop0_req_exclusive,
    output MOESI_state_t snoop0_req_curr_state,

    // snoop0 resp:
    input logic snoop0_resp_valid,
    input block_addr_t snoop0_resp_block_addr,
    input word_t [1:0] snoop0_resp_data,
    input logic snoop0_resp_present,
    input logic snoop0_resp_need_block,
    input MOESI_state_t snoop0_resp_new_state,

    // snoop1 req:
    output logic snoop1_req_valid,
    output block_addr_t snoop1_req_block_addr,
    output logic snoop1_req_exclusive,
    output MOESI_state_t snoop1_req_curr_state,

    // snoop1 resp:
    input logic snoop1_resp_valid,
    input block_addr_t snoop1_resp_block_addr,
    input word_t [1:0] snoop1_resp_data,
    input logic snoop1_resp_present,
    input logic snoop1_resp_need_block,
    input MOESI_state_t snoop1_resp_new_state,

    ///////////////////////////////
    // mem controller interface: //
    ///////////////////////////////

    // dmem0 read req:
    output logic dmem0_read_req_valid,
    output block_addr_t dmem0_read_req_block_addr,

    // dmem0 read resp:
    input logic dmem0_read_resp_valid,
    input word_t [1:0] dmem0_read_resp_data,

    // dmem1 read req:
    output logic dmem1_read_req_valid,
    output block_addr_t dmem1_read_req_block_addr,

    // dmem1 read resp:
    input logic dmem1_read_resp_valid,
    input word_t [1:0] dmem1_read_resp_data,
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
    // dbus req Q's + conflict table + grant logic:

    // dbus req Q's:
    typedef struct packed {
        logic valid;
        block_addr_t block_addr;
        logic exclusive;
        MOESI_state_t curr_state;
    } dbus_req_Q_entry_t;

    // dbus0 req Q:
    dbus_req_Q_entry_t [BUS_CONTROLLER_DBUS_REQ_Q_DEPTH-1:0] dbus0_req_Q;
    dbus_req_Q_entry_t [BUS_CONTROLLER_DBUS_REQ_Q_DEPTH-1:0] next_dbus0_req_Q;

    // dbus1 req Q:
    dbus_req_Q_entry_t [BUS_CONTROLLER_DBUS_REQ_Q_DEPTH-1:0] dbus1_req_Q;
    dbus_req_Q_entry_t [BUS_CONTROLLER_DBUS_REQ_Q_DEPTH-1:0] next_dbus1_req_Q;

    // dbus req Q ptr's:
    typedef struct packed {
        logic msb;
        logic [BUS_CONTROLLER_LOG_DBUS_REQ_Q_DEPTH-1:0] index;
    } dbus_req_Q_ptr_t;

    // dbus0 req Q ptr's:
    dbus_req_Q_ptr_t dbus0_req_Q_head_ptr;
    dbus_req_Q_ptr_t next_dbus0_req_Q_head_ptr;
    dbus_req_Q_ptr_t dbus0_req_Q_tail_ptr;
    dbus_req_Q_ptr_t next_dbus0_req_Q_tail_ptr;

    // dbus1 req Q ptr's:
    dbus_req_Q_ptr_t dbus1_req_Q_head_ptr;
    dbus_req_Q_ptr_t next_dbus1_req_Q_head_ptr;
    dbus_req_Q_ptr_t dbus1_req_Q_tail_ptr;
    dbus_req_Q_ptr_t next_dbus1_req_Q_tail_ptr;

    // conflict table:
    typedef logic [BUS_CONTROLLER_CONFLICT_TABLE_COUNT_BIT_WIDTH-1:0] conflict_table_count_t;

    conflict_table_count_t [1:0][BUS_CONTROLLER_CONFLICT_TABLE_NUM_SETS-1:0] conflict_table_count_by_way_by_set;
    conflict_table_count_t [1:0][BUS_CONTROLLER_CONFLICT_TABLE_NUM_SETS-1:0] next_conflict_table_count_by_way_by_set;

    // conflicts:
    conflict_table_block_addr_t dbus0_req_conflict_block_addr;
    conflict_table_block_addr_t dbus1_req_conflict_block_addr;
    conflict_table_block_addr_t dbus0_resp_conflict_block_addr;
    conflict_table_block_addr_t dbus1_resp_conflict_block_addr;
    logic dbus0_req_conflict;
    logic dbus1_req_conflict;

    // latched snoop0 req:
    logic next_snoop0_req_valid;
    block_addr_t next_snoop0_req_block_addr;
    logic next_snoop0_req_exclusive;
    MOESI_state_t next_snoop0_req_curr_state;

    // latched snoop1 req:
    logic next_snoop1_req_valid;
    block_addr_t next_snoop1_req_block_addr;
    logic next_snoop1_req_exclusive;
    MOESI_state_t next_snoop1_req_curr_state;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            dbus0_req_Q <= '0;
            dbus1_req_Q <= '0;

            dbus0_req_Q_head_ptr <= '0;
            dbus0_req_Q_tail_ptr <= '0;

            dbus1_req_Q_head_ptr <= '0;
            dbus1_req_Q_tail_ptr <= '0;

            conflict_table_count_by_way_by_set <= '0;
            
            snoop0_req_valid <= 1'b0;
            snoop0_req_block_addr <= 13'h0;
            snoop0_req_exclusive <= 1'b0;
            snoop0_req_curr_state <= MOESI_I;

            snoop1_req_valid <= 1'b0;
            snoop1_req_block_addr <= 13'h0;
            snoop1_req_exclusive <= 1'b0;
            snoop1_req_curr_state <= MOESI_I;
        end
        else begin
            dbus0_req_Q <= next_dbus0_req_Q;
            dbus1_req_Q <= next_dbus1_req_Q;

            dbus0_req_Q_head_ptr <= next_dbus0_req_Q_head_ptr;
            dbus0_req_Q_tail_ptr <= next_dbus0_req_Q_tail_ptr;

            dbus1_req_Q_head_ptr <= next_dbus1_req_Q_head_ptr;
            dbus1_req_Q_tail_ptr <= next_dbus1_req_Q_tail_ptr;

            conflict_table_count_by_way_by_set <= next_conflict_table_count_by_way_by_set;

            snoop0_req_valid <= next_snoop0_req_valid;
            snoop0_req_block_addr <= next_snoop0_req_block_addr;
            snoop0_req_exclusive <= next_snoop0_req_exclusive;
            snoop0_req_curr_state <= next_snoop0_req_curr_state;

            snoop1_req_valid <= next_snoop0_req_valid;
            snoop1_req_block_addr <= next_snoop0_req_block_addr;
            snoop1_req_exclusive <= next_snoop0_req_exclusive;
            snoop1_req_curr_state <= next_snoop0_req_curr_state;
        end
    end

    // comb logic:
    always_comb begin

        //////////////////////
        // default outputs: //
        //////////////////////

        // dbus0 req Q:
        next_dbus0_req_Q = dbus0_req_Q;

        // dbus1 req Q:
        next_dbus1_req_Q = dbus1_req_Q:

        // dbus0 req Q ptr's:
        next_dbus0_req_Q_head_ptr = dbus0_req_Q_head_ptr;
        next_dbus0_req_Q_tail_ptr = dbus0_req_Q_tail_ptr;

        // dbus1 req Q ptr's:
        next_dbus1_req_Q_head_ptr = dbus1_req_Q_head_ptr;
        next_dbus1_req_Q_tail_ptr = dbus1_req_Q_tail_ptr;

        // conflict table:
        next_conflict_table_count_by_way_by_set = conflict_table_count_by_way_by_set;

        // conflicts:
            // get addr from head of dbus req Q
        dbus0_req_conflict_block_addr = dbus0_req_Q[dbus0_req_Q_head_ptr.index].block_addr;
        dbus1_req_conflict_block_addr = dbus1_req_Q[dbus1_req_Q_head_ptr.index].block_addr;
        dbus0_resp_conflict_block_addr = dbus0_resp_block_addr;
        dbus1_resp_conflict_block_addr = dbus1_resp_block_addr;

        // latched snoop0 req:
        next_snoop0_req_valid = 1'b0;
        next_snoop0_req_block_addr = 13'h0;
        next_snoop0_req_exclusive = 1'b0;
        next_snoop0_req_curr_state = MOESI_I;

        // latched snoop1 req:
        next_snoop1_req_valid = 1'b0;
        next_snoop1_req_block_addr = 13'h0;
        next_snoop1_req_exclusive = 1'b0;
        next_snoop1_req_curr_state = MOESI_I;

        ///////////////////
        // dbus req enQ: //
        ///////////////////

        // dbus0:
        if (dbus0_req_valid) begin

            // enQ at tail
            next_dbus0_req_Q[dbus0_req_Q_tail_ptr.index] = {
                1'b1,
                dbus0_req_block_addr,
                dbus0_req_exclusive,
                dbus0_req_curr_state
            };

            // increment tail
            next_dbus0_req_Q_tail_ptr = dbus0_req_Q_tail_ptr + 1;
        end

        // dbus1:
        if (dbus1_req_valid) begin

            // enQ at tail
            next_dbus1_req_Q[dbus1_req_Q_tail_ptr.index] = {
                1'b1,
                dbus1_req_block_addr,
                dbus1_req_exclusive,
                dbus1_req_curr_state
            };

            // increment tail
            next_dbus1_req_Q_tail_ptr = dbus1_req_Q_tail_ptr + 1;
        end

        ///////////////////////////////
        // snooping of dbus req Q's: //
        ///////////////////////////////
            // dbus0 req Q:
                // check snoop0 resp for standard snoop state transition
                // check snoop1 resp for inv piggybackable
            // dbus1 req Q:
                // check snoop1 resp for standard snoop state transition
                // check snoop0 resp for inv piggybackable

        // snoop0 resp:
            // check dbus0 req Q for standard snoop state transition
            // check dbus1 req Q for inv piggybackable
        if (snoop0_resp_valid) begin

            
        end
        
        // snoop1 resp:
            // check dbus1 req Q for standard snoop state transition
            // check dbus0 req Q for inv piggybackable
        if (snoop1_resp_valid) begin

        end

        //////////////////
        // grant logic: //
        //////////////////
            // dbus req Q deQ's
            // conflict table 2x read, 2x increment writes
            // next snoop req's
            // conflict table 2x decrement writes
                // purposely put decrement after so can check increment early in cycle
                    // already long path since second increment relies on first being done
                // will mean conflict table effectively gets updates from dbus resp cycle after

        // check for dbus0 req deQ
        dbus0_req_conflict = 1'b0;
        if (dbus0_req_Q[dbus0_req_Q_head_ptr.index].valid) begin

            // check conflict table:
            
            // check both ways != 0
            if (
                (
                    conflict_table_count_by_way_by_set
                    [0]
                    [dbus0_req_conflict_block_addr.lower_index]
                    !=
                    '0
                )
                &
                (
                    conflict_table_count_by_way_by_set
                    [1]
                    [
                        dbus0_req_conflict_block_addr.upper_index
                        ^
                        dbus0_req_conflict_block_addr.lower_index
                    ]
                    !=
                    '0
                )
            ) begin
                dbus0_req_conflict = 1'b1;
            end

            // check either way == MAX
            if (
                (
                    conflict_table_count_by_way_by_set
                    [0]
                    [dbus0_req_conflict_block_addr.lower_index]
                    ==
                    '1
                )
                |
                (
                    conflict_table_count_by_way_by_set
                    [1]
                    [
                        dbus0_req_conflict_block_addr.upper_index
                        ^
                        dbus0_req_conflict_block_addr.lower_index
                    ]
                    ==
                    '1
                )
            ) begin
                dbus0_req_conflict = 1'b1;
            end

            // send snoop req if no conflict
            if (~dbus0_req_conflict) begin

                // snoop req 0->1
                next_snoop1_req_valid = 1'b1;
                next_snoop1_req_block_addr = dbus0_req_Q[dbus0_req_Q_head_ptr.index].block_addr;
                next_snoop1_req_exclusive = dbus0_req_Q[dbus0_req_Q_head_ptr.index].exclusive;
                next_snoop1_req_curr_state = dbus0_req_Q[dbus0_req_Q_head_ptr.index].curr_state;

                // increment way 0 count
                next_conflict_table_count_by_way_by_set
                [0]
                [dbus0_req_conflict_block_addr.lower_index]
                =
                    conflict_table_count_by_way_by_set
                    [0]
                    [dbus0_req_conflict_block_addr.lower_index]
                    + 1
                ;

                // increment way 1 count
                next_conflict_table_count_by_way_by_set
                [1]
                [
                    dbus0_req_conflict_block_addr.upper_index
                    ^
                    dbus0_req_conflict_block_addr.lower_index
                ]
                    =
                    conflict_table_count_by_way_by_set
                    [1]
                    [
                        dbus0_req_conflict_block_addr.upper_index
                        ^
                        dbus0_req_conflict_block_addr.lower_index
                    ]
                    + 1
                ;

                // deQ dbus0 req Q
                    // invalidate head
                    // increment head
                next_dbus0_req_Q[dbus0_req_Q_head_ptr.index].valid = 1'b0;
                next_dbus0_req_Q_head_ptr = dbus0_req_Q_head_ptr + 1;
            end
        end

        // otherwise, check for deQ of invalidated entry -> head invalid, Q not empty -> head != tail
        else if (dbus0_req_Q_head_ptr != dbus0_req_Q_tail_ptr) begin

            // deQ dbus0 req Q
                // increment head
            next_dbus0_req_Q_head_ptr = dbus0_req_Q_head_ptr + 1;
        end

        // check for dbus1 req deQ
        dbus1_req_conflict = 1'b0;
        if (dbus1_req_Q[dbus1_req_Q_head_ptr.index].valid) begin

            // check conflict table:
                // this time read from next conflict table to get dbus0's updates
            
            // check both ways != 0
            if (
                (
                    next_conflict_table_count_by_way_by_set
                    [0]
                    [dbus1_req_conflict_block_addr.lower_index]
                    !=
                    '0
                )
                &
                (
                    next_conflict_table_count_by_way_by_set
                    [1]
                    [
                        dbus1_req_conflict_block_addr.upper_index
                        ^
                        dbus1_req_conflict_block_addr.lower_index
                    ]
                    !=
                    '0
                )
            ) begin
                dbus1_req_conflict = 1'b1;
            end

            // check either way == MAX
            if (
                (
                    next_conflict_table_count_by_way_by_set
                    [0]
                    [dbus1_req_conflict_block_addr.lower_index]
                    ==
                    '1
                )
                |
                (
                    next_conflict_table_count_by_way_by_set
                    [1]
                    [
                        dbus1_req_conflict_block_addr.upper_index
                        ^
                        dbus1_req_conflict_block_addr.lower_index
                    ]
                    ==
                    '1
                )
            ) begin
                dbus1_req_conflict = 1'b1;
            end

            // send snoop req if no conflict
            if (~dbus1_req_conflict) begin

                // snoop req 1->0
                next_snoop0_req_valid = 1'b1;
                next_snoop0_req_block_addr = dbus1_req_Q[dbus1_req_Q_head_ptr.index].block_addr;
                next_snoop0_req_exclusive = dbus1_req_Q[dbus1_req_Q_head_ptr.index].exclusive;
                next_snoop0_req_curr_state = dbus1_req_Q[dbus1_req_Q_head_ptr.index].curr_state;

                // increment way 0 count
                next_conflict_table_count_by_way_by_set
                [0]
                [dbus1_req_conflict_block_addr.lower_index]
                =
                    next_conflict_table_count_by_way_by_set
                    [0]
                    [dbus1_req_conflict_block_addr.lower_index]
                    + 1
                ;

                // increment way 1 count
                next_conflict_table_count_by_way_by_set
                [1]
                [
                    dbus1_req_conflict_block_addr.upper_index
                    ^
                    dbus1_req_conflict_block_addr.lower_index
                ]
                    =
                    next_conflict_table_count_by_way_by_set
                    [1]
                    [
                        dbus1_req_conflict_block_addr.upper_index
                        ^
                        dbus1_req_conflict_block_addr.lower_index
                    ]
                    + 1
                ;

                // deQ dbus1 req Q
                    // invalidate head
                    // increment head
                next_dbus1_req_Q[dbus1_req_Q_head_ptr.index].valid = 1'b0;
                next_dbus1_req_Q_head_ptr = dbus1_req_Q_head_ptr + 1;
            end
        end

        // otherwise, check for deQ of invalidated entry -> head invalid, Q not empty -> head != tail
        else if (dbus1_req_Q_head_ptr != dbus1_req_Q_tail_ptr) begin

            // deQ dbus0 req Q
                // increment head
            next_dbus1_req_Q_head_ptr = dbus1_req_Q_head_ptr + 1;
        end

        // check for dbus0 resp conflict table free
        if (dbus0_resp_valid) begin

            // decrement way 0
            next_conflict_table_count_by_way_by_set
            [0]
            [dbus0_resp_conflict_block_addr.lower_index]
            =
                next_conflict_table_count_by_way_by_set
                [0]
                [dbus0_resp_conflict_block_addr.lower_index]
                - 1
            ;

            // decrement way 1
            next_conflict_table_count_by_way_by_set
            [1]
            [
                dbus0_resp_conflict_block_addr.upper_index
                ^
                dbus0_resp_conflict_block_addr.lower_index
            ]
            =
                next_conflict_table_count_by_way_by_set
                [1]
                [
                    dbus0_resp_conflict_block_addr.upper_index
                    ^
                    dbus0_resp_conflict_block_addr.lower_index
                ]
                - 1
            ;
        end

        // check for dbus1 resp conflict table free
        if (dbus1_resp_valid) begin

            // decrement way 0
            next_conflict_table_count_by_way_by_set
            [0]
            [dbus1_resp_conflict_block_addr.lower_index]
            =
                next_conflict_table_count_by_way_by_set
                [0]
                [dbus1_resp_conflict_block_addr.lower_index]
                - 1
            ;

            // decrement way 1
            next_conflict_table_count_by_way_by_set
            [1]
            [
                dbus1_resp_conflict_block_addr.upper_index
                ^
                dbus1_resp_conflict_block_addr.lower_index
            ]
            =
                next_conflict_table_count_by_way_by_set
                [1]
                [
                    dbus1_resp_conflict_block_addr.upper_index
                    ^
                    dbus1_resp_conflict_block_addr.lower_index
                ]
                - 1
            ;
        end

        // check dbus0 req Q tail surpasses head
            // next tail msb != next head msb
            // next tail index == next head index + 1
        if (
            next_dbus0_req_Q_tail_ptr.msb != next_dbus0_req_Q_head_ptr.msb
            &
            next_dbus0_req_Q_tail_ptr.index != next_dbus0_req_Q_head_ptr.index + 1
        ) begin
            $display("bus_controller: ERROR: dbus0 req Q tail surpasses head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end

        // check dbus1 req Q tail surpasses head
            // next tail msb != next head msb
            // next tail index == next head index + 1
        if (
            next_dbus1_req_Q_tail_ptr.msb != next_dbus1_req_Q_head_ptr.msb
            &
            next_dbus1_req_Q_tail_ptr.index != next_dbus1_req_Q_head_ptr.index + 1
        ) begin
            $display("bus_controller: ERROR: dbus1 req Q tail surpasses head");
            $display("\t@: %0t",$realtime);
            next_DUT_error = 1'b1;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // snoop response logic + dbus resp logic + dmem read resp Q:

    // dmem read resp Q's:
    typedef struct packed {
        logic valid;
        logic returned;
        block_addr_t block_addr;
        word_t [1:0] data;
        MOESI_state_t new_state;
    } dmem_read_resp_Q_entry_t;

    // dmem0 read resp Q
    dmem_read_resp_Q_entry_t [BUS_CONTROLLER_DMEM_READ_RESP_Q_DEPTH-1:0] dmem0_read_resp_Q;
    dmem_read_resp_Q_entry_t [BUS_CONTROLLER_DMEM_READ_RESP_Q_DEPTH-1:0] next_dmem0_read_resp_Q;

    // dmem1 read resp Q
    dmem_read_resp_Q_entry_t [BUS_CONTROLLER_DMEM_READ_RESP_Q_DEPTH-1:0] dmem1_read_resp_Q;
    dmem_read_resp_Q_entry_t [BUS_CONTROLLER_DMEM_READ_RESP_Q_DEPTH-1:0] next_dmem1_read_resp_Q;

    // dmem read resp Q ptr's:
    typedef struct packed {
        logic msb;
        logic [BUS_CONTROLLER_LOG_DMEM_READ_RESP_Q_DEPTH-1:0] index;
    } dmem_read_resp_Q_ptr_t;

    // dmem0 read resp Q ptr's
    dmem_read_resp_Q_ptr_t dmem0_read_resp_Q_head_ptr;
    dmem_read_resp_Q_ptr_t next_dmem0_read_resp_Q_head_ptr;
    dmem_read_resp_Q_ptr_t dmem0_read_resp_Q_tail_ptr;
    dmem_read_resp_Q_ptr_t next_dmem0_read_resp_Q_tail_ptr;

    // dmem1 read resp Q ptr's
    dmem_read_resp_Q_ptr_t dmem1_read_resp_Q_head_ptr;
    dmem_read_resp_Q_ptr_t next_dmem1_read_resp_Q_head_ptr;
    dmem_read_resp_Q_ptr_t dmem1_read_resp_Q_tail_ptr;
    dmem_read_resp_Q_ptr_t next_dmem1_read_resp_Q_tail_ptr;

    // latched snoop0 resp
    logic snoop0_resp_reg_ready_now;
    logic next_snoop0_resp_reg_ready_now;
    logic snoop0_resp_reg_need_mem;
    logic next_snoop0_resp_reg_need_mem;
    block_addr_t snoop0_resp_reg_block_addr;
    block_addr_t next_snoop0_resp_reg_block_addr;
    word_t [1:0] snoop0_resp_reg_data;
    word_t [1:0] next_snoop0_resp_reg_data;
    logic snoop0_resp_reg_need_block;
    logic next_snoop0_resp_reg_need_block;
    MOESI_state_t snoop0_resp_reg_new_state;
    MOESI_state_t next_snoop0_resp_reg_new_state;

    // latched snoop1 resp
    logic snoop1_resp_reg_ready_now;
    logic next_snoop1_resp_reg_ready_now;
    logic snoop1_resp_reg_need_mem;
    logic next_snoop1_resp_reg_need_mem;
    block_addr_t snoop1_resp_reg_block_addr;
    block_addr_t next_snoop1_resp_reg_block_addr;
    word_t [1:0] snoop1_resp_reg_data;
    word_t [1:0] next_snoop1_resp_reg_data;
    logic snoop1_resp_reg_need_block;
    logic next_snoop1_resp_reg_need_block;
    MOESI_state_t snoop1_resp_reg_new_state;
    MOESI_state_t next_snoop1_resp_reg_new_state;

    // seq:
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            dmem0_read_resp_Q <= '0;
            dmem1_read_resp_Q <= '0;

            dmem0_read_resp_Q_head_ptr <= '0;
            dmem0_read_resp_Q_tail_ptr <= '0;
            dmem1_read_resp_Q_head_ptr <= '0;
            dmem1_read_resp_Q_tail_ptr <= '0;

            snoop0_resp_reg_ready_now <= 1'b0;
            snoop0_resp_reg_need_mem <= 1'b0;
            snoop0_resp_reg_block_addr <= 13'h0;
            snoop0_resp_reg_data <= {32'h0, 32'h0};
            snoop0_resp_reg_need_block <= 1'b0;
            snoop0_resp_reg_new_state <= MOESI_I;

            snoop1_resp_reg_ready_now <= 1'b0;
            snoop1_resp_reg_need_mem <= 1'b0;
            snoop1_resp_reg_block_addr <= 13'h0;
            snoop1_resp_reg_data <= {32'h0, 32'h0};
            snoop1_resp_reg_need_block <= 1'b0;
            snoop1_resp_reg_new_state <= MOESI_I;
        end
        else begin
            dmem0_read_resp_Q <= next_dmem0_read_resp_Q;
            dmem1_read_resp_Q <= next_dmem1_read_resp_Q;

            dmem0_read_resp_Q_head_ptr <= next_dmem0_read_resp_Q_head_ptr;
            dmem0_read_resp_Q_tail_ptr <= next_dmem0_read_resp_Q_tail_ptr;
            dmem1_read_resp_Q_head_ptr <= next_dmem1_read_resp_Q_head_ptr;
            dmem1_read_resp_Q_tail_ptr <= next_dmem1_read_resp_Q_tail_ptr;

            snoop0_resp_reg_ready_now <= next_snoop0_resp_reg_ready_now;
            snoop0_resp_reg_need_mem <= next_snoop0_resp_reg_need_mem;
            snoop0_resp_reg_block_addr <= next_snoop0_resp_reg_block_addr;
            snoop0_resp_reg_data <= next_snoop0_resp_reg_data;
            snoop0_resp_reg_need_block <= next_snoop0_resp_reg_need_block;
            snoop0_resp_reg_new_state <= next_snoop0_resp_reg_new_state;

            snoop1_resp_reg_ready_now <= next_snoop1_resp_reg_ready_now;
            snoop1_resp_reg_need_mem <= next_snoop1_resp_reg_need_mem;
            snoop1_resp_reg_block_addr <= next_snoop1_resp_reg_block_addr;
            snoop1_resp_reg_data <= next_snoop1_resp_reg_data;
            snoop1_resp_reg_need_block <= next_snoop1_resp_reg_need_block;
            snoop1_resp_reg_new_state <= next_snoop1_resp_reg_new_state;
        end
    end

    // comb logic:
    always_comb begin

        //////////////////////
        // default outputs: //
        //////////////////////

        // dbus0 resp:
            // invalid from snoop1 resp reg
        dbus0_resp_valid = 1'b0;
        dbus0_resp_block_addr = snoop1_resp_reg_block_addr;
        dbus0_resp_
    end

endmodule