//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Midterm Proejct            : MRA  
//   Author                     : Lin-Hung, Lai
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//   Release version : V2.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
    loc_y         	,
	cost	 		,		
	busy         	,

    // AXI4 IO
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
	   rready_m_inf,
	
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
	   bready_m_inf 
);

// ===============================================================
//  					Input / Output 
// ===============================================================

// << CHIP io port with system >>
input 			  	clk,rst_n;
input 			   	in_valid;
input  [4:0] 		frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;       
  
// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       Your AXI-4 interface could be designed as a bridge in submodule,
	   therefore I declared output of AXI as wire.  
	   Ex: AXI4_interface AXI4_INF(...);
*/



parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;


// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output reg  [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output reg  [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)	axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output reg  [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------


reg [3:0]nxt_state;
reg [3:0]cur_state;
reg [4:0]counter_input;
reg [3:0]counter_net_id;

reg [5:0]loc_x_seq[0:29];
reg [5:0]loc_y_seq[0:29];
reg [3:0]net_id_seq[0:14];
reg [4:0]frame_id_seq;

reg weight_ready;

reg [6:0]address_weight_sram;
reg [6:0]address_map_sram;
reg [127:0]weight_sram_in;
reg [127:0]map_sram_in;
reg [127:0]weight_sram_out;
reg [127:0]map_sram_out;
reg weight_sram_web;
reg map_sram_web;


reg [1:0]map_comb[0:63][0:63];
reg [1:0]map_dff[0:63][0:63];



reg [1:0]prop_in;
reg [1:0]counter_4;


reg [5:0]cur_x;
reg [5:0]cur_y;
reg [5:0]nxt_x;
reg [5:0]nxt_y;


reg [3:0]weight_4_cost;
reg [3:0]weight_4_cost_seq;
reg [127:0]map_sram_in_seq;


reg [6:0]counter_127;


reg [6:0]address_map;
reg [6:0]address_weight;



wire [5:0]cur_x_plus;
wire [5:0]cur_x_minus;
wire [5:0]cur_y_plus;
wire [5:0]cur_y_minus;

wire [5:0] target_x;
wire [5:0] target_y;

reg in_valid_seq;

integer i, j;
parameter IDLE = 0;
parameter INPUT_SAVE = 1;
parameter WRITE_WEIGHT_SRAM = 2;
parameter WAIT_ARREADY = 3;
parameter WRITE_MAP_SRAM = 4;
parameter PROPAGATION = 5;
parameter RETRACE_READ = 6;
parameter RETRACE_WRITE = 7;
parameter MAP_CLEAR = 8;
parameter WAIT_AWREADY = 9;
parameter WRITE_DRAM = 10;
parameter WAIT_BVALID = 11;
parameter MAP_INIT = 12;


assign arid_m_inf = 0;
assign arburst_m_inf = 1;
assign arsize_m_inf = 4;
assign arlen_m_inf = 127;
assign arvalid_m_inf = ((cur_state == INPUT_SAVE && !in_valid_seq) || cur_state == WAIT_ARREADY) ? 1 : 0;


assign rready_m_inf = (cur_state == WRITE_WEIGHT_SRAM || cur_state == WRITE_MAP_SRAM) ? 1 : 0;





//*************************************************//
//******************sram calling*******************//
//*************************************************//


