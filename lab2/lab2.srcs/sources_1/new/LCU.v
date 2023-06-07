`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/08 23:11:22
// Design Name: 
// Module Name: LCU
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


module LCU // depth = 8, width = 4
(
    input clk,
    input rst,
    input [3:0] in,
    input [3:0] rd,
    input enq_edge,
    input deq_edge,
    output full,
    output empty,
    output reg [3:0] out,
    output [2:0] ra,
    output [2:0] wa,
    output [3:0] wd,
    output we,
    output reg [7:0] valid,
    output head
    );

    assign full = &valid;
    assign empty = ~(|valid);

    reg [2:0] head;
    reg [2:0] tail;

    assign ra = head;
    assign wa = tail;

    assign wd = in;
    assign we = enq_edge & ~full & ~rst;

    always @(posedge clk) begin
        if(rst) begin
            valid <= 8'b0;
            head <= 3'b0;
            tail <= 3'b0;
            out <= 4'b0;
        end
        else if(enq_edge & ~full) begin 
            valid[tail] <= 1'b1;
            tail <= tail + 1;
        end
        else if(deq_edge & ~empty) begin
            valid[head] <= 1'b0;
            head <= head + 1;
            out <= rd;
        end
        else begin
            head <= head;
            tail <= tail;      
        end
    end
    
endmodule
