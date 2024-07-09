# 437_OoO
437_OoO is a MIPS dual-core out-of-order CPU implementation based in the Purdue ECE 437 infrastructure. This design was encouraged by architecture lectures in Purdue ECE 437, ECE 565, and ECE 666.

> **_WARNING TO STUDENTS_:** if you are a student in ECE 437 trying to copy from this design for your labs, you will find your effort completely wasted for the following reasons:
>  - this design is unbelievably far outside of the expected microarchitecture specification for the labs
>    - there is not a single module or testbench for a module that will get you a checkoff in the labs
>    - the design will fail all cache lab test cases due to the dcache hit counter
>    - the design will fail some racey multicore lab test cases since these expect your core requests and bus to behave a certain way
>  - this design does not use the required interfaces
>  - Purdue ECE 437 will be using RISC-V instead of MIPS starting Fall 2024!
 
## Goals
- implement R10K-based out-of-order core
- implement split-transaction, pipelined bus
- use MOESI snoopy cache coherence protocol with bus controller for sequential consistency
- use MSHRs, non-blocking caches
- system should act as memory bandwidth maximizing machine, not individual operation latency minimizer since have out-of-order to cover latencies
- target daxpy/vector add behavior

## Constraints
- based in Purdue ECE 437 infrastructure
  - 1x blocking 32-bit ram interface with (LAT-1)/2 CPUCLK cycles of latency
  - lower 16-bit address space
- MIPS integer subset
  - see 437_OoO/asm_i.txt

## Architecture

### System

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/system.sv



- everything within the dotted lines is part of the 437_OoO design
- dual-core
- MOESI snoopy cache coherence
- pipelined, split-transaction bus
- TSO memory consistency
  - only acts as TSO in single very specific case
  - in vast majority of cases, behavior follows Sequential Consistency
- out-of-order cores
- blocking icache
- non-blocking dcache

### Core

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/core.sv



- based on R10K out-of-order design
  - true register rename with physical register file, map table, free list
  - different from R10K: decided to use reservation stations in execution pipelines instead of proper issue queue
    - reservations stations can much more easily support back-to-back forwarding of values on write data buses
  - target vector add program
  - bare minimum memory dependence handling for the sake of sanity
    - no dependence prediction
    - no checkpointing of loads
    - always immediately try to load from dcache
    - if dcache load comes first but should have used SQ value, need restart
      - also restart if dcache invalidates or evicts block to maintain Sequential Consistency
  - Front End
    - Fetch
    - Dispatch
    - ROB
  - Back End
    - Physical Register File
    - 2x ALU Pipelines
    - Branch Resolution Pipeline
    - Load-Store Queue
- Fetch
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/fetch_unit.sv
  - fetch instructions from icache
  - on hit, determine next PC
    - PC+4 or speculated branch prediction
  - branch prediction
    - 32-entry BTB+DIRP
    - 8-entry RAS
    - pre-decode instructions to check for irregular control flow
      - use BTB+DIRP if BEQ/BNE
      - immediately jump following immediate bits if J, JAL
      - use RAS if JR
      - simplifies work branch pipeline must do
        - if any instruction that satisfies hash can use BTB+DIRP or RAS, then every instruction must be checked for the correct next PC
      - ended up not being critical path so perfectly fine
- Dispatch
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/dispatch_unit.sv
  - decode, read register map table and ready table, dequeue physical register free list, try to dispatch to associated pipeline(s)
    - Physical Register Map Table
      - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/phys_reg_map_table.sv
      - map architectural register to physical register
      - gives current in-order dispatch register rename
      - source operands read the table
      - destination operands reads the table to get the old mapping and writes the table with the new rename mapping
    - Physical Register Ready Table
      - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/phys_reg_ready_table.sv
      - tells if physical register value is ready or yet to be written at time of dispatch
    - Physical Register Free List
      - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/phys_reg_free_list.sv
      - gives list of free physical registers which can be used for a rename
      - dequeue on dispatch of register-writing instruction
      - enqueue on commit of register-writing instruction with physical register used before new rename of architecture register for this instruction
  - on successful dispatch, instruction goes to 0, 1, or 2 pipelines
    - 0: J, dead instructions (write to reg 0)
    - 1: reg writing instructions, BEQ, BNE, JR, LW, LL, SW
    - 2: SC, which goes to LQ and SQ
