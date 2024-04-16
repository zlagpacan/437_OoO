org 0x0000

ori $3, $zero, 0x0400
ori $t2, $zero, 2

jal spook

end:
halt

spook:
# overwrite $ra with nested jal, branch to escape incorrect $ra
    # iterate through $t0 and also store $t0
ori $t0, $zero, 4
jal sub_spook
addi $t0, $t0, -1
beq $t0, $zero, end
jr $ra

    sub_spook:
    # get valid mem address and sw there
    sllv $t1, $t2, $t0
    add $3, $3, $t1
    sw $t0, 0($3)
    jr $ra
