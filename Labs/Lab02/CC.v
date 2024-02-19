module CC(
    //Input Port
    clk,
    rst_n,
	in_valid,
	mode,
    xi,
    yi,

    //Output Port
    out_valid,
	xo,
	yo
    );

input               clk, rst_n, in_valid;
input       [1:0]   mode;
input    signed   [7:0]   xi, yi;  

output reg          out_valid;
output reg signed [7:0]   xo, yo;
//==============================================//
//             Parameter and Integer            //
//==============================================//
parameter IDLE = 0;
parameter M_0  = 1;
parameter M_1  = 2;
parameter OUT  = 3;

//==============================================//
//                 reg declaration              //
//==============================================//
reg [1:0] mode_seq;
reg [1:0] cur_state;
reg [1:0] nxt_state;
reg [2:0] counter_4;
reg cnt_4_mode0;
reg cnt_4_mode0_seq;
reg out_valid_comb;
//////////////////////mode 0////////////////////////
reg  signed [8:0] dx_l;
reg  signed [8:0] dx_r;
reg  signed [8:0] dy;
reg  signed [8:0] dy2;
reg  signed [7:0] xo_comb;
reg  signed [7:0] yo_comb;
reg  signed [10:0] x_ubound_comb;
reg  signed [10:0] x_lbound_comb;
reg  signed [10:0] x_ubound_seq;
reg  signed [10:0] x_lbound_seq;
reg  signed [8:0]  distance_y;

// wire signed [17:0] dy_times_xdl;
wire signed [17:0] dy_times_xdr;

reg signed [7:0] x_ul;
reg signed [7:0] y_u;
reg signed [7:0] y_u2;
reg signed [7:0] x_ur;
reg signed [7:0] x_dl;
reg signed [7:0] y_d;
reg signed [7:0] y_d2;
reg signed [7:0] x_dr;
//////////////////////////////////////////////////

//////////////////////mode 1////////////////////////
reg  signed [8:0]  a;
reg  signed [8:0]  b;
reg  signed [16:0] c;
reg  signed [18:0] a_x_plus_b_y_plus_c;
wire [37:0] numerator;
reg  [37:0] numerator_seq;
reg  signed [18:0] denominator;
reg  [18:0] radius;
// wire [37:0] radius_times_de;

reg  signed [18:0] var_4_nu[0:1];
reg  signed [8:0]  var_4_de[0:3];
reg  signed [8:0]  var_4_ra[0:3];

always @(*) begin
    if(counter_4 == 3) begin
        var_4_nu[0] = a_x_plus_b_y_plus_c;
        var_4_nu[1] = a_x_plus_b_y_plus_c;
    end
    else begin
        var_4_nu[0] = denominator;
        var_4_nu[1] = radius;
    end
end

always @(*) begin
    if(mode_seq == 1) begin
        var_4_de[0] = a;
        var_4_de[1] = a;
        var_4_de[2] = b;
        var_4_de[3] = b;
    end
    else if(mode_seq == 2) begin
        var_4_de[0] = dx_l;
        var_4_de[1] = dy2;
        var_4_de[2] = -dx_r;
        var_4_de[3] = dy;
    end
    else begin
        var_4_de[0] = x_dl;
        var_4_de[1] = dy;
        var_4_de[2] = dx_l;
        var_4_de[3] = distance_y + 1;
    end
end

always @(*) begin
    if(mode_seq == 1) begin
        var_4_ra[0] = x_dl - x_dr;
        var_4_ra[1] = x_dl - x_dr;
        var_4_ra[2] = y_d - y_d2;
        var_4_ra[3] = y_d - y_d2;
    end
    else begin
        var_4_ra[0] = x_dr;
        var_4_ra[1] = dy;
        var_4_ra[2] = dx_r;
        var_4_ra[3] = distance_y;
    end
end

assign numerator = var_4_nu[0] * var_4_nu[1];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        numerator_seq <= 0;
    end
    else begin
        numerator_seq <= numerator;
    end
end

assign denominator = var_4_de[0] * var_4_de[1] + var_4_de[2] * var_4_de[3];

assign radius = var_4_ra[0] * var_4_ra[1] + var_4_ra[2] * var_4_ra[3];

// assign radius_times_de = denominator * radius;
//////////////////////////////////////////////////

//////////////////////mode 2////////////////////////
// wire signed [16:0]sum;
wire signed [15:0]A;

// assign sum = dx_l * dy2 - dx_r  * dy;
assign A = (denominator >= 0) ?  denominator >> 1 : (-denominator) >> 1;
//////////////////////////////////////////////////


