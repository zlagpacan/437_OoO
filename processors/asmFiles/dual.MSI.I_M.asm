# want I -> M MSI transition
    # store block

# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0400
    ori $3, $zero, 0xa1b2
    sw $3, 0($2)    # store first block (I->M)
    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0400
    ori $3, $zero, 0xc3d4
    sw $3, 8($2)    # store second block (I->M)
    halt

# data segment
org 0x0400
data:
    cfw 0x0123
    cfw 0x4567
    cfw 0x89ab
    cfw 0xcdef
