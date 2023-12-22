/*
  Eric Villasenor
  evillase@gmail.com

  this block holds the i and d cache
*/


module caches (
  input logic CLK, nRST,
  datapath_cache_if dpif,
  caches_if cif
 /* datapath_cache_if.icache dpiif,
  datapath_cache_if.dcache dpdif,
  caches_if.icache ciif,
  caches_if.dcache cdif

*/

);

  // icache
  icache ICACHE(CLK, nRST, dpif, cif);
  // dcache
  dcache DCACHE(CLK, nRST, dpif, cif);

  // // dcache invalidate before halt handled by dcache when exists
  // assign dcif.flushed = dcif.halt;

  // //singlecycle
  // assign dcif.ihit = (dcif.imemREN) ? ~cif.iwait : 0;
  // assign dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~cif.dwait : 0;
  // assign dcif.imemload = cif.iload;
  // assign dcif.dmemload = cif.dload;


  // assign cif.iREN = dcif.imemREN;
  // assign cif.dREN = dcif.dmemREN;
  // assign cif.dWEN = dcif.dmemWEN;
  // assign cif.dstore = dcif.dmemstore;
  // assign cif.iaddr = dcif.imemaddr;
  // assign cif.daddr = dcif.dmemaddr;

endmodule
