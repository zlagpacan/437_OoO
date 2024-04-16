org 0x0000
ori $sp, $zero, 0x0800
ori $2, $zero, 0xcdef

# push reg 2 to stack
push $2
# addi $29, $29, -4
# sw $2, 0($29)

halt
