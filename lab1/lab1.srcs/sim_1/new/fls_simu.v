`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 22:56:16
// Design Name: 
// Module Name: fls_simu
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


module fls_simu(

    );
    reg clk, rst;
    reg en;
    reg [6:0] d;
    wire [6:0] f;
    initial begin
        rst = 1;
        en = 0;
        d = 1;
        clk = 0;
        #20 rst=0;
    end
    always clk = #1 ~clk;
    always en = #5 ~en;
    fls s0(
        clk,
        rst,
        en,
        d,
        f
    );
endmodule
