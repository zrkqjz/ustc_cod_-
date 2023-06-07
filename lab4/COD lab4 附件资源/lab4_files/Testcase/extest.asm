.text
    addi    gp, x0, 0
TEST1:	# sll test	
    addi    gp, gp, 1
	addi    x5, x0, 2		# x5 = 2
    sll     x6, x5, x5      # x6 = 8
    addi    x7, x0, 8       # x7 = 8
	beq     x6, x7, TEST2
	beq     x0, x0, FAIL

FAIL:	
	lui x7 7
	addi x7 x7 0x700
	addi x7 x7 0x700
	addi x7 x7 0x100	# x7 = 7f00
	addi x8 x0 1
	sw x8 16(x7)		# led[1] = 0
	beq x0, x0, FAIL	# 失败时会在此处死循环

TEST2: # slli test
    addi    gp, gp, 1
	addi    x5, x0, 2		# x5 = 2
    slli    x6, x5, 2       # x6 = 8
    addi    x7, x0, 8       # x7 = 8
    beq     x6, x7, TEST3
	beq     x0, x0, FAIL

TEST3: # srl test
    addi    gp, gp, 1
	addi    x5, x0, 8		# x5 = 8
    addi    x6, x0, 1       # x6 = 1
    srl     x6, x5, x6      # x6 = 4
    addi    x7, x0, 4       # x7 = 4
	beq     x6, x7, TEST4
	beq     x0, x0, FAIL

TEST4: # sub test
    addi    gp, gp, 1
    addi    x5, x0, 16		# x5 = 16
    addi    x7, x0, 8       # x7 = 8
    sub     x6, x5, x7      # x6 = 8
    addi    x7, x0, 8       # x7 = 8
	beq     x6, x7, TEST5
	beq     x0, x0, FAIL

TEST5: # xor test
    addi    gp, gp, 1
    addi    x5, x0, 15		# x5 = 15
    addi    x7, x0, 7       # x7 = 7
    xor     x6, x5, x7      # x6 = 8
    addi    x7, x0, 8       # x7 = 8
	beq     x6, x7, TEST6
	beq     x0, x0, FAIL   

TEST6: # and test
    addi    gp, gp, 1
    addi    x5, x0, 15		# x5 = 15
    addi    x7, x0, 7       # x7 = 7
    and     x6, x5, x7      # x6 = 7
    addi    x7, x0, 7       # x7 = 7
	beq     x6, x7, TEST7
	beq     x0, x0, FAIL 

TEST7: # bne test
    addi    gp, gp, 1
	addi    x5, x0, 1		# x5 = 1
	addi    x6, x0, 2		# x6 = 2
	bne     x6, x5, TEST8
    beq     x0, x0, FAIL

TEST8: # bge test
    addi    gp, gp, 1
	addi    x5, x0, 1		# x5 = 1
	addi    x6, x0, 2		# x6 = 2
	bge     x6, x5, TEST9
    beq     x0, x0, FAIL

TEST9: # bltu test
    addi    gp, gp, 1
    addi    x5, x5, 1       # x5 = 1
    addi    x6, x5, -2      # x6 = -1
    bltu    x6, x5, WIN
    beq     x0, x0, FAIL

WIN:
	lui x7 7
	addi x7 x7 0x700
	addi x7 x7 0x700
	addi x7 x7 0x100	# x7 = 7f00
	addi x8 x0 1
	sw x8 12(x7)		# led[0] = 0
	beq x0, x0, WIN
