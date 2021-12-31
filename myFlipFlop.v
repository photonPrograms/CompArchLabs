module DffSync(q, d, clear, clock);
	input d, clear, clock;
	output reg q;

	always @(posedge clock)
	begin
		q = ~clear & d;
	end
endmodule

module DffAsync(q, d, clear, clock);
	input d, clear, clock;
	output reg q;

	always @(negedge clear or posedge clock)
	begin
		if (!clear)
			q = 1'b0;
		else
			q = d;
	end
endmodule

module testBench;
	reg d, clear, clock;
	wire q;

	DffAsync dff(q, d, clear, clock);

	initial
	begin
		$monitor($time, "\t%d\t%d\t%d\t%d", clock, clear, d, q);
		clock = 1'b0; clear = 1'b0; d = 1'b1;
		#5 clock = 1'b1; clear = 1'b0; d = 1'b1;
		#5 clock = 1'b0; clear = 1'b0; d = 1'b0;
		#5 clock = 1'b1; clear = 1'b1; d = 1'b1;
		#5 clock = 1'b0; clear = 1'b0; d = 1'b1;
		//$finish;
	end
endmodule
