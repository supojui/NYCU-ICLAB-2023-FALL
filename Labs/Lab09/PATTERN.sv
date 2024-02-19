/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype_BEV.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter DRAM_p_w = "../00_TESTBED/DRAM/output.dat";

//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  

//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    randc Action act_id;
    constraint range{
        act_id inside{Make_drink, Supply, Check_Valid_Date};
    }
endclass

/**
 * Class representing a random box from 0 to 255.
 */
class random_box;
    randc logic [7:0] box_id;
    constraint range{
        box_id inside{[0:255]};
    }
endclass

/**
 * Class representing a random bev type.
 */
class random_bev;
    randc Bev_Type bev;
    constraint range{
        bev inside{ Black_Tea      	         ,
                    Milk_Tea	             ,
                    Extra_Milk_Tea           ,
                    Green_Tea 	             ,
                    Green_Milk_Tea           ,
                    Pineapple_Juice          ,
                    Super_Pineapple_Tea      ,
                    Super_Pineapple_Milk_Tea };
    }
endclass

/**
 * Class representing a random bev size L M S.
 */
class random_size;
    randc Bev_Size size;
    constraint range{
        size inside{ L ,
                     M ,
                     S  };
    }
endclass

//================================================================
// initial
//================================================================


parameter CYCLE = 2.5;

integer i, j, latency, total_latency, i_pat, t;
random_act act_rand;
random_box box_rand;
random_bev  bev_type_rand;
random_size bev_size_rand;
Date date;
logic [11:0]black_tea_ing;
logic [11:0]green_tea_ing;
logic [11:0]milk_ing;
logic [11:0]pineapple_juice_ing;


logic [11:0]golden_black_tea;
logic [11:0]golden_green_tea;
logic [11:0]golden_milk;
logic [11:0]golden_pineapple_juice;
logic [3:0]golden_month;
logic [4:0]golden_day;
logic [1:0]golden_err;



logic [11:0]black_tea_need;
logic [11:0]green_tea_need;
logic [11:0]milk_need;
logic [11:0]pineapple_juice_need;


logic [12:0]black_tea_total;
logic [12:0]green_tea_total;
logic [12:0]milk_total;
logic [12:0]pineapple_juice_total;



initial begin 
    $readmemh(DRAM_p_r, golden_DRAM);
    act_rand = new();
    box_rand = new();
    bev_type_rand = new();
    bev_size_rand = new();
    total_latency = 0;
	reset_task;
    for(i_pat = 0; i_pat < 10000; i_pat = i_pat + 1) begin
		input_task;
    	latency = 0;
        wait_out_valid_task;
		check_ans_task;
		$display ("             \033[0;%2dmPass Pattern NO. %d    latency = %d  \033[m    ", 31+(i_pat%7), i_pat, latency);
        repeat($urandom_range(0,3)) @(negedge clk);
	end
    $writememh(DRAM_p_w, golden_DRAM);
	YOU_PASS_TASK;

end


