`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/26 20:10:02
// Design Name: 
// Module Name: Immediate
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


module Immediate(
input[31:0] instruction,
output reg[31:0] Imm
);
always@(*)
begin
 case(instruction[6:0])
 7'b0010011: //addi .etc
    Imm={{20{instruction[31]}},instruction[31:20]};
 7'b1100111://jalr
    Imm={{20{instruction[31]}},instruction[31:20]};
 7'b1101111://jal
    Imm={{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
 7'b1100011://beq .etc
    Imm={{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
 7'b0000011://lw
    Imm={{20{instruction[31]}},instruction[31:20]}; //lw
 7'b0100011://sw
    Imm={{21{instruction[31]}}, instruction[30:25], instruction[11:7]}; //sw
 7'b0010111://auipc
    Imm={instruction[31:12],12'b0};
 7'b0110111://lui
    Imm={instruction[31:12],12'b0};
 default:Imm=32'b0;
 endcase
end
endmodule
