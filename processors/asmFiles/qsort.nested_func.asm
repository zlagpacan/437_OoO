org 0x0000

ori $2, $zero, 0x0200
ori $sp, $zero, 0xfc00

# main
main:
    # store start val
    # call func
    # store result
    # halt
    ori $t0, $zero, 0x53e2
    sw $t0, 0($2)
    jal func
    sw $t0, 4($2)
    halt

# nested func
nested_func:
    # load val
    # get half val
    # subtract half from val
    # store val
    # return
    ori $s1, $zero, 1

    lw $t0, 0($2)
    srlv $t1, $s1, $t0
    sub $t0, $t0, $t1
    sw $t0, 0($2)

    jr $ra

# func
func:
    # load val
    # loop
    # return

    ori $s6, $zero, 6

    start_loop:
        # check val > 6
            # call nested_func
            # restart loop
        lw $t0, 0($2)
        slt $t1, $s6, $t0
        beq $t1, $zero, exit_loop

        addi $sp, $sp, -4
        sw $ra, 4($sp)
        jal nested_func
        lw $ra, 4($sp)
        addi $sp, $sp, 4

        j start_loop

    exit_loop:
    jr $ra


