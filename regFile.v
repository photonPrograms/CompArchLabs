module d_ff(q, d, clock, reset);
	input d, clock, reset;
	output reg q;

	always @(posedge clock or negedge reset)
		if (~reset)
			q = 1'b0;
		else
			q = d;
endmodule

module reg_32bit(q, d, clock, reset);
	input [31:0] d;
	input clock, reset;
	output [31:0] q;

	genvar j;
	generate
		for (j = 0; j < 32; j = j + 1)
		begin: d_loop
			d_ff ff(q[j], d[j], clock, reset);
		end
	endgenerate
endmodule

module decoder2_4(out, in);
	input [1:0] in;
	output [3:0] out;

	assign
		out[0] = ~in[0] & ~in[1],
		out[1] = ~in[0] & in[1],
		out[2] = in[0] & ~in[1],
		out[3] = in[0] & in[1];
endmodule

module mux4_1(out, data0, data1, data2, data3, select);
	input [31:0] data0, data1, data2, data3;
	input [1:0] select;
	output reg [31:0] out;

	always @(data0 or data1 or data2 or data3 or select)
		case (select)
			2'b00: out = data0;
			2'b01: out = data1;
			2'b10: out = data2;
			2'b11: out = data3;
		endcase
endmodule

module regFile_4(readReg1, readReg2, clock, reset,
	writeRegNo, writeData, regWrite, readData1, readData2);
	input [1:0] readReg1, readReg2, writeRegNo;
	input clock, reset, regWrite;
	input [31:0] writeData;
	output [31:0] readData1, readData2;

	wire [3:0] decode;
	wire [31:0] w0, w1, w2, w3;

	decoder2_4 dec(decode, writeRegNo);
	and a0(c0, regWrite, clock, decode[0]);
	and a1(c1, regWrite, clock, decode[1]);
	and a2(c2, regWrite, clock, decode[2]);
	and a3(c3, regWrite, clock, decode[3]);

	reg_32bit r0(w0, writeData, c0, reset);
	reg_32bit r1(w1, writeData, c1, reset);
	reg_32bit r2(w2, writeData, c2, reset);
	reg_32bit r3(w3, writeData, c3, reset);

	mux4_1 m0(readData1, w0, w1, w2, w3, readReg1);
	mux4_1 m1(readData2, w0, w1, w2, w3, readReg2);
endmodule
