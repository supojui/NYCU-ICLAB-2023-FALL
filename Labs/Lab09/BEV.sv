module BEV(input clk, INF.BEV_inf inf);
import usertype::*;
// This file contains the definition of several state machines used in the BEV (Beverage) System RTL design.
// The state machines are defined using SystemVerilog enumerated types.
// The state machines are:
// - state_t: used to represent the overall state of the BEV system
//
// Each enumerated type defines a set of named states that the corresponding process can be in.
typedef enum logic [2:0]{
    INPUT,
    READ,
    CAL,
    CAL_2,
    WRITE,
    WAIT_1,
    OUT
} state_t;

// REGISTERS
state_t cur_state, nxt_state;
logic [1:0]act_seq;
logic [2:0]type_seq;
logic [1:0]size_seq;
Date date_seq;
logic [7:0]box_num_seq;
// logic [11:0]black_tea_ing_seq;
// logic [11:0]green_tea_ing_seq;
// logic [11:0]milk_ing_seq;
// logic [11:0]pineapple_juice_ing_seq;

logic [1:0]counter_3;

logic [63:0]C_data_r_seq;
logic [11:0]golden_black_tea;
logic [11:0]golden_green_tea;
logic [11:0]golden_milk;
logic [11:0]golden_pineapple_juice;
logic [4:0] golden_day;
logic [3:0] golden_month;

assign golden_black_tea       = C_data_r_seq[63:52];
assign golden_green_tea       = C_data_r_seq[51:40];
assign golden_milk            = C_data_r_seq[31:20];
assign golden_pineapple_juice = C_data_r_seq[19:8];
assign golden_month           = C_data_r_seq[39:32];
assign golden_day             = C_data_r_seq[7:0];

logic [1:0]golden_err;


logic [9:0]black_tea_need;
logic [9:0]green_tea_need;
logic [9:0]milk_need;
logic [9:0]pineapple_juice_need;


logic [12:0]black_tea_total;
logic [12:0]green_tea_total;
logic [12:0]milk_total;
logic [12:0]pineapple_juice_total;

logic [11:0]black_tea_out;
logic [11:0]green_tea_out;
logic [11:0]milk_out;
logic [11:0]pineapple_juice_out;


// STATE MACHINE
always_comb begin
    case(cur_state)
        INPUT : begin
            if(act_seq == 1) begin
                nxt_state = (inf.box_sup_valid && counter_3 == 3) ? READ : INPUT;
            end
            else begin
                if(inf.box_no_valid) begin
                    nxt_state = READ;
                end
                else begin
                    nxt_state = INPUT;
                end
            end
        end
        READ : begin
            if(inf.C_out_valid) begin
                nxt_state = (act_seq <= 1) ? CAL : WAIT_1;
            end
            else begin
                nxt_state = READ;
            end
        end
        CAL : begin
            nxt_state = (golden_err == 2'b10 || golden_err == 2'b01) ? OUT : CAL_2;
        end
        CAL_2 : begin
            nxt_state = WRITE;
        end
        WRITE : begin
            if(inf.C_out_valid) begin
                nxt_state = OUT;
            end
            else begin
                nxt_state = WRITE;
            end
        end
        WAIT_1 : begin
            nxt_state = OUT;
        end
        OUT : begin
            nxt_state = INPUT;
        end
        default : nxt_state = INPUT;
    endcase
end

