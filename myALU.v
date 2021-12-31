module Mux2To1(out, in0, in1, sel);
	input in0, in1, sel;
	output out;
	assign out = (sel == 0) ? in0 : in1;
endmodule

module Mux2To1Bits8(out, in0, in1, sel);
	input [7:0] in0, in1;
	input sel;
	output [7:0] out;
	
	genvar k;
	generate
		for (k = 0; k < 8; k = k+1)
		begin: muxLoop1
			Mux2To1 m1(out[k], in0[k], in1[k], sel);
		end
	endgenerate
endmodule

module Mux2To1Bits32(out, in0, in1, sel);
	parameter w = 8;
	input [31:0] in0, in1;
	input sel;
	output [31:0] out;

	genvar j;
	generate
		for (j = 0; j < 4; j = j+1)
		begin: muxLoop2
			Mux2To1Bits8 m2(out[w*j+w-1: w*j], in0[w*j+w-1: w*j], in1[w*j+w-1: w*j], sel);
		end
	endgenerate
endmodule

module Mux3To1Bits32(out, in0, in1, in2, sel);
	input [31:0] in0, in1, in2;
	input [1:0] sel;
	output [31:0] out;

	wire [31:0] in3Dummy = 32'b0;
	wire [31:0] out01, out23;
	
	Mux2To1Bits32 m0(out01, in0, in1, sel[0]);
	Mux2To1Bits32 m1(out23, in2, in3Dummy, sel[0]);

	Mux2To1Bits32 m2(out, out01, out23, sel[1]);
endmodule

module AndBits32(out, in0, in1);
	input [31:0] in0, in1;
	output [31:0] out;
	assign out = in0 & in1;
endmodule

module OrBits32(out, in0, in1);
	input [31:0] in0, in1;
	output[31:0] out;
	assign out = in0 | in1;
endmodule

module FullAdderBits32(cout, sum, in0, in1, cin);
	input [31:0] in0, in1;
	input cin;
	output cout;
	output [31:0] sum;

	assign {cout, sum} = in0 + in1 + cin;
endmodule

module ALUBits32(a, b, binvert, cin, op, out, cout);
	input [31:0] a, b;
	input binvert, cin;
	input [1:0] op;

	output [31:0] out;
	output cout;

	wire [31:0] bin, andOut, orOut, sum;

	assign bin = (binvert == 0) ? b : ~b;

	AndBits32 a0(andOut, a, bin);
	OrBits32 o0(orOut, a, bin);
	FullAdderBits32 fa0(cout, sum, a, bin, cin);

	Mux3To1Bits32 m0(out, andOut, orOut, sum, op);
endmodule

module TestBench;
	reg binvert, cin;
	reg [1:0] op;
	reg [31:0] a, b;
	wire [31:0] out;
	wire cout;

	ALUBits32 alu(a, b, binvert, cin, op, out, cout);

	initial
	begin
		$monitor($time, "\t%d\t%d\t%d", a, b, out);
		a = 32'd1; b = 32'd3; cin = 0; binvert = 0; op = 2'b01;
		#5 a = 32'd15; b = 32'd16; cin = 1; binvert = 1; op = 2'b10;
	end
endmodule

