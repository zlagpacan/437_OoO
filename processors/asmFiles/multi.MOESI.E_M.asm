org 0x0000

# I->S

ori $s0, $zero, shared
ori $s1, $zero, result0

# core0_delay_loop_0
    # want so can guarantee new vals in snoop_dcache1
ori $a0, $zero, 0x0080
core0_delay_loop_0:
    addi $a0, $a0, -1
    bne $a0, $zero, core0_delay_loop_0

lw $t0, 0($s0)
sw $t0, 0($s1)

halt

org 0x0200

# I->E->S

ori $s0, $zero, shared
ori $s1, $zero, result1
ori $t0, $zero, 0x2222

lw $t0, 0($s0)
addi $t0, $t0, 0x1111
sw $t0, 0($s0)

# core1_delay_loop_0
    # want so can guarantee new vals in snoop_dcache1
ori $a0, $zero, 0x0100
core1_delay_loop_0:
    addi $a0, $a0, -1
    bne $a0, $zero, core1_delay_loop_0

# load in other word in O block (avoid SQ forward)
lw $t1, 4($s0)
sw $t1, 0($s1)

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
