ori $2, $0, 0x80
ori $3, $0, 0xabcd
sw $3, 0($2)
ori $4, $0, 0x90
ori $5, $0, 0xef01
ori $6, $0, 0x100
ori $7, $0, 0x2345
sw $5, 0($4)
sw $7, 0($6)
halt
