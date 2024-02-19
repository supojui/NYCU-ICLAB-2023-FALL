//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab01 Exercise		: Supper MOSFET Calculator
//   Author     		: Lin-Hung Lai (lhlai@ieee.org)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SMC.v
//   Module Name : SMC
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
//output [7:0] out_n;         					// use this if using continuous assignment for out_n  // Ex: assign out_n = XXX;
output reg [7:0] out_n; 								// use this if using procedure assignment for out_n   // Ex: always@(*) begin out_n = XXX; end

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment
reg  [7:0]cal_out[0:5];
reg  [7:0]sort_temp[0:5];
reg  [6:0]sort_out[0:2];
reg  [3:0]temp[0:5];
reg  [5:0]W_times_temp[0:5];
reg  [2:0]V_temp[0:5];
reg  [9:0]out_before_divider;
wire [2:0]Vgs_minus1[0:5];
wire [2:0]coefficient_3;
wire [2:0]coefficient_5;
integer  i;
//================================================================
//    DESIGN
//================================================================

// --------------------------------------------------
// write your design here
// --------------------------------------------------
assign Vgs_minus1[0] = V_GS_0 - 1;
assign Vgs_minus1[1] = V_GS_1 - 1;
assign Vgs_minus1[2] = V_GS_2 - 1;
assign Vgs_minus1[3] = V_GS_3 - 1;
assign Vgs_minus1[4] = V_GS_4 - 1;
assign Vgs_minus1[5] = V_GS_5 - 1;


// assign W_times_temp[0] = W_0 * V_temp[0];
// assign W_times_temp[1] = W_1 * V_temp[1];
// assign W_times_temp[2] = W_2 * V_temp[2];
// assign W_times_temp[3] = W_3 * V_temp[3];
// assign W_times_temp[4] = W_4 * V_temp[4];
// assign W_times_temp[5] = W_5 * V_temp[5];

always@(*) begin
	if(Vgs_minus1[0] > V_DS_0) begin
		W_times_temp[0] = W_0 * V_DS_0;
		V_temp[0] = V_DS_0;
	end
	else begin
		W_times_temp[0] = W_0 * Vgs_minus1[0];
		V_temp[0] = Vgs_minus1[0];
	end

	if(Vgs_minus1[1] > V_DS_1) begin
		W_times_temp[1] = W_1 * V_DS_1;
		V_temp[1] = V_DS_1;
	end
	else begin
		W_times_temp[1] = W_1 * Vgs_minus1[1];
		V_temp[1] = Vgs_minus1[1];
	end

	if(Vgs_minus1[2] > V_DS_2) begin
		W_times_temp[2] = W_2 * V_DS_2;
		V_temp[2] = V_DS_2;
	end
	else begin
		W_times_temp[2] = W_2 * Vgs_minus1[2];
		V_temp[2] = Vgs_minus1[2];
	end

	if(Vgs_minus1[3] > V_DS_3) begin
		W_times_temp[3] = W_3 * V_DS_3;
		V_temp[3] = V_DS_3;
	end
	else begin
		W_times_temp[3] = W_3 * Vgs_minus1[3];
		V_temp[3] = Vgs_minus1[3];
	end

	if(Vgs_minus1[4] > V_DS_4) begin
		W_times_temp[4] = W_4 * V_DS_4;
		V_temp[4] = V_DS_4;
	end
	else begin
		W_times_temp[4] = W_4 * Vgs_minus1[4];
		V_temp[4] = Vgs_minus1[4];
	end

	if(Vgs_minus1[5] > V_DS_5) begin
		W_times_temp[5] = W_5 * V_DS_5;
		V_temp[5] = V_DS_5;
	end
	else begin
		W_times_temp[5] = W_5 * Vgs_minus1[5];
		V_temp[5] = Vgs_minus1[5];
	end
end

always@(*) begin
	if(mode[0]) begin
		temp[0] = (Vgs_minus1[0] << 1) - V_temp[0];
		temp[1] = (Vgs_minus1[1] << 1) - V_temp[1];
		temp[2] = (Vgs_minus1[2] << 1) - V_temp[2];
		temp[3] = (Vgs_minus1[3] << 1) - V_temp[3];
		temp[4] = (Vgs_minus1[4] << 1) - V_temp[4];
		temp[5] = (Vgs_minus1[5] << 1) - V_temp[5];
	end
	else begin
		temp[0] = 2;
		temp[1] = 2;
		temp[2] = 2;
		temp[3] = 2;
		temp[4] = 2;
		temp[5] = 2;
	end
end

always@(*) begin
	cal_out[0] = W_times_temp[0] * temp[0];
	cal_out[1] = W_times_temp[1] * temp[1];
	cal_out[2] = W_times_temp[2] * temp[2];
	cal_out[3] = W_times_temp[3] * temp[3];
	cal_out[4] = W_times_temp[4] * temp[4];
	cal_out[5] = W_times_temp[5] * temp[5];
end

