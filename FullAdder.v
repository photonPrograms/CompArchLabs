module Decoder(d, x, y, z);
	input x, y, z;
	output [7:0] d;

	and a0(d[0], ~x, ~y, ~z);
	and a1(d[1], ~x, ~y, z);
	and a2(d[2], ~x, y, ~z);
	and a3(d[3], ~x, y, z);
	and a4(d[4], x, ~y, ~z);
	and a5(d[5], x, ~y, z);
	and a6(d[6], x, y, ~z);
	and a7(d[7], x, y, z);
endmodule

module FAdder(s, c, x, y, z);
	input x, y, z;
	output s, c;
	wire [7:0] d;
	Decoder d0(d, x, y, z);
	assign
		s = d[1] | d[2] | d[4] | d[7],
		c = d[3] | d[5] | d[6] | d[7];
endmodule

module testBench;
	reg x, y, z;
	wire s, c;

	FAdder fa(s, c, x, y, z);

	initial
	begin
		$monitor($time, "\t x=%b\ty=%b\tz=%b\ts=%b\tc=%b", x, y, z, s, c);
		x = 1'b0; y = 1'b1; z = 1'b0;
		#5 x = 1'b1; y = 1'b0; z=1'b1;
		#10 x = 1'b1; y = 1'b1; z = 1'b1;
	end
endmodule