//==============================================//
//            FSM State Declaration             //
//==============================================//

reg  signed [7:0]temp;
wire signed [15:0]dy_times_xdl_or_xdr;
reg  signed [15:0]dy_times_xdl_or_xdr_seq;
wire signed [15:0]temp_times_dy;

////////////////////////////
// assign dy_times_xdl = x_dl * dy  + dx_l * (distance_y + 1);
// assign dy_times_xdr = x_dr * dy  + dx_r * (distance_y);

assign dy_times_xdl_or_xdr = (cnt_4_mode0) ? denominator : radius;


always @(*) begin
    if(nxt_state == M_0) begin
        cnt_4_mode0 = 1;
    end
    else if(xo == x_ubound_comb - 1) begin
        cnt_4_mode0 = 1;
    end
    else begin
        cnt_4_mode0 = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dy_times_xdl_or_xdr_seq <= 0;
        temp <= 0;
        x_lbound_seq <= 0;
        x_ubound_seq <= 0;
        cnt_4_mode0_seq <= 0;
    end
    else begin
        dy_times_xdl_or_xdr_seq <= dy_times_xdl_or_xdr;
        temp <= (dy != 0) ? dy_times_xdl_or_xdr / dy : temp;
        x_lbound_seq <= x_lbound_comb;
        x_ubound_seq <= x_ubound_comb;
        cnt_4_mode0_seq <= cnt_4_mode0;
    end
end

assign temp_times_dy = temp * dy;


always @(*) begin
    if(cnt_4_mode0_seq) begin // calculate lower bound
        x_ubound_comb = x_ubound_seq;
        if(dy_times_xdl_or_xdr_seq != temp_times_dy && dy_times_xdl_or_xdr_seq < 0) begin
            x_lbound_comb = temp - 1;
        end
        else begin
            x_lbound_comb = temp;
        end
    end
    else begin // calculate upper bound
        x_lbound_comb = x_lbound_seq;
        if(dy_times_xdl_or_xdr_seq != temp_times_dy && dy_times_xdl_or_xdr_seq < 0) begin
            x_ubound_comb = temp - 1;
        end
        else begin
            x_ubound_comb = temp;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        distance_y <= 0;
    end
    else begin
        if(cur_state == OUT) begin
            if(xo == x_ubound_comb - 1) begin
                distance_y <= distance_y + 1;
            end
            else begin
                distance_y <= distance_y;
            end
        end
        else begin
            distance_y <= 0;
        end
    end
end
////////////////////////////
always @(*) begin
    case(cur_state)
        IDLE : begin
            if(mode_seq == 2) begin
                xo_comb = A[15:8];
                yo_comb = A[7:0];
            end
            else if(mode_seq == 1) begin
                if(numerator_seq > numerator) begin
                    xo_comb = 0;
                    yo_comb = 0;
                end
                else if(numerator_seq < numerator) begin
                    xo_comb = 0;
                    yo_comb = 1;
                end
                else begin
                    xo_comb = 0;
                    yo_comb = 2;
                end
            end
            else begin
                xo_comb = x_dl;
                yo_comb = y_d;
            end
        end
        M_0 : begin //mode 0
            xo_comb = x_dl;
            yo_comb = y_d;
        end
        OUT : begin
            if(xo < x_ubound_comb) begin
                xo_comb = xo + 1;
                yo_comb = yo;
            end
            else begin
                xo_comb = x_lbound_comb;
                yo_comb = yo + 1;
            end
        end
        default : begin
            xo_comb = 0;
            yo_comb = 0;
        end
    endcase
end

always @(*) begin
    case(cur_state)
        IDLE : begin
            if(mode_seq >= 1 && counter_4 == 4) begin
                out_valid_comb = 1;
            end
            else begin
                out_valid_comb = 0;
            end
        end
        M_0 : begin //mode 0
            out_valid_comb = 1;
        end
        OUT : begin
            if(xo > x_ur - 1 && yo > y_u - 1) begin
                out_valid_comb = 0;
            end
            else begin
                out_valid_comb = 1;
            end
        end
        default : begin
            out_valid_comb = 0;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_comb;
    end
end

//==============================================//
//              Next State Block                //
//==============================================//

always @(*) begin
    case(cur_state)
        IDLE : begin
            if(in_valid) begin
                if(mode_seq == 0 && counter_4 == 3)
                    nxt_state = M_0;
                else
                    nxt_state = IDLE;
            end
            else begin
                nxt_state = IDLE;
            end
        end
        M_0 : begin
            nxt_state = OUT;
        end
        OUT : begin
            if(xo > x_ur - 1 && yo > y_u - 1) begin
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

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end


