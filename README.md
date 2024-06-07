# 437_OoO
MIPS dual-core out-of-order CPU implementation based in Purdue ECE 437 infrastructure
 
## Goals
- implement R10K-based out-of-order core
- implement split transaction bus
- use MOESI snoopy cache coherence protocol
- use MSHRs
- system should act as memory bandwidth maximizing machine, not individual operation latency minimizer

## Constraints
- based in Purdue ECE 437 infrastructure
  - 1x blocking 32-bit ram interface with (LAT-1)/2 CPUCLK cycles of latency
  - lower 16-bit address space
- MIPS integer subset
  - see 437_OoO/asm_i.txt

## Architecture

### system
https://github.com/zlagpacan/437_OoO/blob/main/processors/source/system.sv

![image](https://github.com/zlagpacan/437_OoO/assets/89352193/67b8f4ba-192c-41d8-b72d-5de421fb83ae)

- dual-core
- MOESI snoopy cache coherence
- pipelined, split-transaction bus
- TSO memory consistency
  - only acts as TSO in single very specific case
  - in vast majority of cases, behavior follows Sequential Consistency
- out-of-order cores
- blocking icache
- non-blocking dcache

### core
https://github.com/zlagpacan/437_OoO/blob/main/processors/source/core.sv

![image](https://github.com/zlagpacan/437_OoO/assets/89352193/78c44893-29b7-4bb8-bb7e-e76840067b36)

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
      - especially relevant for loads and stores which can have long latencies and take up precious memory access slots

### icache

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/icache.sv

![image](https://github.com/zlagpacan/437_OoO/assets/89352193/94363922-ca5c-4129-947f-1c47adeb5802)

- 1KB capacity
- way0 is loop way, way1 is stream buffer
  - misses and prefetched blocks after miss are loaded into stream buffer way
  - on hit in stream buffer way, loop way is loaded with block
  - not quite true 2-way set associativy as can have entry in both loop way and stream buffer way
- blocking, synchronous interfaces
  - core side and mem side
- doesn't participate in coherence
  - don't support self-modifying code

### dcache

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/dcache.sv


- 1KB capacity
- 2-way set associative
  - simple lower index bit hashing into both ways
- non-blocking, asynchronous interfaces
  - core side and bus/mem side
- 4-entry write buffer
- 5x MSHRs
  - 4x load MSHRs
  - 1x store MSHR at end of write buffer
- 2x tag arrays
  - one for core requests, one for snoop requests
  - snoop can only modify tag if core not using
    - snoop responses are asynchronous, can be delayed
- participates in coherence
  - must make required bus requests if dcache req's don't have required permissions following MOESI protocol

### bus controller

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/bus_controller.sv


### mem controller

https://github.com/zlagpacan/437_OoO/blob/main/processors/source/dual_mem_controller.sv


## Synthesis Results

- Total Logic Elements: 74,853 / 114,480 ( 65 % )
  - Total Combinational Functions: 70,240 / 114,480 ( 61 % )
  - Dedicated Logic Registers: 21,888 / 114,480 ( 19 % )
- FMAX: 47.77 MHz

## Perf Results
All cycles reported are RAM CLK. CPUCLK = (RAM CLK - 1) / 2. "daxpy" is really an integer vector add. 

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
