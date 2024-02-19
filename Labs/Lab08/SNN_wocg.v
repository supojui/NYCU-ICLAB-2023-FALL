//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Siamese Neural Network 
//   Author     		: Jia-Yu Lee (maggie8905121@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SNN.v
//   Module Name : SNN
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

integer i, j;
reg [7:0]counter;
reg [31:0]image_1[0:3][0:3];
reg [31:0]image_2[0:3][0:3];

reg [31:0]kernel_1[0:2][0:2];
reg [31:0]kernel_2[0:2][0:2];
reg [31:0]kernel_3[0:2][0:2];

reg [31:0]weight[0:1][0:1];

///////////////////////////////////////////////////////////
//////////////////////////counter//////////////////////////
///////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 0;
    end
    else begin
        if(in_valid || (counter <= 123 && counter > 0)) begin
            counter <= counter + 1;
        end
        else begin
            counter <= 0;
        end
    end
end

///////////////////////////////////////////////////////////
//////////////////////////input////////////////////////////
///////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
// #region
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                image_1[i][j] <= 0;
            end
        end
    end
    else begin
        if(in_valid) begin
            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 4; j = j + 1) begin
                    image_1[i][j] <= image_1[i][j];
                end
            end
            case(counter)
                0, 16, 32, 48, 64, 80  : image_1[0][0] <= Img;
                1, 17, 33, 49, 65, 81  : image_1[0][1] <= Img;
                2, 18, 34, 50, 66, 82  : image_1[0][2] <= Img;
                3, 19, 35, 51, 67, 83  : image_1[0][3] <= Img;
                4, 20, 36, 52, 68, 84  : image_1[1][0] <= Img;
                5, 21, 37, 53, 69, 85  : image_1[1][1] <= Img;
                6, 22, 38, 54, 70, 86  : image_1[1][2] <= Img;
                7, 23, 39, 55, 71, 87  : image_1[1][3] <= Img;
                8, 24, 40, 56, 72, 88  : image_1[2][0] <= Img;
                9, 25, 41, 57, 73, 89  : image_1[2][1] <= Img;
                10,26, 42, 58, 74, 90  : image_1[2][2] <= Img;
                11,27, 43, 59, 75, 91  : image_1[2][3] <= Img;
                12,28, 44, 60, 76, 92  : image_1[3][0] <= Img;
                13,29, 45, 61, 77, 93  : image_1[3][1] <= Img;
                14,30, 46, 62, 78, 94  : image_1[3][2] <= Img;
                15,31, 47, 63, 79, 95  : image_1[3][3] <= Img;
            endcase
            
        end
        else begin
            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 4; j = j + 1) begin
                    image_1[i][j] <= image_1[i][j];
                end
            end
        end
    end
// #endregion
end

always @(posedge clk or negedge rst_n) begin
// #region
    if(!rst_n) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                kernel_1[i][j] <= 0;
            end
        end
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                kernel_2[i][j] <= 0;
            end
        end
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                kernel_3[i][j] <= 0;
            end
        end
    end
    else begin
        if(in_valid) begin
            for(i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 3; j = j + 1) begin
                    kernel_1[i][j] <= kernel_1[i][j];
                end
            end
            for(i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 3; j = j + 1) begin
                    kernel_2[i][j] <= kernel_2[i][j];
                end
            end
            for(i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 3; j = j + 1) begin
                    kernel_3[i][j] <= kernel_3[i][j];
                end
            end
            case(counter)
                0  : kernel_1[0][0] <= Kernel;
                1  : kernel_1[0][1] <= Kernel;
                2  : kernel_1[0][2] <= Kernel;
                3  : kernel_1[1][0] <= Kernel;
                4  : kernel_1[1][1] <= Kernel;
                5  : kernel_1[1][2] <= Kernel;
                6  : kernel_1[2][0] <= Kernel;
                7  : kernel_1[2][1] <= Kernel;
                8  : kernel_1[2][2] <= Kernel;
                9  : kernel_2[0][0] <= Kernel;
                10 : kernel_2[0][1] <= Kernel;
                11 : kernel_2[0][2] <= Kernel;
                12 : kernel_2[1][0] <= Kernel;
                13 : kernel_2[1][1] <= Kernel;
                14 : kernel_2[1][2] <= Kernel;
                15 : kernel_2[2][0] <= Kernel;
                16 : kernel_2[2][1] <= Kernel;
                17 : kernel_2[2][2] <= Kernel;
                18 : kernel_3[0][0] <= Kernel;
                19 : kernel_3[0][1] <= Kernel;
                20 : kernel_3[0][2] <= Kernel;
                21 : kernel_3[1][0] <= Kernel;
                22 : kernel_3[1][1] <= Kernel;
                23 : kernel_3[1][2] <= Kernel;
                24 : kernel_3[2][0] <= Kernel;
                25 : kernel_3[2][1] <= Kernel;
                26 : kernel_3[2][2] <= Kernel;
            endcase
        end
        else begin
            for(i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 3; j = j + 1) begin
                    kernel_1[i][j] <= kernel_1[i][j];
                end
            end
            for(i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 3; j = j + 1) begin
                    kernel_2[i][j] <= kernel_2[i][j];
                end
            end
            for(i = 0; i < 3; i = i + 1) begin
                for(j = 0; j < 3; j = j + 1) begin
                    kernel_3[i][j] <= kernel_3[i][j];
                end
            end
        end
    end
// #endregion
end

always @(posedge clk or negedge rst_n) begin
// #region
    if(!rst_n) begin
        for(i = 0; i < 2; i = i + 1) begin
            for(j = 0; j < 2; j = j + 1) begin
                weight[i][j] <= 0;
            end
        end
    end
    else begin
        if(in_valid) begin
            for(i = 0; i < 2; i = i + 1) begin
                for(j = 0; j < 2; j = j + 1) begin
                    weight[i][j] <= weight[i][j];
                end
            end
            case(counter)
                0  : weight[0][0] <= Weight;
                1  : weight[0][1] <= Weight;
                2  : weight[1][0] <= Weight;
                3  : weight[1][1] <= Weight;
            endcase
        end
        else begin
            for(i = 0; i < 2; i = i + 1) begin
                for(j = 0; j < 2; j = j + 1) begin
                    weight[i][j] <= weight[i][j];
                end
            end
        end
    end
// #endregion
end


///////////////////////////////////////////////////////////
////////////////////////padding////////////////////////////
///////////////////////////////////////////////////////////
reg [31:0]image_p_1[0:5][0:5];
reg [1:0]Opt_seq;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Opt_seq <= 0;
    end
    else begin
        if(in_valid && (counter == 0)) begin
            Opt_seq <= Opt;
        end
        else begin
            Opt_seq <= Opt_seq;
        end
    end
end


always @(*) begin
// #region
    if(Opt_seq[0] == 0) begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                if(i == 0) begin
                    image_p_1[i][j] = 'b0;  
                end
                else if(i == 5) begin
                    image_p_1[i][j] = 'b0;
                end
                else if(j == 0 || j == 5) begin
                    image_p_1[i][j] = 'b0;
                end
                else begin
                    image_p_1[i][j] = image_1[i-1][j-1];
                end
            end
        end
        
        image_p_1[0][0] = image_1[0][0];
        image_p_1[0][1] = image_1[0][0];
        image_p_1[0][2] = image_1[0][1];
        image_p_1[0][3] = image_1[0][2];
        image_p_1[0][4] = image_1[0][3];
        image_p_1[0][5] = image_1[0][3];
        image_p_1[0][5] = image_1[0][3];

        image_p_1[1][0] = image_1[0][0];
        image_p_1[1][5] = image_1[0][3];
        image_p_1[2][0] = image_1[1][0];
        image_p_1[2][5] = image_1[1][3];
        image_p_1[3][0] = image_1[2][0];
        image_p_1[3][5] = image_1[2][3];
        image_p_1[4][0] = image_1[3][0];
        image_p_1[4][5] = image_1[3][3];

        image_p_1[5][0] = image_1[3][0];
        image_p_1[5][1] = image_1[3][0];
        image_p_1[5][2] = image_1[3][1];
        image_p_1[5][3] = image_1[3][2];
        image_p_1[5][4] = image_1[3][3];
        image_p_1[5][5] = image_1[3][3];
        image_p_1[5][5] = image_1[3][3];
    end

    else begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                if(i == 0) begin
                    image_p_1[i][j] = 'b0;  
                end
                else if(i == 5) begin
                    image_p_1[i][j] = 'b0;
                end
                else if(j == 0 || j == 5) begin
                    image_p_1[i][j] = 'b0;
                end
                else begin
                    image_p_1[i][j] = image_1[i-1][j-1];
                end
            end
        end
    end
