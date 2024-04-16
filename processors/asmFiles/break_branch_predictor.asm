org 0x0000

ori $1, $zero, 0xdead
ori $2, $zero, 0xbeef
ori $3, $zero, 0x0100
j low_segment

org 0x0040
low_segment:
ori $4, $zero, 0x0008
low_loop_start:
addi $4, $4, -1
bne $4, $zero, low_loop_start
sw $1, 0($3)
j high_segment

org 0xf040
high_segment:
ori $5, $zero, 0x0008
high_loop_start:
addi $5, $5, -1
bne $5, $zero, high_loop_start
sw $2, 4($3)
halt



