module tb3;

reg	in0;
reg	in1;
reg	sel;

wire	out1;
wire	out2;
wire	out3;

mux2to1_cond dut_1(	.out( out1  ),
			.in0( in0  ),
			.in1( in1  ),
			.sel( sel  ));

mux2to1_if dut_2(	.out( out2  ),
			.in0( in0  ),
			.in1( in1  ),
			.sel( sel  ));

fa_case dut_3(	.out( out3  ),
		.in0( in0  ),
		.in1( in1  ),
		.sel( sel  ));

initial begin
	$display("mux2tol_cond Level: out1");
	$display("mux2tol_if Level: out2");
	$display("Using 'case': out3");
	$display("=================================================");
	$display("  sel  in0  in1  out1  out2  out3");
	$display("=================================================");
	#(50)	{sel,  in0,  in1} = 3'b_000;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_001;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_010;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_011;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_100;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_101;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_110;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	{sel,  in0,  in1} = 3'b_111;  #(50) $display("  %b\t%b\t%b\t%b\t%b\t%b", sel, in0, in1, out1, out2, out3);
	#(50)	$finish;
end

endmodule
