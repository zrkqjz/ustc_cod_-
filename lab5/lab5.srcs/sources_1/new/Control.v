`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 23:07:37
// Design Name: 
// Module Name: Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
