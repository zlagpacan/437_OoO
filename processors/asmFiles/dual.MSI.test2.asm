# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x45C

    # big yikes loop 0
    ori $t0, $zero, 0x0004
    big_yikes_loop_0:

        # split 01
        lw $s0, 0($2)
        lw $s1, 4($2)
        add $s4, $s0, $s1
        sw $s4, 0($2)

        # split 12
        lw $s1, 4($2)
        lw $s2, 8($2)
        add $s4, $s1, $s2
        sw $s4, 4($2)

        # split 23
        lw $s2, 8($2)
        lw $s3, 12($2)
        add $s4, $s2, $s3
        sw $s4, 8($2)

        # split 30
        lw $s3, 12($2)
        lw $s0, 0($2)
        add $s4, $s3, $s0
        sw $s4, 12($2)
        
        # loop control
        addi $t0, $t0, -1
        beq $t0, $zero, big_yikes_loop_0

    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x45C

    # big yikes loop 1
    ori $t0, $zero, 0x0004
    big_yikes_loop_1:

        # split 01
        lw $s0, 0($2)
        lw $s1, 4($2)
        add $s4, $s0, $s1
        sw $s4, 0($2)

        # split 12
        lw $s1, 4($2)
        lw $s2, 8($2)
        add $s4, $s1, $s2
        sw $s4, 4($2)

        # split 23
        lw $s2, 8($2)
        lw $s3, 12($2)
        add $s4, $s2, $s3
        sw $s4, 8($2)

        # split 30
        lw $s3, 12($2)
        lw $s0, 0($2)
        add $s4, $s3, $s0
        sw $s4, 12($2)

        # loop control
        addi $t0, $t0, -1
        beq $t0, $zero, big_yikes_loop_1

    halt

# data segment
org 0x045C
data:
cfw 0x0001
cfw 0x0002
cfw 0x0003
cfw 0x0004
