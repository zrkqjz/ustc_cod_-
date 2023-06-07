`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/09 15:48:35
// Design Name: 
// Module Name: getEdge
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


module getEdge(
    input clk, 
    input in,
    output p,//edge
    output s //sychronized 
    );
    reg r0, r1, r2;
    always @(posedge clk) begin
        r0 <= in;
        r1 <= r0;
        r2 <= r1;
    end
    assign s = r1;
    assign p = r1 & ~r2;
endmodule
