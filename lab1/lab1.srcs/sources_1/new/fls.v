`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 20:42:20
// Design Name: 
// Module Name: fls
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


module fls(
        input clk, rst,
        input en, 
        input [6:0] d, 
        output reg [6:0] f
    );
    parameter s0 = 3'b000,
    s1 = 3'b001,
    s2 = 3'b010,
    s3 = 3'b011,
    s4 = 3'b100;
    //È¡±ßÑØ
    reg button_r1,button_r2;
    always@(posedge clk)
        button_r1 <= en;
    always@(posedge clk)
        button_r2 <= button_r1;
    assign button_edge = button_r1 & (~button_r2);
    //current state
    reg [2:0] cs,ns;
    always @(posedge button_edge) begin
        if(rst == 1)  cs <= s0;
        else cs <= ns;
    end 
    //next state
    always @(*) begin
        case (cs)
            s0: ns = s1;
            s1: ns = s2;
            s2: ns = s3;
            s3: ns = s4;
            s4: ns = s2;
            default: ns = cs;
        endcase
    end
    //
    
    reg [6:0] f0, f1;
    wire [6:0] out;
    wire of;
    alu#(7) A1(f0, f1, 4'b0000, out, of);
    //reg of;
    always @(posedge button_edge) begin
        case (cs)
            s0: f0 <= d;
            s1: f1 <= d;
            s2: f <= out;
            s3: f0 <= f1;
            s4: f1 <= f;
            default: f <= out;
        endcase
    end
endmodule
