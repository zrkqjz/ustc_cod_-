# 1. 实验目的
搭建一个多周期CPU，能运行RISC-V的部分指令，并正确处理各类冒险
# 2. 实验原理
## 2.1. 数据通路
采用手册中的数据通路，如下：

![](figs/datapath.png)
## 2.2. 写优先寄存器堆
```verilog
module RF

#(parameter WIDTH = 32)

(   input          clk,
   input  [4 : 0] ra0,
   output reg [WIDTH - 1 : 0] rd0,
   input  [4: 0] ra1,
   output reg [WIDTH - 1 : 0] rd1,
   input  [4 : 0] ra_dbg,
   output reg [WIDTH - 1 : 0] rd_dbg,
   input  [4 : 0] wa,
   input          we,
   input  [WIDTH - 1 : 0] wd
);

reg [WIDTH - 1 : 0] regfile[0 : 31];

integer i;
initial begin
i = 0;
while (i < 32) begin
   regfile[i] = 32'b0;
   i = i + 1;
end
regfile [2] = 32'h2ffc;
regfile [3] = 32'h1800;
end
   always @(posedge clk) begin
       if (we) regfile[wa] <= wd;
   end
 
   always @(*) begin
       if (ra1 == 5'h0)    rd1 = 32'h0;
       else if (ra1 == wa && we == 1) rd1 = wd;
       else                rd1 = regfile[ra1];
   end
 
   always @(*) begin
       if (ra0 == 5'h0)    rd0 = 32'h0;
       else if (ra0 == wa && we == 1) rd0 = wd;
       else                rd0 = regfile[ra0];
   end
 
   always @(*) begin
       if (ra_dbg == 5'h0)    rd_dbg = 32'h0;
       else if (ra_dbg == wa && we == 1) rd_dbg = wd;
       else                rd_dbg = regfile[ra_dbg];
   end

endmodule
```

当要读的地址ra和要写的地址wa一致时，直接输出要写的数据wd。注意写使能we也应该参与判断。

## 2.3. 作为段间寄存器的 PC
```verilog
module PC(
    input [31:0] pc_next,
    input rst,
    input clk,
    input stall,
    output reg [31:0] pc_cur
    );
    always @(posedge clk or posedge rst) begin
        if (rst) pc_cur <= 32'h0000_3000;
        else if(stall) pc_cur <= pc_cur;
        else pc_cur <= pc_next;
    end
  
endmodule
```
增加了一个stall控制信号。当需要stall时，pc_cur的值保持不变。

## 2.4. 控制单元的调整
```verilog
module Control(
    input [31:0] inst,
    output reg rf_re0,
    output reg rf_re1,
    output jal,
    output jalr,
    output [2:0] br_type,
    output reg wb_en,
    output reg [1:0] wb_sel,
    output reg alu_op_1,
    output reg alu_op_2,
    output [3:0] alu_ctrl,
    output reg mem_we,
    output reg [1:0] ALUOpc
    );
    always @(*) begin
        case (inst[6:0])
            7'b0010011://addi
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b11_1_00_0_0_1_10;
            7'b0110011://add
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b10_1_00_0_0_0_11;
            7'b0010111://auipc
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_1_00_0_1_1_10;
            7'b1101111://jal
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_1_01_0_1_1_10;
            7'b1100111://jalr
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_1_01_0_0_1_11;
            7'b1100011://beq
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_0_00_0_1_1_11;
            7'b0000011://lw
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_1_10_0_0_1_11;
            7'b0100011://sw
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_0_00_1_0_1_11;
            7'b0110111://lui
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b00_1_11_0_0_0_10;
            default:
                {ALUOpc, wb_en, wb_sel, mem_we, alu_op_1, alu_op_2, rf_re0, rf_re1} = 10'b0;
        endcase
    end

    //todo
    assign jal = (inst[6:0] == 7'b1101111)?1:0;
    assign jalr = (inst[6:0] == 7'b1100111)?1:0;

    assign br_type = (inst[6:0] == 7'b1100011)?inst[14:12]:3'b111;

    ALU_helper helper(
        .ALUOp(ALUOpc),
        .inst({inst[30],inst[14:12]}),
        .ALU_sel(alu_ctrl)
    );
endmodule
```
增加了读使能rf_re0和rf_re1，作为Hazard模块的判断依据。

