org 0x0000

# setup gauntlet vals
ori $2, $zero, 0x1000
ori $sp, $zero, 0xff00

ori $t1, $zero, 0xa1a1
ori $t2, $zero, 0xb2b2
ori $t3, $zero, 0xc3c3
ori $t4, $zero, 0xd4d4
ori $t5, $zero, 0xe5e5
ori $t6, $zero, 0xf6f6

# branch (don't take), sw, branch (don't take)
l1:
beq $t1, $zero, l2

# branch (don't take), sw, branch (take)
l2:
beq $t3, $zero, l3
sw $t4, 0($2)
bne $t6, $zero, l3
halt

# branch (don't take), sw, jump
l3:
beq $t2, $zero, l4
sw $t5, 4($2)
j l4

# branch horra
l4:
beq $t1, $zero, l5
sw $t1, 8($2)
l5:
bne $zero, $zero, l6
sw $t4, 12($2)
l6:
j l7
sw $2, 16($2)
l7:
bne $t6, $zero, l8
sw $t3, 20($2)
l8:
jal end
sw $t5, 24($2)

# branch (don't take), sw, halt
end:
beq $t3, $zero, purgatory
sw $t3, 200($2)
halt

purgatory:
sw $t4, 200($2)
halt
