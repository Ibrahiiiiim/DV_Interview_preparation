module counter (
	input logic clk,    // Clock
	input logic rst,  // Asynchronous reset active high
	input logic up,
	output logic [3:0]dout
);


	always @(posedge clk or posedge rst) begin 
		if(rst) begin
			dout<= 0;
		end else if (up) begin
			dout <= dout+1;
		end else begin
			dout <= dout-1;	
		end
		
	end

endmodule : counter

module counter_assert (
	input logic clk,    // Clock
	input logic rst,  // Asynchronous reset active high
	input logic up,
	input logic [3:0]dout
);


//(1)behaviour of dout when reset is asserted


////dout is zero in next clock tick after rst
	DOUT_RST_ASS_1:assert property(@(posedge clk) $rose(rst) |=> (dout==0) )
		else $error("there is rst assert 1");

///// dout is zero for all clock ticks during rst
	DOUT_RST_ASS_2:assert property(@(posedge clk) rst |-> (dout==0) )
		else $error("there is rst assert 2");

 ////// dout remain stable to zero for entire duration of rst
 	DOUT_RST_ASS_3:assert property(@(posedge clk) $rose(rst) |=> rst throughout ((dout==0)[*1:36]))
		else $error("there is rst assert 3");


 /* (2) dout is unknown anywhere in the simulation */
    
     //////dout must be valid after rst deassert

    DOUT_VALID_1:assert property(@(posedge clk) $fell(rst) |=> !$isunknown(dout));
    
    DOUT_VALID_2:assert property(@(posedge clk) !$isunknown(dout) );

/* (3)   verifying up and down state of the counter  */

 
 //////current value of dout must be one greater than previous value when up = 1
 	DOUT_UP_1:assert property(@(posedge clk) disable iff(rst) up |-> (dout == $past(dout+1)) || (dout == 0));

/////// next value must be greater than zero when up = 1 and rst = 0 
	
	DOUT_UP_2:assert property(@(posedge clk) $fell(rst) |-> (dout != 0));

	DOUT_UP_3:assert property(@(posedge clk) $fell(rst) |-> up[->1] ##1 !$stable(dout))

 //////current value of dout must be one less than previous value when up = 0

	DOUT_UP_4:assert property(@(posedge clk) disable iff(rst) !up |-> (dout == $past(dout - 1)) || (dout == 0) || ($past(dout)==0));

	DOUT_UP_5:assert property(@(posedge clk) (!up && !rst) |-> !$stable(dout));


endmodule : counter_assert

module bind;
	bind counter counter_assert sva_ins(.*);
endmodule : bind
