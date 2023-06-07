`timescale 1ns / 1ps

/* 
 *   Author: YOU
 *   Last update: 2023.04.20
 */

module CPU(
    output [31:0] test,
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,      // Instruction address (The same as current PC)
    input [31:0] im_dout,       // Instruction data (Current instruction)
    output [31:0] mem_addr,     // Memory read/write address
    output mem_we,              // Memory writing enable		            
    output [31:0] mem_din,      // Data ready to write to memory
    input [31:0] mem_dout,	    // Data read from memory

    // Debug BUS with PDU
    output [31:0] current_pc, 	        // Current_pc, pc_out
    output [31:0] next_pc,              // Next_pc, pc_in    
    input [31:0] cpu_check_addr,	    // Check current datapath state (code)
    output reg [31:0] cpu_check_data   // Current datapath state data

);
    
    // Write your CPU here!
    // You might need to write these modules:
    //      ALU、RF、Control、Add(Or just add-mode ALU)、And(Or just and-mode ALU)、PCReg、Imm、Branch、Mux�?????????...

    //for control
    wire [31:0] inst;
    wire jal;
    wire jalr;
    wire [2:0] br_type;
    wire wb_en;
    wire [1:0] wb_sel;
    wire alu_op1_sel;
    wire alu_op2_sel;
    wire [3:0] alu_ctrl;

    wire [31:0] imm, wb_data, rd_dbg;
    
    wire [31:0] pc_add4;

    wire [31:0] rd0, rd1, pc_cur, pc_next, pc_jalr;

    wire [31:0] alu_op_1, alu_op_2;

    wire [31:0] alu_res;

    wire [31:0] mem_rd;
    
    wire br;

    assign inst = im_dout;
    assign mem_rd = mem_dout;
    assign mem_addr = alu_res;
    assign im_addr = pc_cur;
    assign mem_addr = alu_res;
    assign mem_din = rd1;
    assign current_pc = pc_cur;
    assign next_pc = pc_next;

    Control ctrl(
    .inst(inst),
    .jal(jal),
    .jalr(jalr),
    .br_type(br_type),
    .wb_en(wb_en),
    .wb_sel(wb_sel),
    .alu_op_1(alu_op1_sel),
    .alu_op_2(alu_op2_sel),
    .alu_ctrl(alu_ctrl),
    .mem_we(mem_we)
    );
    
    PC pc(
        .pc_next(pc_next),
        .pc_cur(pc_cur),
        .rst(rst),
        .clk(clk)
    );
    /*
    reg [31:0] pc_cur_temp;
    always @(posedge clk or posedge rst) begin
        if (rst) pc_cur_temp <= 32'h0000_3000;
        else pc_cur_temp <= pc_next;
    end
    assign pc_cur = pc_cur_temp;
    */
    RF rf(
        .ra0(inst[19:15]),
        .ra1(inst[24:20]),
        .wa(inst[11:7]),
        .wd(wb_data),
        .ra_dbg(cpu_check_addr[4:0]),
        .rd_dbg(rd_dbg),
        .rd0(rd0),
        .rd1(rd1),
        .we(wb_en),
        .clk(clk)
    );

    Immediate immediate(
        .instruction(inst),
        .Imm(imm)
    );

    ADD#(32) add(
        .a(32'b100),
        .b(pc_cur),
        .y(pc_add4)
    );

    AND#(32) a0(
        .a(32'hFFFF_FFFE),
        .b(alu_res),
        .y(pc_jalr)
    );

    MUX alu_sel_1(
        .s0(rd0),
        .s1(pc_cur),
        .sel(alu_op1_sel),
        .d(alu_op_1)
    );

    MUX alu_sel_2(
        .s0(rd1),
        .s1(imm),
        .sel(alu_op2_sel),
        .d(alu_op_2)
    );

    Branch branch(
        .rd0(rd0),
        .rd1(rd1),
        .br_type(br_type),
        .br(br)
    );
    
    ALU alu(
        .a(alu_op_1),
        .b(alu_op_2),
        .func(alu_ctrl),
        .y(alu_res)
    );
    
    //assign alu_res = alu_op_1 + alu_op_2;
    
    NPC_SEL npc_sel(
        .pc_add4(pc_add4),
        .pc_jal_br(alu_res),
        .pc_jalr(pc_jalr),
        .jal(jal),
        .jalr(jalr),
        .br(br),
        .pc_next(pc_next)
    );
    
    //assign pc_next = pc_add4;

    MUX2 reg_write_sel(
        .src0(alu_res),
        .src1(pc_add4),
        .src2(mem_rd),
        .src3(imm),
        .sel(wb_sel),
        .res(wb_data)
    );
    
    wire [31:0] check_data;

    always @(*) begin
        case (cpu_check_addr[12])
            0:cpu_check_data = check_data;
            1:cpu_check_data = rd_dbg;
            default: cpu_check_data = check_data;
        endcase
    end

    CHECK_DATA_SEL check_data_sel(
        .check_addr(cpu_check_addr),
        .pc_in(pc_next),
        .pc_out(pc_cur),
        .instruction(inst),
        .rf_ra0(inst[19:15]),
        .rf_ra1(inst[24:20]),
        .rf_rd0(rd0),
        .rf_rd1(rd1),
        .rf_wa(inst[11:7]),
        .rf_wd(wb_data),
        .rf_we(wb_en),
        .imm(imm),
        .alu_sr1(alu_op_1),
        .alu_sr2(alu_op_2),
        .alu_func(alu_ctrl),
        .alu_ans(alu_res),
        .pc_jalr(pc_jalr),
        .dm_addr(alu_res),
        .dm_din(mem_din),
        .dm_dout(mem_rd),
        .dm_we(mem_we),
        .check_data(check_data)       
    );
   assign test = inst;
endmodule