mem_128 WEIGHT_SRAM (.A0(address_weight[0]),.A1(address_weight[1]),.A2(address_weight[2]),.A3(address_weight[3]),.A4(address_weight[4]),.A5(address_weight[5]),.A6(address_weight[6]),

					.DO0(weight_sram_out[0]),.DO1(weight_sram_out[1]),.DO2(weight_sram_out[2]),.DO3(weight_sram_out[3]),.DO4(weight_sram_out[4]),.DO5(weight_sram_out[5]),.DO6(weight_sram_out[6]),
					.DO7(weight_sram_out[7]),.DO8(weight_sram_out[8]),.DO9(weight_sram_out[9]),.DO10(weight_sram_out[10]),.DO11(weight_sram_out[11]),.DO12(weight_sram_out[12]),.DO13(weight_sram_out[13]),.DO14(weight_sram_out[14]),.DO15(weight_sram_out[15]),
					.DO16(weight_sram_out[16]),.DO17(weight_sram_out[17]),.DO18(weight_sram_out[18]),.DO19(weight_sram_out[19]),.DO20(weight_sram_out[20]),.DO21(weight_sram_out[21]),.DO22(weight_sram_out[22]),.DO23(weight_sram_out[23]),
					.DO24(weight_sram_out[24]),.DO25(weight_sram_out[25]),.DO26(weight_sram_out[26]),.DO27(weight_sram_out[27]),.DO28(weight_sram_out[28]),.DO29(weight_sram_out[29]),.DO30(weight_sram_out[30]),.DO31(weight_sram_out[31]),
					.DO32(weight_sram_out[32]),.DO33(weight_sram_out[33]),.DO34(weight_sram_out[34]),.DO35(weight_sram_out[35]),.DO36(weight_sram_out[36]),.DO37(weight_sram_out[37]),.DO38(weight_sram_out[38]),.DO39(weight_sram_out[39]),
					.DO40(weight_sram_out[40]),.DO41(weight_sram_out[41]),.DO42(weight_sram_out[42]),.DO43(weight_sram_out[43]),.DO44(weight_sram_out[44]),.DO45(weight_sram_out[45]),.DO46(weight_sram_out[46]),.DO47(weight_sram_out[47]),
					.DO48(weight_sram_out[48]),.DO49(weight_sram_out[49]),.DO50(weight_sram_out[50]),.DO51(weight_sram_out[51]),.DO52(weight_sram_out[52]),.DO53(weight_sram_out[53]),.DO54(weight_sram_out[54]),.DO55(weight_sram_out[55]),
					.DO56(weight_sram_out[56]),.DO57(weight_sram_out[57]),.DO58(weight_sram_out[58]),.DO59(weight_sram_out[59]),.DO60(weight_sram_out[60]),.DO61(weight_sram_out[61]),.DO62(weight_sram_out[62]),.DO63(weight_sram_out[63]),
					.DO64(weight_sram_out[64]),.DO65(weight_sram_out[65]),.DO66(weight_sram_out[66]),.DO67(weight_sram_out[67]),.DO68(weight_sram_out[68]),.DO69(weight_sram_out[69]),.DO70(weight_sram_out[70]),.DO71(weight_sram_out[71]),
					.DO72(weight_sram_out[72]),.DO73(weight_sram_out[73]),.DO74(weight_sram_out[74]),.DO75(weight_sram_out[75]),.DO76(weight_sram_out[76]),.DO77(weight_sram_out[77]),.DO78(weight_sram_out[78]),.DO79(weight_sram_out[79]),
					.DO80(weight_sram_out[80]),.DO81(weight_sram_out[81]),.DO82(weight_sram_out[82]),.DO83(weight_sram_out[83]),.DO84(weight_sram_out[84]),.DO85(weight_sram_out[85]),.DO86(weight_sram_out[86]),.DO87(weight_sram_out[87]),
					.DO88(weight_sram_out[88]),.DO89(weight_sram_out[89]),.DO90(weight_sram_out[90]),.DO91(weight_sram_out[91]),.DO92(weight_sram_out[92]),.DO93(weight_sram_out[93]),.DO94(weight_sram_out[94]),.DO95(weight_sram_out[95]),
					.DO96(weight_sram_out[96]),.DO97(weight_sram_out[97]),.DO98(weight_sram_out[98]),.DO99(weight_sram_out[99]),.DO100(weight_sram_out[100]),.DO101(weight_sram_out[101]),.DO102(weight_sram_out[102]),.DO103(weight_sram_out[103]),
					.DO104(weight_sram_out[104]),.DO105(weight_sram_out[105]),.DO106(weight_sram_out[106]),.DO107(weight_sram_out[107]),.DO108(weight_sram_out[108]),.DO109(weight_sram_out[109]),.DO110(weight_sram_out[110]),
					.DO111(weight_sram_out[111]),.DO112(weight_sram_out[112]),.DO113(weight_sram_out[113]),.DO114(weight_sram_out[114]),.DO115(weight_sram_out[115]),.DO116(weight_sram_out[116]),.DO117(weight_sram_out[117]),
					.DO118(weight_sram_out[118]),.DO119(weight_sram_out[119]),.DO120(weight_sram_out[120]),.DO121(weight_sram_out[121]),.DO122(weight_sram_out[122]),.DO123(weight_sram_out[123]),.DO124(weight_sram_out[124]),
					.DO125(weight_sram_out[125]),.DO126(weight_sram_out[126]),.DO127(weight_sram_out[127]),
					
					.DI0(weight_sram_in[0]),.DI1(weight_sram_in[1]),.DI2(weight_sram_in[2]),.DI3(weight_sram_in[3]),.DI4(weight_sram_in[4]),
					.DI5(weight_sram_in[5]),.DI6(weight_sram_in[6]),.DI7(weight_sram_in[7]),.DI8(weight_sram_in[8]),.DI9(weight_sram_in[9]),.DI10(weight_sram_in[10]),.DI11(weight_sram_in[11]),.DI12(weight_sram_in[12]),.DI13(weight_sram_in[13]),.DI14(weight_sram_in[14]),
					.DI15(weight_sram_in[15]),.DI16(weight_sram_in[16]),.DI17(weight_sram_in[17]),.DI18(weight_sram_in[18]),.DI19(weight_sram_in[19]),.DI20(weight_sram_in[20]),.DI21(weight_sram_in[21]),.DI22(weight_sram_in[22]),
					.DI23(weight_sram_in[23]),.DI24(weight_sram_in[24]),.DI25(weight_sram_in[25]),.DI26(weight_sram_in[26]),.DI27(weight_sram_in[27]),.DI28(weight_sram_in[28]),.DI29(weight_sram_in[29]),.DI30(weight_sram_in[30]),
					.DI31(weight_sram_in[31]),.DI32(weight_sram_in[32]),.DI33(weight_sram_in[33]),.DI34(weight_sram_in[34]),.DI35(weight_sram_in[35]),.DI36(weight_sram_in[36]),.DI37(weight_sram_in[37]),.DI38(weight_sram_in[38]),
					.DI39(weight_sram_in[39]),.DI40(weight_sram_in[40]),.DI41(weight_sram_in[41]),.DI42(weight_sram_in[42]),.DI43(weight_sram_in[43]),.DI44(weight_sram_in[44]),.DI45(weight_sram_in[45]),.DI46(weight_sram_in[46]),
					.DI47(weight_sram_in[47]),.DI48(weight_sram_in[48]),.DI49(weight_sram_in[49]),.DI50(weight_sram_in[50]),.DI51(weight_sram_in[51]),.DI52(weight_sram_in[52]),.DI53(weight_sram_in[53]),.DI54(weight_sram_in[54]),
					.DI55(weight_sram_in[55]),.DI56(weight_sram_in[56]),.DI57(weight_sram_in[57]),.DI58(weight_sram_in[58]),.DI59(weight_sram_in[59]),.DI60(weight_sram_in[60]),.DI61(weight_sram_in[61]),.DI62(weight_sram_in[62]),
					.DI63(weight_sram_in[63]),.DI64(weight_sram_in[64]),.DI65(weight_sram_in[65]),.DI66(weight_sram_in[66]),.DI67(weight_sram_in[67]),.DI68(weight_sram_in[68]),.DI69(weight_sram_in[69]),.DI70(weight_sram_in[70]),
					.DI71(weight_sram_in[71]),.DI72(weight_sram_in[72]),.DI73(weight_sram_in[73]),.DI74(weight_sram_in[74]),.DI75(weight_sram_in[75]),.DI76(weight_sram_in[76]),.DI77(weight_sram_in[77]),.DI78(weight_sram_in[78]),
					.DI79(weight_sram_in[79]),.DI80(weight_sram_in[80]),.DI81(weight_sram_in[81]),.DI82(weight_sram_in[82]),.DI83(weight_sram_in[83]),.DI84(weight_sram_in[84]),.DI85(weight_sram_in[85]),.DI86(weight_sram_in[86]),
					.DI87(weight_sram_in[87]),.DI88(weight_sram_in[88]),.DI89(weight_sram_in[89]),.DI90(weight_sram_in[90]),.DI91(weight_sram_in[91]),.DI92(weight_sram_in[92]),.DI93(weight_sram_in[93]),.DI94(weight_sram_in[94]),
					.DI95(weight_sram_in[95]),.DI96(weight_sram_in[96]),.DI97(weight_sram_in[97]),.DI98(weight_sram_in[98]),.DI99(weight_sram_in[99]),.DI100(weight_sram_in[100]),.DI101(weight_sram_in[101]),.DI102(weight_sram_in[102]),
					.DI103(weight_sram_in[103]),.DI104(weight_sram_in[104]),.DI105(weight_sram_in[105]),.DI106(weight_sram_in[106]),.DI107(weight_sram_in[107]),.DI108(weight_sram_in[108]),.DI109(weight_sram_in[109]),
					.DI110(weight_sram_in[110]),.DI111(weight_sram_in[111]),.DI112(weight_sram_in[112]),.DI113(weight_sram_in[113]),.DI114(weight_sram_in[114]),.DI115(weight_sram_in[115]),.DI116(weight_sram_in[116]),
					.DI117(weight_sram_in[117]),.DI118(weight_sram_in[118]),.DI119(weight_sram_in[119]),.DI120(weight_sram_in[120]),.DI121(weight_sram_in[121]),.DI122(weight_sram_in[122]),.DI123(weight_sram_in[123]),
					.DI124(weight_sram_in[124]),.DI125(weight_sram_in[125]),.DI126(weight_sram_in[126]),.DI127(weight_sram_in[127]),
					
					.CK(clk),.WEB(weight_sram_web),.OE(1'b1), .CS(1'b1));

