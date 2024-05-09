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
            - dbus req Q's + conflict table + grant logic
                - includes snooping of snoop resp's
                - includes snoop req generation, put into FF to be output next cycle
            - snoop response logic + dbus resp logic + dmem read resp Q
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

    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // snoop response logic + dbus resp logic + dmem read resp Q:



endmodule