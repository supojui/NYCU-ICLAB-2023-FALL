//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//###########################################
//
// Wrtie down your design below
//
//###########################################

parameter IDLE    = 0;
parameter FETCH   = 1;
parameter DECODE  = 2;
parameter EXE     = 3;
parameter W_B     = 4;


parameter WAIT_arready_ins = 5;
parameter READ_ins = 6;

parameter WAIT_arready_dat = 7;
parameter READ_dat = 8;

parameter LOAD = 9;
parameter STORE = 10;
parameter WRITE_BACK = 11;
parameter WRITE_dat = 12;
parameter WAIT_bvalid = 13;


parameter signed offset = 16'h1000;

//####################################################
//               reg & wire
//####################################################
reg [3:0]cur_state, nxt_state;

reg [15:0]ins_to_cache;
reg [31:0]rdata_m_inf_seq;
reg rvalid_seq;

reg [6:0]addr_cache;
reg [6:0]addr_cache_seq;
reg [15:0]cache_out;
reg web;


reg signed [15:0]cur_pc, nxt_pc;
reg signed [15:0]pc_now;
reg [15:0]ins;

wire [2:0]op_code;
wire [3:0]rs;
wire [3:0]rt;
wire [3:0]rd;
wire func;
wire signed [4:0]imm;
wire [12:0]addr;
reg  [2:0]counter_fetch;


reg signed [15:0]rs_data;
reg signed [15:0]rt_data;
reg signed [15:0]rd_data;


wire signed [15:0]dram_addr;


assign arid_m_inf = 0;
assign arburst_m_inf = 4'b0101;
assign arsize_m_inf = 6'b001001;
assign arlen_m_inf = 14'b11_1111_1000_0000;



