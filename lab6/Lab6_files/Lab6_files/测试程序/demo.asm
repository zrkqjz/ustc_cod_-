.text
	addi a0, x0, 0xff
	addi a1, x0, 0
loop:	
	addi a1, a1, 1
	bne  a1, a0, loop
finish:
	beq  x0, x0, finish