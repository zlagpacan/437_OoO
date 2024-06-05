# 437_OoO

## Constraints
- based in Purdue ECE 437 system
  - 1x blocking 32-bit ram interface with (LAT-1)/2 cycles of latency
  - lower 16-bit address space
- MIPS integer subset
  - see 437_OoO/asm_i.txt
 
## Architecture
![image](https://github.com/zlagpacan/437_OoO/assets/89352193/0b220e9f-3a36-41f5-bf3f-fc6691823756)


## Synthesis Results

- Total Logic Elements: 74,853 / 114,480 ( 65 % )
  - Total Combinational Functions: 70,240 / 114,480 ( 61 % )
  - Dedicated Logic Registers: 21,888 / 114,480 ( 19 % )
- FMAX: 47.77 MHz

## Perf Results
All cycles reported are RAM CLK. CPUCLK = (RAM CLK - 1) / 2

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
