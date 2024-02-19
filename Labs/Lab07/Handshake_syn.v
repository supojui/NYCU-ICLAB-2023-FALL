module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

NDFF_syn NDFF_SYN1 (.D(sreq), .Q(dreq), .rst_n(rst_n), .clk(dclk));
NDFF_syn NDFF_SYN2 (.D(dack), .Q(sack), .rst_n(rst_n), .clk(sclk));

reg [2:0]cur_state;
reg [2:0]nxt_state;
reg [31:0]data;

parameter IDLE = 0;
parameter INPUT = 1;
parameter OUTPUT = 2;


assign sidle = sreq;

always @(*) begin
    case(cur_state)
        IDLE : begin
            if(sack) begin
                nxt_state = OUTPUT;
            end
            else begin
                nxt_state = IDLE;
            end
        end

        INPUT : begin
            if(sready) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = INPUT;
            end
        end

        OUTPUT : begin
            nxt_state = INPUT;
        end

        default : nxt_state = INPUT;

    endcase
end

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= INPUT;
    end
    else begin
        cur_state <= nxt_state;
    end
end

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n) begin
        data <= 0;
    end
    else begin
        if(sreq) begin
            data <= data;
        end
        else begin
            data <= (sready) ? din : data;
        end
    end

end

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n) begin
        sreq <= 0;
    end
    else begin
        if(cur_state == IDLE && sack == 0) begin
            sreq <= 1;
        end
        else begin
            sreq <= 0;
        end
    end
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        dack <= 0;
    end
    else begin
        if(dreq == 1) begin
            dack <= 1;
        end
        else begin
            dack <= 0;
        end
    end
end


always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        dout <= 0;
        dvalid <= 0;
    end
    else begin
        if(dack == 1 && dbusy == 0) begin
            dout <= data;
            dvalid <= 1;
        end
        else begin
            dout <= 0;
            dvalid <= 0;
        end
    end

end


endmodule