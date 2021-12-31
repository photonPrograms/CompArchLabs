module InstrMem(instr, pc, clock);
	input [31:0] pc;
	input clock;
	output reg [31:0] instr;

	reg [31:0] memory[0:31];
	integer addr;

	initial
	begin
		memory[0] = 32'd0; // nop
		memory[1] = 32'd0; // nop
		memory[2] = 32'd0; // nop
		memory[3] = 32'd0; // a lw
		memory[4] = 32'd0; // a lw
		memory[5] = 32'd0; // an add
	end

	always @(posedge clock)
	begin
		addr = pc[31:0];
		instr = memory[addr / 4];
	end
endmodule

module ProgCounter(count, clock, reset);
	input clock, reset;
	output reg [31:0] count;
	always @(posedge clock)
		if (!reset)
			count = count + 1;
		else
			count = 0;
endmodule

module ALU32Bit(zero, carryOut, result, a, b, op);
	input [31:0] a, b;
	input [2:0] op;
	output reg [31:0] result;
	output zero, carryOut;
	reg carryOut;

	assign zero = (result == 0) ? 1 : 0;
	always @(a or b or op)
		case(op)
			0: result = a & b;
			1: result = a | b;
			2: {carryOut, result[31:0]} = a + b;
			6: {carryOut, result[31:0]} = a - b;
			7: result = a < b ? 1 : 0;
			default: result = 0;
		endcase
endmodule

module DataMemory(memRead, memWrite, readAddr, writeAddr,
	readData, writeData, clock);
	input memRead, memWrite, clock;
	input [31:0] readAddr, writeAddr, writeData;
	output reg [31:0] readData;

	reg [31:0] memory[0:31];

	initial
	begin
		// dummy values
		memory[0] = 32'd0;
		memory[1] = 32'd0;
		memory[2] = 32'd0;
	end

	always @(posedge clock)
	begin
		if (memWrite)
			memory[writeAddr / 4] = writeData;
		else if (memRead)
			readData = memory[readAddr / 4];
	end
endmodule

module SignExtender(in, out);
	input [15:0] in;
	output [31:0] out;
	assign out = {{16{in[15]}}, in[15:0]};
endmodule

module ShiftLeft(in, out);
	input [31:0] in;
	output [31:0] out;

	assign out = {in[31:2], 2'b00};
endmodule

module concatJumpPC(out, jump, pc);
	input [31:0] jump, pc;
	output [31:0] out;

	assign out = {pc[31:28], jump[27:0]};
endmodule
