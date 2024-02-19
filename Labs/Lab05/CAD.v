module CAD(
    clk, 
    rst_n,
    in_valid,
    in_valid2,
    matrix_size,
    matrix,
    matrix_idx,
    mode,

    out_valid,
    out_value

);

input clk, rst_n, in_valid, in_valid2;
input [1:0]matrix_size;
input [7:0]matrix;
input [3:0]matrix_idx;
input mode;

output reg out_valid, out_value;

parameter IDLE = 0;
parameter INPUT_IMAGE = 1;
parameter INPUT_KERNEL = 2;
parameter INPUT_INDEX = 3;
parameter CAL_CONV = 4;
parameter MAX_POOLING = 5;
parameter CAL_DECONV = 6;
parameter DECONV_OUT = 7;


reg [9:0]counter_address_image;
reg [9:0]counter_address_kernel;
reg [9:0]counter_address_image_seq;
reg [9:0]counter_address_kernel_seq;
wire [9:0]address_image;
wire [9:0]address_kernel;


reg [9:0]counter_1024;
reg [9:0]counter_kernel_comb;
reg [9:0]counter_kernel_seq;
reg [9:0]counter_image_comb;
reg [9:0]counter_image_seq;
reg [3:0]counter_16; // count which image memory is writing
reg [4:0]counter_25;

reg [2:0]counter_5;  // count if address needs to change line
reg [4:0]counter_shift_r;  // count if address needs to change line
reg [5:0]counter_shift_d;  // count if address needs to change line
reg [5:0]counter_new_line;  // count if address needs to change line


reg [10:0]counter_output_address_comb;
reg [10:0]counter_output_address_seq;


reg [4:0]cur_state;
reg [4:0]nxt_state;
reg [1:0]matrix_size_seq;
reg [4:0]output_matrix_size; // the size of convolution ouput i.e. 4, 12, 28
reg [5:0]golden_matrix_size;

reg signed [7:0]memory_32[0:15];
reg signed [7:0]memory_32_seq;
reg signed [7:0]image_out[0:4][0:4];

reg signed [7:0]kernel;
reg signed [7:0]kernel_seq;
reg signed [7:0]kernel_out[0:4][0:4];

reg [15:0]WEB_m_32;

reg WEB_kernel;

reg [3:0]image_idx_seq;
reg [3:0]kernel_idx_seq;
reg mode_seq;

reg [4:0]counter_out_20;
reg [10:0]stop_address;



reg counter_2;
reg counter_out_shift_r;
reg [5:0]counter_out_shift_d;
reg [5:0]counter_out_new_line;
reg signed [19:0]output_port_a_seq;
reg signed [19:0]output_port_b_seq;
reg [4:0]counter_out_16;

reg [10:0]counter_forever;

reg [4:0]counter_25_delay_2;


reg signed [19:0]conv_comb;
reg signed [19:0]conv_seq;

reg signed [19:0]output_port_a;
reg signed [19:0]output_port_b;
reg WEB_out_a;
reg WEB_out_b;



reg [10:0]counter_output_address_seq_d1;
reg [10:0]counter_output_address_seq_d2;
reg [10:0]output_address_a;
reg [10:0]output_address_a_d1;
reg [10:0]output_address_b;




reg signed [7:0]deconv_kernel;
reg signed [7:0]deconv_image;
reg signed [19:0]deconv_out_comb;


reg [5:0]deconv_matrix_size;
reg [10:0]deconv_matrix_size_total;
reg [4:0]deconv_counter20;
reg [10:0]deconv_counter_output_address;
reg [10:0]deconv_counter_output_address_d1;
reg [10:0]deconv_counter_output_address_d2;
reg [10:0]deconv_counter_output_address_d3;


reg out_valid_comb;
wire signed [19:0]out_golden_comb;
reg  signed [19:0]out_golden_seq;


integer i, j;

genvar a;
generate
    for(a = 0; a < 16; a = a + 1) begin
        memory_32_32 m_32_0(.A0(address_image[0]),.A1(address_image[1]),.A2(address_image[2]),.A3(address_image[3]),.A4(address_image[4]),.A5(address_image[5]),
                            .A6(address_image[6]),.A7(address_image[7]),.A8(address_image[8]),.A9(address_image[9]),
                            .DO0(memory_32[a][0]),.DO1(memory_32[a][1]),.DO2(memory_32[a][2]),.DO3(memory_32[a][3]),.DO4(memory_32[a][4]),.DO5(memory_32[a][5]),
                            .DO6(memory_32[a][6]),.DO7(memory_32[a][7]),
                            .DI0(matrix[0]),.DI1(matrix[1]),.DI2(matrix[2]),.DI3(matrix[3]),.DI4(matrix[4]),
                            .DI5(matrix[5]),.DI6(matrix[6]),.DI7(matrix[7]),
                            .CK(clk),.WEB(WEB_m_32[a]),.OE(1'b1),.CS(1'b1));
    end 
endgenerate
   

