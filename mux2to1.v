module mux2to1Gate(a, b, s, f);
	input a, b, s;
	output f;
	wire aChoose, bChoose, sNot;

	not n1(sNot, s);
	and a1(aChoose, a, sNot);
	and a2(bChoose, b, s);
	or o1(f, aChoose, bChoose);
endmodule

module mux2to1DataFlow(a, b, s, f);
	input a, b, s;
	output f;

	assign f = s ? a : b;
endmodule

module mux2to1Behavioral(a, b, s, f);
	input a, b, s;
	output reg f;
	always @(a, b, s)
		if (s == 1)
			f = a;
		else
			f = b;
endmodule

module testBench;
	reg a, b, s;
	wire f;

	mux2to1Behavioral m1(a, b, s, f);
	initial
	begin
		$monitor(, $time, "a = %b, b = %b, s = %b, f = %b", a, b, s, f);
		#0 a = 1'b0; b = 1'b1;
		#2 s = 1'b1;
		#5 s = 1'b0;
		#10 a = 1'b1; b = 1'b0;
		#15 s = 1'b1;
		#20 s = 1'b0;
		#100 $finish;
	end
endmodule
