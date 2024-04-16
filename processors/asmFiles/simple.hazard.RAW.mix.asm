org 0x0000

ori $8, $zero, 0x0100
ori $9, $zero, 0x0200

# EX to 1st and Mem to 2nd (reg)
ori $1, $zero, 0xa1b2
ori $2, $zero, 0x1a2b
add $3, $2, $zero
sw $3, 0($9)

# EX to 1st and Mem to 2nd (load)
lw $1, 0($8)
ori $2, $zero, 0xf053
add $3, $1, $2
sw $3, 4($9) 

# # pain train
# lw $1, 4($8)
# xor $3, $2, $1
# and $1, $3, $1
# xori $3, $2, 0x5f6a
# add $2, $1, $3
# sw $2, 8($9)
# sw $2, 12($9)

halt

org 0x0100
cfw 0x01234567
cfw 0x89abcdef
