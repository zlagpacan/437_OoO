/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
	// sequential (not actually, but get signals anyway)
	input CLK, nRST,

	// interface
	cache_control_if.cc ccif
	// // arbitration
	// logic   [CPUS-1:0]       iwait, dwait, iREN, dREN, dWEN;
	// word_t  [CPUS-1:0]       iload, dload, dstore;
	// word_t  [CPUS-1:0]       iaddr, daddr;

	// // coherence
	// // CPUS = number of cpus parameter passed from system -> cc
	// // ccwait         : lets a cache know it needs to block cpu
	// // ccinv          : let a cache know it needs to invalidate entry
	// // ccwrite        : high if cache is doing a write of addr
	// // ccsnoopaddr    : the addr being sent to other cache with either (wb/inv)
	// // cctrans        : high if the cache state is transitioning (i.e. I->S, I->M, etc...)
	// logic   [CPUS-1:0]      ccwait, ccinv;
	// logic   [CPUS-1:0]      ccwrite, cctrans;
	// word_t  [CPUS-1:0]      ccsnoopaddr;
	
	// // ram side
	// logic                   ramWEN, ramREN;
	// ramstate_t              ramstate;
		// // ramstate
		// typedef enum logic [1:0] {
		// 	FREE,
		// 	BUSY,
		// 	ACCESS,
		// 	ERROR
		// } ramstate_t;
	// word_t                  ramaddr, ramstore, ramload;
	
    //         // cache inputs
    // input   iREN, dREN, dWEN, dstore, iaddr, daddr,
    //         // ram inputs
    //         ramload, ramstate,
    //         // coherence inputs from cache
    //         ccwrite, cctrans,
    //         // cache outputs
    // output  iwait, dwait, iload, dload,
    //         // ram outputs
    //         ramstore, ramaddr, ramWEN, ramREN,
    //         // coherence outputs to cache
    //         ccwait, ccinv, ccsnoopaddr
);
	// type import
	import cpu_types_pkg::*;

	// number of cpus for cc
	parameter CPUS = 2;
    typedef enum logic [3:0] {BUS_REQ, BUS_GRANT, SNOOP, RESPONSE_1, RESPONSE_2, RELINQUISH_1, RELINQUISH_2, MEMORY_1, MEMORY_2} bus_stateType;
    bus_stateType state, next_state;
    logic requester_idx, next_requester_idx;
    logic responder_idx;
    word_t temp_store, next_temp_store;
    logic icache_ff, next_icache_ff;
	logic dcache_ff, next_dcache_ff;

    always_ff @(posedge CLK, negedge nRST) begin
        if (!nRST) begin
            icache_ff <= 1'b0;
			dcache_ff <= 1'b0;
            temp_store <= 'b0;
            state <= BUS_REQ;
            requester_idx <= 1'b0;
        end
        else begin
            icache_ff <= next_icache_ff;
			dcache_ff <= next_dcache_ff;
            temp_store <= next_temp_store;
            state <= next_state;
            requester_idx <= next_requester_idx;
        end
    end
	always_comb begin : MEMORY_CONTROL_LOGIC
        
        ccif.iwait = 2'b11;
		ccif.dwait = 2'b11;
		ccif.ccinv = '0;
		ccif.ccsnoopaddr = '0;
		ccif.ccwait = '0;
		ccif.ramaddr = '0;
		ccif.ramstore = '0;
		ccif.iload[0] = ccif.ramload;
		ccif.iload[1] = ccif.ramload;
		ccif.dload[0] = ccif.ramload;
		ccif.dload[1] = ccif.ramload;
        ccif.ramREN = 1'b0;
        ccif.ramWEN = 1'b0;
        next_icache_ff = icache_ff;
		next_dcache_ff = dcache_ff;
        next_temp_store = temp_store;
        next_requester_idx = requester_idx;
        responder_idx = ~requester_idx;

        if (ccif.iREN[0] | ccif.iREN[1]) begin
			
            // ram address port for instruction access
            if(ccif.iREN[0] & ~ccif.iREN[1]) begin
                ccif.ramaddr = ccif.iaddr[0];
                ccif.ramREN = 1'b1;
                ccif.ramWEN = 1'b0;
                if (ccif.ramstate == ACCESS)
                    ccif.iwait[0] = 1'b0;
                    next_icache_ff = 1'b1;
            end
            else if (ccif.iREN[1] & ~ccif.iREN[0]) begin
                ccif.ramaddr = ccif.iaddr[1];
                ccif.ramREN = 1'b1;
                ccif.ramWEN = 1'b0;
                if (ccif.ramstate == ACCESS)
                    ccif.iwait[1] = 1'b0;
                    next_icache_ff = 1'b0;
            end
            else begin
                ccif.ramaddr = ccif.iaddr[icache_ff];
                ccif.ramREN = 1'b1;
                ccif.ramWEN = 1'b0;
                if (ccif.ramstate == ACCESS) begin
                    ccif.iwait[icache_ff] = 1'b0;
                    next_icache_ff = ~icache_ff;
                end
            end
        end
			  // check for instruction request serviced

        case(state) 
            
            
            BUS_REQ: begin
                if (ccif.dWEN[0] | ccif.dWEN[1] | ccif.dREN[0] | ccif.dREN[1]) begin
                    next_state = BUS_GRANT;
                end
                else begin
                    next_state = BUS_REQ;
                end
            end
            BUS_GRANT: begin
                if ((ccif.dWEN[0] | ccif.dREN[0]) && (ccif.dWEN[1] | ccif.dREN[1])) begin
                    next_requester_idx = dcache_ff;

                    if (ccif.dWEN[dcache_ff]) begin
                        next_dcache_ff = dcache_ff;
                        next_state = MEMORY_1;
                    end
                    else begin
                        next_dcache_ff = ~dcache_ff;
                        next_state = SNOOP;
                    end
                end
                else if (ccif.dWEN[0] | ccif.dREN[0]) begin
                    next_requester_idx = 1'b0;

                    if (ccif.dWEN[0]) begin
                        next_dcache_ff = 1'b0;
                        next_state = MEMORY_1;
                    end
                    else begin
                        next_dcache_ff = 1'b1;
                        next_state = SNOOP;
                    end
                end
                else if (ccif.dWEN[1] | ccif.dREN[1]) begin
                    next_requester_idx = 1'b1;

                    if (ccif.dWEN[1]) begin
                        next_dcache_ff = 1'b1;
                        next_state = MEMORY_1;
                    end
                    else begin
                        next_dcache_ff = 1'b0;
                        next_state = SNOOP;
                    end
                end
                else begin
                    next_requester_idx = 1'b0;
					next_dcache_ff = 1'b0;
					next_state = BUS_REQ;
                end
            end
            SNOOP: begin
                ccif.ccwait[responder_idx] = 1'b1;
                if (ccif.ccwrite[responder_idx]) begin
                    next_state = SNOOP;
                end
                else
                    next_state = RESPONSE_1;
                ccif.ccsnoopaddr[responder_idx] = ccif.daddr[requester_idx];
                ccif.ccinv[responder_idx] = ccif.cctrans[requester_idx];
            end
            RESPONSE_1: begin
                if(ccif.cctrans[responder_idx]) begin
                    next_temp_store = ccif.dstore[responder_idx];
                    ccif.ramREN = 1'b0;
                    ccif.ramWEN = 1'b1;
                end
                else begin
                    next_temp_store = ccif.ramload;
                    ccif.ramREN = 1'b1;
                    ccif.ramWEN = 1'b0;
                end
                if ((ccif.ramstate != ACCESS))
                    next_state = RESPONSE_1;
                else begin
                    next_state = RELINQUISH_1;
                    
                    // signal done with this BusWB
                    ccif.ccinv[responder_idx] = 1'b1;
                end
                    
                ccif.ramaddr = ccif.daddr[requester_idx];
                ccif.ramstore = ccif.dstore[responder_idx];

                // overwrite iREN
                ccif.iwait = 2'b11;
                next_icache_ff = icache_ff;
            end
            RESPONSE_2: begin
                if(ccif.cctrans[responder_idx]) begin
                    next_temp_store = ccif.dstore[responder_idx];
                    ccif.ramREN = 1'b0;
                    ccif.ramWEN = 1'b1;
                end
                else begin
                    next_temp_store = ccif.ramload;
                    ccif.ramREN = 1'b1;
                    ccif.ramWEN = 1'b0;
                end
                if ((ccif.ramstate != ACCESS)) begin
                    next_state = RESPONSE_2;
				end
                else begin
                    next_state = RELINQUISH_2;

                    // signal done with this BusWB
                    ccif.ccinv[responder_idx] = 1'b1;
				end

                ccif.ramaddr = ccif.daddr[requester_idx];
                ccif.ramstore = ccif.dstore[responder_idx];

                // overwrite iREN
                ccif.iwait = 2'b11;
                next_icache_ff = icache_ff;
	        end
            RELINQUISH_1: begin
                ccif.dload[requester_idx] = temp_store;
                ccif.dwait[requester_idx] = 1'b0;
                next_state = RESPONSE_2;
            end
            RELINQUISH_2: begin
                ccif.dload[requester_idx] = temp_store;
                ccif.dwait[requester_idx] = 1'b0;
                next_state = BUS_REQ;
            end
            MEMORY_1: begin
                ccif.ramREN = 1'b0;
                ccif.ramWEN = 1'b1;
                ccif.ramaddr = ccif.daddr[requester_idx];
                ccif.dwait[requester_idx] = (ccif.ramstate != ACCESS);
                ccif.ramstore = ccif.dstore[requester_idx];

                if (ccif.ramstate == ACCESS) begin
                	next_state = MEMORY_2;
				end
				else begin
					next_state = MEMORY_1;
                end

                // overwrite iREN
                ccif.iwait = 2'b11;
                next_icache_ff = icache_ff;
            end
            MEMORY_2: begin
                ccif.ramREN = 1'b0;
                ccif.ramWEN = 1'b1;
                ccif.ramaddr = ccif.daddr[requester_idx];
                ccif.dwait[requester_idx] = (ccif.ramstate != ACCESS);
                ccif.iwait = 2'b11; // overwrite iREN
                ccif.ramstore = ccif.dstore[requester_idx];
                
				if (ccif.ramstate == ACCESS) begin
                	next_state = BUS_REQ;
				end
				else begin
					next_state = MEMORY_2;
				end

                // overwrite iREN
                ccif.iwait = 2'b11;
                next_icache_ff = icache_ff;
            end
        endcase

