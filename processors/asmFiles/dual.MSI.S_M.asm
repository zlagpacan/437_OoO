# want S -> M MSI transition
    # store block previously loaded

# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0400
    lw $3, 0($2)    # load block (I->S)

    # 8 loops
    ori $t0, $zero, 8
    nop_loop0:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop0

        # during loop, other block should load block (I-S)

    ori $4, $zero, 0xa1b2
    sw $4, 4($2)   # store block (S->M), other block should get invalidated (S->I)
    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0400

    # 4 loops
    ori $t0, $zero, 4
    nop_loop1:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop1

    sw $3, 4($2)    # store block (I->M), invalidate other cache (S->I)
    halt

# data segment
org 0x0400
data:
    cfw 0x0123
    cfw 0x4567
    cfw 0x89ab
    cfw 0xcdef
