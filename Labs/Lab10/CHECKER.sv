/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype_BEV.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

/*
    Coverage Part
*/

logic [1:0]act_id;

class BEV;
    Bev_Type bev_type;
    Bev_Size bev_size;
endclass

BEV bev_info = new();

always_ff @(posedge clk) begin
    if (inf.type_valid) begin
        bev_info.bev_type = inf.D.d_type[0];
    end

    if (inf.size_valid) begin
        bev_info.bev_size = inf.D.d_size[0];
    end

    if(inf.sel_action_valid) begin
        act_id = inf.D.d_act[0];
    end
end

/*
1. Each case of Beverage_Type should be select at least 100 times.
*/

covergroup Spec1 @(posedge clk iff inf.type_valid);
    option.per_instance = 1;
    option.at_least = 100;
    coverpoint bev_info.bev_type{
        bins b_bev_type [] = {[Black_Tea:Super_Pineapple_Milk_Tea]};
    }
endgroup

/*
2.	Each case of Bererage_Size should be select at least 100 times.
*/

covergroup Spec2 @(posedge clk iff inf.size_valid);
    option.per_instance = 1;
    option.at_least = 100;
    coverpoint bev_info.bev_size{
        bins b_bev_size [] = {[L:S]};
    }
endgroup


/*
3.	Create a cross bin for the SPEC1 and SPEC2. Each combination should be selected at least 100 times. 
(Black Tea, Milk Tea, Extra Milk Tea, Green Tea, Green Milk Tea, Pineapple Juice, Super Pineapple Tea, Super Pineapple Tea) x (L, M, S)
*/

covergroup Spec3 @(posedge clk iff inf.size_valid);
    option.per_instance = 1;
    option.at_least = 100;
    coverpoint bev_info.bev_type{
        bins b_bev_type [] = {[Black_Tea:Super_Pineapple_Milk_Tea]};
    }
    coverpoint bev_info.bev_size{
        bins b_bev_size [] = {[L:S]};
    }
    cross bev_info.bev_type, bev_info.bev_size;
endgroup


/*
4.	Output signal inf.err_msg should be No_Err, No_Exp, No_Ing and Ing_OF, each at least 20 times. (Sample the value when inf.out_valid is high)
*/

covergroup Spec4 @(posedge clk iff inf.out_valid);
    option.per_instance = 1;
    option.at_least = 20;
    coverpoint inf.err_msg {
        bins err[] = {[No_Err:Ing_OF]};
    }
endgroup

/*
5.	Create the transitions bin for the inf.D.act[0] signal from [0:2] to [0:2]. Each transition should be hit at least 200 times. (sample the value at posedge clk iff inf.sel_action_valid)
*/

covergroup Spec5 @(posedge clk iff inf.sel_action_valid);
    option.per_instance = 1;
    option.at_least = 200;
    coverpoint inf.D.d_act[0] {
        bins act_trans [] = ([0:2] => [0:2]);
    }
endgroup

/*
6.	Create a covergroup for material of supply action with auto_bin_max = 32, and each bin have to hit at least one time.
*/

covergroup Spec6 @(posedge clk iff inf.box_sup_valid);
    option.per_instance = 1;
    option.at_least = 1;
    coverpoint inf.D.d_ing[0] {
        option.auto_bin_max = 32;
    }
endgroup

/*
    Create instances of Spec1, Spec2, Spec3, Spec4, Spec5, and Spec6
*/

Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();
Spec6 cov_inst_6 = new();

/*
    Asseration
*/

/*
    If you need, you can declare some FSM, logic, flag, and etc. here.
*/

logic [4:0]counter_3;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        counter_3 <= 0;
    end
    else begin
        if(inf.box_sup_valid) begin
            counter_3 <= counter_3 + 1;
        end
        else if(inf.out_valid) begin
            counter_3 <= 0;
        end
    end
end


/*
    1. All outputs signals (including BEV.sv and bridge.sv) should be zero after reset.
*/



always @(negedge inf.rst_n) begin
    #1;
    assert_1 : assert (
        (inf.C_out_valid === 0 && inf.C_data_r === 0 && inf.AR_VALID === 0   && 
         inf.AR_ADDR === 0     && inf.R_READY === 0  && inf.AW_VALID === 0   && 
         inf.AW_ADDR === 0     && inf.W_VALID === 0  && inf.W_DATA === 0     && 
         inf.B_READY === 0     &&
         inf.out_valid === 0   && inf.err_msg === 0  && inf.complete === 0   &&
         inf.C_addr === 0      && inf.C_data_w === 0 && inf.C_in_valid === 0 && 
         inf.C_r_wb === 0)
    )
    else begin
        $fatal(0, "Assertion 1 is violated");
    end
end

/*
    2.	Latency should be less than 1000 cycles for each operation.
*/