## 2.5. 段间寄存器SEG_REG
```verilog
module SEG_REG(
   input       [31:0]  pc_cur_in,
   input       [31:0]  inst_in,
   input       [4:0]   rf_ra0_in,
   input       [4:0]   rf_ra1_in,
   input               rf_re0_in,
   input               rf_re1_in,
   input       [31:0]  rf_rd0_raw_in,
   input       [31:0]  rf_rd1_raw_in,
   input       [31:0]  rf_rd0_in,
   input       [31:0]  rf_rd1_in,
   input       [4:0]   rf_wa_in,
   input       [1:0]   rf_wd_sel_in,
   input               rf_we_in,
  //input       [2:0]   imm_type_in,
   input       [31:0]  imm_in,
   input               alu_src1_sel_in,
   input               alu_src2_sel_in,
   input       [31:0]  alu_src1_in,
   input       [31:0]  alu_src2_in,
   input       [3:0]   alu_func_in,
   input       [31:0]  alu_ans_in,
   input       [31:0]  pc_add4_in,
   input       [31:0]  pc_br_in,
   input       [31:0]  pc_jal_in,
   input       [31:0]  pc_jalr_in,
   input               jal_in,
   input               jalr_in,
   input       [2:0]   br_type_in,
   input               br_in,
   input       [1:0]   pc_sel_in,
   input       [31:0]  pc_next_in,
   input       [31:0]  dm_addr_in,
   input       [31:0]  dm_din_in,
   input       [31:0]  dm_dout_in,
   input               dm_we_in,
   input               clk,
   input               flush,
   input               stall,
   output reg  [31:0]  pc_cur_out,
   output reg  [31:0]  inst_out, 
   output reg  [4:0]   rf_ra0_out, 
   output reg  [4:0]   rf_ra1_out, 
   output reg          rf_re0_out, 
   output reg          rf_re1_out, 
   output reg  [31:0]  rf_rd0_raw_out, 
   output reg  [31:0]  rf_rd1_raw_out, 
   output reg  [31:0]  rf_rd0_out, 
   output reg  [31:0]  rf_rd1_out, 
   output reg  [4:0]   rf_wa_out, 
   output reg  [1:0]   rf_wd_sel_out, 
   output reg          rf_we_out, 
 //output reg  [2:0]   imm_type_out, 
   output reg  [31:0]  imm_out, 
   output reg          alu_src1_sel_out, 
   output reg          alu_src2_sel_out, 
   output reg  [31:0]  alu_src1_out, 
   output reg  [31:0]  alu_src2_out, 
   output reg  [3:0]   alu_func_out, 
   output reg  [31:0]  alu_ans_out, 
   output reg  [31:0]  pc_add4_out, 
   output reg  [31:0]  pc_br_out, 
   output reg  [31:0]  pc_jal_out, 
   output reg  [31:0]  pc_jalr_out, 
   output reg          jal_out, 
   output reg          jalr_out, 
   output reg  [2:0]   br_type_out, 
   output reg          br_out, 
   output reg  [1:0]   pc_sel_out, 
   output reg  [31:0]  pc_next_out, 
   output reg  [31:0]  dm_addr_out, 
   output reg  [31:0]  dm_din_out, 
   output reg  [31:0]  dm_dout_out, 
   output reg          dm_we_out 
   );

    always @(posedge clk) begin

        if(flush) begin
           pc_cur_out       <= pc_cur_in;
           inst_out         <= 32'h0000_0033;
           rf_ra0_out       <= rf_ra0_out;
           rf_ra1_out       <= rf_ra1_out;
           rf_re0_out       <= rf_re0_out;
           rf_re1_out       <= rf_re1_out;
           rf_rd0_raw_out   <= 1'b0;
           rf_rd1_raw_out   <= 1'b0;
           rf_rd0_out       <= 1'b0;
           rf_rd1_out       <= 1'b0;
           rf_wa_out        <= 1'b0;
           rf_wd_sel_out    <= 1'b0;
           rf_we_out        <= 1'b0;
           imm_out          <= 1'b0;
           alu_src1_sel_out <= 1'b0;
           alu_src2_sel_out <= 1'b0;
           alu_src1_out     <= 1'b0;
           alu_src2_out     <= 1'b0;
           alu_func_out     <= 1'b0;
           alu_ans_out      <= 1'b0;
           pc_add4_out      <= pc_add4_in;
           pc_br_out        <= 1'b0;
           pc_jal_out       <= 1'b0;
           pc_jalr_out      <= 1'b0;
           jal_out          <= 1'b0;
           jalr_out         <= 1'b0;
           br_type_out      <= 3'b111;
           br_out           <= 1'b0;
           pc_sel_out       <= 1'b0;
           pc_next_out      <= 1'b0;
           dm_addr_out      <= 1'b0;
           dm_din_out       <= 1'b0;
           dm_dout_out      <= 1'b0;
           dm_we_out        <= 1'b0;
        end

        else if(stall) begin
          pc_cur_out       <= pc_cur_out      ;
          inst_out         <= inst_out        ;
          rf_ra0_out       <= rf_ra0_out      ;
          rf_ra1_out       <= rf_ra1_out      ;
          rf_re0_out       <= rf_re0_out      ;
          rf_re1_out       <= rf_re1_out      ;
          rf_rd0_raw_out   <= rf_rd0_raw_out  ;
          rf_rd1_raw_out   <= rf_rd1_raw_out  ;
          rf_rd0_out       <= rf_rd0_out      ;
          rf_rd1_out       <= rf_rd1_out      ;
          rf_wa_out        <= rf_wa_out       ;
          rf_wd_sel_out    <= rf_wd_sel_out   ;
          rf_we_out        <= rf_we_out       ;
          imm_out          <= imm_out         ;
          alu_src1_sel_out <= alu_src1_sel_out;
          alu_src2_sel_out <= alu_src2_sel_out;
          alu_src1_out     <= alu_src1_out    ;
          alu_src2_out     <= alu_src2_out    ;
          alu_func_out     <= alu_func_out    ;
          alu_ans_out      <= alu_ans_out     ;
          pc_add4_out      <= pc_add4_out     ;
          pc_br_out        <= pc_br_out       ;
          pc_jal_out       <= pc_jal_out      ;
          pc_jalr_out      <= pc_jalr_out     ;
          jal_out          <= jal_out         ;
          jalr_out         <= jalr_out        ;
          br_type_out      <= br_type_out     ;
          br_out           <= br_out          ;
          pc_sel_out       <= pc_sel_out      ;
          pc_next_out      <= pc_next_out     ;
          dm_addr_out      <= dm_addr_out     ;
          dm_din_out       <= dm_din_out      ;
          dm_dout_out      <= dm_dout_out     ;
          dm_we_out        <= dm_we_out       ;          
        end

        else begin

           pc_cur_out       <= pc_cur_in;  
           inst_out         <= inst_in;    
           rf_ra0_out       <= rf_ra0_in;      
           rf_ra1_out       <= rf_ra1_in;    
           rf_re0_out       <= rf_re0_in;    
           rf_re1_out       <= rf_re1_in;    
           rf_rd0_raw_out   <= rf_rd0_raw_in;
           rf_rd1_raw_out   <= rf_rd1_raw_in;
           rf_rd0_out       <= rf_rd0_in   ;  
           rf_rd1_out       <= rf_rd1_in   ;  
           rf_wa_out        <= rf_wa_in    ;  
           rf_wd_sel_out    <= rf_wd_sel_in;  
           rf_we_out        <= rf_we_in    ;  
           imm_out          <= imm_in      ;  
           alu_src1_sel_out <= alu_src1_sel_in;
           alu_src2_sel_out <= alu_src2_sel_in;
           alu_src1_out     <= alu_src1_in    ;
           alu_src2_out     <= alu_src2_in    ;
           alu_func_out     <= alu_func_in    ;
           alu_ans_out      <= alu_ans_in     ;
           pc_add4_out      <= pc_add4_in     ;
           pc_br_out        <= pc_br_in       ;
           pc_jal_out       <= pc_jal_in      ;
           pc_jalr_out      <= pc_jalr_in     ;
           jal_out          <= jal_in         ;
           jalr_out         <= jalr_in        ;
           br_type_out      <= br_type_in     ;
           br_out           <= br_in          ;
           pc_sel_out       <= pc_sel_in      ;
           pc_next_out      <= pc_next_in     ;
           dm_addr_out      <= dm_addr_in     ;
           dm_din_out       <= dm_din_in      ;
           dm_dout_out      <= dm_dout_in     ;
           dm_we_out        <= dm_we_in       ;          
       end

    end

endmodule
```

