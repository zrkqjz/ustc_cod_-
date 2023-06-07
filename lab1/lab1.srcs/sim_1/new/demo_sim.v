`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 18:56:43
// Design Name: 
// Module Name: demo_sim
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


module demo_sim(

    );
    reg[5:0] a,b;
    wire [5:0] y1,y2;
    initial
    begin
        a = 6'b00_1100;
        b = 6'b10_0011;
    end
    assign y1 = (a < b)?1:0;
    assign y2 = ($signed(a) < $signed(b))?1:0;
endmodule
