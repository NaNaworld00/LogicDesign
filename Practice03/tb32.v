module	tb32;

	reg[1:0]sel;
	reg[3:0]in;

	wire out1;
	wire out2;
	wire out3;

mux4_inst dut_1(  .sel(sel),
		  .in ( in),
		  .out (out1));

mux4to1_if dut_2(  .sel(sel),
		   .in ( in),
		   .out (out2));

mux4to1_case dut_3(  .sel(sel	),
		     .in ( in	),
		     .out (out3	));

initial begin
	$display("Using Instances: out");
	$display("Using If: out");
	$display("Using Case: out");
	$display("===========================================================");
	$display("  sel0  sel1  in0  in1  in2  in3  out1  out2  out3");
	$display("===========================================================");
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_110001; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_011001; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_100110; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_111111; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_100101; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_010010; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	{sel[0], sel[1], in[0], in[1], in[2], in[3]} = 6'b_110001; #(50) $display(" %b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", sel[0], sel[1], in[0], in[1], in[2], in[3], out1, out2, out3);
	#(50)	$finish;

end
endmodule 