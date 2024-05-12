############
# p0 code: #
############

org 0x0000
ori $t0, $zero, 0x1111
ori $s0, $zero, 0x2000

# repeat store loop
ori $s1, $zero, 0x20

store_loop_p0:
sw $t0, 0x0($s0)
addi $s0, $s0, 8
addi $s1, $s1, -1
bne $s1, $zero, store_loop_p0

halt

############
# p1 code: #
############

org 0x0200
ori $t0, $zero, 0x2222
ori $s0, $zero, 0x3000

# repeat store loop
ori $s1, $zero, 0x20

store_loop_p1:
sw $t0, 0x0($s0)
addi $s0, $s0, 8
addi $s1, $s1, -1
bne $s1, $zero, store_loop_p1

halt
