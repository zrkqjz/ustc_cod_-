`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 17:22:08
// Design Name: 
// Module Name: RF
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



module RF //���˿�32 xWIDTH�Ĵ�����
#(parameter WIDTH = 32) //���ݿ��Ⱥʹ洢�����
(   input clk, //ʱ�ӣ���������Ч��
    input[4 : 0] ra0, //���˿�0��ַ
    output[WIDTH - 1 : 0] rd0, //���˿�0����
    input[4: 0] ra1, //���˿�1��ַ
    output[WIDTH - 1 : 0] rd1, //���˿�1����
    input[4 : 0] wa, //д�˿ڵ�ַ
    input we, //дʹ�ܣ��ߵ�ƽ��Ч
    input[WIDTH - 1 : 0] wd //д�˿�����
);
reg [WIDTH - 1 : 0] regfile[0 : 31];
assign rd0 = regfile[ra0], rd1 = regfile[ra1];
always @ (posedge clk) begin
    if (we && wa != 0) regfile[wa] <= wd;
    else if(!we) regfile[wa] <= regfile[wa];
    else regfile[wa] <= 0;
end
endmodule
