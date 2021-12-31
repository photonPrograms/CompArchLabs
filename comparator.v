module FindSign(isNeg, a);
	input [3:0] a;
	output isNeg;

	assign isNeg = a[3];
endmodule

module Compare(aGtB, aEqB, aLtB, a, b);
	input [3:0] a, b;
	output reg aGtB, aEqB, aLtB;

	wire signA, signB;

	FindSign fs0(signA, a);
	FindSign fs1(signB, b);

	always @(a, b, signA, signB)
	begin
		if (signA ^ signB)
		begin
			aGtB = ~signA;
			aEqB = 0;
			aLtB = ~signB;
		end
		else if (a > b)
		begin
			aGtB = 1;
			aEqB = 0;
			aLtB = 0;
		end
		else if (a == b)
		begin
			aGtB = 0;
			aEqB = 1;
			aLtB = 0;
		end
		else
		begin
			aGtB = 0;
			aEqB = 0;
			aLtB = 1;
		end
	end
endmodule

module testBench;
	reg [3:0] a, b;
	wire aGtB, aEqB, aLtB;
	
	Compare c0(aGtB, aEqB, aLtB, a, b);

	initial
	begin
		$monitor($time, "\ta =%b\tb =%b\t%b\t%b\t%b", a, b, aGtB, aEqB, aLtB);
		a = -8; b = -5;
		#5 a = 2; b = 7;
		#10 a = 5; b = -1;
		#15 a = 10; b = 10;
	end
endmodule
