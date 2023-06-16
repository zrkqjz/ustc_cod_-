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


module BTB#(parameter Index_LEN = 4)(
    input               rst,
    input               clk,
    input       [29:0]  pc,
    input       [29:0]  EX_pc,
    input               enable,
    input               EX_btb_hit,
    input               branch_taken,
    input       [31:0]  EX_branch_target,
    input       [1:0]   pc_sel_ex,
    output  reg         btb_hit,
    output  reg [31:0]  btb_target,
    output              btb_fail,
    output  reg [1:0]   pc_sel_btb,
    output reg  [31:0]  branch_cnt,
    output reg  [31:0]  btb_succ_cnt,
    output reg  [31:0]  btb_fail_cnt
    );
    localparam TAG_LEN  = 30 - Index_LEN;
    localparam Index_Size = 1 << Index_LEN;

    localparam STRONG_TAKEN  = 2'b11;
    localparam WEAK_TAKEN    = 2'b10;
    localparam WEAK_MISS   = 2'b01;
    localparam STRONG_MISS = 2'b00;

    localparam BHR_SIZE = 2'b10;

    // Buffer Register
    reg [TAG_LEN - 1 : 0] tag    [Index_Size - 1 : 0];
    reg [31:0]            target [Index_Size - 1 : 0];
    reg                   valid  [Index_Size - 1 : 0];
    reg [BHR_SIZE - 1 : 0]BHR    [Index_Size - 1 : 0];
    reg [1:0]             state  [Index_Size + BHR_SIZE - 1 : 0];

    // PC tag and index
    wire [TAG_LEN - 1 : 0] pc_tag;
    wire [Index_LEN - 1 : 0] pc_idx;
    wire [TAG_LEN - 1 : 0] EX_pc_tag;
    wire [Index_LEN - 1 : 0] EX_pc_idx;
    wire [Index_Size + BHR_SIZE - 1 : 0] State_idx;
    wire [Index_Size + BHR_SIZE - 1 : 0] EX_State_idx;

    assign {pc_tag,      pc_idx}      = pc;
    assign {EX_pc_tag, EX_pc_idx} = EX_pc;
    assign State_idx = {pc_idx, BHR[pc_idx]};
    assign EX_State_idx = {EX_pc_idx, BHR[EX_pc_idx]};

    //Predict : btb_hit = branch taken, btb_target = target pc
    always @(*) begin
        if (rst) begin
            btb_hit    = 1'b0;
            btb_target = 32'h0;
        end
        else if (valid[pc_idx] && (pc_tag == tag[pc_idx]) && state[State_idx][1]) begin //predict : taken
            btb_hit    = 1'b1;
            btb_target = target[pc_idx];
        end
        else begin
            btb_hit    = 1'b0;
            btb_target = 32'h0;
        end
    end

    reg btb_p_nt, btb_np_t;

    assign btb_fail = btb_p_nt | btb_np_t;

    always @(*) begin
        if (rst) begin
            btb_p_nt  = 1'b0;
            btb_np_t  = 1'b0;
        end
        else begin
            btb_p_nt = (EX_btb_hit) & (~branch_taken);
            btb_np_t = (~EX_btb_hit) & (branch_taken);
        end
    end

    //BHR Update
    always @(posedge clk) begin
        BHR[EX_pc_idx] = {BHR[EX_pc_idx][0], branch_taken};
    end

    integer i = 0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < Index_Size; i = i + 1) begin
                tag[i]    <= 0;
                target[i] <= 32'h0;
                valid[i]  <= 1'b0;
                BHR[i] <= 2'b0;
                state[i*4]  <= WEAK_MISS;
                state[i*4+1]<= WEAK_MISS;
                state[i*4+2]<= WEAK_MISS;
                state[i*4+3]<= WEAK_MISS;
            end
        end
        else if (branch_taken) begin
            // tag matched, update state
            if ((tag[EX_pc_idx] == EX_pc_tag) && valid[EX_pc_idx]) begin
                case (state[EX_State_idx])
                STRONG_TAKEN:
                    state[EX_State_idx] <= btb_fail ? WEAK_TAKEN  : STRONG_TAKEN;
                WEAK_TAKEN:
                    state[EX_State_idx] <= btb_fail ? WEAK_MISS : STRONG_TAKEN;
                WEAK_MISS:
                    state[EX_State_idx] <= btb_fail ? WEAK_TAKEN  : STRONG_MISS;
                STRONG_MISS:
                    state[EX_State_idx] <= btb_fail ? WEAK_MISS : STRONG_MISS;
                endcase
            end
            // tag not matched, change cache
            else begin
                tag[EX_pc_idx]    <= EX_pc_tag;
                target[EX_pc_idx] <= EX_branch_target;
                valid[EX_pc_idx]  <= 1'b1;
                BHR[EX_pc_idx]    <= 'b0;
                state[EX_pc_idx*4]  <= WEAK_MISS;
                state[EX_pc_idx*4+1]<= WEAK_MISS;
                state[EX_pc_idx*4+2]<= WEAK_MISS;
                state[EX_pc_idx*4+3]<= WEAK_MISS;
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