- Physical Register File
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/phys_reg_file.sv
  - 64 physical registers
  - register file is read by reservation stations in execution pipeline
  - 2x read ports, corresponding to the reservation station that wins access for the cycle
  - 3x write ports, 1x for each write data bus
  - to better support forwarding, must support same-cycle write and read
- 2x ALU Pipelines
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/alu_pipeline.sv
  - perform instructions which require an ALU operation
    - and also some instructions that simply need to write registers
      - LUI, JAL, etc.
  - pipelines fully independent
  - 1x ALU each
  - 1x write data bus each
  - primary reasoning behind having 2 pipelines targets vector add program
    - vector element add can be in one pipeline's RS, waiting for load misses and the independent index add operation is free to proceed in the other pipeline
- Branch Resolution Pipeline
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/bru_pipeline.sv
  - ensure conditional branch instructions branched to the correct PC
    - namely BEQ, BNE, JR
  - can send precise interrupt request to ROB
- Load-Store Queue
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/lsq.sv
  - 4-entry Load Queue
  - 4-entry Store Queue
  - 2x operand collection pipelines
    - one for loads, one for stores
  - CAM to check for memory dependence, SQ forward for load value
  - can send precise interrupt request to ROB
    - missed SQ forward value or dcache invalidated or evicted block
  - support LL with link register in dcache
  - support SC by sending conditional write request and conditional read request to dcache
    - conditional read request effectively returns to core like a load
- Reorder Buffer (ROB)
  - https://github.com/zlagpacan/437_OoO/blob/main/processors/source/rob.sv
  - 16 entries 
  - responsible for precise interrupt checkpoint restart and serial rollback logic
    - checkpoints can be used for BEQ, BNE, JR instructions
      - serial rollback if lost checkpoint
    - restarted loads must use serial rollback
    - sends checkpoint and rollback information to dispatch unit to restore effective architectural register state
  - responsible for misspeculated instruction kill logic
    - sends instruction kill information to dispatch unit to restore effective architectural register state
    - sends instruction kill information to execution pipelines to get rid of any lingering misspeculated work which can block useful work or mess up new post-speculation architectural state
      - especially relevant for loads and stores which can have long latencies and take up precious memory access slots in the LSQ
    - kills happen in tandem with serial rollback
    - kills can happen as a fully separate sequential process if checkpoint restart is successful

### Instruction Cache

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/icache.sv



- 1KB capacity
- way0 is loop way, way1 is stream buffer
  - misses and prefetched blocks after miss are loaded into stream buffer way
  - on hit in stream buffer way, loop way is loaded with block
  - not quite true 2-way set associativy as can have entry in both loop way and stream buffer way
- blocking, synchronous interfaces
  - core side and mem side
- doesn't participate in coherence
  - don't support self-modifying code

### Data Cache

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/dcache.sv



- 1KB capacity
- 2-way set associative
  - simple lower index bit hashing into both ways
- non-blocking, asynchronous interfaces
  - core side and bus/mem side
  - can have slow down signals preventing further requests (flow control)
- 4-entry write buffer (store MSHR queue)
- 5x MSHRs
  - 4x load MSHRs
  - 1x store MSHR at end of write buffer
- 2x tag arrays
  - one for core requests, one for snoop requests
  - snoop can only modify tag if core not using
    - snoop responses are asynchronous, can be delayed
- participates in coherence
  - must make required bus requests if core requests don't have required permissions following MOESI protocol
  - 4-entry snoop request queue to backlog snoop requests if need to make modification but core is busy modifying
- bus responses can be piggybacked, so a single block fetch can lead to a single cache frame fill but potentially multiple load data responses or store data writes
- MOESI block state 
  - I: no permissions
  - S: read permissions
  - E: read and write permissions
  - O: read permissions; write on eviction
  - M: read and write permissions; write on eviction

### Bus Controller

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/bus_controller.sv



