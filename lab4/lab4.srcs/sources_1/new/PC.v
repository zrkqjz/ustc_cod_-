`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/28 11:32:05
// Design Name: 
// Module Name: PC
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


module PC(
    input [31:0] pc_next,
    input rst,
    input clk,
    output reg [31:0] pc_cur
    );
    always @(posedge clk or posedge rst) begin
        if (rst) pc_cur <= 32'h0000_3000;
        else pc_cur <= pc_next;
    end

endmodule