/*
        // old memory_control

		// constant outputs
		ccif.iload = ccif.ramload;
		ccif.dload = ccif.ramload;
		ccif.ramstore = ccif.dstore;

		// causing not being able to read after mem instr?
		ccif.ramREN = (ccif.iREN | ccif.dREN) & ~ccif.dWEN;
		// ccif.ramREN = ccif.iREN | ccif.dREN;
	
		ccif.ramWEN = ccif.dWEN;

		// default outputs (effectively, case for no memory access)
		ccif.iwait = 1'b1;
		ccif.dwait = 1'b1;
		ccif.ramaddr = ccif.iaddr;

		// prioritize data access (write)
		if (ccif.dWEN)
		begin
			// ram address port for data access
			ccif.ramaddr = ccif.daddr;

			// check for data request serviced
			if (ccif.ramstate == ACCESS)
			begin
				// indicate data write ready
				ccif.dwait = 1'b0;
			end
		end
		// next, prioritize data access (read)
		else if (ccif.dREN)
		begin
			// ram address port for data access
			ccif.ramaddr = ccif.daddr;

			// check for data request serviced
			if (ccif.ramstate == ACCESS)
			begin
				// indicate read data ready
				ccif.dwait = 1'b0;
			end
		end
		// otherwise, check for instruction access
		else if (ccif.iREN)
		begin
			// ram address port for instruction access
			ccif.ramaddr = ccif.iaddr;

			// check for instruction request serviced
			if (ccif.ramstate == ACCESS)
			begin
				// indicate read instruction ready
				ccif.iwait = 1'b0;
			end
		end
    */
		// otherwise, no data access, keep default outputs
	end

endmodule