assert_2_1 : assert property (@(negedge clk) (act_id == 2'd0 && inf.box_no_valid === 1) |-> (##[1:1000] inf.out_valid))
else begin
    $fatal(0, "Assertion 2 is violated");
end

assert_2_2 : assert property (@(negedge clk) (act_id == 2'd1 && inf.box_sup_valid === 1) |-> (##[1:1000] inf.out_valid))
else begin
    $fatal(0, "Assertion 2 is violated");
end

assert_2_3 : assert property (@(negedge clk) (act_id == 2'd2 && inf.box_no_valid === 1) |-> (##[1:1000] inf.out_valid))
else begin
    $fatal(0, "Assertion 2 is violated");
end

/*
    3. If out_valid does not pull up, complete should be 0.
*/

// assert_3 : assert property (@(posedge inf.complete) (inf.out_valid === 0 |-> inf.complete === 0))
// else begin
//     $fatal(0, "Assertion 3 is violated");
// end
always @(posedge inf.complete) begin
    assert (inf.out_valid === 1 && inf.err_msg === 0)
    else begin
        $fatal(0, "Assertion 3 is violated");
    end
end


/*
    4. Next input valid will be valid 1-4 cycles after previous input valid fall.
*/

assert_4_1_1 : assert property (@(negedge clk) (inf.sel_action_valid === 1) |-> ((##[1:4] (inf.type_valid === 1 || inf.date_valid === 1))))
else begin
    $fatal(0, "Assertion 4 is violated");
end
assert_4_1_2 : assert property (@(negedge clk) (inf.type_valid === 1) |-> (##[1:4] (inf.size_valid === 1)))
else begin
    $fatal(0, "Assertion 4 is violated");
end
assert_4_1_3 : assert property (@(negedge clk) (inf.size_valid === 1) |-> (##[1:4] (inf.date_valid === 1)))
else begin
    $fatal(0, "Assertion 4 is violated");
end
assert_4_1_4 : assert property (@(negedge clk) (inf.date_valid === 1) |-> (##[1:4] (inf.box_no_valid === 1)))
else begin
    $fatal(0, "Assertion 4 is violated");
end


// assert_4_2_1 : assert property (@(negedge clk) (act_id == 1 && inf.sel_action_valid === 1) |-> (##[1:4] (inf.date_valid === 1)))
// else begin
//     $fatal(0, "Assertion 4 is violated");
// end
// assert_4_2_2 : assert property (@(negedge clk) (act_id == 1 && inf.date_valid === 1) |-> (##[1:4] (inf.box_no_valid === 1)))
// else begin
//     $fatal(0, "Assertion 4 is violated");
// end
assert_4_2_3 : assert property (@(negedge clk) (act_id == 1 && inf.box_no_valid === 1) |-> (##[1:4] (inf.box_sup_valid === 1)))
else begin
    $fatal(0, "Assertion 4 is violated");
end
assert_4_2_4 : assert property (@(negedge clk) (counter_3 != 4 && inf.box_sup_valid === 1) |-> (##[1:4] (inf.box_sup_valid === 1)))
else begin
    $fatal(0, "Assertion 4 is violated");
end


// assert_4_3_1 : assert property (@(negedge clk) (act_id == 2 && inf.sel_action_valid === 1) |-> (##[1:4] (inf.date_valid === 1)))
// else begin
//     $fatal(0, "Assertion 4 is violated");
// end
// assert_4_3_2 : assert property (@(negedge clk) (act_id == 2 && inf.date_valid === 1) |-> (##[1:4] (inf.box_no_valid === 1)))
// else begin
//     $fatal(0, "Assertion 4 is violated");
// end

/*
    5. All input valid signals won't overlap with each other. 
*/

logic [2:0]num_of_valids;
assign num_of_valids = inf.sel_action_valid + inf.type_valid + inf.size_valid + inf.date_valid + inf.box_no_valid + inf.box_sup_valid;
assert_5 : assert property (@(posedge clk) (num_of_valids <= 1))
else begin
    $fatal(0, "Assertion 5 is violated");
end

/*
    6. Out_valid can only be high for exactly one cycle.
*/

assert_6 : assert property (@(negedge clk) (inf.out_valid === 1) |-> ##1 (inf.out_valid === 0))
else begin
    $fatal(0, "Assertion 6 is violated");
end

/*
    7. Next operation will be valid 1-4 cycles after out_valid fall.
*/

assert_7 : assert property (@(negedge clk) (inf.out_valid === 1) |-> ##[2:5] (inf.sel_action_valid === 1))
else begin
    $fatal(0, "Assertion 7 is violated");
end

/*
    8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)
*/

always @(posedge clk) begin
    if(inf.date_valid) begin
        assert_8 : assert (!(inf.D.d_date[0].M > 12 || (inf.D.d_date[0].M == 2 && inf.D.d_date[0].D > 28) || (inf.D.d_date[0].M == 4 && inf.D.d_date[0].D > 30) ||
                          (inf.D.d_date[0].M == 6 && inf.D.d_date[0].D > 30) || (inf.D.d_date[0].M == 9 && inf.D.d_date[0].D > 30) || 
                          (inf.D.d_date[0].M == 11 && inf.D.d_date[0].D > 30) || (inf.D.d_date[0].D > 31) || (inf.D.d_date[0].D == 0) || (inf.D.d_date[0].M == 0)))
        else begin
            $fatal(0, "Assertion 8 is violated");
        end
    end
end

/*
    9. C_in_valid can only be high for one cycle and can't be pulled high again before C_out_valid
*/

assert_9 : assert property(@(negedge clk) ((inf.C_in_valid === 1) |-> ##1(inf.C_in_valid === 0)))
else begin
    $fatal(0, "Assertion 9 is violated");
end 

endmodule
