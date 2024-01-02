/*
    Repo: https://github.com/zlagpacan/437_OoO.git
    Author: zlagpacan

    File Name: dispatch_unit.sv
    Instantiation Hierarchy: system -> core -> dispatch_unit
    Description: 
        The Physical Register Ready Table provides whether a physical register value is ready or is yet to
        be computed in the datapath. As far as can tell, this module does not require checkpointing or 
        revert logic since future instr's that use a value will use the most recent dispatch's ready val,
        which may or may not have been completed since. 
        
        It is the external controller's responsibility to prevent the clearing of phys reg 0.
*/

`include "core_types.vh"
import core_types_pkg::*;