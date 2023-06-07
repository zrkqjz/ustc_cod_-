`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/21 20:24:18
// Design Name: 
// Module Name: Hazard
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


module Hazard(
    input               btb_fail,
    input       [1:0]   rf_wd_sel_ex,
    input       [4:0]   rf_wa_ex,
    input       [4:0]   rf_ra0_id,
    input       [4:0]   rf_ra1_id,
    input               rf_re0_id,
    input               rf_re1_id,
    //
    input       [4:0]   rf_ra0_ex,
    input       [4:0]   rf_ra1_ex,
    input               rf_re0_ex,
    input               rf_re1_ex,
    input       [4:0]   rf_wa_mem,
    input               rf_we_mem,
    input       [1:0]   rf_wd_sel_mem,
    input       [31:0]  alu_ans_mem,
    input       [31:0]  pc_add4_mem,
    input       [31:0]  imm_mem,
    input       [4:0]   rf_wa_wb,
    input               rf_we_wb,
    input       [31:0]  rf_wd_wb,
    input       [1:0]   pc_sel_ex,
    output reg          rf_rd0_fe,
    output reg          rf_rd1_fe,
    output reg  [31:0]  rf_rd0_fd,
    output reg  [31:0]  rf_rd1_fd,
    output reg          stall_if,
    output reg          stall_id,
    output reg          stall_ex,
    output reg          flush_if,
    output reg          flush_id,
    output reg          flush_ex,
    output reg          flush_mem
    );
    //forward
    always @(*) begin
        if(rf_we_mem && (rf_wa_mem != 0) && (rf_ra0_ex == rf_wa_mem)) //mem前�??
        	rf_rd0_fe = 1'b1;
        else if(rf_we_wb && (rf_wa_wb != 0) && (rf_ra0_ex == rf_wa_wb)) //wb前�??
	        rf_rd0_fe = 1'b1;
        else 
        	rf_rd0_fe = 1'b0;
        
        if(rf_we_mem && (rf_wa_mem != 0) && (rf_ra1_ex == rf_wa_mem)) //mem前�??
        	rf_rd1_fe = 1'b1;
        else if(rf_we_wb && (rf_wa_wb != 0) && (rf_ra1_ex == rf_wa_wb)) //wb前�??
        	rf_rd1_fe = 1'b1;
        else
        	rf_rd1_fe = 1'b0;
    end

    always @(*) begin
        //TODO : 分离rd1 �?? rd0
        if((rf_ra0_ex == rf_wa_mem) && (rf_re0_ex) && rf_we_mem) begin //获取mem�???
        	case (rf_wd_sel_mem)
                2'b00: begin //alu
                    rf_rd0_fd = alu_ans_mem;
                end 
                2'b01: begin
                    rf_rd0_fd = pc_add4_mem;
                end
                2'b10: begin
                    rf_rd0_fd = rf_wd_wb;
                end
                2'b11: begin
                    rf_rd0_fd = imm_mem;              
                end
                default: begin
                    rf_rd0_fd = alu_ans_mem;
                end
            endcase
        end
        else if((rf_ra0_ex == rf_wa_wb) && (rf_re0_ex) && rf_we_wb) begin//获取wb�???
        	rf_rd0_fd = rf_wd_wb;
        end
        else begin //随便
        	rf_rd0_fd = rf_wd_wb;
        end

        if((rf_ra1_ex == rf_wa_mem) && (rf_re1_ex) && rf_we_mem) begin
            case (rf_wd_sel_mem)
                2'b00: begin //alu
        	        rf_rd1_fd = alu_ans_mem;
                end 
                2'b01: begin
                    rf_rd1_fd = pc_add4_mem;
                end
                2'b10: begin
                    rf_rd1_fd = rf_wd_wb;
                end
                2'b11: begin
                    rf_rd1_fd = imm_mem;               
                end
                default: begin
        	        rf_rd1_fd = alu_ans_mem;
                end                
            endcase
        end
        else if((rf_ra1_ex == rf_wa_wb) && (rf_re1_ex) && rf_we_wb) begin//获取wb�???
         	rf_rd1_fd = rf_wd_wb;
        end
        else begin //随便
        	rf_rd1_fd = rf_wd_wb;	
        end
    end

    //load use
    always @(*) begin
        if((rf_wd_sel_ex == 2'b10) && (((rf_wa_ex == rf_ra0_id) && rf_re0_id)||((rf_wa_ex == rf_ra1_id) && rf_re1_id))) begin
            stall_if = 1'b1;
            stall_id = 1'b1;
            stall_ex = 1'b0;
            flush_mem= 1'b0;
            flush_ex = 1'b1;
        end
        else if(btb_fail) begin
            flush_ex = 1'b1;
            flush_id = 1'b1;
        end
        else if(pc_sel_ex == 2'b01 || pc_sel_ex == 2'b10) begin
            flush_ex = 1'b1;
            flush_id = 1'b1;
            /* flush_mem= 1'b1; */
        end
        else begin
            stall_if = 1'b0;
            stall_id = 1'b0;
            stall_ex = 1'b0;
            flush_if = 1'b0;
            flush_mem= 1'b0;
            flush_ex = 1'b0;
            flush_id = 1'b0;    
            /* flush_ex = 1'b0;  */       
        end
    end

    //if branch 
/*     always @(*) begin
        if(pc_sel_ex != 2'b00) begin
            flush_ex = 1'b1;
            flush_id = 1'b1;
            flush_mem= 1'b1;
        end
        else begin
            flush_ex = 1'b0;
            flush_id = 1'b0;
            flush_mem= 1'b0;           
        end
    end */
endmodule
