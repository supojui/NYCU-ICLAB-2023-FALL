`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD_iclab103.v"

module PATTERN(
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

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [12:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data; 

// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output W_READY;
// write response channel
output B_VALID;
output [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output AR_READY;
// read data channel
output [63:0] R_DATA;
output R_VALID;
output [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency, latency;
integer i_pat, t, temp, i;


always #(CYCLE/2.0) clk = ~clk;

initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r");
    reset_signal_task;

    i_pat = 0;
    total_latency = 0;
    i = $fscanf(pat_read, "%d", PAT_NUM);
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task;
        total_latency = total_latency + latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);

    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM);
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);
    YOU_PASS_task;
end

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////




reg direction_temp;
reg [12:0]addr_dram_temp;
reg [15:0]addr_sd_temp;
reg [63:0]golden_out_data;



//////////////////////////////////////////////////////////////////////

task reset_signal_task; begin
    rst_n = 'b1;
    force clk = 0;
    in_valid = 'b0;
    direction = 'bx;
	addr_dram = 'bx;
    addr_sd = 'bx;
    total_latency = 0;

    #40; rst_n = 0; 
    #40; rst_n = 1;
    if(out_valid !== 0 || out_data !== 0 || AW_ADDR !== 0 || AW_VALID !== 0 ||
       W_VALID   !== 0 || W_DATA   !== 0 || B_READY !== 0 || AR_ADDR  !== 0 || 
       AR_VALID  !== 0 || R_READY  !== 0 || MOSI    !== 1) begin
        $display("************************************************************");  
        $display("                          FAIL!                             ");    
        $display("*                     SPEC MAIN-1 FAIL                     *");
        $display("************************************************************");
        repeat(2) #CYCLE;
        $finish;
    end
    #40; release clk;

end endtask


task input_task; begin
    temp = $fscanf(pat_read, "%d ", direction_temp);
    temp = $fscanf(pat_read, "%d ", addr_dram_temp);
    temp = $fscanf(pat_read, "%d ", addr_sd_temp);
    t = $urandom_range(1,4);
    repeat(t) @(negedge clk);

    in_valid = 1'b1;
    direction = direction_temp;
    addr_dram = addr_dram_temp;
    addr_sd = addr_sd_temp;
    @(negedge clk);
    in_valid = 1'b0;
    direction = 'bx;
    addr_dram = 'bx;
    addr_sd = 'bx;
end endtask


task wait_out_valid_task; begin
    latency = 0;
    while(out_valid == 1'b0) begin
	    latency = latency + 1;
        if(latency == 10000) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-3 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end

        if(out_data !== 8'b0) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-2 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        @(negedge clk);
   end
   total_latency = total_latency + latency;
end endtask


task check_ans_task; begin
    latency = 0;
    while(out_valid === 1'b1) begin
        latency = latency + 1;
        if(latency > 8) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-4 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(direction_temp == 1'b0) begin
            golden_out_data = u_DRAM.DRAM[addr_dram_temp];
        end
        else if(direction_temp == 1'b1) begin
             golden_out_data = u_SD.SD[addr_sd_temp];
        end

        if(u_DRAM.DRAM[addr_dram_temp] !== u_SD.SD[addr_sd_temp]) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-6 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end

        if(out_data !== golden_out_data[63:56] && latency == 1) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[55:48] && latency == 2) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[47:40] && latency == 3) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[39:32] && latency == 4) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[31:24] && latency == 5) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[23:16] && latency == 6) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[15:8] && latency == 7) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end
        if(out_data !== golden_out_data[7:0] && latency == 8) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-5 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
        end

        @(negedge clk);
    end

    if(out_data !== 8'b0) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-2 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
    end

    if(latency != 8) begin
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("*                       SPEC MAIN-4 FAIL               *");
            $display("********************************************************");
            repeat(2)@(negedge clk);
            $finish;
    end
end endtask


task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                    Error message from PATTERN.v                       *");
end endtask

pseudo_DRAM u_DRAM (
    .clk(clk),
    .rst_n(rst_n),
    // write address channel
    .AW_ADDR(AW_ADDR),
    .AW_VALID(AW_VALID),
    .AW_READY(AW_READY),
    // write data channel
    .W_VALID(W_VALID),
    .W_DATA(W_DATA),
    .W_READY(W_READY),
    // write response channel
    .B_VALID(B_VALID),
    .B_RESP(B_RESP),
    .B_READY(B_READY),
    // read address channel
    .AR_ADDR(AR_ADDR),
    .AR_VALID(AR_VALID),
    .AR_READY(AR_READY),
    // read data channel
    .R_DATA(R_DATA),
    .R_VALID(R_VALID),
    .R_RESP(R_RESP),
    .R_READY(R_READY)
);

pseudo_SD u_SD (
    .clk(clk),
    .MOSI(MOSI),
    .MISO(MISO)
);

endmodule