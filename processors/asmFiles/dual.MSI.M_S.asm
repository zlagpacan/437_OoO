# want M -> S MSI transition
    # store block then other cache loads block

# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0400
    lw $3, 0($2)    # load block (I->S), old value

    # 8 loops
    ori $t0, $zero, 4
    nop_loop0:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop0

        # during loop, other block should store block (I->M)
        # this block should invalidate (M->I)

    lw $3, 0($2)    # load block (I->S), updated written value

    sw $3, 28($2)   # store other block to prove have new val (I->M)

    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0400
    ori $3, $zero, 0xa1b2

    # 2 loops
    ori $t0, $zero, 2
    nop_loop1_0:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop1_0

    sw $3, 0($2)    # store block (I->M)

    # 8 loops
    ori $t0, $zero, 8
    nop_loop1_1:
        addi $t0, $t0, -1
        bne $t0, $zero, nop_loop1_1

        # during loop, other block should load block (I->S), this block loses write priveledge (M->S)

    sw $3, 20($2)   # store other block to prove have new val (I->M)

    halt

# data segment
org 0x0400
data:
    cfw 0x0123
    cfw 0x4567
    cfw 0x89ab
    cfw 0xcdef
