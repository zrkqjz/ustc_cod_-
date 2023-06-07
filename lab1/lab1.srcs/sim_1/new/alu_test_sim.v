`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/01 18:07:57
// Design Name: 
// Module Name: alu_test_sim
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


module alu_test_sim(

    );
    reg clk;
    reg en;
    reg [1:0] sel;
    reg [5:0] x;
    wire [5:0] y;
    wire of;
    initial begin
        x = 6'b00_0011;
        clk = 0;
        en = 1;
        sel = 0;
        forever begin
        #5 clk = ~clk;sel = sel + 1;
        end
    end
    alu_test simu2(
        .clk(clk),
        .en(en),
        .sel(sel),
        .x(x),
        .y(y),
        .of(of)
    );
endmodule
