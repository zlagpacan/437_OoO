/*
  Eric Villasenor
  evillase@gmail.com

  system interface
*/
`ifndef SYSTEM_IF_VH
`define SYSTEM_IF_VH

// types
`include "cpu_types_pkg.vh"

interface system_if;
  // import types
  import cpu_types_pkg::*;

  logic               tbCTRL, halt, WEN, REN;
  word_t              addr, store, load;

  // system ports
  modport sys (
    input   tbCTRL, WEN, REN, store, addr,
    output  load, halt
  );
  // testbench program
  modport tb (
    input   load, halt,
    output  tbCTRL, WEN, REN, store, addr
  );
endinterface

`endif //SYSTEM_IF_VH
