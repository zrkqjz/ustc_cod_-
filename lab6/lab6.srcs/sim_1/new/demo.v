`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/05 21:54:09
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
    wire [1:0] t;
    BTB t_btb(
        .branch_taken(1'b1),
        .IDEX_btb_hit(1'b0),
        .pc_sel_ex(2'b11),
        .pc_sel_btb(t)
    );
endmodule
