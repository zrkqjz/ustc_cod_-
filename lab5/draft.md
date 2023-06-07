# 改动
br_type从两位改为三位
imm_type删了
# Forward
| Opcode         | state |     |     |     |     |
| -------------- | ----- | --- | --- | --- | --- |
| addi x1, x0, 1 | ex    | mem | wb  | ..  | ..  |
| addi x2, x0, 0 |       | ex  | mem | wb  |     |
| addi x3, x1, 1 |       |     | ex  | mem | wb  | 

## wb前递
把wb段准备写回的数据前递，作为ALU的操作数

```verilog
if(rf_we_wb && (rf_wa_wb != 0) && (rf_ra0_ex == rf_wa_wb)) //wb前递
	rf_rd0_fe = 1'b1;
else 
	rf_rd0_fe = 1'b0;
if(rf_we_wb && (rf_wa_wb != 0) && (rf_ra1_ex == rf_wa_wb)) //wb前递
	rf_rd1_fe = 1'b1;
else 
	rf_rd1_fe = 1'b0;
```

## mem前递
```
addi x1, x0, 1 
addi x3, x1, 1
```

在第一条的mem段，第二条的ex段，需要把MEM段接收到的alu_ans前递，作为ALU的操作数

```verilog
if(rf_we_mem && (rf_wa_mem != 0) && (rf_ra0_ex == rf_wa_mem)) //mem前递
	rf_rd0_fe = 1'b1;
else 
	rf_rd0_fe = 1'b0;
if(rf_we_mem && (rf_wa_mem != 0) && (rf_ra1_ex == rf_wa_mem)) //mem前递
	rf_rd1_fe = 1'b1;
else 
	rf_rd1_fe = 1'b0;
```

## 都想前递
```
addi x1, x0, 1 
addi x1, x1, 1 
addi x2, x1, 1
```

在第三条的ex段，需要第二条mem段的前递，不需要第一条wb段的前递

```verilog
if(rf_ra0_ex == rf_wa_mem || rf_ra1_ex == rf_wa_mem) begin //获取mem段
      case (rf_wd_sel_mem)
          2'b00: begin //alu
              rf_rd0_fd = alu_ans_mem;
              rf_rd1_fd = alu_ans_mem;
          end
          2'b01: begin
              rf_rd0_fd = pc_add4_mem;
              rf_rd1_fd = pc_add4_mem;
          end
          2'b11: begin
              rf_rd0_fd = imm_mem;
              rf_rd1_fd = imm_mem;              
          end
          default:
              rf_rd0_fd = alu_ans_mem;
              rf_rd1_fd = alu_ans_mem;
      endcase
end
else if(rf_ra0_ex == rf_wa_wb || rf_ra1_ex == rf_wa_wb) begin//获取wb段
	rf_rd0_fd = rf_wd_wb;
	rf_rd1_fd = rf_wd_wb;
end
else begin //随便
	rf_rd0_fd = rf_wd_wb;
	rf_rd1_fd = rf_wd_wb;	
end
```
# Hazard
## load use