memory_400 m_kernel( .A0(address_kernel[0]),.A1(address_kernel[1]),.A2(address_kernel[2]),.A3(address_kernel[3]),.A4(address_kernel[4]),.A5(address_kernel[5]),
                     .A6(address_kernel[6]),.A7(address_kernel[7]),.A8(address_kernel[8]),
                     .DO0(kernel[0]),.DO1(kernel[1]),.DO2(kernel[2]),.DO3(kernel[3]),.DO4(kernel[4]),.DO5(kernel[5]),
                     .DO6(kernel[6]),.DO7(kernel[7]),
                     .DI0(matrix[0]),.DI1(matrix[1]),.DI2(matrix[2]),.DI3(matrix[3]),.DI4(matrix[4]),
                     .DI5(matrix[5]),.DI6(matrix[6]),.DI7(matrix[7]),
                     .CK(clk),.WEB(WEB_kernel),.OE(1'b1),.CS(1'b1));    

assign address_image = (cur_state == CAL_DECONV) ? counter_address_image_seq : counter_address_image;
assign address_kernel = (cur_state == CAL_DECONV) ? counter_address_kernel_seq : counter_address_kernel;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_address_image_seq <= 0;
        counter_address_kernel_seq <= 0;
    end
    else begin
        counter_address_image_seq <= counter_address_image;
        counter_address_kernel_seq <= counter_address_kernel;
    end

end


always @(*) begin
    if(cur_state == CAL_CONV || cur_state == CAL_DECONV) begin
        counter_address_image = counter_image_seq;
    end
    else begin
        counter_address_image = counter_1024;
    end
end

always @(*) begin
    if(cur_state == CAL_CONV || cur_state == CAL_DECONV) begin
        counter_address_kernel = counter_kernel_seq;
    end
    else begin
        if(cur_state == INPUT_IMAGE) begin
            counter_address_kernel = 0;
        end
        else begin
            counter_address_kernel = counter_1024;
        end
    end
end


/////////////////////////////
////////state control////////
/////////////////////////////


always @(*) begin
    if(cur_state == IDLE) begin
        if(in_valid) begin
            nxt_state = INPUT_IMAGE;
        end
        else if(in_valid2) begin
            nxt_state = INPUT_INDEX;
        end
        else begin
            nxt_state = IDLE;
        end
    end
    else if(cur_state == INPUT_IMAGE)begin
        case(matrix_size_seq)
            2'd0 : begin
                if(counter_1024 == 63 && counter_16 == 15) begin
                    nxt_state = INPUT_KERNEL;
                end
                else begin
                    nxt_state = INPUT_IMAGE;
                end
            end
            2'd1 : begin
                if(counter_1024 == 255 && counter_16 == 15) begin
                    nxt_state = INPUT_KERNEL;
                end
                else begin
                    nxt_state = INPUT_IMAGE;
                end
            end
            2'd2 : begin
                if(counter_1024 == 1023 && counter_16 == 15) begin
                    nxt_state = INPUT_KERNEL;
                end
                else begin
                    nxt_state = INPUT_IMAGE;
                end
            end
            default : begin
                nxt_state = INPUT_IMAGE;
            end
        endcase
    end
    else if(cur_state == INPUT_KERNEL) begin
        if(counter_1024 == 399) begin
            nxt_state = INPUT_INDEX;
        end
        else begin
            nxt_state = INPUT_KERNEL;
        end
    end
    else if(cur_state == INPUT_INDEX) begin
        if(counter_16 == 2 && mode_seq == 0) begin
            nxt_state = CAL_CONV;
        end
        else if(counter_16 == 2 && mode_seq == 1) begin
            nxt_state = CAL_DECONV;
        end
        else begin
            nxt_state = INPUT_INDEX;
        end
    end

    else if(cur_state == CAL_CONV) begin
        if(counter_new_line == output_matrix_size && counter_shift_d == 0 && counter_shift_r == 0 && counter_5 == 2) begin
            nxt_state = MAX_POOLING;
        end
        else begin
            nxt_state = CAL_CONV;
        end
    end

    else if(cur_state == MAX_POOLING) begin
        if(counter_output_address_seq == stop_address && counter_out_20 == 25) begin
            nxt_state = IDLE;
        end
        else begin
            nxt_state = MAX_POOLING;
        end
    end
/////////////////////////
    else if(cur_state == CAL_DECONV) begin
        if(counter_new_line == deconv_matrix_size-4 && counter_shift_d == 0 && counter_shift_r == 0 && counter_5 == 3) begin
            nxt_state = DECONV_OUT;
        end
        else begin
            nxt_state = CAL_DECONV;
        end
    end

    else if(cur_state == DECONV_OUT) begin
        if(deconv_counter_output_address_d3 == deconv_matrix_size_total && deconv_counter20 == 2) begin
            nxt_state = IDLE;
        end
        else begin 
            nxt_state = DECONV_OUT;
        end
    end
/////////////////////////
    else begin
        nxt_state = IDLE;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= 0;
        matrix_size_seq <= 0;
    end
    else begin
        cur_state <= nxt_state;
        if(in_valid && cur_state == IDLE) begin
            matrix_size_seq <= matrix_size;
        end
        else begin
            matrix_size_seq <= matrix_size_seq;
        end
    end
end

/////////////////////////////
/////////////////////////////
/////////////////////////////



