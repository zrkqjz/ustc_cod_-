`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 23:10:10
// Design Name: 
// Module Name: ALU_Ctrl
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


module ALU_helper(
input[1:0] ALUOp,
input[3:0] inst,
output reg[3:0] ALU_sel);
always@(*)
begin
 case(ALUOp)
 2'b00:ALU_sel=4'b0000;
 2'b01:ALU_sel=4'b0001;
 2'b10:
 begin
 case(inst)
 4'b0000:ALU_sel=4'b0000;
 4'b1000:ALU_sel=4'b0001;
 4'b0001:ALU_sel=4'b1001;
 4'b0100:ALU_sel=4'b0111;
 4'b0101:ALU_sel=4'b1000;
 4'b0110:ALU_sel=4'b0110;
 4'b0111:ALU_sel=4'b0101;
 default:ALU_sel=4'b0001;
 endcase
 end
 2'b11:
 begin
 casex(inst)
 4'bx000:ALU_sel=4'b0000;
 4'bx100:ALU_sel=4'b0111;
 4'bx110:ALU_sel=4'b0110;
 4'bx111:ALU_sel=4'b0101;
 4'bx001:ALU_sel=4'b1001;
 default:ALU_sel=4'b0000;
 endcase
 end
 default:ALU_sel=4'b0001;
 endcase
end
endmodule

