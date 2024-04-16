#---------------------------------------
# Lab 3/4 Halt Unit Test
#---------------------------------------

# set the address for code segment
org 0x0000

# setup:
ori $s0, $zero, 0x0100  # address to store to
ori $s1, $zero, 0x1 # should happen value to store
ori $s2, $zero, 0x2 # shouldn't store, spacer to avoid RAW
ori $s3, $zero, 0x3 # shouldn't store, spacer to avoid RAW

# pre halt:
sw $s1, 0($s0)  # should happen
halt

# post halt:
sw $s2, 4($s0)  # shouldn't happen
# halt