/*Sort*/
always@(*) begin
	for(i = 0; i < 6; i = i + 1) begin
		sort_temp[i] = cal_out[i];
	end
	if(sort_temp[1] < sort_temp[5]) begin
		{sort_temp[5],  sort_temp[1]} = 
		{sort_temp[1],  sort_temp[5]};
	end
	else begin
		{sort_temp[5],  sort_temp[1]} = 
		{sort_temp[5],  sort_temp[1]};
	end
	if(sort_temp[0] < sort_temp[4]) begin
		{sort_temp[4],  sort_temp[0]} = 
		{sort_temp[0],  sort_temp[4]};
	end
	else begin
		{sort_temp[4],  sort_temp[0]} = 
		{sort_temp[4],  sort_temp[0]};
	end
	if(sort_temp[3] < sort_temp[5]) begin
		{sort_temp[5],  sort_temp[3]} = 
		{sort_temp[3],  sort_temp[5]};
	end
	else begin
		{sort_temp[5],  sort_temp[3]} = 
		{sort_temp[5],  sort_temp[3]};
	end
	if(sort_temp[2] < sort_temp[4]) begin
		{sort_temp[4],  sort_temp[2]} = 
		{sort_temp[2],  sort_temp[4]};
	end
	else begin
		{sort_temp[4],  sort_temp[2]} = 
		{sort_temp[4],  sort_temp[2]};
	end
	if(sort_temp[1] < sort_temp[3]) begin
		{sort_temp[3],  sort_temp[1]} = 
		{sort_temp[1],  sort_temp[3]};
	end
	else begin
		{sort_temp[3],  sort_temp[1]} = 
		{sort_temp[3],  sort_temp[1]};
	end
	if(sort_temp[0] < sort_temp[2]) begin
		{sort_temp[0],  sort_temp[2]} = 
		{sort_temp[2],  sort_temp[0]};
	end
	else begin
		{sort_temp[0],  sort_temp[2]} = 
		{sort_temp[0],  sort_temp[2]};
	end
	if(sort_temp[4] < sort_temp[5]) begin
		{sort_temp[4],  sort_temp[5]} = 
		{sort_temp[5],  sort_temp[4]};
	end
	else begin
		{sort_temp[4],  sort_temp[5]} = 
		{sort_temp[4],  sort_temp[5]};
	end
	if(sort_temp[2] < sort_temp[3]) begin
		{sort_temp[2],  sort_temp[3]} = 
		{sort_temp[3],  sort_temp[2]};
	end
	else begin
		{sort_temp[2],  sort_temp[3]} = 
		{sort_temp[2],  sort_temp[3]};
	end
	if(sort_temp[0] < sort_temp[1]) begin
		{sort_temp[0],  sort_temp[1]} = 
		{sort_temp[1],  sort_temp[0]};
	end
	else begin
		{sort_temp[0],  sort_temp[1]} = 
		{sort_temp[0],  sort_temp[1]};
	end
	if(sort_temp[1] < sort_temp[4]) begin
		{sort_temp[1],  sort_temp[4]} = 
		{sort_temp[4],  sort_temp[1]};
	end
	else begin
		{sort_temp[1],  sort_temp[4]} = 
		{sort_temp[1],  sort_temp[4]};
	end
	if(sort_temp[3] < sort_temp[4]) begin
		{sort_temp[3],  sort_temp[4]} = 
		{sort_temp[4],  sort_temp[3]};
	end
	else begin
		{sort_temp[3],  sort_temp[4]} = 
		{sort_temp[3],  sort_temp[4]};
	end
	if(sort_temp[1] < sort_temp[2]) begin
		{sort_temp[2],  sort_temp[1]} = 
		{sort_temp[1],  sort_temp[2]};
	end
	else begin
		{sort_temp[2],  sort_temp[1]} = 
		{sort_temp[2],  sort_temp[1]};
	end

	if(mode[1]) begin
		sort_temp[0] = sort_temp[0];
		sort_temp[1] = sort_temp[1];
		sort_temp[2] = sort_temp[2];
	end
	else begin
		sort_temp[0] = sort_temp[3];
		sort_temp[1] = sort_temp[4];
		sort_temp[2] = sort_temp[5];
	end
end

DIVIDER_3 D1 (.data_in1(sort_temp[0]), .out(sort_out[0]));
DIVIDER_3 D2 (.data_in1(sort_temp[1]), .out(sort_out[1]));
DIVIDER_3 D3 (.data_in1(sort_temp[2]), .out(sort_out[2]));

// always@(*) begin
// 	sort_out[0] = 4*sort_temp[0]/12;
// 	sort_out[1] = 4*sort_temp[1]/12;
// 	sort_out[2] = 4*sort_temp[2]/12;
// end

assign coefficient_3 = (mode[0]) ? 3 : 4;
assign coefficient_5 = (mode[0]) ? 5 : 4;



always@(*) begin
	out_before_divider = (coefficient_3*sort_out[0] + 4*sort_out[1] + coefficient_5*sort_out[2]);
end

assign out_n[7] = 1'b0;
DIVIDER_12 D4 (.data_in1(out_before_divider), .out(out_n[6:0]));

// always@(*) begin
// 	out_n = 8*out_before_divider/96;
// end
/*Output*/

endmodule


//================================================================
//   SUB MODULE
//================================================================

