`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 20:28:58
// Design Name: 
// Module Name: Branch
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


module Branch(
    input [2:0] br_type,
    input [31:0] rd0,
    input [31:0] rd1,
    output reg br
    );
    always @(*) begin
        case (br_type)
            3'b000://beq
                br = (rd0 == rd1)?1:0;
            3'b001://bne
                br = (rd0 == rd1)?0:1;
            3'b100://blt
                br = ($signed(rd0) < $signed(rd1))?1:0;
            3'b101://bge
                br = ($signed(rd0) >= $signed(rd1))?1:0;
            3'b110://bltu
                br = (rd0 < rd1)?1:0;
            default: br = 0;
        endcase

    end
endmodule
