`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 20:00:36
// Design Name: 
// Module Name: dff
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


module dff#(parameter n = 6)(
    input clk,
    input [n-1:0] in,
    input en,
    output reg [n-1:0] out
    );
    always @(posedge clk) begin
        if(en == 1) out <= in;
        else out <= out;
    end
endmodule
