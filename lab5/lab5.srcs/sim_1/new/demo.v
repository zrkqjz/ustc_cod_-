`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 19:18:35
// Design Name: 
// Module Name: demo
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


module demo(

    );
    //Test RF
/*     reg          clk; 
    reg  [4 : 0] ra0; 
    wire [31 - 1 : 0] rd0; 
    reg  [4: 0] ra1; 
    wire [31 - 1 : 0] rd1; 
    reg  [4 : 0] ra_dbg;
    wire [31 - 1 : 0] rd_dbg; 
    reg  [4 : 0] wa; 
    reg          we; 
    reg  [31 - 1 : 0] wd;

    RF test_RF(
        clk, 
        ra0, 
        rd0, 
        ra1, 
        rd1, 
        ra_dbg,
        rd_dbg, 
        wa, 
        we, 
        wd 
    );
    initial begin
        clk = 0;
        we = 0;
        ra0 = 0;
        wd = 1111;
        forever
            #1 clk = ~clk;
    end
    initial begin
        #50 we = 1;wa = 5'h0a;
        #5 wd = 16'h2222; wa = 5'h0b; 
        #5 we = 0;
    end
    initial begin
        forever 
            #5 ra0 = ra0 + 1;
    end */

    //test seg_reg
    reg clk, flush, stall;
    reg [31:0] inst_in;
    wire [31:0] inst_out;
    initial begin
        inst_in = 32'h0000_0033;
        flush = 0;
        stall = 0;
        clk = 0;
        forever
            #1 clk = ~clk;
    end    
    SEG_REG test_seg(
        .flush(flush),
        .stall(stall),
        .inst_in(inst_in),
        .inst_out(inst_out),
        .clk(clk)
    );
endmodule
