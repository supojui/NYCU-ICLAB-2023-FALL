module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        seed_out <= 0;
        out_valid <= 0;
    end
    else begin
        if(!out_idle) begin
            if(in_valid) begin
                seed_out <= seed_in;
                out_valid <= 1;;
            end
            else begin
                seed_out <= 0;
                out_valid <= 0;
            end
        end
        else begin
            seed_out <= seed_out;
            out_valid <= 0;
        end
    end
end


endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output reg out_valid;
output reg [31:0] rand_num;
output reg busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
input handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;


reg [31:0]seed_seq;
reg [31:0]seed_comb;
reg [1:0]cur_state;
reg [1:0]nxt_state;
reg [8:0]counter_out;



wire [31:0]seed_2;
wire [31:0]seed_3;
wire [31:0]seed_4;

parameter IDLE = 0;
parameter OUT  = 1;



always @(*) begin
    case(cur_state)
        IDLE : begin
            seed_comb = seed_seq;
            busy = 0;
            if(in_valid) begin
                nxt_state = OUT;
            end
            else begin
                nxt_state = IDLE;
            end
        end

        OUT : begin
            seed_comb = rand_num;
            busy = 1;
            if(counter_out < 258) begin
                nxt_state = OUT;
            end
            else begin
                nxt_state = IDLE;
            end
        end
        
        default : begin
            seed_comb = seed_seq;
            busy = 0;
            nxt_state = IDLE;
        end
    endcase

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        seed_seq <= 0;
        cur_state <= IDLE;
    end
    else begin
        seed_seq <= (in_valid) ? seed : (fifo_full) ? seed_seq : seed_comb;
        cur_state <= nxt_state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_out <= 0;
    end
    else begin
        if(cur_state == OUT && !fifo_full && !in_valid) begin
            if(counter_out < 258)
                counter_out <= counter_out + 1;
            else
                counter_out <= counter_out;
        end
        else begin
            counter_out <= (in_valid) ? 0 : counter_out;
        end
    end
end


assign seed_2 = seed_seq ^ (seed_seq << 13);
assign seed_3 = seed_2   ^ (seed_2   >> 17);
assign seed_4 = seed_3   ^ (seed_3   << 5 );

assign rand_num = seed_4;

always @(*) begin
    if((cur_state == OUT) && !fifo_full) begin
        out_valid = (in_valid) ? 0 : 1;
    end 
    else begin
        out_valid = 0;
    end

end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         // out_valid <= 0;
//         rand_num <= 0;
//     end
//     else begin
//         // out_valid <= ((nxt_state == OUT || nxt_state == FULL) && !fifo_full) ? 1 : 0;
//         rand_num <= (nxt_state == OUT) ? seed_4 : rand_num;
//     end

// end

endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;


reg [31:0]rand_num_comb;
reg [31:0]rand_num_seq;
reg out_valid_comb;
reg out_valid_seq;
reg out_valid_seq2;
reg out_valid_seq3;

reg fifo_empty_seq;
reg fifo_empty_seq2;
reg fifo_empty_seq3;


reg [8:0]counter_out;

 

assign fifo_rinc = out_valid_comb;

always @(*) begin
    if(!fifo_empty) begin
        // rand_num_comb = fifo_rdata;
        out_valid_comb = 1;
    end
    else begin
        // rand_num_comb = 0;
        out_valid_comb = 0;
    end


    if(!fifo_empty_seq) begin
        rand_num_comb = fifo_rdata;
    end
    else begin
        rand_num_comb = rand_num_seq;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_empty_seq <= 1;
        fifo_empty_seq2 <= 1;
        fifo_empty_seq3 <= 1;

        rand_num_seq <= 0;
    end
    else begin
        fifo_empty_seq <= fifo_empty;
        fifo_empty_seq2 <= fifo_empty_seq;
        fifo_empty_seq3 <= fifo_empty_seq2;

        rand_num_seq <= rand_num_comb;
    end

end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         out_valid_seq <= 0;
//         out_valid_seq2 <= 0;
//         out_valid_seq3 <= 0;
//         out_valid <= 0;
//         rand_num <= 0;
//     end
//     else begin
//         out_valid_seq <=(counter_out == 258) ? 0 :  out_valid_comb;
//         out_valid_seq2 <=(counter_out == 258) ? 0 :  out_valid_seq;
//         out_valid_seq3 <= (counter_out == 258) ? 0 : out_valid_seq2;
//         out_valid <= (counter_out == 258) ? out_valid_comb : (fifo_empty_seq2) ? 0 : out_valid_seq3;
//         rand_num <=  (counter_out == 258) ? rand_num_comb : (fifo_empty_seq2) ? 0 : rand_num_comb;
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid_seq <= 0;
        out_valid_seq2 <= 0;
        out_valid <= 0;
        // rand_num <= 0;
    end
    else begin
        out_valid_seq <= out_valid_comb;
        out_valid_seq2 <= out_valid_seq;
        out_valid <= (counter_out >= 257) ? 0 : (fifo_empty) ? 0 : out_valid_seq;
        // rand_num <= (counter_out >= 2 && counter_out < 258) ? rand_num_comb : 0;
    end
end

always @(*) begin
    if(counter_out >= 2 && counter_out < 258) begin
        rand_num = (fifo_empty_seq) ? 0 : rand_num_comb;
    end
    else begin
        rand_num = 0;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_out <= 0;
    end
    else begin
        counter_out <= (out_valid_comb) ? counter_out + 1 : (counter_out >= 257) ? 0 : counter_out;
    end
end

endmodule