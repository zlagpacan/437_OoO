/*
Eric Villasenor
evillase@gmail.com

system top block wraps processor(datapath+cache)
and memory (ram).
*/

// system interface
`include "system_if.vh"

// types
// `include "cpu_types_pkg.vh"
// import cpu_types_pkg::*;
	// use mine instead

`include "core_types.vh"
import core_types_pkg::*;

`include "mem_types.vh"
import mem_types_pkg::*;

module system (input logic CLK, nRST, system_if.sys syif);

	// stopped running
	logic halt;

	// clock division
	parameter CLKDIV = 2;
	logic CPUCLK;
	logic [3:0] count;
	//logic CPUnRST;

	always_ff @(posedge CLK, negedge nRST)
	begin
		if (!nRST)
		begin
		count <= 0;
		CPUCLK <= 0;
		end
		else if (count == CLKDIV-2)
		begin
		count <= 0;
		CPUCLK <= ~CPUCLK;
		end
		else
		begin
		count <= count + 1;
		end
	end

	// CPU-RAM interface
	cpu_ram_if                            prif ();
		// // ram signals
		// logic               ramREN, ramWEN;
		// word_t              ramaddr, ramstore, ramload;
		// ramstate_t          ramstate;

		// // cpu signals
		// logic               memREN, memWEN;
		// word_t              memaddr, memstore;

		// // cpu ports
		// modport cpu (
		//   input   ramstate, ramload,
		//   output  memaddr, memREN, memWEN, memstore
		// );

		// // ram ports
		// modport ram (
		//   input   ramaddr, ramstore, ramREN, ramWEN,
		//   output  ramstate, ramload
		// );

		// // unused and may change
		// modport sdram (
		//   input   ramaddr, ramstore, ramREN, ramWEN,
		//   output  ramstate, ramload
		// );

	// memory
	ram RAM (CLK, nRST, prif);

	// ///////////////////////////////////////////////////////////////////////////////////////////////////////
	// // unicore, no caches hack: 
	// 	// basically, immediately do all transactions
	// 		// d$ resp next cycle after req
	// 			// can assume everything will be fine if LAT = 0
	// 			// can block writes if there is a read
	// 	// no need to support anything fancy
	// 		// kill bus
	// 		// invalidations

	// logic DUT_error;
	
	// // i$ interface
	// logic icache_hit;
	// word_t icache_load;
	// logic icache_REN;
	// word_t icache_addr;
	// logic icache_halt; // can use for official halt

	// // d$ interface
	// logic dcache_read_req_valid;
	// LQ_index_t dcache_read_req_LQ_index;
	// daddr_t dcache_read_req_addr;

	// logic dcache_read_resp_valid;
	// LQ_index_t dcache_read_resp_LQ_index;
	// word_t dcache_read_resp_data;

	// logic dcache_write_req_valid;
	// daddr_t dcache_write_req_addr;
	// word_t dcache_write_req_data;
	// logic dcache_write_req_blocked;

	// // need write buffer to make sure write req's don't disappear if read req at same time
	// typedef struct packed {
	// 	logic valid;
	// 	daddr_t addr;
	// 	word_t data;
	// } write_buffer_t;

	// write_buffer_t [3:0] write_buffer, next_write_buffer;
	// logic [2:0] write_buffer_head, next_write_buffer_head;
	// logic [2:0] write_buffer_tail, next_write_buffer_tail; 

	// // write buffer CAM value
	// logic write_buffer_CAM_found;
	// word_t write_buffer_CAM_data;

	// word_t next_dcache_read_resp_data;

	// core CORE0 (
	// 	.CLK(CPUCLK),
	// 	.nRST(nRST),

	// 	.DUT_error(DUT_error),

	// 	.icache_hit(icache_hit),
	// 	.icache_load(icache_load),
	// 	.icache_REN(icache_REN),
	// 	.icache_addr(icache_addr),
	// 	.icache_halt(icache_halt),
		
	// 	.dcache_read_req_valid(dcache_read_req_valid),
	// 	.dcache_read_req_LQ_index(dcache_read_req_LQ_index),
	// 	.dcache_read_req_addr(dcache_read_req_addr),
	// 	.dcache_read_req_blocked(1'b0),

	// 	.dcache_read_resp_valid(dcache_read_resp_valid),
	// 	.dcache_read_resp_LQ_index(dcache_read_resp_LQ_index),
	// 	.dcache_read_resp_data(dcache_read_resp_data),

	// 	.dcache_write_req_valid(dcache_write_req_valid),
	// 	.dcache_write_req_addr(dcache_write_req_addr),
	// 	.dcache_write_req_data(dcache_write_req_data),
	// 	.dcache_write_req_blocked(dcache_write_req_blocked),

	// 	.dcache_inv_valid(1'b0),

	// 	.dcache_inv_block_addr(13'h0)
	// );

	// // hack mem interface

	// always_ff @ (posedge CPUCLK, negedge nRST) begin
	// 	if (~nRST) begin

	// 		// immediate d$ read req resp
	// 		dcache_read_resp_valid <= 1'b0;
	// 		dcache_read_resp_LQ_index <= LQ_index_t'(0);
	// 		dcache_read_resp_data <= 32'h0;

	// 		// write buffer
	// 		write_buffer <= '0;
	// 		write_buffer_head <= 3'h0;
	// 		write_buffer_tail <= 3'h0;
	// 	end
	// 	else begin

	// 		// immediate d$ read req resp
	// 		dcache_read_resp_valid <= dcache_read_req_valid;
	// 		dcache_read_resp_LQ_index <= dcache_read_req_LQ_index;
	// 		dcache_read_resp_data <= next_dcache_read_resp_data;

	// 		// write buffer
	// 		write_buffer <= next_write_buffer;
	// 		write_buffer_head <= next_write_buffer_head;
	// 		write_buffer_tail <= next_write_buffer_tail;
	// 	end
	// end

	// always_comb begin
	// 	halt = icache_halt;

	// 	// defaults:

	// 	// ram interface
	// 	prif.memaddr = 32'h0;
	// 	prif.memREN = 1'b0;
	// 	prif.memWEN = 1'b0;
	// 	prif.memstore = write_buffer[write_buffer_head[1:0]].data;

	// 	// i$ interface
	// 	icache_hit = 1'b0;
	// 	icache_load = prif.ramload;

	// 	// d$ interface
	// 	dcache_write_req_blocked = 1'b0;

	// 	// write buffer
	// 	next_write_buffer = write_buffer;
	// 	next_write_buffer_head = write_buffer_head;
	// 	next_write_buffer_tail = write_buffer_tail;
	// 	write_buffer_CAM_data = 32'h0;
	// 	write_buffer_CAM_found = 1'b0;
	// 	next_dcache_read_resp_data = 32'h0;
		
	// 	// priority:
	// 		// d$ read req
	// 			// if write req, block it
	// 		// d$ write req
	// 		// i$ read req
	// 	if (dcache_read_req_valid) begin

	// 		// CAM search write buffer
	// 		for (int i = 0; i < 4; i++) begin

	// 			if (
	// 				write_buffer[i].valid & 
	// 				write_buffer[i].addr == dcache_read_req_addr
	// 			) begin
	// 				write_buffer_CAM_found = 1'b1;
	// 				write_buffer_CAM_data = write_buffer[i].data;
	// 			end
	// 		end

	// 		if (write_buffer_CAM_found) begin
	// 			next_dcache_read_resp_data = write_buffer_CAM_data;
	// 		end	
	// 		else begin
	// 			// service d$ read req with RAM
	// 			prif.memaddr = {16'h0, dcache_read_req_addr, 2'b00};
	// 			prif.memREN = 1'b1;
	// 			next_dcache_read_resp_data = prif.ramload;
	// 		end
	// 	end
	// 	// else if (dcache_write_req_valid) begin

	// 	// 	// service d$ write req
	// 	// 	prif.memaddr = {16'h0, dcache_write_req_addr, 2'b00};
	// 	// 	prif.memWEN = 1'b1;
	// 	// end
	// 	else if (write_buffer[write_buffer_head[1:0]].valid) begin

	// 		// send write to RAM
	// 		prif.memaddr = {16'h0, write_buffer[write_buffer_head[1:0]].addr, 2'b00};
	// 		prif.memWEN = 1'b1;

	// 		// deQ write buffer
	// 		next_write_buffer_head = write_buffer_head + 1;
	// 		next_write_buffer[write_buffer_head[1:0]].valid = 1'b0;
	// 	end
	// 	else if (icache_REN) begin

	// 		// service i$ read req
	// 		prif.memaddr = icache_addr;
	// 		prif.memREN = 1'b1;

	// 		// give hit
	// 		icache_hit = 1'b1;
	// 	end

	// 	// write buffer enQ
	// 	if (dcache_write_req_valid) begin
	// 		next_write_buffer[write_buffer_tail[1:0]].valid = 1'b1;
	// 		next_write_buffer[write_buffer_tail[1:0]].addr = dcache_write_req_addr;
	// 		next_write_buffer[write_buffer_tail[1:0]].data = dcache_write_req_data;

	// 		next_write_buffer_tail = write_buffer_tail + 1;
	// 	end

	// 	// write buffer full
	// 	if (
	// 		next_write_buffer_head[1:0] == next_write_buffer_tail[1:0]
	// 		&
	// 		next_write_buffer_head[2] != next_write_buffer_tail[2]
	// 	) begin
	// 		dcache_write_req_blocked = 1'b1;
	// 	end
	// end

	// // system interface connections
	// // assign syif.halt = halt;
	// assign syif.halt = 
	// 	halt &
	// 	~write_buffer[0].valid &
	// 	~write_buffer[1].valid &
	// 	~write_buffer[2].valid &
	// 	~write_buffer[3].valid
	// ;
	// 	// clear write buffer before finish halt

	// ///////////////////////////////////////////////////////////////////////////////////////////////////////

	// ///////////////////////////////////////////////////////////////////////////////////////////////////////
	// // unicore with caches + mem controller

	// // DUT error's
	// logic core_DUT_error;
	// logic icache_DUT_error;
	// logic dcache_DUT_error;
	// logic mem_controller_DUT_error;
	
	// // core <-> i$ interface:
	// logic icache_hit;
	// word_t icache_load;
	// logic icache_REN;
	// word_t icache_addr;
	// logic icache_halt;

	// // core <-> d$ interface:

	// // read req interface
	// logic dcache_read_req_valid;
	// LQ_index_t dcache_read_req_LQ_index;
	// daddr_t dcache_read_req_addr;
	// logic dcache_read_req_linked;
	// logic dcache_read_req_conditional;
	// logic dcache_read_req_blocked;

	// // read resp interface
	// logic dcache_read_resp_valid;
	// LQ_index_t dcache_read_resp_LQ_index;
	// word_t dcache_read_resp_data;

	// // write req interface
	// logic dcache_write_req_valid;
	// daddr_t dcache_write_req_addr;
	// word_t dcache_write_req_data;
	// logic dcache_write_req_conditional;
	// logic dcache_write_req_blocked;

	// // read kill interface x2:
    // logic dcache_read_kill_0_valid;
    // LQ_index_t dcache_read_kill_0_LQ_index;
    // logic dcache_read_kill_1_valid;
    // LQ_index_t dcache_read_kill_1_LQ_index;

    // // invalidation interface:
    // logic dcache_inv_valid;
    // block_addr_t dcache_inv_block_addr;

    // // halt interface:
   	// logic dcache_halt;

	// // i$ <-> mem controller interface:
	// logic imem_REN;
    // block_addr_t imem_block_addr;
    // logic imem_hit;
    // word_t [1:0] imem_load;

	// // d$ <-> mem controller interface:

	// // dmem read req:
    // logic dmem_read_req_valid;
    // block_addr_t dmem_read_req_block_addr;

    // // dmem read resp:
    // logic dmem_read_resp_valid;
    // block_addr_t dmem_read_resp_block_addr;
    // word_t [1:0] dmem_read_resp_data;

    // // dmem write req:
    // logic dmem_write_req_valid;
    // block_addr_t dmem_write_req_block_addr;
    // word_t [1:0] dmem_write_req_data;
	// logic dmem_write_req_slow_down;

	// // flushed:
	// logic dcache_flushed;
	// logic mem_controller_flushed;

	// // core
	// core CORE0 (
	// 	.CLK(CPUCLK),
	// 	.nRST(nRST),

	// 	.DUT_error(core_DUT_error),

	// 	.icache_hit(icache_hit),
	// 	.icache_load(icache_load),
	// 	.icache_REN(icache_REN),
	// 	.icache_addr(icache_addr),
	// 	.icache_halt(icache_halt),
		
	// 	.dcache_read_req_valid(dcache_read_req_valid),
	// 	.dcache_read_req_LQ_index(dcache_read_req_LQ_index),
	// 	.dcache_read_req_addr(dcache_read_req_addr),
	// 	.dcache_read_req_linked(dcache_read_req_linked),
	// 	.dcache_read_req_conditional(dcache_read_req_conditional),
	// 	.dcache_read_req_blocked(dcache_read_req_blocked),

	// 	.dcache_read_resp_valid(dcache_read_resp_valid),
	// 	.dcache_read_resp_LQ_index(dcache_read_resp_LQ_index),
	// 	.dcache_read_resp_data(dcache_read_resp_data),

	// 	.dcache_write_req_valid(dcache_write_req_valid),
	// 	.dcache_write_req_addr(dcache_write_req_addr),
	// 	.dcache_write_req_data(dcache_write_req_data),
	// 	.dcache_write_req_conditional(dcache_write_req_conditional),
	// 	.dcache_write_req_blocked(dcache_write_req_blocked),

	// 	.dcache_read_kill_0_valid(dcache_read_kill_0_valid),
	// 	.dcache_read_kill_0_LQ_index(dcache_read_kill_0_LQ_index),
	// 	.dcache_read_kill_1_valid(dcache_read_kill_1_valid),
	// 	.dcache_read_kill_1_LQ_index(dcache_read_kill_1_LQ_index),

	// 	.dcache_inv_valid(dcache_inv_valid),
	// 	.dcache_inv_block_addr(dcache_inv_block_addr),

	// 	.dcache_halt(dcache_halt)
	// );

	// // icache
	// icache ICACHE0 (
	// 	.CLK(CPUCLK),
	// 	.nRST(nRST),

	// 	.DUT_error(icache_DUT_error),

	// 	.icache_REN(icache_REN),
	// 	.icache_addr(icache_addr),
	// 	.icache_halt(icache_halt),
	// 	.icache_hit(icache_hit),
	// 	.icache_load(icache_load),

	// 	.imem_REN(imem_REN),
	// 	.imem_block_addr(imem_block_addr),
	// 	.imem_hit(imem_hit),
	// 	.imem_load(imem_load)
	// );

	// // dcache
	// dcache DCACHE0 (
	// 	.CLK(CPUCLK),
	// 	.nRST(nRST),

	// 	.DUT_error(dcache_DUT_error),

	// 	.dcache_read_req_valid(dcache_read_req_valid),
	// 	.dcache_read_req_LQ_index(dcache_read_req_LQ_index),
	// 	.dcache_read_req_addr(dcache_read_req_addr),
	// 	.dcache_read_req_linked(dcache_read_req_linked),
	// 	.dcache_read_req_conditional(dcache_read_req_conditional),
	// 	.dcache_read_req_blocked(dcache_read_req_blocked),

	// 	.dcache_read_resp_valid(dcache_read_resp_valid),
	// 	.dcache_read_resp_LQ_index(dcache_read_resp_LQ_index),
	// 	.dcache_read_resp_data(dcache_read_resp_data),

	// 	.dcache_write_req_valid(dcache_write_req_valid),
	// 	.dcache_write_req_addr(dcache_write_req_addr),
	// 	.dcache_write_req_data(dcache_write_req_data),
	// 	.dcache_write_req_conditional(dcache_write_req_conditional),
	// 	.dcache_write_req_blocked(dcache_write_req_blocked),

	// 	.dcache_read_kill_0_valid(dcache_read_kill_0_valid),
	// 	.dcache_read_kill_0_LQ_index(dcache_read_kill_0_LQ_index),
	// 	.dcache_read_kill_1_valid(dcache_read_kill_1_valid),
	// 	.dcache_read_kill_1_LQ_index(dcache_read_kill_1_LQ_index),

	// 	.dcache_inv_valid(dcache_inv_valid),
	// 	.dcache_inv_block_addr(dcache_inv_block_addr),

	// 	.dcache_halt(dcache_halt),

	// 	.dmem_read_req_valid(dmem_read_req_valid),
	// 	.dmem_read_req_block_addr(dmem_read_req_block_addr),

	// 	.dmem_read_resp_valid(dmem_read_resp_valid),
	// 	.dmem_read_resp_block_addr(dmem_read_resp_block_addr),
	// 	.dmem_read_resp_data(dmem_read_resp_data),
		
	// 	.dmem_write_req_valid(dmem_write_req_valid),
	// 	.dmem_write_req_block_addr(dmem_write_req_block_addr),
	// 	.dmem_write_req_data(dmem_write_req_data),
	// 	.dmem_write_req_slow_down(dmem_write_req_slow_down),

	// 	.flushed(dcache_flushed)
	// );

	// // mem controller
	// mem_controller MEM_CONTROLLER (
	// 	.CLK(CPUCLK),
	// 	.nRST(nRST),

	// 	.DUT_error(mem_controller_DUT_error),

	// 	.prif(prif),

	// 	.imem_REN(imem_REN),
	// 	.imem_block_addr(imem_block_addr),
	// 	.imem_hit(imem_hit),
	// 	.imem_load(imem_load),

	// 	.dmem_read_req_valid(dmem_read_req_valid),
	// 	.dmem_read_req_block_addr(dmem_read_req_block_addr),

	// 	.dmem_read_resp_valid(dmem_read_resp_valid),
	// 	.dmem_read_resp_block_addr(dmem_read_resp_block_addr),
	// 	.dmem_read_resp_data(dmem_read_resp_data),
		
	// 	.dmem_write_req_valid(dmem_write_req_valid),
	// 	.dmem_write_req_block_addr(dmem_write_req_block_addr),
	// 	.dmem_write_req_data(dmem_write_req_data),
	// 	.dmem_write_req_slow_down(dmem_write_req_slow_down),

	// 	.dcache_flushed(dcache_flushed),
	// 	.mem_controller_flushed(mem_controller_flushed)
	// );

	// // system interface connections
	// assign syif.halt = mem_controller_flushed;

	// ///////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// multicore:
		// 2 cores
		// 2 icaches
		// 2 snoop dcaches
		// bus controller
		// dual mem controller

	// DUT error's:
	logic core0_DUT_error;
	logic icache0_DUT_error;
	logic snoop_dcache0_DUT_error;

	logic core1_DUT_error;
	logic icache1_DUT_error;
	logic snoop_dcache1_DUT_error;

	logic bus_controller_DUT_error;
	logic dual_mem_controller_DUT_error;

	// core <-> i$ interfaces:
	logic icache0_hit;
	word_t icache0_load;
	logic icache0_REN;
	word_t icache0_addr;
	logic icache0_halt;

	logic icache1_hit;
	word_t icache1_load;
	logic icache1_REN;
	word_t icache1_addr;
	logic icache1_halt;

	// core <-> d$ interfaces:

	// read req interface
	logic dcache0_read_req_valid;
	LQ_index_t dcache0_read_req_LQ_index;
	daddr_t dcache0_read_req_addr;
	logic dcache0_read_req_linked;
	logic dcache0_read_req_conditional;
	logic dcache0_read_req_blocked;

	logic dcache1_read_req_valid;
	LQ_index_t dcache1_read_req_LQ_index;
	daddr_t dcache1_read_req_addr;
	logic dcache1_read_req_linked;
	logic dcache1_read_req_conditional;
	logic dcache1_read_req_blocked;

	// read resp interface
	logic dcache0_read_resp_valid;
	LQ_index_t dcache0_read_resp_LQ_index;
	word_t dcache0_read_resp_data;

	logic dcache1_read_resp_valid;
	LQ_index_t dcache1_read_resp_LQ_index;
	word_t dcache1_read_resp_data;

	// write req interface
	logic dcache0_write_req_valid;
	daddr_t dcache0_write_req_addr;
	word_t dcache0_write_req_data;
	logic dcache0_write_req_conditional;
	logic dcache0_write_req_blocked;

	logic dcache1_write_req_valid;
	daddr_t dcache1_write_req_addr;
	word_t dcache1_write_req_data;
	logic dcache1_write_req_conditional;
	logic dcache1_write_req_blocked;

	// read kill interface x2:
    logic dcache0_read_kill_0_valid;
    LQ_index_t dcache0_read_kill_0_LQ_index;
    logic dcache0_read_kill_1_valid;
    LQ_index_t dcache0_read_kill_1_LQ_index;

    logic dcache1_read_kill_0_valid;
    LQ_index_t dcache1_read_kill_0_LQ_index;
    logic dcache1_read_kill_1_valid;
    LQ_index_t dcache1_read_kill_1_LQ_index;

    // invalidation interface:
    logic dcache0_inv_valid;
    block_addr_t dcache0_inv_block_addr;
	logic dcache0_evict_valid;
    block_addr_t dcache0_evict_block_addr;

    logic dcache1_inv_valid;
    block_addr_t dcache1_inv_block_addr;
	logic dcache1_evict_valid;
    block_addr_t dcache1_evict_block_addr;

    // halt interface:
   	logic dcache0_halt;
   	logic dcache1_halt;

	// imem interfaces:

	// imem0:
	logic imem0_REN;
    block_addr_t imem0_block_addr;
    logic imem0_hit;
    word_t [1:0] imem0_load;

	// imem1:
	logic imem1_REN;
    block_addr_t imem1_block_addr;
    logic imem1_hit;
    word_t [1:0] imem1_load;

	// dbus interfaces:

	// dbus0 req:
	logic dbus0_req_valid;
	block_addr_t dbus0_req_block_addr;
	logic dbus0_req_exclusive;
	MOESI_state_t dbus0_req_curr_state;

    // dbus0 resp:
    logic dbus0_resp_valid;
    block_addr_t dbus0_resp_block_addr;
    word_t [1:0] dbus0_resp_data;
    logic dbus0_resp_need_block;
    MOESI_state_t dbus0_resp_new_state;
    
	// dbus1 req:
    logic dbus1_req_valid;
    block_addr_t dbus1_req_block_addr;
    logic dbus1_req_exclusive;
    MOESI_state_t dbus1_req_curr_state;
    
	// dbus1 resp:
    logic dbus1_resp_valid;
    block_addr_t dbus1_resp_block_addr;
    word_t [1:0] dbus1_resp_data;
    logic dbus1_resp_need_block;
    MOESI_state_t dbus1_resp_new_state;

    // snoop0 req:
    logic snoop0_req_valid;
    block_addr_t snoop0_req_block_addr;
    logic snoop0_req_exclusive;
    MOESI_state_t snoop0_req_curr_state;

    // snoop0 resp:
    logic snoop0_resp_valid;
    block_addr_t snoop0_resp_block_addr;
    word_t [1:0] snoop0_resp_data;
    logic snoop0_resp_present;
    logic snoop0_resp_need_block;
    MOESI_state_t snoop0_resp_new_state;

    // snoop1 req:
    logic snoop1_req_valid;
    block_addr_t snoop1_req_block_addr;
    logic snoop1_req_exclusive;
    MOESI_state_t snoop1_req_curr_state;

    // snoop1 resp:
    logic snoop1_resp_valid;
    block_addr_t snoop1_resp_block_addr;
    word_t [1:0] snoop1_resp_data;
    logic snoop1_resp_present;
    logic snoop1_resp_need_block;
    MOESI_state_t snoop1_resp_new_state;

	// dmem interfaces:

    // dmem0 read req;
    logic dmem0_read_req_valid;
    block_addr_t dmem0_read_req_block_addr;

    // dmem0 read resp:
    logic dmem0_read_resp_valid;
    word_t [1:0] dmem0_read_resp_data;

    // dmem1 read req:
    logic dmem1_read_req_valid;
    block_addr_t dmem1_read_req_block_addr;

    // dmem1 read resp:
    logic dmem1_read_resp_valid;
    word_t [1:0] dmem1_read_resp_data;

    // dmem0 write req:
    logic dmem0_write_req_valid;
    block_addr_t dmem0_write_req_block_addr;
    word_t [1:0] dmem0_write_req_data;
    logic dmem0_write_req_slow_down;

    // dmem1 write req:
    logic dmem1_write_req_valid;
    block_addr_t dmem1_write_req_block_addr;
    word_t [1:0] dmem1_write_req_data;
    logic dmem1_write_req_slow_down;

	// flushed:
    logic snoop_dcache0_flushed;
    logic snoop_dcache1_flushed;
    logic dual_mem_controller_flushed;

	// core0:
	core #(
		.PC_RESET_VAL(16'h0000)
	) CORE0 ( 
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(core0_DUT_error),

		.icache_hit(icache0_hit),
		.icache_load(icache0_load),
		.icache_REN(icache0_REN),
		.icache_addr(icache0_addr),
		.icache_halt(icache0_halt),
		
		.dcache_read_req_valid(dcache0_read_req_valid),
		.dcache_read_req_LQ_index(dcache0_read_req_LQ_index),
		.dcache_read_req_addr(dcache0_read_req_addr),
		.dcache_read_req_linked(dcache0_read_req_linked),
		.dcache_read_req_conditional(dcache0_read_req_conditional),
		.dcache_read_req_blocked(dcache0_read_req_blocked),

		.dcache_read_resp_valid(dcache0_read_resp_valid),
		.dcache_read_resp_LQ_index(dcache0_read_resp_LQ_index),
		.dcache_read_resp_data(dcache0_read_resp_data),

		.dcache_write_req_valid(dcache0_write_req_valid),
		.dcache_write_req_addr(dcache0_write_req_addr),
		.dcache_write_req_data(dcache0_write_req_data),
		.dcache_write_req_conditional(dcache0_write_req_conditional),
		.dcache_write_req_blocked(dcache0_write_req_blocked),

		.dcache_read_kill_0_valid(dcache0_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(dcache0_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(dcache0_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(dcache0_read_kill_1_LQ_index),

		.dcache_inv_valid(dcache0_inv_valid),
		.dcache_inv_block_addr(dcache0_inv_block_addr),

		.dcache_evict_valid(dcache0_evict_valid),
		.dcache_evict_block_addr(dcache0_evict_block_addr),

		.dcache_halt(dcache0_halt)
	);

	// icache0
	icache ICACHE0 (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(icache0_DUT_error),

		.icache_REN(icache0_REN),
		.icache_addr(icache0_addr),
		.icache_halt(icache0_halt),
		.icache_hit(icache0_hit),
		.icache_load(icache0_load),

		.imem_REN(imem0_REN),
		.imem_block_addr(imem0_block_addr),
		.imem_hit(imem0_hit),
		.imem_load(imem0_load)
	);

	// snoop_dcache0
	snoop_dcache SNOOP_DCACHE0 (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(snoop_dcache0_DUT_error),

		.dcache_read_req_valid(dcache0_read_req_valid),
		.dcache_read_req_LQ_index(dcache0_read_req_LQ_index),
		.dcache_read_req_addr(dcache0_read_req_addr),
		.dcache_read_req_linked(dcache0_read_req_linked),
		.dcache_read_req_conditional(dcache0_read_req_conditional),
		.dcache_read_req_blocked(dcache0_read_req_blocked),

		.dcache_read_resp_valid(dcache0_read_resp_valid),
		.dcache_read_resp_LQ_index(dcache0_read_resp_LQ_index),
		.dcache_read_resp_data(dcache0_read_resp_data),

		.dcache_write_req_valid(dcache0_write_req_valid),
		.dcache_write_req_addr(dcache0_write_req_addr),
		.dcache_write_req_data(dcache0_write_req_data),
		.dcache_write_req_conditional(dcache0_write_req_conditional),
		.dcache_write_req_blocked(dcache0_write_req_blocked),

		.dcache_read_kill_0_valid(dcache0_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(dcache0_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(dcache0_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(dcache0_read_kill_1_LQ_index),

		.dcache_inv_valid(dcache0_inv_valid),
		.dcache_inv_block_addr(dcache0_inv_block_addr),

		.dcache_evict_valid(dcache0_evict_valid),
		.dcache_evict_block_addr(dcache0_evict_block_addr),

		.dcache_halt(dcache0_halt),

		.dbus_req_valid(dbus0_req_valid),
		.dbus_req_block_addr(dbus0_req_block_addr),
		.dbus_req_exclusive(dbus0_req_exclusive),
		.dbus_req_curr_state(dbus0_req_curr_state),

		.dbus_resp_valid(dbus0_resp_valid),
		.dbus_resp_block_addr(dbus0_resp_block_addr),
		.dbus_resp_data(dbus0_resp_data),
		.dbus_resp_need_block(dbus0_resp_need_block),
		.dbus_resp_new_state(dbus0_resp_new_state),

		.snoop_req_valid(snoop0_req_valid),
		.snoop_req_block_addr(snoop0_req_block_addr),
		.snoop_req_exclusive(snoop0_req_exclusive),
		.snoop_req_curr_state(snoop0_req_curr_state),

		.snoop_resp_valid(snoop0_resp_valid),
		.snoop_resp_block_addr(snoop0_resp_block_addr),
		.snoop_resp_data(snoop0_resp_data),
		.snoop_resp_present(snoop0_resp_present),
		.snoop_resp_need_block(snoop0_resp_need_block),
		.snoop_resp_new_state(snoop0_resp_new_state),

		.dmem_write_req_valid(dmem0_write_req_valid),
		.dmem_write_req_block_addr(dmem0_write_req_block_addr),
		.dmem_write_req_data(dmem0_write_req_data),
		.dmem_write_req_slow_down(dmem0_write_req_slow_down),

		.flushed(snoop_dcache0_flushed)
	);

	// core1:
	core #(
		.PC_RESET_VAL(16'h0200)
	) CORE1 ( 
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(core1_DUT_error),

		.icache_hit(icache1_hit),
		.icache_load(icache1_load),
		.icache_REN(icache1_REN),
		.icache_addr(icache1_addr),
		.icache_halt(icache1_halt),
		
		.dcache_read_req_valid(dcache1_read_req_valid),
		.dcache_read_req_LQ_index(dcache1_read_req_LQ_index),
		.dcache_read_req_addr(dcache1_read_req_addr),
		.dcache_read_req_linked(dcache1_read_req_linked),
		.dcache_read_req_conditional(dcache1_read_req_conditional),
		.dcache_read_req_blocked(dcache1_read_req_blocked),

		.dcache_read_resp_valid(dcache1_read_resp_valid),
		.dcache_read_resp_LQ_index(dcache1_read_resp_LQ_index),
		.dcache_read_resp_data(dcache1_read_resp_data),

		.dcache_write_req_valid(dcache1_write_req_valid),
		.dcache_write_req_addr(dcache1_write_req_addr),
		.dcache_write_req_data(dcache1_write_req_data),
		.dcache_write_req_conditional(dcache1_write_req_conditional),
		.dcache_write_req_blocked(dcache1_write_req_blocked),

		.dcache_read_kill_0_valid(dcache1_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(dcache1_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(dcache1_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(dcache1_read_kill_1_LQ_index),

		.dcache_inv_valid(dcache1_inv_valid),
		.dcache_inv_block_addr(dcache1_inv_block_addr),

		.dcache_evict_valid(dcache1_evict_valid),
		.dcache_evict_block_addr(dcache1_evict_block_addr),

		.dcache_halt(dcache1_halt)
	);

	// icache1
	icache ICACHE1 (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(icache1_DUT_error),

		.icache_REN(icache1_REN),
		.icache_addr(icache1_addr),
		.icache_halt(icache1_halt),
		.icache_hit(icache1_hit),
		.icache_load(icache1_load),

		.imem_REN(imem1_REN),
		.imem_block_addr(imem1_block_addr),
		.imem_hit(imem1_hit),
		.imem_load(imem1_load)
	);

	// snoop_dcache1
	snoop_dcache SNOOP_DCACHE1 (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(snoop_dcache1_DUT_error),

		.dcache_read_req_valid(dcache1_read_req_valid),
		.dcache_read_req_LQ_index(dcache1_read_req_LQ_index),
		.dcache_read_req_addr(dcache1_read_req_addr),
		.dcache_read_req_linked(dcache1_read_req_linked),
		.dcache_read_req_conditional(dcache1_read_req_conditional),
		.dcache_read_req_blocked(dcache1_read_req_blocked),

		.dcache_read_resp_valid(dcache1_read_resp_valid),
		.dcache_read_resp_LQ_index(dcache1_read_resp_LQ_index),
		.dcache_read_resp_data(dcache1_read_resp_data),

		.dcache_write_req_valid(dcache1_write_req_valid),
		.dcache_write_req_addr(dcache1_write_req_addr),
		.dcache_write_req_data(dcache1_write_req_data),
		.dcache_write_req_conditional(dcache1_write_req_conditional),
		.dcache_write_req_blocked(dcache1_write_req_blocked),

		.dcache_read_kill_0_valid(dcache1_read_kill_0_valid),
		.dcache_read_kill_0_LQ_index(dcache1_read_kill_0_LQ_index),
		.dcache_read_kill_1_valid(dcache1_read_kill_1_valid),
		.dcache_read_kill_1_LQ_index(dcache1_read_kill_1_LQ_index),

		.dcache_inv_valid(dcache1_inv_valid),
		.dcache_inv_block_addr(dcache1_inv_block_addr),

		.dcache_evict_valid(dcache1_evict_valid),
		.dcache_evict_block_addr(dcache1_evict_block_addr),

		.dcache_halt(dcache1_halt),

		.dbus_req_valid(dbus1_req_valid),
		.dbus_req_block_addr(dbus1_req_block_addr),
		.dbus_req_exclusive(dbus1_req_exclusive),
		.dbus_req_curr_state(dbus1_req_curr_state),

		.dbus_resp_valid(dbus1_resp_valid),
		.dbus_resp_block_addr(dbus1_resp_block_addr),
		.dbus_resp_data(dbus1_resp_data),
		.dbus_resp_need_block(dbus1_resp_need_block),
		.dbus_resp_new_state(dbus1_resp_new_state),

		.snoop_req_valid(snoop1_req_valid),
		.snoop_req_block_addr(snoop1_req_block_addr),
		.snoop_req_exclusive(snoop1_req_exclusive),
		.snoop_req_curr_state(snoop1_req_curr_state),

		.snoop_resp_valid(snoop1_resp_valid),
		.snoop_resp_block_addr(snoop1_resp_block_addr),
		.snoop_resp_data(snoop1_resp_data),
		.snoop_resp_present(snoop1_resp_present),
		.snoop_resp_need_block(snoop1_resp_need_block),
		.snoop_resp_new_state(snoop1_resp_new_state),

		.dmem_write_req_valid(dmem1_write_req_valid),
		.dmem_write_req_block_addr(dmem1_write_req_block_addr),
		.dmem_write_req_data(dmem1_write_req_data),
		.dmem_write_req_slow_down(dmem1_write_req_slow_down),

		.flushed(snoop_dcache1_flushed)
	);

	// bus controller
	bus_controller BUS_CONTROLLER (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(bus_controller_DUT_error),

		.dbus0_req_valid(dbus0_req_valid),
		.dbus0_req_block_addr(dbus0_req_block_addr),
		.dbus0_req_exclusive(dbus0_req_exclusive),
		.dbus0_req_curr_state(dbus0_req_curr_state),

		.dbus0_resp_valid(dbus0_resp_valid),
		.dbus0_resp_block_addr(dbus0_resp_block_addr),
		.dbus0_resp_data(dbus0_resp_data),
		.dbus0_resp_need_block(dbus0_resp_need_block),
		.dbus0_resp_new_state(dbus0_resp_new_state),

		.dbus1_req_valid(dbus1_req_valid),
		.dbus1_req_block_addr(dbus1_req_block_addr),
		.dbus1_req_exclusive(dbus1_req_exclusive),
		.dbus1_req_curr_state(dbus1_req_curr_state),

		.dbus1_resp_valid(dbus1_resp_valid),
		.dbus1_resp_block_addr(dbus1_resp_block_addr),
		.dbus1_resp_data(dbus1_resp_data),
		.dbus1_resp_need_block(dbus1_resp_need_block),
		.dbus1_resp_new_state(dbus1_resp_new_state),

		.snoop0_req_valid(snoop0_req_valid),
		.snoop0_req_block_addr(snoop0_req_block_addr),
		.snoop0_req_exclusive(snoop0_req_exclusive),
		.snoop0_req_curr_state(snoop0_req_curr_state),

		.snoop0_resp_valid(snoop0_resp_valid),
		.snoop0_resp_block_addr(snoop0_resp_block_addr),
		.snoop0_resp_data(snoop0_resp_data),
		.snoop0_resp_present(snoop0_resp_present),
		.snoop0_resp_need_block(snoop0_resp_need_block),
		.snoop0_resp_new_state(snoop0_resp_new_state),

		.snoop1_req_valid(snoop1_req_valid),
		.snoop1_req_block_addr(snoop1_req_block_addr),
		.snoop1_req_exclusive(snoop1_req_exclusive),
		.snoop1_req_curr_state(snoop1_req_curr_state),

		.snoop1_resp_valid(snoop1_resp_valid),
		.snoop1_resp_block_addr(snoop1_resp_block_addr),
		.snoop1_resp_data(snoop1_resp_data),
		.snoop1_resp_present(snoop1_resp_present),
		.snoop1_resp_need_block(snoop1_resp_need_block),
		.snoop1_resp_new_state(snoop1_resp_new_state),

		.dmem0_read_req_valid(dmem0_read_req_valid),
		.dmem0_read_req_block_addr(dmem0_read_req_block_addr),

		.dmem0_read_resp_valid(dmem0_read_resp_valid),
		.dmem0_read_resp_data(dmem0_read_resp_data),

		.dmem1_read_req_valid(dmem1_read_req_valid),
		.dmem1_read_req_block_addr(dmem1_read_req_block_addr),

		.dmem1_read_resp_valid(dmem1_read_resp_valid),
		.dmem1_read_resp_data(dmem1_read_resp_data)
	);

	// dual mem controller
	dual_mem_controller DUAL_MEM_CONTROLLER (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(dual_mem_controller_DUT_error),

		.prif(prif),

		.imem0_REN(imem0_REN),
		.imem0_block_addr(imem0_block_addr),
		.imem0_hit(imem0_hit),
		.imem0_load(imem0_load),

		.imem1_REN(imem1_REN),
		.imem1_block_addr(imem1_block_addr),
		.imem1_hit(imem1_hit),
		.imem1_load(imem1_load),

		.dmem0_read_req_valid(dmem0_read_req_valid),
		.dmem0_read_req_block_addr(dmem0_read_req_block_addr),

		.dmem1_read_req_valid(dmem1_read_req_valid),
		.dmem1_read_req_block_addr(dmem1_read_req_block_addr),

		.dmem0_read_resp_valid(dmem0_read_resp_valid),
		.dmem0_read_resp_data(dmem0_read_resp_data),

		.dmem1_read_resp_valid(dmem1_read_resp_valid),
		.dmem1_read_resp_data(dmem1_read_resp_data),

		.dmem0_write_req_valid(dmem0_write_req_valid),
		.dmem0_write_req_block_addr(dmem0_write_req_block_addr),
		.dmem0_write_req_data(dmem0_write_req_data),
		.dmem0_write_req_slow_down(dmem0_write_req_slow_down),

		.dmem1_write_req_valid(dmem1_write_req_valid),
		.dmem1_write_req_block_addr(dmem1_write_req_block_addr),
		.dmem1_write_req_data(dmem1_write_req_data),
		.dmem1_write_req_slow_down(dmem1_write_req_slow_down),

		.dcache0_flushed(snoop_dcache0_flushed),
		.dcache1_flushed(snoop_dcache1_flushed),
		.mem_controller_flushed(dual_mem_controller_flushed)
	);

	// system interface connections
	assign syif.halt = dual_mem_controller_flushed;

	///////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// system tb connections: 

	assign syif.load = prif.ramload;

	// who has ram control
	assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
	assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
	assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
	assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule
