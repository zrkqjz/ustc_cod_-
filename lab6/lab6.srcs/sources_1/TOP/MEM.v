module MEM(
    output [31:0] mem_t,
    input [2:0] func3,
    input clk,

    // MEM Data BUS with CPU
	// IM port
    input [31:0] im_addr,
    output [31:0] im_dout,
	
	// DM port
    input  [31:0] dm_addr,
    input dm_we,
    input  [31:0] dm_din,
    output reg [31:0] dm_dout,

    // MEM Debug BUS
    input [31:0] mem_check_addr,
    output [31:0] mem_check_data
);
   
   // TODO: Your IP here.
   // Remember that we need [9:2]?
    dist_mem_gen_0 inst_mem(
        .a(im_addr[10:2]),
        .spo(im_dout)
    );


    reg [31:0] data_in; 
    wire [31:0] data_out;
    dist_mem_gen_1 data_mem_0(
        .a(dm_addr[9:2]),
        .d(data_in[7:0]),
        .dpra(mem_check_addr[7:0]),
        .we(dm_we),
        .clk(clk),
        .spo(data_out[7:0]),
        .dpo(mem_check_data[7:0])
    );

    dist_mem_gen_2 data_mem_1(
        .a(dm_addr[9:2]),
        .d(data_in[15:8]),
        .dpra(mem_check_addr[7:0]),
        .we(dm_we),
        .clk(clk),
        .spo(data_out[15:8]),
        .dpo(mem_check_data[15:8])
    );

    dist_mem_gen_3 data_mem_2(
        .a(dm_addr[9:2]),
        .d(data_in[23:16]),
        .dpra(mem_check_addr[7:0]),
        .we(dm_we),
        .clk(clk),
        .spo(data_out[23:16]),
        .dpo(mem_check_data[23:16])
    );

    dist_mem_gen_4 data_mem_3(
        .a(dm_addr[9:2]),
        .d(data_in[31:24]),
        .dpra(mem_check_addr[7:0]),
        .we(dm_we),
        .clk(clk),
        .spo(data_out[31:24]),
        .dpo(mem_check_data[31:24])
    );

    always @(*) begin
        case (func3)
            3'b000: //LB
            case (dm_addr[1:0])
                2'b00: dm_dout = {{24{data_out[7]}},  data_out[7:0]};
                2'b01: dm_dout = {{24{data_out[15]}}, data_out[15:8]};
                2'b10: dm_dout = {{24{data_out[23]}}, data_out[23:16]};
                2'b11: dm_dout = {{24{data_out[31]}}, data_out[31:24]};
            endcase
            3'b001: //LH
            case (dm_addr[1])
                1'b0: dm_dout = {{16{data_out[15]}}, data_out[15:0]};
                1'b1: dm_dout = {{16{data_out[31]}}, data_out[31:16]};
            endcase
            3'b010: dm_dout = data_out; //LW
            3'b100: //LBU
            case (dm_addr[1:0])
                2'b00: dm_dout = {24'h0, data_out[7:0]};
                2'b01: dm_dout = {24'h0, data_out[15:8]};
                2'b10: dm_dout = {24'h0, data_out[23:16]};
                2'b11: dm_dout = {24'h0, data_out[31:24]};
            endcase
            3'b101: //LHU
            case (dm_addr[1])
                1'b0: dm_dout = {16'h0, data_out[15:0]};
                1'b1: dm_dout = {16'h0, data_out[31:16]};
            endcase
            default: dm_dout = data_out;
        endcase
    end

    always @(*) begin
        if (dm_we) begin
            case(func3)
                3'b000: //SB
                case(dm_addr[1:0]) 
                    2'b00: data_in = {data_out[31:8], dm_din[7:0]};
                    2'b01: data_in = {data_out[31:16], dm_din[7:0], data_out[7:0]};
                    2'b10: data_in = {data_out[31:24], dm_din[7:0], data_out[15:0]};
                    2'b11: data_in = {dm_din[7:0], data_out[23:0]};
                endcase
                3'b001: //SH
                case (dm_addr[1])
                    1'b0: data_in = {data_out[31:16], dm_din[15:0]};
                    1'b1: data_in = {dm_din[15:0], data_out[15:0]};
                endcase
                3'b010: data_in = dm_din; //SW
                default: data_in = data_out;
            endcase
        end
        else begin
            data_in = data_out;
        end
    end

    assign mem_t = func3;
endmodule