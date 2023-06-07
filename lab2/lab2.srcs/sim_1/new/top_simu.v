`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 19:22:55
// Design Name: 
// Module Name: top_simu
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


module top_simu(

    );
    reg clk;
    reg [4:0] addr;
    reg [15:0] in;
    reg we;
    reg ena;
    wire [15:0] dis_out;
    wire [15:0] block_out;
    initial begin
        clk = 0;
        we = 0;
        ena = 1;
        addr = 0;
        in = 16'habcd;
        forever 
            #1 clk = ~clk;
    end
    initial begin
        forever
        #5 addr = addr + 1;
    end
    initial begin
        #50 we = 1;
    end
    
    dist_mem_gen_0 dis0(
        .clk(clk),
        .a(addr),
        .d(in),
        .we(we),
        .spo(dis_out)
    );
    blk_mem_gen_0 blk0(
        .clka(clk),
        .addra(addr),
        .dina(in),
        .douta(block_out),
        .wea(we)
    );
endmodule
