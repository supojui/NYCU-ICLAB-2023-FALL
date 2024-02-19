//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : HT_TOP.v
//   	Module Name : HT_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Output signals
    out_valid, 
	out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg out_mode_seq;
reg [4:0]counter_7;
reg [4:0]in_weight_comb[0:7];
reg [4:0]in_weight_seq[0:7];
reg [7:0]node_comb[0:7];
reg [7:0]node_seq[0:7];
reg [7:0]code_comb[0:7];
reg [7:0]code_seq[0:7];
reg [3:0]height_comb[0:7];
reg [3:0]height_seq[0:7];
reg [31:0]OUT_character;
reg [31:0]OUT_character_seq;
reg [2:0]cur_state;
reg [2:0]nxt_state;

reg  [4:0]add_in_1;
reg  [4:0]add_in_2;
wire [4:0]add_out;


integer  i;
parameter IDLE = 0;
parameter CAL  = 1;
parameter OUT1 = 2;
parameter OUT2 = 3;
parameter OUT3 = 4;
parameter OUT4 = 5;
parameter OUT5 = 6;
parameter IP_WIDTH = 8;
// ===============================================================
// Design
// ===============================================================

SORT_IP #(.IP_WIDTH(IP_WIDTH)) sort_1(.IN_character({4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0}), 
                                      .IN_weight({in_weight_seq[7], in_weight_seq[6], in_weight_seq[5], in_weight_seq[4], 
                                                  in_weight_seq[3], in_weight_seq[2], in_weight_seq[1], in_weight_seq[0]}),
                                      .OUT_character(OUT_character));



always @(*) begin
    if(cur_state == IDLE) begin
        if(counter_7 >= 1) begin
            nxt_state = CAL;   
        end
        else begin
            nxt_state = IDLE;
        end
    end
    else if(cur_state == CAL) begin
        if(counter_7 == 15) begin
            nxt_state = OUT1;   
        end
        else begin
            nxt_state = CAL;
        end
    end
    else if(cur_state == OUT1) begin
        if(height_seq[3] == 1) begin
            nxt_state = OUT2;
        end
        else begin
            nxt_state = OUT1;
        end
    end
    else if(cur_state == OUT2) begin
        if(out_mode_seq == 0) begin
            if(height_seq[2] == 1) begin
                nxt_state = OUT3;
            end
            else begin
                nxt_state = OUT2;
            end
        end
        else begin
            if(height_seq[5] == 1) begin
                nxt_state = OUT3;
            end
            else begin
                nxt_state = OUT2;
            end
        end
    end
    else if(cur_state == OUT3) begin
        if(out_mode_seq == 0) begin
            if(height_seq[1] == 1) begin
                nxt_state = OUT4;
            end
            else begin
                nxt_state = OUT3;
            end
        end
        else begin
            if(height_seq[2] == 1) begin
                nxt_state = OUT4;
            end
            else begin
                nxt_state = OUT3;
            end
        end
    end
    else if(cur_state == OUT4) begin
        if(out_mode_seq == 0) begin
            if(height_seq[0] == 1) begin
                nxt_state = OUT5;
            end
            else begin
                nxt_state = OUT4;
            end
        end
        else begin
            if(height_seq[7] == 1) begin
                nxt_state = OUT5;
            end
            else begin
                nxt_state = OUT4;
            end
        end
    end
    else if(cur_state == OUT5) begin
        if(out_mode_seq == 0) begin
            if(height_seq[4] == 1) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = OUT5;
            end
        end
        else begin
            if(height_seq[6] == 1) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = OUT5;
            end
        end
    end
    else begin
        nxt_state = IDLE;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= IDLE;
        OUT_character_seq <= 0;
    end
    else begin
        cur_state <= nxt_state;
        OUT_character_seq <= OUT_character;
    end

end