//####################################################
//               State Control
//####################################################
always @(*) begin
	case(cur_state)
		IDLE : nxt_state = (cur_state == IDLE) ? WAIT_arready_ins : IDLE;
		WAIT_arready_ins : nxt_state = (arready_m_inf) ? READ_ins : WAIT_arready_ins;
		READ_ins : begin
			if(addr_cache_seq == 127) begin
				nxt_state = FETCH;
			end
			else begin
				nxt_state = READ_ins;
			end
		end
		FETCH : begin
			nxt_state = (counter_fetch == 3) ? DECODE : FETCH;
		end
		DECODE : begin
			nxt_state = EXE;
		end
		EXE : begin
			if(op_code == 3'b010) begin
				nxt_state = LOAD;
			end
			else if(op_code == 3'b011) begin
				nxt_state = STORE;
			end////////////////////////////////////////////
			else if(op_code == 3'b101) begin/////////////////
				nxt_state = (cur_pc[11:8] == pc_now[11:8]) ? FETCH : WAIT_arready_ins;
			end////////////////////////////////////////////
			else if(op_code == 3'b100) begin
				if(rs_data == rt_data) begin
					nxt_state = (cur_pc[11:8] == pc_now[11:8]) ? FETCH : WAIT_arready_ins;
				end
				else begin
					nxt_state = (cur_pc[11:8] == pc_now[11:8]) ? FETCH : WAIT_arready_ins;
				end
			end
			else begin
				nxt_state = WRITE_BACK;
			end

		end
		LOAD : begin
			nxt_state = (arready_m_inf) ? READ_dat : LOAD;
		end
		READ_dat : begin
			if(rlast_m_inf == 1) begin
				nxt_state = (cur_pc[11:8] == pc_now[11:8]) ? FETCH : WAIT_arready_ins;
			end
			else begin
				nxt_state = READ_dat;
			end
		end
		WRITE_BACK : nxt_state = (cur_pc[11:8] == pc_now[11:8]) ? FETCH : WAIT_arready_ins;
		STORE : begin
			nxt_state = (awready_m_inf) ? WRITE_dat : STORE;
		end
		WRITE_dat : begin
			nxt_state = (wready_m_inf) ? WAIT_bvalid : WRITE_dat;
		end
		WAIT_bvalid : begin
			nxt_state = (bvalid_m_inf) ? (cur_pc[11:8] == pc_now[11:8]) ? FETCH : WAIT_arready_ins : WAIT_bvalid;
		end
		default : nxt_state = IDLE;
	endcase
end


always @(posedge clk or negedge rst_n ) begin
	if(!rst_n) begin
		cur_state <= IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end


//####################################################
//               READ ins
//####################################################
assign dram_addr = (rs_data+imm)*2 + offset;
assign arvalid_m_inf = (cur_state == WAIT_arready_ins) ? 2 : (cur_state == LOAD) ? 1 : 0;
assign araddr_m_inf  = (cur_state == WAIT_arready_ins) ? {cur_pc[15:8], 8'b0, 32'b0} : (cur_state == LOAD) ? {32'b0, dram_addr} : 0;
assign rready_m_inf  = (cur_state == READ_ins) ? 2 : (cur_state == READ_dat) ? 1 : 0;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rdata_m_inf_seq <= 0;
	end
	else begin
		rdata_m_inf_seq <= rdata_m_inf;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rvalid_seq <= 0;
	end
	else begin
		rvalid_seq <= rvalid_m_inf[1] || rvalid_m_inf[0];
	end
end

always @(*) begin
	ins_to_cache = (rvalid_seq && cur_state == READ_ins) ? rdata_m_inf_seq[31:16] : rdata_m_inf_seq[15:0];	
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		addr_cache_seq <= 0;
	end
	else begin
		if(rvalid_seq && (cur_state == READ_ins || cur_state == READ_dat)) begin
			addr_cache_seq <= addr_cache + 1;
		end
		else begin
			addr_cache_seq <= (op_code == 3'b010) ? 128 : 0;
		end
	end
end

always @(*) begin
	if(cur_state == FETCH) begin
		addr_cache = cur_pc[7:1];
	end
	else begin
		addr_cache = addr_cache_seq;
	end
end

always @(*) begin
	if(rvalid_seq && cur_state == READ_ins) begin
		web = 0;
	end
	else begin
		web = 1;
	end
end

// mem_16x256 cache  (.A0(addr_cache[0]),.A1(addr_cache[1]),.A2(addr_cache[2]),.A3(addr_cache[3]),.A4(addr_cache[4]),.A5(addr_cache[5]),.A6(addr_cache[6]),.A7(addr_cache[7]),
// 				   .DO0(cache_out[0]),.DO1(cache_out[1]),.DO2(cache_out[2]),.DO3(cache_out[3]),.DO4(cache_out[4]),.DO5(cache_out[5]),
//                    .DO6(cache_out[6]),.DO7(cache_out[7]),.DO8(cache_out[8]),.DO9(cache_out[9]),.DO10(cache_out[10]),.DO11(cache_out[11]),
// 				   .DO12(cache_out[12]),.DO13(cache_out[13]),.DO14(cache_out[14]),.DO15(cache_out[15]),
// 				   .DI0(ins_to_cache[0]),.DI1(ins_to_cache[1]),.DI2(ins_to_cache[2]),.DI3(ins_to_cache[3]),.DI4(ins_to_cache[4]),.DI5(ins_to_cache[5]),
// 				   .DI6(ins_to_cache[6]),.DI7(ins_to_cache[7]),.DI8(ins_to_cache[8]),.DI9(ins_to_cache[9]),.DI10(ins_to_cache[10]),.DI11(ins_to_cache[11]),
// 				   .DI12(ins_to_cache[12]),.DI13(ins_to_cache[13]),.DI14(ins_to_cache[14]),.DI15(ins_to_cache[15]),
// 				   .CK(clk),.WEB(web),.OE(1'b1), .CS(1'b1));

mem_16x128 cache   (.A0(addr_cache[0]),.A1(addr_cache[1]),.A2(addr_cache[2]),.A3(addr_cache[3]),.A4(addr_cache[4]),.A5(addr_cache[5]),.A6(addr_cache[6]),
					.DO0(cache_out[0]),.DO1(cache_out[1]),.DO2(cache_out[2]),.DO3(cache_out[3]),.DO4(cache_out[4]),.DO5(cache_out[5]),
					.DO6(cache_out[6]),.DO7(cache_out[7]),.DO8(cache_out[8]),.DO9(cache_out[9]),.DO10(cache_out[10]),.DO11(cache_out[11]),
					.DO12(cache_out[12]),.DO13(cache_out[13]),.DO14(cache_out[14]),.DO15(cache_out[15]),
                    .DI0(ins_to_cache[0]),.DI1(ins_to_cache[1]),.DI2(ins_to_cache[2]),.DI3(ins_to_cache[3]),.DI4(ins_to_cache[4]),.DI5(ins_to_cache[5]),
				    .DI6(ins_to_cache[6]),.DI7(ins_to_cache[7]),.DI8(ins_to_cache[8]),.DI9(ins_to_cache[9]),.DI10(ins_to_cache[10]),.DI11(ins_to_cache[11]),
				    .DI12(ins_to_cache[12]),.DI13(ins_to_cache[13]),.DI14(ins_to_cache[14]),.DI15(ins_to_cache[15]),
				    .CK(clk),.WEB(web),.OE(1'b1), .CS(1'b1));



always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pc_now <= 0;
	end
	else begin
		pc_now <= (nxt_state == WAIT_arready_ins && cur_state != WAIT_arready_ins) ? cur_pc : pc_now;
	end
end



//####################################################
//               FETCH 
//####################################################
assign op_code = ins[15:13];
assign rs 	   = ins[12:9];
assign rt 	   = ins[8:5];
assign rd 	   = ins[4:1];
assign func    = ins[0];
assign imm 	   = ins[4:0];
assign addr    = {3'b000, ins[12:0]};


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ins <= 0;
	end
	else begin
		ins <= (cur_state == FETCH) ? cache_out : ins;
	end
end 

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		counter_fetch <= 0;
	end
	else begin
		counter_fetch <= (cur_state == FETCH) ? counter_fetch + 1 : 0;
	end
end


//####################################################
//               DECODE 
//####################################################
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rs_data <= 0;
	end
	else begin
		if(nxt_state == DECODE) begin
			case(rs)
				0 : rs_data <= core_r0;
				1 : rs_data <= core_r1;
				2 : rs_data <= core_r2;
				3 : rs_data <= core_r3;
				4 : rs_data <= core_r4;
				5 : rs_data <= core_r5;
				6 : rs_data <= core_r6;
				7 : rs_data <= core_r7;
				8 : rs_data <= core_r8;
				9 : rs_data <= core_r9;
				10 : rs_data <= core_r10;
				11 : rs_data <= core_r11;
				12 : rs_data <= core_r12;
				13 : rs_data <= core_r13;
				14 : rs_data <= core_r14;
				15 : rs_data <= core_r15;
			endcase
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rt_data <= 0;
	end
	else begin
		if(nxt_state == DECODE) begin
			case(rt)
				0 : rt_data <= core_r0;
				1 : rt_data <= core_r1;
				2 : rt_data <= core_r2;
				3 : rt_data <= core_r3;
				4 : rt_data <= core_r4;
				5 : rt_data <= core_r5;
				6 : rt_data <= core_r6;
				7 : rt_data <= core_r7;
				8 : rt_data <= core_r8;
				9 : rt_data <= core_r9;
				10 : rt_data <= core_r10;
				11 : rt_data <= core_r11;
				12 : rt_data <= core_r12;
				13 : rt_data <= core_r13;
				14 : rt_data <= core_r14;
				15 : rt_data <= core_r15;
			endcase
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_data <= 0;
	end
	else begin
		if(nxt_state == EXE) begin
			case(op_code)
				3'b000 : begin
					rd_data <= (func == 0) ? rs_data + rt_data : rs_data - rt_data;
				end
				3'b001 : begin
					if(func == 0) begin
						rd_data <= (rs_data < rt_data) ? 1 : 0;
					end
					else begin
						rd_data <= rs_data * rt_data;
					end
				end
				default : rd_data <= 0;
			endcase
		end
	end
end
//####################################################
//               EXE 
//####################################################
always @(*) begin
	case(op_code)
		3'b101 : nxt_pc = addr;
		3'b100 : begin
			if(rs_data == rt_data) begin
				nxt_pc = cur_pc + 2 + imm*2;
			end
			else begin
				nxt_pc = cur_pc + 2;
			end
		end
		default : nxt_pc = cur_pc + 2;

	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cur_pc <= 'h1000;
	end
	else begin
		cur_pc <= (nxt_state == EXE) ? nxt_pc : cur_pc;
	end
end 


//####################################################
//               WRITE DRAM
//####################################################
// assign dram_addr = (rs_data+imm)*2 + offset;
assign awid_m_inf = 0;
assign awburst_m_inf = 4'b0101;
assign awsize_m_inf = 6'b001001;
assign awlen_m_inf = 14'b00_0000_0000_0000;


assign awaddr_m_inf = {32'b0, dram_addr};
assign awvalid_m_inf = (cur_state == STORE) ? 1 : 0;

assign wvalid_m_inf = (cur_state == WRITE_dat) ? 1 : 0;
assign wdata_m_inf  = (cur_state == WRITE_dat) ? rt_data : 0;
assign wlast_m_inf  = (cur_state == WRITE_dat) ? 1 : 0;

assign bready_m_inf = (cur_state == WAIT_bvalid) ? 1 : 0;

//####################################################
//               Resgiter mani.
//####################################################
reg signed [31:0]rdata_dummy1;
// reg signed [31:0]rdata_dummy2;
// reg signed [31:0]rdata_dummy3;
// reg signed [31:0]rdata_dummy4;


reg signed [31:0]rd_data_dummy1;
// reg signed [31:0]rd_data_dummy2;
// reg signed [31:0]rd_data_dummy3;
// reg signed [31:0]rd_data_dummy4;

always @(*) begin
	rdata_dummy1 = 0;
	rd_data_dummy1 = 0;
	if(rst_n == 1) begin
		if(cur_state >= 1) begin
			if(nxt_state >= 1) begin
				if(IO_stall == 1) begin
					rdata_dummy1 = rdata_m_inf;
					rd_data_dummy1 = rd_data;
				end
			end
		end
	end
end

// always @(*) begin
// 	if(cur_state >= 1) begin
// 		rdata_dummy2 = ~rdata_dummy1;
// 		rd_data_dummy2 = ~rd_data_dummy1;
// 	end
// 	else begin
// 		rdata_dummy2 = 0;
// 		rd_data_dummy2 = 0;
// 	end
// end

// always @(*) begin
// 	if(nxt_state >= 1) begin
// 		rdata_dummy3 = ~rdata_dummy2;
// 		rd_data_dummy3 = ~rd_data_dummy2;
// 	end
// 	else begin
// 		rdata_dummy3 = 0;
// 		rd_data_dummy3 = 0;
// 	end
// end

// always @(*) begin
// 	if(IO_stall == 1) begin
// 		rdata_dummy4 = ~rdata_dummy3;
// 		rd_data_dummy4 = ~rd_data_dummy3;
// 	end
// 	else begin
// 		rdata_dummy4 = 0;
// 		rd_data_dummy4 = 0;
// 	end
// end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r0 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 0) begin
			core_r0 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 0) begin
			core_r0 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r1 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 1) begin
			core_r1 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 1) begin
			core_r1 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r2 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 2) begin
			core_r2 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 2) begin
			core_r2 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r3 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 3) begin
			core_r3 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 3) begin
			core_r3 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r4 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 4) begin
			core_r4 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 4) begin
			core_r4 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r5 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 5) begin
			core_r5 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 5) begin
			core_r5 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r6 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 6) begin
			core_r6 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 6) begin
			core_r6 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r7 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 7) begin
			core_r7 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 7) begin
			core_r7 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r8 <= 0;
	end
	else begin
		if(nxt_state == WRITE_BACK && rd == 8) begin
			core_r8 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 8) begin
			core_r8 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r9 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 9) begin
			core_r9 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 9) begin
			core_r9 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r10 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 10) begin
			core_r10 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 10) begin
			core_r10 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r11 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 11) begin
			core_r11 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 11) begin
			core_r11 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r12 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 12) begin
			core_r12 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 12) begin
			core_r12 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r13 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 13) begin
			core_r13 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 13) begin
			core_r13 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r14 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 14) begin
			core_r14 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 14) begin
			core_r14 <= rdata_dummy1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		core_r15 <= 0;
	end
	else begin		
		if(nxt_state == WRITE_BACK && rd == 15) begin
			core_r15 <= rd_data_dummy1;
		end
		else if(rvalid_m_inf == 1 && rvalid_seq == 0 && rt == 15) begin
			core_r15 <= rdata_dummy1;
		end
	end
end

//####################################################
//               Output Control
//####################################################
reg not_init_read_ins;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		not_init_read_ins <= 0;
	end
	else begin
		not_init_read_ins <= (cur_state != FETCH && nxt_state == FETCH) ? 1 : not_init_read_ins;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		IO_stall <= 1;
	end
	else begin
		if (nxt_state == FETCH && cur_state != FETCH && not_init_read_ins == 1)
			IO_stall <= 0;
		else 
			IO_stall <= (araddr_m_inf == 64'h2000_0000_0000) ? 0 : 1;
	end
end


endmodule



