/////////////////////////////
//////counter for input//////
/////////////////////////////


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_1024 <= 0;
        counter_16 <= 0;
    end
    else begin
        if(nxt_state == INPUT_IMAGE) begin
            case(matrix_size_seq)
                2'd0 : begin
                    if(counter_1024 == 63) begin
                        counter_16 <= counter_16 + 1;
                        counter_1024 <= 0;
                    end
                    else begin
                        counter_16 <= counter_16;
                        counter_1024 <= counter_1024 + 1;
                    end
                end
                2'd1 : begin
                    if(counter_1024 == 255) begin
                        counter_16 <= counter_16 + 1;
                        counter_1024 <= 0;
                    end
                    else begin
                        counter_16 <= counter_16;
                        counter_1024 <= counter_1024 + 1;
                    end
                end
                2'd2 : begin
                    if(counter_1024 == 1023) begin
                        counter_16 <= counter_16 + 1;
                        counter_1024 <= 0;
                    end
                    else begin
                        counter_16 <= counter_16;
                        counter_1024 <= counter_1024 + 1;
                    end
                end
            endcase
        end
        else if(nxt_state == INPUT_KERNEL) begin
            if(counter_1024 < 399 && cur_state == INPUT_KERNEL) begin
                counter_1024 <= counter_1024 + 1; 
            end
            else begin
                counter_1024 <= 0;
            end
        end
        else if(nxt_state == INPUT_INDEX) begin
            counter_1024 <= 0;
            if(in_valid2) begin
                counter_16 <= counter_16 + 1;
            end
            else begin
                counter_16 <= 0;
            end
        end
        else begin
            counter_1024 <= 0;
            counter_16 <= 0;
        end
    end
end

/////////////////////////////
/////////////////////////////
/////////////////////////////


/////////////////////////////
////////counter address//////
/////////////////////////////


always @(*) begin
    case(matrix_size_seq) 
        2'd0 : output_matrix_size = 4;
        2'd1 : output_matrix_size = 12;
        2'd2 : output_matrix_size = 28;
        default : output_matrix_size = 0;
    endcase

end

always @(*) begin
    case(matrix_size_seq) 
        2'd0 : golden_matrix_size = 8;
        2'd1 : golden_matrix_size = 16;
        2'd2 : golden_matrix_size = 32;
        default : golden_matrix_size = 0;
    endcase

end

//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////

always @(*) begin
    if(cur_state == CAL_CONV) begin
        counter_image_comb = counter_5 + counter_shift_d + counter_shift_r*golden_matrix_size + counter_new_line*golden_matrix_size;
    end
    else if(cur_state == CAL_DECONV) begin
        if(counter_25_delay_2 == 23) begin
            counter_image_comb = counter_image_seq + 1;
        end
        else begin
            counter_image_comb = counter_image_seq;
        end
    end
    else begin
        counter_image_comb = 0;
    end

end
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_5 <= 0;
        counter_shift_r <= 0;
        counter_shift_d <= 0;
        counter_new_line <= 0;
    end
    else begin
        if(cur_state == CAL_CONV) begin
            if(counter_5 == 4) begin
                counter_5 <= 0;
                if(counter_shift_r == 4) begin
                    counter_shift_r <= 0;

                    if(counter_shift_d == output_matrix_size-1) begin
                        counter_shift_d <= 0;
                        
                        counter_new_line <= counter_new_line + 1;
                    end
                    else begin
                        counter_shift_d <= counter_shift_d + 1;

                        counter_new_line <= counter_new_line;
                    end
                end
                else begin
                    counter_shift_r <= counter_shift_r + 1;

                    counter_shift_d <= counter_shift_d;

                    counter_new_line <= counter_new_line;
                end
            end
            else begin
                counter_5 <= counter_5 + 1;
                counter_shift_r <= counter_shift_r;
                counter_shift_d <= counter_shift_d;
                counter_new_line <= counter_new_line;
            end
        end
        else if(cur_state == CAL_DECONV) begin
            if(counter_5 == 4) begin
                counter_5 <= 0;
                if(counter_shift_r == 4) begin
                    counter_shift_r <= 0;

                    if(counter_shift_d == deconv_matrix_size-5) begin
                        counter_shift_d <= 0;
                        
                        counter_new_line <= counter_new_line + 1;
                    end
                    else begin
                        counter_shift_d <= counter_shift_d + 1;

                        counter_new_line <= counter_new_line;
                    end
                end
                else begin
                    counter_shift_r <= counter_shift_r + 1;

                    counter_shift_d <= counter_shift_d;

                    counter_new_line <= counter_new_line;
                end
            end
            else begin
                counter_5 <= counter_5 + 1;
                counter_shift_r <= counter_shift_r;
                counter_shift_d <= counter_shift_d;
                counter_new_line <= counter_new_line;
            end
        end
        else begin
            counter_5 <= 0;
            counter_shift_r <= 0;
            counter_shift_d <= 0;
            counter_new_line <= 0;
        end
    end

end 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_25 <= 0;
    end    
    else begin
        if(counter_shift_d >= 1 || counter_new_line >= 1)begin
            counter_25 <= 0;
            if(counter_shift_r >= 1 || (counter_5 >= 1 && counter_shift_r == 0 && counter_shift_d == 0 && counter_new_line == 0)) begin
                counter_25 <= counter_25 + 1;
            end
        end
        else begin
            counter_25 <= 0;
        end
    end
end


