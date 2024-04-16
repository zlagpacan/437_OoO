org 0x0000

ori $2, $zero, 0x0200

# predict take, shouldn't take
ori $t0, $zero, 50
ori $s0, $zero, 15

take_loop:
addi $t0, $t0, -1
beq $t0, $s0, take_loop
sw $t0, 0($2)

# predict don't take, should take
ori $t1, $zero, 32
ori $s1, $zero, 74

dont_take_loop:
beq $t1, $s1, done_dont_take_loop
addi $t1, $t1, 2
j dont_take_loop

done_dont_take_loop:
sw $t1, 4($2)
halt
