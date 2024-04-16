# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x0400

    # get LL ratio'd
    ll $3, 0($2)
    addi $3, $3, 0x1010
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    # nice try
    sc $3, 0($2)
    sw $3, 8($2)

    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x0400

    # quick R, M, W
    ll $3, 0($2)
    addi $3, $3, 0x0909
    sc $3, 0($2)
    sw $3, 12($2)

    halt

# data segment
org 0x0400
data:
    cfw 0xa1a1
    cfw 0xdead
    cfw 0xdead
    cfw 0xdead