always @(*) begin
    if(counter_shift_d >= 1 || counter_new_line >= 1 || counter_shift_r >= 1 || (counter_5 >= 1 && counter_shift_r == 0 && counter_shift_d == 0 && counter_new_line == 0)) begin
        counter_kernel_comb = counter_kernel_seq + 1;
        if(counter_5 == 0 && counter_shift_r == 0) begin
            case(kernel_idx_seq)
            0  : counter_kernel_comb = 0;
            1  : counter_kernel_comb = 25;
            2  : counter_kernel_comb = 50;
            3  : counter_kernel_comb = 75;
            4  : counter_kernel_comb = 100;
            5  : counter_kernel_comb = 125;
            6  : counter_kernel_comb = 150;
            7  : counter_kernel_comb = 175;
            8  : counter_kernel_comb = 200;
            9  : counter_kernel_comb = 225;
            10 : counter_kernel_comb = 250;
            11 : counter_kernel_comb = 275;
            12 : counter_kernel_comb = 300;
            13 : counter_kernel_comb = 325;
            14 : counter_kernel_comb = 350;
            15 : counter_kernel_comb = 375;
            default : counter_kernel_comb = counter_kernel_seq;
            endcase
        end
    end
    else begin
        case(kernel_idx_seq)
            0  : counter_kernel_comb = 0;
            1  : counter_kernel_comb = 25;
            2  : counter_kernel_comb = 50;
            3  : counter_kernel_comb = 75;
            4  : counter_kernel_comb = 100;
            5  : counter_kernel_comb = 125;
            6  : counter_kernel_comb = 150;
            7  : counter_kernel_comb = 175;
            8  : counter_kernel_comb = 200;
            9  : counter_kernel_comb = 225;
            10 : counter_kernel_comb = 250;
            11 : counter_kernel_comb = 275;
            12 : counter_kernel_comb = 300;
            13 : counter_kernel_comb = 325;
            14 : counter_kernel_comb = 350;
            15 : counter_kernel_comb = 375;
            default : counter_kernel_comb = counter_kernel_seq;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_image_seq <= 0;
    end
    else begin
        counter_image_seq <= counter_image_comb;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_kernel_seq <= 0;
    end
    else begin
        counter_kernel_seq <= counter_kernel_comb;
    end

end
/////////////////////////////
/////////////////////////////
/////////////////////////////


/////////////////////////////
//////////Convolution////////
/////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_25_delay_2 <= 0;
    end    
    else begin
        if(counter_25_delay_2 == 25)begin
            counter_25_delay_2 <= 1;
        end
        else if(counter_shift_r >= 1|| counter_shift_d >= 1 || counter_new_line >= 1 || (counter_5 >= 2 && counter_shift_r == 0 && counter_shift_d == 0 && counter_new_line == 0)) begin
            counter_25_delay_2 <= counter_25_delay_2 + 1;
        end
        else begin
            counter_25_delay_2 <= 0;
        end
    end
end


always @(*) begin
    if(cur_state == INPUT_IMAGE || cur_state == INPUT_KERNEL) begin
        conv_comb = 0;
    end
    else if(cur_state == CAL_DECONV) begin
        conv_comb = deconv_out_comb;
    end 
    else if(cur_state == IDLE) begin
        conv_comb = 0;
    end
    else begin
        conv_comb = (counter_25_delay_2 >= 1) ? conv_seq + memory_32_seq * kernel_seq : memory_32_seq * kernel_seq;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        conv_seq <= 0;
    end
    else begin
        if(counter_5 <= 2 && counter_shift_r == 0 && counter_shift_d == 0 && counter_new_line == 0) begin
            conv_seq <= 0;
        end
        else begin
            conv_seq <= (counter_25_delay_2 == 25) ? 0 : conv_comb;
        end
    end
end


////port a for write////
////post b for read/////

always @(*) begin
    if(counter_25_delay_2 == 25 && cur_state == CAL_CONV) begin
        WEB_out_a = 0;
    end
    else if(cur_state == CAL_DECONV && output_address_a != output_address_b) begin
        WEB_out_a = 0;
    end
    else if(cur_state == INPUT_IMAGE || cur_state == INPUT_KERNEL) begin
        WEB_out_a = 0;
    end
    else if(cur_state == DECONV_OUT || cur_state == IDLE) begin
        if(output_address_a != output_address_b && counter_5 != 4) begin
            WEB_out_a = 0;
        end
        else begin
            WEB_out_a = 1;
        end
    end
    else begin
        WEB_out_a = 1;
    end

    
    if((counter_out_16 <= 6 && counter_out_16 >= 3) && cur_state == MAX_POOLING) begin
        WEB_out_b = 0;
    end
    else begin
        WEB_out_b = 1;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_forever <= 0;
    end
    else begin
        if(counter_forever != 1295) begin
            counter_forever <= counter_forever + 1;
        end
        else begin
            counter_forever <= 0;
        end
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        deconv_counter_output_address_d1 <= 0;
        deconv_counter_output_address_d2 <= 0;
        deconv_counter_output_address_d3 <= 0;
        output_address_a_d1 <= 0;
    end
    else begin
        deconv_counter_output_address_d1 <= deconv_counter_output_address;
        deconv_counter_output_address_d2 <= deconv_counter_output_address_d1;
        deconv_counter_output_address_d3 <= deconv_counter_output_address_d2;
        output_address_a_d1 <= output_address_a;
    end
end


// always @(*) begin
//     if(cur_state == INPUT_IMAGE || cur_state == INPUT_KERNEL) begin
//         output_address_a = counter_forever;
//     end
//     else if(cur_state == CAL_CONV) begin
//         output_address_a = counter_output_address_seq;
//     end
//     else if(cur_state == DECONV_OUT || cur_state == IDLE) begin
//         output_address_a = deconv_counter_output_address_d1;
//     end
//     else if(cur_state == MAX_POOLING) begin
//         output_address_a = (counter_out_16 <= 3) ? counter_output_address_seq_d2 : 0;
//     end
//     else begin
//         output_address_a = counter_output_address_seq_d2;
//     end

