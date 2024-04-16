/*
Eric Villasenor
evillase@gmail.com

system top block wraps processor(datapath+cache)
and memory (ram).
*/

// system interface
`include "system_if.vh"

// types
`include "cpu_types_pkg.vh"
`include "core_types.vh"
import core_types_pkg::*;

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

	// cores

	// caches

	// bus

	// memory controller

	// memory
	ram RAM (CLK, nRST, prif);

	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// unicore, no caches hack: 
		// basically, immediately do all transactions
			// d$ resp next cycle after req
				// can assume everything will be fine if LAT = 0
				// can block writes if there is a read
		// no need to support anything fancy
			// kill bus
			// invalidations

	logic DUT_error;
	
	// i$ interface
	logic icache_hit;
	word_t icache_load;
	logic icache_REN;
	word_t icache_addr;
	logic icache_halt; // can use for official halt

	// d$ interface
	logic dcache_read_req_valid;
	LQ_index_t dcache_read_req_LQ_index;
	daddr_t dcache_read_req_addr;

	logic dcache_read_resp_valid;
	LQ_index_t dcache_read_resp_LQ_index;
	word_t dcache_read_resp_data;

	logic dcache_write_req_valid;
	daddr_t dcache_write_req_addr;
	word_t dcache_write_req_data;
	logic dcache_write_req_blocked;

	core CORE0 (
		.CLK(CPUCLK),
		.nRST(nRST),

		.DUT_error(DUT_error),

		.icache_hit(icache_hit),
		.icache_load(icache_load),
		.icache_REN(icache_REN),
		.icache_addr(icache_addr),
		.icache_halt(icache_halt),
		
		.dcache_read_req_valid(dcache_read_req_valid),
		.dcache_read_req_LQ_index(dcache_read_req_LQ_index),
		.dcache_read_req_addr(dcache_read_req_addr),
		.dcache_read_req_blocked(1'b0),

		.dcache_read_resp_valid(dcache_read_resp_valid),
		.dcache_read_resp_LQ_index(dcache_read_resp_LQ_index),
		.dcache_read_resp_data(dcache_read_resp_data),

		.dcache_write_req_valid(dcache_write_req_valid),
		.dcache_write_req_addr(dcache_write_req_addr),
		.dcache_write_req_data(dcache_write_req_data),
		.dcache_write_req_blocked(dcache_write_req_blocked),

		.dcache_inv_valid(1'b0),

		.dcache_inv_block_addr(13'h0)
	);

	// hack mem interface

	always_ff @ (posedge CPUCLK, negedge nRST) begin
		if (~nRST) begin
			dcache_read_resp_valid <= 1'b0;
			dcache_read_resp_LQ_index <= LQ_index_t'(0);
			dcache_read_resp_data <= 32'h0;
		end
		else begin
			dcache_read_resp_valid <= dcache_read_req_valid;
			dcache_read_resp_LQ_index <= dcache_read_req_LQ_index;
			dcache_read_resp_data <= prif.ramload;
		end
	end

	always_comb begin
		halt = icache_halt;

		// defaults:

		// ram interface
		prif.memaddr = 32'h0;
		prif.memREN = 1'b0;
		prif.memWEN = 1'b0;
		prif.memstore = dcache_write_req_data;

		// i$ interface
		icache_hit = 1'b0;
		icache_load = prif.ramload;

		// d$ interface
		dcache_write_req_blocked = 1'b0;
		
		// priority:
			// d$ read req
				// if write req, block it
			// d$ write req
			// i$ read req
		if (dcache_read_req_valid) begin

			// service d$ read req
			prif.memaddr = {16'h0, dcache_read_req_addr, 2'b00};
			prif.memREN = 1'b1;

			// if write req, block it
			if (dcache_write_req_valid) begin
				dcache_write_req_blocked = 1'b1;
			end
		end
		else if (dcache_write_req_valid) begin

			// service d$ write req
			prif.memaddr = {16'h0, dcache_write_req_addr, 2'b00};
			prif.memWEN = 1'b1;
		end
		else if (icache_REN) begin

			// service i$ read req
			prif.memaddr = icache_addr;
			prif.memREN = 1'b1;

			// give hit
			icache_hit = 1'b1;
		end
	end

	///////////////////////////////////////////////////////////////////////////////////////////////////////

	// interface connections
	assign syif.halt = halt;
	assign syif.load = prif.ramload;

	// who has ram control
	assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
	assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
	assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
	assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule
