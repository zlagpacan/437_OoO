/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: core_types.vh
    Instantiation Hierarchy: system -> core
    Description: 
        This file defines types for common fields in MIPS instructions. Also defines some parameters useful 
        for this specific core implementation.
*/

`ifndef CORE_TYPES_VH
`define CORE_TYPES_VH

package core_types_pkg;

    // words
    parameter WORD_WIDTH = 32;
    typedef logic [31:0] word_t;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // MIPS ISA defs:

    parameter NUM_ARCH_REGS = 32;
    parameter OPCODE_WIDTH = 6;
    parameter ARCH_REG_WIDTH = 5;
    parameter SHAMT_WIDTH = 5;
    parameter FUNCT_WIDTH = 6;
    parameter IMM16_WIDTH = 16;
    parameter JADDR_WIDTH = 26;

    // imm16
    typedef logic [IMM16_WIDTH-1:0] imm16_t;

    // opcode
    typedef enum logic [OPCODE_WIDTH-1:0] {
        // R-type
        RTYPE   = 6'b000000,

        // J-type
        J       = 6'b000010,
        JAL     = 6'b000011,

        // I-type
        BEQ     = 6'b000100,
        BNE     = 6'b000101,
        ADDI    = 6'b001000,
        ADDIU   = 6'b001001,
        SLTI    = 6'b001010,
        SLTIU   = 6'b001011,
        ANDI    = 6'b001100,
        ORI     = 6'b001101,
        XORI    = 6'b001110,
        LUI     = 6'b001111,
        LW      = 6'b100011,
        LBU     = 6'b100100,
        LHU     = 6'b100101,
        SB      = 6'b101000,
        SH      = 6'b101001,
        SW      = 6'b101011,
        LL      = 6'b110000,
        SC      = 6'b111000,
        HALT    = 6'b111111
    } opcode_t;

    // funct
    typedef enum logic [FUNCT_WIDTH-1:0] {
        NOP     = 6'b000000,    // added so fully enumerated
        SLLV    = 6'b000100,
        SRLV    = 6'b000110,
        JR      = 6'b001000,
        ADD     = 6'b100000,
        ADDU    = 6'b100001,
        SUB     = 6'b100010,
        SUBU    = 6'b100011,
        AND     = 6'b100100,
        OR      = 6'b100101,
        XOR     = 6'b100110,
        NOR     = 6'b100111,
        SLT     = 6'b101010,
        SLTU    = 6'b101011
    } funct_t;

    typedef logic [ARCH_REG_WIDTH-1:0] arch_reg_tag_t;

    // j type instr
    typedef struct packed {
        opcode_t                opcode;
        logic [JADDR_WIDTH-1:0] jaddr;
    } j_t;

    // i type instr
    typedef struct packed {
        opcode_t                opcode;
        arch_reg_tag_t          rs;
        arch_reg_tag_t          rt;
        imm16_t                 imm16;
    } i_t;

    // r type instr
    typedef struct packed {
        opcode_t                opcode;
        arch_reg_tag_t          rs;
        arch_reg_tag_t          rt;
        arch_reg_tag_t          rd;
        logic [SHAMT_WIDTH-1:0] shamt;
        funct_t                 funct;
    } r_t;

    // ramstate
    typedef enum logic [1:0] {
        FREE,
        BUSY,
        ACCESS,
        ERROR
    } ramstate_t;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // this implementation's defs:

    // top level:

    parameter ADDR_SPACE_WIDTH = 16;
    parameter WORD_ADDR_SPACE_WIDTH = ADDR_SPACE_WIDTH - 2;
    parameter PC_WIDTH = WORD_ADDR_SPACE_WIDTH;
    parameter BLOCK_ADDR_SPACE_WIDTH = WORD_ADDR_SPACE_WIDTH - 1;
    parameter NUM_PHYS_REGS = 64;
    parameter PHYS_REG_WIDTH = $clog2(NUM_PHYS_REGS);

    typedef logic [PHYS_REG_WIDTH-1:0] phys_reg_tag_t;

    typedef logic [PC_WIDTH-1:0] pc_t;

    typedef logic [WORD_ADDR_SPACE_WIDTH-1:0] daddr_t;

    typedef logic [BLOCK_ADDR_SPACE_WIDTH-1:0] block_addr_t;

    typedef struct packed {
        logic needed;
        logic ready;
        phys_reg_tag_t phys_reg_tag;
    } source_reg_status_t;

    /////////////////
    // fetch unit: //
    /////////////////

    parameter BTB_FRAMES = 32;
    parameter LOG_BTB_FRAMES = $clog2(BTB_FRAMES);
    parameter RAS_DEPTH = 8;
    parameter LOG_RAS_DEPTH = $clog2(RAS_DEPTH);

    typedef logic [LOG_BTB_FRAMES-1:0] BTB_DIRP_index_t;

    typedef enum logic {
        FU_DEFAULT,
        FU_HALT
    } fetch_unit_state_t;

    ////////////////////////
    // checkpoint system: //
    ////////////////////////

    parameter CHECKPOINT_COLUMNS = 4;
    parameter LOG_CHECKPOINT_COLUMNS = $clog2(CHECKPOINT_COLUMNS);

    typedef logic [LOG_CHECKPOINT_COLUMNS-1:0] checkpoint_column_t;

    /////////////////////////
    // phys reg map table: //
    /////////////////////////

        // need checkpoint columns
        // internal array follows NUM_ARCH_REGS

    /////////////////////////
    // phys reg free list: //
    /////////////////////////

        // need checkpoint columns
        // max size of free list is (NUM_PHYS_REGS - NUM_ARCH_REGS)?
            // maximum number of non-in-flight phys reg's

    parameter FREE_LIST_DEPTH = NUM_PHYS_REGS - NUM_ARCH_REGS;
    parameter LOG_FREE_LIST_DEPTH = $clog2(FREE_LIST_DEPTH);

    ///////////////////////////
    // phys reg ready table: //
    ///////////////////////////

        // internal array follows NUM_PHYS_REGS

    ////////////////////////
    // phys reg reg file: //
    ////////////////////////

        // 

    //////////
    // ROB: //
    //////////

    parameter ROB_DEPTH = 16;
    parameter LOG_ROB_DEPTH = $clog2(ROB_DEPTH);

    typedef logic [LOG_ROB_DEPTH:0] ROB_index_t;
        // has extra pointer msb bit
            // forget why need it
            // fails without it
            // small overhead so whatever, keep

    typedef struct packed {
        logic DU_ALU_0;
        logic DU_ALU_1;
        logic DU_LQ;
        logic DU_SQ;
        logic DU_BRU;
        logic DU_J;
        logic DU_DEAD;
        logic DU_HALT;
    } dispatched_unit_t;

    typedef struct packed {
        logic valid;
        logic complete;
        dispatched_unit_t dispatched_unit;  // just a check that expected unit(s) give complete
        // restore info
        pc_t restart_PC;    // for general instr restart (restart this instr)
        logic reg_write;
        arch_reg_tag_t dest_arch_reg_tag;
        phys_reg_tag_t safe_dest_phys_reg_tag;
        phys_reg_tag_t speculated_dest_phys_reg_tag;
    } ROB_entry_t;
        // consider adding safe checkpoint column here to better support general instr checkpointing
            // fine for now since checkpoint goes to BRU, and only BRU instr's are allowed to checkpoint

    typedef enum logic [1:0] {
        ROB_IDLE,
        ROB_RESTORE,
        ROB_REVERT,
        // ROB_KILL,
            // instead of kill state, always work kill jobs so can go back to IDLE for new instr dispatch
            // allocate kill jobs when get successful restore
        ROB_HALT
    } ROB_state_t;

    //////////
    // ALU: //
    //////////

    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_NOR,
        ALU_XOR,
        ALU_SLT,
        ALU_SLTU,
        ALU_SLLV,
        ALU_SRLV,
        ALU_LUI,    // R[dest] <= {imm16, 16'h0} (no reg input needed)
        ALU_LINK    // R[dest] <= {16'h0, imm16[15:2] + 1, 2'b00} (no reg input needed)
    } ALU_op_t;

    typedef struct packed {
        // ALU needs
        ALU_op_t op;
        logic itype;
        source_reg_status_t source_0;
        source_reg_status_t source_1;
        phys_reg_tag_t dest_phys_reg_tag;
        imm16_t imm16;
        // ROB needs
        ROB_index_t ROB_index;
    } ALU_RS_input_struct_t;

    //////////
    // LSQ: //
    //////////

    parameter LQ_DEPTH = 4;
    parameter LOG_LQ_DEPTH = $clog2(LQ_DEPTH);
    parameter SQ_DEPTH = 4;
    parameter LOG_SQ_DEPTH = $clog2(SQ_DEPTH);

    typedef logic [LOG_LQ_DEPTH-1:0] LQ_index_t;
        // doesn't have extra pointer msb bit
    typedef logic [LOG_SQ_DEPTH-1:0] SQ_index_t;
        // doesn't have extra pointer msb bit

    typedef enum logic [1:0] {
        LQ_LW,
        LQ_LL,
        LQ_SC
    } LQ_op_t;

    typedef enum logic {
        SQ_SW,
        SQ_SC
    } SQ_op_t;

    // LQ structs
    typedef struct packed {
        // LQ needs
        LQ_op_t op;
        source_reg_status_t source;
        phys_reg_tag_t dest_phys_reg_tag;
        daddr_t imm14;
        // SQ_index_t SQ_index;   // for SC, doubles as SQ index for store part of SC to track
        //     // may want separate counter tag to link the store and load parts of SC
        //         // or ROB_index serves this role
            // just grab local value
        ROB_index_t ROB_index;
    } LQ_enqueue_struct_t;

    typedef struct packed {
        logic valid;
        logic ready;
        logic linked;
        logic conditional;
        logic SQ_searched;
        logic SQ_loaded;
        logic dcache_loaded;
        ROB_index_t ROB_index;
        SQ_index_t SQ_index;
        daddr_t read_addr;
        phys_reg_tag_t dest_phys_reg_tag;
    } LQ_entry_t;

    // SQ structs
    typedef struct packed {
        // SQ needs
        SQ_op_t op;
        source_reg_status_t source_0;
        source_reg_status_t source_1;
        daddr_t imm14;
        LQ_index_t LQ_index;
            // may want separate counter tag to link the store and load parts of SC
                // or ROB_index serves this role
        // admin
        ROB_index_t ROB_index;
    } SQ_enqueue_struct_t;

    typedef struct packed {
        logic valid;
        logic ready;
        logic conditional;
        ROB_index_t ROB_index;
        daddr_t write_addr;
        word_t write_data;
    } SQ_entry_t;

    //////////
    // BRU: //
    //////////

    typedef enum logic [1:0] {
        BRU_BEQ,
        BRU_BNE,
        BRU_JR
    } BRU_op_t;

    // structs
    typedef struct packed {
        // BRU needs
        BRU_op_t op;
        source_reg_status_t source_0;
        source_reg_status_t source_1;
        logic [15:0] imm16;
        pc_t PC;    // will use to grab PC bits for BTB/DIRP index and do branch add ((PC + 4) + imm16)
        pc_t nPC;   // PC taken to check against
        // save/restore info
        checkpoint_column_t checkpoint_safe_column;
        // admin
        ROB_index_t ROB_index;
    } BRU_RS_input_struct_t;

endpackage

`endif  // CORE_TYPES_VH