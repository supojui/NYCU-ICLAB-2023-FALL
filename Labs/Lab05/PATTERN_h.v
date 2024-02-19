
`define CYCLE_TIME   20.0
module PATTERN(
	//input
	out_valid,
	out_value,
	//output
	clk, rst_n, in_valid, in_valid2,
	mode, matrix, matrix_size, matrix_idx
);
input out_valid, out_value;
output reg clk, rst_n, in_valid, in_valid2, mode;
output reg [7:0] matrix;
output reg [1:0] matrix_size;
output reg [3:0] matrix_idx;

integer pat_num;
integer latency, total_latency;
integer f_in, f_out,a , t,  i, j, k, l;

initial clk = 1'b1;
real CYCLE = `CYCLE_TIME;
always #(CYCLE / 2.0) clk = ~clk;

reg signed [7:0] matrix8X8   [0:15][0:7][0:7];
reg signed [7:0] matrix16X16 [0:15][0:15][0:15];
reg signed [7:0] matrix32X32 [0:15][0:31][0:31];
reg signed [7:0] kernel 	  [0:15][0:4][0:4];
reg	signed [19:0] Conv_matrix [0:27][0:27];
reg signed [19:0] golden_matrix [0:35][0:35];
reg [3:0] Kernel_idx, Matrix_idx;
reg [1:0] Matrix_size;
reg Mode;
integer pat_count, pat_count_2;
initial begin
	f_in = $fopen("../00_TESTBED/input.txt", "r");
	f_out = $fopen("../00_TESTBED/debug.txt", "w");
	a = $fscanf(f_in, "%d", pat_num);
	reset_task;
	for(pat_count = 0; pat_count < pat_num;pat_count = pat_count + 1)begin
		input_task;
		for(pat_count_2 = 0; pat_count_2 < 16; pat_count_2 = pat_count_2 + 1)begin
			input_task_2;
			calculate_task;
			wait_task;
			check_ans_task;
			$display("pattern %d - %d pass", pat_count, pat_count_2);
			
		end
		
	end
	$finish;
end

//======================================//
//            reset task                //
//======================================//
task reset_task;
	matrix = 'bX;
	matrix_idx = 'bX;
	matrix_size = 'bX;
	rst_n = 1'b1;
	in_valid = 1'b0;
	in_valid2 = 1'b0;
	mode = 'bX;
	
	force clk = 0;
	#(CYCLE / 2.0) rst_n = 1'b0;
	#(CYCLE / 2.0) rst_n = 1'b1;
	if(out_valid !== 0 || out_value !== 0)begin
		$display("                                           `:::::`                                                       ");
        $display("                                          .+-----++                                                      ");
        $display("                .--.`                    o:------/o                                                      ");
        $display("              /+:--:o/                   //-------y.          -//:::-        `.`                         ");
        $display("            `/:------y:                  `o:--::::s/..``    `/:-----s-    .:/:::+:                       ");
        $display("            +:-------:y                `.-:+///::-::::://:-.o-------:o  `/:------s-                      ");
        $display("            y---------y-        ..--:::::------------------+/-------/+ `+:-------/s                      ");
        $display("           `s---------/s       +:/++/----------------------/+-------s.`o:--------/s                      ");
        $display("           .s----------y-      o-:----:---------------------/------o: +:---------o:                      ");
        $display("           `y----------:y      /:----:/-------/o+----------------:+- //----------y`                      ");
        $display("            y-----------o/ `.--+--/:-/+--------:+o--------------:o: :+----------/o                       ");
        $display("            s:----------:y/-::::::my-/:----------/---------------+:-o-----------y.                       ");
        $display("            -o----------s/-:hmmdy/o+/:---------------------------++o-----------/o                        ");
        $display("             s:--------/o--hMMMMMh---------:ho-------------------yo-----------:s`                        ");
        $display("             :o--------s/--hMMMMNs---------:hs------------------+s------------s-                         ");
        $display("              y:-------o+--oyhyo/-----------------------------:o+------------o-                          ");
        $display("              -o-------:y--/s--------------------------------/o:------------o/                           ");
        $display("               +/-------o+--++-----------:+/---------------:o/-------------+/                            ");
        $display("               `o:-------s:--/+:-------/o+-:------------::+d:-------------o/                             ");
        $display("                `o-------:s:---ohsoosyhh+----------:/+ooyhhh-------------o:                              ");
        $display("                 .o-------/d/--:h++ohy/---------:osyyyyhhyyd-----------:o-                               ");
        $display("                 .dy::/+syhhh+-::/::---------/osyyysyhhysssd+---------/o`                                ");
        $display("                  /shhyyyymhyys://-------:/oyyysyhyydysssssyho-------od:                                 ");
        $display("                    `:hhysymmhyhs/:://+osyyssssydyydyssssssssyyo+//+ymo`                                 ");
        $display("                      `+hyydyhdyyyyyyyyyyssssshhsshyssssssssssssyyyo:`                                   ");
        $display("                        -shdssyyyyyhhhhhyssssyyssshssssssssssssyy+.    Output signal should be 0         ");
        $display("                         `hysssyyyysssssssssssssssyssssssssssshh+                                        ");
        $display("                        :yysssssssssssssssssssssssssssssssssyhysh-     after the reset signal is asserted");
        $display("                      .yyhhdo++oosyyyyssssssssssssssssssssssyyssyh/                                      ");
        $display("                      .dhyh/--------/+oyyyssssssssssssssssssssssssy:   at %4d ps                         ", $time*1000);
        $display("                       .+h/-------------:/osyyysssssssssssssssyyh/.                                      ");
        $display("                        :+------------------::+oossyyyyyyyysso+/s-                                       ");
        $display("                       `s--------------------------::::::::-----:o                                       ");
        $display("                       +:----------------------------------------y`                                      ");
        repeat(5) #(CYCLE);
        $finish;
	end
	#(CYCLE / 2.0) release clk;
	
