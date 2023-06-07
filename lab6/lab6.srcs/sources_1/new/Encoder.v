`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/21 16:39:05
// Design Name: 
// Module Name: Encoder
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


module Encoder(
    input   jal,
    input   jalr,
    input   br,
    output reg [1:0]  pc_sel
    );
    always @(*) begin
        case ({jal, jalr, br})
            3'b000: pc_sel = 2'b00;
            3'b100: pc_sel = 2'b10;
            3'b010: pc_sel = 2'b01;
            3'b001: pc_sel = 2'b11; 
            default: pc_sel = 2'b00;
        endcase
    end
endmodule
