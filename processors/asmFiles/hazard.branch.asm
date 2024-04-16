org 0x0000

ori $1, $zero, 0x0012
ori $2, $zero, 0x0034
ori $3, $zero, 0x0100
ori $4, $zero, 0x0005

# take branch many times bne
loop_beginning_bne:
    addi $1, $1, 0xffff
    bne $1, $zero, loop_beginning_bne

loop_end_bne:
    sw $1, 0($3)

# take branch many times bne
loop_beginning_beq:
    addi $2, $2, 0xffff
    slt $5, $2, $4
    beq $5, $zero, loop_beginning_beq

loop_end_beq:
    sw $2, 4($3)

ori $1, $zero, 0x0012
ori $2, $zero, 0x0000

# don't take branch
beq $1, $zero, loop_end_bne
sw $1, 8($3)
bne $2, $zero, loop_end_beq
sw $2, 12($3)

halt
