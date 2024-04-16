org 0x0000
ori $2, $zero, 0x0800
ori $3, $zero, 0x89abcdef
j label1

org 0x0040
label1:
lw $4, 0($2)
sw $3, 4($2)
j label2

org 0x0080
label2:
lw $4, 0($2)
sw $3, 8($2)
beq $zero, $zero, label3

org 0x00c0
label3:
lw $4, 0($2)
sw $3, 12($2)
beq $zero, $2, labeldont

label4:
lw $4, 0($2)
sw $3, 16($2)
halt

org 0x0800
cfw 0x01234567

org 0x1000
labeldont:
lw $4, 0($2)
sw $3, 200($2)
