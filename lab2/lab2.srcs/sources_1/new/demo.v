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
    input              clk,
    input       [3:0]  data,
    input       [7:0]  valid,
    output reg  [2:0]  adrs,
    output      [2:0]  an,
    output      [3:0]  seg
);
    // Counter: slow the clock down to 400Hz
    wire clk_400hz;
    reg [17:0] clk_cnt;
    assign clk_400hz = ~(|clk_cnt);     // clk_400hz = (clk_cnt == 0)
    always @(posedge clk) begin
        if (clk_cnt >= 18'h3D08F) begin // clk_cnt >= 249999
            clk_cnt <= 18'h00000;
            adrs <= adrs + 3'b001;
        end else
            clk_cnt <= clk_cnt + 18'h00001; 
    end
    // Generate segplay output
    reg [2:0] an_reg;
    reg [3:0] seg_reg;
    always @(posedge clk) begin
        if (clk_400hz && valid[adrs]) begin
            an_reg <= adrs;
            seg_reg <= data;
        end
    end
    assign seg = (|valid) ? seg_reg : 4'h0;
    assign an = (|valid) ? an_reg : 3'h0;
endmodule