endtask
//===============================================//
//               input task                      //
//===============================================//
task input_task;
	t = $urandom_range(1,3);
	repeat (t) @(negedge clk);
	a = $fscanf(f_in, "%d", Matrix_size);
	matrix_size = Matrix_size;
	in_valid = 1'b1;
	if(matrix_size == 0)begin
		for(i = 0 ;i < 16; i = i + 1)begin
			for( j = 0; j < 8; j = j + 1)begin
				for(k = 0; k < 8; k = k + 1)begin
					a = $fscanf(f_in, "%d", matrix);
					matrix8X8[i][j][k] = matrix;
					if(i + j + k != 0)begin
						matrix_size = 'bX;
					end
					@(negedge clk);
				end
			end
		end
		matrix_size = 'bX;
		for(i = 0 ;i < 16; i = i + 1)begin
			for( j = 0; j < 5; j = j + 1)begin
				for(k = 0; k < 5; k = k + 1)begin
					a = $fscanf(f_in, "%d", matrix);
					kernel[i][j][k] = matrix;
					@(negedge clk);
				end
			end
		end
	end
	else if(matrix_size == 1)begin
		for(i = 0 ;i < 16; i = i + 1)begin
			for( j = 0; j < 16; j = j + 1)begin
				for(k = 0; k < 16; k = k + 1)begin
					a = $fscanf(f_in, "%d", matrix);
					matrix16X16[i][j][k] = matrix;
					if(i + j + k != 0)begin
						matrix_size = 'bX;
					end
					@(negedge clk);
				end
			end
		end
		matrix_size = 'bX;
		for(i = 0 ;i < 16; i = i + 1)begin
			for( j = 0; j < 5; j = j + 1)begin
				for(k = 0; k < 5; k = k + 1)begin
					a = $fscanf(f_in, "%d", matrix);
					kernel[i][j][k] = matrix;
					@(negedge clk);
				end
			end
		end
	end
	else begin
		for(i = 0 ;i < 16; i = i + 1)begin
			for( j = 0; j < 32; j = j + 1)begin
				for(k = 0; k < 32; k = k + 1)begin
					a = $fscanf(f_in, "%d", matrix);
					matrix32X32[i][j][k] = matrix;
					if(i + j + k != 0)begin
						matrix_size = 'bX;
					end
					@(negedge clk);
				end
			end
		end
		matrix_size = 'bX;
		for(i = 0 ;i < 16; i = i + 1)begin
			for( j = 0; j < 5; j = j + 1)begin
				for(k = 0; k < 5; k = k + 1)begin
					a = $fscanf(f_in, "%d", matrix);
					kernel[i][j][k] = matrix;
					@(negedge clk);
				end
			end
		end
	end
	matrix_size = 'bX;
	matrix = 'bX;
	in_valid = 1'b0;
endtask

task input_task_2;
	t = $urandom_range(1,3);
	repeat (t)@(negedge clk);
	a = $fscanf(f_in, "%d", Matrix_idx);
	a = $fscanf(f_in, "%d", Kernel_idx);
	a = $fscanf(f_in, "%d", Mode);
	in_valid2 = 1'b1;
	matrix_idx = Matrix_idx;
	mode = Mode;
	@(negedge clk);
	matrix_idx = Kernel_idx;
	mode = 'bX;
	in_valid2 = 1'b1;
	@(negedge clk);
	matrix_idx = 'bX;
	in_valid2 = 1'b0;
endtask

integer idx1, idx2;
function signed [19:0] Conv;
	input signed [7:0] image1, image2, image3, image4, image5;
	input signed [7:0] filter1, filter2, filter3, filter4, filter5;
	begin
		Conv = image1 * filter1 + image2 * filter2 + image3 * filter3 + image4 * filter4 + image5 * filter5; 
	end
endfunction
function signed [19:0] max;
	input signed [19:0] input1, input2, input3, input4;
	begin
		if(input1 >= input2 && input1 >= input3 && input1 >= input4)begin
			max = input1;
		end
		else if(input2 >= input1 && input2 >= input3 && input2 >= input4)begin
			max = input2;
		end
		else if(input3 >= input1 && input3 >= input2 && input3 >= input4)begin
			max = input3;
		end
		else begin
			max = input4;
		end
	end
