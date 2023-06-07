module MEM(
    input clk,

    // MEM Data BUS with CPU
	// IM port
    input [31:0] im_addr,
    output [31:0] im_dout,
	
	// DM port
    input  [31:0] dm_addr,
    input dm_we,
    input  [31:0] dm_din,
    output [31:0] dm_dout,

    // MEM Debug BUS
    input [31:0] mem_check_addr,
    output [31:0] mem_check_data
);
   
   // TODO: Your IP here.
   // Remember that we need [9:2]?
    dist_mem_gen_0 inst_mem(
        .a(im_addr[9:2]),
        .spo(im_dout)
    );

    dist_mem_gen_1 data_mem(
        .a(dm_addr[9:2]),
        .d(dm_din),
        .dpra(mem_check_addr[7:0]),
        .we(dm_we),
        .clk(clk),
        .spo(dm_dout),
        .dpo(mem_check_data)
    );
endmodule