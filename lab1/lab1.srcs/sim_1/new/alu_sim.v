`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 19:45:58
// Design Name: 
// Module Name: alu_sim
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


module alu_sim(

    );
        reg [5:0] a,b;
    reg [3:0] f;
    wire [5:0] out;
    wire of;
    initial
    begin
        a = 6'b11_1111;
        b = 6'b10_0000;
        f = 4'b0000;
        forever
            #5 f = f + 1;
    end
    alu sim1(
        .a(a),
        .b(b),
        .func(f),
        .y(out),
        .of(of)
    );
endmodule
