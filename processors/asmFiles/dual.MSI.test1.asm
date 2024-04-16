# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0420
    ori $4, $zero, 0x0002
    
    # I -> S, S -> M, M -> S

    # wait for core 2 I -> M
    # 3 loops
    ori $t0, $zero, 3
    nop_loop0_0:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop0_0

    # I -> S
    lw $5, 4($2)
    or $4, $4, $5

    # wait for core 2 read while S
    # 3 loops
    ori $t0, $zero, 3
    nop_loop0_1:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop0_1
    
    # S -> M
    sw $4, 0($2)

    # wait for core 2 I -> S, this core M -> S
    # 3 loops
    ori $t0, $zero, 3
    nop_loop0_2:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop0_2

    # dump outputs
    sw $5, 8($2)
    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0420
    ori $4, $zero, 0x0001

    # I -> M, M -> S, S -> I, I -> S

    # I -> M
    sw $4, 4($2)

    # wait for core 1 I -> S, this core M -> S
    # 3 loops
    ori $t0, $zero, 10
    nop_loop1_0:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop1_0

    # read while S
    lw $5, 4($2)

    # wait for core 1 S -> M, this core S -> I
    # 3 loops
    ori $t0, $zero, 10
    nop_loop1_1:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop1_1

    # I -> S
    lw $6, 0($2)

    # dump outputs
    sw $5, 16($2)
    sw $6, 20($2)
    halt

# data segment
org 0x0420
data:
    cfw 0x0123
    cfw 0x4567
    cfw 0x89ab
    cfw 0xcdef
