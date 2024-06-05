# 437_OoO

## Constraints
- based in Purdue ECE 437 system
  - 1x blocking 32-bit ram interface with (LAT-1)/2 cycles of latency
  - lower 16-bit address space
- MIPS integer subset
  - see 437_OoO/asm_i.txt
 
## Goals
- implement R10K-based out-of-order core
- implement split transaction bus
- use MOESI protocol
- use MSHRs
- system should act as memory bandwidth maximizing machine, not individual operation latency minimizer
 
## Architecture

### system
- dual-core
- MOESI snoopy cache coherence
- pipelined, split-transaction bus
- TSO memory consistency
  - only acts as TSO in single very specific case
  - in vast majority of cases, behavior follows Sequential Consistency
- out-of-order cores
- blocking icache
- non-blocking dcache
  - 1KB capacity
  - asynchronous interface
  - 5x MSHRs
  - participates in coherence
![image](https://github.com/zlagpacan/437_OoO/assets/89352193/67b8f4ba-192c-41d8-b72d-5de421fb83ae)

### core
- based on R10K out-of-order design
  - true register rename with physical register file, map table, free list
  - different from R10K: decided to use reservation stations in execution pipelines instead of proper issue queue
    - more easily support back-to-back forwarding of values on write data buses
  - target vector add program
- Fetch
  - 
- Dispatch
  - 
- Physical Register File
  - 64 physical registers
- 2x ALU Pipelines
  - perform instructions which require an ALU operation
    - and also some instructions that simply need to write registers
      - LUI, JAL
  - pipelines fully independent
  - 1x ALU each
  - 1x write data bus each
  - primary reasoning behind having 2 pipelines targets vector add program
    - vector element add can be in one pipeline's RS, waiting for load misses and the independent index add operation is free to proceed in the other pipeline
- Branch Pipeline
  - ensure conditional branch instructions branched to the correct PC
    - namely BEQ, BNE, JR
  - can send precise interrupt request to ROB
- Load-Store Queue
  - 4-entry Load Queue
  - 4-entry Store Queue
- ROB
  - contains precise interrupt checkpoint restart and serial rollback logic
  - 16-entries

### icache
- 1KB capacity
- way0 is hit cache, way1 is stream buffer
  - stream buffer prefetching on miss
- blocking, synchronous interface
- doesn't participate in coherence
  - don't support self-modifying code

### dcache
- 1KB capacity
- 2-way set associative
  - simple lower index bit hashing into both ways
- non-blocking, asynchronous interface
- 5x MSHRs
- 2x tag arrays
  - one for core requests, one for snoop requests
  - snoop can only modify tag if core not using
    - snoop responses are asynchronous, can be delayed
- participates in coherence
  - must make required bus requests if dcache req's don't have required permissions following MOESI protocol

### bus controller

### mem controller

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