task reset_task; begin
    inf.rst_n = 1'b1;
    inf.sel_action_valid = 1'b0;
    inf.type_valid = 1'b0;
    inf.size_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.box_no_valid = 1'b0;
    inf.box_sup_valid = 1'b0;
    inf.D = 'dx;

    force clk = 0;

    #(10); inf.rst_n = 0;
    #(50); inf.rst_n = 1;
    
	release clk;
    // check output reset
    if(inf.out_valid !== 1'b0 || inf.complete !== 1'b0 || inf.err_msg !== 2'b00) begin
        YOU_FAIL_TASK;
        $display("************************************************************");
        $display("*  Output signal should be 0 after initial RESET           *");
        $display("************************************************************");
        repeat(2) @(negedge clk);
        $finish;
    end

end
endtask

task input_task; begin
    t = $urandom_range(0, 3);
    repeat(t) @(negedge clk);

    inf.sel_action_valid = 'b1;
    act_rand.randomize();
    inf.D = act_rand.act_id;
    @(negedge clk);

    inf.sel_action_valid = 'b0;
    inf.D = 'bx;
    t = $urandom_range(0, 3);
    repeat(t) @(negedge clk);

    if(act_rand.act_id == Make_drink) begin
        ///////////////////////////////
        ////////input 4 bev type///////
        ///////////////////////////////
        inf.type_valid = 'b1;
        bev_type_rand.randomize();
        inf.D = bev_type_rand.bev;
        @(negedge clk);
        inf.type_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        

        
        ///////////////////////////////
        ////////input 4 bev size///////
        ///////////////////////////////
        inf.size_valid = 'b1;
        bev_size_rand.randomize();
        inf.D = bev_size_rand.size;
        @(negedge clk);
        inf.size_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);


        
        ///////////////////////////////
        //////////input 4 date/////////
        ///////////////////////////////
        date.M = $urandom_range(1, 12);
        if(date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 ||
           date.M == 10|| date.M == 12) begin
            date.D = $urandom_range(1, 31);
        end
        else if(date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) begin
            date.D = $urandom_range(1, 30);
        end
        else if(date.M == 2) begin
            date.D = $urandom_range(1, 28);
        end
        inf.date_valid = 'b1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);

        
        
        ///////////////////////////////
        ////////input 4 box num////////
        ///////////////////////////////
        inf.box_no_valid = 'b1;
        box_rand.randomize();
        inf.D = box_rand.box_id;
        @(negedge clk);
        inf.box_no_valid = 'b0;
        inf.D = 'bx;
    end
    else if(act_rand.act_id == Supply) begin
        ///////////////////////////////
        //////////input 4 date/////////
        ///////////////////////////////
        date.M = $urandom_range(1, 12);
        if(date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 ||
           date.M == 10|| date.M == 12) begin
            date.D = $urandom_range(1, 31);
        end
        else if(date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) begin
            date.D = $urandom_range(1, 30);
        end
        else if(date.M == 2) begin
            date.D = $urandom_range(1, 28);
        end
        inf.date_valid = 'b1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);

        
        ///////////////////////////////
        ////////input 4 box num////////
        ///////////////////////////////
        inf.box_no_valid = 'b1;
        box_rand.randomize();
        inf.D = box_rand.box_id;
        @(negedge clk);
        inf.box_no_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);

        
        
        ///////////////////////////////
        ///////input 4 ingrediant//////
        ///////////////////////////////
        inf.box_sup_valid = 'b1;
        black_tea_ing = $urandom_range(0, 4095);
        inf.D = black_tea_ing;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);

        inf.box_sup_valid = 'b1;
        green_tea_ing = $urandom_range(0, 4095);
        inf.D = green_tea_ing;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        
        inf.box_sup_valid = 'b1;
        milk_ing = $urandom_range(0, 4095);
        inf.D = milk_ing;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        
        inf.box_sup_valid = 'b1;
        pineapple_juice_ing = $urandom_range(0, 4095);
        inf.D = pineapple_juice_ing;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        
    end
    else if(act_rand.act_id == Check_Valid_Date) begin
        ///////////////////////////////
        //////////input 4 date/////////
        ///////////////////////////////
        date.M = $urandom_range(1, 12);
        if(date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 ||
           date.M == 10|| date.M == 12) begin
            date.D = $urandom_range(1, 31);
        end
        else if(date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) begin
            date.D = $urandom_range(1, 30);
        end
        else if(date.M == 2) begin
            date.D = $urandom_range(1, 28);
        end
        inf.date_valid = 'b1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);

        
        ///////////////////////////////
        ////////input 4 box num////////
        ///////////////////////////////
        inf.box_no_valid = 'b1;
        box_rand.randomize();
        inf.D = box_rand.box_id;
        @(negedge clk);
        inf.box_no_valid = 'b0;
        inf.D = 'bx;

    end

end endtask

