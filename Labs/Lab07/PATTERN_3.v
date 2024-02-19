`ifdef RTL
	`define CYCLE_TIME_clk1 14.1
	`define CYCLE_TIME_clk2 3.9
	`define CYCLE_TIME_clk3 20.7
`endif
`ifdef GATE
	`define CYCLE_TIME_clk1 14.1
	`define CYCLE_TIME_clk2 3.9
	`define CYCLE_TIME_clk3 20.7
`endif

module PATTERN(
	clk1,
	clk2,
	clk3,
	rst_n,
	in_valid,
	seed,
	out_valid,
	rand_num
);

output reg clk1, clk2, clk3;
output reg rst_n;
output reg in_valid;
output reg [31:0] seed;

input out_valid;
input [31:0] rand_num;
reg [31:0] golden_ans [0:255];

//================================================================
// parameters & integer
//================================================================
real	CYCLE_clk1 = `CYCLE_TIME_clk1;
real	CYCLE_clk2 = `CYCLE_TIME_clk2;
//real	CYCLE_clk3 = `CYCLE_TIME_clk3;
real	CYCLE_clk3 = 67.3;
integer total_latency, t, latency, patcount, out_count;

reg [31:0] seed_dff;
//================================================================
// wire & registers 
//================================================================


//================================================================
// clock
//================================================================
always #(CYCLE_clk1 / 2.0) clk1 = ~clk1;
always #(CYCLE_clk2 / 2.0) clk2 = ~clk2;
always #(CYCLE_clk3 / 2.0) clk3 = ~clk3;
initial clk1 = 0;
initial clk2 = 0;
initial clk3 = 0;
integer a;
//================================================================
// initial
//================================================================
initial begin
	reset_task;
	total_latency = 0;
	a = $fopen("debug.txt", "w");
	for(patcount = 1; patcount <= 1000; patcount = patcount + 1)begin
		input_task;
		out_count = 1;
		while(out_count <= 256)begin
			wait_out_valid_task;
			check_ans;
		end
		$display(" You pass %d pattern", patcount);
	end
	YOU_PASS_task;
end

//================================================================
// task
//================================================================
task reset_task;
	rst_n = 1'b1;
	in_valid = 1'b0;
	seed = 'bX;
	latency = 0;
	force clk1 = 0;
	force clk2 = 0;
	force clk3 = 0;
	#(CYCLE_clk3); rst_n = 1'b0;
	#(CYCLE_clk3); rst_n = 1'b1;
	if(out_valid !== 0 || rand_num !== 0)begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		
		#(100);
	    $finish ;
	end
	#(CYCLE_clk3); release clk1;
	release clk2;
	release clk3;
endtask
integer i;
task input_task;
	latency = 0;
	t = $urandom_range(1,3);
	repeat (t)@(negedge clk1);
	in_valid = 1'b1;
	seed = $urandom();
	seed_dff = seed;
	@(negedge clk1);
	in_valid = 1'b0;
	seed = 'bX;
	golden_ans[0] = seed_dff ^ (seed_dff << 13);
	golden_ans[0] = golden_ans[0] ^ (golden_ans[0] >> 17);
	golden_ans[0] = golden_ans[0] ^ (golden_ans[0] << 5);
	for(i = 1; i < 256; i = i + 1)begin
		golden_ans[i] = golden_ans[i - 1] ^ (golden_ans[i - 1] << 13);
		golden_ans[i] = golden_ans[i] ^ (golden_ans[i] >> 17);
		golden_ans[i] = golden_ans[i] ^ (golden_ans[i] << 5);
	end
	for(i = 0; i < 256; i = i + 1)begin
		$fwrite(a,"num %d = %h\n", i + 1, golden_ans[i]);
	end
endtask

task wait_out_valid_task;
	while(out_valid !== 1)begin
		latency = latency + 1;
		if(latency === 2000) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                     The execution latency are over  2000 cycles                                          ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk3);
			$finish;
		end
		@(negedge clk3);
	end
	total_latency = total_latency + latency;
endtask
reg [31:0] num, num1, num2, golden_num;
task check_ans;
	num = seed_dff;
	while(out_valid === 1)begin
		num1 = num ^ (num << 13);
		num2 = num1 ^ (num1 >> 17);
		golden_num = num2 ^ (num2 << 5);
		total_latency = total_latency + 1;
		if(rand_num !== golden_num)begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                    			golden = %h      your num = %h                                                 ", golden_num, rand_num);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2) @(negedge clk3);
			$finish;
		end 
		if(out_count > 256)begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                    			     output never stop                                                         ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2) @(negedge clk3);
			$finish;
		end
		out_count = out_count + 1;
		@(negedge clk3);
		
		num = golden_num;
	end

endtask

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE_clk3);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE_clk3);
    $display("*************************************************************************");
    $finish;
end endtask


endmodule