mem_128 MAP_SRAM (.A0(address_map[0]),.A1(address_map[1]),.A2(address_map[2]),.A3(address_map[3]),.A4(address_map[4]),.A5(address_map[5]),.A6(address_map[6]),

					.DO0(map_sram_out[0]),.DO1(map_sram_out[1]),.DO2(map_sram_out[2]),.DO3(map_sram_out[3]),.DO4(map_sram_out[4]),.DO5(map_sram_out[5]),.DO6(map_sram_out[6]),
					.DO7(map_sram_out[7]),.DO8(map_sram_out[8]),.DO9(map_sram_out[9]),.DO10(map_sram_out[10]),.DO11(map_sram_out[11]),.DO12(map_sram_out[12]),.DO13(map_sram_out[13]),.DO14(map_sram_out[14]),.DO15(map_sram_out[15]),
					.DO16(map_sram_out[16]),.DO17(map_sram_out[17]),.DO18(map_sram_out[18]),.DO19(map_sram_out[19]),.DO20(map_sram_out[20]),.DO21(map_sram_out[21]),.DO22(map_sram_out[22]),.DO23(map_sram_out[23]),
					.DO24(map_sram_out[24]),.DO25(map_sram_out[25]),.DO26(map_sram_out[26]),.DO27(map_sram_out[27]),.DO28(map_sram_out[28]),.DO29(map_sram_out[29]),.DO30(map_sram_out[30]),.DO31(map_sram_out[31]),
					.DO32(map_sram_out[32]),.DO33(map_sram_out[33]),.DO34(map_sram_out[34]),.DO35(map_sram_out[35]),.DO36(map_sram_out[36]),.DO37(map_sram_out[37]),.DO38(map_sram_out[38]),.DO39(map_sram_out[39]),
					.DO40(map_sram_out[40]),.DO41(map_sram_out[41]),.DO42(map_sram_out[42]),.DO43(map_sram_out[43]),.DO44(map_sram_out[44]),.DO45(map_sram_out[45]),.DO46(map_sram_out[46]),.DO47(map_sram_out[47]),
					.DO48(map_sram_out[48]),.DO49(map_sram_out[49]),.DO50(map_sram_out[50]),.DO51(map_sram_out[51]),.DO52(map_sram_out[52]),.DO53(map_sram_out[53]),.DO54(map_sram_out[54]),.DO55(map_sram_out[55]),
					.DO56(map_sram_out[56]),.DO57(map_sram_out[57]),.DO58(map_sram_out[58]),.DO59(map_sram_out[59]),.DO60(map_sram_out[60]),.DO61(map_sram_out[61]),.DO62(map_sram_out[62]),.DO63(map_sram_out[63]),
					.DO64(map_sram_out[64]),.DO65(map_sram_out[65]),.DO66(map_sram_out[66]),.DO67(map_sram_out[67]),.DO68(map_sram_out[68]),.DO69(map_sram_out[69]),.DO70(map_sram_out[70]),.DO71(map_sram_out[71]),
					.DO72(map_sram_out[72]),.DO73(map_sram_out[73]),.DO74(map_sram_out[74]),.DO75(map_sram_out[75]),.DO76(map_sram_out[76]),.DO77(map_sram_out[77]),.DO78(map_sram_out[78]),.DO79(map_sram_out[79]),
					.DO80(map_sram_out[80]),.DO81(map_sram_out[81]),.DO82(map_sram_out[82]),.DO83(map_sram_out[83]),.DO84(map_sram_out[84]),.DO85(map_sram_out[85]),.DO86(map_sram_out[86]),.DO87(map_sram_out[87]),
					.DO88(map_sram_out[88]),.DO89(map_sram_out[89]),.DO90(map_sram_out[90]),.DO91(map_sram_out[91]),.DO92(map_sram_out[92]),.DO93(map_sram_out[93]),.DO94(map_sram_out[94]),.DO95(map_sram_out[95]),
					.DO96(map_sram_out[96]),.DO97(map_sram_out[97]),.DO98(map_sram_out[98]),.DO99(map_sram_out[99]),.DO100(map_sram_out[100]),.DO101(map_sram_out[101]),.DO102(map_sram_out[102]),.DO103(map_sram_out[103]),
					.DO104(map_sram_out[104]),.DO105(map_sram_out[105]),.DO106(map_sram_out[106]),.DO107(map_sram_out[107]),.DO108(map_sram_out[108]),.DO109(map_sram_out[109]),.DO110(map_sram_out[110]),
					.DO111(map_sram_out[111]),.DO112(map_sram_out[112]),.DO113(map_sram_out[113]),.DO114(map_sram_out[114]),.DO115(map_sram_out[115]),.DO116(map_sram_out[116]),.DO117(map_sram_out[117]),
					.DO118(map_sram_out[118]),.DO119(map_sram_out[119]),.DO120(map_sram_out[120]),.DO121(map_sram_out[121]),.DO122(map_sram_out[122]),.DO123(map_sram_out[123]),.DO124(map_sram_out[124]),
					.DO125(map_sram_out[125]),.DO126(map_sram_out[126]),.DO127(map_sram_out[127]),
					
					.DI0(map_sram_in[0]),.DI1(map_sram_in[1]),.DI2(map_sram_in[2]),.DI3(map_sram_in[3]),.DI4(map_sram_in[4]),
					.DI5(map_sram_in[5]),.DI6(map_sram_in[6]),.DI7(map_sram_in[7]),.DI8(map_sram_in[8]),.DI9(map_sram_in[9]),.DI10(map_sram_in[10]),.DI11(map_sram_in[11]),.DI12(map_sram_in[12]),.DI13(map_sram_in[13]),.DI14(map_sram_in[14]),
					.DI15(map_sram_in[15]),.DI16(map_sram_in[16]),.DI17(map_sram_in[17]),.DI18(map_sram_in[18]),.DI19(map_sram_in[19]),.DI20(map_sram_in[20]),.DI21(map_sram_in[21]),.DI22(map_sram_in[22]),
					.DI23(map_sram_in[23]),.DI24(map_sram_in[24]),.DI25(map_sram_in[25]),.DI26(map_sram_in[26]),.DI27(map_sram_in[27]),.DI28(map_sram_in[28]),.DI29(map_sram_in[29]),.DI30(map_sram_in[30]),
					.DI31(map_sram_in[31]),.DI32(map_sram_in[32]),.DI33(map_sram_in[33]),.DI34(map_sram_in[34]),.DI35(map_sram_in[35]),.DI36(map_sram_in[36]),.DI37(map_sram_in[37]),.DI38(map_sram_in[38]),
					.DI39(map_sram_in[39]),.DI40(map_sram_in[40]),.DI41(map_sram_in[41]),.DI42(map_sram_in[42]),.DI43(map_sram_in[43]),.DI44(map_sram_in[44]),.DI45(map_sram_in[45]),.DI46(map_sram_in[46]),
					.DI47(map_sram_in[47]),.DI48(map_sram_in[48]),.DI49(map_sram_in[49]),.DI50(map_sram_in[50]),.DI51(map_sram_in[51]),.DI52(map_sram_in[52]),.DI53(map_sram_in[53]),.DI54(map_sram_in[54]),
					.DI55(map_sram_in[55]),.DI56(map_sram_in[56]),.DI57(map_sram_in[57]),.DI58(map_sram_in[58]),.DI59(map_sram_in[59]),.DI60(map_sram_in[60]),.DI61(map_sram_in[61]),.DI62(map_sram_in[62]),
					.DI63(map_sram_in[63]),.DI64(map_sram_in[64]),.DI65(map_sram_in[65]),.DI66(map_sram_in[66]),.DI67(map_sram_in[67]),.DI68(map_sram_in[68]),.DI69(map_sram_in[69]),.DI70(map_sram_in[70]),
					.DI71(map_sram_in[71]),.DI72(map_sram_in[72]),.DI73(map_sram_in[73]),.DI74(map_sram_in[74]),.DI75(map_sram_in[75]),.DI76(map_sram_in[76]),.DI77(map_sram_in[77]),.DI78(map_sram_in[78]),
					.DI79(map_sram_in[79]),.DI80(map_sram_in[80]),.DI81(map_sram_in[81]),.DI82(map_sram_in[82]),.DI83(map_sram_in[83]),.DI84(map_sram_in[84]),.DI85(map_sram_in[85]),.DI86(map_sram_in[86]),
					.DI87(map_sram_in[87]),.DI88(map_sram_in[88]),.DI89(map_sram_in[89]),.DI90(map_sram_in[90]),.DI91(map_sram_in[91]),.DI92(map_sram_in[92]),.DI93(map_sram_in[93]),.DI94(map_sram_in[94]),
					.DI95(map_sram_in[95]),.DI96(map_sram_in[96]),.DI97(map_sram_in[97]),.DI98(map_sram_in[98]),.DI99(map_sram_in[99]),.DI100(map_sram_in[100]),.DI101(map_sram_in[101]),.DI102(map_sram_in[102]),
					.DI103(map_sram_in[103]),.DI104(map_sram_in[104]),.DI105(map_sram_in[105]),.DI106(map_sram_in[106]),.DI107(map_sram_in[107]),.DI108(map_sram_in[108]),.DI109(map_sram_in[109]),
					.DI110(map_sram_in[110]),.DI111(map_sram_in[111]),.DI112(map_sram_in[112]),.DI113(map_sram_in[113]),.DI114(map_sram_in[114]),.DI115(map_sram_in[115]),.DI116(map_sram_in[116]),
					.DI117(map_sram_in[117]),.DI118(map_sram_in[118]),.DI119(map_sram_in[119]),.DI120(map_sram_in[120]),.DI121(map_sram_in[121]),.DI122(map_sram_in[122]),.DI123(map_sram_in[123]),
					.DI124(map_sram_in[124]),.DI125(map_sram_in[125]),.DI126(map_sram_in[126]),.DI127(map_sram_in[127]),
					
					.CK(clk),.WEB(map_sram_web),.OE(1'b1), .CS(1'b1));


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_valid_seq <= 0;
	end
	else begin
		in_valid_seq <= in_valid;
	end

