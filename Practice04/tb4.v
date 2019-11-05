module tb4;

reg	[2:0] in	;
reg	en	;

wire	[7:0] out1	;
wire	[7:0] out2	;

dec3to8_shift dut_1(	.out( out1 ),
			.in ( in ),
			.en ( en ));

dec3to8_case dut_2(	.out( out2 ),
			.in ( in ),
			.en ( en ));

initial begin
	$display("Using Shift: out");
	$display("Using Case: out");
	$display("==========================================");
	$display(" en  in  out1  out2");
	$display("==========================================");
	#(50)	{en, in} = 4'b0_000; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b0_001; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b0_010; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b0_011; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b0_100; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b0_101; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b0_110; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_111; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_000; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_001; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_010; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_011; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_100; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_101; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_110; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	{en, in} = 4'b1_111; #(50) $display(" %b\t%b\t%b\t%b", en, in, out1, out2);
	#(50)	$finish;
end

endmodule
