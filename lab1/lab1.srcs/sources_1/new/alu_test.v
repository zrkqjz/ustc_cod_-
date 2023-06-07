`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 16:40:15
// Design Name: 
// Module Name: alu_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependenfies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_test
(
    input clk,
    input en,
    input [1:0] sel,
    input [5:0] x,
    output [5:0] y,
    output of
);
    //ÒëÂëÆ÷
    reg ena, enb, enf;
    always @(*) begin
        if(en == 0) begin
            ena = 0;
            enb = 0;
            enf = 0;
        end
        else if(sel == 2'b00) begin
            ena = 1;
            enb = 0;
            enf = 0;
        end
        else if(sel == 2'b01) begin
            ena = 0;
            enb = 1;
            enf = 0;
        end
        else if(sel == 2'b10) begin
            ena = 0;
            enb = 0;
            enf = 1;
        end
        else begin
            ena = 0;
            enb = 0;
            enf = 0;           
        end
    end
    //¼Ä´æÆ÷
    //(clk,in,en,out)
    wire [5:0] aout, bout;
    wire [3:0] fout;
    dff #(6)Da(
        clk,
        x,
        ena,
        aout
    );
    dff #(6)Db(
        clk,
        x,
        enb,
        bout
    );
    dff #(4)Df(
        clk,
        x[3:0],
        enf,
        fout
    );
    //assign y = {3'b0,ena,enb,enf};
    //assign y = aout;
    
    alu#(6) A0(
        .a(aout),
        .b(bout),
        .func(fout),
        .y(y),
        .of(of)
    );
    
endmodule