- 在不需要stall也不需要flush时，将输入传给对应的输出。
- 需要stall时，输出保持上一个周期的值不变。
- 需要flush时，输出应该是nop指令(add x0 x0 x0)的值。基本都是0，但br_type不能是0(beq对应的fun3)，选择了3'b111，不对应任何branch指令。
## 2.6. 冒险处理模块Hazard
```verilog
module Hazard(
    input       [4:0]   rf_ra0_ex,
    input       [4:0]   rf_ra1_ex,
    input               rf_re0_ex,
    input               rf_re1_ex,
    input       [4:0]   rf_wa_mem,
    input               rf_we_mem,
    input       [1:0]   rf_wd_sel_mem,
    input       [31:0]  alu_ans_mem,
    input       [31:0]  pc_add4_mem,
    input       [31:0]  imm_mem,
    input       [4:0]   rf_wa_wb,
    input               rf_we_wb,
    input       [31:0]  rf_wd_wb,
    input       [1:0]   pc_sel_ex,
    output reg          rf_rd0_fe,
    output reg          rf_rd1_fe,
    output reg  [31:0]  rf_rd0_fd,
    output reg  [31:0]  rf_rd1_fd,
    output reg          stall_if,
    output reg          stall_id,
    output reg          stall_ex,
    output reg          flush_if,
    output reg          flush_id,
    output reg          flush_ex,
    output reg          flush_mem
    );
    //forward
    always @(*) begin
        if(rf_we_mem && (rf_wa_mem != 0) && (rf_ra0_ex == rf_wa_mem)) //mem前�??
        	rf_rd0_fe = 1'b1;
        else if(rf_we_wb && (rf_wa_wb != 0) && (rf_ra0_ex == rf_wa_wb)) //wb前�??
	        rf_rd0_fe = 1'b1;
        else 
        	rf_rd0_fe = 1'b0;
        
        if(rf_we_mem && (rf_wa_mem != 0) && (rf_ra1_ex == rf_wa_mem)) //mem前�??
        	rf_rd1_fe = 1'b1;
        else if(rf_we_wb && (rf_wa_wb != 0) && (rf_ra1_ex == rf_wa_wb)) //wb前�??
        	rf_rd1_fe = 1'b1;
        else
        	rf_rd1_fe = 1'b0;
    end

    always @(*) begin
        if((rf_ra0_ex == rf_wa_mem) && (rf_re0_ex)) begin //获取mem�???
        	case (rf_wd_sel_mem)
                2'b00: begin //alu
                    rf_rd0_fd = alu_ans_mem;
                end 
                2'b01: begin
                    rf_rd0_fd = pc_add4_mem;
                end
                2'b10: begin
                    rf_rd0_fd = rf_wd_wb;
                end
                2'b11: begin
                    rf_rd0_fd = imm_mem;              
                end
                default: begin
                    rf_rd0_fd = alu_ans_mem;
                end
            endcase
        end
        else if((rf_ra0_ex == rf_wa_wb) && (rf_re0_ex)) begin//获取wb�???
        	rf_rd0_fd = rf_wd_wb;
        end
        else begin //随便
        	rf_rd0_fd = rf_wd_wb;
        end

        if((rf_ra1_ex == rf_wa_mem) && (rf_re1_ex)) begin
            case (rf_wd_sel_mem)
                2'b00: begin //alu
        	        rf_rd1_fd = alu_ans_mem;
                end 
                2'b01: begin
                    rf_rd1_fd = pc_add4_mem;
                end
                2'b10: begin
                    rf_rd1_fd = rf_wd_wb;
                end
                2'b11: begin
                    rf_rd1_fd = imm_mem;               
                end
                default: begin
        	        rf_rd1_fd = alu_ans_mem;
                end                
            endcase
        end
        else if((rf_ra1_ex == rf_wa_wb) && (rf_re1_ex)) begin//获取wb�???
         	rf_rd1_fd = rf_wd_wb;
        end
        else begin //随便
        	rf_rd1_fd = rf_wd_wb;	
        end
    end

    //load use
    always @(*) begin
        if((rf_wd_sel_mem == 2'b10) && (((rf_wa_mem == rf_ra0_ex) && rf_re0_ex)||((rf_wa_mem == rf_ra1_ex) && rf_re1_ex))) begin
            stall_if = 1'b1;
            stall_id = 1'b1;
            stall_ex = 1'b1;
            flush_if = 1'b0;
            flush_mem= 1'b1;
            /* flush_ex = 1'b1; */
        end
        else begin
            stall_if = 1'b0;
            stall_id = 1'b0;
            stall_ex = 1'b0;
            flush_if = 1'b0;
            flush_mem= 1'b0;    
            /* flush_ex = 1'b0;  */       
        end
    end

    //if branch 
    always @(*) begin
        if(pc_sel_ex != 2'b00) begin
            flush_ex = 1'b1;
            flush_id = 1'b1;
            /* flush_mem= 1'b1; */
        end
        else begin
            flush_ex = 1'b0;
            flush_id = 1'b0;
            /* flush_mem= 1'b0; */           
        end
    end
endmodule
```
需要处理三种冒险：
### 2.6.1. 前递
```asm
addi x1, x0, 1 
addi x2, x0, 0 
addi x3, x1, 1
```
此时在第三条指令处于EX段时，需要WB段的数据rf_wd_wb。前递发生的条件为`(rf_we_wb && (rf_wa_wb != 0) && (rf_ra1_ex == rf_wa_wb))`和`(rf_we_wb && (rf_wa_wb != 0) && (rf_ra0_ex == rf_wa_wb))`
```asm
addi x1, x0, 1 
addi x3, x1, 1
```
此时在第二条指令处于EX段时，需要MEM段的数据。具体前递哪一个数据由rf_wd_sel_mem决定。前递发生的条件为`(rf_we_mem && (rf_wa_mem != 0) && (rf_ra0_ex == rf_wa_mem))`和`(rf_we_mem && (rf_wa_mem != 0) && (rf_ra1_ex == rf_wa_mem))`。
```asm
addi x1, x0, 1 
addi x1, x1, 1 
addi x2, x1, 1
```
当同时需要前递时，优先MEM段前递，比如上面的例子，第三条指令取第二条指令的alu_ans作为操作数。
### 2.6.2. Load-use Hazard
```asm
lw x1, 0(x0) 
addi x2, x1, 1
```
当load指令的结果是下一条指令操作数时，需要等待一个周期。在本实验中，load指令执行到MEM段时检测到Load-Use Hazard，此时需要保存IF、ID、EX段的数据，在MEM段插入nop指令。这两个周期各段的指令如下：

| IF    | ID    | EX   | MEM | WB  |
| ----- | ----- | ---- | --- | --- |
| ...   | ...   | addi | lw  | ... |
| stall | stall | addi | nop | lw  | 

### 2.6.3. 跳转指令
本实验采用默认分支不发生的策略。如果分支发生，在分支指令的EX段被检测到，此时需要清空IF、ID段的指令。判断分支发生可以用pc_sel_ex信号。

# 3. 估计时钟周期
Load-Use Hazard需要插入一个气泡，预测错误需要插入2个气泡。如果load指令占25%，其中20%导致Load-Use Hazard；分支指令占20%，其中60%选择分支；那么$CPI=1+0.25*0.2*1+0.2*0.6*2=1.21$

# 4. 遇到的问题
- load-use冒险应该在load的ex阶段检测，lab5写的有问题，lab6已经更正。
- 端口连线和声明工作量有点大，需要合理使用编辑器的查找替换。