module DIVIDER_3(input [7:0]data_in1, output reg [6:0]out);
	always@(*) begin
		case(data_in1)
			8'd0 : out = 0;
			8'd1 : out = 0;
			8'd2 : out = 0;
			8'd3 : out = 1;
			8'd4 : out = 1;
			8'd5 : out = 1;
			8'd6 : out = 2;
			8'd7 : out = 2;
			8'd8 : out = 2;
			8'd9 : out = 3;
			8'd10 : out = 3;
			8'd11 : out = 3;
			8'd12 : out = 4;
			8'd13 : out = 4;
			8'd14 : out = 4;
			8'd15 : out = 5;
			8'd16 : out = 5;
			8'd17 : out = 5;
			8'd18 : out = 6;
			8'd19 : out = 6;
			8'd20 : out = 6;
			8'd21 : out = 7;
			8'd22 : out = 7;
			8'd23 : out = 7;
			8'd24 : out = 8;
			8'd25 : out = 8;
			8'd26 : out = 8;
			8'd27 : out = 9;
			8'd28 : out = 9;
			8'd29 : out = 9;
			8'd30 : out = 10;
			8'd31 : out = 10;
			8'd32 : out = 10;
			8'd33 : out = 11;
			8'd34 : out = 11;
			8'd35 : out = 11;
			8'd36 : out = 12;
			8'd37 : out = 12;
			8'd38 : out = 12;
			8'd39 : out = 13;
			8'd40 : out = 13;
			8'd41 : out = 13;
			8'd42 : out = 14;
			8'd43 : out = 14;
			8'd44 : out = 14;
			8'd45 : out = 15;
			8'd46 : out = 15;
			8'd47 : out = 15;
			8'd48 : out = 16;
			8'd49 : out = 16;
			8'd50 : out = 16;
			8'd51 : out = 17;
			8'd52 : out = 17;
			8'd53 : out = 17;
			8'd54 : out = 18;
			8'd55 : out = 18;
			8'd56 : out = 18;
			8'd57 : out = 19;
			8'd58 : out = 19;
			8'd59 : out = 19;
			8'd60 : out = 20;
			8'd61 : out = 20;
			8'd62 : out = 20;
			8'd63 : out = 21;
			8'd64 : out = 21;
			8'd65 : out = 21;
			8'd66 : out = 22;
			8'd67 : out = 22;
			8'd68 : out = 22;
			8'd69 : out = 23;
			8'd70 : out = 23;
			8'd71 : out = 23;
			8'd72 : out = 24;
			8'd73 : out = 24;
			8'd74 : out = 24;
			8'd75 : out = 25;
			8'd76 : out = 25;
			8'd77 : out = 25;
			8'd78 : out = 26;
			8'd79 : out = 26;
			8'd80 : out = 26;
			8'd81 : out = 27;
			8'd82 : out = 27;
			8'd83 : out = 27;
			8'd84 : out = 28;
			8'd85 : out = 28;
			8'd86 : out = 28;
			8'd87 : out = 29;
			8'd88 : out = 29;
			8'd89 : out = 29;
			8'd90 : out = 30;
			8'd91 : out = 30;
			8'd92 : out = 30;
			8'd93 : out = 31;
			8'd94 : out = 31;
			8'd95 : out = 31;
			8'd96 : out = 32;
			8'd97 : out = 32;
			8'd98 : out = 32;
			8'd99 : out = 33;
			8'd100 : out = 33;
			8'd101 : out = 33;
			8'd102 : out = 34;
			8'd103 : out = 34;
			8'd104 : out = 34;
			8'd105 : out = 35;
			8'd106 : out = 35;
			8'd107 : out = 35;
			8'd108 : out = 36;
			8'd109 : out = 36;
			8'd110 : out = 36;
			8'd111 : out = 37;
			8'd112 : out = 37;
			8'd113 : out = 37;
			8'd114 : out = 38;
			8'd115 : out = 38;
			8'd116 : out = 38;
			8'd117 : out = 39;
			8'd118 : out = 39;
			8'd119 : out = 39;
			8'd120 : out = 40;
			8'd121 : out = 40;
			8'd122 : out = 40;
			8'd123 : out = 41;
			8'd124 : out = 41;
			8'd125 : out = 41;
			8'd126 : out = 42;
			8'd127 : out = 42;
			8'd128 : out = 42;
			8'd129 : out = 43;
			8'd130 : out = 43;
			8'd131 : out = 43;
			8'd132 : out = 44;
			8'd133 : out = 44;
			8'd134 : out = 44;
			8'd135 : out = 45;
			8'd136 : out = 45;
			8'd137 : out = 45;
			8'd138 : out = 46;
			8'd139 : out = 46;
			8'd140 : out = 46;
			8'd141 : out = 47;
			8'd142 : out = 47;
			8'd143 : out = 47;
			8'd144 : out = 48;
			8'd145 : out = 48;
			8'd146 : out = 48;
			8'd147 : out = 49;
			8'd148 : out = 49;
			8'd149 : out = 49;
			8'd150 : out = 50;
			8'd151 : out = 50;
			8'd152 : out = 50;
			8'd153 : out = 51;
			8'd154 : out = 51;
			8'd155 : out = 51;
			8'd156 : out = 52;
			8'd157 : out = 52;
			8'd158 : out = 52;
			8'd159 : out = 53;
			8'd160 : out = 53;
			8'd161 : out = 53;
			8'd162 : out = 54;
			8'd163 : out = 54;
			8'd164 : out = 54;
			8'd165 : out = 55;
			8'd166 : out = 55;
			8'd167 : out = 55;
			8'd168 : out = 56;
			8'd169 : out = 56;
			8'd170 : out = 56;
			8'd171 : out = 57;
			8'd172 : out = 57;
			8'd173 : out = 57;
			8'd174 : out = 58;
			8'd175 : out = 58;
			8'd176 : out = 58;
			8'd177 : out = 59;
			8'd178 : out = 59;
			8'd179 : out = 59;
			8'd180 : out = 60;
			8'd181 : out = 60;
			8'd182 : out = 60;
			8'd183 : out = 61;
			8'd184 : out = 61;
			8'd185 : out = 61;
			8'd186 : out = 62;
			8'd187 : out = 62;
			8'd188 : out = 62;
			8'd189 : out = 63;
			8'd190 : out = 63;
			8'd191 : out = 63;
			8'd192 : out = 64;
			8'd193 : out = 64;
			8'd194 : out = 64;
			8'd195 : out = 65;
			8'd196 : out = 65;
			8'd197 : out = 65;
			8'd198 : out = 66;
			8'd199 : out = 66;
			8'd200 : out = 66;
			8'd201 : out = 67;
			8'd202 : out = 67;
			8'd203 : out = 67;
			8'd204 : out = 68;
			8'd205 : out = 68;
			8'd206 : out = 68;
			8'd207 : out = 69;
			8'd208 : out = 69;
			8'd209 : out = 69;
			8'd210 : out = 70;
			8'd211 : out = 70;
			8'd212 : out = 70;
			8'd213 : out = 71;
			8'd214 : out = 71;
			8'd215 : out = 71;
			8'd216 : out = 72;
			8'd217 : out = 72;
			8'd218 : out = 72;
			8'd219 : out = 73;
			8'd220 : out = 73;
			8'd221 : out = 73;
			8'd222 : out = 74;
			8'd223 : out = 74;
			8'd224 : out = 74;
			8'd225 : out = 75;
			8'd226 : out = 75;
			8'd227 : out = 75;
			8'd228 : out = 76;
			8'd229 : out = 76;
			8'd230 : out = 76;
			8'd231 : out = 77;
			8'd232 : out = 77;
			8'd233 : out = 77;
			8'd234 : out = 78;
			8'd235 : out = 78;
			8'd236 : out = 78;
			8'd237 : out = 79;
			8'd238 : out = 79;
			8'd239 : out = 79;
			8'd240 : out = 80;
			8'd241 : out = 80;
			8'd242 : out = 80;
			8'd243 : out = 81;
			8'd244 : out = 81;
			8'd245 : out = 81;
			8'd246 : out = 82;
			8'd247 : out = 82;
			8'd248 : out = 82;
			8'd249 : out = 83;
			8'd250 : out = 83;
			8'd251 : out = 83;
			8'd252 : out = 84;
			8'd253 : out = 84;
			8'd254 : out = 84;
			8'd255 : out = 85;
			default : out = 0;
		endcase
	end

endmodule

