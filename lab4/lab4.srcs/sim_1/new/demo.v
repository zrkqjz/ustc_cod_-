`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/06 22:01:59
// Design Name: 
// Module Name: demo
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


module demo(

    );
    /*
    reg [31:0] pc_next;
    reg rst;
    reg clk;
    wire [31:0] pc_cur;
    PC t_pc(
        pc_next,
        rst,
        clk,
        pc_cur
    );

    always @ (*) pc_next = pc_cur + 32'h4;
    initial begin
        rst = 1;
        clk = 0;
        #20 rst = 0;
    end
    
    always #5 clk <= ~clk;
    */
    /*
    reg clk; 
    wire[31 : 0] rd0;
    wire[31 : 0] rd1;
    wire [31:0] inst;
    assign inst = 32'h003200b3;
    initial begin
        clk = 0;
    end
    RF rf(
        .ra0(inst[19:15]),
        .ra1(inst[24:20]),
        .rd0(rd0),
        .rd1(rd1),
        .clk(clk)
    );
    always #5 clk <= ~clk;*/
    reg [31:0] alu_op_1, alu_op_2;
    wire [31:0] alu_res;
    reg [3:0] alu_ctrl;
    initial begin
        alu_op_1 = 32'b0;
        alu_op_2 = 32'h64;
        alu_ctrl = 4'b0000;
    end
    ALU t_alu(
        alu_op_1,
        alu_op_2,
        alu_ctrl,
        alu_res
    );
endmodule