// #endregion
end

///////////////////////////////////////////////////////////
////////////////////////Convolution////////////////////////
///////////////////////////////////////////////////////////
reg [31:0]dp_in_1[0:2];
reg [31:0]dp_in_2[0:2];
reg [31:0]dp_in_3[0:2];
reg [31:0]dp_in_1_seq[0:2];
reg [31:0]dp_in_2_seq[0:2];
reg [31:0]dp_in_3_seq[0:2];


reg [31:0]dp_kernel[0:2][0:2];
reg [31:0]dp_kernel_seq[0:2][0:2];

reg [31:0]dp_out_1;
reg [31:0]dp_out_2;
reg [31:0]dp_out_3;
reg [31:0]dp_out_1_seq;
reg [31:0]dp_out_2_seq;
reg [31:0]dp_out_3_seq;

reg [31:0]sum3_out;

reg [31:0]f_map_1[0:3][0:3];
reg [31:0]f_map_1_seq[0:3][0:3];

reg [31:0]add_in;
reg [31:0]add_out;



always @(*) begin
// #region
    case(counter)
        9, 25, 41, 57, 73, 89 : begin
            dp_in_1[0] = image_p_1[0][0];
            dp_in_1[1] = image_p_1[0][1];
            dp_in_1[2] = image_p_1[0][2];
            dp_in_2[0] = image_p_1[1][0];
            dp_in_2[1] = image_p_1[1][1];
            dp_in_2[2] = image_p_1[1][2];
            dp_in_3[0] = image_p_1[2][0];
            dp_in_3[1] = image_p_1[2][1];
            dp_in_3[2] = image_p_1[2][2];
        end
        10, 26, 42, 58, 74, 90 : begin
            dp_in_1[0] = image_p_1[0][1];
            dp_in_1[1] = image_p_1[0][2];
            dp_in_1[2] = image_p_1[0][3];
            dp_in_2[0] = image_p_1[1][1];
            dp_in_2[1] = image_p_1[1][2];
            dp_in_2[2] = image_p_1[1][3];
            dp_in_3[0] = image_p_1[2][1];
            dp_in_3[1] = image_p_1[2][2];
            dp_in_3[2] = image_p_1[2][3];
        end
        11, 27, 43, 59, 75, 91 : begin
            dp_in_1[0] = image_p_1[0][2];
            dp_in_1[1] = image_p_1[0][3];
            dp_in_1[2] = image_p_1[0][4];
            dp_in_2[0] = image_p_1[1][2];
            dp_in_2[1] = image_p_1[1][3];
            dp_in_2[2] = image_p_1[1][4];
            dp_in_3[0] = image_p_1[2][2];
            dp_in_3[1] = image_p_1[2][3];
            dp_in_3[2] = image_p_1[2][4];
        end
        12, 28, 44, 60, 76, 92 : begin
            dp_in_1[0] = image_p_1[0][3];
            dp_in_1[1] = image_p_1[0][4];
            dp_in_1[2] = image_p_1[0][5];
            dp_in_2[0] = image_p_1[1][3];
            dp_in_2[1] = image_p_1[1][4];
            dp_in_2[2] = image_p_1[1][5];
            dp_in_3[0] = image_p_1[2][3];
            dp_in_3[1] = image_p_1[2][4];
            dp_in_3[2] = image_p_1[2][5];
        end
        13, 29, 45, 61, 77, 93 : begin
            dp_in_1[0] = image_p_1[1][0];
            dp_in_1[1] = image_p_1[1][1];
            dp_in_1[2] = image_p_1[1][2];
            dp_in_2[0] = image_p_1[2][0];
            dp_in_2[1] = image_p_1[2][1];
            dp_in_2[2] = image_p_1[2][2];
            dp_in_3[0] = image_p_1[3][0];
            dp_in_3[1] = image_p_1[3][1];
            dp_in_3[2] = image_p_1[3][2];
        end
        14, 30, 46, 62, 78, 94 : begin
            dp_in_1[0] = image_p_1[1][1];
            dp_in_1[1] = image_p_1[1][2];
            dp_in_1[2] = image_p_1[1][3];
            dp_in_2[0] = image_p_1[2][1];
            dp_in_2[1] = image_p_1[2][2];
            dp_in_2[2] = image_p_1[2][3];
            dp_in_3[0] = image_p_1[3][1];
            dp_in_3[1] = image_p_1[3][2];
            dp_in_3[2] = image_p_1[3][3];
        end
        15, 31, 47, 63, 79, 95 : begin
            dp_in_1[0] = image_p_1[1][2];
            dp_in_1[1] = image_p_1[1][3];
            dp_in_1[2] = image_p_1[1][4];
            dp_in_2[0] = image_p_1[2][2];
            dp_in_2[1] = image_p_1[2][3];
            dp_in_2[2] = image_p_1[2][4];
            dp_in_3[0] = image_p_1[3][2];
            dp_in_3[1] = image_p_1[3][3];
            dp_in_3[2] = image_p_1[3][4];
        end
        16, 32, 48, 64, 80, 96 : begin
            dp_in_1[0] = image_p_1[1][3];
            dp_in_1[1] = image_p_1[1][4];
            dp_in_1[2] = image_p_1[1][5];
            dp_in_2[0] = image_p_1[2][3];
            dp_in_2[1] = image_p_1[2][4];
            dp_in_2[2] = image_p_1[2][5];
            dp_in_3[0] = image_p_1[3][3];
            dp_in_3[1] = image_p_1[3][4];
            dp_in_3[2] = image_p_1[3][5];
        end
        17, 33, 49, 65, 81, 97 : begin
            dp_in_1[0] = image_p_1[2][0];
            dp_in_1[1] = image_p_1[2][1];
            dp_in_1[2] = image_p_1[2][2];
            dp_in_2[0] = image_p_1[3][0];
            dp_in_2[1] = image_p_1[3][1];
            dp_in_2[2] = image_p_1[3][2];
            dp_in_3[0] = image_p_1[4][0];
            dp_in_3[1] = image_p_1[4][1];
            dp_in_3[2] = image_p_1[4][2];
        end
        18, 34, 50, 66, 82, 98 : begin
            dp_in_1[0] = image_p_1[2][1];
            dp_in_1[1] = image_p_1[2][2];
            dp_in_1[2] = image_p_1[2][3];
            dp_in_2[0] = image_p_1[3][1];
            dp_in_2[1] = image_p_1[3][2];
            dp_in_2[2] = image_p_1[3][3];
            dp_in_3[0] = image_p_1[4][1];
            dp_in_3[1] = image_p_1[4][2];
            dp_in_3[2] = image_p_1[4][3];
        end
        19, 35, 51, 67, 83, 99 : begin
            dp_in_1[0] = image_p_1[2][2];
            dp_in_1[1] = image_p_1[2][3];
            dp_in_1[2] = image_p_1[2][4];
            dp_in_2[0] = image_p_1[3][2];
            dp_in_2[1] = image_p_1[3][3];
            dp_in_2[2] = image_p_1[3][4];
            dp_in_3[0] = image_p_1[4][2];
            dp_in_3[1] = image_p_1[4][3];
            dp_in_3[2] = image_p_1[4][4];
        end
        20, 36, 52, 68, 84, 100 : begin
            dp_in_1[0] = image_p_1[2][3];
            dp_in_1[1] = image_p_1[2][4];
            dp_in_1[2] = image_p_1[2][5];
            dp_in_2[0] = image_p_1[3][3];
            dp_in_2[1] = image_p_1[3][4];
            dp_in_2[2] = image_p_1[3][5];
            dp_in_3[0] = image_p_1[4][3];
            dp_in_3[1] = image_p_1[4][4];
            dp_in_3[2] = image_p_1[4][5];
        end
        21, 37, 53, 69, 85, 101 : begin
            dp_in_1[0] = image_p_1[3][0];
            dp_in_1[1] = image_p_1[3][1];
            dp_in_1[2] = image_p_1[3][2];
            dp_in_2[0] = image_p_1[4][0];
            dp_in_2[1] = image_p_1[4][1];
            dp_in_2[2] = image_p_1[4][2];
            dp_in_3[0] = image_p_1[5][0];
            dp_in_3[1] = image_p_1[5][1];
            dp_in_3[2] = image_p_1[5][2];
        end
        22, 38, 54, 70, 86, 102 : begin
            dp_in_1[0] = image_p_1[3][1];
            dp_in_1[1] = image_p_1[3][2];
            dp_in_1[2] = image_p_1[3][3];
            dp_in_2[0] = image_p_1[4][1];
            dp_in_2[1] = image_p_1[4][2];
            dp_in_2[2] = image_p_1[4][3];
            dp_in_3[0] = image_p_1[5][1];
            dp_in_3[1] = image_p_1[5][2];
            dp_in_3[2] = image_p_1[5][3];
        end
        23, 39, 55, 71, 87, 103 : begin
            dp_in_1[0] = image_p_1[3][2];
            dp_in_1[1] = image_p_1[3][3];
            dp_in_1[2] = image_p_1[3][4];
            dp_in_2[0] = image_p_1[4][2];
            dp_in_2[1] = image_p_1[4][3];
            dp_in_2[2] = image_p_1[4][4];
            dp_in_3[0] = image_p_1[5][2];
            dp_in_3[1] = image_p_1[5][3];
            dp_in_3[2] = image_p_1[5][4];
        end
        24, 40, 56, 72, 88, 104 : begin
            dp_in_1[0] = image_p_1[3][3];
            dp_in_1[1] = image_p_1[3][4];
            dp_in_1[2] = image_p_1[3][5];
            dp_in_2[0] = image_p_1[4][3];
            dp_in_2[1] = image_p_1[4][4];
            dp_in_2[2] = image_p_1[4][5];
            dp_in_3[0] = image_p_1[5][3];
            dp_in_3[1] = image_p_1[5][4];
            dp_in_3[2] = image_p_1[5][5];
        end
        default : begin
            dp_in_1[0] = dp_in_1_seq[0]; ////////////////trash/////////////////
            dp_in_1[1] = dp_in_1_seq[1];
            dp_in_1[2] = dp_in_1_seq[2];
            dp_in_2[0] = dp_in_2_seq[0];
            dp_in_2[1] = dp_in_2_seq[1];
            dp_in_2[2] = dp_in_2_seq[2];
            dp_in_3[0] = dp_in_3_seq[0];
            dp_in_3[1] = dp_in_3_seq[1];
            dp_in_3[2] = dp_in_3_seq[2];
        end
    endcase
