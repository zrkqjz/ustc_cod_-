.data
kb_ready_addr: 	.word 0xFFFF0000
kb_register_addr:	.word 0xFFFF0004
string:	.asciz "Hello World\n"

.text
addi    x5, x0, 100
test:
add x2, x5, x5
lui x3, 100
auipc   x4, 100
beq x5, x2, test
jal x6, test  
