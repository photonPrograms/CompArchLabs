module MealyMachine(out, in, reset, clock);
	input in, reset, clock;
	output reg out;

	reg [1:0] state;

	always @(posedge clock, posedge reset)
	begin
		if (reset)
		begin
			state = 2'b00;
			out = 1'b0;
		end

		else
		begin
			case (state)
				2'b00:
				begin
					state = (in) ? 2'b01 : 2'b10;
					out = 1'b0;
				end
				
				2'b01:
				begin
					state = (in) ? 2'b00 : 2'b10;
					out = in;
				end

				2'b10:
				begin
					state = (in) ? 2'b01 : 2'b00;
					out = ~in;
				end

				default:
				begin
					state = 2'b00;
					out = 1'b0;
				end
			endcase
		end
	end
endmodule

module testBench;
	reg clock, reset, in;
	wire out;
	reg [15:0] sequence;
	integer i;

	MealyMachine mm(out, clock, reset, in);

	initial
	begin
		clock = 0;
		reset = 1;
		sequence = 16'b0101_0111_0111_0010;
		#5 reset = 0;

		for (i = 0; i < 15; i = i + 1)
		begin
			in = sequence[i];
			#2 clock = 1;
			#2 clock = 0;
			$display("state = %b, input = %b, output = %b", mm.state, in, out);
		end
		testing;
	end

	task testing;
		for (i = 0; i <= 15; i = i + 1)
		begin
			in = $random % 2;
			#2 clock = 1;
			#2 clock = 0;
			$display("state = %b, input = %b, output = %b", mm.state, in, out);
		end
	endtask
endmodule