always @(*) begin
    case(counter_7)
        8 : begin
            add_in_1 = in_weight_seq[OUT_character[7:4]];
            add_in_2 = in_weight_seq[OUT_character[3:0]];
        end
        9 : begin
            add_in_1 = in_weight_seq[OUT_character[11:8]];
            add_in_2 = in_weight_seq[OUT_character[7:4]];
        end
        10 : begin
            add_in_1 = in_weight_seq[OUT_character[15:12]];
            add_in_2 = in_weight_seq[OUT_character[11:8]];
        end
        11 : begin
            add_in_1 = in_weight_seq[OUT_character[19:16]];
            add_in_2 = in_weight_seq[OUT_character[15:12]];
        end
        12 : begin
            add_in_1 = in_weight_seq[OUT_character[23:20]];
            add_in_2 = in_weight_seq[OUT_character[19:16]];
        end
        13 : begin
            add_in_1 = in_weight_seq[OUT_character[27:24]];
            add_in_2 = in_weight_seq[OUT_character[23:20]];
        end
        14 : begin
            add_in_1 = in_weight_seq[OUT_character[31:28]];
            add_in_2 = in_weight_seq[OUT_character[27:24]];
        end
        default : begin
            add_in_1 = 0;
            add_in_2 = 0;
        end
    endcase
end

 
assign add_out = add_in_1 + add_in_2;


always @(*) begin
    if(in_valid) begin
        for(i = 0; i < 8; i = i + 1) begin
            if(i == counter_7) begin
                in_weight_comb[7-i] = in_weight;
            end
            else begin
                in_weight_comb[7-i] = in_weight_seq[7-i];
            end
        end
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
            in_weight_comb[i] = in_weight_seq[i];
        end


    
        // in_weight_comb[7] = (counter_7 == 14) ? add_out : (counter_7 >= 15) ? 0 : in_weight_seq[OUT_character[31:28]];
        // in_weight_comb[6] = (counter_7 == 13) ? add_out : (counter_7 >= 14) ? 0 : in_weight_seq[OUT_character[27:24]];
        // in_weight_comb[5] = (counter_7 == 12) ? add_out : (counter_7 >= 13) ? 0 : in_weight_seq[OUT_character[23:20]];
        // in_weight_comb[4] = (counter_7 == 11) ? add_out : (counter_7 >= 12) ? 0 : in_weight_seq[OUT_character[19:16]];
        // in_weight_comb[3] = (counter_7 == 10) ? add_out : (counter_7 >= 11) ? 0 : in_weight_seq[OUT_character[15:12]];
        // in_weight_comb[2] = (counter_7 == 9)  ? add_out : (counter_7 >= 10) ? 0 : in_weight_seq[OUT_character[11:8]];
        // in_weight_comb[1] = (counter_7 == 8)  ? add_out : (counter_7 >= 9)  ? 0 : in_weight_seq[1];
        // in_weight_comb[0] = (counter_7 >= 8)  ? 0 : in_weight_seq[0];



        if(counter_7 == 8) begin
            in_weight_comb[7] = in_weight_seq[OUT_character[31:28]];
            in_weight_comb[6] = in_weight_seq[OUT_character[27:24]];
            in_weight_comb[5] = in_weight_seq[OUT_character[23:20]];
            in_weight_comb[4] = in_weight_seq[OUT_character[19:16]];
            in_weight_comb[3] = in_weight_seq[OUT_character[15:12]];
            in_weight_comb[2] = in_weight_seq[OUT_character[11:8]];
            in_weight_comb[1] = add_out;
            in_weight_comb[0] = 0;
        end
        else if(counter_7 == 9) begin
            in_weight_comb[7] = in_weight_seq[OUT_character[31:28]];
            in_weight_comb[6] = in_weight_seq[OUT_character[27:24]];
            in_weight_comb[5] = in_weight_seq[OUT_character[23:20]];
            in_weight_comb[4] = in_weight_seq[OUT_character[19:16]];
            in_weight_comb[3] = in_weight_seq[OUT_character[15:12]];
            in_weight_comb[2] = add_out;
            in_weight_comb[1] = 0;
            in_weight_comb[0] = 0;
        end
        else if(counter_7 == 10) begin
            in_weight_comb[7] = in_weight_seq[OUT_character[31:28]];
            in_weight_comb[6] = in_weight_seq[OUT_character[27:24]];
            in_weight_comb[5] = in_weight_seq[OUT_character[23:20]];
            in_weight_comb[4] = in_weight_seq[OUT_character[19:16]];
            in_weight_comb[3] = add_out;
            in_weight_comb[2] = 0;
            in_weight_comb[1] = 0;
            in_weight_comb[0] = 0;
        end
        else if(counter_7 == 11) begin
            in_weight_comb[7] = in_weight_seq[OUT_character[31:28]];
            in_weight_comb[6] = in_weight_seq[OUT_character[27:24]];
            in_weight_comb[5] = in_weight_seq[OUT_character[23:20]];
            in_weight_comb[4] = add_out;
            in_weight_comb[3] = 0;
            in_weight_comb[2] = 0;
            in_weight_comb[1] = 0;
            in_weight_comb[0] = 0;
        end
        else if(counter_7 == 12) begin
            in_weight_comb[7] = in_weight_seq[OUT_character[31:28]];
            in_weight_comb[6] = in_weight_seq[OUT_character[27:24]];
            in_weight_comb[5] = add_out;
            in_weight_comb[4] = 0;
            in_weight_comb[3] = 0;
            in_weight_comb[2] = 0;
            in_weight_comb[1] = 0;
            in_weight_comb[0] = 0;
        end
        else if(counter_7 == 13) begin
            in_weight_comb[7] = in_weight_seq[OUT_character[31:28]];
            in_weight_comb[6] = add_out;
            in_weight_comb[5] = 0;
            in_weight_comb[4] = 0;
            in_weight_comb[3] = 0;
            in_weight_comb[2] = 0;
            in_weight_comb[1] = 0;
            in_weight_comb[0] = 0;
        end
        else if(counter_7 == 14) begin
            in_weight_comb[7] = add_out;
            in_weight_comb[6] = 0;
            in_weight_comb[5] = 0;
            in_weight_comb[4] = 0;
            in_weight_comb[3] = 0;
            in_weight_comb[2] = 0;
            in_weight_comb[1] = 0;
            in_weight_comb[0] = 0;
        end
        
    end
