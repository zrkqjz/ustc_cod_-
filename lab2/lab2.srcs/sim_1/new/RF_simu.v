`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 17:24:59
// Design Name: 
// Module Name: RF_simu
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


module RF_simu(

    );
    reg clk; //时钟（上升沿有效）
    reg[4 : 0] ra0; //读端口0地址
    wire[31 - 1 : 0] rd0; //读端口0数据
    reg[4: 0] ra1; //读端口1地址
    wire[31 - 1 : 0] rd1; //读端口1数据
    reg[4 : 0] wa; //写端口地址
    reg we; //写使能，高电平有效
    reg[31 - 1 : 0] wd; //写端口数据

    initial
    begin
        clk = 0;
        ra0 = 0;
        ra1 = 0;
        we = 1;
        wa = 0;
        #5 forever #5 ra0 = ra0 + 1;
    end
    initial begin
        forever #1 clk = ~clk;
    end
    initial begin
        forever #5 wa = wa + 1;
    end
    always @ (*) wd = wa + 2;
    RF test1(
        clk,
        ra0,
        rd0,
        ra1,
        rd1,
        wa,
        we,
        wd
    );
endmodule
