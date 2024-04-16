org 0x0000

ori $3, $0, 10
jal outer_func
sw $3, 0x0200($0)
sw $4, 0x0204($0)
halt

outer_func:
    push $ra

    check_inner:
        beq $3, $0, done_inner
        jal inner_func
        j check_inner

    done_inner:
        pop $ra
        jr $ra

inner_func:
    addi $3, $3, -1
    addi $4, $4, 1
    jr $ra