endfunction
task calculate_task;
	
	if(Mode == 0)begin
		if(Matrix_size == 0)begin
			idx1 = 2;
			idx2 = 2;
			
		end
		else if(Matrix_size == 1)begin
			idx1 = 6;
			idx2 = 6;
		end
		else begin
			idx1 = 14;
			idx2 = 14;
		end
	end
	else begin
		if(Matrix_size == 0)begin
			idx1 = 12;
			idx2 = 12;
		end
		else if(Matrix_size == 1)begin
			idx1 = 20;
			idx2 = 20;
		end
		else begin
			idx1 = 36;
			idx2 = 36;
		end
	end
	for(i = 0; i < 36; i = i + 1)begin
		for( j = 0 ;j < 36 ;j = j + 1)begin
			golden_matrix[i][j] = 0;
		end
	end
	if(Mode == 0)begin
		if(Matrix_size == 0)begin
			for(i = 0; i < 4;i = i + 1)begin
				for(j = 0;j < 4;j = j + 1)begin
					Conv_matrix[i][j] = Conv(.image1(matrix8X8[Matrix_idx][i][j]), .filter1(kernel[Kernel_idx][0][0]),
											.image2(matrix8X8[Matrix_idx][i][j + 1]), .filter2(kernel[Kernel_idx][0][1]),
											.image3(matrix8X8[Matrix_idx][i][j + 2]), .filter3(kernel[Kernel_idx][0][2]),
											.image4(matrix8X8[Matrix_idx][i][j + 3]), .filter4(kernel[Kernel_idx][0][3]),
											.image5(matrix8X8[Matrix_idx][i][j + 4]), .filter5(kernel[Kernel_idx][0][4])) +
										Conv(.image1(matrix8X8[Matrix_idx][i + 1][j]), .filter1(kernel[Kernel_idx][1][0]),
											.image2(matrix8X8[Matrix_idx][i + 1][j + 1]), .filter2(kernel[Kernel_idx][1][1]),
											.image3(matrix8X8[Matrix_idx][i + 1][j + 2]), .filter3(kernel[Kernel_idx][1][2]),
											.image4(matrix8X8[Matrix_idx][i + 1][j + 3]), .filter4(kernel[Kernel_idx][1][3]),
											.image5(matrix8X8[Matrix_idx][i + 1][j + 4]), .filter5(kernel[Kernel_idx][1][4])) +
										Conv(.image1(matrix8X8[Matrix_idx][i + 2][j]), .filter1(kernel[Kernel_idx][2][0]),
											.image2(matrix8X8[Matrix_idx][i + 2][j + 1]), .filter2(kernel[Kernel_idx][2][1]),
											.image3(matrix8X8[Matrix_idx][i + 2][j + 2]), .filter3(kernel[Kernel_idx][2][2]),
											.image4(matrix8X8[Matrix_idx][i + 2][j + 3]), .filter4(kernel[Kernel_idx][2][3]),
											.image5(matrix8X8[Matrix_idx][i + 2][j + 4]), .filter5(kernel[Kernel_idx][2][4])) +
										Conv(.image1(matrix8X8[Matrix_idx][i + 3][j]), .filter1(kernel[Kernel_idx][3][0]),
											.image2(matrix8X8[Matrix_idx][i + 3][j + 1]), .filter2(kernel[Kernel_idx][3][1]),
											.image3(matrix8X8[Matrix_idx][i + 3][j + 2]), .filter3(kernel[Kernel_idx][3][2]),
											.image4(matrix8X8[Matrix_idx][i + 3][j + 3]), .filter4(kernel[Kernel_idx][3][3]),
											.image5(matrix8X8[Matrix_idx][i + 3][j + 4]), .filter5(kernel[Kernel_idx][3][4])) +
										Conv(.image1(matrix8X8[Matrix_idx][i + 4][j]), .filter1(kernel[Kernel_idx][4][0]),
											.image2(matrix8X8[Matrix_idx][i + 4][j + 1]), .filter2(kernel[Kernel_idx][4][1]),
											.image3(matrix8X8[Matrix_idx][i + 4][j + 2]), .filter3(kernel[Kernel_idx][4][2]),
											.image4(matrix8X8[Matrix_idx][i + 4][j + 3]), .filter4(kernel[Kernel_idx][4][3]),
											.image5(matrix8X8[Matrix_idx][i + 4][j + 4]), .filter5(kernel[Kernel_idx][4][4]));
				end
			end
		end
		else if(Matrix_size == 1)begin
			for(i = 0; i < 12;i = i + 1)begin
				for(j = 0;j < 12;j = j + 1)begin
					Conv_matrix[i][j] = Conv(.image1(matrix16X16[Matrix_idx][i][j]), .filter1(kernel[Kernel_idx][0][0]),
											.image2(matrix16X16[Matrix_idx][i][j + 1]), .filter2(kernel[Kernel_idx][0][1]),
											.image3(matrix16X16[Matrix_idx][i][j + 2]), .filter3(kernel[Kernel_idx][0][2]),
											.image4(matrix16X16[Matrix_idx][i][j + 3]), .filter4(kernel[Kernel_idx][0][3]),
											.image5(matrix16X16[Matrix_idx][i][j + 4]), .filter5(kernel[Kernel_idx][0][4])) +
										Conv(.image1(matrix16X16[Matrix_idx][i + 1][j]), .filter1(kernel[Kernel_idx][1][0]),
											.image2(matrix16X16[Matrix_idx][i + 1][j + 1]), .filter2(kernel[Kernel_idx][1][1]),
											.image3(matrix16X16[Matrix_idx][i + 1][j + 2]), .filter3(kernel[Kernel_idx][1][2]),
											.image4(matrix16X16[Matrix_idx][i + 1][j + 3]), .filter4(kernel[Kernel_idx][1][3]),
											.image5(matrix16X16[Matrix_idx][i + 1][j + 4]), .filter5(kernel[Kernel_idx][1][4])) +
										Conv(.image1(matrix16X16[Matrix_idx][i + 2][j]), .filter1(kernel[Kernel_idx][2][0]),
											.image2(matrix16X16[Matrix_idx][i + 2][j + 1]), .filter2(kernel[Kernel_idx][2][1]),
											.image3(matrix16X16[Matrix_idx][i + 2][j + 2]), .filter3(kernel[Kernel_idx][2][2]),
											.image4(matrix16X16[Matrix_idx][i + 2][j + 3]), .filter4(kernel[Kernel_idx][2][3]),
											.image5(matrix16X16[Matrix_idx][i + 2][j + 4]), .filter5(kernel[Kernel_idx][2][4])) +
										Conv(.image1(matrix16X16[Matrix_idx][i + 3][j]), .filter1(kernel[Kernel_idx][3][0]),
											.image2(matrix16X16[Matrix_idx][i + 3][j + 1]), .filter2(kernel[Kernel_idx][3][1]),
											.image3(matrix16X16[Matrix_idx][i + 3][j + 2]), .filter3(kernel[Kernel_idx][3][2]),
											.image4(matrix16X16[Matrix_idx][i + 3][j + 3]), .filter4(kernel[Kernel_idx][3][3]),
											.image5(matrix16X16[Matrix_idx][i + 3][j + 4]), .filter5(kernel[Kernel_idx][3][4])) +
										Conv(.image1(matrix16X16[Matrix_idx][i + 4][j]), .filter1(kernel[Kernel_idx][4][0]),
											.image2(matrix16X16[Matrix_idx][i + 4][j + 1]), .filter2(kernel[Kernel_idx][4][1]),
											.image3(matrix16X16[Matrix_idx][i + 4][j + 2]), .filter3(kernel[Kernel_idx][4][2]),
											.image4(matrix16X16[Matrix_idx][i + 4][j + 3]), .filter4(kernel[Kernel_idx][4][3]),
											.image5(matrix16X16[Matrix_idx][i + 4][j + 4]), .filter5(kernel[Kernel_idx][4][4]));
				end
			end
		end
		else begin
			for(i = 0; i < 28;i = i + 1)begin
				for(j = 0;j < 28;j = j + 1)begin
					Conv_matrix[i][j] = Conv(.image1(matrix32X32[Matrix_idx][i][j]), .filter1(kernel[Kernel_idx][0][0]),
											.image2(matrix32X32[Matrix_idx][i][j + 1]), .filter2(kernel[Kernel_idx][0][1]),
											.image3(matrix32X32[Matrix_idx][i][j + 2]), .filter3(kernel[Kernel_idx][0][2]),
											.image4(matrix32X32[Matrix_idx][i][j + 3]), .filter4(kernel[Kernel_idx][0][3]),
											.image5(matrix32X32[Matrix_idx][i][j + 4]), .filter5(kernel[Kernel_idx][0][4])) +
										Conv(.image1(matrix32X32[Matrix_idx][i + 1][j]), .filter1(kernel[Kernel_idx][1][0]),
											.image2(matrix32X32[Matrix_idx][i + 1][j + 1]), .filter2(kernel[Kernel_idx][1][1]),
											.image3(matrix32X32[Matrix_idx][i + 1][j + 2]), .filter3(kernel[Kernel_idx][1][2]),
											.image4(matrix32X32[Matrix_idx][i + 1][j + 3]), .filter4(kernel[Kernel_idx][1][3]),
											.image5(matrix32X32[Matrix_idx][i + 1][j + 4]), .filter5(kernel[Kernel_idx][1][4])) +
										Conv(.image1(matrix32X32[Matrix_idx][i + 2][j]), .filter1(kernel[Kernel_idx][2][0]),
											.image2(matrix32X32[Matrix_idx][i + 2][j + 1]), .filter2(kernel[Kernel_idx][2][1]),
											.image3(matrix32X32[Matrix_idx][i + 2][j + 2]), .filter3(kernel[Kernel_idx][2][2]),
											.image4(matrix32X32[Matrix_idx][i + 2][j + 3]), .filter4(kernel[Kernel_idx][2][3]),
											.image5(matrix32X32[Matrix_idx][i + 2][j + 4]), .filter5(kernel[Kernel_idx][2][4])) +
										Conv(.image1(matrix32X32[Matrix_idx][i + 3][j]), .filter1(kernel[Kernel_idx][3][0]),
											.image2(matrix32X32[Matrix_idx][i + 3][j + 1]), .filter2(kernel[Kernel_idx][3][1]),
											.image3(matrix32X32[Matrix_idx][i + 3][j + 2]), .filter3(kernel[Kernel_idx][3][2]),
											.image4(matrix32X32[Matrix_idx][i + 3][j + 3]), .filter4(kernel[Kernel_idx][3][3]),
											.image5(matrix32X32[Matrix_idx][i + 3][j + 4]), .filter5(kernel[Kernel_idx][3][4])) +
										Conv(.image1(matrix32X32[Matrix_idx][i + 4][j]), .filter1(kernel[Kernel_idx][4][0]),
											.image2(matrix32X32[Matrix_idx][i + 4][j + 1]), .filter2(kernel[Kernel_idx][4][1]),
											.image3(matrix32X32[Matrix_idx][i + 4][j + 2]), .filter3(kernel[Kernel_idx][4][2]),
											.image4(matrix32X32[Matrix_idx][i + 4][j + 3]), .filter4(kernel[Kernel_idx][4][3]),
											.image5(matrix32X32[Matrix_idx][i + 4][j + 4]), .filter5(kernel[Kernel_idx][4][4]));
				end
			end
		end
	end
	else begin
		if(Matrix_size == 0)begin
			for(i = 0; i < 8; i = i + 1)begin
				for(j = 0; j < 8; j = j + 1)begin
					golden_matrix[i][j + 0] = golden_matrix[i][j + 0] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][0][0];
					golden_matrix[i][j + 1] = golden_matrix[i][j + 1] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][0][1];
					golden_matrix[i][j + 2] = golden_matrix[i][j + 2] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][0][2];
					golden_matrix[i][j + 3] = golden_matrix[i][j + 3] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][0][3];
					golden_matrix[i][j + 4] = golden_matrix[i][j + 4] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][0][4];
					
					golden_matrix[i + 1][j + 0] = golden_matrix[i + 1][j + 0] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][1][0];
					golden_matrix[i + 1][j + 1] = golden_matrix[i + 1][j + 1] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][1][1];
					golden_matrix[i + 1][j + 2] = golden_matrix[i + 1][j + 2] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][1][2];
					golden_matrix[i + 1][j + 3] = golden_matrix[i + 1][j + 3] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][1][3];
					golden_matrix[i + 1][j + 4] = golden_matrix[i + 1][j + 4] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][1][4];
					
					golden_matrix[i + 2][j + 0] = golden_matrix[i + 2][j + 0] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][2][0];
					golden_matrix[i + 2][j + 1] = golden_matrix[i + 2][j + 1] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][2][1];
					golden_matrix[i + 2][j + 2] = golden_matrix[i + 2][j + 2] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][2][2];
					golden_matrix[i + 2][j + 3] = golden_matrix[i + 2][j + 3] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][2][3];
					golden_matrix[i + 2][j + 4] = golden_matrix[i + 2][j + 4] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][2][4];
					
					golden_matrix[i + 3][j + 0] = golden_matrix[i + 3][j + 0] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][3][0];
					golden_matrix[i + 3][j + 1] = golden_matrix[i + 3][j + 1] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][3][1];
					golden_matrix[i + 3][j + 2] = golden_matrix[i + 3][j + 2] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][3][2];
					golden_matrix[i + 3][j + 3] = golden_matrix[i + 3][j + 3] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][3][3];
					golden_matrix[i + 3][j + 4] = golden_matrix[i + 3][j + 4] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][3][4];
					
					golden_matrix[i + 4][j + 0] = golden_matrix[i + 4][j + 0] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][4][0];
					golden_matrix[i + 4][j + 1] = golden_matrix[i + 4][j + 1] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][4][1];
					golden_matrix[i + 4][j + 2] = golden_matrix[i + 4][j + 2] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][4][2];
					golden_matrix[i + 4][j + 3] = golden_matrix[i + 4][j + 3] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][4][3];
					golden_matrix[i + 4][j + 4] = golden_matrix[i + 4][j + 4] + matrix8X8[Matrix_idx][i][j] * kernel[Kernel_idx][4][4];
					
				end
			end
		end
		else if(Matrix_size == 1)begin
			for(i = 0; i < 16; i = i + 1)begin
				for(j = 0; j < 16; j = j + 1)begin
					golden_matrix[i][j + 0] = golden_matrix[i][j + 0] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][0][0];
					golden_matrix[i][j + 1] = golden_matrix[i][j + 1] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][0][1];
					golden_matrix[i][j + 2] = golden_matrix[i][j + 2] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][0][2];
					golden_matrix[i][j + 3] = golden_matrix[i][j + 3] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][0][3];
					golden_matrix[i][j + 4] = golden_matrix[i][j + 4] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][0][4];
					
					golden_matrix[i + 1][j + 0] = golden_matrix[i + 1][j + 0] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][1][0];
					golden_matrix[i + 1][j + 1] = golden_matrix[i + 1][j + 1] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][1][1];
					golden_matrix[i + 1][j + 2] = golden_matrix[i + 1][j + 2] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][1][2];
					golden_matrix[i + 1][j + 3] = golden_matrix[i + 1][j + 3] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][1][3];
					golden_matrix[i + 1][j + 4] = golden_matrix[i + 1][j + 4] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][1][4];
					
					golden_matrix[i + 2][j + 0] = golden_matrix[i + 2][j + 0] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][2][0];
					golden_matrix[i + 2][j + 1] = golden_matrix[i + 2][j + 1] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][2][1];
					golden_matrix[i + 2][j + 2] = golden_matrix[i + 2][j + 2] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][2][2];
					golden_matrix[i + 2][j + 3] = golden_matrix[i + 2][j + 3] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][2][3];
					golden_matrix[i + 2][j + 4] = golden_matrix[i + 2][j + 4] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][2][4];
					
					golden_matrix[i + 3][j + 0] = golden_matrix[i + 3][j + 0] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][3][0];
					golden_matrix[i + 3][j + 1] = golden_matrix[i + 3][j + 1] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][3][1];
					golden_matrix[i + 3][j + 2] = golden_matrix[i + 3][j + 2] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][3][2];
					golden_matrix[i + 3][j + 3] = golden_matrix[i + 3][j + 3] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][3][3];
					golden_matrix[i + 3][j + 4] = golden_matrix[i + 3][j + 4] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][3][4];
					
					golden_matrix[i + 4][j + 0] = golden_matrix[i + 4][j + 0] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][4][0];
					golden_matrix[i + 4][j + 1] = golden_matrix[i + 4][j + 1] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][4][1];
					golden_matrix[i + 4][j + 2] = golden_matrix[i + 4][j + 2] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][4][2];
					golden_matrix[i + 4][j + 3] = golden_matrix[i + 4][j + 3] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][4][3];
					golden_matrix[i + 4][j + 4] = golden_matrix[i + 4][j + 4] + matrix16X16[Matrix_idx][i][j] * kernel[Kernel_idx][4][4];
					
				end
			end
		end
		else begin
			for(i = 0; i < 32; i = i + 1)begin
				for(j = 0; j < 32; j = j + 1)begin
					golden_matrix[i][j + 0] = golden_matrix[i][j + 0] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][0][0];
					golden_matrix[i][j + 1] = golden_matrix[i][j + 1] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][0][1];
					golden_matrix[i][j + 2] = golden_matrix[i][j + 2] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][0][2];
					golden_matrix[i][j + 3] = golden_matrix[i][j + 3] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][0][3];
					golden_matrix[i][j + 4] = golden_matrix[i][j + 4] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][0][4];
					
					golden_matrix[i + 1][j + 0] = golden_matrix[i + 1][j + 0] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][1][0];
					golden_matrix[i + 1][j + 1] = golden_matrix[i + 1][j + 1] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][1][1];
					golden_matrix[i + 1][j + 2] = golden_matrix[i + 1][j + 2] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][1][2];
					golden_matrix[i + 1][j + 3] = golden_matrix[i + 1][j + 3] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][1][3];
					golden_matrix[i + 1][j + 4] = golden_matrix[i + 1][j + 4] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][1][4];
					
					golden_matrix[i + 2][j + 0] = golden_matrix[i + 2][j + 0] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][2][0];
					golden_matrix[i + 2][j + 1] = golden_matrix[i + 2][j + 1] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][2][1];
					golden_matrix[i + 2][j + 2] = golden_matrix[i + 2][j + 2] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][2][2];
					golden_matrix[i + 2][j + 3] = golden_matrix[i + 2][j + 3] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][2][3];
					golden_matrix[i + 2][j + 4] = golden_matrix[i + 2][j + 4] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][2][4];
					
					golden_matrix[i + 3][j + 0] = golden_matrix[i + 3][j + 0] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][3][0];
					golden_matrix[i + 3][j + 1] = golden_matrix[i + 3][j + 1] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][3][1];
					golden_matrix[i + 3][j + 2] = golden_matrix[i + 3][j + 2] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][3][2];
					golden_matrix[i + 3][j + 3] = golden_matrix[i + 3][j + 3] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][3][3];
					golden_matrix[i + 3][j + 4] = golden_matrix[i + 3][j + 4] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][3][4];
					
					golden_matrix[i + 4][j + 0] = golden_matrix[i + 4][j + 0] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][4][0];
					golden_matrix[i + 4][j + 1] = golden_matrix[i + 4][j + 1] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][4][1];
					golden_matrix[i + 4][j + 2] = golden_matrix[i + 4][j + 2] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][4][2];
					golden_matrix[i + 4][j + 3] = golden_matrix[i + 4][j + 3] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][4][3];
					golden_matrix[i + 4][j + 4] = golden_matrix[i + 4][j + 4] + matrix32X32[Matrix_idx][i][j] * kernel[Kernel_idx][4][4];
					
				end
			end
		end
	end
	
	
	if(Mode == 0)begin
		for( i = 0 ;i < idx1; i = i + 1)begin
			for(j = 0 ;j < idx2;j = j + 1)begin
				golden_matrix[i][j] = max(.input1(Conv_matrix[2 * i][2 * j]), .input2(Conv_matrix[2 * i][2 * j + 1]),
										  .input3(Conv_matrix[2 * i + 1][2 * j]), .input4(Conv_matrix[2 * i + 1][2 * j + 1])
				);
			end
		end
	end