//==============================================//
//                  Input Block                 //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mode_seq <= 0;
        x_ul <= 0;
        x_ur <= 0;
        x_dl <= 0;
        x_dr <= 0;
        y_u  <= 0;
        y_u2 <= 0;
        y_d  <= 0;
        y_d2 <= 0;
        counter_4 <= 0;
        a <= 0;
        b <= 0;
        c <= 0;
        a_x_plus_b_y_plus_c <= 0;
        dx_l <= 0;
        dx_r <= 0;
        dy   <= 0;
        dy2  <= 0;
    end
    else begin
        if(in_valid) begin            
            mode_seq <= mode;
            case(counter_4)
                2'd0 : begin
                    x_ul <= xi;
                    x_ur <= x_ur;
                    x_dl <= x_dl;
                    x_dr <= x_dr;
                    y_u  <= yi;
                    y_u2 <= y_u2;
                    y_d  <= y_d;
                    y_d2 <= y_d2;
                    a <= a;
                    b <= b;
                    c <= c;
                    a_x_plus_b_y_plus_c <= a_x_plus_b_y_plus_c;
                    dx_l <= dx_l;
                    dx_r <= dx_r;
                    dy   <= dy;
                    dy2  <= dy2;
                end
                2'd1 : begin
                    x_ul <= x_ul;
                    x_ur <= xi;
                    x_dl <= x_dl;
                    x_dr <= x_dr;
                    y_u  <= y_u;
                    y_u2 <= yi;
                    y_d  <= y_d;
                    y_d2 <= y_d2;
                    a <= y_u  - yi;
                    b <= xi - x_ul;
                    c <= yi * x_ul - y_u  * xi;
                    a_x_plus_b_y_plus_c <= a_x_plus_b_y_plus_c;
                    dx_l <= dx_l;
                    dx_r <= dx_r;
                    dy   <= dy;
                    dy2  <= dy2;
                end
                2'd2 : begin
                    x_ul <= x_ul;
                    x_ur <= x_ur;
                    x_dl <= xi;
                    x_dr <= x_dr;
                    y_u  <= y_u;
                    y_u2 <= y_u2;
                    y_d  <= yi;
                    y_d2 <= y_d2;
                    a <= a;
                    b <= b;
                    c <= c;
                    a_x_plus_b_y_plus_c <= a*xi + b*yi + c;
                    dx_l <= dx_l;
                    dx_r <= dx_r;
                    dy   <= dy;
                    dy2  <= dy2;
                end
                2'd3 : begin
                    x_ul <= x_ul;
                    x_ur <= x_ur;
                    x_dl <= x_dl;
                    x_dr <= xi;
                    y_u  <= y_u;
                    y_u2 <= y_u2;
                    y_d  <= y_d;
                    y_d2 <= yi;
                    a    <= a;
                    b    <= b;
                    c    <= c;
                    a_x_plus_b_y_plus_c <= a_x_plus_b_y_plus_c;
                    dx_l <= x_ul - x_dl;
                    dx_r <= x_ur - xi;
                    dy   <= y_u  - y_d;
                    dy2  <= y_u2 - yi;
                end
                default : begin
                    x_ul <= x_ul;
                    x_ur <= x_ur;
                    x_dl <= x_dl;
                    x_dr <= x_dr;
                    y_u  <= y_u;
                    y_u2 <= y_u2;
                    y_d  <= y_d;
                    y_d2 <= y_d2;
                    a <= a;
                    b <= b;
                    c <= c;
                    a_x_plus_b_y_plus_c <= a_x_plus_b_y_plus_c;
                    dx_l <= dx_l;
                    dx_r <= dx_r;
                    dy   <= dy;
                    dy2  <= dy2;
                end
            endcase
            counter_4 <= counter_4 + 1;
        end
        else begin
            mode_seq <= mode_seq;
            x_ul <= x_ul;
            x_ur <= x_ur;
            x_dl <= x_dl;
            x_dr <= x_dr;
            y_u  <= y_u;
            y_u2 <= y_u2;
            y_d  <= y_d;
            y_d2 <= y_d2;
            a <= a;
            b <= b;
            c <= c;
            a_x_plus_b_y_plus_c <= a_x_plus_b_y_plus_c;
            dx_l <= dx_l;
            dx_r <= dx_r;
            dy   <= dy;
            dy2  <= dy2;
            counter_4 <= 0;
        end
    end
end


//==============================================//
//                Output Block                  //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        xo <= 0;
        yo <= 0;
    end
    else begin
        xo <= xo_comb;
        yo <= yo_comb;
    end

end


endmodule