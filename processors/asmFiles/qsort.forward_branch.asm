org 0x0000

# mem addr
ori $2, $zero, 0x0200

# incrementing converge val
ori $t0, $zero, 0x0001

# decrementing converge val
ori $t1, $zero, 0x4000

# shamt
ori $s1, $zero, 1

# loop through, squeezing $t0 and $t1 towards each other
loop:
sllv $t0, $s1, $t1
srlv $t1, $s1, $t1
bne $t0, $t1, loop 
sw $t0, 0($2)
sw $t1, 4($2)
halt
