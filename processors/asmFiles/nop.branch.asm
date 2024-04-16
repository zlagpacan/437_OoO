#---------------------------------------
# Lab 3/4 Branch Unit Test
#---------------------------------------

# set the address for code segment
org 0x0000

# setup:
ori $a0, $zero, 0x0200  # starting address for mem dump check
ori $s0, $zero, 0x0     # val for unintended store (0)
ori $s1, $zero, 0x1     # val for intended store (1)

ori $t0, $zero, 0xb7a3  # first comp val
ori $t1, $zero, 0xb7a3  # second comp val
ori $t2, $zero, 0xa905  # third comp val
ori $t3, $zero, 0xa805  # fourth comp val

####################
# down test cases: #
####################

# Unit Test 1: beq, take branch down
test1:
    beq $t0, $t1, test2 # should take branch
    nop
    nop
    nop
    notake1:
        sw $s0, 0($a0)  # shouldn't happen

# Unit Test 3: beq, don't take branch
test3:
    beq $t0, $t2, take3 # shouldn't take branch
    nop
    nop
    nop
    notake3:
        sw $s1, 8($a0)  # should happen
    take3:
        sw $s1, 12($a0) # should happen

# Unit Test 4: bne, don't take branch
test4:
    bne $t1, $t0, take4 # shouldn't take branch
    nop
    nop
    nop
    notake4:
        sw $s1, 16($a0) # should happen
    take4:
        sw $s1, 20($a0) # should happen

# Unit Test 5: bne, take branch down
test5:
    bne $t3, $zero, test6   # should take branch
    nop
    nop
    nop
    notake5:
        sw $s0, 24($a0)     # shouldn't happen

# done testing
finish:
    halt

##################
# up test cases: #
##################

# second instruction segment
org 0x00fc

# Unit Test 6: bne, take branch up
test6:
    bne $t0, $zero, finish  # should take branch
    nop
    nop
    nop
    notake6:
        sw $s0, 28($a0)     # shouldn't happen

# Unit Test 2: beq, take branch up
test2: 
    beq $t1, $t0, test3 # should take branch
    nop
    nop
    nop
    notake2:
        sw $s0, 4($a0)  # shouldn't happen

# memory check segment
org 0x0200

# starting memory values
cfw 0x11111111  # expect: 0x11111111 @ (0x80)
cfw 0x22222222  # expect: 0x22222222 @ (0x81)
cfw 0x33333333  # expect: 0x00000001 @ (0x82)
cfw 0x44444444  # expect: 0x00000001 @ (0x83)
cfw 0x55555555  # expect: 0x00000001 @ (0x84)
cfw 0x66666666  # expect: 0x00000001 @ (0x85)
cfw 0x77777777  # expect: 0x77777777 @ (0x86)
cfw 0x88888888  # expect: 0x88888888 @ (0x87)