end


//*************************************************//
//******************state control******************//
//*************************************************//

always @(*) begin
	case(cur_state)
		IDLE : begin
			if(in_valid) begin
				nxt_state = INPUT_SAVE;
			end
			else begin
				nxt_state = IDLE;
			end
		end

		INPUT_SAVE : begin
			if(arready_m_inf) begin
				nxt_state = WRITE_WEIGHT_SRAM;
			end
			else begin
				nxt_state = INPUT_SAVE;
			end
		end

		WRITE_WEIGHT_SRAM : begin
			if(rlast_m_inf) begin
				nxt_state = WAIT_ARREADY;
			end
			else begin
				nxt_state = WRITE_WEIGHT_SRAM;
			end
		end

		WAIT_ARREADY : begin
			if(arready_m_inf) begin
				nxt_state = WRITE_MAP_SRAM;
			end
			else begin
				nxt_state = WAIT_ARREADY;
			end
		end

		WRITE_MAP_SRAM : begin
			if(rlast_m_inf) begin
				nxt_state = MAP_INIT;
			end
			else begin
				nxt_state = WRITE_MAP_SRAM;
			end
		end

		PROPAGATION : begin
			if(map_dff[loc_y_seq[1]][loc_x_seq[1]][1] == 1) begin // sink value != 0
				nxt_state = RETRACE_READ;
				// show_map;
			end
			else begin
				nxt_state = PROPAGATION;
				// show_map;
			end
		end

		RETRACE_READ : begin
			nxt_state = RETRACE_WRITE;
		end

		RETRACE_WRITE : begin
			if(net_id_seq[1] == 0 && cur_x == loc_x_seq[0] && cur_y == loc_y_seq[0]) begin
				nxt_state = WAIT_AWREADY;
				// show_map;
			end
			else if(cur_x == loc_x_seq[0] && cur_y == loc_y_seq[0]) begin
				nxt_state = MAP_CLEAR;
				//$display("loc x = %d loc y = %d", loc_x_seq[0], loc_y_seq[0]);
				// show_map;
			end
			else begin
				nxt_state = RETRACE_READ;
				// show_map;
			end
		end

		WAIT_AWREADY : begin
			if(awready_m_inf) begin
				nxt_state = WRITE_DRAM;
			end
			else begin
				nxt_state = WAIT_AWREADY;
			end
		end

		WRITE_DRAM : begin
			if(address_map_sram == 127) begin
				nxt_state = WAIT_BVALID;
			end
			else begin
				nxt_state = WRITE_DRAM;
			end
		end

		WAIT_BVALID : begin
			if(bvalid_m_inf) begin
				nxt_state = IDLE;
			end
			else begin
				nxt_state = WAIT_BVALID;
			end
		end

		MAP_CLEAR : begin
			nxt_state = MAP_INIT;
		end
		MAP_INIT : begin
			nxt_state = PROPAGATION;
		end

		default : nxt_state = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cur_state <= IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end

