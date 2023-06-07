`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 20:13:48
// Design Name: 
// Module Name: dff_simu
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


module dff_simu(

    );
    reg clk;
    reg [5:0] in;
    reg en;
    wire [5:0] out;
    initial  begin
        clk = 0;
        in = 6'b00_0011;
        en = 1;
        forever begin
            #1 clk = ~clk;
            #5 in = in + 1;
        end
    end
endmodule
