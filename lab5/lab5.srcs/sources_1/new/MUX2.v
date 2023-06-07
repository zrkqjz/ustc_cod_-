`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/05 21:38:35
// Design Name: 
// Module Name: MUX2
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


module MUX2(
    input [31:0] src0,
    input [31:0] src1,
    input [31:0] src2,
    input [31:0] src3,
    input [1:0] sel,
    output reg [31:0] res
    );
    always @(*) begin
        case (sel)
            2'b00: res = src0;
            2'b01: res = src1;
            2'b10: res = src2;
            2'b11: res = src3;
            default: res = src0;
        endcase
    end
endmodule
