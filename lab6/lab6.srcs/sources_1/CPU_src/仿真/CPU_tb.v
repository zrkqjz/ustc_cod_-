`timescale 1ns / 1ps
/* 
 *   Author: wintermelon
 *   Last update: 2023.04.20
 */

// CPU testbench
module CPU_tb();

    reg cpu_clk, cpu_rst;
    wire[31:0] mem_addr, mem_din, mem_dout, im_addr, im_dout, current_pc, next_pc;
    wire [2:0] func3;
    wire mem_we;
    wire [31:0] test, test2/* , test3 */;
    wire [31:0] inst_if, inst_id, inst_ex;
/*     wire [31:0] cpu_check_data;
    wire [2:0] func3; */
    CPU cpu (
        .test2(test2),
        .inst_if(inst_if),
        .inst_id(inst_id),
        .inst_ex(inst_ex),
        .func3_mem(func3),
        .clk(cpu_clk), 
        .rst(cpu_rst),

        // ================================ Memory and MMIO Part ================================
        // MEM And MMIO Data BUS
        .im_addr(im_addr),
        .im_dout(im_dout),
        .mem_addr(mem_addr),
        .mem_we(mem_we),			
        .mem_din(mem_din),	
        .mem_dout(mem_dout),


        // ================================ Debug Part ================================
        // Debug BUS with PDU
        .test(test),
        .current_pc(current_pc), 	 
        .next_pc(next_pc),   
        .cpu_check_addr(32'h05),	
        .cpu_check_data()    // No need to connect

    );

/*     wire [31:0] mem_check_data;
    wire [31:0] mem_t; */
    MEM memory (
        .func3(func3),
        /* .mem_t(mem_t), */
        .clk(cpu_clk),
        // No reset signals here

        // ================================ Memory Part ================================
        // MEM Data BUS with CPU
        .im_addr(im_addr),
        .im_dout(im_dout),
        .dm_addr(mem_addr),
        .dm_we(mem_we),
        .dm_din(mem_din),
        .dm_dout(mem_dout),
        
        // ================================ Debug Part ================================
        // MEM Debug BUS
        .mem_check_addr(32'h01),
        .mem_check_data()   // No need to connect
    );


    // Set the signals

    initial begin
        cpu_clk = 0;
        cpu_rst = 1;

        #20 cpu_rst = 0;
    end

    always #3 cpu_clk <= ~cpu_clk;      // 10ns Clock

endmodule
