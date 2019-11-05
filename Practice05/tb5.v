`timescale 1ns/1ns
module tb5;

reg	d;
reg	clk;

wire	q_block;
wire	q_nonblock;

initial clk = 1'b0;
always #(50) clk = ~clk;

block dut_1(	.q( q_block ),
		.d( d ),
		.clk( clk ));

nonblock dut_2(   .q( q_nonblock ),
		  .d( d ),
		  .clk( clk ));

initial begin
#(0)	{d} = 1'b0;
#(50)	{d} = 1'b0;
#(50)	{d} = 1'b1;
#(50)	{d} = 1'b1;
#(50)	{d} = 1'b0;
#(50)	{d} = 1'b0;
#(50)	{d} = 1'b0;
#(50)	{d} = 1'b1;
#(50)	$finish;

end
endmodule
