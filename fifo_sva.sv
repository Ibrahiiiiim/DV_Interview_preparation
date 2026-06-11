module fifo (
	input logic clk,rst,wr,rd,
	input logic [7:0]din,
	output logic [7:0]dout,
	output logic empty,full
	
);

	logic [7:0] mem[15:0];
	logic [3:0] wptr=0, rptr=0,cnt=0;

	always_ff @(posedge clk) begin 
		if(rst) begin
			cnt<= 0;
			rptr<= 0;
			wptr<= 0;
		end else if (wr && !full) begin
			if (cnt<15) begin
				mem[wptr]<=din;
				wptr<=wptr+1;
				cnt<=cnt+1;
			end
		end else if (rd && !empty) begin
			if (cnt>0) begin
				dout<=mem[rptr];
				rptr<=rptr+1;
				cnt<=cnt-1;
			end
		end
		
		if(wptr == 15) wptr <= 0;
        if(rptr == 15) rptr <= 0;

	end

	assign full = (cnt == 15) ? 1'b1: 1'b0;
    assign empty = (cnt == 0) ? 1'b1: 1'b0;


endmodule : fifo

module fifo_assert #(parameter DEPTH=16)(
	input logic clk,rst,wr,rd,
	input logic [7:0]din,
	input logic [7:0]dout,
	input logic empty,full,
	input logic wptr,rprt,[$clog2(DEPTH)-1:0]cnt
	
);


/*# SVA: When to Use |-> vs |=>

## Key Idea

Assertions sample signals before Non-Blocking Assignments (NBA) are updated.

RTL:

```systemverilog
always_ff @(posedge clk)
    q <= d;
```

At a clock edge:

1. Assertions sample values.
2. RTL evaluates.
3. NBA updates occur.
4. Registers get new values.

Therefore, assertions usually see the **old value** of a register during the current clock edge.

---

## Overlapping Implication (|->)

Syntax:

```systemverilog
A |-> B
```

Meaning:

> If A is true in the current cycle, B must also be true in the current cycle.

Example:

```systemverilog
assert property (
    @(posedge clk)
    rst |-> empty
);
```

Use when checking signals that should already be valid at the same sampled edge.

---

## Non-Overlapping Implication (|=>)

Syntax:

```systemverilog
A |=> B
```

Meaning:

> If A is true now, B must be true in the next clock cycle.

Example:

```systemverilog
assert property (
    @(posedge clk)
    rst |=> (cnt == 0)
);
```

Use when checking the effect of a sequential update.

---

## Why Reset Checks Usually Use |=>

RTL:

```systemverilog
always_ff @(posedge clk)
begin
    if (rst)
        cnt <= 0;
end
```

At cycle N:

```text
rst = 1
cnt = 5
```

Assertion sampling sees:

```text
cnt = 5
```

not:

```text
cnt = 0
```

because NBA updates have not occurred yet.

Therefore:

```systemverilog
rst |-> (cnt == 0)    // likely FAIL
```

but:

```systemverilog
rst |=> (cnt == 0)    // PASS
```

because cnt is checked one cycle later.

---

## Rule of Thumb

Checking combinational behavior:
Use |->

Checking sequential/register updates:
Use |=>

Checking results of <= assignments:
Usually use |=>

Checking current-cycle relationships:
Usually use |->*/



	 // (1) status of full and empty when rst asserted

	 ///chech on edge

	 RST_1:assert property(@(posedge clk) $rose(rst) |-> (empty==1) && (full==0) );

	 //chech on level

	 RST_2:assert property (@(posedge clk) rst |-> (empty==1) && (full==0) );

	 RESET_CHECK:assert property (@(posedge clk) rst |=> (cnt == 0 && wptr == 0 && rptr == 0));



 //  (2) operation of full and empty flag

 	FULL_1:assert property(@(posedge clk) disable iff(rst) $rose(full) |=> (wptr==0) [*1:$] ##1 !full);

 	FULL_2:assert property(@(posedge clk) disable iff(rst) (cnt==DEPTH) == (full)) ;

 	EMPTY_1:assert property(@(posedge clk) disable iff(rst) $rose(empty) |=> (rptr==0)[*1:$] ##1 !empty);

 	EMPTY_2:assert property(@(posedge clk) disable iff(rst) (cnt==0) == (empty) );

    /// (3) read while empty
   A_NO_OVERFLOW:assert property(@(posedge clk) disable iff(rst) wr |-> !full);
   
   A_NO_UNDERFLOW:assert property(@(posedge clk) disable iff(rst) rd |-> !empty);

////////////// (5) Write+Read pointer behavior with rd and wr signal

	      //////if wr high and full is low, wptr must incr


	WPTR_1:assert property(@(posedge clk) (!rst && wr && !full) |=> $changed(wptr));
	
	WPTR_2:assert property(@(posedge clk) (!rst && !wr) |=> $stable(wptr));

	WPTR_3:assert property(@(posedge clk) (!rst && rd) |=> $stable(wptr));

	RPTR_1:assert property(@(posedge clk) (!rst &&rd && !empty) |=> $changed(rptr))

	RPTR_2:assert property(@(posedge clk) (!rst && !rd ) |=> $stable(rptr));

	RPTR_3:assert property(@(posedge clk) (!rst && wr ) |=> $stable(rptr));


	DIN_IS_UNKNOWN:assert property(@(posedge clk) disable iff(rst) !$isunknown(din));
	DOUT_IS_UNKNOWN:assert property(@(posedge clk) disable iff(rst) !$isunknown(dout));
	WR_IS_UNKNOWN:assert property(@(posedge clk) disable iff(rst) !$isunknown(wr));
	RD_IS_UNKNOWN:assert property(@(posedge clk) disable iff(rst) !$isunknown(rd));

	A_COUN_DEPTH:assert property(@(posedge clk) disable iff(rst) cnt <=DEPTH);


	A_COUNT_WR:assert property(@(posedge clk) disable iff(rst) (wr && !full && !rd) |=> (cnt == $past(cnt) +1));
	
	A_COUNT_RD:assert property(@(posedge clk) disable iff(rst) (!wr && !empty && rd) |=> (cnt == $past(cnt) -1));

	A_COUNT_WR:assert property(@(posedge clk) disable iff(rst) (wr && !empty && rd && !full)  |=> $stable(cnt));

	C_EMPTY_TO_FULL:assert property(@(posedge clk) disable iff(rst) empty ##[1:$] full);


	C_FULL_THEN_READ:assert property(@(posedge clk) disable iff(rst) full ##1(rd && !wr));
endmodule : fifo_assert


module bind;

	bind fifo fifo_assert #(parameter DEPTH=16) sva_ins(.clk  (clk),.rd   (rd),.rst  (rst),.wr   (wr),.empty(empty),.full (full),.wptr (wptr),.din  (din),.dout (dout),.rprt (rprt),.cnt(cnt));

endmodule : bind