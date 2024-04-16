/*
  Eric Villasenor
  evillase@gmail.com

  all types used to make life easier.

  Shubham Rastogi
  shubhamrastogi3111995@gmail.com

  cache structs added
  
*/
`ifndef CPU_TYPES_PKG_VH
`define CPU_TYPES_PKG_VH
package cpu_types_pkg;

  // word width and size
  parameter WORD_W    = 32;
  parameter WBYTES    = WORD_W/8;

  // instruction format widths
  parameter OP_W      = 6;
  parameter REG_W     = 5;
  parameter SHAM_W    = REG_W;
  parameter FUNC_W    = OP_W;
  parameter IMM_W     = 16;
  parameter ADDR_W    = 26;

  // alu op width
  parameter AOP_W     = 4;

  // icache format widths
  parameter ITAG_W    = 26;
  parameter IIDX_W    = 4;
  parameter IBLK_W    = 0; // <- important
  parameter IBYT_W    = 2;

  // dcache format widths
  parameter DTAG_W    = 26;
  parameter DIDX_W    = 3;
  parameter DBLK_W    = 1;
  parameter DBYT_W    = 2;
  parameter DWAY_ASS  = 2;

// opcodes
  // opcode type
  typedef enum logic [OP_W-1:0] {
    // rtype - use funct
    RTYPE   = 6'b000000,

    // jtype
    J       = 6'b000010,
    JAL     = 6'b000011,

    // itype
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

  // rtype funct op type
  typedef enum logic [FUNC_W-1:0] {
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

  // alu op type
  typedef enum logic [AOP_W-1:0] {
    ALU_SLL     = 4'b0000,
    ALU_SRL     = 4'b0001,
    ALU_ADD     = 4'b0010,
    ALU_SUB     = 4'b0011,
    ALU_AND     = 4'b0100,
    ALU_OR      = 4'b0101,
    ALU_XOR     = 4'b0110,
    ALU_NOR     = 4'b0111,
    ALU_SLT     = 4'b1010,
    ALU_SLTU    = 4'b1011
  } aluop_t;

// instruction format types
  // register bits types
  typedef logic [REG_W-1:0] regbits_t;

  // j type
  typedef struct packed {
    opcode_t            opcode;
    logic [ADDR_W-1:0]  addr;
  } j_t;
  // i type
  typedef struct packed {
    opcode_t            opcode;
    regbits_t           rs;
    regbits_t           rt;
    logic [IMM_W-1:0]   imm;
  } i_t;
  // r type
  typedef struct packed {
    opcode_t            opcode;
    regbits_t           rs;
    regbits_t           rt;
    regbits_t           rd;
    logic [SHAM_W-1:0]  shamt;
    funct_t             funct;
  } r_t;

// cache address format types
  // icache format type
  typedef struct packed {
    logic [ITAG_W-1:0]  tag;
    logic [IIDX_W-1:0]  idx;
    logic [IBYT_W-1:0]  bytoff;
  } icachef_t;

  // dcache format type
  typedef struct packed {
    logic [DTAG_W-1:0]  tag;
    logic [DIDX_W-1:0]  idx;
    logic [DBLK_W-1:0]  blkoff;
    logic [DBYT_W-1:0]  bytoff;
  } dcachef_t;

// word_t
  typedef logic [WORD_W-1:0] word_t;

// memory state
  // ramstate
  typedef enum logic [1:0] {
    FREE,
    BUSY,
    ACCESS,
    ERROR
  } ramstate_t;

// cache frame structs
  //dcache frame
  typedef struct packed {
	logic valid;
	logic dirty;
	logic [DTAG_W - 1:0] tag;
	word_t [1:0] data;
  } dcache_frame;

  //icache frame  
  typedef struct packed {
	logic valid;
	logic [ITAG_W - 1:0] tag;
	word_t data;
  } icache_frame;

endpackage
`endif //CPU_TYPES_PKG_VH
