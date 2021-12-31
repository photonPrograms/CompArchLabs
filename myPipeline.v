module Encoder(in, out);
	input [7:0] in;
	output [2:0] out;

	assign out[0] = in[1] | in[3] | in[5] | in[7],
		out[1] = in[2] | in[3] | in[6] | in[7],
		out[2] = in[4] | in[5] | in[6] | in[7];
endmodule

module testBench;
	reg [3:0] A, B;
	reg [7:0] instr;
	reg clock;
	wire parity;

	Integrate i0(A, B, instr, clock, parity);

	initial
	begin
		$monitor($time, "\t%b\t%b\t%b\t%b", A, B, instr, parity);
		clock = 1'b0;
		#8 A = 4'b1111; B = 4'b1110; instr = 8'b0000_0000;
		#8 instr = 8'b0000_0001;
		#8 instr = 8'b0000_1000;
		#8 instr = 8'b1000_0000;
		#8 $finish;
	end

	always
		#2 clock = ~clock;
endmodule

module ALUBits4(A, B, op, X);
	input [3:0] A, B;
	input [2:0] op;
	output [3:0] X;

	assign X = (op == 3'b000) ? A + B :
		(op == 3'b001) ? A - B :
		(op == 3'b010) ? A ^ B :
		(op == 3'b011) ? A | B :
		(op == 3'b100) ? A & B :
		(op == 3'b101) ? ~(A | B) :
		(op == 3'b110) ? ~(A & B) : ~(A ^ B);
endmodule

module EvenParityGenerator(X, parity);
	input [3:0] X;
	output parity;

	assign parity = ~(^X);
endmodule

module Pipeline1(A, B, op, clock, AOut, BOut, ctrl);
	input [3:0] A, B;
	input [2:0] op;
	input clock;
	
	output reg [3:0] AOut, BOut;
	output reg [2:0] ctrl;

	always @(posedge clock)
	begin
		AOut <= A;
		BOut <= B;
		ctrl <= op;
	end
endmodule

module Pipeline2(X, clock, XOut);
	input [3:0] X;
	input clock;

	output reg [3:0] XOut;

	always @(posedge clock)
	begin
		XOut <= X;
	end
endmodule

module Integrate(A, B, instr, clock, parity);
	input [3:0] A, B;
	input [7:0] instr;
	input clock;

	output parity;

	wire [2:0] op, ctrl;
	wire [3:0] AOut, BOut, X, XOut;

	Encoder en(instr, op);
	Pipeline1 p1(A, B, op, clock, AOut, BOut, ctrl);
	ALUBits4 alu(AOut, BOut, ctrl, X);
	Pipeline2 p2(X, clock, XOut);
	EvenParityGenerator epar(XOut, parity);
endmodule
