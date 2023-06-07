.data
elem1: .word 0x0001
elem2: .word 0x0001
.text
#load
    addi a1, x0, 1
    addi a2, x0, 1
    addi a4, x0, 10 #a4 holds the number n
    addi a7, x0, 0
#print elem1, elem2
    addi a3, a1, 0
    jal print
    addi a3, a2, 0
    jal print
    addi a4, a4, -1
loop:
    add a3, a1, a2
    jal print
#update elem1, elem2
    addi a1, a2, 0
    addi a2, a3, 0
#update n
    addi a4, a4, -1
#loop
    blt zero, a4, loop
    j exit
print:#print a2
    addi a0, a3, 0
    addi a7, a7, 4
    sw   a0, 0(a7)
    ret
exit:
    addi 	a7, x0, 10
    ecall