// #endregion
end


always @(*) begin
    if(counter < 25) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = kernel_1[i][j];
            end
        end
    end
    else if(counter >= 25 && counter < 41) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = kernel_2[i][j];
            end
        end
    end
    else if(counter >= 41 && counter < 57) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = kernel_3[i][j];
            end
        end
    end
    else if(counter >= 57 && counter < 73) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = kernel_1[i][j];
            end
        end
    end
    else if(counter >= 73 && counter < 89) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = kernel_2[i][j];
            end
        end
    end
    else if(counter >= 89 && counter < 105) begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = kernel_3[i][j];
            end
        end
    end
    else begin
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel[i][j] = dp_kernel_seq[i][j]; ////////////////trash/////////////////
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 3; i = i + 1) begin
            dp_in_1_seq[i] <= 0;
        end
        for(i = 0; i < 3; i = i + 1) begin
            dp_in_2_seq[i] <= 0;
        end
        for(i = 0; i < 3; i = i + 1) begin
            dp_in_3_seq[i] <= 0;
        end
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel_seq[i][j] <= 0;
            end
        end
    end
    else begin
        for(i = 0; i < 3; i = i + 1) begin
            dp_in_1_seq[i] <= dp_in_1[i];
        end
        for(i = 0; i < 3; i = i + 1) begin
            dp_in_2_seq[i] <= dp_in_2[i];
        end
        for(i = 0; i < 3; i = i + 1) begin
            dp_in_3_seq[i] <= dp_in_3[i];
        end
        for(i = 0; i < 3; i = i + 1) begin
            for(j = 0; j < 3; j = j + 1) begin
                dp_kernel_seq[i][j] <= dp_kernel[i][j];
            end
        end
    end

end

reg [31:0]dp_mul_out[0:2][0:2];

