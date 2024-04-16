org 0x0000

ori $2, $zero, 0x2000


# collision on predict take, shouldn't take

# take loop
branch_slot_1a:

ori $t0, $zero, 28
ori $s0, $zero, 13

take_loop1:
addi $t0, $t0, -1
j branch_1a

org 0x0100
branch_1a:
beq $t0, $s0, take_loop1
sw $t0, 0($2)
j branch_slot_1b


# collision on predict don't take, should take

# don't take loop
branch_slot_2a:

ori $t1, $zero, 32
ori $s1, $zero, 74
j dont_take_loop

org 0x0200
dont_take_loop:
beq $t1, $s1, done_dont_take_loop
addi $t1, $t1, 2
j dont_take_loop

done_dont_take_loop:
sw $t1, 8($2)
j branch_slot_2b

###########################################################################################################

org 0x8000


# collision on predict take, shouldn't take

# don't take branch
branch_slot_1b:

ori $t0, $zero, 0xabcd
j branch_1b

org 0x8100
branch_1b:
beq $t0, $zero, purgatory
sw $t0, 4($2)

j branch_slot_2a


# collision on predict don't take, should take

# take branch
branch_slot_2b:

ori $t1, $zero, 0xef01
j branch_2b

org 0x8200
branch_2b:
bne $t1, $zero, exit

# purgatory: shouldn't get here

purgatory:
ori $s7, $zero, 0xdead
sw $s7, 200($2)
halt

exit:
ori $s6, $zero, 0xabcd
sw $s6, 12($2)
halt