endtask
//===============================================//
//            check answer task                  //
//===============================================//
integer cnt;
task check_ans_task;
	cnt = 0;
	while(out_valid === 1)begin
		for(i = 0; i < idx1; i = i + 1)begin
			for(j = 0; j < idx2; j = j + 1)begin
				for(k = 0 ; k <= 19; k = k + 1)begin
					if(out_value !== golden_matrix[i][j][k])begin
						$display("***************************************************");
						$display("*         output wrong %d row %d column %d bit    *", i, j, k);
						$display("*            golden output = %d	                *", golden_matrix[i][j][k]);
						$display("***************************************************");
						print_answer_task;
						repeat (9)@(negedge clk);
						$finish;

					end
					cnt = cnt + 1;
					@(negedge clk);
				end
			end
		end
	end
	if(cnt !== idx1 * idx2 * 20)begin
		$display("****************************************");
		$display("*         output count not enough      *");
		$display("*         you have only %d input       *", cnt);
		$display("****************************************");
		repeat (9)@(negedge clk);
		$finish;
	end

endtask
//===============================================//
//             print answer task                 //
//===============================================//
task print_answer_task;
	$fwrite(f_out," pattern %d - %d wrong\n ", pat_count, pat_count_2);
	if(Mode == 0)begin
		$fwrite(f_out, "************************************************************\n");
		$fwrite(f_out, "*                  Conv   matrix                           *\n");
		$fwrite(f_out, "************************************************************\n");
		for(i = 0; i < 2 * idx1; i = i + 1)begin
			for(j = 0; j < 2 * idx2; j = j + 1)begin
				$fwrite(f_out, "%d", Conv_matrix[i][j]);
			end
			$fwrite(f_out, "\n");
		end
	end
	
	$fwrite(f_out,"************************************************************\n");
	$fwrite(f_out,"*                golden   matrix                           *\n");
	$fwrite(f_out,"************************************************************\n");
	for(i = 0; i < idx1; i = i + 1)begin
			for(j = 0; j < idx2; j = j + 1)begin
				$fwrite(f_out,"%d", golden_matrix[i][j]);
			end
			$fwrite(f_out,"\n");
	end
	$fwrite(f_out,"******************************************************\n");
	
