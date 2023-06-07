`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/05 16:41:58
// Design Name: 
// Module Name: BTB
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


module BTB#(parameter BUF_LEN = 4)(
    input               rst,
    input               clk,
    input       [29:0]  pc,
    input       [29:0]  IDEX_pc,
    input               enable,
    input               IDEX_btb_hit,
    input               branch_taken,
    input       [31:0]  IDEX_branch_target,
    input       [1:0]   pc_sel_ex,
    output  reg         btb_hit,
    output  reg [31:0]  btb_target,
    output              btb_fail,
    output  reg [1:0]   pc_sel_btb,
    output reg  [31:0]  branch_cnt,
    output reg  [31:0]  btb_succ_cnt,
    output reg  [31:0]  btb_fail_cnt
    );
    localparam TAG_LEN  = 30 - BUF_LEN;
    localparam BUF_SIZE = 1 << BUF_LEN;

    localparam STRONG_TAKEN  = 2'b11;
    localparam WEAK_TAKEN    = 2'b10;
    localparam WEAK_MISS   = 2'b01;
    localparam STRONG_MISS = 2'b00;

    // Buffer Register
    reg [TAG_LEN - 1 : 0] tag    [BUF_SIZE - 1 : 0];
    reg [31:0]            target [BUF_SIZE - 1 : 0];
    reg                   valid  [BUF_SIZE - 1 : 0];
    reg [1:0]             state  [BUF_SIZE - 1 : 0];

    // PC tag and index
    wire [TAG_LEN - 1 : 0] pc_tag;
    wire [BUF_LEN - 1 : 0] pc_idx;
    wire [TAG_LEN - 1 : 0] IDEX_pc_tag;
    wire [BUF_LEN - 1 : 0] IDEX_pc_idx;

    assign {pc_tag,      pc_idx}      = pc;
    assign {IDEX_pc_tag, IDEX_pc_idx} = IDEX_pc;

    //Predict : btb_hit = branch taken, btb_target = target pc
    always @(*) begin
        if (rst) begin
            btb_hit    = 1'b0;
            btb_target = 32'h0;
        end
        else if (valid[pc_idx] && (pc_tag == tag[pc_idx]) && state[pc_idx][1]) begin //predict : taken
            btb_hit    = 1'b1;
            btb_target = target[pc_idx];
        end
        else begin
            btb_hit    = 1'b0;
            btb_target = 32'h0;
        end
    end

    // Buffer Update
    reg btb_p_nt;  // branch predicted but not taken 
    reg btb_np_t;  // not branch predicted but taken

    assign btb_fail = btb_p_nt | btb_np_t;

    always @(*) begin
        if (rst) begin
            btb_p_nt  = 1'b0;
            btb_np_t  = 1'b0;
        end
        else begin
            btb_p_nt = (IDEX_btb_hit) & (~branch_taken);
            btb_np_t = (~IDEX_btb_hit) & (branch_taken);
        end
    end

    integer i = 0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BUF_SIZE; i = i + 1) begin
                tag[i]    <= 0;
                target[i] <= 32'h0;
                valid[i]  <= 1'b0;
                state[i]  <= WEAK_MISS;
            end
        end
        else if (branch_taken) begin
            // tag matched, update state
            if ((tag[IDEX_pc_idx] == IDEX_pc_tag) && valid[IDEX_pc_idx]) begin
                case (state[IDEX_pc_idx])
                STRONG_TAKEN:
                    state[IDEX_pc_idx] <= btb_fail ? WEAK_TAKEN  : STRONG_TAKEN;
                WEAK_TAKEN:
                    state[IDEX_pc_idx] <= btb_fail ? WEAK_MISS : STRONG_TAKEN;
                WEAK_MISS:
                    state[IDEX_pc_idx] <= btb_fail ? WEAK_TAKEN  : STRONG_MISS;
                STRONG_MISS:
                    state[IDEX_pc_idx] <= btb_fail ? WEAK_MISS : STRONG_MISS;
                endcase
            end
            // tag not matched, change buffer
            else begin
                tag[IDEX_pc_idx]    <= IDEX_pc_tag;
                target[IDEX_pc_idx] <= IDEX_branch_target;
                valid[IDEX_pc_idx]  <= 1'b1;
                state[IDEX_pc_idx]  <= WEAK_MISS;
            end
        end
    end

    //pc_sel
    always @(*) begin
        if(pc_sel_ex == 2'b01)   pc_sel_btb = 2'b01;
        else if(pc_sel_ex == 2'b10) pc_sel_btb = 2'b10;
        else if(btb_p_nt)        pc_sel_btb = 2'b11;
        else if(btb_np_t)   pc_sel_btb = 2'b10;
        else                pc_sel_btb = 2'b00;
    end

    // Counter Part
always @(posedge clk or posedge rst) begin
    if (rst) begin
        branch_cnt   <= 32'h0;
        btb_succ_cnt <= 32'h0;
        btb_fail_cnt <= 32'h0;
    end
    else begin
        if (branch_taken) begin
            branch_cnt   <= branch_cnt   + 32'h1;
            if (btb_fail) btb_fail_cnt <= btb_fail_cnt + 32'h1;
            else          btb_succ_cnt <= btb_succ_cnt + 32'h1;
        end
        
    end
end
endmodule
