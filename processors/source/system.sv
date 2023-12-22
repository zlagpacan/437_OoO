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

  // interface
  cpu_ram_if                            prif ();

  // processor
  //singlecycle #(.PC0('h0))              CPU (CPUCLK, nRST, halt, prif);
  //pipeline    #(.PC0('h0))              CPU (CPUCLK, nRST, halt, prif);
  multicore   #(.PC0('h0), .PC1('h200)) CPU (CPUCLK, nRST, halt, prif);

  // memory
  ram                         RAM (CLK, nRST, prif);
  //sdram                                 RAM (CLK, nRST, prif);

  // interface connections
  assign syif.halt = halt;
  assign syif.load = prif.ramload;

  // who has ram control
  assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
  assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
  assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
  assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule
