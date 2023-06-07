`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/09 16:25:42
// Design Name: 
// Module Name: FIFO
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


module FIFO(
    input clk,
    input rst,
    input enq,
    input deq,
    input [3:0] in,
    output [3:0] out,
    output empty,
    output full,
    output [2:0] an,
    output [3:0] seg
    );

    wire enq_edge;
    wire deq_edge;
    getEdge edgeEnq(
        .clk(clk),
        .in(enq),
        .p(enq_edge)
    );
    getEdge edgeDeq(
        .clk(clk),
        .in(deq),
        .p(deq_edge)
    );

    wire we;
    wire [2:0] ra0, wa, ra1;
    wire [3:0] rd0, wd, rd1;
    wire [7:0] valid;
    wire [2:0] head;
    
    LCU lcu(
        .clk(clk),
        .rst(rst),
        .in(in),
        .rd(rd0),
        .enq_edge(enq_edge),
        .deq_edge(deq_edge),
        .full(full),
        .empty(empty),
        .out(out),
        .ra(ra0),
        .wa(wa),
        .wd(wd),
        .we(we),
        .valid(valid),
        .head(head)
    );
    RF#(4) regFile(
        .clk(clk),
        .ra0(ra0),
        .ra1(ra1),
        .rd0(rd0),
        .rd1(rd1),
        .wa(wa),
        .wd(wd),
        .we(we)
    );
    SDU sdu(
        .clk(clk),
        .valid(valid),
        .data(rd1),
        .adrs(ra1),
        .an(an),
        .seg(seg),
        .head(head)
    );
endmodule