assign target_x = loc_x_seq[1];
assign target_y = loc_y_seq[1];


//*************************************************//
//*******************input save********************//
//*************************************************//

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i = 0; i < 30; i = i + 1) begin
			loc_x_seq[i] <= 0;
			loc_y_seq[i] <= 0;
		end
		for(i = 0; i < 15; i = i + 1) begin
			net_id_seq[i] <= 0;
		end

		frame_id_seq <= 0;
	end
	else begin
		for(i = 0; i < 30; i = i + 1) begin
			loc_x_seq[i] <= loc_x_seq[i];
			loc_y_seq[i] <= loc_y_seq[i];
		end
		for(i = 0; i < 15; i = i + 1) begin
			net_id_seq[i] <= net_id_seq[i];
		end
		frame_id_seq <= frame_id_seq;

		if(nxt_state == INPUT_SAVE && in_valid) begin
			loc_x_seq[counter_input] <= loc_x;
			loc_y_seq[counter_input] <= loc_y;
			net_id_seq[counter_net_id] <= net_id;
			frame_id_seq <= frame_id;
		end
		else if(nxt_state == IDLE) begin
			for(i = 0; i < 30; i = i + 1) begin
				loc_x_seq[i] <= 0;
				loc_y_seq[i] <= 0;
			end
			for(i = 0; i < 15; i = i + 1) begin
				net_id_seq[i] <= 0;
			end
		end
		else if(nxt_state == MAP_CLEAR) begin
			for(i = 0; i < 28; i = i + 1) begin
				loc_x_seq[i] <= loc_x_seq[i+2];
				loc_y_seq[i] <= loc_y_seq[i+2];
			end
			loc_x_seq[28] <= 0;
			loc_y_seq[28] <= 0;
			loc_x_seq[29] <= 0;
			loc_y_seq[29] <= 0;

			for(i = 0; i < 14; i = i + 1) begin
				net_id_seq[i] <= net_id_seq[i+1];
			end

			net_id_seq[14] <= 0;
		end

	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		counter_input <= 0;
		counter_net_id <= 0;
	end
	else begin
		if(nxt_state == INPUT_SAVE && in_valid) begin
			counter_input <= counter_input + 1;
			counter_net_id <= (counter_input[0] == 1) ? counter_net_id + 1 : counter_net_id;
		end
		else if(nxt_state == IDLE) begin
			counter_input <= 0;
			counter_net_id <= 0;
		end
		else begin
			counter_input <= 0;
			counter_net_id <= counter_net_id;
		end
	end
end


always @(*) begin
	if(cur_state == WRITE_WEIGHT_SRAM || cur_state == INPUT_SAVE) begin
		araddr_m_inf = 32'h0002_0000 + frame_id_seq * 2048;
	end
	else begin
		araddr_m_inf = 32'h0001_0000 + frame_id_seq * 2048;
	end
end



//*************************************************//
//*****************write weight sram***************//
//*************************************************//

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		address_weight_sram <= 0;
	end
	else begin
		if(rvalid_m_inf && cur_state == WRITE_WEIGHT_SRAM) begin
			address_weight_sram <= address_weight_sram + 1;
		end
		else begin
			address_weight_sram <= 0;
		end
	end
end


always @(*) begin
	if(cur_state == RETRACE_READ || cur_state == RETRACE_WRITE) begin
		address_weight = {cur_y, cur_x[5]};
	end
	else begin
		address_weight = address_weight_sram;
	end
end




always @(*) begin
	if(cur_state == WRITE_WEIGHT_SRAM) begin
		weight_sram_in = rdata_m_inf;
		if(rvalid_m_inf == 1) begin
			weight_sram_web = 0;
		end
		else begin
			weight_sram_web = 1;
		end
	end
	else begin
		weight_sram_in = 0;
		weight_sram_web = 1;
	end

end



//*************************************************//
//*******************write map sram****************//
//*************************************************//
assign cur_x_plus = cur_x + 1;
assign cur_x_minus = cur_x - 1;
assign cur_y_plus = cur_y + 1;
assign cur_y_minus = cur_y - 1;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		address_map_sram <= 0;
	end
	else begin
		if(rvalid_m_inf && cur_state == WRITE_MAP_SRAM) begin
			address_map_sram <= address_map_sram + 1;
		end
		else if(cur_state == WRITE_DRAM) begin
			address_map_sram <= counter_127;
		end
		else begin
			address_map_sram <= 0;
		end
	end
end


always @(*) begin
	if(cur_state == RETRACE_READ || cur_state == RETRACE_WRITE) begin
		address_map = {cur_y, cur_x[5]};
	end
	else if(cur_state == WRITE_DRAM) begin
		address_map = counter_127;
	end
	else begin
		address_map = address_map_sram;
	end
