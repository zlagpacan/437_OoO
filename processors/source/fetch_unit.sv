/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: fetch_unit.sv
    Instantiation Hierarchy: system -> core -> fetch_unit
    Description: 
        The Fetch Unit makes PC addr req's to icache, receives the icache instr resp, and determines the 
        next PC addr. The fetch unit employs a BTB/DIRP, RAS, and immediately jumps for j and jal. 
*/

`include "core_types.vh"
import core_types_pkg::*;

module fetch_unit #(
    parameter PC_RESET_VAL = 16'h0
) (
    // seq
    input logic CLK, nRST,

    // DUT error
    output logic DUT_error,

    // BTB/DIRP inputs from pipeline
    input logic from_pipeline_BTB_DIRP_update,              // shared b/w BTB and DIRP
    input BTB_DIRP_index_t from_pipeline_BTB_DIRP_index,    // shared b/w BTB and DIRP
    input pc_t from_pipeline_BTB_target,                    // only need 14-bit addr
    input logic from_pipeline_DIRP_taken,
    
    // resolved target from pipeline
    input logic from_pipeline_take_resolved,
    input pc_t from_pipeline_resolved_PC,

    // I$
    input logic icache_hit,
    input word_t icache_load,
    output logic icache_REN,
    output word_t icache_addr,
    output logic icache_halt,

    // core controller
    input logic core_control_stall_fetch_unit,
    input logic core_control_halt,

    // to pipeline
    output word_t to_pipeline_instr,
    output logic to_pipeline_ivalid,
    output pc_t to_pipeline_PC,         // only need 14-bit addr
    output pc_t to_pipeline_nPC         // only need 14-bit addr
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
    // internal signals:

    // PC's
    pc_t PC;            // only need 14-bit addr
    pc_t nPC;           // only need 14-bit addr

    pc_t PC_plus_4;     // only need 14-bit addr
    pc_t jPC;           // only need 14-bit addr
    pc_t RAS_pop_val;   // only need 14-bit addr
    pc_t BTB_target;    // only need 14-bit addr
        // resolved PC

    // BTB/DIRP
        // BTB_FRAMES x frames BTB/DIRP
    typedef enum logic [1:0] {
        STRONG_NT   = 2'b00,
        WEAK_NT     = 2'b01,
        WEAK_T      = 2'b10,
        STRONG_T    = 2'b11
    } DIRP_state_t;

    typedef struct packed {
        pc_t target;            // only need 14-bit addr
        DIRP_state_t state;
    } BTB_DIRP_entry_t;

    BTB_DIRP_entry_t [BTB_FRAMES-1:0] BTB_DIRP_entry_by_frame_index;
    BTB_DIRP_entry_t [BTB_FRAMES-1:0] next_BTB_DIRP_entry_by_frame_index;

    logic [LOG_BTB_FRAMES-1:0] BTB_DIRP_frame_index;
    
    DIRP_state_t DIRP_state;

    // RAS
        // RAS_DEPTH x entries RAS
        // can write over itself, only need top pointer
    typedef struct packed {
        pc_t PC;                // only need 14-bit addr
    } RAS_entry_t;

    RAS_entry_t [RAS_DEPTH-1:0] RAS_entry_by_top_index;
    RAS_entry_t [RAS_DEPTH-1:0] next_RAS_entry_by_top_index;

    logic [LOG_RAS_DEPTH-1:0] RAS_top_write_index;
    logic [LOG_RAS_DEPTH-1:0] next_RAS_top_write_index;
    logic [LOG_RAS_DEPTH-1:0] RAS_top_read_index;

    pc_t RAS_push_val;

    // pre-decode
    word_t instr;
    opcode_t instr_opcode;
    logic is_beq_bne;
    logic is_j;
    logic is_jal;
    logic is_jr;

    // PC select logic

    // I$
    logic next_icache_REN;
    logic next_icache_halt;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BTB/DIRP:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            for (int i = 0; i < BTB_FRAMES; i++) begin
                BTB_DIRP_entry_by_frame_index[i].target <= 14'h0;
                BTB_DIRP_entry_by_frame_index[i].state <= WEAK_NT;
            end
        end
        else begin
            BTB_DIRP_entry_by_frame_index <= next_BTB_DIRP_entry_by_frame_index;
        end
    end

    // comb
    always_comb begin

        // get index bits
        BTB_DIRP_frame_index = PC[LOG_BTB_FRAMES-1:0];

        // read BTB/DIRP array
        BTB_target = BTB_DIRP_entry_by_frame_index[BTB_DIRP_frame_index].target;
        DIRP_state = BTB_DIRP_entry_by_frame_index[BTB_DIRP_frame_index].state;

        // write BTB/DIRP array:

        // default: hold states
        next_BTB_DIRP_entry_by_frame_index = BTB_DIRP_entry_by_frame_index;

        // update specific entry
        if (from_pipeline_BTB_DIRP_update) begin

            // BTB target update
                // calculate target every time, might as well update every time
            next_BTB_DIRP_entry_by_frame_index[from_pipeline_BTB_DIRP_index].target = from_pipeline_BTB_target;

            // DIRP state update
            case (BTB_DIRP_entry_by_frame_index[from_pipeline_BTB_DIRP_index].state)
                
                STRONG_NT:
                begin
                    next_BTB_DIRP_entry_by_frame_index[from_pipeline_BTB_DIRP_index].state = 
                        from_pipeline_DIRP_taken ? 
                        WEAK_NT : 
                        STRONG_NT;  // saturate
                end

                WEAK_NT:
                begin
                    next_BTB_DIRP_entry_by_frame_index[from_pipeline_BTB_DIRP_index].state = 
                        from_pipeline_DIRP_taken ? 
                        STRONG_T :  // skip WEAK_T
                        STRONG_NT;
                end

                WEAK_T:
                begin
                    next_BTB_DIRP_entry_by_frame_index[from_pipeline_BTB_DIRP_index].state = 
                        from_pipeline_DIRP_taken ? 
                        STRONG_T : 
                        STRONG_NT;  // skip WEAK_NT
                end

                STRONG_T:
                begin
                    next_BTB_DIRP_entry_by_frame_index[from_pipeline_BTB_DIRP_index].state = 
                        from_pipeline_DIRP_taken ? 
                        STRONG_T :  // saturate
                        WEAK_T;
                end

            endcase
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // RAS:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            RAS_entry_by_top_index <= '0;
            RAS_top_write_index <= '0;
        end
        else begin
            RAS_entry_by_top_index <= next_RAS_entry_by_top_index;
            RAS_top_write_index <= next_RAS_top_write_index;
        end
    end

    // comb
    always_comb begin

        // read RAS entry (1 below top of stack)
        RAS_top_read_index = RAS_top_write_index - 1;
        RAS_pop_val = RAS_entry_by_top_index[RAS_top_read_index];

        // write RAS array:

        // default: hold states
        next_RAS_entry_by_top_index = RAS_entry_by_top_index;
        next_RAS_top_write_index = RAS_top_write_index;

        // push to RAS on jump and link
        RAS_push_val = PC_plus_4;
        if (is_jal) begin
            
            // RAS write at top index
            next_RAS_entry_by_top_index[RAS_top_write_index] = RAS_push_val;

            // increment top index
            next_RAS_top_write_index = RAS_top_write_index + 3'd1;
        end

        // pop from RAS on jump to register
        if (is_jr) begin

            // decrement top index
            next_RAS_top_write_index = RAS_top_read_index;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // pre-decode:

    // comb
    always_comb begin

        // get instruction opcode
        instr = icache_load;
        instr_opcode = opcode_t'(instr[31:26]);

        // check for BEQ/BNE
        is_beq_bne = (instr_opcode == BEQ | instr_opcode == BNE);

        // check for J
        is_j = (instr_opcode == J);

        // check for JAL
        is_jal = (instr_opcode == JAL);

        // check for JR
        is_jr = (instr_opcode == RTYPE) & (funct_t'(instr[5:0]) == JR);
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // PC select logic:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            PC <= PC_RESET_VAL[ADDR_SPACE_WIDTH-1:2]; // bits 15:2 (lower 14 bits at word granularity)
        end
        else begin
            PC <= nPC;
        end
    end

    // comb
    always_comb begin

        // no DUT error
        next_DUT_error = 1'b0;

        // get J bits (lower 14)
        jPC = instr[PC_WIDTH-1:0];

        // PC + 4
        PC_plus_4 = PC + 14'd1; // PC + 4 equivalent to PC + 1 since chop of 2 lsb

        // synthesis wants default val for nPC
        nPC = PC;

        // nPC select mux
            // priority:    resolved (from_pipeline_resolved_PC) > 
            //              ihit & ~stall {is_beq_bne (DIRP_state -> BTB_target vs. PC+4), 
            //                  is_j/is_jal (jPC), is_jr (RAS_pop_val), else (PC+4)} > 
            //              ~icache_hit | stall {PC}

        // resolved PC
        if (from_pipeline_take_resolved) begin
            nPC = from_pipeline_resolved_PC;
        end

        // icache hit
        else if (icache_hit & ~core_control_stall_fetch_unit) begin

            // branch
            if (is_beq_bne) begin
                // taken
                if (DIRP_state == STRONG_T | DIRP_state == WEAK_T) begin
                    $display("fetch_unit: speculate branch taken to BTB target");
                    nPC = BTB_target;
                end
                // not taken
                else if (DIRP_state == STRONG_NT | DIRP_state == WEAK_NT) begin
                    $display("fetch unit: speculate branch not taken");
                    nPC = PC_plus_4;
                end
                // shouldn't get here
                else begin
                    $display("fetch_unit: ERROR: DIRP_state invalid");
                    // assert(0);
                    next_DUT_error = 1'b1;
                end
            end
            // j or jal
            else if (is_j | is_jal) begin

                // take imm j address
                nPC = jPC;
            end
            // jr
            else if (is_jr) begin

                // take RAS pop address
                nPC = RAS_pop_val;
            end

            // PC + 4
            else begin

                // take PC + 4
                nPC = PC_plus_4;
            end
        end

        // hold PC
        else begin
            nPC = PC;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // ireq controls:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            icache_REN <= 1'b0;
            icache_halt <= 1'b0;
        end
        else begin
            icache_REN <= next_icache_REN;
            icache_halt <= next_icache_halt;
        end
    end

    // comb
    always_comb begin

        // default: do fetch
        next_icache_REN = 1'b1;
        next_icache_halt = 1'b0;

        // halt fetch unit
        if (core_control_halt) begin
            next_icache_REN = 1'b0;
            next_icache_halt = 1'b1;
            // PC will automatically be paused since will not get ihit's
        end

        // // pause fetch unit
        //     // don't need REN disable since ivalid already turned off
        //     // likely will want next instr so good idea to fetch
        // else if (core_control_stall_fetch_unit) begin
        //     // next_icache_REN = 1'b0;
        //     // next_icache_halt = 1'b0;
        //     // PC will automatically be paused since will not get ihit's
        // end
    end

    // wires
    assign icache_addr = {16'h0, PC, 2'h0};

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline output mapping:

    // ivalid logic
    assign to_pipeline_ivalid = 
        icache_hit & 
        ~from_pipeline_take_resolved & 
        ~core_control_stall_fetch_unit & 
        ~core_control_halt;

    // wires
    assign to_pipeline_instr = instr;
    assign to_pipeline_PC = PC;
    assign to_pipeline_nPC = nPC;

endmodule