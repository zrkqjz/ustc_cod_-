`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 19:59:39
// Design Name: 
// Module Name: block_simu
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


module block_simu(

    );
    reg clk;
    reg [4:0] addr;
    reg [15:0] in;
    reg we;
    wire [15:0] out_wf;
    wire [15:0] out_rf;
    wire [15:0] out_nc;
    
    initial begin
        clk = 0;
        we = 0;
        addr = 0;
        in = 1111;
        forever
            #1 clk = ~clk;
    end
    initial begin
        #50 we = 1;
        #5 in = 16'h2222; 
        #5 we = 0;
    end
    initial begin
        forever 
            #5 addr = addr + 1;
    end
    
    blk_mem_gen_0 blk_wf(
        .clka(clk),
        .addra(addr),
        .dina(in),
        .douta(out_wf),
        .wea(we)
    );
    
    blk_mem_gen_1 blk_rf(
        .clka(clk),
        .addra(addr),
        .dina(in),
        .douta(out_rf),
        .wea(we)     
    );
    
    blk_mem_gen_2 blk_nc(
        .clka(clk),
        .addra(addr),
        .dina(in),
        .douta(out_nc),
        .wea(we)
    );
endmodule