module DIVIDER_12(input [9:0]data_in1, output reg [6:0]out);
	always@(*) begin
		case(data_in1)
			10'd0 : out = 0;
			10'd1 : out = 0;
			10'd2 : out = 0;
			10'd3 : out = 0;
			10'd4 : out = 0;
			10'd5 : out = 0;
			10'd6 : out = 0;
			10'd7 : out = 0;
			10'd8 : out = 0;
			10'd9 : out = 0;
			10'd10 : out = 0;
			10'd11 : out = 0;
			10'd12 : out = 1;
			10'd13 : out = 1;
			10'd14 : out = 1;
			10'd15 : out = 1;
			10'd16 : out = 1;
			10'd17 : out = 1;
			10'd18 : out = 1;
			10'd19 : out = 1;
			10'd20 : out = 1;
			10'd21 : out = 1;
			10'd22 : out = 1;
			10'd23 : out = 1;
			10'd24 : out = 2;
			10'd25 : out = 2;
			10'd26 : out = 2;
			10'd27 : out = 2;
			10'd28 : out = 2;
			10'd29 : out = 2;
			10'd30 : out = 2;
			10'd31 : out = 2;
			10'd32 : out = 2;
			10'd33 : out = 2;
			10'd34 : out = 2;
			10'd35 : out = 2;
			10'd36 : out = 3;
			10'd37 : out = 3;
			10'd38 : out = 3;
			10'd39 : out = 3;
			10'd40 : out = 3;
			10'd41 : out = 3;
			10'd42 : out = 3;
			10'd43 : out = 3;
			10'd44 : out = 3;
			10'd45 : out = 3;
			10'd46 : out = 3;
			10'd47 : out = 3;
			10'd48 : out = 4;
			10'd49 : out = 4;
			10'd50 : out = 4;
			10'd51 : out = 4;
			10'd52 : out = 4;
			10'd53 : out = 4;
			10'd54 : out = 4;
			10'd55 : out = 4;
			10'd56 : out = 4;
			10'd57 : out = 4;
			10'd58 : out = 4;
			10'd59 : out = 4;
			10'd60 : out = 5;
			10'd61 : out = 5;
			10'd62 : out = 5;
			10'd63 : out = 5;
			10'd64 : out = 5;
			10'd65 : out = 5;
			10'd66 : out = 5;
			10'd67 : out = 5;
			10'd68 : out = 5;
			10'd69 : out = 5;
			10'd70 : out = 5;
			10'd71 : out = 5;
			10'd72 : out = 6;
			10'd73 : out = 6;
			10'd74 : out = 6;
			10'd75 : out = 6;
			10'd76 : out = 6;
			10'd77 : out = 6;
			10'd78 : out = 6;
			10'd79 : out = 6;
			10'd80 : out = 6;
			10'd81 : out = 6;
			10'd82 : out = 6;
			10'd83 : out = 6;
			10'd84 : out = 7;
			10'd85 : out = 7;
			10'd86 : out = 7;
			10'd87 : out = 7;
			10'd88 : out = 7;
			10'd89 : out = 7;
			10'd90 : out = 7;
			10'd91 : out = 7;
			10'd92 : out = 7;
			10'd93 : out = 7;
			10'd94 : out = 7;
			10'd95 : out = 7;
			10'd96 : out = 8;
			10'd97 : out = 8;
			10'd98 : out = 8;
			10'd99 : out = 8;
			10'd100 : out = 8;
			10'd101 : out = 8;
			10'd102 : out = 8;
			10'd103 : out = 8;
			10'd104 : out = 8;
			10'd105 : out = 8;
			10'd106 : out = 8;
			10'd107 : out = 8;
			10'd108 : out = 9;
			10'd109 : out = 9;
			10'd110 : out = 9;
			10'd111 : out = 9;
			10'd112 : out = 9;
			10'd113 : out = 9;
			10'd114 : out = 9;
			10'd115 : out = 9;
			10'd116 : out = 9;
			10'd117 : out = 9;
			10'd118 : out = 9;
			10'd119 : out = 9;
			10'd120 : out = 10;
			10'd121 : out = 10;
			10'd122 : out = 10;
			10'd123 : out = 10;
			10'd124 : out = 10;
			10'd125 : out = 10;
			10'd126 : out = 10;
			10'd127 : out = 10;
			10'd128 : out = 10;
			10'd129 : out = 10;
			10'd130 : out = 10;
			10'd131 : out = 10;
			10'd132 : out = 11;
			10'd133 : out = 11;
			10'd134 : out = 11;
			10'd135 : out = 11;
			10'd136 : out = 11;
			10'd137 : out = 11;
			10'd138 : out = 11;
			10'd139 : out = 11;
			10'd140 : out = 11;
			10'd141 : out = 11;
			10'd142 : out = 11;
			10'd143 : out = 11;
			10'd144 : out = 12;
			10'd145 : out = 12;
			10'd146 : out = 12;
			10'd147 : out = 12;
			10'd148 : out = 12;
			10'd149 : out = 12;
			10'd150 : out = 12;
			10'd151 : out = 12;
			10'd152 : out = 12;
			10'd153 : out = 12;
			10'd154 : out = 12;
			10'd155 : out = 12;
			10'd156 : out = 13;
			10'd157 : out = 13;
			10'd158 : out = 13;
			10'd159 : out = 13;
			10'd160 : out = 13;
			10'd161 : out = 13;
			10'd162 : out = 13;
			10'd163 : out = 13;
			10'd164 : out = 13;
			10'd165 : out = 13;
			10'd166 : out = 13;
			10'd167 : out = 13;
			10'd168 : out = 14;
			10'd169 : out = 14;
			10'd170 : out = 14;
			10'd171 : out = 14;
			10'd172 : out = 14;
			10'd173 : out = 14;
			10'd174 : out = 14;
			10'd175 : out = 14;
			10'd176 : out = 14;
			10'd177 : out = 14;
			10'd178 : out = 14;
			10'd179 : out = 14;
			10'd180 : out = 15;
			10'd181 : out = 15;
			10'd182 : out = 15;
			10'd183 : out = 15;
			10'd184 : out = 15;
			10'd185 : out = 15;
			10'd186 : out = 15;
			10'd187 : out = 15;
			10'd188 : out = 15;
			10'd189 : out = 15;
			10'd190 : out = 15;
			10'd191 : out = 15;
			10'd192 : out = 16;
			10'd193 : out = 16;
			10'd194 : out = 16;
			10'd195 : out = 16;
			10'd196 : out = 16;
			10'd197 : out = 16;
			10'd198 : out = 16;
			10'd199 : out = 16;
			10'd200 : out = 16;
			10'd201 : out = 16;
			10'd202 : out = 16;
			10'd203 : out = 16;
			10'd204 : out = 17;
			10'd205 : out = 17;
			10'd206 : out = 17;
			10'd207 : out = 17;
			10'd208 : out = 17;
			10'd209 : out = 17;
			10'd210 : out = 17;
			10'd211 : out = 17;
			10'd212 : out = 17;
			10'd213 : out = 17;
			10'd214 : out = 17;
			10'd215 : out = 17;
			10'd216 : out = 18;
			10'd217 : out = 18;
			10'd218 : out = 18;
			10'd219 : out = 18;
			10'd220 : out = 18;
			10'd221 : out = 18;
			10'd222 : out = 18;
			10'd223 : out = 18;
			10'd224 : out = 18;
			10'd225 : out = 18;
			10'd226 : out = 18;
			10'd227 : out = 18;
			10'd228 : out = 19;
			10'd229 : out = 19;
			10'd230 : out = 19;
			10'd231 : out = 19;
			10'd232 : out = 19;
			10'd233 : out = 19;
			10'd234 : out = 19;
			10'd235 : out = 19;
			10'd236 : out = 19;
			10'd237 : out = 19;
			10'd238 : out = 19;
			10'd239 : out = 19;
			10'd240 : out = 20;
			10'd241 : out = 20;
			10'd242 : out = 20;
			10'd243 : out = 20;
			10'd244 : out = 20;
			10'd245 : out = 20;
			10'd246 : out = 20;
			10'd247 : out = 20;
			10'd248 : out = 20;
			10'd249 : out = 20;
			10'd250 : out = 20;
			10'd251 : out = 20;
			10'd252 : out = 21;
			10'd253 : out = 21;
			10'd254 : out = 21;
			10'd255 : out = 21;
			10'd256 : out = 21;
			10'd257 : out = 21;
			10'd258 : out = 21;
			10'd259 : out = 21;
			10'd260 : out = 21;
			10'd261 : out = 21;
			10'd262 : out = 21;
			10'd263 : out = 21;
			10'd264 : out = 22;
			10'd265 : out = 22;
			10'd266 : out = 22;
			10'd267 : out = 22;
			10'd268 : out = 22;
			10'd269 : out = 22;
			10'd270 : out = 22;
			10'd271 : out = 22;
			10'd272 : out = 22;
			10'd273 : out = 22;
			10'd274 : out = 22;
			10'd275 : out = 22;
			10'd276 : out = 23;
			10'd277 : out = 23;
			10'd278 : out = 23;
			10'd279 : out = 23;
			10'd280 : out = 23;
			10'd281 : out = 23;
			10'd282 : out = 23;
			10'd283 : out = 23;
			10'd284 : out = 23;
			10'd285 : out = 23;
			10'd286 : out = 23;
			10'd287 : out = 23;
			10'd288 : out = 24;
			10'd289 : out = 24;
			10'd290 : out = 24;
			10'd291 : out = 24;
			10'd292 : out = 24;
			10'd293 : out = 24;
			10'd294 : out = 24;
			10'd295 : out = 24;
			10'd296 : out = 24;
			10'd297 : out = 24;
			10'd298 : out = 24;
			10'd299 : out = 24;
			10'd300 : out = 25;
			10'd301 : out = 25;
			10'd302 : out = 25;
			10'd303 : out = 25;
			10'd304 : out = 25;
			10'd305 : out = 25;
			10'd306 : out = 25;
			10'd307 : out = 25;
			10'd308 : out = 25;
			10'd309 : out = 25;
			10'd310 : out = 25;
			10'd311 : out = 25;
			10'd312 : out = 26;
			10'd313 : out = 26;
			10'd314 : out = 26;
			10'd315 : out = 26;
			10'd316 : out = 26;
			10'd317 : out = 26;
			10'd318 : out = 26;
			10'd319 : out = 26;
			10'd320 : out = 26;
			10'd321 : out = 26;
			10'd322 : out = 26;
			10'd323 : out = 26;
			10'd324 : out = 27;
			10'd325 : out = 27;
			10'd326 : out = 27;
			10'd327 : out = 27;
			10'd328 : out = 27;
			10'd329 : out = 27;
			10'd330 : out = 27;
			10'd331 : out = 27;
			10'd332 : out = 27;
			10'd333 : out = 27;
			10'd334 : out = 27;
			10'd335 : out = 27;
			10'd336 : out = 28;
			10'd337 : out = 28;
			10'd338 : out = 28;
			10'd339 : out = 28;
			10'd340 : out = 28;
			10'd341 : out = 28;
			10'd342 : out = 28;
			10'd343 : out = 28;
			10'd344 : out = 28;
			10'd345 : out = 28;
			10'd346 : out = 28;
			10'd347 : out = 28;
			10'd348 : out = 29;
			10'd349 : out = 29;
			10'd350 : out = 29;
			10'd351 : out = 29;
			10'd352 : out = 29;
			10'd353 : out = 29;
			10'd354 : out = 29;
			10'd355 : out = 29;
			10'd356 : out = 29;
			10'd357 : out = 29;
			10'd358 : out = 29;
			10'd359 : out = 29;
			10'd360 : out = 30;
			10'd361 : out = 30;
			10'd362 : out = 30;
			10'd363 : out = 30;
			10'd364 : out = 30;
			10'd365 : out = 30;
			10'd366 : out = 30;
			10'd367 : out = 30;
			10'd368 : out = 30;
			10'd369 : out = 30;
			10'd370 : out = 30;
			10'd371 : out = 30;
			10'd372 : out = 31;
			10'd373 : out = 31;
			10'd374 : out = 31;
			10'd375 : out = 31;
			10'd376 : out = 31;
			10'd377 : out = 31;
			10'd378 : out = 31;
			10'd379 : out = 31;
			10'd380 : out = 31;
			10'd381 : out = 31;
			10'd382 : out = 31;
			10'd383 : out = 31;
			10'd384 : out = 32;
			10'd385 : out = 32;
			10'd386 : out = 32;
			10'd387 : out = 32;
			10'd388 : out = 32;
			10'd389 : out = 32;
			10'd390 : out = 32;
			10'd391 : out = 32;
			10'd392 : out = 32;
			10'd393 : out = 32;
			10'd394 : out = 32;
			10'd395 : out = 32;
			10'd396 : out = 33;
			10'd397 : out = 33;
			10'd398 : out = 33;
			10'd399 : out = 33;
			10'd400 : out = 33;
			10'd401 : out = 33;
			10'd402 : out = 33;
			10'd403 : out = 33;
			10'd404 : out = 33;
			10'd405 : out = 33;
			10'd406 : out = 33;
			10'd407 : out = 33;
			10'd408 : out = 34;
			10'd409 : out = 34;
			10'd410 : out = 34;
			10'd411 : out = 34;
			10'd412 : out = 34;
			10'd413 : out = 34;
			10'd414 : out = 34;
			10'd415 : out = 34;
			10'd416 : out = 34;
			10'd417 : out = 34;
			10'd418 : out = 34;
			10'd419 : out = 34;
			10'd420 : out = 35;
			10'd421 : out = 35;
			10'd422 : out = 35;
			10'd423 : out = 35;
			10'd424 : out = 35;
			10'd425 : out = 35;
			10'd426 : out = 35;
			10'd427 : out = 35;
			10'd428 : out = 35;
			10'd429 : out = 35;
			10'd430 : out = 35;
			10'd431 : out = 35;
			10'd432 : out = 36;
			10'd433 : out = 36;
			10'd434 : out = 36;
			10'd435 : out = 36;
			10'd436 : out = 36;
			10'd437 : out = 36;
			10'd438 : out = 36;
			10'd439 : out = 36;
			10'd440 : out = 36;
			10'd441 : out = 36;
			10'd442 : out = 36;
			10'd443 : out = 36;
			10'd444 : out = 37;
			10'd445 : out = 37;
			10'd446 : out = 37;
			10'd447 : out = 37;
			10'd448 : out = 37;
			10'd449 : out = 37;
			10'd450 : out = 37;
			10'd451 : out = 37;
			10'd452 : out = 37;
			10'd453 : out = 37;
			10'd454 : out = 37;
			10'd455 : out = 37;
			10'd456 : out = 38;
			10'd457 : out = 38;
			10'd458 : out = 38;
			10'd459 : out = 38;
			10'd460 : out = 38;
			10'd461 : out = 38;
			10'd462 : out = 38;
			10'd463 : out = 38;
			10'd464 : out = 38;
			10'd465 : out = 38;
			10'd466 : out = 38;
			10'd467 : out = 38;
			10'd468 : out = 39;
			10'd469 : out = 39;
			10'd470 : out = 39;
			10'd471 : out = 39;
			10'd472 : out = 39;
			10'd473 : out = 39;
			10'd474 : out = 39;
			10'd475 : out = 39;
			10'd476 : out = 39;
			10'd477 : out = 39;
			10'd478 : out = 39;
			10'd479 : out = 39;
			10'd480 : out = 40;
			10'd481 : out = 40;
			10'd482 : out = 40;
			10'd483 : out = 40;
			10'd484 : out = 40;
			10'd485 : out = 40;
			10'd486 : out = 40;
			10'd487 : out = 40;
			10'd488 : out = 40;
			10'd489 : out = 40;
			10'd490 : out = 40;
			10'd491 : out = 40;
			10'd492 : out = 41;
			10'd493 : out = 41;
			10'd494 : out = 41;
			10'd495 : out = 41;
			10'd496 : out = 41;
			10'd497 : out = 41;
			10'd498 : out = 41;
			10'd499 : out = 41;
			10'd500 : out = 41;
			10'd501 : out = 41;
			10'd502 : out = 41;
			10'd503 : out = 41;
			10'd504 : out = 42;
			10'd505 : out = 42;
			10'd506 : out = 42;
			10'd507 : out = 42;
			10'd508 : out = 42;
			10'd509 : out = 42;
			10'd510 : out = 42;
			10'd511 : out = 42;
			10'd512 : out = 42;
			10'd513 : out = 42;
			10'd514 : out = 42;
			10'd515 : out = 42;
			10'd516 : out = 43;
			10'd517 : out = 43;
			10'd518 : out = 43;
			10'd519 : out = 43;
			10'd520 : out = 43;
			10'd521 : out = 43;
			10'd522 : out = 43;
			10'd523 : out = 43;
			10'd524 : out = 43;
			10'd525 : out = 43;
			10'd526 : out = 43;
			10'd527 : out = 43;
			10'd528 : out = 44;
			10'd529 : out = 44;
			10'd530 : out = 44;
			10'd531 : out = 44;
			10'd532 : out = 44;
			10'd533 : out = 44;
			10'd534 : out = 44;
			10'd535 : out = 44;
			10'd536 : out = 44;
			10'd537 : out = 44;
			10'd538 : out = 44;
			10'd539 : out = 44;
			10'd540 : out = 45;
			10'd541 : out = 45;
			10'd542 : out = 45;
			10'd543 : out = 45;
			10'd544 : out = 45;
			10'd545 : out = 45;
			10'd546 : out = 45;
			10'd547 : out = 45;
			10'd548 : out = 45;
			10'd549 : out = 45;
			10'd550 : out = 45;
			10'd551 : out = 45;
			10'd552 : out = 46;
			10'd553 : out = 46;
			10'd554 : out = 46;
			10'd555 : out = 46;
			10'd556 : out = 46;
			10'd557 : out = 46;
			10'd558 : out = 46;
			10'd559 : out = 46;
			10'd560 : out = 46;
			10'd561 : out = 46;
			10'd562 : out = 46;
			10'd563 : out = 46;
			10'd564 : out = 47;
			10'd565 : out = 47;
			10'd566 : out = 47;
			10'd567 : out = 47;
			10'd568 : out = 47;
			10'd569 : out = 47;
			10'd570 : out = 47;
			10'd571 : out = 47;
			10'd572 : out = 47;
			10'd573 : out = 47;
			10'd574 : out = 47;
			10'd575 : out = 47;
			10'd576 : out = 48;
			10'd577 : out = 48;
			10'd578 : out = 48;
			10'd579 : out = 48;
			10'd580 : out = 48;
			10'd581 : out = 48;
			10'd582 : out = 48;
			10'd583 : out = 48;
			10'd584 : out = 48;
			10'd585 : out = 48;
			10'd586 : out = 48;
			10'd587 : out = 48;
			10'd588 : out = 49;
			10'd589 : out = 49;
			10'd590 : out = 49;
			10'd591 : out = 49;
			10'd592 : out = 49;
			10'd593 : out = 49;
			10'd594 : out = 49;
			10'd595 : out = 49;
			10'd596 : out = 49;
			10'd597 : out = 49;
			10'd598 : out = 49;
			10'd599 : out = 49;
			10'd600 : out = 50;
			10'd601 : out = 50;
			10'd602 : out = 50;
			10'd603 : out = 50;
			10'd604 : out = 50;
			10'd605 : out = 50;
			10'd606 : out = 50;
			10'd607 : out = 50;
			10'd608 : out = 50;
			10'd609 : out = 50;
			10'd610 : out = 50;
			10'd611 : out = 50;
			10'd612 : out = 51;
			10'd613 : out = 51;
			10'd614 : out = 51;
			10'd615 : out = 51;
			10'd616 : out = 51;
			10'd617 : out = 51;
			10'd618 : out = 51;
			10'd619 : out = 51;
			10'd620 : out = 51;
			10'd621 : out = 51;
			10'd622 : out = 51;
			10'd623 : out = 51;
			10'd624 : out = 52;
			10'd625 : out = 52;
			10'd626 : out = 52;
			10'd627 : out = 52;
			10'd628 : out = 52;
			10'd629 : out = 52;
			10'd630 : out = 52;
			10'd631 : out = 52;
			10'd632 : out = 52;
			10'd633 : out = 52;
			10'd634 : out = 52;
			10'd635 : out = 52;
			10'd636 : out = 53;
			10'd637 : out = 53;
			10'd638 : out = 53;
			10'd639 : out = 53;
			10'd640 : out = 53;
			10'd641 : out = 53;
			10'd642 : out = 53;
			10'd643 : out = 53;
			10'd644 : out = 53;
			10'd645 : out = 53;
			10'd646 : out = 53;
			10'd647 : out = 53;
			10'd648 : out = 54;
			10'd649 : out = 54;
			10'd650 : out = 54;
			10'd651 : out = 54;
			10'd652 : out = 54;
			10'd653 : out = 54;
			10'd654 : out = 54;
			10'd655 : out = 54;
			10'd656 : out = 54;
			10'd657 : out = 54;
			10'd658 : out = 54;
			10'd659 : out = 54;
			10'd660 : out = 55;
			10'd661 : out = 55;
			10'd662 : out = 55;
			10'd663 : out = 55;
			10'd664 : out = 55;
			10'd665 : out = 55;
			10'd666 : out = 55;
			10'd667 : out = 55;
			10'd668 : out = 55;
			10'd669 : out = 55;
			10'd670 : out = 55;
			10'd671 : out = 55;
			10'd672 : out = 56;
			10'd673 : out = 56;
			10'd674 : out = 56;
			10'd675 : out = 56;
			10'd676 : out = 56;
			10'd677 : out = 56;
			10'd678 : out = 56;
			10'd679 : out = 56;
			10'd680 : out = 56;
			10'd681 : out = 56;
			10'd682 : out = 56;
			10'd683 : out = 56;
			10'd684 : out = 57;
			10'd685 : out = 57;
			10'd686 : out = 57;
			10'd687 : out = 57;
			10'd688 : out = 57;
			10'd689 : out = 57;
			10'd690 : out = 57;
			10'd691 : out = 57;
			10'd692 : out = 57;
			10'd693 : out = 57;
			10'd694 : out = 57;
			10'd695 : out = 57;
			10'd696 : out = 58;
			10'd697 : out = 58;
			10'd698 : out = 58;
			10'd699 : out = 58;
			10'd700 : out = 58;
			10'd701 : out = 58;
			10'd702 : out = 58;
			10'd703 : out = 58;
			10'd704 : out = 58;
			10'd705 : out = 58;
			10'd706 : out = 58;
			10'd707 : out = 58;
			10'd708 : out = 59;
			10'd709 : out = 59;
			10'd710 : out = 59;
			10'd711 : out = 59;
			10'd712 : out = 59;
			10'd713 : out = 59;
			10'd714 : out = 59;
			10'd715 : out = 59;
			10'd716 : out = 59;
			10'd717 : out = 59;
			10'd718 : out = 59;
			10'd719 : out = 59;
			10'd720 : out = 60;
			10'd721 : out = 60;
			10'd722 : out = 60;
			10'd723 : out = 60;
			10'd724 : out = 60;
			10'd725 : out = 60;
			10'd726 : out = 60;
			10'd727 : out = 60;
			10'd728 : out = 60;
			10'd729 : out = 60;
			10'd730 : out = 60;
			10'd731 : out = 60;
			10'd732 : out = 61;
			10'd733 : out = 61;
			10'd734 : out = 61;
			10'd735 : out = 61;
			10'd736 : out = 61;
			10'd737 : out = 61;
			10'd738 : out = 61;
			10'd739 : out = 61;
			10'd740 : out = 61;
			10'd741 : out = 61;
			10'd742 : out = 61;
			10'd743 : out = 61;
			10'd744 : out = 62;
			10'd745 : out = 62;
			10'd746 : out = 62;
			10'd747 : out = 62;
			10'd748 : out = 62;
			10'd749 : out = 62;
			10'd750 : out = 62;
			10'd751 : out = 62;
			10'd752 : out = 62;
			10'd753 : out = 62;
			10'd754 : out = 62;
			10'd755 : out = 62;
			10'd756 : out = 63;
			10'd757 : out = 63;
			10'd758 : out = 63;
			10'd759 : out = 63;
			10'd760 : out = 63;
			10'd761 : out = 63;
			10'd762 : out = 63;
			10'd763 : out = 63;
			10'd764 : out = 63;
			10'd765 : out = 63;
			10'd766 : out = 63;
			10'd767 : out = 63;
			10'd768 : out = 64;
			10'd769 : out = 64;
			10'd770 : out = 64;
			10'd771 : out = 64;
			10'd772 : out = 64;
			10'd773 : out = 64;
			10'd774 : out = 64;
			10'd775 : out = 64;
			10'd776 : out = 64;
			10'd777 : out = 64;
			10'd778 : out = 64;
			10'd779 : out = 64;
			10'd780 : out = 65;
			10'd781 : out = 65;
			10'd782 : out = 65;
			10'd783 : out = 65;
			10'd784 : out = 65;
			10'd785 : out = 65;
			10'd786 : out = 65;
			10'd787 : out = 65;
			10'd788 : out = 65;
			10'd789 : out = 65;
			10'd790 : out = 65;
			10'd791 : out = 65;
			10'd792 : out = 66;
			10'd793 : out = 66;
			10'd794 : out = 66;
			10'd795 : out = 66;
			10'd796 : out = 66;
			10'd797 : out = 66;
			10'd798 : out = 66;
			10'd799 : out = 66;
			10'd800 : out = 66;
			10'd801 : out = 66;
			10'd802 : out = 66;
			10'd803 : out = 66;
			10'd804 : out = 67;
			10'd805 : out = 67;
			10'd806 : out = 67;
			10'd807 : out = 67;
			10'd808 : out = 67;
			10'd809 : out = 67;
			10'd810 : out = 67;
			10'd811 : out = 67;
			10'd812 : out = 67;
			10'd813 : out = 67;
			10'd814 : out = 67;
			10'd815 : out = 67;
			10'd816 : out = 68;
			10'd817 : out = 68;
			10'd818 : out = 68;
			10'd819 : out = 68;
			10'd820 : out = 68;
			10'd821 : out = 68;
			10'd822 : out = 68;
			10'd823 : out = 68;
			10'd824 : out = 68;
			10'd825 : out = 68;
			10'd826 : out = 68;
			10'd827 : out = 68;
			10'd828 : out = 69;
			10'd829 : out = 69;
			10'd830 : out = 69;
			10'd831 : out = 69;
			10'd832 : out = 69;
			10'd833 : out = 69;
			10'd834 : out = 69;
			10'd835 : out = 69;
			10'd836 : out = 69;
			10'd837 : out = 69;
			10'd838 : out = 69;
			10'd839 : out = 69;
			10'd840 : out = 70;
			10'd841 : out = 70;
			10'd842 : out = 70;
			10'd843 : out = 70;
			10'd844 : out = 70;
			10'd845 : out = 70;
			10'd846 : out = 70;
			10'd847 : out = 70;
			10'd848 : out = 70;
			10'd849 : out = 70;
			10'd850 : out = 70;
			10'd851 : out = 70;
			10'd852 : out = 71;
			10'd853 : out = 71;
			10'd854 : out = 71;
			10'd855 : out = 71;
			10'd856 : out = 71;
			10'd857 : out = 71;
			10'd858 : out = 71;
			10'd859 : out = 71;
			10'd860 : out = 71;
			10'd861 : out = 71;
			10'd862 : out = 71;
			10'd863 : out = 71;
			10'd864 : out = 72;
			10'd865 : out = 72;
			10'd866 : out = 72;
			10'd867 : out = 72;
			10'd868 : out = 72;
			10'd869 : out = 72;
			10'd870 : out = 72;
			10'd871 : out = 72;
			10'd872 : out = 72;
			10'd873 : out = 72;
			10'd874 : out = 72;
			10'd875 : out = 72;
			10'd876 : out = 73;
			10'd877 : out = 73;
			10'd878 : out = 73;
			10'd879 : out = 73;
			10'd880 : out = 73;
			10'd881 : out = 73;
			10'd882 : out = 73;
			10'd883 : out = 73;
			10'd884 : out = 73;
			10'd885 : out = 73;
			10'd886 : out = 73;
			10'd887 : out = 73;
			10'd888 : out = 74;
			10'd889 : out = 74;
			10'd890 : out = 74;
			10'd891 : out = 74;
			10'd892 : out = 74;
			10'd893 : out = 74;
			10'd894 : out = 74;
			10'd895 : out = 74;
			10'd896 : out = 74;
			10'd897 : out = 74;
			10'd898 : out = 74;
			10'd899 : out = 74;
			10'd900 : out = 75;
			10'd901 : out = 75;
			10'd902 : out = 75;
			10'd903 : out = 75;
			10'd904 : out = 75;
			10'd905 : out = 75;
			10'd906 : out = 75;
			10'd907 : out = 75;
			10'd908 : out = 75;
			10'd909 : out = 75;
			10'd910 : out = 75;
			10'd911 : out = 75;
			10'd912 : out = 76;
			10'd913 : out = 76;
			10'd914 : out = 76;
			10'd915 : out = 76;
			10'd916 : out = 76;
			10'd917 : out = 76;
			10'd918 : out = 76;
			10'd919 : out = 76;
			10'd920 : out = 76;
			10'd921 : out = 76;
			10'd922 : out = 76;
			10'd923 : out = 76;
			10'd924 : out = 77;
			10'd925 : out = 77;
			10'd926 : out = 77;
			10'd927 : out = 77;
			10'd928 : out = 77;
			10'd929 : out = 77;
			10'd930 : out = 77;
			10'd931 : out = 77;
			10'd932 : out = 77;
			10'd933 : out = 77;
			10'd934 : out = 77;
			10'd935 : out = 77;
			10'd936 : out = 78;
			10'd937 : out = 78;
			10'd938 : out = 78;
			10'd939 : out = 78;
			10'd940 : out = 78;
			10'd941 : out = 78;
			10'd942 : out = 78;
			10'd943 : out = 78;
			10'd944 : out = 78;
			10'd945 : out = 78;
			10'd946 : out = 78;
			10'd947 : out = 78;
			10'd948 : out = 79;
			10'd949 : out = 79;
			10'd950 : out = 79;
			10'd951 : out = 79;
			10'd952 : out = 79;
			10'd953 : out = 79;
			10'd954 : out = 79;
			10'd955 : out = 79;
			10'd956 : out = 79;
			10'd957 : out = 79;
			10'd958 : out = 79;
			10'd959 : out = 79;
			10'd960 : out = 80;
			10'd961 : out = 80;
			10'd962 : out = 80;
			10'd963 : out = 80;
			10'd964 : out = 80;
			10'd965 : out = 80;
			10'd966 : out = 80;
			10'd967 : out = 80;
			10'd968 : out = 80;
			10'd969 : out = 80;
			10'd970 : out = 80;
			10'd971 : out = 80;
			10'd972 : out = 81;
			10'd973 : out = 81;
			10'd974 : out = 81;
			10'd975 : out = 81;
			10'd976 : out = 81;
			10'd977 : out = 81;
			10'd978 : out = 81;
			10'd979 : out = 81;
			10'd980 : out = 81;
			10'd981 : out = 81;
			10'd982 : out = 81;
			10'd983 : out = 81;
			10'd984 : out = 82;
			10'd985 : out = 82;
			10'd986 : out = 82;
			10'd987 : out = 82;
			10'd988 : out = 82;
			10'd989 : out = 82;
			10'd990 : out = 82;
			10'd991 : out = 82;
			10'd992 : out = 82;
			10'd993 : out = 82;
			10'd994 : out = 82;
			10'd995 : out = 82;
			10'd996 : out = 83;
			10'd997 : out = 83;
			10'd998 : out = 83;
			10'd999 : out = 83;
			10'd1000 : out = 83;
			10'd1001 : out = 83;
			10'd1002 : out = 83;
			10'd1003 : out = 83;
			10'd1004 : out = 83;
			10'd1005 : out = 83;
			10'd1006 : out = 83;
			10'd1007 : out = 83;
			10'd1008 : out = 84;
			10'd1009 : out = 84;
			10'd1010 : out = 84;
			10'd1011 : out = 84;
			10'd1012 : out = 84;
			10'd1013 : out = 84;
			10'd1014 : out = 84;
			10'd1015 : out = 84;
			10'd1016 : out = 84;
			10'd1017 : out = 84;
			10'd1018 : out = 84;
			10'd1019 : out = 84;
			10'd1020 : out = 85;
			10'd1021 : out = 85;
			10'd1022 : out = 85;
			10'd1023 : out = 85;
			default : out = 0;
		endcase
	end

endmodule

// module BBQ (meat,vagetable,water,cost);
// input XXX;
// output XXX;
// 
// endmodule

// --------------------------------------------------
// Example for using submodule 
// BBQ bbq0(.meat(meat_0), .vagetable(vagetable_0), .water(water_0),.cost(cost[0]));
// --------------------------------------------------
// Example for continuous assignment
// assign out_n = XXX;
// --------------------------------------------------
// Example for procedure assignment
// always@(*) begin 
// 	out_n = XXX; 
// end
// --------------------------------------------------
// Example for case statement
// always @(*) begin
// 	case(op)
// 		2'b00: output_reg = a + b;
// 		2'b10: output_reg = a - b;
// 		2'b01: output_reg = a * b;
// 		2'b11: output_reg = a / b;
// 		default: output_reg = 0;
// 	endcase
// end
// --------------------------------------------------
