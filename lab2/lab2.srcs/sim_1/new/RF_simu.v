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
    reg clk; //ʱ�ӣ���������Ч��
    reg[4 : 0] ra0; //���˿�0��ַ
    wire[31 - 1 : 0] rd0; //���˿�0����
    reg[4: 0] ra1; //���˿�1��ַ
    wire[31 - 1 : 0] rd1; //���˿�1����
    reg[4 : 0] wa; //д�˿ڵ�ַ
    reg we; //дʹ�ܣ��ߵ�ƽ��Ч
    reg[31 - 1 : 0] wd; //д�˿�����

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
