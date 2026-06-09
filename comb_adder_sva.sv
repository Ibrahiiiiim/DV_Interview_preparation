module comb_adder (input logic[3:0] a,b ,output[4:0] logic y);
	assign y=a+b;
endmodule : comb_adder

module comb_adder_assert (input logic[3:0] a,b ,input[4:0] logic y);
	assert #0 (a+b==y)
		else $error("adder_mismatch");
endmodule : comb_adder_assert

module bind;
	bind comb_adder comb_adder_assert sva_ins(.*);
endmodule : bind