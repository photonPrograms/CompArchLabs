module ShiftReg(q, in, clock, en);
	parameter n = 4;
	input in, clock, en;
	output reg [n - 1 : 0] q;

	initial
		q = 4'b10;

	always @(posedge clock)
	begin
		if (en)
			q = {in, q[n - 1: 1]}; 
	end
endmodule

module testBench;
	parameter n = 4;
	reg en, in, clock;
	wire [n - 1 : 0] q;

	ShiftReg sr(q, in, clock, en);

	initial
	begin
		clock = 0;
	end

	always
		#2 clock = ~clock;

	initial
		$monitor($time, "\t%b\t%b\t%b", en, in, q);

	initial
	begin
		in = 0; en = 0;
		#4 in = 1; en = 1;
		#4 in = 1; en = 0;
		#4 in = 0; en = 1;
		#5 $finish;
	end
endmodule
