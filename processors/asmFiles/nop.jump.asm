#---------------------------------------
# Lab 3/4 Jump Unit Test
#---------------------------------------

# set the address for code segment
org 0x0000

# setup:
ori $a0, $zero, 0x0200  # starting address for mem dump check
ori $s0, $zero, 0x0     # val for unintended store (0)
ori $s1, $zero, 0x1     # val for intended store (1)
ori $a2, $zero, 0x0100  # register to jump to

####################
# down test cases: #
####################

# Unit Test 1: j down
test1:
    j test2
    nop
    sw $s0, 4($a0)  # shouldn't happen

# Unit Test 3: jal down
test3:
    jal check_test3
    nop
    sw $s0, 8($a0)  # shouldn't happen

check_test4:
    nop
    sw $ra, 20($a0) # should happen

# Unit Test 5: jr
test5:
    jr $a2
    nop

# second instruction segment
org 0x00fc

# jump target of register $a2
    sw $s0, 24($a0) # shouldn't happen
    sw $s1, 28($a0) # should happen
    
# Unit Test 6: jal/jr func call
test6:
    jal func
    nop
    halt

##################
# up test cases: #
##################

check_test3:
    nop
    sw $ra, 12($a0) # should happen

# Unit Test 4: jal up
test4:
    jal check_test4
    nop
    sw $s0, 16($a0) # shouldn't happen

# Unit Test 2: j up
test2:
    sw $s1, 0($a0)  # should happen
    j test3
    nop

func:
    sw $s1, 32($a0) # should happen
    jr $ra     
    nop

# memory check segment
org 0x0200

# starting memory values
cfw 0x11111111  # expect: 0x00000001 @ (0x80)
cfw 0x22222222  # expect: 0x22222222 @ (0x81)
cfw 0x33333333  # expect: 0x33333333 @ (0x82)
cfw 0x44444444  # expect: 0x0000001c @ (0x83)
cfw 0x55555555  # expect: 0x55555555 @ (0x84)
cfw 0x66666666  # expect: 0x00000114 @ (0x85)
cfw 0x77777777  # expect: 0x77777777 @ (0x86)
cfw 0x88888888  # expect: 0x00000001 @ (0x87)
cfw 0x99999999  # expect: 0x00000001 @ (0x88)

