org 0x0000

# I->S

ori $s0, $zero, shared
ori $s1, $zero, result0
ori $t0, $zero, 0x3333

# core0_delay_loop_0
    # want so can guarantee vals in snoop_dcache1
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

lw $t0, 0($s0)
sw $t0, 0($s1)

# core0_delay_loop_1
    # want so can guarantee vals in snoop_dcache0
ori $a0, $zero, 0x0100
core0_delay_loop_1:
    addi $a0, $a0, -1
    bne $a0, $zero, core0_delay_loop_1
nop
nop
nop
nop
nop
nop
nop
nop

halt

org 0x0200

# I->E->S->evict:I->S

ori $s0, $zero, shared
ori $s1, $zero, result1
ori $t0, $zero, 0x2222

lw $t0, 0($s0)

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

# evict block
ori $s2, $zero, 0x2000
lw $t1, 0($s2)
ori $s3, $zero, 0x3000
lw $t1, 0($s3)

# core1_delay_loop_1
    # want so can guarantee evicted from snoop_dcache1
ori $a0, $zero, 0x0100
core1_delay_loop_1:
    addi $a0, $a0, -1
    bne $a0, $zero, core1_delay_loop_1
nop
nop
nop
nop
nop
nop
nop
nop

# get block again
lw $t0, 0($s0)
sw $t0, 0($s1)

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
