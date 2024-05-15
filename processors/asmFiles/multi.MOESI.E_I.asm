org 0x0000

# I->M

ori $s0, $zero, shared
ori $s1, $zero, result0
ori $t0, $zero, 0xAAAA

# core0_delay_loop_0
    # want so can guarantee new vals in snoop_dcache1
ori $a0, $zero, 0x0080
core0_delay_loop_0:
    addi $a0, $a0, -1
    bne $a0, $zero, core0_delay_loop_0
nop
nop
nop
nop
nop
nop
nop
nop

# store word
sw $t0, 0($s0)

halt

org 0x0200

# I->E->I

ori $s0, $zero, shared
ori $s1, $zero, result1

# load word
lw $t0, 0($s0)
sw $t0, 0($s1)

# core1_delay_loop_0
    # want so can guarantee new vals in snoop_dcache0
ori $a0, $zero, 0x0100
core1_delay_loop_0:
    addi $a0, $a0, -1
    bne $a0, $zero, core1_delay_loop_0
nop
nop
nop
nop
nop
nop
nop
nop

halt

org 0x1000

shared:
cfw 0x1111
cfw 0xFFFF

result0:
cfw 0
cfw 0

result1:
cfw 0
cfw 0
