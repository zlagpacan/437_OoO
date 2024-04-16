# want I -> S MSI transition
    # load block

# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0400
    lw $3, 0($2)    # same word, same block (I->S)
    lw $4, 8($2)    # diff word, same block (I->S)

    # # 16 loops
    # ori $t0, $zero, 16 
    # nop_loop0:
    #     addi $t0, $t0, -1
    #     bne $t0, $zero, nop_loop0

    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0400
    lw $3, 0($2)    # same word, same block (I->S)
    lw $4, 12($2)   # diff word, same block (I->S)

    # # 16 loops
    # ori $t0, $zero, 16 
    # nop_loop1:
    #     addi $t0, $t0, -1
    #     bne $t0, $zero, nop_loop1

    halt

# data segment
org 0x0400
data:
    cfw 0x0123
    cfw 0x4567
    cfw 0x89ab
    cfw 0xcdef
