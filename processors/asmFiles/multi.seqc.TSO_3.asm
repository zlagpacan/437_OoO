###########################################################################################################
# core 0:
org 0x0000

# A = 1
# print(B)

# may want loop of ihit's here to make rest of program ihit

ori $s0, $zero, A
ori $s1, $zero, B
ori $s2, $zero, result0
ori $t0, $zero, 1

# loop to move away
ori $a0, $zero, 0x0100
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

# A = 1
sw $t0, 0($s0)

# print(B)
lw $t1, 0($s1)
sw $t1, 0($s2)

# loop to move away
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

# core0 checks results:

# get both results
ori $s0, $zero, result0
ori $s1, $zero, result1
lw $t0, 0($s0)
lw $t1, 0($s1)

# mark if valid at final_result:
    # (0,0) F
    # (0,1) T
    # (1,0) T
    # (1,1) T
    # OR
ori $s2, $zero, final_result
or $t2, $t0, $t1
sw $t2, 0($s2)

# mark out both results
ori $a0, $zero, 0xFFFF
sw $a0, 0($s0)
sw $a0, 0($s1)

halt

###########################################################################################################
# core 1:
org 0x0200

# B = 1
# print(A)

# may want loop of ihit's here to make rest of program ihit

ori $s0, $zero, A
ori $s1, $zero, B
ori $s2, $zero, result1
ori $t1, $zero, 1

# bring in A and B for hits
lw $a0, 0($s0)
lw $a0, 0($s1)

# loop to move away
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

# B = 1
sw $t1, 0($s1)

# print(A)
lw $t0, 0($s0)
sw $t0, 0($s2)

# loop to move away
ori $a0, $zero, 0x0100
core1_delay_loop_1:
    addi $a0, $a0, -1
    bne $a0, $zero, core1_delay_loop_1

halt

###########################################################################################################
# data
org 0x1000
A:
cfw 0x0
cfw 0x0

B:
cfw 0x0
cfw 0x0

result0:
cfw 0x0
cfw 0x0

result1:
cfw 0x0
cfw 0x0

final_result:
cfw 0x0
cfw 0x0
