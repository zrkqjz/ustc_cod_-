`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 17:22:08
// Design Name: 
// Module Name: RF
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



module RF 
#(parameter WIDTH = 32) 
(   input          clk, 
    input  [4 : 0] ra0, 
    output reg [WIDTH - 1 : 0] rd0, 
    input  [4: 0] ra1, 
    output reg [WIDTH - 1 : 0] rd1, 
    input  [4 : 0] ra_dbg,
    output reg [WIDTH - 1 : 0] rd_dbg, 
    input  [4 : 0] wa, 
    input          we, 
    input  [WIDTH - 1 : 0] wd 
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
        if (ra1 == 5'h0)    rd1 = 32'h0;
        else if (ra1 == wa && we == 1) rd1 = wd;
        else                rd1 = regfile[ra1];
    end

    always @(*) begin
        if (ra0 == 5'h0)    rd0 = 32'h0;
        else if (ra0 == wa && we == 1) rd0 = wd;
        else                rd0 = regfile[ra0];
    end

    always @(*) begin
        if (ra_dbg == 5'h0)    rd_dbg = 32'h0;
        else if (ra_dbg == wa && we == 1) rd_dbg = wd;
        else                rd_dbg = regfile[ra_dbg];
    end
endmodule