// end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        output_address_a <= 0;
    end
    else begin
        if(cur_state == INPUT_IMAGE || cur_state == INPUT_KERNEL) begin
            output_address_a <= counter_forever;
        end
        else if(cur_state == CAL_CONV) begin
            output_address_a <= counter_output_address_seq;
        end
        else if(cur_state == DECONV_OUT || cur_state == IDLE) begin
            output_address_a <= deconv_counter_output_address_d1;
        end
        else if(cur_state == MAX_POOLING) begin
            output_address_a <= (counter_out_16 <= 3) ? counter_output_address_seq_d2 : 0;
        end
        else begin
            output_address_a <= counter_output_address_seq_d2;
        end
    end
end

// always @(*) begin
//     if(cur_state == DECONV_OUT) begin
//         output_address_b = deconv_counter_output_address;
//     end
//     else if(cur_state == INPUT_IMAGE || cur_state == INPUT_KERNEL) begin
//         output_address_b = (counter_forever == 1295) ? 0 : counter_forever + 1;
//     end
//     else if(cur_state == CAL_CONV) begin
//         output_address_b = counter_output_address_seq + 1;
//     end
//     else if(cur_state == MAX_POOLING) begin
//         output_address_b = output_address_a_d1;
//     end
//     else begin
//         output_address_b = counter_output_address_seq;
//     end

// end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        output_address_b <= 0;
    end
    else begin
        if(nxt_state == DECONV_OUT) begin
            output_address_b <= deconv_counter_output_address;
        end
        else if(nxt_state == INPUT_IMAGE || nxt_state == INPUT_KERNEL) begin
            output_address_b <= (counter_forever == 1295) ? 0 : counter_forever + 1;
        end
        else if(nxt_state == CAL_CONV) begin
            output_address_b <= counter_output_address_seq + 1;
        end
        else if(nxt_state == MAX_POOLING) begin
            output_address_b <= output_address_a_d1;
        end
        else begin
            output_address_b <= counter_output_address_seq;
        end
    end
end


memory_36_36 m_out(  .A0(output_address_a[0]),.A1(output_address_a[1]),
                     .A2(output_address_a[2]),.A3(output_address_a[3]),
                     .A4(output_address_a[4]),.A5(output_address_a[5]),
                     .A6(output_address_a[6]),.A7(output_address_a[7]),
                     .A8(output_address_a[8]),.A9(output_address_a[9]),
                     .A10(output_address_a[10]),

                     .B0(output_address_b[0]),.B1(output_address_b[1]),
                     .B2(output_address_b[2]),.B3(output_address_b[3]),
                     .B4(output_address_b[4]),.B5(output_address_b[5]),
                     .B6(output_address_b[6]),.B7(output_address_b[7]),
                     .B8(output_address_b[8]),.B9(output_address_b[9]),
                     .B10(output_address_b[10]),

                     .DOA0(output_port_a[0]),.DOA1(output_port_a[1]),.DOA2(output_port_a[2]),
                     .DOA3(output_port_a[3]),.DOA4(output_port_a[4]),.DOA5(output_port_a[5]),
                     .DOA6(output_port_a[6]),.DOA7(output_port_a[7]),.DOA8(output_port_a[8]),
                     .DOA9(output_port_a[9]),.DOA10(output_port_a[10]),.DOA11(output_port_a[11]),
                     .DOA12(output_port_a[12]),.DOA13(output_port_a[13]),.DOA14(output_port_a[14]),
                     .DOA15(output_port_a[15]),.DOA16(output_port_a[16]),.DOA17(output_port_a[17]),
                     .DOA18(output_port_a[18]),.DOA19(output_port_a[19]),

                     .DOB0(output_port_b[0]),.DOB1(output_port_b[1]),.DOB2(output_port_b[2]),
                     .DOB3(output_port_b[3]),.DOB4(output_port_b[4]),.DOB5(output_port_b[5]),
                     .DOB6(output_port_b[6]),.DOB7(output_port_b[7]),.DOB8(output_port_b[8]),
                     .DOB9(output_port_b[9]),.DOB10(output_port_b[10]),.DOB11(output_port_b[11]),
                     .DOB12(output_port_b[12]),.DOB13(output_port_b[13]),.DOB14(output_port_b[14]),
                     .DOB15(output_port_b[15]),.DOB16(output_port_b[16]),.DOB17(output_port_b[17]),
                     .DOB18(output_port_b[18]),.DOB19(output_port_b[19]),

                     .DIA0(conv_comb[0]),.DIA1(conv_comb[1]),.DIA2(conv_comb[2]),.DIA3(conv_comb[3]),
                     .DIA4(conv_comb[4]),.DIA5(conv_comb[5]),.DIA6(conv_comb[6]),.DIA7(conv_comb[7]),
                     .DIA8(conv_comb[8]),.DIA9(conv_comb[9]),.DIA10(conv_comb[10]),.DIA11(conv_comb[11]),
                     .DIA12(conv_comb[12]),.DIA13(conv_comb[13]),.DIA14(conv_comb[14]),.DIA15(conv_comb[15]),
                     .DIA16(conv_comb[16]),.DIA17(conv_comb[17]),.DIA18(conv_comb[18]),.DIA19(conv_comb[19]),

                     .DIB0(conv_comb[0]),.DIB1(conv_comb[1]),.DIB2(conv_comb[2]),.DIB3(conv_comb[3]),
                     .DIB4(conv_comb[4]),.DIB5(conv_comb[5]),.DIB6(conv_comb[6]),.DIB7(conv_comb[7]),
                     .DIB8(conv_comb[8]),.DIB9(conv_comb[9]),.DIB10(conv_comb[10]),.DIB11(conv_comb[11]),
                     .DIB12(conv_comb[12]),.DIB13(conv_comb[13]),.DIB14(conv_comb[14]),.DIB15(conv_comb[15]),
                     .DIB16(conv_comb[16]),.DIB17(conv_comb[17]),.DIB18(conv_comb[18]),
                     .DIB19(conv_comb[19]),
                     .WEAN(WEB_out_a),.WEBN(WEB_out_b),
                     .CKA(clk),.CKB(clk),
                     .CSA(1'b1),.CSB(1'b1),
                     .OEA(1'b1),.OEB(1'b1));