end



always @(*) begin

    for(i = 0; i < 8; i = i + 1) begin
        code_comb[i] = code_seq[i];
    end
    for(i = 0; i < 8; i = i + 1) begin
        height_comb[i] = height_seq[i];
    end
    for(i = 0; i < 8; i = i + 1) begin
        node_comb[i] = node_seq[i];
    end

    
    if(counter_7 == 9)begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[7:4]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[3:0]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end
        node_comb[7] = node_seq[OUT_character_seq[31:28]];
        node_comb[6] = node_seq[OUT_character_seq[27:24]];
        node_comb[5] = node_seq[OUT_character_seq[23:20]];
        node_comb[4] = node_seq[OUT_character_seq[19:16]];
        node_comb[3] = node_seq[OUT_character_seq[15:12]];
        node_comb[2] = node_seq[OUT_character_seq[11:8]];
        node_comb[1] = node_seq[OUT_character_seq[7:4]] | node_seq[OUT_character_seq[3:0]];
        node_comb[0] = 0;
    end
    else if(counter_7 == 10) begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[11:8]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[7:4]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end

        node_comb[7] = node_seq[OUT_character_seq[31:28]];
        node_comb[6] = node_seq[OUT_character_seq[27:24]];
        node_comb[5] = node_seq[OUT_character_seq[23:20]];
        node_comb[4] = node_seq[OUT_character_seq[19:16]];
        node_comb[3] = node_seq[OUT_character_seq[15:12]];
        node_comb[2] = node_seq[OUT_character_seq[11:8]] | node_seq[OUT_character_seq[7:4]];
        node_comb[1] = 0;
        node_comb[0] = 0;
    end
    else if(counter_7 == 11) begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[15:12]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[11:8]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end

        node_comb[7] = node_seq[OUT_character_seq[31:28]];
        node_comb[6] = node_seq[OUT_character_seq[27:24]];
        node_comb[5] = node_seq[OUT_character_seq[23:20]];
        node_comb[4] = node_seq[OUT_character_seq[19:16]];
        node_comb[3] = node_seq[OUT_character_seq[15:12]] | node_seq[OUT_character_seq[11:8]];
        node_comb[2] = 0;
        node_comb[1] = 0;
        node_comb[0] = 0;
    end
    else if(counter_7 == 12) begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[19:16]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[15:12]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end

        node_comb[7] = node_seq[OUT_character_seq[31:28]];
        node_comb[6] = node_seq[OUT_character_seq[27:24]];
        node_comb[5] = node_seq[OUT_character_seq[23:20]];
        node_comb[4] = node_seq[OUT_character_seq[19:16]] | node_seq[OUT_character_seq[15:12]];
        node_comb[3] = 0;
        node_comb[2] = 0;
        node_comb[1] = 0;
        node_comb[0] = 0;
    end
    else if(counter_7 == 13) begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[23:20]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[19:16]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end

        node_comb[7] = node_seq[OUT_character_seq[31:28]];
        node_comb[6] = node_seq[OUT_character_seq[27:24]];
        node_comb[5] = node_seq[OUT_character_seq[23:20]] | node_seq[OUT_character_seq[19:16]];
        node_comb[4] = 0;
        node_comb[3] = 0;
        node_comb[2] = 0;
        node_comb[1] = 0;
        node_comb[0] = 0;
    end
    else if(counter_7 == 14) begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[27:24]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[23:20]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end

        node_comb[7] = node_seq[OUT_character_seq[31:28]];
        node_comb[6] = node_seq[OUT_character_seq[27:24]] | node_seq[OUT_character_seq[23:20]];
        node_comb[5] = 0;
        node_comb[4] = 0;
        node_comb[3] = 0;
        node_comb[2] = 0;
        node_comb[1] = 0;
        node_comb[0] = 0;
    end
    else if(counter_7 == 15) begin

        for(i = 0; i < 8; i = i + 1) begin //find the 1s in the least two element in node array
            if(node_seq[OUT_character_seq[31:28]][i] == 1) begin //left, so append 0 in the front
                code_comb[i] = {1'b0, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b0;

                height_comb[i] = height_seq[i] + 1;
            end

            if(node_seq[OUT_character_seq[27:24]][i] == 1) begin //right, so append 1 in the front
                code_comb[i] = {1'b1, code_seq[i][7:1]};
                // code_comb[i][7] = 1'b1;

                height_comb[i] = height_seq[i] + 1;
            end
        end

        node_comb[7] = node_seq[OUT_character_seq[31:28]] | node_seq[OUT_character_seq[27:24]];
        node_comb[6] = 0;
        node_comb[5] = 0;
        node_comb[4] = 0;
        node_comb[3] = 0;
        node_comb[2] = 0;
        node_comb[1] = 0;
        node_comb[0] = 0;
    end

    
end



always @(*) begin
    if(cur_state == IDLE || cur_state == CAL) begin
        out_code = 0;
    end
    else if(cur_state == OUT1) begin
        out_code = code_seq[3][7];
    end
    else if(cur_state == OUT2) begin
        if(out_mode_seq == 0) begin
            out_code = code_seq[2][7];
        end
        else begin
            out_code = code_seq[5][7];
        end
    end
    else if(cur_state == OUT3) begin
        if(out_mode_seq == 0) begin
            out_code = code_seq[1][7];
        end
        else begin
            out_code = code_seq[2][7];
        end
    end
    else if(cur_state == OUT4) begin
        if(out_mode_seq == 0) begin
            out_code = code_seq[0][7];
        end
        else begin
            out_code = code_seq[7][7];
        end
    end
    else if(cur_state == OUT5) begin
        if(out_mode_seq == 0) begin
            out_code = code_seq[4][7];
        end
        else begin
            out_code = code_seq[6][7];
        end
    end
    else begin
        out_code = 0;
    end

end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
            in_weight_seq[i] <= 0;
        end
        counter_7 <= 0;
        out_mode_seq <= 0;
    end
    else begin

        for(i = 0; i < 8; i = i + 1) begin
            in_weight_seq[i] <= in_weight_comb[i];
        end

        if(in_valid) begin
            counter_7 <= counter_7 + 1;
            out_mode_seq <= (counter_7 == 0) ? out_mode : out_mode_seq;
        end
        else begin
            counter_7 <= (counter_7 != 15 && counter_7 >= 8) ? counter_7 + 1 : 0;
            out_mode_seq <= out_mode_seq;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        node_seq[7] <= 8'b1000_0000; //128
        node_seq[6] <= 8'b0100_0000; //64
        node_seq[5] <= 8'b0010_0000; //32
        node_seq[4] <= 8'b0001_0000; //16
        node_seq[3] <= 8'b0000_1000; //8
        node_seq[2] <= 8'b0000_0100; //4
        node_seq[1] <= 8'b0000_0010; //2
        node_seq[0] <= 8'b0000_0001; //1

        for(i = 0; i < 8; i = i + 1) begin
            code_seq[i] <= 0;
            height_seq[i] <= 0;
        end
    end
    else begin
        if(cur_state == IDLE) begin
            node_seq[7] <= 8'b1000_0000; //128
            node_seq[6] <= 8'b0100_0000; //64
            node_seq[5] <= 8'b0010_0000; //32
            node_seq[4] <= 8'b0001_0000; //16
            node_seq[3] <= 8'b0000_1000; //8
            node_seq[2] <= 8'b0000_0100; //4
            node_seq[1] <= 8'b0000_0010; //2
            node_seq[0] <= 8'b0000_0001; //1

            for(i = 0; i < 8; i = i + 1) begin
                code_seq[i] <= 0;
                height_seq[i] <= 0;
            end
        end
        else if(cur_state == CAL)begin
            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= node_comb[i];
                code_seq[i] <= code_comb[i];
                height_seq[i] <= height_comb[i];
            end
        end
        else if(cur_state == OUT1) begin

            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= node_comb[i];
            end

            height_seq[3] <= height_seq[3] - 1;
            code_seq[3]   <= code_seq[3] << 1;
        end
        else if(cur_state == OUT2) begin

            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= node_comb[i];
            end

            if(out_mode_seq == 0) begin
                height_seq[2] <= height_seq[2] - 1;
                code_seq[2] <= code_seq[2] << 1;
            end
            else begin
                height_seq[5] <= height_seq[5] - 1;
                code_seq[5] <= code_seq[5] << 1;
            end
        end
        else if(cur_state == OUT3) begin

            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= node_comb[i];
            end

            if(out_mode_seq == 0) begin
                height_seq[1] <= height_seq[1] - 1;
                code_seq[1] <= code_seq[1] << 1;
            end
            else begin
                height_seq[2] <= height_seq[2] - 1;
                code_seq[2] <= code_seq[2] << 1;
            end
        end
        else if(cur_state == OUT4) begin
            
            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= node_comb[i];
            end

            if(out_mode_seq == 0) begin
                height_seq[0] <= height_seq[0] - 1;
                code_seq[0] <= code_seq[0] << 1;
            end
            else begin
                height_seq[7] <= height_seq[7] - 1;
                code_seq[7] <= code_seq[7] << 1;
            end
        end
        else if(cur_state == OUT5) begin
            
            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= node_comb[i];
            end

            if(out_mode_seq == 0) begin
                height_seq[4] <= height_seq[4] - 1;
                code_seq[4] <= code_seq[4] << 1;
            end
            else begin
                height_seq[6] <= height_seq[6] - 1;
                code_seq[6] <= code_seq[6] << 1;
            end
        end
        else begin
            for(i = 0; i < 8; i = i + 1) begin
                node_seq[i] <= 0;
                code_seq[i] <= 0;
                height_seq[i] <= 0;
            end
        end
    end

end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         out_valid <= 0;
//     end
//     else begin
//         out_valid <= (nxt_state != IDLE && nxt_state != CAL) ? 1 : 0;
//     end
// end

always @(*) begin
    if(cur_state != IDLE && cur_state != CAL) begin
        out_valid = 1;
    end
    else begin
        out_valid = 0;
    end
end

endmodule