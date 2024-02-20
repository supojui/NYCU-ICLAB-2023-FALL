`timescale 1ns/1ps

`include "PATTERN.v"
`ifdef RTL
  `include "Train.v"
`endif
`ifdef GATE
  `include "Train_SYN.v"
`endif
	  		  	
module TESTBED;

wire         clk, rst_n, in_valid;
wire  [3:0]  data;


wire         out_valid;
wire         result;

initial begin
  `ifdef RTL
    $fsdbDumpfile("Train.fsdb");
	$fsdbDumpvars(0,"+mda");
    $fsdbDumpvars();
  `endif
  `ifdef GATE
    $sdf_annotate("Train_SYN.sdf", u_train);
    $fsdbDumpfile("Train_SYN.fsdb");
	$fsdbDumpvars(0,"+mda");
    $fsdbDumpvars();    
  `endif
end

`ifdef RTL
Train u_train(
    .clk            (   clk        ),
    .rst_n          (   rst_n      ),
    .in_valid       (   in_valid   ),
    .data           (   data       ),	
								   
    .out_valid      (   out_valid  ),
	.result         (   result     )
);
`endif	

`ifdef GATE
Train u_train(
    .clk            (   clk        ),
    .rst_n          (   rst_n      ),
    .in_valid       (   in_valid   ),
    .data           (   data       ),	
								   
    .out_valid      (   out_valid  ),
	.result         (   result     )
);
`endif	

PATTERN u_PATTERN(
    .clk            (   clk        ),
    .rst_n          (   rst_n      ),
    .in_valid       (   in_valid   ),
    .data           (   data       ),	
								   
    .out_valid      (   out_valid  ),
	.result         (   result     )
);
endmodule