always_ff @( posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_state <= INPUT;
    end
    else begin
        cur_state <= nxt_state;
    end
end


////////////////////////////////////////
//////////////input save////////////////
////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        counter_3 <= 0;
    end
    else begin
        if(inf.box_sup_valid) counter_3 <= counter_3 + 1;
        else counter_3 <= counter_3;
    end

end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        act_seq                 <= 0;
        type_seq                <= 0;
        size_seq                <= 0;
        date_seq                <= 0;
        box_num_seq             <= 0;
        // black_tea_ing_seq       <= 0;
        // green_tea_ing_seq       <= 0;
        // milk_ing_seq            <= 0;
        // pineapple_juice_ing_seq <= 0;
    end
    else begin
        if(inf.sel_action_valid)                   act_seq                 <= inf.D.d_act[0];
        if(inf.type_valid)                         type_seq                <= inf.D.d_type[0];
        if(inf.size_valid)                         size_seq                <= inf.D.d_size[0];
        if(inf.date_valid)                         date_seq                <= inf.D.d_date[0];
        if(inf.box_no_valid)                       box_num_seq             <= inf.D.d_box_no[0];
        // if(inf.box_sup_valid && counter_3 == 0)    black_tea_ing_seq       <= inf.D.d_ing[0];
        // if(inf.box_sup_valid && counter_3 == 1)    green_tea_ing_seq       <= inf.D.d_ing[0];
        // if(inf.box_sup_valid && counter_3 == 2)    milk_ing_seq            <= inf.D.d_ing[0];
        // if(inf.box_sup_valid && counter_3 == 3)    pineapple_juice_ing_seq <= inf.D.d_ing[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        C_data_r_seq <= 0;
    end
    else begin
        if(inf.C_out_valid) C_data_r_seq <= inf.C_data_r;
        else C_data_r_seq <= C_data_r_seq;
    end

end

////////////////////////////////////////
///////////////////CAL//////////////////
////////////////////////////////////////
logic [12:0]black_tea_in;
logic [12:0]green_tea_in;
logic [12:0]milk_in;
logic [12:0]pineapple_juice_in;
logic [4:0] day_in;
logic [3:0] month_in;

// assign black_tea_in       = (act_seq == 0) ? -black_tea_need : black_tea_ing_seq;
// assign green_tea_in       = (act_seq == 0) ? -green_tea_need : green_tea_ing_seq;
// assign milk_in            = (act_seq == 0) ? -milk_need : milk_ing_seq;
// assign pineapple_juice_in = (act_seq == 0) ? -pineapple_juice_need : pineapple_juice_ing_seq;
// assign day_in             = (act_seq == 0) ? golden_day : date_seq.D;
// assign month_in           = (act_seq == 0) ? golden_month : date_seq.M;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        black_tea_in       <= 0;
        green_tea_in       <= 0;
        milk_in            <= 0;
        pineapple_juice_in <= 0;
        day_in             <= 0;
        month_in           <= 0;
    end
    else begin
        if(act_seq == 0) begin
            black_tea_in       <= -black_tea_need;
            green_tea_in       <= -green_tea_need;
            milk_in            <= -milk_need;
            pineapple_juice_in <= -pineapple_juice_need;
            day_in             <= golden_day;
            month_in           <= golden_month;
        end
        else begin
            if(inf.box_sup_valid && counter_3 == 0)    black_tea_in       <= inf.D.d_ing[0];
            if(inf.box_sup_valid && counter_3 == 1)    green_tea_in       <= inf.D.d_ing[0];
            if(inf.box_sup_valid && counter_3 == 2)    milk_in            <= inf.D.d_ing[0];
            if(inf.box_sup_valid && counter_3 == 3)    pineapple_juice_in <= inf.D.d_ing[0];
            // black_tea_in       <= black_tea_ing_seq;
            // green_tea_in       <= green_tea_ing_seq;
            // milk_in            <= milk_ing_seq;
            // pineapple_juice_in <= pineapple_juice_ing_seq;
            day_in             <= date_seq.D;
            month_in           <= date_seq.M;
        end
    end

end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        black_tea_total       <= 0;
        green_tea_total       <= 0;
        milk_total            <= 0;
        pineapple_juice_total <= 0;
    end
    else begin
        black_tea_total       <= black_tea_in       + golden_black_tea;
        green_tea_total       <= green_tea_in       + golden_green_tea;
        milk_total            <= milk_in            + golden_milk;
        pineapple_juice_total <= pineapple_juice_in + golden_pineapple_juice;
    end

end

assign black_tea_out       = (black_tea_total[12])       ? 4095 : black_tea_total;
assign green_tea_out       = (green_tea_total[12])       ? 4095 : green_tea_total;
assign milk_out            = (milk_total[12])            ? 4095 : milk_total;
assign pineapple_juice_out = (pineapple_juice_total[12]) ? 4095 : pineapple_juice_total;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        black_tea_need       <= 0;
        green_tea_need       <= 0;
        milk_need            <= 0;
        pineapple_juice_need <= 0;
    end
    else begin
        black_tea_need       <= 0;
        green_tea_need       <= 0;
        milk_need            <= 0;
        pineapple_juice_need <= 0;
        case(type_seq)
            0 : begin
                black_tea_need <= (size_seq == 0) ? 960 : (size_seq == 1) ? 720 : 480;
            end
            1 : begin
                black_tea_need <= (size_seq == 0) ? 720 : (size_seq == 1) ? 540 : 360;
                milk_need      <= (size_seq == 0) ? 240 : (size_seq == 1) ? 180 : 120;
            end
            2 : begin
                black_tea_need <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
                milk_need      <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
            end
            3 : begin
                green_tea_need <= (size_seq == 0) ? 960 : (size_seq == 1) ? 720 : 480;
            end
            4 : begin
                green_tea_need <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
                milk_need      <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
            end
            5 : begin
                pineapple_juice_need <= (size_seq == 0) ? 960 : (size_seq == 1) ? 720 : 480;
            end
            6 : begin
                black_tea_need       <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
                pineapple_juice_need <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
            end
            7 : begin
                black_tea_need       <= (size_seq == 0) ? 480 : (size_seq == 1) ? 360 : 240;
                milk_need            <= (size_seq == 0) ? 240 : (size_seq == 1) ? 180 : 120;
                pineapple_juice_need <= (size_seq == 0) ? 240 : (size_seq == 1) ? 180 : 120;
            end
        endcase
    end
end


always_comb begin
    case(act_seq)
        0 : begin
            if(date_seq.M > golden_month || (date_seq.M == golden_month && date_seq.D > golden_day)) begin
                golden_err = 2'b01;
            end
            else if(black_tea_need > golden_black_tea || green_tea_need > golden_green_tea || milk_need > golden_milk || pineapple_juice_need > golden_pineapple_juice) begin
                golden_err = 2'b10;
            end
            else begin
                golden_err = 2'b00;
            end
        end
        1 : begin
            if(black_tea_total[12] || green_tea_total[12] || milk_total[12] || pineapple_juice_total[12]) begin //may be changed to [12]
                golden_err = 2'b11;
            end
            else begin
                golden_err = 2'b00;
            end
        end
        2 : begin
            if(date_seq.M > golden_month || (date_seq.M == golden_month && date_seq.D > golden_day)) begin
                golden_err = 2'b01;
            end
            else begin
                golden_err = 2'b00;
            end
        end
        default : golden_err = 2'b00;
    endcase
end


////////////////////////////////////////
/////////////////output/////////////////
////////////////////////////////////////

assign inf.C_addr = box_num_seq;

assign inf.C_data_w = {black_tea_out, green_tea_out, 4'b0000, month_in, milk_out, pineapple_juice_out, 3'b000, day_in};

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        // inf.C_data_w <= 0;
        inf.C_in_valid <= 0;
        inf.C_r_wb <= 0;
    end
    else begin
        if(cur_state != READ && nxt_state == READ) begin
            // inf.C_data_w <= inf.C_data_w;
            inf.C_in_valid <= 1;
            inf.C_r_wb <= 1;
        end
        else if(cur_state != WRITE && nxt_state == WRITE) begin
            // inf.C_data_w <= {black_tea_out, green_tea_out, 4'b0000, month_in, milk_out, pineapple_juice_out, 3'b000, day_in};
            inf.C_in_valid <= 1;
            inf.C_r_wb <= 0;
        end
        else begin
            // inf.C_data_w <= inf.C_data_w;
            inf.C_in_valid <= 0;
            inf.C_r_wb <= 0;
        end
    end

end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.out_valid <= 0;
        inf.err_msg <= 0;
        inf.complete <= 0;
    end
    else begin
        inf.out_valid <= (nxt_state == OUT) ? 1 : 0;
        inf.err_msg <= (nxt_state == OUT) ? golden_err : 0;
        inf.complete <= (nxt_state == OUT && golden_err == 2'b00) ? 1 : 0;
    end

end

endmodule