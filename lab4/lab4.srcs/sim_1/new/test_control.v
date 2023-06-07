`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/28 11:43:57
// Design Name: 
// Module Name: test_control
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


module test_control(

    );
    reg [31:0] inst;
    wire jal;
    wire jalr;
    wire [2:0] br_type;
    wire wb_en;
    wire wb_sel;
    wire alu_op_1;
    wire alu_op_2;
    wire [3:0] alu_ctrl;
    wire mem_we;
    wire [1:0] ALUOpc;
    wire [3:0] temp;

    Control t_ctrl(
        inst,
        jal,
        jalr,
        br_type,
        wb_en,
        wb_sel,
        alu_op_1,
        alu_op_2,
        alu_ctrl,
        mem_we,
        ALUOpc
    );
    ALU_helper t_helper(
        ALUOpc,
        {inst[30],inst[14:12]},
        temp
    );

    initial begin
        inst = 32'h00b50533; //add x4, x5, x6
        #1 inst = 32'h00150593; //addi x4, x5, 16
        #1 inst = 32'h00000517; //auipc x4, 100
        #1 $finish;
    end
endmodule