- split transaction, pipelined bus
  - pipeline stages:
    - Request Stage
      - enqueue pending bus requests
    - Grant Stage
      - grant the next per-core in-order bus request if it does not conflict with an active bus request
    - Snoop Stage
      - includes per-core in-order request and response phases
    - Memory Stage
      - includes per-core in-order request and response phases
    - Response Stage
  - the pipeline is superscalar, one lane for dbus0 requests and one lane for dbus1 requests
    - this is trivial in the dual-core case since dbus requests only need to snoop into the single other dcache
- asynchronous request/response interfaces
  - bus request/response
    - 8-entry dbus request queue each for dbus0 and dbus1
  - snoop request/response
    - 4-entry snoop request queue each in dcache0 and dcache1
  - memory request/response
    - 8-entry read response queue each for dmem0 and dmem1
    - 8-entry read buffer in memory controller
- out-of-order responses are possible if an older request needs memory and a younger request does not
- implement dbus request queues as opposed to dbus request retry if don't get bus pipeline grant
  - easier on dcache, simply send dbus request and be done
  - need to potentially update requests, but they are already in the dbus request queues in the bus controller
    - block state is tracked and maintained in the dbus request queues by receiving snoop requests to the same cache
    - redundant, piggybackable dbus requests are killed in the dbus request queues by receiving snoop responses from the opposite cache
      - this is only a performance optimization to improve bus bandwidth. if specific timing has a piggybackable request unneedingly enter the pipeline, the bus will simply refetch the data, and the dcache ignores the response
- the conflict table prevents a request from being granted if its block address is already in the bus pipeline
  - maintains single-block coherence
- memory writes fully bypass the bus and can come directly from the dcaches
  - due to the use of the MOESI protocol, the bus controller does not need to generate any memory writes
    - no BusWB response to snoop request
    - a memory write should only happen on dirty block eviction or flush
- instruction memory reads fully bypass the bus and can come directly from the icaches
  - instruction memory is not coherent
  - no support for self-modifying code
- potential optimization: upgrading requests
- MOESI state transition diagram
  - mostly standard MOESI, but can make some more assumptions since know only have 2 cores
    - <ins>underlined</ins> behaviors are unique to dual-core implementation
    - these cases allow a snoop of a block in S state to guarantee the ability to provide a BusCache, since the block in S does not have to compete with any other block potentially wanting to also provide a BusCache, which would be possible if >1 other core were being snooped

### Memory Controller

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/dual_mem_controller.sv



- arbitrate structural hazard of single exclusive access to 32-bit blocking RAM port
  - competing requests for memory access
    - imem0 read
    - imem1 read
    - dmem0 read
    - dmem1 read
    - dmem0 write
    - dmem1 write
  - single active request each for imem0 read, imem1 read
  - read buffer backlogs up to 8 dmem0 or dmem1 read requests
  - write buffer backlogs up to 8 dmem0 or dmem1 write requests
- provide forwarding of pending data memory writes to data memory reads to the same block
  - dmem read requests perform CAM search on write buffer while simultaneously starting RAM access
  - if block present in write buffer, forward value from write buffer to use as the dmem read response

## Synthesis Results

- Total Logic Elements: 74,853 / 114,480 ( 65 % )
  - Total Combinational Functions: 70,240 / 114,480 ( 61 % )
  - Dedicated Logic Registers: 21,888 / 114,480 ( 19 % )
- FMAX: 47.77 MHz

## Performance Results
All cycles reported are RAM CLK. CPUCLK = (RAM CLK - 1) / 2. "daxpy" is really an integer vector add loop. The daxpy program most clearly shows the out-of-order and pipelined bus benefits since future daxpy loop iterations can be started while independent memory accesses from previous iterations are waiting on completion. 

- multi.simple.loop.asm
  - LAT=0: 3175 cycles -> old 437: 3211 cycles
  - LAT=2: 3215 cycles -> old 437: 3245 cycles
  - LAT=6: 3271 cycles -> old 437: 3285 cycles
  - LAT=10: 3335 cycles -> old 437: 3337 cycles
- multi.simple.loop_hit.asm
  - LAT=0: 18533 cycles -> old 437: 6291 cycles
  - LAT=2: 18607 cycles -> old 437: 6331 cycles
  - LAT=6: 18649 cycles -> old 437: 6373 cycles
  - LAT=10: 18711 cycles -> old 437: 6433 cycles
