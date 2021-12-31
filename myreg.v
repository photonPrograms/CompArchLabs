module Dff(q, d, clock, reset);
	input d, clock, reset;
	output reg q;

	always @(posedge clock)
	begin
		// active-low reset
		if (!reset)
			q = 1'b0;
		else
			q = d;
	end
endmodule

/* without using Dff
module RegBits32(q, d, clock, reset);
	input [31:0] d;
	input clock, reset;
	output reg [31:0] q;
	
	integer j;

	always @(posedge clock)
	begin
		if (!reset)
			q = 32'b0;
		else
		begin
			for (j = 0; j < 32; j = j + 1)
				q[j] = d[j];
		end
	end
endmodule
*/

module RegBits32(q, d, clock, reset);
	input [31:0] d;
	input clock, reset;
	output [31:0] q;

	genvar j;
	generate
		for (j = 0; j < 32; j = j + 1)
		begin: regLoop
			Dff dff(q[j], d[j], clock, reset);
		end
	endgenerate
endmodule

module Mux4To1Bits32(out, in0, in1, in2, in3, sel);
	input [31:0] in0, in1, in2, in3;
	input [1:0] sel;
	output [31:0] out;

	assign out = (sel[1] == 0) ? (sel[0] == 0 ? in0 : in1) : 
		(sel[0] == 0 ? in2 : in3); 
endmodule

module Decoder2To4(out, in);
	input [1:0] in;
	output [3:0] out;

	assign out = {in[1] & in[0], in[1] & ~in[0],
		~in[1] & in[0], ~in[1] & ~in[0]};
endmodule

module RegFile(readData1, readData2, readReg1, readReg2,
				writeReg, writeData, regWrite, clock, reset);
	input [1:0] readReg1, readReg2, writeReg;
	input regWrite, clock, reset;
	input [31:0] writeData;

	output [31:0] readData1, readData2;

	wire [3:0] writeRegSel, clocks;
	wire [31:0] q0, q1, q2, q3;
	genvar j;

	Decoder2To4 de(writeRegSel, writeReg);

	generate
		for (j = 0; j < 4; j = j + 1)
		begin: setClock
			and a(clocks[j], regWrite, writeRegSel[j], clock);
		end
	endgenerate

	RegBits32 r0(q0, writeData, clocks[0], reset);
	RegBits32 r1(q1, writeData, clocks[1], reset);
	RegBits32 r2(q2, writeData, clocks[2], reset);
	RegBits32 r3(q3, writeData, clocks[3], reset);

	Mux4To1Bits32 m0(readData1, q0, q1, q2, q3, readReg1);
	Mux4To1Bits32 m1(readData2, q0, q1, q2, q3, readReg2);
endmodule

module TestBench;
	reg [31:0] writeData;
	reg reset, regWrite, clock;
	reg [1:0] readReg1, readReg2, writeReg;
	wire [31:0] readData1, readData2;

	RegFile rgf(readData1, readData2, readReg1, readReg2,
				writeReg, writeData, regWrite, clock, reset);
	
	initial
	begin
		$monitor($time, "%b\t%d\t%d\t%d", clock, writeData, readData1, readData2);
		reset = 0; readReg1 = 2'b00; readReg2 = 2'b11; clock = 0;
		#2 clock = 1;
		#4 reset = 1; clock = 0;
		#6 clock = 1; writeData = 32'd15; writeReg = 2'b11;
		#8 clock = 0;
	end
endmodule
