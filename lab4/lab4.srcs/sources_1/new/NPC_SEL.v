`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/05 21:37:36
// Design Name: 
// Module Name: NPC_SEL
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


module NPC_SEL(
    input [31:0] pc_add4,
    input [31:0] pc_jal_br,
    input [31:0] pc_jalr,
    input jal,
    input jalr,
    input br,
    output reg [31:0] pc_next
    );
    always @(*) begin
        if(jal == 0 && jalr == 0 && br == 1)   
            pc_next = pc_jal_br;
        else if(jal == 1 && jalr == 0 && br == 0)
            pc_next = pc_jal_br;
        else if(jal == 0 && jalr == 1 && br == 0)
            pc_next = pc_jalr;
        else if(jal == 0 && jalr == 0 && br == 0)
            pc_next = pc_add4;
        else pc_next = pc_add4;
    end
endmodule
