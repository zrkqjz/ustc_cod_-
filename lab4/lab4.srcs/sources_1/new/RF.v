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



module RF //锟斤拷锟剿匡�?32 xWIDTH锟侥达拷锟斤拷锟斤拷
#(parameter WIDTH = 32) //锟斤拷锟捷匡拷锟饺和存储锟斤拷锟斤拷锟�
(   input clk, //时锟接ｏ拷锟斤拷锟斤拷锟斤拷锟斤拷效锟斤�?
    input[4 : 0] ra0, //锟斤拷锟剿匡�?0锟斤拷址
    output[WIDTH - 1 : 0] rd0, //锟斤拷锟剿匡�?0锟斤拷锟斤拷
    input[4: 0] ra1, //锟斤拷锟剿匡�?1锟斤拷址
    output[WIDTH - 1 : 0] rd1, 
    input[4 : 0] ra_dbg,
    output[WIDTH - 1 : 0] rd_dbg, //锟斤拷锟剿匡�?1锟斤拷锟斤拷
    input[4 : 0] wa, //写锟剿口碉拷�?
    input we, //写使锟杰ｏ拷锟竭碉拷平锟斤拷�?
    input[WIDTH - 1 : 0] wd //写锟剿匡拷锟斤拷锟斤�?
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
assign rd0 = regfile[ra0], rd1 = regfile[ra1], rd_dbg = regfile[ra_dbg]; 
always @ (posedge clk) begin
    if (we && wa != 0) regfile[wa] <= wd;
    else if(!we) regfile[wa] <= regfile[wa];
    else regfile[wa] <= 0;
end

endmodule
