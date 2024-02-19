`include "DESIGN_module.v"
`include "synchronizer/Handshake_syn.v"
`include "synchronizer/FIFO_syn.v"
`include "synchronizer/NDFF_syn.v"
`include "synchronizer/PULSE_syn.v"
`include "synchronizer/NDFF_BUS_syn.v"

module PRGN_TOP (
	// Input signals
	clk1,
	clk2,
	clk3,
	rst_n,
	in_valid,
	seed,
	//  Output signals
	out_valid,
	rand_num
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk1; 
input clk2;
input clk3;			
input rst_n;
input in_valid;
input [31:0] seed;
output out_valid;
output [31:0] rand_num; 	

// --------------------------------------------------------------------
//   SIGNAL DECLARATION
// --------------------------------------------------------------------
wire sidle;
wire seed_valid_clk1;
wire [31:0] seed_clk1;
wire seed_valid_clk2;
wire [31:0] seed_clk2;
wire prgn_busy;
wire rand_num_valid_clk2;
wire [31:0] rand_num_clk2;
wire fifo_full;
wire fifo_empty;
wire fifo_rinc;
wire [31:0] fifo_rdata; 

// Custom flags to use if needed
wire clk1_handshake_flag1;
wire clk1_handshake_flag2;
wire clk1_handshake_flag3;
wire clk1_handshake_flag4;

wire handshake_clk2_flag1;
wire handshake_clk2_flag2;
wire handshake_clk2_flag3;
wire handshake_clk2_flag4;

wire clk2_fifo_flag1;
wire clk2_fifo_flag2;
wire clk2_fifo_flag3;
wire clk2_fifo_flag4;

wire fifo_clk3_flag1;
wire fifo_clk3_flag2;
wire fifo_clk3_flag3;
wire fifo_clk3_flag4;


CLK_1_MODULE u_input (
    .clk (clk1),
    .rst_n (rst_n),
    .in_valid (in_valid),
    .seed_in (seed),
    .out_idle (sidle),
    .out_valid (seed_valid_clk1),
    .seed_out (seed_clk1),

    .clk1_handshake_flag1(clk1_handshake_flag1),
    .clk1_handshake_flag2(clk1_handshake_flag2),
    .clk1_handshake_flag3(clk1_handshake_flag3),
    .clk1_handshake_flag4(clk1_handshake_flag4)
);


Handshake_syn #(32) u_Handshake_syn (
    .sclk (clk1),
    .dclk (clk2),
    .rst_n (rst_n),
    .sready (seed_valid_clk1),
    .din (seed_clk1),
    .dbusy (prgn_busy),
    .sidle (sidle),
    .dvalid (seed_valid_clk2),
    .dout (seed_clk2),

    .clk1_handshake_flag1(clk1_handshake_flag1),
    .clk1_handshake_flag2(clk1_handshake_flag2),
    .clk1_handshake_flag3(clk1_handshake_flag3),
    .clk1_handshake_flag4(clk1_handshake_flag4),

    .handshake_clk2_flag1(handshake_clk2_flag1),
    .handshake_clk2_flag2(handshake_clk2_flag2),
    .handshake_clk2_flag3(handshake_clk2_flag3),
    .handshake_clk2_flag4(handshake_clk2_flag4)
);

CLK_2_MODULE u_PRGN (
	.clk (clk2),
    .rst_n (rst_n),
    .in_valid (seed_valid_clk2),
    .fifo_full (fifo_full),
    .seed (seed_clk2),
    .out_valid (rand_num_valid_clk2),
    .rand_num (rand_num_clk2),
    .busy (prgn_busy),

    .handshake_clk2_flag1(handshake_clk2_flag1),
    .handshake_clk2_flag2(handshake_clk2_flag2),
    .handshake_clk2_flag3(handshake_clk2_flag3),
    .handshake_clk2_flag4(handshake_clk2_flag4),

    .clk2_fifo_flag1(clk2_fifo_flag1),
    .clk2_fifo_flag2(clk2_fifo_flag2),
    .clk2_fifo_flag3(clk2_fifo_flag3),
    .clk2_fifo_flag4(clk2_fifo_flag4)
);

FIFO_syn #(.WIDTH(32), .WORDS(64)) u_FIFO_syn (
    .wclk (clk2),
    .rclk (clk3),
    .rst_n (rst_n),
    .winc (rand_num_valid_clk2),
    .wdata (rand_num_clk2),
    .wfull (fifo_full),
    .rinc (fifo_rinc),
    .rdata (fifo_rdata),
    .rempty (fifo_empty),

    .clk2_fifo_flag1(clk2_fifo_flag1),
    .clk2_fifo_flag2(clk2_fifo_flag2),
    .clk2_fifo_flag3(clk2_fifo_flag3),
    .clk2_fifo_flag4(clk2_fifo_flag4),

    .fifo_clk3_flag1(fifo_clk3_flag1),
    .fifo_clk3_flag2(fifo_clk3_flag2),
    .fifo_clk3_flag3(fifo_clk3_flag3),
    .fifo_clk3_flag4(fifo_clk3_flag4)
);

CLK_3_MODULE u_output (
    .clk (clk3),
    .rst_n (rst_n),
    .fifo_empty (fifo_empty),
    .fifo_rdata (fifo_rdata),
    .fifo_rinc (fifo_rinc),
    .out_valid (out_valid),
    .rand_num (rand_num),

    .fifo_clk3_flag1(fifo_clk3_flag1),
    .fifo_clk3_flag2(fifo_clk3_flag2),
    .fifo_clk3_flag3(fifo_clk3_flag3),
    .fifo_clk3_flag4(fifo_clk3_flag4)
);


endmodule