- dual.mergesort_singlethreaded.asm:
  - LAT=0: 16095 cycles -> old 437: 17419 cycles
  - LAT=2: 17511 cycles -> old 437: 18541 cycles
  - LAT=6: 20295 cycles -> old 437: 21371 cycles
  - LAT=10: 23857 cycles -> old 437: 23911 cycles
- dual.mergesort.asm:
  - LAT=0: 10093 cycles -> old 437: 10863 cycles
  - LAT=2: 11353 cycles -> old 437: 11859 cycles
  - LAT=6: 14383 cycles -> old 437: 14623 cycles
  - LAT=10: 17731 cycles -> old 437: 16841 cycles
- daxpy.asm (single-threaded):
  - LAT=0: 84637 cycles -> old 437: 180353 cycles
  - LAT=2: 89415 cycles -> old 437: 214181 cycles
  - LAT=6: 98939 cycles -> old 437: 298249 cycles
  - LAT=10: 125001 cycles -> old 437: 374113 cycles
- dual.daxpy.asm:
  - LAT=0: 42553 cycles -> old 437: 111757 cycles
  - LAT=2: 45123 cycles -> old 437: 141783 cycles
  - LAT=6: 77887 cycles -> old 437: 208057 cycles
  - LAT=10: 117501 cycles -> old 437: 307675 cycles
- palgorithm.asm:
  - LAT=0: 237527 cycles -> old 437: 307135 cycles
  - LAT=2: 264485 cycles -> old 437: 370193 cycles
  - LAT=6: 343507 cycles -> old 437: 559447 cycles
  - LAT=10: 409817 cycles -> old 437: 720085 cycles

## Notes
- I am one person and I did not want to go completely insane in designing and verifying this system. This led to the following results:
  - Testbenches for each module (if they exist) were designed with initial versions of modules before various stages of integration and debug. Most testbenches will not pass all test cases for the current versions of the module. Some testbenches may be missing some inputs or outputs or for reasons other than this may fail to simulate.
  - I would not be surprised at all if there are bugs in the design that hurt performance but not correctness (e.g. something like a load restarting when it did not need to).
  - I would be only a little surprised if there are correctness issues in the design.
  - I was too lazy to implement any sort of memory dependence prediction. This is the primary culprit making certain non-trivial test cases worse on the 437_OoO design versus my old 437 design I used for the class labs (in-order pipeline, blocking dcaches, blocking atomic bus, no speculated memory accesses).
    - multi.simple.loop_hit.asm purposely targets this weakness. The massive performance loss can be easily seen.
- I treated this project as a learning experience, a design challenge, and a place to experiment.
  - I wasn't strictly aiming for performance maximization. I more wanted to implement certain architecture features, whether they made sense for performance or not. 
  - I made all my microarchitecture desicions based on the higher-level architecture overviews from ECE 565 and ECE 666. I challenged myself by figuring out all the unspecified and nitty-gritty details myself, not referring to other existing microarchitecture implementations. 
  - I was pleasantly surprised that some of my decisions matched real used methods.
    - notably mis-speculated instruction killing methods, which was not discussed in detail in ECE 565
  - I was not surprised that other decisions of mine were quite silly.
    - notably my ugly reservation stations in what should have been a proper R10K design with an isolated register file directly interacting with the functional units
      - the back-to-back forwarding I so preciously valued was not prioritized in real designs, or at least was not implemented in the way I did
- I was not nearly as careful as I should have been with memory consistency.
  - I intended for the system to follow sequential consistency, and I purposely tried to make microarchitecture decisions which enabled this
  - However, I decided to be thorough in my assembly testing and I found a scenario where the system fails sequential consistency and acts like TSO
    - multi.seqc.TSO_5.asm
    - failure is detailed in system.txt

## Potential Future Development
- Conversion from the MIPS subset to RISC-V RV32IA
  - or at least the RV32IA subset that ECE 437 implements
- Performance counters (e.g. dcache hit counts) for performance verification and insight for future design iterations
- Turning a basis of this design into a future iteration of Purdue ECE 437 where students can implement out-of-order cores, non-blocking caches, and pipelined buses!
