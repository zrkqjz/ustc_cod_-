`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 12:06:15
// Design Name: 
// Module Name: FIFO_simu
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


module FIFO_simu(

    );
    reg clk;
    reg rst;
    reg enq;
    reg deq;
    reg [3:0] in;
    wire [3:0] out;
    wire empty;
    wire full;

    FIFO simu(
        .clk(clk),
        .rst(rst),
        .enq(enq),
        .deq(deq),
        .in(in),
        .out(out),
        .empty(empty),
        .full(full)
    );

    initial begin
        clk = 0;
        rst = 1;
        enq = 0;
        deq = 0;
        in = 0;
        #10 rst = 0;
    end
    initial begin
    forever
        #1 clk = ~clk;
    end
    
    integer i;
    initial begin
        # 5
        for(i = 0; i < 16; i = i + 1)begin
            #10;
            enq = ~enq;
        end
        for (i = 0;i < 16 ;i = i + 1 ) begin
            #10;
            deq = ~deq; 
        end
    end
    initial begin
        forever begin
            #20 in = in + 1;
        end
    end
endmodule
