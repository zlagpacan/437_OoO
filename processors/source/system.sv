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

	// need write buffer to make sure write req's don't disappear if read req at same time
	typedef struct packed {
		logic valid;
		daddr_t addr;
		word_t data;
	} write_buffer_t;

	write_buffer_t [3:0] write_buffer, next_write_buffer;
	logic [2:0] write_buffer_head, next_write_buffer_head;
	logic [2:0] write_buffer_tail, next_write_buffer_tail; 

	// write buffer CAM value
	logic write_buffer_CAM_found;
	word_t write_buffer_CAM_data;

	word_t next_dcache_read_resp_data;

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

			// immediate d$ read req resp
			dcache_read_resp_valid <= 1'b0;
			dcache_read_resp_LQ_index <= LQ_index_t'(0);
			dcache_read_resp_data <= 32'h0;

			// write buffer
			write_buffer <= '0;
			write_buffer_head <= 3'h0;
			write_buffer_tail <= 3'h0;
		end
		else begin

			// immediate d$ read req resp
			dcache_read_resp_valid <= dcache_read_req_valid;
			dcache_read_resp_LQ_index <= dcache_read_req_LQ_index;
			dcache_read_resp_data <= next_dcache_read_resp_data;

			// write buffer
			write_buffer <= next_write_buffer;
			write_buffer_head <= next_write_buffer_head;
			write_buffer_tail <= next_write_buffer_tail;
		end
	end

	always_comb begin
		halt = icache_halt;

		// defaults:

		// ram interface
		prif.memaddr = 32'h0;
		prif.memREN = 1'b0;
		prif.memWEN = 1'b0;
		prif.memstore = write_buffer[write_buffer_head[1:0]].data;

		// i$ interface
		icache_hit = 1'b0;
		icache_load = prif.ramload;

		// d$ interface
		dcache_write_req_blocked = 1'b0;

		// write buffer
		next_write_buffer = write_buffer;
		next_write_buffer_head = write_buffer_head;
		next_write_buffer_tail = write_buffer_tail;
		write_buffer_CAM_data = 32'h0;
		write_buffer_CAM_found = 1'b0;
		next_dcache_read_resp_data = 32'h0;
		
		// priority:
			// d$ read req
				// if write req, block it
			// d$ write req
			// i$ read req
		if (dcache_read_req_valid) begin

			// CAM search write buffer
			for (int i = 0; i < 4; i++) begin

				if (
					write_buffer[i].valid & 
					write_buffer[i].addr == dcache_read_req_addr
				) begin
					write_buffer_CAM_found = 1'b1;
					write_buffer_CAM_data = write_buffer[i].data;
				end
			end

			if (write_buffer_CAM_found) begin
				next_dcache_read_resp_data = write_buffer_CAM_data;
			end	
			else begin
				// service d$ read req with RAM
				prif.memaddr = {16'h0, dcache_read_req_addr, 2'b00};
				prif.memREN = 1'b1;
				next_dcache_read_resp_data = prif.ramload;
			end
		end
		// else if (dcache_write_req_valid) begin

		// 	// service d$ write req
		// 	prif.memaddr = {16'h0, dcache_write_req_addr, 2'b00};
		// 	prif.memWEN = 1'b1;
		// end
		else if (write_buffer[write_buffer_head[1:0]].valid) begin

			// send write to RAM
			prif.memaddr = {16'h0, write_buffer[write_buffer_head[1:0]].addr, 2'b00};
			prif.memWEN = 1'b1;

			// deQ write buffer
			next_write_buffer_head = write_buffer_head + 1;
			next_write_buffer[write_buffer_head[1:0]].valid = 1'b0;
		end
		else if (icache_REN) begin

			// service i$ read req
			prif.memaddr = icache_addr;
			prif.memREN = 1'b1;

			// give hit
			icache_hit = 1'b1;
		end

		// write buffer enQ
		if (dcache_write_req_valid) begin
			next_write_buffer[write_buffer_tail[1:0]].valid = 1'b1;
			next_write_buffer[write_buffer_tail[1:0]].addr = dcache_write_req_addr;
			next_write_buffer[write_buffer_tail[1:0]].data = dcache_write_req_data;

			next_write_buffer_tail = write_buffer_tail + 1;
		end

		// write buffer full
		if (
			next_write_buffer_head[1:0] == next_write_buffer_tail[1:0]
			&
			next_write_buffer_head[2] != next_write_buffer_tail[2]
		) begin
			dcache_write_req_blocked = 1'b1;
		end
	end

	///////////////////////////////////////////////////////////////////////////////////////////////////////

	// interface connections
	// assign syif.halt = halt;
	assign syif.halt = 
		halt &
		~write_buffer[0].valid &
		~write_buffer[1].valid &
		~write_buffer[2].valid &
		~write_buffer[3].valid
	;
		// clear write buffer before finish halt
	assign syif.load = prif.ramload;

	// who has ram control
	assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
	assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
	assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
	assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule