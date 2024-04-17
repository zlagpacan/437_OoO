org 0x0000

ori $sp, $0, 0x3ffc
ori $3, $0, 10
jal main
sw $3, 0x0200($0)
sw $4, 0x0204($0)
sw $5, 0x0208($0)
sw $6, 0x020C($0)
halt

main:
    push $ra

    jal outer_func

    addi $5, $3, 1
    addi $6, $4, -1

    pop $ra
    jr $ra

inner_func:
    addi $3, $3, -1
    addi $4, $4, 1
    jr $ra

outer_func:
    push $ra

    jal inner_func

    pop $ra
    jr $ra
