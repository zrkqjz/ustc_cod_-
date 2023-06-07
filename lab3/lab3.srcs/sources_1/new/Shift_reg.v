`timescale 1ns / 1ps

module Shift_reg(
    input rst,
    input clk,          // Work at 100MHz clock

    input [31:0] din,   // Data input  
    input [3:0] hex,    // Hexadecimal code for the switches
    input add,          // Add signal
    input del,          // Delete signal
    input set,          // Set signal
    
    output reg [31:0] dout  // Data output
);

    // TODO
    reg [31:0] dout_mid;
    always @(posedge clk) begin
        if(rst) dout_mid <= 0;
        else if(set) dout_mid <=  din;
        else if(add) begin
            dout_mid <= {dout_mid[27:0], hex};
        end
        else if(del) begin
            dout_mid <= {4'b0, dout_mid[31:4]};
        end
        else
            dout_mid <= dout_mid;
    end
    always @(*) begin
        dout <= dout_mid;
    end
endmodule

