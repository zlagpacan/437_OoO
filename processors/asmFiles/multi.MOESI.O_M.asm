org 0x0000

# I->S->I->S

ori $s0, $zero, shared
ori $s1, $zero, result0

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

# load first word
lw $t0, 0($s0)
sw $t0, 0($s1)

# core0_delay_loop_1
    # want so can guarantee new vals in snoop_dcache1
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

# load second word
lw $t0, 4($s0)
sw $t0, 4($s1)

halt

org 0x0200

# I->M->O->M->O

ori $s0, $zero, shared
ori $s1, $zero, result1
ori $t0, $zero, 0xAAAA
ori $t1, $zero, 0xBBBB

# write first word
sw $t0, 0($s0)

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

# write second word
sw $t1, 4($s0)

# core1_delay_loop_1
    # want so can guarantee new vals in snoop_dcache0
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

# load first and second word
lw $t2, 0($s0)
lw $t3, 4($s0)
sw $t2, 0($s1)
sw $t3, 4($s1)

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
