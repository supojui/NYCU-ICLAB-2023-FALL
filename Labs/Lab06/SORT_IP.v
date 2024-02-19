//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : SORT_IP.v
//   	Module Name : SORT_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SORT_IP #(parameter IP_WIDTH = 8) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output [IP_WIDTH*4-1:0] OUT_character;

// ===============================================================
// Design
// ===============================================================
wire [31:0]out_app;
wire [39:0]weight_app;

reg [31:0]out;
reg [39:0]weight;

generate
    case(IP_WIDTH)
        'd3 : begin
            assign out_app = {IN_character, 20'b0};
            assign weight_app = {IN_weight, 25'b0};

            assign OUT_character = out[31:20];
        end
        'd4 : begin
            assign out_app = {IN_character, 16'b0};
            assign weight_app = {IN_weight, 20'b0};

            assign OUT_character = out[31:16];
        end
        'd5 : begin
            assign out_app = {IN_character, 12'b0};
            assign weight_app = {IN_weight, 15'b0};
            
            assign OUT_character = out[31:12];
        end
        'd6 : begin
            assign out_app = {IN_character, 8'b0};
            assign weight_app = {IN_weight, 10'b0};

            assign OUT_character = out[31:8];
        end
        'd7 : begin
            assign out_app = {IN_character, 4'b0};
            assign weight_app = {IN_weight, 5'b0};
            
            assign OUT_character = out[31:4];
        end
        'd8 : begin
            assign out_app = IN_character;
            assign weight_app = IN_weight;
            
            assign OUT_character = out;
        end
        default : begin
            assign out_app = 0;
            assign weight_app = 0;

            assign OUT_character = 0;
        end
    endcase

endgenerate


always@(*) begin
    out = out_app;
    weight = weight_app;

	if(weight[4:0] > weight[9:5]) begin
		{weight[4:0],  weight[9:5]} = 
		{weight[9:5],  weight[4:0]};
        {out[3:0], out[7:4]} = 
        {out[7:4], out[3:0]};
	end
	else begin
		{weight[4:0],  weight[9:5]} = 
		{weight[4:0],  weight[9:5]};
        {out[7:4], out[3:0]} = 
        {out[7:4], out[3:0]};
	end
	if(weight[14:10] > weight[19:15]) begin
		{weight[14:10],  weight[19:15]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[15:12], out[11:8]};
	end
	else begin
		{weight[19:15],  weight[14:10]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[11:8], out[15:12]};
	end
	if(weight[24:20] > weight[29:25]) begin
		{weight[24:20],  weight[29:25]} = 
		{weight[29:25],  weight[24:20]};
        {out[19:16], out[23:20]} = 
        {out[23:20], out[19:16]};
	end
	else begin
		{weight[24:20],  weight[29:25]} = 
		{weight[24:20],  weight[29:25]};
        {out[19:16], out[23:20]} = 
        {out[19:16], out[23:20]};
	end
	if(weight[34:30] > weight[39:35]) begin
		{weight[34:30],  weight[39:35]} = 
		{weight[39:35],  weight[34:30]};
        {out[27:24], out[31:28]} = 
        {out[31:28], out[27:24]};
	end
	else begin
		{weight[34:30],  weight[39:35]} = 
		{weight[34:30],  weight[39:35]};
        {out[27:24], out[31:28]} = 
        {out[27:24], out[31:28]};
	end
    if(weight[9:5] > weight[14:10]) begin
		{weight[9:5],  weight[14:10]} = 
		{weight[14:10],  weight[9:5]};
        {out[7:4], out[11:8]} = 
        {out[11:8], out[7:4]};
	end
	else begin
		{weight[9:5],  weight[14:10]} = 
		{weight[9:5],  weight[14:10]};
        {out[7:4], out[11:8]} = 
        {out[7:4], out[11:8]};
	end
	if(weight[19:15] > weight[24:20]) begin
		{weight[19:15],  weight[24:20]} = 
		{weight[24:20],  weight[19:15]};
        {out[15:12], out[19:16]} = 
        {out[19:16], out[15:12]};
	end
	else begin
		{weight[19:15],  weight[24:20]} = 
		{weight[19:15],  weight[24:20]};
        {out[15:12], out[19:16]} = 
        {out[15:12], out[19:16]};
	end
	if(weight[29:25] > weight[34:30]) begin
		{weight[29:25],  weight[34:30]} = 
		{weight[34:30],  weight[29:25]};
        {out[23:20], out[27:24]} = 
        {out[27:24], out[23:20]};
	end
	else begin
		{weight[29:25],  weight[34:30]} = 
		{weight[29:25],  weight[34:30]};
        {out[23:20], out[27:24]} = 
        {out[23:20], out[27:24]};
	end



    if(weight[4:0] > weight[9:5]) begin
		{weight[4:0],  weight[9:5]} = 
		{weight[9:5],  weight[4:0]};
        {out[3:0], out[7:4]} = 
        {out[7:4], out[3:0]};
	end
	else begin
		{weight[4:0],  weight[9:5]} = 
		{weight[4:0],  weight[9:5]};
        {out[7:4], out[3:0]} = 
        {out[7:4], out[3:0]};
	end
	if(weight[14:10] > weight[19:15]) begin
		{weight[14:10],  weight[19:15]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[15:12], out[11:8]};
	end
	else begin
		{weight[19:15],  weight[14:10]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[11:8], out[15:12]};
	end
	if(weight[24:20] > weight[29:25]) begin
		{weight[24:20],  weight[29:25]} = 
		{weight[29:25],  weight[24:20]};
        {out[19:16], out[23:20]} = 
        {out[23:20], out[19:16]};
	end
	else begin
		{weight[24:20],  weight[29:25]} = 
		{weight[24:20],  weight[29:25]};
        {out[19:16], out[23:20]} = 
        {out[19:16], out[23:20]};
	end
	if(weight[34:30] > weight[39:35]) begin
		{weight[34:30],  weight[39:35]} = 
		{weight[39:35],  weight[34:30]};
        {out[27:24], out[31:28]} = 
        {out[31:28], out[27:24]};
	end
	else begin
		{weight[34:30],  weight[39:35]} = 
		{weight[34:30],  weight[39:35]};
        {out[27:24], out[31:28]} = 
        {out[27:24], out[31:28]};
	end
    if(weight[9:5] > weight[14:10]) begin
		{weight[9:5],  weight[14:10]} = 
		{weight[14:10],  weight[9:5]};
        {out[7:4], out[11:8]} = 
        {out[11:8], out[7:4]};
	end
	else begin
		{weight[9:5],  weight[14:10]} = 
		{weight[9:5],  weight[14:10]};
        {out[7:4], out[11:8]} = 
        {out[7:4], out[11:8]};
	end
	if(weight[19:15] > weight[24:20]) begin
		{weight[19:15],  weight[24:20]} = 
		{weight[24:20],  weight[19:15]};
        {out[15:12], out[19:16]} = 
        {out[19:16], out[15:12]};
	end
	else begin
		{weight[19:15],  weight[24:20]} = 
		{weight[19:15],  weight[24:20]};
        {out[15:12], out[19:16]} = 
        {out[15:12], out[19:16]};
	end
	if(weight[29:25] > weight[34:30]) begin
		{weight[29:25],  weight[34:30]} = 
		{weight[34:30],  weight[29:25]};
        {out[23:20], out[27:24]} = 
        {out[27:24], out[23:20]};
	end
	else begin
		{weight[29:25],  weight[34:30]} = 
		{weight[29:25],  weight[34:30]};
        {out[23:20], out[27:24]} = 
        {out[23:20], out[27:24]};
	end
	



    if(weight[4:0] > weight[9:5]) begin
		{weight[4:0],  weight[9:5]} = 
		{weight[9:5],  weight[4:0]};
        {out[3:0], out[7:4]} = 
        {out[7:4], out[3:0]};
	end
	else begin
		{weight[4:0],  weight[9:5]} = 
		{weight[4:0],  weight[9:5]};
        {out[7:4], out[3:0]} = 
        {out[7:4], out[3:0]};
	end
	if(weight[14:10] > weight[19:15]) begin
		{weight[14:10],  weight[19:15]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[15:12], out[11:8]};
	end
	else begin
		{weight[19:15],  weight[14:10]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[11:8], out[15:12]};
	end
	if(weight[24:20] > weight[29:25]) begin
		{weight[24:20],  weight[29:25]} = 
		{weight[29:25],  weight[24:20]};
        {out[19:16], out[23:20]} = 
        {out[23:20], out[19:16]};
	end
	else begin
		{weight[24:20],  weight[29:25]} = 
		{weight[24:20],  weight[29:25]};
        {out[19:16], out[23:20]} = 
        {out[19:16], out[23:20]};
	end
	if(weight[34:30] > weight[39:35]) begin
		{weight[34:30],  weight[39:35]} = 
		{weight[39:35],  weight[34:30]};
        {out[27:24], out[31:28]} = 
        {out[31:28], out[27:24]};
	end
	else begin
		{weight[34:30],  weight[39:35]} = 
		{weight[34:30],  weight[39:35]};
        {out[27:24], out[31:28]} = 
        {out[27:24], out[31:28]};
	end
    if(weight[9:5] > weight[14:10]) begin
		{weight[9:5],  weight[14:10]} = 
		{weight[14:10],  weight[9:5]};
        {out[7:4], out[11:8]} = 
        {out[11:8], out[7:4]};
	end
	else begin
		{weight[9:5],  weight[14:10]} = 
		{weight[9:5],  weight[14:10]};
        {out[7:4], out[11:8]} = 
        {out[7:4], out[11:8]};
	end
	if(weight[19:15] > weight[24:20]) begin
		{weight[19:15],  weight[24:20]} = 
		{weight[24:20],  weight[19:15]};
        {out[15:12], out[19:16]} = 
        {out[19:16], out[15:12]};
	end
	else begin
		{weight[19:15],  weight[24:20]} = 
		{weight[19:15],  weight[24:20]};
        {out[15:12], out[19:16]} = 
        {out[15:12], out[19:16]};
	end
	if(weight[29:25] > weight[34:30]) begin
		{weight[29:25],  weight[34:30]} = 
		{weight[34:30],  weight[29:25]};
        {out[23:20], out[27:24]} = 
        {out[27:24], out[23:20]};
	end
	else begin
		{weight[29:25],  weight[34:30]} = 
		{weight[29:25],  weight[34:30]};
        {out[23:20], out[27:24]} = 
        {out[23:20], out[27:24]};
	end



    if(weight[4:0] > weight[9:5]) begin
		{weight[4:0],  weight[9:5]} = 
		{weight[9:5],  weight[4:0]};
        {out[3:0], out[7:4]} = 
        {out[7:4], out[3:0]};
	end
	else begin
		{weight[4:0],  weight[9:5]} = 
		{weight[4:0],  weight[9:5]};
        {out[7:4], out[3:0]} = 
        {out[7:4], out[3:0]};
	end
	if(weight[14:10] > weight[19:15]) begin
		{weight[14:10],  weight[19:15]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[15:12], out[11:8]};
	end
	else begin
		{weight[19:15],  weight[14:10]} = 
		{weight[19:15],  weight[14:10]};
        {out[11:8], out[15:12]} = 
        {out[11:8], out[15:12]};
	end
	if(weight[24:20] > weight[29:25]) begin
		{weight[24:20],  weight[29:25]} = 
		{weight[29:25],  weight[24:20]};
        {out[19:16], out[23:20]} = 
        {out[23:20], out[19:16]};
	end
	else begin
		{weight[24:20],  weight[29:25]} = 
		{weight[24:20],  weight[29:25]};
        {out[19:16], out[23:20]} = 
        {out[19:16], out[23:20]};
	end
	if(weight[34:30] > weight[39:35]) begin
		{weight[34:30],  weight[39:35]} = 
		{weight[39:35],  weight[34:30]};
        {out[27:24], out[31:28]} = 
        {out[31:28], out[27:24]};
	end
	else begin
		{weight[34:30],  weight[39:35]} = 
		{weight[34:30],  weight[39:35]};
        {out[27:24], out[31:28]} = 
        {out[27:24], out[31:28]};
	end
    if(weight[9:5] > weight[14:10]) begin
		{weight[9:5],  weight[14:10]} = 
		{weight[14:10],  weight[9:5]};
        {out[7:4], out[11:8]} = 
        {out[11:8], out[7:4]};
	end
	else begin
		{weight[9:5],  weight[14:10]} = 
		{weight[9:5],  weight[14:10]};
        {out[7:4], out[11:8]} = 
        {out[7:4], out[11:8]};
	end
	if(weight[19:15] > weight[24:20]) begin
		{weight[19:15],  weight[24:20]} = 
		{weight[24:20],  weight[19:15]};
        {out[15:12], out[19:16]} = 
        {out[19:16], out[15:12]};
	end
	else begin
		{weight[19:15],  weight[24:20]} = 
		{weight[19:15],  weight[24:20]};
        {out[15:12], out[19:16]} = 
        {out[15:12], out[19:16]};
	end
	if(weight[29:25] > weight[34:30]) begin
		{weight[29:25],  weight[34:30]} = 
		{weight[34:30],  weight[29:25]};
        {out[23:20], out[27:24]} = 
        {out[27:24], out[23:20]};
	end
	else begin
		{weight[29:25],  weight[34:30]} = 
		{weight[29:25],  weight[34:30]};
        {out[23:20], out[27:24]} = 
        {out[23:20], out[27:24]};
	end

end

endmodule