/////////////////////////////
/////////////////////////////
/////////////////////////////


/////////////////////////////
//////////Max pooling////////
/////////////////////////////



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_out_16 <= 0;
    end
    else begin
        if(counter_2 == 1 && counter_out_shift_r == 1) begin
            if(counter_out_16 == 16) begin
                counter_out_16 <= 0;                
            end
            else begin
                counter_out_16 <= counter_out_16 + 1;
            end
        end
        else begin
            counter_out_16 <= 0;
        end
    end
end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_2 <= 0;
        counter_out_shift_r <= 0;
        counter_out_shift_d <= 0;
        counter_out_new_line <= 0;
    end
    else begin
        if(cur_state == MAX_POOLING || cur_state == CAL_DECONV) begin
            if(counter_2 == 1) begin
                if(counter_out_shift_r == 1) begin
                    if(counter_out_16 != 16) begin
                        counter_2 <= counter_2;

                        counter_out_shift_r <= counter_out_shift_r;

                        counter_out_shift_d <= counter_out_shift_d;

                        counter_out_new_line <= counter_out_new_line;
                    end
                    else begin
                        counter_2 <= 0;

                        counter_out_shift_r <= 0;

                        if(counter_out_shift_d == output_matrix_size - 2) begin
                            counter_out_shift_d <= 0;
                            
                            counter_out_new_line <= counter_out_new_line + 2;
                        end
                        else begin
                            counter_out_shift_d <= counter_out_shift_d + 2;

                            counter_out_new_line <= counter_out_new_line;
                        end
                    end
                end
                else begin
                    counter_2 <= 0;

                    counter_out_shift_r <= ~counter_out_shift_r;

                    counter_out_shift_d <= counter_out_shift_d;

                    counter_out_new_line <= counter_out_new_line;
                end
            end
            else begin
                counter_2 <= ~counter_2;
                counter_out_shift_r <= counter_out_shift_r;
                counter_out_shift_d <= counter_out_shift_d;
                counter_out_new_line <= counter_out_new_line;
            end
        end
        else begin
            counter_2 <= 0;
            counter_out_shift_r <= 0;
            counter_out_shift_d <= 0;
            counter_out_new_line <= 0;
        end
    end
end 

always @(*) begin
    if(counter_25_delay_2 == 25 && nxt_state != MAX_POOLING) begin
        counter_output_address_comb = counter_output_address_seq + 1;
    end
    else if(nxt_state == MAX_POOLING) begin
        counter_output_address_comb = counter_2 + counter_out_shift_r * output_matrix_size + counter_out_shift_d 
                                    + counter_out_new_line * output_matrix_size; 
    end
    else if(cur_state == CAL_CONV)begin
        counter_output_address_comb = counter_output_address_seq;
    end
    else if(cur_state == CAL_DECONV) begin
        counter_output_address_comb = counter_5 + counter_shift_d + counter_shift_r*deconv_matrix_size + counter_new_line*deconv_matrix_size;
    end
    else begin
        counter_output_address_comb = 0;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_output_address_seq <= 0;
        counter_output_address_seq_d1 <= 0; 
        counter_output_address_seq_d2 <= 0; 
    end
    else begin
        counter_output_address_seq <= counter_output_address_comb; 
        counter_output_address_seq_d1 <= counter_output_address_seq; 
        counter_output_address_seq_d2 <= counter_output_address_seq_d1; 
    end
end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        output_port_a_seq <= 0;
        output_port_b_seq <= 0;
    end
    else begin
        if(cur_state == MAX_POOLING) begin
            output_port_a_seq <= (counter_out_20 == 22 || counter_out_20 == 2) ? output_port_a : (output_port_a_seq > output_port_a) ? output_port_a_seq : output_port_a; 
            output_port_b_seq <= output_port_b;
        end
        else if(cur_state == CAL_DECONV) begin
            output_port_a_seq <= 0; 
            output_port_b_seq <= output_port_b;
        end
        else if(cur_state == DECONV_OUT) begin
            output_port_a_seq <= 0;
            output_port_b_seq <= output_port_b; 
        end
        else begin
            output_port_a_seq <= 0;
            output_port_b_seq <= 0;
        end
    end

end


