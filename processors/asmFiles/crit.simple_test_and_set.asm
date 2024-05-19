###########
# core 0: #
###########
org 0x0000

# init pointers
ori $s0, $zero, lock
ori $s1, $zero, value

# unlock:
unlock_loop_core0:

    # test and set
    test_and_set_loop_core0:
        ori $t1, $zero, 1
        ll $t0, 0($s0)
        sc $t1, 0($s0)
        beq $t1, $zero, test_and_set_loop_core0

    # check unlocked
    bne $t0, $zero, unlock_loop_core0

# increment
lw $t2, 0($s1)
addi $t2, $t2, 1
sw $t2, 0($s1)

# unlock
sw $zero, 0($s0)

halt

###########
# core 1: #
###########
org 0x0200

# init pointers
ori $s0, $zero, lock
ori $s1, $zero, value

# unlock:
unlock_loop_core1:

    # test and set
    test_and_set_loop_core1:
        ori $t1, $zero, 1
        ll $t0, 0($s0)
        sc $t1, 0($s0)
        beq $t1, $zero, test_and_set_loop_core1

    # check unlocked
    bne $t0, $zero, unlock_loop_core1

# increment
lw $t2, 0($s1)
addi $t2, $t2, 1
sw $t2, 0($s1)

# unlock
sw $zero, 0($s0)

halt

##########
# funcs: #
##########
org 0x0400

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