DW_fp_mult_inst dp_mul_1_1 (.inst_a(dp_in_1_seq[0]), .inst_b(dp_kernel_seq[0][0]), .inst_rnd(3'b000), .z_inst(dp_mul_out[0][0]));
DW_fp_mult_inst dp_mul_1_2 (.inst_a(dp_in_1_seq[1]), .inst_b(dp_kernel_seq[0][1]), .inst_rnd(3'b000), .z_inst(dp_mul_out[0][1]));
DW_fp_mult_inst dp_mul_1_3 (.inst_a(dp_in_1_seq[2]), .inst_b(dp_kernel_seq[0][2]), .inst_rnd(3'b000), .z_inst(dp_mul_out[0][2]));
DW_fp_mult_inst dp_mul_2_1 (.inst_a(dp_in_2_seq[0]), .inst_b(dp_kernel_seq[1][0]), .inst_rnd(3'b000), .z_inst(dp_mul_out[1][0]));
DW_fp_mult_inst dp_mul_2_2 (.inst_a(dp_in_2_seq[1]), .inst_b(dp_kernel_seq[1][1]), .inst_rnd(3'b000), .z_inst(dp_mul_out[1][1]));
DW_fp_mult_inst dp_mul_2_3 (.inst_a(dp_in_2_seq[2]), .inst_b(dp_kernel_seq[1][2]), .inst_rnd(3'b000), .z_inst(dp_mul_out[1][2]));
DW_fp_mult_inst dp_mul_3_1 (.inst_a(dp_in_3_seq[0]), .inst_b(dp_kernel_seq[2][0]), .inst_rnd(3'b000), .z_inst(dp_mul_out[2][0]));
DW_fp_mult_inst dp_mul_3_2 (.inst_a(dp_in_3_seq[1]), .inst_b(dp_kernel_seq[2][1]), .inst_rnd(3'b000), .z_inst(dp_mul_out[2][1]));
DW_fp_mult_inst dp_mul_3_3 (.inst_a(dp_in_3_seq[2]), .inst_b(dp_kernel_seq[2][2]), .inst_rnd(3'b000), .z_inst(dp_mul_out[2][2]));

DW_fp_sum3_inst dp_sum3_1 (.inst_a(dp_mul_out[0][0]), .inst_b(dp_mul_out[0][1]), .inst_c(dp_mul_out[0][2]), .inst_rnd(3'b000), .z_inst(dp_out_1));
DW_fp_sum3_inst dp_sum3_2 (.inst_a(dp_mul_out[1][0]), .inst_b(dp_mul_out[1][1]), .inst_c(dp_mul_out[1][2]), .inst_rnd(3'b000), .z_inst(dp_out_2));
DW_fp_sum3_inst dp_sum3_3 (.inst_a(dp_mul_out[2][0]), .inst_b(dp_mul_out[2][1]), .inst_c(dp_mul_out[2][2]), .inst_rnd(3'b000), .z_inst(dp_out_3));


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dp_out_1_seq <= 0;
        dp_out_2_seq <= 0;
        dp_out_3_seq <= 0;
    end
    else begin
        dp_out_1_seq <= dp_out_1;
        dp_out_2_seq <= dp_out_2;
        dp_out_3_seq <= dp_out_3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                f_map_1_seq[i][j] <= 0;
            end
        end
    end
    else begin
        if(out_valid == 1) begin
            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 4; j = j + 1) begin
                    f_map_1_seq[i][j] <= 0;
                end
            end
        end
        else begin
            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 4; j = j + 1) begin
                    f_map_1_seq[i][j] <= f_map_1[i][j];
                end
            end
        end
    end
end

always @(*) begin
    case(counter)
        11, 27, 43  : add_in = f_map_1_seq[0][0];
        12, 28, 44  : add_in = f_map_1_seq[0][1];
        13, 29, 45  : add_in = f_map_1_seq[0][2];
        14, 30, 46  : add_in = f_map_1_seq[0][3];
        15, 31, 47  : add_in = f_map_1_seq[1][0];
        16, 32, 48  : add_in = f_map_1_seq[1][1];
        17, 33, 49  : add_in = f_map_1_seq[1][2];
        18, 34, 50  : add_in = f_map_1_seq[1][3];
        19, 35, 51  : add_in = f_map_1_seq[2][0];
        20, 36, 52  : add_in = f_map_1_seq[2][1];
        21, 37, 53  : add_in = f_map_1_seq[2][2];
        22, 38, 54  : add_in = f_map_1_seq[2][3];
        23, 39, 55  : add_in = f_map_1_seq[3][0];
        24, 40, 56  : add_in = f_map_1_seq[3][1];
        25, 41, 57  : add_in = f_map_1_seq[3][2];
        26, 42, 58  : add_in = f_map_1_seq[3][3];


        59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74 : add_in = 0;
        75, 91  : add_in = f_map_1_seq[0][0];
        76, 92  : add_in = f_map_1_seq[0][1];
        77, 93  : add_in = f_map_1_seq[0][2];
        78, 94  : add_in = f_map_1_seq[0][3];
        79, 95  : add_in = f_map_1_seq[1][0];
        80, 96  : add_in = f_map_1_seq[1][1];
        81, 97  : add_in = f_map_1_seq[1][2];
        82, 98  : add_in = f_map_1_seq[1][3];
        83, 99  : add_in = f_map_1_seq[2][0];
        84, 100 : add_in = f_map_1_seq[2][1];
        85, 101 : add_in = f_map_1_seq[2][2];
        86, 102 : add_in = f_map_1_seq[2][3];
        87, 103 : add_in = f_map_1_seq[3][0];
        88, 104 : add_in = f_map_1_seq[3][1];
        89, 105 : add_in = f_map_1_seq[3][2];
        90, 106 : add_in = f_map_1_seq[3][3];


        default : add_in = 0;
    endcase
end

always @(*) begin
    for(i = 0; i < 4; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            // if(counter != 59) begin
                f_map_1[i][j] = f_map_1_seq[i][j];
            // end
            // else begin
            //     f_map_1[i][j] = 0;
            // end
        end
    end
    case(counter)
        11, 27, 43 : f_map_1[0][0] = add_out;
        12, 28, 44 : f_map_1[0][1] = add_out;
        13, 29, 45 : f_map_1[0][2] = add_out;
        14, 30, 46 : f_map_1[0][3] = add_out;
        15, 31, 47 : f_map_1[1][0] = add_out;
        16, 32, 48 : f_map_1[1][1] = add_out;
        17, 33, 49 : f_map_1[1][2] = add_out;
        18, 34, 50 : f_map_1[1][3] = add_out;
        19, 35, 51 : f_map_1[2][0] = add_out;
        20, 36, 52 : f_map_1[2][1] = add_out;
        21, 37, 53 : f_map_1[2][2] = add_out;
        22, 38, 54 : f_map_1[2][3] = add_out;
        23, 39, 55 : f_map_1[3][0] = add_out;
        24, 40, 56 : f_map_1[3][1] = add_out;
        25, 41, 57 : f_map_1[3][2] = add_out;
        26, 42, 58 : f_map_1[3][3] = add_out;

        59, 75, 91  : f_map_1[0][0] = add_out;
        60, 76, 92  : f_map_1[0][1] = add_out;
        61, 77, 93  : f_map_1[0][2] = add_out;
        62, 78, 94  : f_map_1[0][3] = add_out;
        63, 79, 95  : f_map_1[1][0] = add_out;
        64, 80, 96  : f_map_1[1][1] = add_out;
        65, 81, 97  : f_map_1[1][2] = add_out;
        66, 82, 98  : f_map_1[1][3] = add_out;
        67, 83, 99  : f_map_1[2][0] = add_out;
        68, 84, 100 : f_map_1[2][1] = add_out;
        69, 85, 101 : f_map_1[2][2] = add_out;
        70, 86, 102 : f_map_1[2][3] = add_out;
        71, 87, 103 : f_map_1[3][0] = add_out;
        72, 88, 104 : f_map_1[3][1] = add_out;
        73, 89, 105 : f_map_1[3][2] = add_out;
        74, 90, 106 : f_map_1[3][3] = add_out;
    endcase

end



DW_fp_sum3_inst dp_sum (.inst_a(dp_out_1_seq), .inst_b(dp_out_2_seq), .inst_c(dp_out_3_seq), .inst_rnd(3'b000), .z_inst(sum3_out));
DW_fp_add_inst  dp_add (.inst_a(add_in), .inst_b(sum3_out), .inst_rnd(3'b000), .z_inst(add_out));


///////////////////////////////////////////////////////////
////////////////////////Equalization///////////////////////
///////////////////////////////////////////////////////////

reg [31:0] f_map_padding[0:5][0:5];


always @(*) begin
    if(Opt_seq[0] == 0) begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                if(i == 0) begin
                    f_map_padding[i][j] = 'b0;  
                end
                else if(i == 5) begin
                    f_map_padding[i][j] = 'b0;
                end
                else if(j == 0 || j == 5) begin
                    f_map_padding[i][j] = 'b0;
                end
                else begin
                    f_map_padding[i][j] = f_map_1_seq[i-1][j-1];
                end
            end
        end
        
        f_map_padding[0][0] = f_map_1_seq[0][0];
        f_map_padding[0][1] = f_map_1_seq[0][0];
        f_map_padding[0][2] = f_map_1_seq[0][1];
        f_map_padding[0][3] = f_map_1_seq[0][2];
        f_map_padding[0][4] = f_map_1_seq[0][3];
        f_map_padding[0][5] = f_map_1_seq[0][3];
        f_map_padding[0][5] = f_map_1_seq[0][3];

        f_map_padding[1][0] = f_map_1_seq[0][0];
        f_map_padding[1][5] = f_map_1_seq[0][3];
        f_map_padding[2][0] = f_map_1_seq[1][0];
        f_map_padding[2][5] = f_map_1_seq[1][3];
        f_map_padding[3][0] = f_map_1_seq[2][0];
        f_map_padding[3][5] = f_map_1_seq[2][3];
        f_map_padding[4][0] = f_map_1_seq[3][0];
        f_map_padding[4][5] = f_map_1_seq[3][3];

        f_map_padding[5][0] = f_map_1_seq[3][0];
        f_map_padding[5][1] = f_map_1_seq[3][0];
        f_map_padding[5][2] = f_map_1_seq[3][1];
        f_map_padding[5][3] = f_map_1_seq[3][2];
        f_map_padding[5][4] = f_map_1_seq[3][3];
        f_map_padding[5][5] = f_map_1_seq[3][3];
        f_map_padding[5][5] = f_map_1_seq[3][3];
    end

    else begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                if(i == 0) begin
                    f_map_padding[i][j] = 'b0;  
                end
                else if(i == 5) begin
                    f_map_padding[i][j] = 'b0;
                end
                else if(j == 0 || j == 5) begin
                    f_map_padding[i][j] = 'b0;
                end
                else begin
                    f_map_padding[i][j] = f_map_1_seq[i-1][j-1];
                end
            end
        end
    end
// #endregion
end


reg [31:0]equalize_in[0:2][0:2];
reg [31:0]equalize_temp[0:2];
reg [31:0]equalize_out;
reg [31:0]equalize_out_seq;


always @(*) begin
// #region
    for(i = 0; i < 3; i = i + 1) begin
        for(j = 0; j < 3; j = j + 1) begin
            equalize_in[i][j] = 0;
        end
    end

    case(counter)
        49, 97 : begin
            equalize_in[0][0] = f_map_padding[0][0];
            equalize_in[0][1] = f_map_padding[0][1];
            equalize_in[0][2] = f_map_padding[0][2];
            equalize_in[1][0] = f_map_padding[1][0];
            equalize_in[1][1] = f_map_padding[1][1];
            equalize_in[1][2] = f_map_padding[1][2];
            equalize_in[2][0] = f_map_padding[2][0];
            equalize_in[2][1] = f_map_padding[2][1];
            equalize_in[2][2] = f_map_padding[2][2];
        end
        50, 98 : begin
            equalize_in[0][0] = f_map_padding[0][1];
            equalize_in[0][1] = f_map_padding[0][2];
            equalize_in[0][2] = f_map_padding[0][3];
            equalize_in[1][0] = f_map_padding[1][1];
            equalize_in[1][1] = f_map_padding[1][2];
            equalize_in[1][2] = f_map_padding[1][3];
            equalize_in[2][0] = f_map_padding[2][1];
            equalize_in[2][1] = f_map_padding[2][2];
            equalize_in[2][2] = f_map_padding[2][3];
        end
        51, 99 : begin
            equalize_in[0][0] = f_map_padding[0][2];
            equalize_in[0][1] = f_map_padding[0][3];
            equalize_in[0][2] = f_map_padding[0][4];
            equalize_in[1][0] = f_map_padding[1][2];
            equalize_in[1][1] = f_map_padding[1][3];
            equalize_in[1][2] = f_map_padding[1][4];
            equalize_in[2][0] = f_map_padding[2][2];
            equalize_in[2][1] = f_map_padding[2][3];
            equalize_in[2][2] = f_map_padding[2][4];
        end
        52, 100 : begin
            equalize_in[0][0] = f_map_padding[0][3];
            equalize_in[0][1] = f_map_padding[0][4];
            equalize_in[0][2] = f_map_padding[0][5];
            equalize_in[1][0] = f_map_padding[1][3];
            equalize_in[1][1] = f_map_padding[1][4];
            equalize_in[1][2] = f_map_padding[1][5];
            equalize_in[2][0] = f_map_padding[2][3];
            equalize_in[2][1] = f_map_padding[2][4];
            equalize_in[2][2] = f_map_padding[2][5];
        end

        
        53, 101 : begin
            equalize_in[0][0] = f_map_padding[1][0];
            equalize_in[0][1] = f_map_padding[1][1];
            equalize_in[0][2] = f_map_padding[1][2];
            equalize_in[1][0] = f_map_padding[2][0];
            equalize_in[1][1] = f_map_padding[2][1];
            equalize_in[1][2] = f_map_padding[2][2];
            equalize_in[2][0] = f_map_padding[3][0];
            equalize_in[2][1] = f_map_padding[3][1];
            equalize_in[2][2] = f_map_padding[3][2];
        end
        54, 102 : begin
            equalize_in[0][0] = f_map_padding[1][1];
            equalize_in[0][1] = f_map_padding[1][2];
            equalize_in[0][2] = f_map_padding[1][3];
            equalize_in[1][0] = f_map_padding[2][1];
            equalize_in[1][1] = f_map_padding[2][2];
            equalize_in[1][2] = f_map_padding[2][3];
            equalize_in[2][0] = f_map_padding[3][1];
            equalize_in[2][1] = f_map_padding[3][2];
            equalize_in[2][2] = f_map_padding[3][3];
        end
        55, 103 : begin
            equalize_in[0][0] = f_map_padding[1][2];
            equalize_in[0][1] = f_map_padding[1][3];
            equalize_in[0][2] = f_map_padding[1][4];
            equalize_in[1][0] = f_map_padding[2][2];
            equalize_in[1][1] = f_map_padding[2][3];
            equalize_in[1][2] = f_map_padding[2][4];
            equalize_in[2][0] = f_map_padding[3][2];
            equalize_in[2][1] = f_map_padding[3][3];
            equalize_in[2][2] = f_map_padding[3][4];
        end
        56, 104 : begin
            equalize_in[0][0] = f_map_padding[1][3];
            equalize_in[0][1] = f_map_padding[1][4];
            equalize_in[0][2] = f_map_padding[1][5];
            equalize_in[1][0] = f_map_padding[2][3];
            equalize_in[1][1] = f_map_padding[2][4];
            equalize_in[1][2] = f_map_padding[2][5];
            equalize_in[2][0] = f_map_padding[3][3];
            equalize_in[2][1] = f_map_padding[3][4];
            equalize_in[2][2] = f_map_padding[3][5];
        end

        
        57, 105 : begin
            equalize_in[0][0] = f_map_padding[2][0];
            equalize_in[0][1] = f_map_padding[2][1];
            equalize_in[0][2] = f_map_padding[2][2];
            equalize_in[1][0] = f_map_padding[3][0];
            equalize_in[1][1] = f_map_padding[3][1];
            equalize_in[1][2] = f_map_padding[3][2];
            equalize_in[2][0] = f_map_padding[4][0];
            equalize_in[2][1] = f_map_padding[4][1];
            equalize_in[2][2] = f_map_padding[4][2];
        end
        58, 106 : begin
            equalize_in[0][0] = f_map_padding[2][1];
            equalize_in[0][1] = f_map_padding[2][2];
            equalize_in[0][2] = f_map_padding[2][3];
            equalize_in[1][0] = f_map_padding[3][1];
            equalize_in[1][1] = f_map_padding[3][2];
            equalize_in[1][2] = f_map_padding[3][3];
            equalize_in[2][0] = f_map_padding[4][1];
            equalize_in[2][1] = f_map_padding[4][2];
            equalize_in[2][2] = f_map_padding[4][3];
        end
        59, 107 : begin
            equalize_in[0][0] = f_map_padding[2][2];
            equalize_in[0][1] = f_map_padding[2][3];
            equalize_in[0][2] = f_map_padding[2][4];
            equalize_in[1][0] = f_map_padding[3][2];
            equalize_in[1][1] = f_map_padding[3][3];
            equalize_in[1][2] = f_map_padding[3][4];
            equalize_in[2][0] = f_map_padding[4][2];
            equalize_in[2][1] = f_map_padding[4][3];
            equalize_in[2][2] = f_map_padding[4][4];
        end
        60, 108 : begin
            equalize_in[0][0] = f_map_padding[2][3];
            equalize_in[0][1] = f_map_padding[2][4];
            equalize_in[0][2] = f_map_padding[2][5];
            equalize_in[1][0] = f_map_padding[3][3];
            equalize_in[1][1] = f_map_padding[3][4];
            equalize_in[1][2] = f_map_padding[3][5];
            equalize_in[2][0] = f_map_padding[4][3];
            equalize_in[2][1] = f_map_padding[4][4];
            equalize_in[2][2] = f_map_padding[4][5];
        end


        
        61, 109 : begin
            equalize_in[0][0] = f_map_padding[3][0];
            equalize_in[0][1] = f_map_padding[3][1];
            equalize_in[0][2] = f_map_padding[3][2];
            equalize_in[1][0] = f_map_padding[4][0];
            equalize_in[1][1] = f_map_padding[4][1];
            equalize_in[1][2] = f_map_padding[4][2];
            equalize_in[2][0] = f_map_padding[5][0];
            equalize_in[2][1] = f_map_padding[5][1];
            equalize_in[2][2] = f_map_padding[5][2];
        end
        62, 110 : begin
            equalize_in[0][0] = f_map_padding[3][1];
            equalize_in[0][1] = f_map_padding[3][2];
            equalize_in[0][2] = f_map_padding[3][3];
            equalize_in[1][0] = f_map_padding[4][1];
            equalize_in[1][1] = f_map_padding[4][2];
            equalize_in[1][2] = f_map_padding[4][3];
            equalize_in[2][0] = f_map_padding[5][1];
            equalize_in[2][1] = f_map_padding[5][2];
            equalize_in[2][2] = f_map_padding[5][3];
        end
        63, 111 : begin
            equalize_in[0][0] = f_map_padding[3][2];
            equalize_in[0][1] = f_map_padding[3][3];
            equalize_in[0][2] = f_map_padding[3][4];
            equalize_in[1][0] = f_map_padding[4][2];
            equalize_in[1][1] = f_map_padding[4][3];
            equalize_in[1][2] = f_map_padding[4][4];
            equalize_in[2][0] = f_map_padding[5][2];
            equalize_in[2][1] = f_map_padding[5][3];
            equalize_in[2][2] = f_map_padding[5][4];
        end
        64, 112 : begin
            equalize_in[0][0] = f_map_padding[3][3];
            equalize_in[0][1] = f_map_padding[3][4];
            equalize_in[0][2] = f_map_padding[3][5];
            equalize_in[1][0] = f_map_padding[4][3];
            equalize_in[1][1] = f_map_padding[4][4];
            equalize_in[1][2] = f_map_padding[4][5];
            equalize_in[2][0] = f_map_padding[5][3];
            equalize_in[2][1] = f_map_padding[5][4];
            equalize_in[2][2] = f_map_padding[5][5];
        end
    endcase

// #endregion
end




DW_fp_sum3_inst eq_sum_1 (.inst_a(equalize_in[0][0]), .inst_b(equalize_in[0][1]), .inst_c(equalize_in[0][2]), .inst_rnd(3'b000), .z_inst(equalize_temp[0]));
DW_fp_sum3_inst eq_sum_2 (.inst_a(equalize_in[1][0]), .inst_b(equalize_in[1][1]), .inst_c(equalize_in[1][2]), .inst_rnd(3'b000), .z_inst(equalize_temp[1]));
DW_fp_sum3_inst eq_sum_3 (.inst_a(equalize_in[2][0]), .inst_b(equalize_in[2][1]), .inst_c(equalize_in[2][2]), .inst_rnd(3'b000), .z_inst(equalize_temp[2]));
DW_fp_sum3_inst eq_sum_4 (.inst_a(equalize_temp[0]),  .inst_b(equalize_temp[1]),  .inst_c(equalize_temp[2]),  .inst_rnd(3'b000), .z_inst(equalize_out));


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        equalize_out_seq <= 0;        
    end
    else begin
        equalize_out_seq <= equalize_out;
    end
end

reg [31:0]equalize_div_out;

DW_fp_div_inst div_eq (.inst_a(equalize_out_seq), .inst_b(32'b01000001000100000000000000000000), .z_inst(equalize_div_out), .inst_rnd(3'b000));


reg [31:0]f_eq_map[0:3][0:3];
reg [31:0]f_eq_map_seq[0:3][0:3];

always @(*) begin
    for(i = 0; i < 4; i = i + 1 ) begin
        for(j = 0; j < 4; j = j + 1 ) begin
            f_eq_map[i][j] = f_eq_map_seq[i][j];
        end
    end

    case(counter)
        50, 98 : f_eq_map[0][0] = equalize_div_out;
        51, 99 : f_eq_map[0][1] = equalize_div_out;
        52, 100: f_eq_map[0][2] = equalize_div_out;
        53, 101: f_eq_map[0][3] = equalize_div_out;
        54, 102: f_eq_map[1][0] = equalize_div_out;
        55, 103: f_eq_map[1][1] = equalize_div_out;
        56, 104: f_eq_map[1][2] = equalize_div_out;
        57, 105: f_eq_map[1][3] = equalize_div_out;
        58, 106: f_eq_map[2][0] = equalize_div_out;
        59, 107: f_eq_map[2][1] = equalize_div_out;
        60, 108: f_eq_map[2][2] = equalize_div_out;
        61, 109: f_eq_map[2][3] = equalize_div_out;
        62, 110: f_eq_map[3][0] = equalize_div_out;
        63, 111: f_eq_map[3][1] = equalize_div_out;
        64, 112: f_eq_map[3][2] = equalize_div_out;
        65, 113: f_eq_map[3][3] = equalize_div_out;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1 ) begin
            for(j = 0; j < 4; j = j + 1 ) begin
                f_eq_map_seq[i][j] <= 0;
            end
        end
    end
    else begin
        for(i = 0; i < 4; i = i + 1 ) begin
            for(j = 0; j < 4; j = j + 1 ) begin
                f_eq_map_seq[i][j] <= f_eq_map[i][j];
            end
        end
    end
end


///////////////////////////////////////////////////////////
////////////////////////Max Pooling////////////////////////
///////////////////////////////////////////////////////////

reg [31:0]max_pooling_in[0:3][0:3];

always @(*) begin
    if(counter == 66 || counter == 114) begin
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                max_pooling_in[i][j] = f_eq_map_seq[i][j];
            end
        end
    end
    else begin
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                max_pooling_in[i][j] = {counter, counter, counter, counter};
            end
        end
    end
end

reg [31:0]max_pooling_00;
reg [31:0]max_pooling_01;
reg [31:0]max_pooling_10;
reg [31:0]max_pooling_11;

reg [31:0]com_F1_00_0;
reg [31:0]com_F1_00_1;

DW_fp_cmp_inst COM_F1_00_0 (.inst_a(max_pooling_in[0][0]), .inst_b(max_pooling_in[0][1]), .z1_inst(com_F1_00_0), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_00_1 (.inst_a(max_pooling_in[1][0]), .inst_b(max_pooling_in[1][1]), .z1_inst(com_F1_00_1), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_00   (.inst_a(com_F1_00_0),   .inst_b(com_F1_00_1),   .z1_inst(max_pooling_00), .inst_zctr(1'b0));

reg [31:0]com_F1_01_0;
reg [31:0]com_F1_01_1;

DW_fp_cmp_inst COM_F1_01_0 (.inst_a(max_pooling_in[0][2]), .inst_b(max_pooling_in[0][3]), .z1_inst(com_F1_01_0), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_01_1 (.inst_a(max_pooling_in[1][2]), .inst_b(max_pooling_in[1][3]), .z1_inst(com_F1_01_1), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_01   (.inst_a(com_F1_01_0),   .inst_b(com_F1_01_1),   .z1_inst(max_pooling_01), .inst_zctr(1'b0));

reg [31:0]com_F1_10_0;
reg [31:0]com_F1_10_1;

DW_fp_cmp_inst COM_F1_10_0 (.inst_a(max_pooling_in[2][0]), .inst_b(max_pooling_in[2][1]), .z1_inst(com_F1_10_0), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_10_1 (.inst_a(max_pooling_in[3][0]), .inst_b(max_pooling_in[3][1]), .z1_inst(com_F1_10_1), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_10   (.inst_a(com_F1_10_0),   .inst_b(com_F1_10_1),   .z1_inst(max_pooling_10), .inst_zctr(1'b0));


reg [31:0]com_F1_11_0;
reg [31:0]com_F1_11_1;

DW_fp_cmp_inst COM_F1_11_0 (.inst_a(max_pooling_in[2][2]), .inst_b(max_pooling_in[2][3]), .z1_inst(com_F1_11_0), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_11_1 (.inst_a(max_pooling_in[3][2]), .inst_b(max_pooling_in[3][3]), .z1_inst(com_F1_11_1), .inst_zctr(1'b0));
DW_fp_cmp_inst COM_F1_11   (.inst_a(com_F1_11_0),   .inst_b(com_F1_11_1),   .z1_inst(max_pooling_11), .inst_zctr(1'b0));


reg [31:0]fully_con_map_temp[0:3];
reg [31:0]fully_con_map_1[0:3];
reg [31:0]fully_con_map_2[0:3];

reg [31:0]dp2_mul_out[0:7];
DW_fp_mult_inst dp2_mul_1 (.inst_a(max_pooling_00), .inst_b(weight[0][0]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[0]));
DW_fp_mult_inst dp2_mul_2 (.inst_a(max_pooling_01), .inst_b(weight[1][0]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[1]));
DW_fp_add_inst  dp2_add_1 (.inst_a(dp2_mul_out[0]), .inst_b(dp2_mul_out[1]), .inst_rnd(3'b000), .z_inst(fully_con_map_temp[0]));

DW_fp_mult_inst dp2_mul_3 (.inst_a(max_pooling_00), .inst_b(weight[0][1]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[2]));
DW_fp_mult_inst dp2_mul_4 (.inst_a(max_pooling_01), .inst_b(weight[1][1]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[3]));
DW_fp_add_inst  dp2_add_2 (.inst_a(dp2_mul_out[2]), .inst_b(dp2_mul_out[3]), .inst_rnd(3'b000), .z_inst(fully_con_map_temp[1]));

DW_fp_mult_inst dp2_mul_5 (.inst_a(max_pooling_10), .inst_b(weight[0][0]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[4]));
DW_fp_mult_inst dp2_mul_6 (.inst_a(max_pooling_11), .inst_b(weight[1][0]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[5]));
DW_fp_add_inst  dp2_add_3 (.inst_a(dp2_mul_out[4]), .inst_b(dp2_mul_out[5]), .inst_rnd(3'b000), .z_inst(fully_con_map_temp[2]));

DW_fp_mult_inst dp2_mul_7 (.inst_a(max_pooling_10), .inst_b(weight[0][1]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[6]));
DW_fp_mult_inst dp2_mul_8 (.inst_a(max_pooling_11), .inst_b(weight[1][1]), .inst_rnd(3'b000), .z_inst(dp2_mul_out[7]));
DW_fp_add_inst  dp2_add_4 (.inst_a(dp2_mul_out[6]), .inst_b(dp2_mul_out[7]), .inst_rnd(3'b000), .z_inst(fully_con_map_temp[3]));


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            fully_con_map_1[i] <= 0;
        end
        for(i = 0; i < 4; i = i + 1) begin
            fully_con_map_2[i] <= 0;
        end
    end
    else begin
        for(i = 0; i < 4; i = i + 1) begin
            fully_con_map_1[i] <= fully_con_map_1[i];
        end
        for(i = 0; i < 4; i = i + 1) begin
            fully_con_map_2[i] <= fully_con_map_2[i];
        end
        if(counter == 66) begin
            for(i = 0; i < 4; i = i + 1) begin
                fully_con_map_1[i] <= fully_con_map_temp[i];
            end
        end
        else if(counter == 114) begin
            for(i = 0; i < 4; i = i + 1) begin
                fully_con_map_2[i] <= fully_con_map_temp[i];
            end
        end
    end
end


///////////////////////////////////////////////////////////
//////////////////////Normalization////////////////////////
///////////////////////////////////////////////////////////

reg [31:0]max_F1;
reg [31:0]min_F1;
reg [31:0]max_F1_0_1;
reg [31:0]min_F1_0_1;
reg [31:0]max_F1_2_3;
reg [31:0]min_F1_2_3;

reg [31:0]normal_in[0:3];

always @(*) begin
    for(i = 0; i < 4; i = i + 1) begin
        normal_in[i] = 0;
    end

    if(counter >= 67 && counter <= 70) begin ////////////////need to be changed/////////////////
        for(i = 0; i < 4; i = i + 1) begin
            normal_in[i] = fully_con_map_1[i];
        end
    end
    else if(counter >= 115 && counter <= 118) begin
        for(i = 0; i < 4; i = i + 1) begin
            normal_in[i] = fully_con_map_2[i];
        end
    end
end

DW_fp_cmp_inst MAX_F1_0_1 (.inst_a(normal_in[0]), .inst_b(normal_in[1]), .z0_inst(min_F1_0_1), .z1_inst(max_F1_0_1), .inst_zctr(1'b0));
DW_fp_cmp_inst MAX_F1_2_3 (.inst_a(normal_in[2]), .inst_b(normal_in[3]), .z0_inst(min_F1_2_3), .z1_inst(max_F1_2_3), .inst_zctr(1'b0));
DW_fp_cmp_inst MAX_F1     (.inst_a(max_F1_0_1),         .inst_b(max_F1_2_3),         .z1_inst(max_F1),    .inst_zctr(1'b0));
DW_fp_cmp_inst MIN_F1     (.inst_a(min_F1_0_1),         .inst_b(min_F1_2_3),         .z0_inst(min_F1),    .inst_zctr(1'b0));


reg [31:0]normal_F1[0:3];
reg [31:0]normal_F2[0:3];
reg [31:0]normal_temp;
reg [31:0]deno_F1;
reg [31:0]nume_F1[0:3];
reg [31:0]deno_F1_seq;
reg [31:0]nume_F1_seq[0:3];

reg [31:0]normal_div_in;

genvar a;

DW_fp_sub_inst sub_deno_F1 (.inst_a(max_F1), .inst_b(min_F1), .z_inst(deno_F1), .inst_rnd(3'b000));
DW_fp_sub_inst sub_nume_F2 (.inst_a(normal_in[0]), .inst_b(min_F1), .z_inst(nume_F1[0]),  .inst_rnd(3'b000));
DW_fp_sub_inst sub_nume_F3 (.inst_a(normal_in[1]), .inst_b(min_F1), .z_inst(nume_F1[1]),  .inst_rnd(3'b000));
DW_fp_sub_inst sub_nume_F4 (.inst_a(normal_in[2]), .inst_b(min_F1), .z_inst(nume_F1[2]),  .inst_rnd(3'b000));
DW_fp_sub_inst sub_nume_F5 (.inst_a(normal_in[3]), .inst_b(min_F1), .z_inst(nume_F1[3]),  .inst_rnd(3'b000));
DW_fp_div_inst div_F1      (.inst_a(normal_div_in), .inst_b(deno_F1_seq),.z_inst(normal_temp),.inst_rnd(3'b000));

always @(*) begin
    normal_div_in = 0; ////////////////trash/////////////////
    case(counter)
        68, 116 : normal_div_in = nume_F1_seq[0];
        69, 117 : normal_div_in = nume_F1_seq[1];
        70, 118 : normal_div_in = nume_F1_seq[2];
        71, 119 : normal_div_in = nume_F1_seq[3];
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        deno_F1_seq <= 0;
        for(i = 0; i < 4; i = i + 1) begin
            nume_F1_seq[i] <= 0;
        end
    end
    else begin
        deno_F1_seq <= deno_F1;
        for(i = 0; i < 4; i = i + 1) begin
            nume_F1_seq[i] <= nume_F1[i];
        end
    end

end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            normal_F1[i] <= 0;
        end
        for(i = 0; i < 4; i = i + 1) begin
            normal_F2[i] <= 0;
        end
    end
    else begin
        for(i = 0; i < 4; i = i + 1) begin
            normal_F1[i] <= normal_F1[i];
        end
        for(i = 0; i < 4; i = i + 1) begin
            normal_F2[i] <= normal_F2[i];
        end
        case(counter)
            68 : normal_F1[0] <= normal_temp;
            69 : normal_F1[1] <= normal_temp;
            70 : normal_F1[2] <= normal_temp;
            71 : normal_F1[3] <= normal_temp;
            116: normal_F2[0] <= normal_temp;
            117: normal_F2[1] <= normal_temp;
            118: normal_F2[2] <= normal_temp;
            119: normal_F2[3] <= normal_temp;
        endcase
    end
end


///////////////////////////////////////////////////////////
///////////////////Activation Function/////////////////////
///////////////////////////////////////////////////////////

reg [31:0]activation_in;

reg [31:0]sigmoid_out;
reg [31:0]sigmoid_deno;
reg [31:0]sigmoid_deno_seq;
reg [31:0]tanh_out;
reg [31:0]tanh_deno;
reg [31:0]tanh_nume;
reg [31:0]tanh_deno_seq;
reg [31:0]tanh_nume_seq;
reg [31:0]e_to_power_pos;
reg [31:0]e_to_power_neg;
reg [31:0]e_to_power_pos_seq;
reg [31:0]e_to_power_neg_seq;

reg [31:0]div_in_1;
reg [31:0]div_in_2;
reg [31:0]sig_tran_out;

always @(*) begin
    activation_in = 0;
    case(counter)
        69 : activation_in = normal_F1[0];
        70 : activation_in = normal_F1[1];
        71 : activation_in = normal_F1[2];
        72 : activation_in = normal_F1[3];
        117: activation_in = normal_F2[0];
        118: activation_in = normal_F2[1];
        119: activation_in = normal_F2[2];
        120: activation_in = normal_F2[3];
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        e_to_power_neg_seq = 0;
        e_to_power_pos_seq = 0;
    end
    else begin
        e_to_power_neg_seq = e_to_power_neg;
        e_to_power_pos_seq = e_to_power_pos;
    end
end

always @(*) begin
    if(Opt_seq[1] == 0) begin
        div_in_1 = 32'b00111111100000000000000000000000;
        div_in_2 = sigmoid_deno_seq;
    end
    else begin
        div_in_1 = tanh_nume_seq;
        div_in_2 = tanh_deno_seq;
    end

end

DW_fp_exp_inst F1_E_POS (.inst_a(activation_in), .z_inst(e_to_power_pos));
DW_fp_exp_inst F1_E_NEG (.inst_a({~activation_in[31] , activation_in[30:0]}), .z_inst(e_to_power_neg));


DW_fp_add_inst F1_SIG_deno (.inst_a(32'b00111111100000000000000000000000), .inst_b(e_to_power_neg_seq), .z_inst(sigmoid_deno), .inst_rnd(3'b000));
DW_fp_sub_inst F1_TANH_nume (.inst_a(e_to_power_pos_seq), .inst_b(e_to_power_neg_seq), .z_inst(tanh_nume), .inst_rnd(3'b000));
DW_fp_add_inst F1_TANH_deno (.inst_a(e_to_power_pos_seq), .inst_b(e_to_power_neg_seq), .z_inst(tanh_deno), .inst_rnd(3'b000));


DW_fp_div_inst SIG_F1   (.inst_a(div_in_1), .inst_b(div_in_2), .z_inst(sig_tran_out), .inst_rnd(3'b000));


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sigmoid_deno_seq <= 0;
        tanh_deno_seq <= 0;
        tanh_nume_seq <= 0;
    end
    else begin
        sigmoid_deno_seq <= sigmoid_deno;
        tanh_deno_seq <= tanh_deno;
        tanh_nume_seq <= tanh_nume;
    end
end



reg [31:0]sig_tran_F1[0:3];
reg [31:0]sig_tran_F2[0:3];


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            sig_tran_F1[i] <= 0;
        end
        for(i = 0; i < 4; i = i + 1) begin
            sig_tran_F2[i] <= 0;
        end
    end
    else begin
        for(i = 0; i < 4; i = i + 1) begin
            sig_tran_F1[i] <= sig_tran_F1[i];
        end
        for(i = 0; i < 4; i = i + 1) begin
            sig_tran_F2[i] <= sig_tran_F2[i];
        end
        case(counter)
            71 : sig_tran_F1[0] <= sig_tran_out;
            72 : sig_tran_F1[1] <= sig_tran_out;
            73 : sig_tran_F1[2] <= sig_tran_out;
            74 : sig_tran_F1[3] <= sig_tran_out;
            119: sig_tran_F2[0] <= sig_tran_out;
            120: sig_tran_F2[1] <= sig_tran_out;
            121: sig_tran_F2[2] <= sig_tran_out;
            122: sig_tran_F2[3] <= sig_tran_out;
        endcase
    end
end


///////////////////////////////////////////////////////////
///////////////////Activation Function/////////////////////
///////////////////////////////////////////////////////////
wire [31:0]p[0:3];
wire [31:0]q[0:3];
wire [31:0]golden_out_temp[0:3];
reg  [31:0]golden_out;
reg  [31:0]out_comb;

reg out_valid_comb;

generate
    for(a = 0; a < 4; a = a + 1) begin
        assign p[a] = sig_tran_F1[a];
        assign q[a] = sig_tran_F2[a];
        DW_fp_sub_inst GOLDEN_SUB (.inst_a(p[a]), .inst_b(q[a]), .z_inst(golden_out_temp[a]), .inst_rnd(3'b000));
    end
endgenerate

DW_fp_sum4_inst GOLDEN_SUM (.inst_a({1'b0, golden_out_temp[0][30:0]}), .inst_b({1'b0, golden_out_temp[1][30:0]}), .inst_c({1'b0, golden_out_temp[2][30:0]}), .inst_d({1'b0, golden_out_temp[3][30:0]}), .z_inst(golden_out), .inst_rnd(3'b000));

always @(*) begin
    if(counter == 123) begin
        out_valid_comb = 1;
        out_comb = golden_out;
    end
    else begin
        out_valid_comb = 0;
        out_comb = 0;
    end
end


///////////////////////////////////////////////////////////
//////////////////////////output///////////////////////////
///////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out <= 0;
    end
    else begin
        out_valid <= out_valid_comb;
        out <= out_comb;
    end
end
 
endmodule


module DW_fp_dp3_inst( inst_a, inst_b, inst_c, inst_d, inst_e,
inst_f, inst_rnd, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch_type = 0;


    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [inst_sig_width+inst_exp_width : 0] inst_c;
    input [inst_sig_width+inst_exp_width : 0] inst_d;
    input [inst_sig_width+inst_exp_width : 0] inst_e;
    input [inst_sig_width+inst_exp_width : 0] inst_f;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_dp3
    DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .d(inst_d),
    .e(inst_e),
    .f(inst_f),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_sum3_inst( inst_a, inst_b, inst_c, inst_rnd, z_inst,
status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch_type = 0;


    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [inst_sig_width+inst_exp_width : 0] inst_c;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_sum3
    DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_cmp_inst( inst_a, inst_b, inst_zctr, aeqb_inst, altb_inst,
    agtb_inst, unordered_inst, z0_inst, z1_inst, status0_inst,
    status1_inst );
    parameter sig_width = 23;
    parameter exp_width = 8;
    parameter ieee_compliance = 0;
    input [sig_width+exp_width : 0] inst_a;
    input [sig_width+exp_width : 0] inst_b;
    input inst_zctr;
    output aeqb_inst;
    output altb_inst;
    output agtb_inst;
    output unordered_inst;
    output [sig_width+exp_width : 0] z0_inst;
    output [sig_width+exp_width : 0] z1_inst;
    output [7 : 0] status0_inst;
    output [7 : 0] status1_inst;
    // Instance of DW_fp_cmp
    DW_fp_cmp #(sig_width, exp_width, ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .zctr(inst_zctr), .aeqb(aeqb_inst),
    .altb(altb_inst), .agtb(agtb_inst), .unordered(unordered_inst),
    .z0(z0_inst), .z1(z1_inst), .status0(status0_inst),
    .status1(status1_inst) );
endmodule

module DW_fp_dp2_inst( inst_a, inst_b, inst_c, inst_d, inst_rnd,
z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch_type = 0;
    
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [inst_sig_width+inst_exp_width : 0] inst_c;
    input [inst_sig_width+inst_exp_width : 0] inst_d;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_dp2
    DW_fp_dp2 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .d(inst_d),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_sub_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter sig_width = 23;
    parameter exp_width = 8;
    parameter ieee_compliance = 0;

    input [sig_width+exp_width : 0] inst_a;
    input [sig_width+exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [sig_width+exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_sub
    DW_fp_sub #(sig_width, exp_width, ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule

module DW_fp_div_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter sig_width = 23;
    parameter exp_width = 8;
    parameter ieee_compliance = 0;
    parameter faithful_round = 0;
    
    input [sig_width+exp_width : 0] inst_a;
    input [sig_width+exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [sig_width+exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_div
    DW_fp_div #(sig_width, exp_width, ieee_compliance, faithful_round) U1
    ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst)
    );
endmodule

module DW_fp_exp_inst( inst_a, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch = 0;

    input [inst_sig_width+inst_exp_width : 0] inst_a;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_exp
    DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U1 (
    .a(inst_a),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_add_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter sig_width = 23;
    parameter exp_width = 8;
    parameter ieee_compliance = 0;
    input [sig_width+exp_width : 0] inst_a;
    input [sig_width+exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [sig_width+exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_add
    DW_fp_add #(sig_width, exp_width, ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule

module DW_fp_sum4_inst( inst_a, inst_b, inst_c, inst_d, inst_rnd,
z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch_type = 0;
    
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [inst_sig_width+inst_exp_width : 0] inst_c;
    input [inst_sig_width+inst_exp_width : 0] inst_d;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_sum4
    DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .d(inst_d),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_mult_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter sig_width = 23;
    parameter exp_width = 8;
    parameter ieee_compliance = 0;
    input [sig_width+exp_width : 0] inst_a;
    input [sig_width+exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [sig_width+exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_mult
    DW_fp_mult #(sig_width, exp_width, ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule