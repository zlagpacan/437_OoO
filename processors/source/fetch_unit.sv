/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: fetch_unit.sv
    Instantiation Hierarchy: system -> core -> fetch_unit
    Description: 
        The fetch unit makes PC addr req's to icache, receives the icache instr resp, and determines the 
        next PC addr. The fetch unit employs a BTB, DIRP, RAS, and immediately jumps. 
*/

module fetch_unit #(
    parameter BTB_WIDTH = 8,
    parameter RAS_DEPTH = 4,
    parameter
) (

);

endmodule