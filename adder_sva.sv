module add (input logic clk ,[7:0] a, b, output logic[8:0] sum);

	always_ff @(posedge clk) begin
			sum <= a+b;
	end

endmodule : add

module sum_assert (
	input logic clk,    // Clock
	input logic [7:0] a,b,
	input logic [8:0] sum
	
);



	SUM_CHECK:assert property( @(posedge clk) $changed(sum) |-> (sum == (a + b)))
		else $error("sum is not correct");

	SUM_VALID:assert property( @(posedge clk) !$isunknown(sum))
		else $error("sum is x or z");
	assert property (@ (posedge clk) !$isunknown(a))
		else $error("a is x or z");
	assert property (@ (posedge clk) !$isunknown(b))
		else $error("b is x or z");

endmodule : sum_assert

module bind;

	bind add sum_assert sva_ins(.*);

endmodule : bind


