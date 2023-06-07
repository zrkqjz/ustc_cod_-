# 实验目的

- 理解RISC-V常用32位整数指令功能
- 熟悉RISC-V汇编仿真软件RARS，掌握程序调试的基本方法
- 设计用于生成斐波那契数列的RISC-V汇编程序设计，以及存储器初始化文件(COE)的生成方法
- 理解CPU调试模块PDU的使用方法
# 移位寄存器
## 代码
```verilog
module Shift_reg(
    input rst,
    input clk,          // Work at 100MHz clock

    input [31:0] din,   // Data input  
    input [3:0] hex,    // Hexadecimal code for the switches
    input add,          // Add signal
    input del,          // Delete signal
    input set,          // Set signal
    
    output reg [31:0] dout  // Data output
);

    // TODO
    reg [31:0] dout_mid;
    always @(posedge clk) begin
        if(rst) dout_mid <= 0;
        else if(set) dout_mid <=  din;
        else if(add) begin
            dout_mid <= {dout_mid[27:0], hex};
        end
        else if(del) begin
            dout_mid <= {4'b0, dout_mid[31:4]};
        end
        else
            dout_mid <= dout_mid;
    end
    always @(*) begin
        dout <= dout_mid;
    end
endmodule
```
使用位拼接实现移位。
## 上板结果
![](figs/Screenshot%202023-04-20%20232358.png)
与演示视频一致。
# 计算斐波那契-卢卡斯数列的代码
  
  ```asm line numbers
  .data
  elem1: .word 0x0001
  elem2: .word 0x0001
  .text
  #load
    lw a1, elem1
    lw a2, elem2
    addi a4, x0, 10 #a4 holds the number n
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
    addi a7, x0, 1
    ecall
    #newLine
    addi a0, x0, 10
    addi a7, x0, 11
    ecall
    ret
  exit:
    addi     a7, x0, 10
    ecall
  ```
```.data```段存储第一个和第二个元素，```.text```
段先读取第一个和第二个元素，调用```ecall```输出，随后进入循环，计算下一项的值。输出，更新前两项的值。

最终结果如图：
![](figs/Screenshot%202023-04-20%20225536.png)
# 外设输入和输出
完整代码贴在最后，此处分段说明。
## 数据段
 ```nasm {.line-numbers}
.data
kb_ready_addr: 	.word 0x00007f00
kb_register_addr:	.word 0x00007f04
display_register_addr:	.word 0x00007f0c
elem1: .word 0x0001
elem2: .word 0x0001
string: .string "\n"
 ```
## 输入轮询
```nasm 
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
```
在wait_for_ready段，循环检测kb_ready_addr是否为1，是则跳到ready段处理输入。

在ready段，将输入减去'0'，拼接到a4中，回到wait_for_ready等待下一个输入。

当输入';'时，跳到FLS处理，结束轮询。


## 斐波那契数列生成

```asm
    lw a1, elem1
    lw a2, elem2

    addi a4, a4, -2
    blez    a4, exit
    addi a0, a1, 0
    jal s4, output
    addi a0, a2, 0
    jal s4, output
loop0:
    add a0, a1, a2
    jal s4, output

    addi a1, a2, 0
    addi a2, a0, 0

    addi a4, a4, -1

    bgtz a4, loop0
    j exit
```
与之前类似，只是输出从ecall变为调用output段。此外，还需要检测输入的n是否大于2.
## 输出
输出的基本思路是先用sw指令将数据存入.data段里的string，随后用lbu指令每次读取一个二位16进制数，处理后输出。

21-24行将二位16进制数分为两个一位16进制数，分别存入t4和t5。

40-45行分别输出两位。

46-52行判断是否输出结束。

27-38行用于消除无效位数的0.当s11为0时，不断循环，直到碰到第一个非0的数时，将s11中的判断变量置1。

print段判断输出0-9还是a-f，并将其处理为相应的ASCII码。
```nasm
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
```

## 结果
40位结果如下：
![](figs/Screenshot%202023-04-20%20233105.png)
# 总结
- 本次实验难度适中。
- 使用外设输出时，记得将delay length设为1，以及设置memory configuration。
# 外设输入的完整代码
```nasm
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
```

