/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: fetch_unit.sv
    Instantiation Hierarchy: system -> core -> fetch_unit
    Description: 
        The fetch unit makes PC addr req's to icache, receives the icache instr resp, and determines the 
        next PC addr. The fetch unit employs a BTB/DIRP, RAS, and immediately jumps for j and jal. 
*/

`include "instr_types.vh"
import instr_types_pkg::*;

module fetch_unit #(
    parameter PC_RESET_VAL = 16'h0,
    parameter BTB_FRAMES = 256,
    parameter RAS_DEPTH = 8,

    // calculated params
    parameter LOG_BTB_FRAMES = $clog2(BTB_FRAMES),
    parameter LOG_RAS_DEPTH = $clog2(RAS_DEPTH)
) (
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // inputs: 

    // seq
    input CLK, nRST,

    // BTB/DIRP inputs from pipeline
    input pipeline_BTB_DIRP_update,                     // shared b/w BTB and DIRP
    input [LOG_BTB_FRAMES-1:0] pipeline_BTB_DIRP_index,   // shared b/w BTB and DIRP
    input pc_t pipeline_BTB_target,           // only need 14-bit addr
    input pipeline_DIRP_taken,
    
    // resolved target from pipeline
    input pipeline_take_resolved,
    input pc_t pipeline_resolved_PC,

    // I$
    input icache_hit,
    input word_t icache_load,

    // core controller
    input pipeline_stall_fetch_unit,
    input pipeline_halt,

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // outputs:

    // I$
    output logic icache_REN,
    output word_t icache_addr,
    output logic icache_halt,

    // to pipeline
    output word_t pipeline_instr,
    output logic pipeline_ivalid,
    output pc_t pipeline_PC,    // only need 14-bit addr
    output pc_t pipeline_nPC    // only need 14-bit addr
);

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

    // branch take signals
    logic DIRP_state;

    // BTB/DIRP
        // BTB_FRAMES x entries BTB/DIRP
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

    // RAS
        // RAS_DEPTH x entries RAS
        // can write over itself, only need top pointer
    typedef struct packed {
        pc_t PC;                // only need 14-bit addr
    } RAS_entry_t;

    RAS_entry_t [RAS_DEPTH-1:0] RAS_entry_by_top_index;
    RAS_entry_t [RAS_DEPTH-1:0] next_RAS_entry_by_top_index;

    logic [LOG_RAS_DEPTH-1:0] RAS_top_index;
    logic [LOG_RAS_DEPTH-1:0] next_RAS_top_index;

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

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // BTB/DIRP:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            BTB_DIRP_entry_by_frame_index <= '0;
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
        if (pipeline_BTB_DIRP_update) begin

            // BTB target update
                // calculate target every time, might as well update every time
            next_BTB_DIRP_entry_by_frame_index[pipeline_BTB_DIRP_index].target = pipeline_BTB_target;

            // DIRP state update
            case (BTB_DIRP_entry_by_frame_index[pipeline_BTB_DIRP_index].state)
                
                STRONG_NT:
                begin
                    next_BTB_DIRP_entry_by_frame_index[pipeline_BTB_DIRP_index].state = 
                        pipeline_DIRP_taken ? 
                        WEAK_NT : 
                        STRONG_NT;  // saturate
                end

                WEAK_NT:
                begin
                    next_BTB_DIRP_entry_by_frame_index[pipeline_BTB_DIRP_index].state = 
                        pipeline_DIRP_taken ? 
                        STRONG_T :  // skip WEAK_T
                        STRONG_NT;
                end

                WEAK_T:
                begin
                    next_BTB_DIRP_entry_by_frame_index[pipeline_BTB_DIRP_index].state = 
                        pipeline_DIRP_taken ? 
                        STRONG_T : 
                        STRONG_NT;  // skip WEAK_NT
                end

                STRONG_T:
                begin
                    next_BTB_DIRP_entry_by_frame_index[pipeline_BTB_DIRP_index].state = 
                        pipeline_DIRP_taken ? 
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
            RAS_top_index <= '0;
        end
        else begin
            RAS_entry_by_top_index <= next_RAS_entry_by_top_index;
            RAS_top_index <= next_RAS_top_index;
        end
    end

    // comb
    always_comb begin

        // read RAS entry
        RAS_pop_val = RAS_entry_by_top_index[RAS_top_index];

        // write RAS array:

        // default: hold states
        next_RAS_entry_by_top_index = RAS_entry_by_top_index;
        next_RAS_top_index = RAS_top_index;

        // push to RAS on jump and link
        RAS_push_val = PC_plus_4;
        if (is_jal) begin
            
            // RAS write at top index
            next_RAS_entry_by_top_index[RAS_top_index] = RAS_push_val;

            // increment top index
            next_RAS_top_index = RAS_top_index + 1;
        end

        // pop from RAS on jump to register
        if (is_jr) begin

            // decrement top index
            next_RAS_top_index = RAS_top_index - 1;
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // pre-decode:

    // comb
    always_comb begin

        // get instruction opcode
        instr = icache_load;
        instr_opcode = opcode_t'(instr[31:25]);

        // check for BEQ/BNE
        is_beq_bne = (instr_opcode == BEQ | instr_opcode == BNE);

        // check for J
        is_j = (instr_opcode == J);

        // check for JAL
        is_jal = (instr_opcode == JAL);

        // check for JR
        is_jr = (instr_opcode == JR);
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // PC select logic:

    // seq
    always_ff @ (posedge CLK, negedge nRST) begin
        if (~nRST) begin
            PC <= PC_RESET_VAL[ADDR_SPACE_WIDTH:2]; // bits 15:2 (lower 14 bits at word granularity)
        end
        else begin
            PC <= nPC;
        end
    end

    // comb
    always_comb begin

        // get J bits (lower 14)
        jPC = instr[PC_WIDTH-1:0];

        // PC + 4
        PC_plus_4 = PC + 1; // PC + 4 equivalent to PC + 1 since chop of 2 lsb

        // nPC select mux
            // priority:    pipeline_take_resolved (pipeline_resolved_PC) > 
            //              icache_hit {is_beq_bne (DIRP_state -> BTB_target / PC+4), 
            //                  is_j/is_jal (jPC), is_jr (RAS_pop_val), else (PC+4)} > 
            //              ~icache_hit {PC}

        // resolved PC
        if (pipeline_take_resolved) begin
            nPC = pipeline_resolved_PC;
        end

        // icache hit
        else if (icache_hit) begin

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
                    assert(0);
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
    always_ff @ (posedge CLK, nRST) begin
        if (~nRST) begin
            icache_REN <= 1'b0;
        end
        else begin
            icache_REN <= next_icache_REN;
        end
    end

    // comb
    always_comb begin

        // default: do fetch
        next_icache_REN = 1'b1;
        icache_addr = {16'h0, PC, 2'h0};

        // halt fetch unit
        if (pipeline_halt) begin
            next_icache_REN = 1'b0;
            // PC will automatically be paused since will not get ihit's
        end

        // pause fetch unit
        else if (pipeline_stall_fetch_unit) begin
            next_icache_REN = 1'b0;
            // PC will automatically be paused since will not get ihit's
        end
    end

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // pipeline output mapping:

    // wires
    assign pipeline_instr = instr;
    assign pipeline_ivalid = icache_hit;
    assign pipeline_PC = PC;
    assign pipeline_nPC = nPC;

    assign icache_halt = pipeline_halt;

endmodule