end



always @(*) begin
	if(cur_state == WRITE_MAP_SRAM) begin
		map_sram_in = rdata_m_inf;
		if(rvalid_m_inf == 1) begin
			map_sram_web = 0;
		end
		else begin
			map_sram_web = 1;
		end
	end
	else if(cur_state == RETRACE_WRITE) begin
		map_sram_in = map_sram_out;
		map_sram_web = 0;

		case(cur_x[4:0])
			0  : map_sram_in[3:0]     = net_id_seq[0];
			1  : map_sram_in[7:4]     = net_id_seq[0];
			2  : map_sram_in[11:8]    = net_id_seq[0];
			3  : map_sram_in[15:12]   = net_id_seq[0];
			4  : map_sram_in[19:16]   = net_id_seq[0];
			5  : map_sram_in[23:20]   = net_id_seq[0];
			6  : map_sram_in[27:24]   = net_id_seq[0];
			7  : map_sram_in[31:28]   = net_id_seq[0];
			8  : map_sram_in[35:32]   = net_id_seq[0];
			9  : map_sram_in[39:36]   = net_id_seq[0];
			10 : map_sram_in[43:40]   = net_id_seq[0];
			11 : map_sram_in[47:44]   = net_id_seq[0];
			12 : map_sram_in[51:48]   = net_id_seq[0];
			13 : map_sram_in[55:52]   = net_id_seq[0];
			14 : map_sram_in[59:56]   = net_id_seq[0];
			15 : map_sram_in[63:60]   = net_id_seq[0];
			16 : map_sram_in[67:64]   = net_id_seq[0];
			17 : map_sram_in[71:68]   = net_id_seq[0];
			18 : map_sram_in[75:72]   = net_id_seq[0];
			19 : map_sram_in[79:76]   = net_id_seq[0];
			20 : map_sram_in[83:80]   = net_id_seq[0];
			21 : map_sram_in[87:84]   = net_id_seq[0];
			22 : map_sram_in[91:88]   = net_id_seq[0];
			23 : map_sram_in[95:92]   = net_id_seq[0];
			24 : map_sram_in[99:96]   = net_id_seq[0];
			25 : map_sram_in[103:100] = net_id_seq[0];
			26 : map_sram_in[107:104] = net_id_seq[0];
			27 : map_sram_in[111:108] = net_id_seq[0];
			28 : map_sram_in[115:112] = net_id_seq[0];
			29 : map_sram_in[119:116] = net_id_seq[0];
			30 : map_sram_in[123:120] = net_id_seq[0];
			31 : map_sram_in[127:124] = net_id_seq[0];
		endcase
	end
	else if(cur_state == RETRACE_READ) begin
		map_sram_in = map_sram_out;
		map_sram_web = 1;
	end
	else begin
		map_sram_in = 0;
		map_sram_web = 1;
	end
end


// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		map_sram_in_seq <= 0;
// 	end
// 	else begin
// 		map_sram_in_seq <= map_sram_in;
// 	end
// end



