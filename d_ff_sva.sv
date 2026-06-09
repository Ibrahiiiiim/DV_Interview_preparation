module D_FF (
	input logic clk,    // Clock
	input logic rst_n,  // Asynchronous reset active low
	input logic D,
	output logic Q	
);


	always @(posedge clk or negedge rst_n) begin 
		if(~rst_n) begin
			Q<= 0;
		end else begin
			Q<=D ;
		end
	end

endmodule : D_FF

module D_FF_ASSERT (
	input logic clk,    // Clock
	input logic rst_n,  // Asynchronous reset active low
	input logic D,
	input logic Q
);


	Q_ASS:assert property(@(posedge clk) disable iff (!rst_n) Q == $past(D))
		else $error("Q does not equal the last value of D");

	//RESET_ASSE:assert property(@(negedge rst_n) Q==1'b0)
		//else $error("there is a problem in reset");

	RESET_ASSE:assert property(@(posedge clk) $fall(rst_n) |=> (Q==1'b0))
		else $error("there is a problem in reset");	

	/*
	In real simulations, because nonblocking assignments update after the active event region, 
	the exact assertion for async reset may depend on when you sample q. If you find that

	@(negedge rst_n) q == 0 fails due to scheduling,
	you may need a delayed check (e.g., |=>) so the assertion evaluates after the reset assignment has taken effect in the design.
	This is a common simulator/scheduling detail in SVA interviews and real verification work.
	
	*/
endmodule : D_FF_ASSERT

module bind;
	bind D_FF D_FF_ASSERT sva_ins(.*);
endmodule : bind