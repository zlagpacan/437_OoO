org 0x0000

# I->E->flushed->S
# I->E->flushed->I

ori $s0, $zero, shared0
ori $s1, $zero, shared1
ori $s2, $zero, result0

lw $t0, 0($s0)
lw $t1, 0($s1)

sw $t0, 0($s2)
sw $t1, 4($s2)

halt

org 0x0200

# I->S snoop
# I->M snoop

ori $s0, $zero, shared0
ori $s1, $zero, shared1
ori $s2, $zero, result1

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

lw $t0, 0($s0)
ori $t1, $zero, 0xFFFF
sw $t1, 4($s1)

halt

org 0x1000

shared0:
cfw 0x1111
cfw 0x2222

shared1:
cfw 0x3333
cfw 0x4444

result0:
cfw 0x0
cfw 0x0

result1:
cfw 0x0
cfw 0x0
