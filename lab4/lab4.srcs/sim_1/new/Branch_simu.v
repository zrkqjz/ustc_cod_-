`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 21:24:26
// Design Name: 
// Module Name: Branch_simu
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


module Branch_simu(

    );
    reg [31:0] rd0;
    reg [31:0] rd1;
    reg [2:0] br_type;
    wire br;
    
    initial begin
        rd0 = 32'hffff_ffff;
        rd1 = 32'h7fff_ffff;
        br_type = 3'b110;
    end
    Branch t_branch(
        br_type,
        rd0,
        rd1,
        br
    );
    
endmodule
