module mux2to1_cond(	out,
			in0,
			in1,
			sel);

output		out		;
input		in0		;
input		in1		;
input		sel		;

assign	out = (sel)? in1 : in0	;

endmodule

module	mux2to1_if( out, in0, in1, sel);

output		out		;
input		in0		;
input		in1		;
input		sel		;

reg		out;

always @(in0 or in1 or sel) begin
	if(sel == 1'b0) begin
	    out = in0	;
	end else begin
	    out = in1	;
	end
	end
endmodule

module fa_case(		out,
			in0,
			in1,
			sel	);

output		out;
input		in0;
input		in1;
input		sel;

reg		out;

always @(in0 or in1 or sel) begin
	case( {sel, in0, in1} )
		3'b000 : {out} = 2'b00;
		3'b001 : {out} = 2'b01;
		3'b010 : {out} = 2'b10;
         	3'b011 : {out} = 2'b11;
		3'b100 : {out} = 2'b00;
		3'b101 : {out} = 2'b01;
		3'b110 : {out} = 2'b10;
		3'b111 : {out} = 2'b11;
	endcase
end
endmodule
		