/////////////////////////////
/////////////////////////////
/////////////////////////////



/////////////////////////////
//////////Memory read////////
/////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        memory_32_seq <= 0;
    end
    else begin
        if(cur_state == CAL_CONV) begin
            case(image_idx_seq)
                0  : memory_32_seq <= memory_32[0];
                1  : memory_32_seq <= memory_32[1];
                2  : memory_32_seq <= memory_32[2];
                3  : memory_32_seq <= memory_32[3];
                4  : memory_32_seq <= memory_32[4];
                5  : memory_32_seq <= memory_32[5];
                6  : memory_32_seq <= memory_32[6];
                7  : memory_32_seq <= memory_32[7];
                8  : memory_32_seq <= memory_32[8];
                9  : memory_32_seq <= memory_32[9];
                10 : memory_32_seq <= memory_32[10];
                11 : memory_32_seq <= memory_32[11];
                12 : memory_32_seq <= memory_32[12];
                13 : memory_32_seq <= memory_32[13];
                14 : memory_32_seq <= memory_32[14];
                15 : memory_32_seq <= memory_32[15];
                default : memory_32_seq <= 0;
            endcase
        end
        else begin
            memory_32_seq <= 0;
        end

    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        kernel_seq <= 0;
    end
    else begin
        kernel_seq <= ((cur_state == IDLE || cur_state == INPUT_IMAGE) && counter_address_kernel <= 1) ? 0 : kernel;
    end
end

/////////////////////////////
/////////////////////////////
/////////////////////////////


/////////////////////////////
//////////WEB control////////
/////////////////////////////


always @(*) begin
    if(in_valid && (cur_state == IDLE || cur_state == INPUT_IMAGE)) begin
        case(counter_16)
            4'd0 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[0] = 0;
            end
            4'd1 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[1] = 0;
            end
            4'd2 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[2] = 0;
            end
            4'd3 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[3] = 0;
            end
            4'd4 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[4] = 0;
            end
            4'd5 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[5] = 0;
            end
            4'd6 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[6] = 0;
            end
            4'd7 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[7] = 0;
            end
            4'd8 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[8] = 0;
            end
            4'd9 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[9] = 0;
            end
            4'd10 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[10] = 0;
            end
            4'd11 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[11] = 0;
            end
            4'd12 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[12] = 0;
            end
            4'd13 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[13] = 0;
            end
            4'd14 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[14] = 0;
            end
            4'd15 : begin
                WEB_m_32 = 16'b1111_1111_1111_1111;
                WEB_m_32[15] = 0;
            end
        endcase
    end
    else begin
        WEB_m_32 = 16'b1111_1111_1111_1111;
    end
end

always @(*) begin
    if(cur_state == INPUT_KERNEL) begin
        WEB_kernel = 0;
    end
    else begin
        WEB_kernel = 1;
    end

end

/////////////////////////////
/////////////////////////////
/////////////////////////////





always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        image_idx_seq <= 0;
        kernel_idx_seq <= 0;
        mode_seq <= 0;
    end
    else begin
        if(nxt_state == INPUT_INDEX && in_valid2) begin
            if(counter_16 == 0) begin
                image_idx_seq <= matrix_idx;
                kernel_idx_seq <= 0;
                mode_seq <= mode;
            end
            else begin
                image_idx_seq <= image_idx_seq;
                kernel_idx_seq <= matrix_idx;
                mode_seq <= mode_seq;
            end
        end
        else begin
            image_idx_seq <= image_idx_seq;
            kernel_idx_seq <= kernel_idx_seq;
            mode_seq <= mode_seq;
        end 
    end

end


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////Deconvolution/////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        deconv_kernel <= 0;
        deconv_image <= 0;
    end
    else begin
        if(cur_state == CAL_DECONV) begin
            deconv_kernel <= kernel;
            case(image_idx_seq)
                0  : deconv_image <= memory_32[0 ];
                1  : deconv_image <= memory_32[1 ];
                2  : deconv_image <= memory_32[2 ];
                3  : deconv_image <= memory_32[3 ];
                4  : deconv_image <= memory_32[4 ];
                5  : deconv_image <= memory_32[5 ];
                6  : deconv_image <= memory_32[6 ];
                7  : deconv_image <= memory_32[7 ];
                8  : deconv_image <= memory_32[8 ];
                9  : deconv_image <= memory_32[9 ];
                10 : deconv_image <= memory_32[10];
                11 : deconv_image <= memory_32[11];
                12 : deconv_image <= memory_32[12];
                13 : deconv_image <= memory_32[13];
                14 : deconv_image <= memory_32[14];
                15 : deconv_image <= memory_32[15];
                default : deconv_image <= 0;
            endcase
        end
        else begin
            deconv_kernel <= 0;
            deconv_image <= 0;
        end
    end
end


always @(*) begin
    if(cur_state == CAL_DECONV && (counter_5 >= 3 || counter_shift_r >= 1 || counter_shift_d >= 1 || counter_new_line >= 1)) begin
        deconv_out_comb = output_port_b_seq + deconv_kernel * deconv_image;
    end
    else begin
        deconv_out_comb = 0;
    end
end

always @(*) begin
    case(matrix_size_seq)
        0 : deconv_matrix_size = 12;
        1 : deconv_matrix_size = 20;
        2 : deconv_matrix_size = 36;
        default : deconv_matrix_size = 0;
    endcase
end

