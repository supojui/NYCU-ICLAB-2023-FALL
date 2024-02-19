//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

// Input Signals
input clk, rst_n;
input in_valid;
input direction;
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output reg [7:0] out_data;

// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;

//==============================================//
//                CRC calculation               //
//==============================================//


function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1

    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;
    input [63:0] data;  // 40-bit data input
    reg [15:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 16'h1021;  // x^16 + x^12 + x^5 + 1

    begin
        crc = 16'd0;
        for (i = 0; i < 64; i = i + 1) begin
            data_in = data[63-i];
            data_out = crc[15];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC16_CCITT = crc;
    end
endfunction




//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter IDLE          = 0;
parameter AR_ready      = 1;
parameter R_ready       = 2;
parameter COMMAND       = 3;
parameter RESPONSE      = 4;
parameter WAIT_24       = 5;
parameter SD_write      = 6;
parameter DATA_response = 7;
parameter BUSY          = 8;
parameter WAIT_token    = 9;
parameter SD_read       = 10;
parameter AW_ready      = 11;
parameter W_ready       = 12;
parameter B_valid       = 13;
parameter OUT           = 14;

//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [3:0]cur_state;
reg [3:0]nxt_state;
reg MOSI_comb;
reg MISO_seq;
wire [5:0]counter_24;
reg  [5:0]counter_24_seq;
wire [5:0]counter_48;
reg  [5:0]counter_48_seq;
wire [5:0]counter_8;
reg  [5:0]counter_8_seq;
wire [6:0]counter_88;
reg  [6:0]counter_88_seq;
wire [6:0]counter_80;
reg  [6:0]counter_80_seq;

reg direction_seq;
reg in_valid_seq;
//==============================================//
//                  design                      //
//==============================================//

assign counter_48 = (cur_state == COMMAND)  ? counter_48_seq + 1 : 0;
assign counter_8  = ((cur_state == RESPONSE && MISO == 0) || cur_state == DATA_response || cur_state == OUT) ? counter_8_seq  + 1 : 0;
assign counter_88 = (cur_state == SD_write) ? counter_88_seq + 1 : 0;
assign counter_80 = (cur_state == SD_read) ? counter_80_seq + 1 : 0; 
assign counter_24 = (cur_state == WAIT_24) ? counter_24_seq + 1 : 0;

always @(*) begin
    case(cur_state)
        IDLE : begin
            if(in_valid_seq) begin
                if(direction_seq == 0) begin
                    nxt_state = AR_ready;
                end
                else if(direction_seq == 1) begin
                    nxt_state = COMMAND;
                end
                else begin
                    nxt_state = IDLE;
                end
            end
            else begin
                nxt_state = IDLE;
            end
        end
        AR_ready : begin
            if(AR_READY && AR_VALID) begin
                nxt_state = R_ready;
            end
            else begin
                nxt_state = AR_ready;
            end
        end
        R_ready : begin
            if(R_READY && R_VALID) begin
                nxt_state = COMMAND;
            end
            else begin
                nxt_state = R_ready;
            end
        end
        COMMAND : begin
            if(counter_48_seq >= 47) begin //count 48 cycles then go to response
                nxt_state = RESPONSE;
            end
            else begin
                nxt_state = COMMAND;
            end
        end
        RESPONSE : begin
            if(counter_8_seq >= 7 && direction_seq == 0) begin
                nxt_state = WAIT_24;
            end
            else if(counter_8_seq >= 7 && direction_seq == 1) begin
                nxt_state = WAIT_token;
            end
            else begin
                nxt_state = RESPONSE;
            end
        end
        WAIT_24 : begin
            if(counter_24_seq >= 22) begin
                nxt_state = SD_write;
            end
            else begin
                nxt_state = WAIT_24;
            end
        end
        SD_write : begin
            if(counter_88_seq >= 87) begin
                nxt_state = DATA_response;
            end

            else begin
                nxt_state = SD_write;
            end
        end
        DATA_response : begin
            if(counter_8_seq >= 8) begin
                nxt_state = BUSY;
            end
            else begin
                nxt_state = DATA_response;
            end
        end
        BUSY : begin
            if(MISO == 0) begin
                nxt_state = BUSY;
            end
            else begin
                nxt_state = OUT;
            end
        end

        WAIT_token : begin
            if(MISO == 0) begin
                nxt_state = SD_read;
            end
            else begin
                nxt_state = WAIT_token;
            end
        end
        SD_read : begin
            if(counter_80_seq >= 79) begin
                nxt_state = AW_ready;
            end
            else begin
                nxt_state = SD_read;
            end
        end
        AW_ready : begin
            if(AW_READY && AW_VALID) begin
                nxt_state = W_ready;
            end
            else begin
                nxt_state = AW_ready;
            end
        end
        W_ready : begin
            if(W_READY && W_VALID) begin
                nxt_state = B_valid;
            end
            else begin
                nxt_state = W_ready;
            end
        end
        B_valid : begin
            if(B_VALID && B_READY) begin
                nxt_state = OUT;
            end
            else begin
                nxt_state = B_valid;
            end
        end
        OUT : begin
            if(counter_8_seq >= 7) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = OUT;
            end
        end
        default : begin
            nxt_state = IDLE;
        end

    endcase
end

///////////////////////////////////////////////////
//                      IDLE                     //
///////////////////////////////////////////////////
reg [31:0]addr_dram_seq;
reg [31:0]addr_sd_seq;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_dram_seq <= 0;
        addr_sd_seq <= 0;
        direction_seq <= 0;
    end
    else begin
        addr_dram_seq <= (in_valid) ? addr_dram : addr_dram_seq;
        addr_sd_seq <= (in_valid) ? addr_sd : addr_sd_seq;
        direction_seq <= (in_valid) ? direction : direction_seq;
    end
end

///////////////////////////////////////////////////
//                  DRAM read                    //
///////////////////////////////////////////////////
reg AR_VALID_comb;
reg [31:0]AR_ADDR_comb;
reg R_READY_comb;
reg [63:0]data_dram;

always @(*) begin
    if(cur_state == AR_ready) begin
        AR_VALID_comb = 1;
        AR_ADDR_comb = addr_dram_seq;
    end
    else begin
        AR_VALID_comb = 0;
        AR_ADDR_comb = 0;
    end
end

always @(*) begin
    if(cur_state == R_ready) begin
        R_READY_comb = 1;
    end
    else begin
        R_READY_comb = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        AR_VALID <= 0;
        AR_ADDR <= 0;
        R_READY <= 0;
    end
    else begin
        AR_VALID <= AR_VALID_comb;
        AR_ADDR <= AR_ADDR_comb;
        R_READY <= R_READY_comb;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_dram <= 0;
    end
    else begin
        data_dram <= (R_VALID && R_READY) ? R_DATA : (cur_state == OUT) ? (data_dram << 8) : data_dram;
    end
end

///////////////////////////////////////////////////
//                    COMMAND                    //
///////////////////////////////////////////////////
wire [6:0]crc7;
wire [47:0]MOSI48_comb;
reg  [47:0]MOSI48;

assign crc7 = (direction_seq) ? CRC7(.data({2'b01, 6'd17, addr_sd_seq})) : CRC7(.data({2'b01, 6'd24, addr_sd_seq}));

assign MOSI48_comb = (direction_seq) ? {2'b01, 6'd17, addr_sd_seq, crc7, 1'b1} : {2'b01, 6'd24, addr_sd_seq, crc7, 1'b1};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        MOSI48 <= 0;
        in_valid_seq <= 0;
    end
    else begin
        MOSI48 <= (cur_state == COMMAND) ? (MOSI48 << 1) : MOSI48_comb;
        in_valid_seq <= in_valid;
    end
end

///////////////////////////////////////////////////
//                    RESPONSE                   //
///////////////////////////////////////////////////

///////////////////////////////////////////////////
//                    WAIT_24                    //
///////////////////////////////////////////////////

///////////////////////////////////////////////////
//                    SD_write                   //
///////////////////////////////////////////////////
wire [15:0]crc16;
wire [87:0]MOSI88_comb;
reg  [87:0]MOSI88;

assign crc16 = CRC16_CCITT(.data(data_dram));

assign MOSI88_comb = {8'hFE, data_dram, crc16};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        MOSI88 <= 0;
    end
    else begin
        MOSI88 <= (cur_state == SD_write) ? MOSI88 << 1 : MOSI88_comb;
    end
end

///////////////////////////////////////////////////
//                  DATA_response                //
///////////////////////////////////////////////////

///////////////////////////////////////////////////
//                      BUSY                     //
///////////////////////////////////////////////////

///////////////////////////////////////////////////
//                      SD_read                  //
///////////////////////////////////////////////////
reg [79:0] data_sd_comb;
reg [79:0] data_sd;


wire [15:0] check;

assign check = CRC16_CCITT(.data(data_sd[79:16]));


// $display("%d", check == data_sd[15:0]);

always @(*) begin
    if(cur_state == SD_read) begin
        data_sd_comb = data_sd << 1;
        data_sd_comb[0] = MISO;
    end
    else begin
        data_sd_comb = data_sd;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_sd <= 0;
    end
    else begin
        data_sd <= (cur_state == OUT) ? data_sd_comb << 8 : data_sd_comb;
    end
end


///////////////////////////////////////////////////
//                      AW_ready                 //
///////////////////////////////////////////////////
reg AW_VALID_comb;
reg [31:0]AW_ADDR_comb;

// reg [15:0]check;

// assign check = CRC16_CCITT(.data(data_sd[79:16]));



always @(*) begin
    if(cur_state == AW_ready) begin
        // $display("%d", check);
        // $display("%d", data_sd[15:0]);
        AW_VALID_comb = 1;
        AW_ADDR_comb = addr_dram_seq;
    end
    else begin
        AW_VALID_comb = 0;
        AW_ADDR_comb = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        AW_VALID <= 0;
        AW_ADDR <= 0;
    end
    else begin
        AW_VALID <= AW_VALID_comb;
        AW_ADDR <= AW_ADDR_comb;
    end
end

///////////////////////////////////////////////////
//                      W_ready                  //
///////////////////////////////////////////////////
reg W_VALID_comb;
reg [63:0]W_DATA_comb;

always @(*) begin
    if(cur_state == W_ready) begin
        W_VALID_comb = 1;
        W_DATA_comb = data_sd[79:16];
    end
    else begin
        W_VALID_comb = 0;
        W_DATA_comb = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        W_VALID <= 0;
        W_DATA <= 0;
    end
    else begin
        W_VALID <= W_VALID_comb;
        W_DATA <= W_DATA_comb;
    end
end

///////////////////////////////////////////////////
//                      B_valid                  //
///////////////////////////////////////////////////
reg B_READY_comb;

always @(*) begin
    if(cur_state == B_valid) begin
        B_READY_comb = 1;
    end
    else begin
        B_READY_comb = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        B_READY <= 0;
    end
    else begin
        B_READY <= B_READY_comb;
    end
end

///////////////////////////////////////////////////
//                       OUT                     //
///////////////////////////////////////////////////
reg out_valid_comb;
reg [7:0]out_data_comb;

always @(*) begin
    if(cur_state == OUT) begin
        out_valid_comb = 1;
        out_data_comb = (direction_seq) ? data_sd[79:72] : data_dram[63:56];
    end
    else begin
        out_valid_comb = 0;
        out_data_comb = 0;
    end
end


///////////////////////////////////////////////////
//                    MOSI_comb                  //
///////////////////////////////////////////////////
always @(*) begin
    if(cur_state == COMMAND) begin
        MOSI_comb = MOSI48[47];
    end
    else if(cur_state == SD_write) begin
        MOSI_comb = MOSI88[87];
    end
    else begin
        MOSI_comb = 1;
    end
end



///////////////////////////////////////////////////
//                    DFF                        //
///////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= 0;
        counter_48_seq <= 0;
        counter_8_seq <= 0;
        counter_88_seq <= 0;
        counter_80_seq <= 0;
        counter_24_seq <= 0;
    end
    else begin
        cur_state <= nxt_state;
        counter_48_seq <= counter_48;
        counter_8_seq <= counter_8;
        counter_88_seq <= counter_88;
        counter_80_seq <= counter_80;
        counter_24_seq <= counter_24;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        MOSI <= 1;
        MISO_seq <= 0;
        out_data <= 0;
        out_valid <= 0;
    end
    else begin
        MOSI <= MOSI_comb;
        MISO_seq <= MISO;
        out_data <= out_data_comb;
        out_valid <= out_valid_comb;
    end
end


endmodule

