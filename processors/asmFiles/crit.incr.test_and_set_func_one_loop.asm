###########
# core 0: #
###########
org 0x0000

# init pointers
ori $s0, $zero, lock
ori $s1, $zero, value

# update value
ori $t1, $zero, 0x1F
sw $t1, 0($s1)

# loop wait unlock
ori $a0, $zero, 0x0080
incr_loop_core0:
    addi $a0, $a0, -1
    bne $a0, $zero, incr_loop_core0

# unlock
sw $zero, 0($s0)

halt

###########
# core 1: #
###########
org 0x0200

jal incr_func

halt

##########
# funcs: #
##########
org 0x0400

incr_func:

    # init pointers
    ori $s0, $zero, lock
    ori $s1, $zero, value

    # unlock:
    unlock_loop:

        # test and set
        test_and_set_loop:
            ori $t1, $zero, 1
            ll $t0, 0($s0)
            sc $t1, 0($s0)
            beq $t1, $zero, test_and_set_loop

        # check unlocked
        bne $t0, $zero, unlock_loop

    # increment
    lw $t2, 0($s1)
    addi $t2, $t2, 1
    sw $t2, 0($s1)

    # unlock
    sw $zero, 0($s0)

    # return
    jr $ra

#########
# data: #
#########
org 0x1000

lock:
cfw 0x0
cfw 0x0

value:
cfw 0x0
cfw 0x0