always @(*) begin
	if(cur_state == WRITE_MAP_SRAM) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = map_dff[i][j];
			end
		end
		if(address_map_sram[0] == 0) begin
			// map_comb[address_map_sram[6:1]][0]  = (rdata_m_inf[3  :0  ] > 0) ? 1 : 0;
			// map_comb[address_map_sram[6:1]][1]  = (rdata_m_inf[7  :4  ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][2]  = (rdata_m_inf[11 :8  ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][3]  = (rdata_m_inf[15 :12 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][4]  = (rdata_m_inf[19 :16 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][5]  = (rdata_m_inf[23 :20 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][6]  = (rdata_m_inf[27 :24 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][7]  = (rdata_m_inf[31 :28 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][8]  = (rdata_m_inf[35 :32 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][9]  = (rdata_m_inf[39 :36 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][10] = (rdata_m_inf[43 :40 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][11] = (rdata_m_inf[47 :44 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][12] = (rdata_m_inf[51 :48 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][13] = (rdata_m_inf[55 :52 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][14] = (rdata_m_inf[59 :56 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][15] = (rdata_m_inf[63 :60 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][16] = (rdata_m_inf[67 :64 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][17] = (rdata_m_inf[71 :68 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][18] = (rdata_m_inf[75 :72 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][19] = (rdata_m_inf[79 :76 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][20] = (rdata_m_inf[83 :80 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][21] = (rdata_m_inf[87 :84 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][22] = (rdata_m_inf[91 :88 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][23] = (rdata_m_inf[95 :92 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][24] = (rdata_m_inf[99 :96 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][25] = (rdata_m_inf[103:100] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][26] = (rdata_m_inf[107:104] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][27] = (rdata_m_inf[111:108] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][28] = (rdata_m_inf[115:112] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][29] = (rdata_m_inf[119:116] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][30] = (rdata_m_inf[123:120] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][31] = (rdata_m_inf[127:124] > 0) ? 1 : 0;
			
			// map_comb[loc_y_seq[0]][loc_x_seq[0]] = 3; //source
			// map_comb[loc_y_seq[1]][loc_x_seq[1]] = 0; //sink
		end
		else begin
			map_comb[address_map_sram[6:1]][32]  = (rdata_m_inf[3  :0  ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][33]  = (rdata_m_inf[7  :4  ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][34]  = (rdata_m_inf[11 :8  ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][35]  = (rdata_m_inf[15 :12 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][36]  = (rdata_m_inf[19 :16 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][37]  = (rdata_m_inf[23 :20 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][38]  = (rdata_m_inf[27 :24 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][39]  = (rdata_m_inf[31 :28 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][40]  = (rdata_m_inf[35 :32 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][41]  = (rdata_m_inf[39 :36 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][42]  = (rdata_m_inf[43 :40 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][43]  = (rdata_m_inf[47 :44 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][44]  = (rdata_m_inf[51 :48 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][45]  = (rdata_m_inf[55 :52 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][46]  = (rdata_m_inf[59 :56 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][47]  = (rdata_m_inf[63 :60 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][48]  = (rdata_m_inf[67 :64 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][49]  = (rdata_m_inf[71 :68 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][50]  = (rdata_m_inf[75 :72 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][51]  = (rdata_m_inf[79 :76 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][52]  = (rdata_m_inf[83 :80 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][53]  = (rdata_m_inf[87 :84 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][54]  = (rdata_m_inf[91 :88 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][55]  = (rdata_m_inf[95 :92 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][56]  = (rdata_m_inf[99 :96 ] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][57]  = (rdata_m_inf[103:100] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][58]  = (rdata_m_inf[107:104] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][59]  = (rdata_m_inf[111:108] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][60]  = (rdata_m_inf[115:112] > 0) ? 1 : 0;
			map_comb[address_map_sram[6:1]][61]  = (rdata_m_inf[119:116] > 0) ? 1 : 0;
			// map_comb[address_map_sram[6:1]][62]  = (rdata_m_inf[123:120] > 0) ? 1 : 0;
			// map_comb[address_map_sram[6:1]][63]  = (rdata_m_inf[127:124] > 0) ? 1 : 0;
			
			// map_comb[loc_y_seq[0]][loc_x_seq[0]] = 3; //source
			// map_comb[loc_y_seq[1]][loc_x_seq[1]] = 0; //sink
		end
	end

	else if(cur_state == PROPAGATION) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = map_dff[i][j];
			end
		end
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				if(i == 0 && j == 0) begin
					if(map_dff[0][0][1]) begin
						map_comb[0][1] = (map_dff[0][1] == 0) ? prop_in : map_dff[0][1];
						map_comb[1][0] = (map_dff[1][0] == 0) ? prop_in : map_dff[1][0];
					end
				end
				else if(i == 0 && j == 63) begin
					if(map_dff[0][63][1]) begin
						map_comb[0][62] = (map_dff[0][62] == 0) ? prop_in : map_dff[0][62];
						map_comb[1][63] = (map_dff[1][63] == 0) ? prop_in : map_dff[1][63];
					end
				end
				else if(i == 63 && j == 0) begin
					if(map_dff[63][0][1]) begin
						map_comb[62][0] = (map_dff[62][0] == 0) ? prop_in : map_dff[62][0];
						map_comb[63][1] = (map_dff[63][1] == 0) ? prop_in : map_dff[63][1];
					end
				end
				else if(i == 63 && j == 63) begin
					if(map_dff[63][63][1]) begin
						map_comb[62][63] = (map_dff[62][63] == 0) ? prop_in : map_dff[62][63];
						map_comb[63][62] = (map_dff[63][62] == 0) ? prop_in : map_dff[63][62];
					end
				end
				else if(i == 0) begin
					if(map_dff[0][j][1]) begin
						map_comb[i+1][j] = (map_dff[i+1][j] == 0) ? prop_in : map_dff[i+1][j];
						map_comb[i][j+1] = (map_dff[i][j+1] == 0) ? prop_in : map_dff[i][j+1];
						map_comb[i][j-1] = (map_dff[i][j-1] == 0) ? prop_in : map_dff[i][j-1];
					end
				end
				else if(i == 63) begin
					if(map_dff[63][j][1]) begin
						map_comb[i-1][j] = (map_dff[i-1][j] == 0) ? prop_in : map_dff[i-1][j];
						map_comb[i][j+1] = (map_dff[i][j+1] == 0) ? prop_in : map_dff[i][j+1];
						map_comb[i][j-1] = (map_dff[i][j-1] == 0) ? prop_in : map_dff[i][j-1];
					end
				end
				else if(j == 0) begin
					if(map_dff[i][0][1]) begin
						map_comb[i+1][j] = (map_dff[i+1][j] == 0) ? prop_in : map_dff[i+1][j];
						map_comb[i-1][j] = (map_dff[i-1][j] == 0) ? prop_in : map_dff[i-1][j];
						map_comb[i][j+1] = (map_dff[i][j+1] == 0) ? prop_in : map_dff[i][j+1];
					end
				end
				else if(j == 63) begin
					if(map_dff[i][63][1]) begin
						map_comb[i+1][j] = (map_dff[i+1][j] == 0) ? prop_in : map_dff[i+1][j];
						map_comb[i-1][j] = (map_dff[i-1][j] == 0) ? prop_in : map_dff[i-1][j];
						map_comb[i][j-1] = (map_dff[i][j-1] == 0) ? prop_in : map_dff[i][j-1];
					end
				end
				else begin
					if(map_dff[i][j][1]) begin
						map_comb[i+1][j] = (map_dff[i+1][j] == 0) ? prop_in : map_dff[i+1][j];
						map_comb[i-1][j] = (map_dff[i-1][j] == 0) ? prop_in : map_dff[i-1][j];
						map_comb[i][j+1] = (map_dff[i][j+1] == 0) ? prop_in : map_dff[i][j+1];
						map_comb[i][j-1] = (map_dff[i][j-1] == 0) ? prop_in : map_dff[i][j-1];
					end
				end
			end
		end
	end

	else if(cur_state == RETRACE_WRITE) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = map_dff[i][j];
			end
		end

		map_comb[cur_y][cur_x] = 1;
	end

	else if(cur_state == MAP_CLEAR) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = (map_dff[i][j][1]) ? 0 : map_dff[i][j];
			end
		end
	end

	else if(cur_state == MAP_INIT) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = map_dff[i][j];
			end
		end
		map_comb[loc_y_seq[0]][loc_x_seq[0]] = 3; //source
		map_comb[loc_y_seq[1]][loc_x_seq[1]] = 0; //sink
	end

	else if(cur_state == IDLE) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = 0;
			end
		end
	end

	else begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_comb[i][j] = map_dff[i][j];
			end
		end
	end

end



always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_dff[i][j] <= 0;
			end
		end
	end
	else begin
		for(i = 0; i < 64; i = i + 1) begin
			for(j = 0; j < 64; j = j + 1) begin
				map_dff[i][j] <= map_comb[i][j];
			end
		end
	end
end


//*************************************************//
//******************propagation********************//
//*************************************************//

always @(*) begin
	case(counter_4)
		2'd0 : prop_in = 2;
		2'd1 : prop_in = 2;
		2'd2 : prop_in = 3;
		2'd3 : prop_in = 3;
		default : prop_in = 0;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		counter_4 <= 0;
	end
	else begin
		if(cur_state == PROPAGATION) begin
			counter_4 <= (nxt_state == RETRACE_READ) ? counter_4 - 2 : counter_4 + 1;
		end
		else if(cur_state == RETRACE_WRITE) begin
			counter_4 <= counter_4 - 1;
		end
		else if(cur_state == RETRACE_READ) begin
			counter_4 <= counter_4;
		end
		else begin
			counter_4 <= 0;
		end
	end

end


//*************************************************//
//********************retrace**********************//
//*************************************************//

always @(*) begin
	nxt_x = cur_x;
	nxt_y = cur_y;
	if(map_dff[cur_y_plus][cur_x] == prop_in && cur_y != 63) begin // up
		nxt_y = cur_y_plus;
	end
	else if(map_dff[cur_y_minus][cur_x] == prop_in && cur_y != 0) begin // down
		nxt_y = cur_y_minus;
	end
	else if(map_dff[cur_y][cur_x_plus] == prop_in && cur_x != 63) begin // right
		nxt_x = cur_x_plus;
	end
	else begin // left
		nxt_x = cur_x_minus;
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cur_x <= 0;
		cur_y <= 0;
	end
	else begin
		if(cur_state == RETRACE_WRITE) begin
			cur_x <= nxt_x;
			cur_y <= nxt_y;
		end
		else if(cur_state == RETRACE_READ) begin
			cur_x <= cur_x;
			cur_y <= cur_y;
		end
		else begin
			cur_x <= loc_x_seq[1];
			cur_y <= loc_y_seq[1];
		end
	end
end

always @(*) begin
	if(cur_x != loc_x_seq[1] || cur_y != loc_y_seq[1]) begin
		case(cur_x[4:0])
			0  : weight_4_cost = weight_sram_out[3:0];
			1  : weight_4_cost = weight_sram_out[7:4];
			2  : weight_4_cost = weight_sram_out[11:8];
			3  : weight_4_cost = weight_sram_out[15:12];
			4  : weight_4_cost = weight_sram_out[19:16];
			5  : weight_4_cost = weight_sram_out[23:20];
			6  : weight_4_cost = weight_sram_out[27:24];
			7  : weight_4_cost = weight_sram_out[31:28];
			8  : weight_4_cost = weight_sram_out[35:32];
			9  : weight_4_cost = weight_sram_out[39:36];
			10 : weight_4_cost = weight_sram_out[43:40];
			11 : weight_4_cost = weight_sram_out[47:44];
			12 : weight_4_cost = weight_sram_out[51:48];
			13 : weight_4_cost = weight_sram_out[55:52];
			14 : weight_4_cost = weight_sram_out[59:56];
			15 : weight_4_cost = weight_sram_out[63:60];
			16 : weight_4_cost = weight_sram_out[67:64];
			17 : weight_4_cost = weight_sram_out[71:68];
			18 : weight_4_cost = weight_sram_out[75:72];
			19 : weight_4_cost = weight_sram_out[79:76];
			20 : weight_4_cost = weight_sram_out[83:80];
			21 : weight_4_cost = weight_sram_out[87:84];
			22 : weight_4_cost = weight_sram_out[91:88];
			23 : weight_4_cost = weight_sram_out[95:92];
			24 : weight_4_cost = weight_sram_out[99:96];
			25 : weight_4_cost = weight_sram_out[103:100];
			26 : weight_4_cost = weight_sram_out[107:104];
			27 : weight_4_cost = weight_sram_out[111:108];
			28 : weight_4_cost = weight_sram_out[115:112];
			29 : weight_4_cost = weight_sram_out[119:116];
			30 : weight_4_cost = weight_sram_out[123:120];
			31 : weight_4_cost = weight_sram_out[127:124];
			default : weight_4_cost = 0;
		endcase
	end
	else begin
		weight_4_cost = 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		weight_4_cost_seq <= 0;
	end
	else begin
		if(cur_state == RETRACE_READ || cur_state == RETRACE_WRITE) begin
			weight_4_cost_seq <= weight_4_cost;
		end
		else if(cur_state == IDLE || cur_state == MAP_CLEAR) begin
			weight_4_cost_seq <= 0;
		end
		else begin
			weight_4_cost_seq <= weight_4_cost_seq;
		end
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cost <= 0;
	end
	else begin
		if(cur_state == RETRACE_READ) begin
			cost <= cost + weight_4_cost_seq;
		end
		else if(cur_state == IDLE) begin
			cost <= 0;
		end
		else begin
			cost <= cost;
		end
	end
end


//*************************************************//
//******************WAIT_AWREADY*******************//
//*************************************************//

assign awid_m_inf = 0;
assign awburst_m_inf = 1;
assign awsize_m_inf = 4;
assign awlen_m_inf = 127;
assign awvalid_m_inf = (cur_state == WAIT_AWREADY) ? 1 : 0;

always @(*) begin
	if(cur_state == WAIT_AWREADY) begin
		awaddr_m_inf = 32'h0001_0000 + frame_id_seq * 2048;
	end
	else begin
		awaddr_m_inf = 0;
	end
end


//*************************************************//
//*******************WRITE_DRAM********************//
//*************************************************//

assign wvalid_m_inf = (cur_state == WRITE_DRAM) ? 1 : 0;
assign wlast_m_inf = (address_map_sram == 127 && cur_state == WRITE_DRAM) ? 1 : 0;

always @(*) begin
	wdata_m_inf = map_sram_out;
end


always @(*) begin
	if(wready_m_inf) begin
		counter_127 = address_map_sram + 1;
	end
	else begin
		counter_127 = 0;
	end
end

//*************************************************//
//*******************WAIT_BVALID*******************//
//*************************************************//

assign bready_m_inf = (cur_state == WAIT_BVALID) ? 1 : 0;



//*************************************************//
//*********************output**********************//
//*************************************************//

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		busy <= 0;
	end
	else begin
		if(nxt_state == IDLE)
			busy <= 0;
		else if(nxt_state == INPUT_SAVE)
			busy <= (!in_valid) ? 1 : 0;
		else
			busy <= 1;
	end
end

//*********************************************************//
//                    debug logic                          //
//*********************************************************//
// task show_map;
// 	$display("    cur x = %d cur y = %d   ", cur_x, cur_y);
// 	for(i = 0; i < 64; i = i + 1)begin
// 		for(j = 0; j < 64; j = j + 1)begin
// 			if(map_dff[i][j] == 1)
// 				$write("\033[0;32;32m%d", map_dff[i][j]);
// 			else 
// 				$write("\033[m%d",map_dff[i][j]);
// 		end
// 		$write("\n");
// 	end

// endtask

endmodule