endtask
//===============================================//
//               wait task                       //
//===============================================//
task wait_task; begin
    latency = -1;
    while (out_valid !== 1) begin
        if (out_value !== 0) begin
            $display("                                           `:::::`                                                       ");
            $display("                                          .+-----++                                                      ");
            $display("                .--.`                    o:------/o                                                      ");
            $display("              /+:--:o/                   //-------y.          -//:::-        `.`                         ");
            $display("            `/:------y:                  `o:--::::s/..``    `/:-----s-    .:/:::+:                       ");
            $display("            +:-------:y                `.-:+///::-::::://:-.o-------:o  `/:------s-                      ");
            $display("            y---------y-        ..--:::::------------------+/-------/+ `+:-------/s                      ");
            $display("           `s---------/s       +:/++/----------------------/+-------s.`o:--------/s                      ");
            $display("           .s----------y-      o-:----:---------------------/------o: +:---------o:                      ");
            $display("           `y----------:y      /:----:/-------/o+----------------:+- //----------y`                      ");
            $display("            y-----------o/ `.--+--/:-/+--------:+o--------------:o: :+----------/o                       ");
            $display("            s:----------:y/-::::::my-/:----------/---------------+:-o-----------y.                       ");
            $display("            -o----------s/-:hmmdy/o+/:---------------------------++o-----------/o                        ");
            $display("             s:--------/o--hMMMMMh---------:ho-------------------yo-----------:s`                        ");
            $display("             :o--------s/--hMMMMNs---------:hs------------------+s------------s-                         ");
            $display("              y:-------o+--oyhyo/-----------------------------:o+------------o-                          ");
            $display("              -o-------:y--/s--------------------------------/o:------------o/                           ");
            $display("               +/-------o+--++-----------:+/---------------:o/-------------+/                            ");
            $display("               `o:-------s:--/+:-------/o+-:------------::+d:-------------o/                             ");
            $display("                `o-------:s:---ohsoosyhh+----------:/+ooyhhh-------------o:                              ");
            $display("                 .o-------/d/--:h++ohy/---------:osyyyyhhyyd-----------:o-                               ");
            $display("                 .dy::/+syhhh+-::/::---------/osyyysyhhysssd+---------/o`                                ");
            $display("                  /shhyyyymhyys://-------:/oyyysyhyydysssssyho-------od:                                 ");
            $display("                    `:hhysymmhyhs/:://+osyyssssydyydyssssssssyyo+//+ymo`                                 ");
            $display("                      `+hyydyhdyyyyyyyyyyssssshhsshyssssssssssssyyyo:`                                   ");
            $display("                        -shdssyyyyyhhhhhyssssyyssshssssssssssssyy+.    Output signal should be 0         ");
            $display("                         `hysssyyyysssssssssssssssyssssssssssshh+                                        ");
            $display("                        :yysssssssssssssssssssssssssssssssssyhysh-     when the out_valid is pulled down ");
            $display("                      .yyhhdo++oosyyyyssssssssssssssssssssssyyssyh/                                      ");
            $display("                      .dhyh/--------/+oyyyssssssssssssssssssssssssy:   at %4d ps                         ", $time*1000);
            $display("                       .+h/-------------:/osyyysssssssssssssssyyh/.                                      ");
            $display("                        :+------------------::+oossyyyyyyyysso+/s-                                       ");
            $display("                       `s--------------------------::::::::-----:o                                       ");
            $display("                       +:----------------------------------------y`                                      ");
            repeat(5) #(CYCLE);
            $finish;
        end
        if (latency == 100000) begin
            $display("                                   ..--.                                ");
            $display("                                `:/:-:::/-                              ");
            $display("                                `/:-------o                             ");
            $display("                                /-------:o:                             "); 
            $display("                                +-:////+s/::--..                        ");
            $display("    The execution latency      .o+/:::::----::::/:-.       at %-12d ps  ", $time*1000);
            $display("    is over %5d   cycles    `:::--:/++:----------::/:.                ", 100000);
            $display("                            -+:--:++////-------------::/-               ");
            $display("                            .+---------------------------:/--::::::.`   ");
            $display("                          `.+-----------------------------:o/------::.  ");
            $display("                       .-::-----------------------------:--:o:-------:  ");
            $display("                     -:::--------:/yy------------------/y/--/o------/-  ");
            $display("                    /:-----------:+y+:://:--------------+y--:o//:://-   ");
            $display("                   //--------------:-:+ssoo+/------------s--/. ````     ");
            $display("                   o---------:/:------dNNNmds+:----------/-//           ");
            $display("                   s--------/o+:------yNNNNNd/+--+y:------/+            ");
            $display("                 .-y---------o:-------:+sso+/-:-:yy:------o`            ");
            $display("              `:oosh/--------++-----------------:--:------/.            ");
            $display("              +ssssyy--------:y:---------------------------/            ");
            $display("              +ssssyd/--------/s/-------------++-----------/`           ");
            $display("              `/yyssyso/:------:+o/::----:::/+//:----------+`           ");
            $display("             ./osyyyysssso/------:/++o+++///:-------------/:            ");
            $display("           -osssssssssssssso/---------------------------:/.             ");
            $display("         `/sssshyssssssssssss+:---------------------:/+ss               ");
            $display("        ./ssssyysssssssssssssso:--------------:::/+syyys+               ");
            $display("     `-+sssssyssssssssssssssssso-----::/++ooooossyyssyy:                ");
            $display("     -syssssyssssssssssssssssssso::+ossssssssssssyyyyyss+`              ");
            $display("     .hsyssyssssssssssssssssssssyssssssssssyhhhdhhsssyssso`             ");
            $display("     +/yyshsssssssssssssssssssysssssssssyhhyyyyssssshysssso             ");
            $display("    ./-:+hsssssssssssssssssssssyyyyyssssssssssssssssshsssss:`           ");
            $display("    /---:hsyysyssssssssssssssssssssssssssssssssssssssshssssy+           ");
            $display("    o----oyy:-:/+oyysssssssssssssssssssssssssssssssssshssssy+-          ");
            $display("    s-----++-------/+sysssssssssssssssssssssssssssssyssssyo:-:-         ");
            $display("    o/----s-----------:+syyssssssssssssssssssssssyso:--os:----/.        ");
            $display("    `o/--:o---------------:+ossyysssssssssssyyso+:------o:-----:        ");
            $display("      /+:/+---------------------:/++ooooo++/:------------s:---::        ");
            $display("       `/o+----------------------------------------------:o---+`        ");
            $display("         `+-----------------------------------------------o::+.         ");
            $display("          +-----------------------------------------------/o/`          ");
            $display("          ::----------------------------------------------:-            ");
            repeat(5) @(negedge clk);
            $finish; 
        end
        latency = latency + 1;
        @(negedge clk);
    end
end endtask


endmodule