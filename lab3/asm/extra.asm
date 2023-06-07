.data
kb_ready_addr: 	.word 0x00007f00
kb_register_addr:	.word 0x00007f04
display_register_addr:	.word 0x00007f0c
elem1: .word 0x0001
elem2: .word 0x0001
string: .string "\n"
.text
setup:
    # s5 <- kb ready bit addr
	# s6 <- kb register addr
    # s0 <- ';'
	la	t0, kb_ready_addr
	lw	s5, 0(t0)
	la	t0, kb_register_addr
	lw	s6, 0(t0)
    li  s0, 59
    li  s1, 10

wait_for_ready:
	# while(ready_bit == 0);
	lw	t0, 0(s5)
	beq	t0, zero, wait_for_ready
	
ready:
	lw	t0, 0(s6)
    bge t0, s0, OK
    addi    t0, t0, -48
    mul a4, a4, s1
    add a4, a4, t0
    j wait_for_ready
OK:
    jal FLS

FLS:
#load
    lw a1, elem1
    lw a2, elem2
#print elem1, elem2
    addi a4, a4, -2
    blez    a4, exit
    addi a0, a1, 0
    jal s4, output
    addi a0, a2, 0
    jal s4, output
loop0:
    add a0, a1, a2
    jal s4, output
#update elem1, elem2
    addi a1, a2, 0
    addi a2, a0, 0
#update n
    addi a4, a4, -1
#loop
    bgtz a4, loop0
    j exit
output:
    # a0 <- src
    # t0 <- string address
    # t1 <- number of bit
    # t2 <- pointer
    # s1 <- display_register_addr\
    # s2 <- 16
    # s3 <- 10
    # s4 <- return Address
    # s11 <- judge
    li  s11, 0
    li  s3, 10
    li  s2, 16
    la	t0, display_register_addr
    lw	s1, 0(t0)
    la  t0, string
    sw  a0, 0(t0)
    li  t1, 3
    add t0, t0, t1
loop1:
    lbu t3, 0(t0)
    divu    t4, t3, s2
    mul t5, t4, s2
    sub t5, t3, t5
    #
    bgtz    s11, printHigh 
    Judge:
    beqz t4, judgeLow
    addi s11, x0, 1
    j printHigh
    judgeLow:
    beqz t5, notPrint
    addi s11, x0, 1
    j printLow
    notPrint:
    addi    t0, t0, -1
    addi    t1, t1, -1
    beqz s11, loop1
    
    printHigh:
    addi    t3, t4, 0
    jal print
    printLow:
    addi    t3, t5, 0
    jal print
    addi    t0, t0, -1
    addi    t1, t1, -1
    bgez    t1, loop1
    #finish output
    addi    t3, x0, 10
    sw	t3, 0(s1)
    jr  s4
print:
    bge t3, s3, ge9 # if t3 >9 then target
    addi    t3, t3, 48
    j return  # jump to return
ge9:
    addi    t3, t3, 87
return:
    sw	t3, 0(s1)
    ret
exit:
    addi 	a7, x0, 10
    ecall
