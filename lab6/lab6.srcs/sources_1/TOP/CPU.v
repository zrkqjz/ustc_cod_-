`timescale 1ns / 1ps

/* 
 *   Author: YOU
 *   Last update: 2023.04.20
 */

module CPU(
    output [2:0] func3_mem,
    output [31:0] inst_if,
    output [31:0] inst_id,
    output [31:0] inst_ex,
    output [31:0] test2,
    output [31:0] test3,
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,      // Instruction address (The same as current PC)
    input [31:0] im_dout,       // Instruction data (Current instruction)
    output [31:0] mem_addr,     // Memory read/write address
    output mem_we,              // Memory writing enable		            
    output [31:0] mem_din,      // Data ready to write to memory
    input [31:0] mem_dout,	    // Data read from memory

    output [31:0] test,
    // Debug BUS with PDU
    output [31:0] current_pc, 	        // Current_pc, pc_out
    output [31:0] next_pc,              // Next_pc, pc_in    
    input [31:0] cpu_check_addr,	    // Check current datapath state (code)
    output [31:0] cpu_check_data    // Current datapath state data
);
    
    
    // Write your CPU here!
    // You might need to write these modules:
    //      ALU、RF、Control、Add(Or just add-mode ALU)、And(Or just and-mode ALU)、PCReg、Imm、Branch、Mux�??????????...
    
    //IF
    wire [31:0] pc_cur_if, pc_add4_if, pc_next, inst_raw, inst_if, dm_dout;
    wire [31:0] pc_cur_id, inst_id, pc_add4_id;
    wire [4:0] rf_ra0_id, rf_ra1_id, rf_wa_id;
    wire cpu_clk, stall_if, cpu_rst, flush_if, flush_id, stall_id;

    wire btb_hit, btb_fail, btb_hit_id, btb_hit_ex, btb_hit_mem, btb_hit_wb;
    wire [31:0] btb_target, btb_target_id, btb_target_ex, btb_target_mem, btb_target_wb;
    wire [1:0] pc_sel_btb;
    wire [31:0] pc_add4_btb;
    assign pc_add4_btb = (btb_hit)?btb_target:pc_add4_if;
    
    assign inst_raw = im_dout;
    assign dm_dout = mem_dout;
    assign cpu_clk = clk;
    assign cpu_rst = rst;

    ADD add(
        .a(pc_cur_if),
        .b(32'h4),
        .y(pc_add4_if)
    );
    PC pc(
        .pc_next(pc_next),
        .rst(cpu_rst),
        .clk(cpu_clk),
        .stall(stall_if),
        .pc_cur(pc_cur_if)
    );
    MUX1 inst_flush(
        .s0(inst_raw),
        .s1(32'h0000_0033),
        .sel(flush_if),
        .d(inst_if)
    );


    SEG_REG seg_reg_if_id(
        .pc_cur_in(pc_cur_if),
        .inst_in(inst_if),
        .rf_ra0_in(inst_if[19:15]),
        .rf_ra1_in(inst_if[24:20]),
        .rf_re0_in(1'h0),
        .rf_re1_in(1'h0),
        .rf_rd0_raw_in(32'h0),
        .rf_rd1_raw_in(32'h0),
        .rf_rd0_in(32'h0),
        .rf_rd1_in(32'h0),
        .rf_wa_in(inst_if[11:7]),
        .rf_wd_sel_in(2'h0),
        .rf_we_in(1'h0),
        .imm_in(32'h0),
        .alu_src1_sel_in(1'h0),
        .alu_src2_sel_in(1'h0),
        .alu_src1_in(32'h0),
        .alu_src2_in(32'h0),
        .alu_func_in(4'h0),
        .alu_ans_in(32'h0),
        .pc_add4_in(pc_add4_if),
        .pc_br_in(32'h0),
        .pc_jal_in(32'h0),
        .pc_jalr_in(32'h0),
        .jal_in(1'h0),
        .jalr_in(1'h0),
        .br_type_in(3'h0),
        .br_in(1'h0),
        .pc_sel_in(2'h0),
        .pc_next_in(32'h0),
        .dm_addr_in(32'h0),
        .dm_din_in(32'h0),
        .dm_dout_in(32'h0),
        .dm_we_in(1'h0),
        .clk(cpu_clk),
        .flush(flush_id),
        .stall(stall_id),
        .pc_cur_out(pc_cur_id),
        .inst_out(inst_id),
        .rf_ra0_out(rf_ra0_id),
        .rf_ra1_out(rf_ra1_id),
        .rf_wa_out(rf_wa_id),
        .pc_add4_out(pc_add4_id),
        .btb_hit_in(btb_hit),
        .btb_hit_out(btb_hit_id)
    );

    //ID
    wire [31:0] rf_rd0_raw_id, rf_rd1_raw_id, rf_rd_dbg_id, rf_wd_wb, imm_id;
    wire [4:0] rf_wa_wb;
    wire [3:0] alu_func_id, alu_func_ex;
    wire [2:0] br_type_id, br_type_ex;
    wire [1:0] rf_wd_sel_id;
    wire rf_we_wb, jal_id, jalr_id, rf_re0_id, rf_re1_id, rf_we_id, alu_src1_sel_id, alu_src2_sel_id, dm_we_id;
    wire flush_ex, stall_ex, rf_re0_ex, rf_re1_ex, rf_we_ex, alu_src1_sel_ex, alu_src2_sel_ex, jal_ex, jalr_ex, dm_we_ex;
    wire [31:0] pc_cur_ex, inst_ex, rf_rd0_raw_ex, rf_rd1_raw_ex, imm_ex, pc_add4_ex;
    wire [4:0] rf_ra0_ex, rf_ra1_ex, rf_wa_ex;
    wire [1:0] rf_wd_sel_ex;

    RF rf(
        .clk(cpu_clk), 
        .ra0(rf_ra0_id), 
        .rd0(rf_rd0_raw_id), 
        .ra1(rf_ra1_id), 
        .rd1(rf_rd1_raw_id), 
        .ra_dbg(cpu_check_addr[4:0]),
        .rd_dbg(rf_rd_dbg_id), 
        .wa(rf_wa_wb), 
        .we(rf_we_wb), 
        .wd(rf_wd_wb) 
    );

    Immediate immediate(
        .instruction(inst_id),
        .Imm(imm_id)
    );

    Control ctrl(
        .inst(inst_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .jal(jal_id),
        .jalr(jalr_id),
        .br_type(br_type_id),
        .wb_en(rf_we_id),
        .wb_sel(rf_wd_sel_id),
        .alu_op_1(alu_src1_sel_id),
        .alu_op_2(alu_src2_sel_id),
        .alu_ctrl(alu_func_id),
        .mem_we(dm_we_id)
    );

    SEG_REG seg_reg_id_ex(
        .pc_cur_in(pc_cur_id),
        .inst_in(inst_id),
        .rf_ra0_in(rf_ra0_id),
        .rf_ra1_in(rf_ra1_id),
        .rf_re0_in(rf_re0_id),
        .rf_re1_in(rf_re1_id),
        .rf_rd0_raw_in(rf_rd0_raw_id),
        .rf_rd1_raw_in(rf_rd1_raw_id),
        .rf_rd0_in(32'h0),
        .rf_rd1_in(32'h0),
        .rf_wa_in(rf_wa_id),
        .rf_wd_sel_in(rf_wd_sel_id),
        .rf_we_in(rf_we_id),
        .imm_in(imm_id),
        .alu_src1_sel_in(alu_src1_sel_id),
        .alu_src2_sel_in(alu_src2_sel_id),
        .alu_src1_in(32'h0),
        .alu_src2_in(32'h0),
        .alu_func_in(alu_func_id),
        .alu_ans_in(32'h0),
        .pc_add4_in(pc_add4_id),
        .pc_br_in(32'h0),
        .pc_jal_in(32'h0),
        .pc_jalr_in(32'h0),
        .jal_in(jal_id),
        .jalr_in(jalr_id),
        .br_type_in(br_type_id),
        .br_in(1'h0),
        .pc_sel_in(2'h0),
        .pc_next_in(32'h0),
        .dm_addr_in(32'h0),
        .dm_din_in(32'h0),
        .dm_dout_in(32'h0),
        .dm_we_in(dm_we_id),
        .clk(cpu_clk),
        .flush(flush_ex),
        .stall(stall_ex),
        .pc_cur_out(pc_cur_ex),
        .inst_out(inst_ex),
        .rf_ra0_out(rf_ra0_ex),
        .rf_ra1_out(rf_ra1_ex),
        .rf_re0_out(rf_re0_ex),
        .rf_re1_out(rf_re1_ex),
        .rf_rd0_raw_out(rf_rd0_raw_ex),
        .rf_rd1_raw_out(rf_rd1_raw_ex),
        .rf_wa_out(rf_wa_ex),
        .rf_wd_sel_out(rf_wd_sel_ex),
        .rf_we_out(rf_we_ex),
        .imm_out(imm_ex),
        .alu_src1_sel_out(alu_src1_sel_ex),
        .alu_src2_sel_out(alu_src2_sel_ex),
        .alu_func_out(alu_func_ex),
        .pc_add4_out(pc_add4_ex),
        .jal_out(jal_ex),
        .jalr_out(jalr_ex),
        .br_type_out(br_type_ex),
        .dm_we_out(dm_we_ex),
        .btb_hit_in(btb_hit_id),
        .btb_hit_out(btb_hit_ex)
    );

    //EX
    wire [31:0] pc_jalr_ex, alu_src1_ex, alu_src2_ex, alu_ans_ex, rf_rd0_ex, rf_rd1_ex, rf_rd0_fd, rf_rd1_fd;
    wire br_ex, rf_rd0_fe, rf_rd1_fe;
    wire [1:0] pc_sel_ex;
    wire flush_mem;
    wire [31:0]  pc_cur_mem;
    wire [31:0]  inst_mem;
    wire [4:0]   rf_ra0_mem;
    wire [4:0]   rf_ra1_mem;
    wire         rf_re0_mem;
    wire         rf_re1_mem;
    wire [31:0]  rf_rd0_raw_mem;
    wire [31:0]  rf_rd1_raw_mem;
    wire [31:0]  rf_rd0_mem;
    wire [31:0]  rf_rd1_mem;
    wire [4:0]   rf_wa_mem;
    wire [1:0]   rf_wd_sel_mem;
    wire         rf_we_mem;
    wire [31:0]  imm_mem;
    wire         alu_src1_sel_mem;
    wire         alu_src2_sel_mem;
    wire [31:0]  alu_src1_mem;
    wire [31:0]  alu_src2_mem;
    wire [3:0]   alu_func_mem;
    wire [31:0]  alu_ans_mem;
    wire [31:0]  pc_add4_mem;
    wire [31:0]  pc_br_mem;
    wire [31:0]  pc_jal_mem;
    wire [31:0]  pc_jalr_mem;
    wire         jal_mem;
    wire         jalr_mem;
    wire [2:0]   br_type_mem;
    wire         br_mem;
    wire [1:0]   pc_sel_mem;
    wire [31:0]  pc_next_mem;
    wire [31:0]  dm_addr_mem;
    wire [31:0]  dm_din_mem;
    wire         dm_we_mem;

    AND And(
        .a(32'hffff_fffe),
        .b(alu_ans_ex),
        .y(pc_jalr_ex)
    );

    MUX1 alu_sel1(
        .s0(rf_rd0_ex),
        .s1(pc_cur_ex),
        .sel(alu_src1_sel_ex),
        .d(alu_src1_ex)
    );

    MUX1 alu_sel2(
        .s0(rf_rd1_ex),
        .s1(imm_ex),
        .sel(alu_src2_sel_ex),
        .d(alu_src2_ex)
    );

    ALU alu(
        .a(alu_src1_ex),
        .b(alu_src2_ex),
        .func(alu_func_ex),
        .y(alu_ans_ex)
    );

    Branch branch(
        .br_type(br_type_ex),
        .rd0(rf_rd0_ex),
        .rd1(rf_rd1_ex),
        .br(br_ex)
    );

    Encoder encoder(
        .jal(jal_ex),
        .jalr(jalr_ex),
        .br(br_ex),
        .pc_sel(pc_sel_ex)        
    );

    MUX1 rf_rd0_fwd(
        .s0(rf_rd0_raw_ex),
        .s1(rf_rd0_fd),
        .sel(rf_rd0_fe),
        .d(rf_rd0_ex)        
    );
    MUX1 rf_rd1_fwd(
        .s0(rf_rd1_raw_ex),
        .s1(rf_rd1_fd),
        .sel(rf_rd1_fe),
        .d(rf_rd1_ex)        
    );

    wire  [31:0]  branch_cnt;
    wire  [31:0]  btb_succ_cnt;
    wire  [31:0]  btb_fail_cnt;
    BTB btb(
        .rst(cpu_rst),
        .clk(cpu_clk),
        .pc(pc_cur_if),
        .IDEX_pc(pc_cur_ex),
        //.enable(enable),//TODO:unknown signal
        .pc_sel_ex(pc_sel_ex),
        .IDEX_btb_hit(btb_hit_ex),
        .branch_taken(br_ex),
        .IDEX_branch_target(alu_ans_ex),
        .btb_hit(btb_hit),
        .btb_target(btb_target),
        .btb_fail(btb_fail),
        .pc_sel_btb(pc_sel_btb),
        .branch_cnt(branch_cnt),
        .btb_succ_cnt(btb_succ_cnt),
        .btb_fail_cnt(btb_fail_cnt)
    );

    SEG_REG seg_reg_ex_mem(
        .pc_cur_in(pc_cur_ex),
        .inst_in(inst_ex),
        .rf_ra0_in(rf_ra0_ex),
        .rf_ra1_in(rf_ra1_ex),
        .rf_re0_in(rf_re0_ex),
        .rf_re1_in(rf_re1_ex),
        .rf_rd0_raw_in(rf_rd0_raw_ex),
        .rf_rd1_raw_in(rf_rd1_raw_ex),
        .rf_rd0_in(rf_rd0_ex),
        .rf_rd1_in(rf_rd1_ex),
        .rf_wa_in(rf_wa_ex),
        .rf_wd_sel_in(rf_wd_sel_ex),
        .rf_we_in(rf_we_ex),
        .imm_in(imm_ex),
        .alu_src1_sel_in(alu_src1_sel_ex),
        .alu_src2_sel_in(alu_src2_sel_ex),
        .alu_src1_in(alu_src1_ex),
        .alu_src2_in(alu_src2_ex),
        .alu_func_in(alu_func_ex),
        .alu_ans_in(alu_ans_ex),
        .pc_add4_in(pc_add4_ex),
        .pc_br_in(alu_ans_ex),
        .pc_jal_in(alu_ans_ex),
        .pc_jalr_in(pc_jalr_ex),
        .jal_in(jal_ex),
        .jalr_in(jalr_ex),
        .br_type_in(br_type_ex),
        .br_in(br_ex),
        .pc_sel_in(pc_sel_ex),
        .pc_next_in(pc_next),
        .dm_addr_in(alu_ans_ex),
        .dm_din_in(rf_rd1_ex),
        .dm_dout_in(32'h0),
        .dm_we_in(dm_we_ex),
        .clk(cpu_clk),
        .flush(flush_mem),
        .stall(1'h0),
        .pc_cur_out(pc_cur_mem),
        .inst_out(inst_mem),
        .rf_ra0_out(rf_ra0_mem),
        .rf_ra1_out(rf_ra1_mem),
        .rf_re0_out(rf_re0_mem),
        .rf_re1_out(rf_re1_mem),
        .rf_rd0_raw_out(rf_rd0_raw_mem),
        .rf_rd1_raw_out(rf_rd1_raw_mem),
        .rf_rd0_out(rf_rd0_mem),
        .rf_rd1_out(rf_rd1_mem),
        .rf_wa_out(rf_wa_mem),
        .rf_wd_sel_out(rf_wd_sel_mem),
        .rf_we_out(rf_we_mem),
        .imm_out(imm_mem),
        .alu_src1_sel_out(alu_src1_sel_mem),
        .alu_src2_sel_out(alu_src2_sel_mem),
        .alu_src1_out(alu_src1_mem),
        .alu_src2_out(alu_src2_mem),
        .alu_func_out(alu_func_mem),
        .alu_ans_out(alu_ans_mem),
        .pc_add4_out(pc_add4_mem),
        .pc_br_out(pc_br_mem),
        .pc_jal_out(pc_jal_mem),
        .pc_jalr_out(pc_jalr_mem),
        .jal_out(jal_mem),
        .jalr_out(jalr_mem),
        .br_type_out(br_type_mem),
        .br_out(br_mem),
        .pc_sel_out(pc_sel_mem),
        .pc_next_out(pc_next_mem),
        .dm_addr_out(dm_addr_mem),
        .dm_din_out(dm_din_mem),
        .dm_we_out(dm_we_mem),
        .btb_hit_in(btb_hit_ex),
        .btb_hit_out(btb_hit_mem)
    );

    //MEM
    wire [31:0]  pc_cur_wb;
    wire [31:0]  inst_wb;
    wire [4:0]   rf_ra0_wb;
    wire [4:0]   rf_ra1_wb;
    wire         rf_re0_wb;
    wire         rf_re1_wb;
    wire [31:0]  rf_rd0_raw_wb;
    wire [31:0]  rf_rd1_raw_wb;
    wire [31:0]  rf_rd0_wb;
    wire [31:0]  rf_rd1_wb;
    wire [1:0]   rf_wd_sel_wb;
    wire [31:0]  imm_wb;
    wire         alu_src1_sel_wb;
    wire         alu_src2_sel_wb;
    wire [31:0]  alu_src1_wb;
    wire [31:0]  alu_src2_wb;
    wire [3:0]   alu_func_wb;
    wire [31:0]  alu_ans_wb;
    wire [31:0]  pc_add4_wb;
    wire [31:0]  pc_br_wb;
    wire [31:0]  pc_jal_wb;
    wire [31:0]  pc_jalr_wb;
    wire         jal_wb;
    wire         jalr_wb;
    wire [2:0]   br_type_wb;
    wire         br_wb;
    wire [1:0]   pc_sel_wb;
    wire [31:0]  pc_next_wb;
    wire [31:0]  dm_addr_wb;
    wire [31:0]  dm_din_wb;
    wire [31:0]  dm_dout_wb;
    wire         dm_we_wb;

    assign func3_mem = inst_mem[14:12];

    SEG_REG seg_reg_mem_wb(
        .pc_cur_in(pc_cur_mem),
        .inst_in(inst_mem),
        .rf_ra0_in(rf_ra0_mem),
        .rf_ra1_in(rf_ra1_mem),
        .rf_re0_in(rf_re0_mem),
        .rf_re1_in(rf_re1_mem),
        .rf_rd0_raw_in(rf_rd0_raw_mem),
        .rf_rd1_raw_in(rf_rd1_raw_mem),
        .rf_rd0_in(rf_rd0_mem),
        .rf_rd1_in(rf_rd1_mem),
        .rf_wa_in(rf_wa_mem),
        .rf_wd_sel_in(rf_wd_sel_mem),
        .rf_we_in(rf_we_mem),
        .imm_in(imm_mem),
        .alu_src1_sel_in(alu_src1_sel_mem),
        .alu_src2_sel_in(alu_src2_sel_mem),
        .alu_src1_in(alu_src1_mem),
        .alu_src2_in(alu_src2_mem),
        .alu_func_in(alu_func_mem),
        .alu_ans_in(alu_ans_mem),
        .pc_add4_in(pc_add4_mem),
        .pc_br_in(br_mem),
        .pc_jal_in(pc_jal_mem),
        .pc_jalr_in(pc_jalr_mem),
        .jal_in(jal_mem),
        .jalr_in(jalr_mem),
        .br_type_in(br_type_mem),
        .br_in(br_mem),
        .pc_sel_in(pc_sel_mem),
        .pc_next_in(pc_next_mem),
        .dm_addr_in(dm_addr_mem),
        .dm_din_in(dm_din_mem),
        .dm_dout_in(dm_dout),
        .dm_we_in(dm_we_mem),
        .clk(cpu_clk),
        .flush(1'h0),
        .stall(1'h0),
        .pc_cur_out(pc_cur_wb),
        .inst_out(inst_wb),
        .rf_ra0_out(rf_ra0_wb),
        .rf_ra1_out(rf_ra1_wb),
        .rf_re0_out(rf_re0_wb),
        .rf_re1_out(rf_re1_wb),
        .rf_rd0_raw_out(rf_rd0_raw_wb),
        .rf_rd1_raw_out(rf_rd1_raw_wb),
        .rf_rd0_out(rf_rd0_wb),
        .rf_rd1_out(rf_rd1_wb),
        .rf_wa_out(rf_wa_wb),
        .rf_wd_sel_out(rf_wd_sel_wb),
        .rf_we_out(rf_we_wb),
        .imm_out(imm_wb),
        .alu_src1_sel_out(alu_src1_sel_wb),
        .alu_src2_sel_out(alu_src2_sel_wb),
        .alu_src1_out(alu_src1_wb),
        .alu_src2_out(alu_src2_wb),
        .alu_func_out(alu_func_wb),
        .alu_ans_out(alu_ans_wb),
        .pc_add4_out(pc_add4_wb),
        .pc_br_out(pc_br_wb),
        .pc_jal_out(pc_jal_wb),
        .pc_jalr_out(pc_jalr_wb),
        .jal_out(jal_wb),
        .jalr_out(jalr_wb),
        .br_type_out(br_type_wb),
        .br_out(br_wb),
        .pc_sel_out(pc_sel_wb),
        .pc_next_out(pc_next_wb),
        .dm_addr_out(dm_addr_wb),
        .dm_din_out(dm_din_wb),
        .dm_dout_out(dm_dout_wb),
        .dm_we_out(dm_we_wb),
        .btb_hit_in(btb_hit_mem),
        .btb_hit_out(btb_hit_wb)
    );

    //wb
    assign im_addr = pc_cur_if;
    assign mem_addr = alu_ans_mem;
    assign mem_din = dm_din_mem;
    assign mem_we = dm_we_mem;
    assign current_pc = pc_cur_if;
    assign next_pc = pc_next;

    MUX2 reg_write_sel(
        .src0(alu_ans_wb),
        .src1(pc_add4_wb),
        .src2(dm_dout_wb),
        .src3(imm_wb),
        .sel(rf_wd_sel_wb),
        .res(rf_wd_wb)        
    );

    //Hazard
    Hazard hazard(
        .btb_fail(btb_fail),
        .rf_wd_sel_ex(rf_wd_sel_ex),
        .rf_wa_ex(rf_wa_ex),
        .rf_ra0_id(rf_ra0_id),
        .rf_ra1_id(rf_ra1_id),
        .rf_re0_id(rf_re0_id),
        .rf_re1_id(rf_re1_id),
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .rf_wa_mem(rf_wa_mem),
        .rf_we_mem(rf_we_mem),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem),
        .rf_wa_wb(rf_wa_wb),
        .rf_we_wb(rf_we_wb),
        .rf_wd_wb(rf_wd_wb),
        .pc_sel_ex(pc_sel_ex),
        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .flush_mem(flush_mem)       
    );

    MUX2 npc_sel(
        .src0(pc_add4_btb),
        .src1(pc_jalr_ex),
        .src2(alu_ans_ex),
        .src3(pc_add4_ex),
        .sel(pc_sel_btb),
        .res(pc_next)
    );

    //Debug
    wire [31:0] check_data_if;
    
    Check_Data_SEL check_data_sel_if(
        .pc_cur(pc_cur_if),
        .instruction(inst_if),
        .rf_ra0(inst_if[19:15]),
        .rf_ra1(inst_if[24:20]),
        .rf_re0(1'h0),
        .rf_re1(1'h0),
        .rf_rd0_raw(32'h0),
        .rf_rd1_raw(32'h0),
        .rf_rd0(1'h0),
        .rf_rd1(1'h0),
        .rf_wa(inst_if[11:7]),
        .rf_wd_sel(1'h0),
        .rf_wd(1'h0),
        .rf_we(1'h0),
        .immediate(1'h0),
        .alu_sr1(1'h0),
        .alu_sr2(1'h0),
        .alu_func(1'h0),
        .alu_ans(1'h0),
        .pc_add4(pc_add4_if),
        .pc_br(1'h0),
        .pc_jal(1'h0),
        .pc_jalr(1'h0),
        .pc_sel(1'h0),
        .pc_next(1'h0),
        .dm_addr(1'h0),
        .dm_din(1'h0),
        .dm_dout(1'h0),
        .dm_we(1'h0),
        .branch_cnt(branch_cnt),
        .btb_succ_cnt(btb_succ_cnt),
        .btb_fail_cnt(btb_fail_cnt),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_if)
    );
    
    wire [31:0] check_data_id;
    Check_Data_SEL check_data_sel_id(
        .pc_cur(pc_cur_id),
        .instruction(inst_id),
        .rf_ra0(rf_ra0_id),
        .rf_ra1(rf_ra1_id),
        .rf_re0(rf_re0_id),
        .rf_re1(rf_re1_id),
        .rf_rd0_raw(rf_rd0_raw_id),
        .rf_rd1_raw(rf_rd1_raw_id),
        .rf_rd0(1'h0),
        .rf_rd1(1'h0),
        .rf_wa(rf_wa_id),
        .rf_wd_sel(rf_wd_sel_id),
        .rf_wd(1'h0),
        .rf_we(rf_we_id),
        .immediate(imm_id),
        .alu_sr1(1'h0),
        .alu_sr2(1'h0),
        .alu_func(alu_func_id),
        .alu_ans(1'h0),
        .pc_add4(pc_add4_id),
        .pc_br(1'h0),
        .pc_jal(1'h0),
        .pc_jalr(1'h0),
        .pc_sel(1'h0),
        .pc_next(1'h0),
        .dm_addr(1'h0),
        .dm_din(1'h0),
        .dm_dout(1'h0),
        .dm_we(dm_we_id),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_id)       
    );
    
    wire [31:0] check_data_ex;
    Check_Data_SEL check_data_sel_ex(
        .pc_cur(pc_cur_ex),
        .instruction(inst_ex),
        .rf_ra0(rf_ra0_ex),
        .rf_ra1(rf_ra1_ex),
        .rf_re0(rf_re0_ex),
        .rf_re1(rf_re1_ex),
        .rf_rd0_raw(rf_rd0_raw_ex),
        .rf_rd1_raw(rf_rd1_raw_ex),
        .rf_rd0(rf_rd0_ex),
        .rf_rd1(rf_rd1_ex),
        .rf_wa(rf_wa_ex),
        .rf_wd_sel(rf_wd_sel_ex),
        .rf_wd(1'h0),
        .rf_we(rf_we_ex),
        .immediate(imm_ex),
        .alu_sr1(alu_src1_ex),
        .alu_sr2(alu_src2_ex),
        .alu_func(alu_func_ex),
        .alu_ans(alu_ans_ex),
        .pc_add4(pc_add4_ex),
        .pc_br(alu_ans_ex),
        .pc_jal(alu_ans_ex),
        .pc_jalr(pc_jalr_ex),
        .pc_sel(pc_sel_ex),
        .pc_next(pc_next),
        .dm_addr(alu_ans_ex),
        .dm_din(1'h0),
        .dm_dout(1'h0),
        .dm_we(dm_we_ex),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_ex)        
    );
    
    wire [31:0] check_data_mem;
    
    Check_Data_SEL check_data_sel_mem(
        .pc_cur(pc_cur_mem),
        .instruction(inst_mem),
        .rf_ra0(rf_ra0_mem),
        .rf_ra1(rf_ra1_mem),
        .rf_re0(rf_re0_mem),
        .rf_re1(rf_re1_mem),
        .rf_rd0_raw(rf_rd0_raw_mem),
        .rf_rd1_raw(rf_rd1_raw_mem),
        .rf_rd0(rf_rd0_mem),
        .rf_rd1(rf_rd1_mem),
        .rf_wa(rf_wa_mem),
        .rf_wd_sel(rf_wd_sel_mem),
        .rf_wd(1'h0),
        .rf_we(rf_we_mem),
        .immediate(imm_mem),
        .alu_sr1(alu_src1_mem),
        .alu_sr2(alu_src2_mem),
        .alu_func(alu_func_mem),
        .alu_ans(alu_ans_mem),
        .pc_add4(pc_add4_mem),
        .pc_br(alu_ans_mem),
        .pc_jal(alu_ans_mem),
        .pc_jalr(pc_jalr_mem),
        .pc_sel(pc_sel_mem),
        .pc_next(pc_next),
        .dm_addr(alu_ans_mem),
        .dm_din(dm_din_mem),
        .dm_dout(dm_dout),
        .dm_we(dm_we_mem),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_mem)        
    );
    
    wire [31:0] check_data_wb;
    
    Check_Data_SEL check_data_sel_wb(
        .pc_cur(pc_cur_wb),
        .instruction(inst_wb),
        .rf_ra0(rf_ra0_wb),
        .rf_ra1(rf_ra1_wb),
        .rf_re0(rf_re0_wb),
        .rf_re1(rf_re1_wb),
        .rf_rd0_raw(rf_rd0_raw_wb),
        .rf_rd1_raw(rf_rd1_raw_wb),
        .rf_rd0(rf_rd0_wb),
        .rf_rd1(rf_rd1_wb),
        .rf_wa(rf_wa_wb),
        .rf_wd_sel(rf_wd_sel_wb),
        .rf_wd(1'h0),
        .rf_we(rf_we_wb),
        .immediate(imm_wb),
        .alu_sr1(alu_src1_wb),
        .alu_sr2(alu_src2_wb),
        .alu_func(alu_func_wb),
        .alu_ans(alu_ans_wb),
        .pc_add4(pc_add4_wb),
        .pc_br(alu_ans_wb),
        .pc_jal(alu_ans_wb),
        .pc_jalr(pc_jalr_wb),
        .pc_sel(pc_sel_wb),
        .pc_next(pc_next),
        .dm_addr(alu_ans_wb),
        .dm_din(dm_din_wb),
        .dm_dout(dm_dout),
        .dm_we(dm_we_wb),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_wb)        
    );

    wire [31:0] check_data_hzd;
    Check_Data_SEL_HZD check_data_sel_hzd(
        .rf_ra0_ex(rf_ra0_ex),
        .rf_ra1_ex(rf_ra1_ex),
        .rf_re0_ex(rf_re0_ex),
        .rf_re1_ex(rf_re1_ex),
        .pc_sel_ex(pc_sel_ex),
        .rf_wa_mem(rf_wa_mem),
        .rf_we_mem(rf_we_mem),
        .rf_wd_sel_mem(rf_wd_sel_mem),
        .alu_ans_mem(alu_ans_mem),
        .pc_add4_mem(pc_add4_mem),
        .imm_mem(imm_mem)  ,
        .rf_wa_wb(rf_wa_wb) ,
        .rf_we_wb(rf_we_wb) ,
        .rf_wd_wb(rf_wd_wb) ,
        .rf_rd0_fe(rf_rd0_fe),
        .rf_rd1_fe(rf_rd1_fe),
        .rf_rd0_fd(rf_rd0_fd),
        .rf_rd1_fd(rf_rd1_fd),
        .stall_if(stall_if) ,
        .stall_id(stall_id) ,
        .stall_ex(stall_ex) ,
        .flush_if(flush_if) ,
        .flush_id(flush_id) ,
        .flush_ex(flush_ex) ,
        .flush_mem(flush_mem),
        .check_addr(cpu_check_addr[4:0]),
        .check_data(check_data_hzd)
    );
    wire [31:0] check_data;
    Check_Data_SEG_SEL check_data_seg_sel(
        .check_data_if(check_data_if),
        .check_data_id(check_data_id),
        .check_data_ex(check_data_ex),
        .check_data_mem(check_data_mem),
        .check_data_wb(check_data_wb),
        .check_data_hzd(check_data_hzd),
        .check_addr(cpu_check_addr[7:5]),
        .check_data(check_data)
    );

    MUX1 cpu_check_data_sel(
        .s0(check_data),
        .s1(rf_rd_dbg_id),
        .sel(cpu_check_addr[12]),
        .d(cpu_check_data)
    );


    assign test = alu_src1_ex;
    assign test2= alu_src2_ex;
    assign test3= btb_fail;
endmodule