task wait_out_valid_task; begin
    while(inf.out_valid !== 1'b1) begin
        latency = latency + 1;
        if(latency == 1000) begin
            YOU_FAIL_TASK;
            $display("*************************************************************************");
            $display("                           fail pattern: %d                           ", i_pat);
            $display("             The execution latency is limited in 1000 cycle              ");
            $display("*************************************************************************");
            $finish;
        end

        @(negedge clk);
    end
    total_latency = total_latency + latency;
end
endtask

task check_ans_task; begin
    golden_black_tea       = {golden_DRAM[65536+ 7 +8*box_rand.box_id],      golden_DRAM[65536+ 6 +8*box_rand.box_id][7:4]};
    golden_green_tea       = {golden_DRAM[65536+ 6 +8*box_rand.box_id][3:0], golden_DRAM[65536+ 5 +8*box_rand.box_id]};
    golden_milk            = {golden_DRAM[65536+ 3 +8*box_rand.box_id],      golden_DRAM[65536+ 2 +8*box_rand.box_id][7:4]};
    golden_pineapple_juice = {golden_DRAM[65536+ 2 +8*box_rand.box_id][3:0], golden_DRAM[65536+ 1 +8*box_rand.box_id]};
    golden_month           = {golden_DRAM[65536+ 4 +8*box_rand.box_id]};
    golden_day             = {golden_DRAM[65536+ 0 +8*box_rand.box_id]};
    
    black_tea_need       = 0;
    green_tea_need       = 0;
    milk_need            = 0;
    pineapple_juice_need = 0;

    black_tea_total       = 0;
    green_tea_total       = 0;
    milk_total            = 0;
    pineapple_juice_total = 0;

    
    case(bev_type_rand.bev)
        Black_Tea : begin
            black_tea_need = (bev_size_rand.size == L) ? 960 : (bev_size_rand.size == M) ? 720 : 480;
        end
        Milk_Tea : begin
            black_tea_need = (bev_size_rand.size == L) ? 720 : (bev_size_rand.size == M) ? 540 : 360;
            milk_need      = (bev_size_rand.size == L) ? 240 : (bev_size_rand.size == M) ? 180 : 120;
        end
        Extra_Milk_Tea : begin
            black_tea_need = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
            milk_need      = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
        end
        Green_Tea : begin
            green_tea_need = (bev_size_rand.size == L) ? 960 : (bev_size_rand.size == M) ? 720 : 480;
        end
        Green_Milk_Tea : begin
            green_tea_need = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
            milk_need      = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
        end
        Pineapple_Juice : begin
            pineapple_juice_need = (bev_size_rand.size == L) ? 960 : (bev_size_rand.size == M) ? 720 : 480;
        end
        Super_Pineapple_Tea : begin
            black_tea_need       = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
            pineapple_juice_need = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
        end
        Super_Pineapple_Milk_Tea : begin
            black_tea_need       = (bev_size_rand.size == L) ? 480 : (bev_size_rand.size == M) ? 360 : 240;
            milk_need            = (bev_size_rand.size == L) ? 240 : (bev_size_rand.size == M) ? 180 : 120;
            pineapple_juice_need = (bev_size_rand.size == L) ? 240 : (bev_size_rand.size == M) ? 180 : 120;
        end

    endcase


    if(act_rand.act_id == Make_drink) begin
        if(golden_month < date.M || (golden_month == date.M && golden_day < date.D)) begin
            golden_err = 2'b01;
        end
        else if(black_tea_need > golden_black_tea || green_tea_need > golden_green_tea || milk_need > golden_milk || 
                pineapple_juice_need > golden_pineapple_juice) begin
            golden_err = 2'b10;
            // $finish;
        end
        else begin
            golden_err = 2'b00;
        end
        
        {golden_DRAM[65536+ 7 +8*box_rand.box_id], golden_DRAM[65536+ 6 +8*box_rand.box_id][7:4]} = (golden_err == 2'b00) ? golden_black_tea - black_tea_need : golden_black_tea;
        {golden_DRAM[65536+ 6 +8*box_rand.box_id][3:0], golden_DRAM[65536+ 5 +8*box_rand.box_id]} = (golden_err == 2'b00) ? golden_green_tea - green_tea_need : golden_green_tea;
        {golden_DRAM[65536+ 3 +8*box_rand.box_id], golden_DRAM[65536+ 2 +8*box_rand.box_id][7:4]} = (golden_err == 2'b00) ? golden_milk - milk_need : golden_milk;
        {golden_DRAM[65536+ 2 +8*box_rand.box_id][3:0], golden_DRAM[65536+ 1 +8*box_rand.box_id]} = (golden_err == 2'b00) ? golden_pineapple_juice - pineapple_juice_need : golden_pineapple_juice;

        if(inf.err_msg !== golden_err) begin
			YOU_FAIL_TASK;
			$display("*************************************************************************");
			$display("                           fail pattern: %d                              ", i_pat);
			$display("                               Wrong Answer                              ");
			$display("*************************************************************************");
			$display("golden_err  = %b\n", golden_err);
			$display("your answer = %b\n", inf.err_msg);
			$finish;
        end
        else if(inf.complete === 1 && golden_err != 2'b00) begin
			YOU_FAIL_TASK;
			$display("*************************************************************************");
			$display("                           fail pattern: %d                              ", i_pat);
			$display("              Complete should be 1 when there's no error                 ");
			$display("*************************************************************************");
			$display("golden_err    = %b\n", golden_err);
			$display("your answer   = %b\n", inf.err_msg);
			$display("your complete = %b\n", inf.complete);
			$finish;
        end

    end
    else if(act_rand.act_id == Supply) begin
        black_tea_total       = black_tea_ing       + golden_black_tea;
        green_tea_total       = green_tea_ing       + golden_green_tea;
        milk_total            = milk_ing            + golden_milk;
        pineapple_juice_total = pineapple_juice_ing + golden_pineapple_juice;

        if(black_tea_total > 4095 || green_tea_total > 4095 || milk_total > 4095 || pineapple_juice_total > 4095) begin
            golden_err = 2'b11;
        end
        else begin
            golden_err = 2'b00;
        end
        
        {golden_DRAM[65536+ 7 +8*box_rand.box_id], golden_DRAM[65536+ 6 +8*box_rand.box_id][7:4]} = (black_tea_total > 4095) ? 4095 : black_tea_total;
        {golden_DRAM[65536+ 6 +8*box_rand.box_id][3:0], golden_DRAM[65536+ 5 +8*box_rand.box_id]} = (green_tea_total > 4095) ? 4095 : green_tea_total;
        {golden_DRAM[65536+ 3 +8*box_rand.box_id], golden_DRAM[65536+ 2 +8*box_rand.box_id][7:4]} = (milk_total > 4095) ? 4095 : milk_total;
        {golden_DRAM[65536+ 2 +8*box_rand.box_id][3:0], golden_DRAM[65536+ 1 +8*box_rand.box_id]} = (pineapple_juice_total > 4095) ? 4095 : pineapple_juice_total;
        {golden_DRAM[65536+ 4 +8*box_rand.box_id]} = date.M;
        {golden_DRAM[65536+ 0 +8*box_rand.box_id]} = date.D;

        if(inf.err_msg !== golden_err) begin
			YOU_FAIL_TASK;
			$display("*************************************************************************");
			$display("                           fail pattern: %d                              ", i_pat);
			$display("                               Wrong Answer                              ");
			$display("*************************************************************************");
			$display("golden err  = %b\n", golden_err);
			$display("your   err  = %b\n", inf.err_msg);
			$finish;
        end
        else if(inf.complete === 1 && golden_err != 2'b00) begin
			YOU_FAIL_TASK;
			$display("*************************************************************************");
			$display("                           fail pattern: %d                              ", i_pat);
			$display("              Complete should be 1 when there's no error                 ");
			$display("*************************************************************************");
			$display("golden_err    = %b\n", golden_err);
			$display("your answer   = %b\n", inf.err_msg);
			$display("your complete = %b\n", inf.complete);
			$finish;
        end
    end
    else if(act_rand.act_id == Check_Valid_Date) begin
        if(golden_month < date.M || (golden_month == date.M && golden_day < date.D)) begin
            golden_err = 2'b01;
        end
        else begin
            golden_err = 2'b00;
        end

        if(inf.err_msg !== golden_err) begin
			YOU_FAIL_TASK;
			$display("*************************************************************************");
			$display("                           fail pattern: %d                              ", i_pat);
			$display("                               Wrong Answer                              ");
			$display("*************************************************************************");
			$display("golden err  = %b\n", golden_err);
			$display("your   err  = %b\n", inf.err_msg);
			$finish;
        end
        else if(inf.complete === 1 && golden_err != 2'b00) begin
			YOU_FAIL_TASK;
			$display("*************************************************************************");
			$display("                           fail pattern: %d                              ", i_pat);
			$display("              Complete should be 1 when there's no error                 ");
			$display("*************************************************************************");
			$display("golden_err    = %b\n", golden_err);
			$display("your answer   = %b\n", inf.err_msg);
			$display("your complete = %b\n", inf.complete);
			$finish;
        end

    end

end endtask


task YOU_FAIL_TASK; begin
    $display("\n");
    $display("\n");
    $display("        ----------------------------               ");
    $display("        --                        --       |\__||  ");
    $display("        --  OOPS!!                --      / X,X  | ");
    $display("        --                        --    /_____   | ");
    $display("        --  \033[0;31mSimulation FAIL!!\033[m   --   /^ ^ ^ \\  |");
    $display("        --                        --  |^ ^ ^ ^ |w| ");
    $display("        ----------------------------   \\m___m__|_|");
    $display("\n");
end endtask


task YOU_PASS_TASK; begin
    $display("\033[37m                                                                                                                                          ");        
    $display("\033[37m                                                                                \033[32m      :BBQvi.                                              ");        
    $display("\033[37m                                                              .i7ssrvs7         \033[32m     BBBBBBBBQi                                           ");        
    $display("\033[37m                        .:r7rrrr:::.        .::::::...   .i7vr:.      .B:       \033[32m    :BBBP :7BBBB.                                         ");        
    $display("\033[37m                      .Kv.........:rrvYr7v7rr:.....:rrirJr.   .rgBBBBg  Bi      \033[32m    BBBB     BBBB                                         ");        
    $display("\033[37m                     7Q  :rubEPUri:.       ..:irrii:..    :bBBBBBBBBBBB  B      \033[32m   iBBBv     BBBB       vBr                               ");        
    $display("\033[37m                    7B  BBBBBBBBBBBBBBB::BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB :R     \033[32m   BBBBBKrirBBBB.     :BBBBBB:                            ");        
    $display("\033[37m                   Jd .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: Bi    \033[32m  rBBBBBBBBBBBR.    .BBBM:BBB                             ");        
    $display("\033[37m                  uZ .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .B    \033[32m  BBBB   .::.      EBBBi :BBU                             ");        
    $display("\033[37m                 7B .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  B    \033[32m MBBBr           vBBBu   BBB.                             ");        
    $display("\033[37m                .B  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: JJ   \033[32m i7PB          iBBBBB.  iBBB                              ");        
    $display("\033[37m                B. BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  Lu             \033[32m  vBBBBPBBBBPBBB7       .7QBB5i                ");        
    $display("\033[37m               Y1 KBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBi XBBBBBBBi :B            \033[32m :RBBB.  .rBBBBB.      rBBBBBBBB7              ");        
    $display("\033[37m              :B .BBBBBBBBBBBBBsRBBBBBBBBBBBrQBBBBB. UBBBRrBBBBBBr 1BBBBBBBBB  B.          \033[32m    .       BBBB       BBBB  :BBBB             ");        
    $display("\033[37m              Bi BBBBBBBBBBBBBi :BBBBBBBBBBE .BBK.  .  .   QBBBBBBBBBBBBBBBBBB  Bi         \033[32m           rBBBr       BBBB    BBBU            ");        
    $display("\033[37m             .B .BBBBBBBBBBBBBBQBBBBBBBBBBBB       \033[38;2;242;172;172mBBv \033[37m.LBBBBBBBBBBBBBBBBBBBBBB. B7.:ii:   \033[32m           vBBB        .BBBB   :7i.            ");        
    $display("\033[37m            .B  PBBBBBBBBBBBBBBBBBBBBBBBBBBBBbYQB. \033[38;2;242;172;172mBB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBB  Jr:::rK7 \033[32m             .7  BBB7   iBBBg                  ");        
    $display("\033[37m           7M  PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBB. \033[37mBBBBBBBBBBBBBBBBBBBBBBB..i   .   v1                  \033[32mdBBB.   5BBBr                 ");        
    $display("\033[37m          sZ .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBB. \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBB iD2BBQL.                 \033[32m ZBBBr  EBBBv     YBBBBQi     ");        
    $display("\033[37m  .7YYUSIX5 .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBB. \033[37mBBBBBBBBBBBBBBBBBBBBBBBBY.:.      :B                 \033[32m  iBBBBBBBBD     BBBBBBBBB.   ");        
    $display("\033[37m LB.        ..BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB. \033[38;2;242;172;172mBB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBMBBB. BP17si                 \033[32m    :LBBBr      vBBBi  5BBB   ");        
    $display("\033[37m  KvJPBBB :BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: \033[38;2;242;172;172mZB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBsiJr .i7ssr:                \033[32m          ...   :BBB:   BBBu  ");        
    $display("\033[37m i7ii:.   ::BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBj \033[38;2;242;172;172muBi \033[37mQBBBBBBBBBBBBBBBBBBBBBBBBi.ir      iB                \033[32m         .BBBi   BBBB   iMBu  ");        
    $display("\033[37mDB    .  vBdBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBg \033[38;2;242;172;172m7Bi \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBBB rBrXPv.                \033[32m          BBBX   :BBBr        ");        
    $display("\033[37m :vQBBB. BQBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBQ \033[38;2;242;172;172miB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .L:ii::irrrrrrrr7jIr   \033[32m          .BBBv  :BBBQ        ");        
    $display("\033[37m :7:.   .. 5BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBr \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBB:            ..... ..YB. \033[32m           .BBBBBBBBB:        ");        
    $display("\033[37mBU  .:. BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mB7 \033[37mgBBBBBBBBBBBBBBBBBBBBBBBBBB. gBBBBBBBBBBBBBBBBBB. BL \033[32m             rBBBBB1.         ");        
    $display("\033[37m rY7iB: BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: \033[38;2;242;172;172mB7 \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBB. QBBBBBBBBBBBBBBBBBi  v5                                ");        
    $display("\033[37m     us EBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB \033[38;2;242;172;172mIr \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBgu7i.:BBBBBBBr Bu                                 ");        
    $display("\033[37m      B  7BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB.\033[38;2;242;172;172m:i \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBv:.  .. :::  .rr    rB                                  ");        
    $display("\033[37m      us  .BBBBBBBBBBBBBQLXBBBBBBBBBBBBBBBBBBBBBBBBq  .BBBBBBBBBBBBBBBBBBBBBBBBBv  :iJ7vri:::1Jr..isJYr                                   ");        
    $display("\033[37m      B  BBBBBBB  MBBBM      qBBBBBBBBBBBBBBBBBBBBBB: BBBBBBBBBBBBBBBBBBBBBBBBBB  B:           iir:                                       ");        
    $display("\033[37m     iB iBBBBBBBL       BBBP. :BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  B.                                                       ");        
    $display("\033[37m     P: BBBBBBBBBBB5v7gBBBBBB  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: Br                                                        ");        
    $display("\033[37m     B  BBBs 7BBBBBBBBBBBBBB7 :BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .B                                                         ");        
    $display("\033[37m    .B :BBBB.  EBBBBBQBBBBBJ .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB. B.                                                         ");        
    $display("\033[37m    ij qBBBBBg          ..  .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .B                                                          ");        
    $display("\033[37m    UY QBBBBBBBBSUSPDQL...iBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBK EL                                                          ");        
    $display("\033[37m    B7 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: B:                                                          ");        
    $display("\033[37m    B  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBYrBB vBBBBBBBBBBBBBBBBBBBBBBBB. Ls                                                          ");        
    $display("\033[37m    B  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBi_  /UBBBBBBBBBBBBBBBBBBBBBBBBB. :B:                                                        ");        
    $display("\033[37m   rM .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  ..IBBBBBBBBBBBBBBBBQBBBBBBBBBB  B                                                        ");        
    $display("\033[37m   B  BBBBBBBBBdZBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBPBBBBBBBBBBBBEji:..     sBBBBBBBr Br                                                       ");        
    $display("\033[37m  7B 7BBBBBBBr     .:vXQBBBBBBBBBBBBBBBBBBBBBBBBBQqui::..  ...i:i7777vi  BBBBBBr Bi                                                       ");        
    $display("\033[37m  Ki BBBBBBB  rY7vr:i....  .............:.....  ...:rii7vrr7r:..      7B  BBBBB  Bi                                                       ");        
    $display("\033[37m  B. BBBBBB  B:    .::ir77rrYLvvriiiiiiirvvY7rr77ri:..                 bU  iQBB:..rI                                                      ");        
    $display("\033[37m.S: 7BBBBP  B.                                                          vI7.  .:.  B.                                                     ");        
    $display("\033[37mB: ir:.   :B.                                                             :rvsUjUgU.                                                      ");        
    $display("\033[37mrMvrrirJKur                                                                                                                               \033[m");
    $display ("----------------------------------------------------------------------------------------------------------------------");
    $display ("                                                  Congratulations!                						             ");
    $display ("                                           You have passed all patterns!          						             ");
    $display ("                                           Your execution cycles = %5d cycles                                                            ", total_latency);
    $display ("                                           Your clock period = %.1f ns                                                               ", CYCLE);
    $display ("                                           Total Latency = %.1f ns                                                               ", total_latency*CYCLE);
    $display ("----------------------------------------------------------------------------------------------------------------------");     
    repeat(2)@(negedge clk);
    $display ("----------------------------------------------------------------------------------------------------------------------");

    $finish;	
end endtask

endprogram
