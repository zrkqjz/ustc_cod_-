`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/09 15:57:26
// Design Name: 
// Module Name: SDU
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




module SDU(
    input clk,
    input [3:0] data,
    input [7:0] valid,
    input [2:0] head,
    output reg [2:0] adrs,
    output [2:0] an,
    output [3:0] seg
    );
    // 100M Hz to 100 Hz
    wire clk_100;
    reg [19:0] clk_cnt;
    assign clk_100 = ~(|clk_cnt);     
    always @(posedge clk) begin
        if (clk_cnt >= 20'd99_9999) begin 
            clk_cnt <= 20'd0;
            adrs <= adrs + 1;
        end 
        else
            clk_cnt <= clk_cnt + 20'd1; 
    end

    reg [2:0] temp_an;
    reg [3:0] temp_seg;
    always @(posedge clk_100) begin
        if(valid[adrs] == 1) begin
        temp_an <= adrs - head;
        temp_seg <= data;
        end
        else begin
        temp_an <= temp_an;
        temp_seg <= temp_seg;
        end
    end
    assign an = (|valid)?temp_an:0;
    assign seg = (|valid)?temp_seg:0;
endmodule