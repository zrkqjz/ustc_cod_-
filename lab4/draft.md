# 数据通路
![[Datapath.png]]
# add
```verilog
		alu_ctrl = 4'b0000;
		alu_op1_sel = 0; //rd0
		alu_op1_sel = 0; //rd1
		wb_sel = 0; //alu
		wb_en = 1;
```

# addi
```verilog
		alu_ctrl = 4'b0000;
		alu_op1_sel = 0; //rd0
		alu_op2_sel = 1; //imm
		wb_sel = 0; //alu
		wb_en = 1;
```
# lui
```verilog
		 wb_sel = 2'b11; //imm
		 wb_en = 1;
```
# auipc

```verilog
		wb_sel = 2'b00; //alu_res
		alu_op1_sel = 2'b01;//pc
		alu_op2_sel = 2'b01;//imm
		wb_en = 1;
```
# lw
```verilog
		alu_op1_sel = 0; //rs1
		alu_op2_sel = 2'b01;//imm
		alu_ctrl = 4'b0000;//+
		wb_sel = 2'b10; //mem
		wb_en = 1;
```
# sw
```verilog
		alu_op1_sel = 0; //rs1
		alu_op2_sel = 2'b01;//imm
		alu_ctrl = 4'b0000;//+
		mem_we = 1;
```
# beq
```verilog
		
```
# blt
# jal
```verilog
		alu_op1_sel = 1; //pc
		alu_op2_sel = 1; //imm
		wb_sel = 2'b01; //pc+4
		wb_en = 1;
```
# jalr
```verilog
		alu_op1_sel = 0; //rs1
		alu_op2_sel = 1; //imm
		wb_sel = 2'b01; //pc+4
		wb_en = 1;		
```
# ALU
| ALUOpc | instruction[30],ins[14:12] | ALU_ctr   |
| ------ | -------------------------- | --------- |
| 00     | xxxx                       | 0000(+)   |
| 10     | 0000                       | 0000(+)   |
| 10     | 1000                       | 0001(-)   |
| 10     | 0001                       | 1001(<<)  |
| 10     | 0100                       | 0111(^)   |
| 10     | 0101                       | 1000(>>)  |
| 10     | 0110                       | 0110(or)  |
| 10     | 0111                       | 0101(and) |
| 11     | x000                       | 0000(+)   |
| 11     | x100                       | 0111(^)   |
| 11     | x110                       | 0110(or)  |
| 11     | x111                       | 0101(and) |
| 11     | x001                          |    1001(<<)       |

# Control
| Opcode  | 例子  | ALUOpc | wb_en | wb_sel  | mem_we | alu_op_1 | alu_op_2 |
| ------- | ----- | ------ | ----- | ------- | ------ | -------- | -------- |
| 0010011 | addi  | 11     | 1     | 00(alu) | 0      | 0        | 1        |
| 0110011 | add   | 10     | 1     | 00      | 0      | 0        | 0        |
| 0010111 | auipc | 00     | 1     | 00      | 0      | 1        | 1        |
| 1101111 | jal   | 00     | 1     | 01      | 0      | 1        | 1        |
| 1100111 | jalr  | 00     | 1     | 01      | 0      | 0        | 1        |
| 1100011 | beq   | 00    | 0     | xx      | 0      | 1        | 0        | 
| 0000011 | lw    | 00     | 1     | 10      | 0      | 0        | 1        |
| 0100011 | sw    | 00     | 0     | xx      | 1      | 0        | 1        |
| 0110111 | lui   | xx     | 1     | 11      | 0    | xx       | xx       |
此外，还有信号jal和jalr，在遇到对应指令时输出。br_type直接取ins[14:12]即可。
# br_type
| ins[14:12] | 指令 | 
| ---------- | ---- | 
| 000        | beq  | 
| 001        | bne  | 
| 100        | blt  | 
| 101        | bge  | 
| 110        | bltu | 
| 111        | bgeu | 

# 选做指令
sll, slli, srl, sub, xor, and, bne, bge, bltu