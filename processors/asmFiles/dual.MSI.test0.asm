# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0400
    ori $3, $zero, 0xc3d4

    # 8 loops
    ori $t0, $zero, 8
    nop_loop0:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop0

        # during loop, other block should store block (I->M)

    sw $3, 4($2)    # store block (I->M), get updated written value for word 0, write word 1

    sw $3, 16($2)   # store other block to prove have both new vals (I->M)
    sw $4, 20($2)

    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0400
    ori $3, $zero, 0xa1b2

    sw $3, 0($2)    # store block (I->M)

    # 8 loops
    ori $t0, $zero, 16
    nop_loop1:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop1

        # during loop, other block should store block (I->M), this block invalidated (M->I)

    lw $4, 4($2)    # load block, should miss, get updated value (I->S)

    sw $3, 24($2)   # store other block to prove have both new vals (I->M)
    sw $4, 28($2)

    halt

# data segment
org 0x0400
data:
    cfw 0x0123
    cfw 0x4567
    cfw 0x89ab
    cfw 0xcdef
