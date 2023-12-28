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
        logic [IMM16_WIDTH-1:0] imm16;
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
    parameter NUM_PHYS_REGS = 64;
    parameter PHYS_REG_WIDTH = $clog2(NUM_PHYS_REGS);

    typedef logic [PHYS_REG_WIDTH-1:0] phys_reg_tag_t;

    typedef logic [PC_WIDTH-1:0] pc_t;

    typedef logic [WORD_ADDR_SPACE_WIDTH-1:0] daddr_t;

    // fetch unit:

    parameter BTB_FRAMES = 256;
    parameter LOG_BTB_FRAMES = $clog2(BTB_FRAMES);
    parameter RAS_DEPTH = 8;
    parameter LOG_RAS_DEPTH = $clog2(RAS_DEPTH);

    typedef logic [LOG_BTB_FRAMES-1:0] BTB_DIRP_index_t;

    // checkpoint system:

    parameter CHECKPOINT_COLUMNS = 4;
    parameter LOG_CHECKPOINT_COLUMNS = $clog2(CHECKPOINT_COLUMNS);

    typedef logic [LOG_CHECKPOINT_COLUMNS-1:0] checkpoint_column_t;

    // phys reg map table:

        // need checkpoint columns
        // internal array follows NUM_ARCH_REGS

    // phys reg free list:

        // need checkpoint columns
        // max size of free list is (NUM_PHYS_REGS - NUM_ARCH_REGS)?
            // maximum number of non-in-flight phys reg's

    parameter FREE_LIST_DEPTH = NUM_PHYS_REGS - NUM_ARCH_REGS;
    parameter LOG_FREE_LIST_DEPTH = $clog2(FREE_LIST_DEPTH);

    // ROB:

    parameter ROB_DEPTH = 32;
    parameter LOG_ROB_DEPTH = $clog2(ROB_DEPTH);

    typedef logic [LOG_ROB_DEPTH-1:0] ROB_index_t;

endpackage

`endif  // CORE_TYPES_VH