always @(*) begin
    case(matrix_size_seq)
        0 : deconv_matrix_size_total = 143;
        1 : deconv_matrix_size_total = 399;
        2 : deconv_matrix_size_total = 1295;
        default : deconv_matrix_size_total = 0;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        deconv_counter20 <= 0;
    end
    else begin
        if(cur_state == DECONV_OUT) begin
            if(deconv_counter20 == 19) begin
                deconv_counter20 <= 0;
            end
            else begin
                deconv_counter20 <= deconv_counter20 + 1;
            end
        end
        else begin
            deconv_counter20 <= 0;
        end
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        deconv_counter_output_address <= 0;
    end
    else begin
        if(cur_state == DECONV_OUT) begin
            if(deconv_counter20 == 19) begin
                if(deconv_counter_output_address == deconv_matrix_size_total) begin
                    deconv_counter_output_address <= 0;
                end
                else begin
                    deconv_counter_output_address <= deconv_counter_output_address + 1;
                end
            end
            else begin
                deconv_counter_output_address <= deconv_counter_output_address;
            end
        end
        else begin
            deconv_counter_output_address <= 0;
        end
    end

end

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////
/////////////Output//////////
/////////////////////////////


always @(*) begin
    if(mode_seq == 0) begin
        case(matrix_size_seq)
            0 : stop_address = 21;
            1 : stop_address = 157;
            2 : stop_address = 813;
            default : stop_address = 0;
        endcase
    end
    else begin
        case(matrix_size_seq)
            0 : stop_address = 143;
            1 : stop_address = 399;
            2 : stop_address = 1295;
            default : stop_address = 0;
        endcase
    end

end

assign out_golden_comb = (counter_out_16 == 6) ? output_port_a_seq : out_golden_seq;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_golden_seq <= 0;
    end
    else begin
        out_golden_seq <= out_golden_comb;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_out_20 <= 0;
    end
    else begin
        if((counter_2 == 1 && counter_out_shift_r == 1) || (counter_out_20 > 0 && counter_out_20 <= 19)) begin
            counter_out_20 <= counter_out_20 + 1;
            if(counter_out_20 == 26) begin
                counter_out_20 <= 7;
            end
        end
        else begin
            counter_out_20 <= 0;
        end
    end
end

always @(*) begin
    if(cur_state == MAX_POOLING && counter_out_20 > 5) begin
        out_valid_comb = 1;
    end
    else if(nxt_state == DECONV_OUT && (deconv_counter20 >= 2 || deconv_counter_output_address >= 1)) begin
        out_valid_comb = 1;
    end
    else if(deconv_counter_output_address_d2 == deconv_matrix_size_total && deconv_counter20 == 1) begin
        out_valid_comb = 1;
    end
    else if(deconv_counter20 == 0 && deconv_counter_output_address_d1 == deconv_matrix_size_total) begin
        out_valid_comb = 1;
    end
    else begin
        out_valid_comb = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_comb;
    end
end

always @(*) begin
    if(out_valid) begin
        if(cur_state == MAX_POOLING || cur_state == IDLE) begin
            case(counter_out_20)
                7   : out_value = out_golden_seq[0];
                8   : out_value = out_golden_seq[1];
                9  : out_value = out_golden_seq[2];
                10  : out_value = out_golden_seq[3];
                11  : out_value = out_golden_seq[4];
                12  : out_value = out_golden_seq[5];
                13  : out_value = out_golden_seq[6];
                14  : out_value = out_golden_seq[7];
                15  : out_value = out_golden_seq[8];
                16  : out_value = out_golden_seq[9];
                17  : out_value = out_golden_seq[10];
                18  : out_value = out_golden_seq[11];
                19  : out_value = out_golden_seq[12];
                20  : out_value = out_golden_seq[13];
                21  : out_value = out_golden_seq[14];
                22  : out_value = out_golden_seq[15];
                23  : out_value = out_golden_seq[16];
                24  : out_value = out_golden_seq[17];
                25  : out_value = out_golden_seq[18];
                26  : out_value = out_golden_seq[19];
                default : out_value = 0;
            endcase
        end
        else if(cur_state == DECONV_OUT) begin
            case(deconv_counter20)
                3   : out_value = output_port_b_seq[0];
                4   : out_value = output_port_b_seq[1];
                5   : out_value = output_port_b_seq[2];
                6   : out_value = output_port_b_seq[3];
                7   : out_value = output_port_b_seq[4];
                8   : out_value = output_port_b_seq[5];
                9   : out_value = output_port_b_seq[6];
                10  : out_value = output_port_b_seq[7];
                11  : out_value = output_port_b_seq[8];
                12  : out_value = output_port_b_seq[9];
                13  : out_value = output_port_b_seq[10];
                14  : out_value = output_port_b_seq[11];
                15  : out_value = output_port_b_seq[12];
                16  : out_value = output_port_b_seq[13];
                17  : out_value = output_port_b_seq[14];
                18  : out_value = output_port_b_seq[15];
                19  : out_value = output_port_b_seq[16];
                0   : out_value = output_port_b_seq[17];
                1   : out_value = output_port_b_seq[18];
                2   : out_value = output_port_b_seq[19];
                default : out_value = 0;
            endcase
        end
        else begin
            out_value = 0;
        end
    end
    else begin
        out_value = 0;
    end
end

/////////////////////////////
/////////////////////////////
/////////////////////////////

endmodule