module top(
    input logic clk,
    input logic rst,
    input logic din,
    output logic dout
);

    enum bit [2:0] {
        idle = 3'b001,
        s0 = 3'b010,
        s1 = 3'b100
    } state = idle, next_state = idle;

    always_ff begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end

    always_comb begin
        dout = 1'b0;
        next_state = idle;
        case(state)
            idle: begin
                dout = 1'b0;
                next_state = s0;
            end

            s0: begin
                if(din == 1'b1) begin
                    next_state = s1;
                    dout = 1'b0;
                end
                else begin
                    next_state = s0;
                    dout = 1'b0;
                end
            end

            s1: begin
                if(din == 1'b1) begin
                    next_state = s0;
                    dout = 1'b1;
                end
                else begin
                    next_state = s1;
                    dout = 0;
                end
            end

            default: begin
                next_state = idle;
                dout = 0;
            end
        endcase
    end
endmodule

module top_assert (
    input logic clk,
    input logic rst,
    input logic din,
    input logic dout,
    input logic [2:0] state,
    input logic [2:0] next_state
    
);

////////////// (1) State is one hot encoded
    // state one hot encoding

    STATE_ENCODING:assert property(@(posedge clk) $onehot(state));

////////////// (2) Behavior on rst high
    //rst behavior
    
    STATE_RST_HIGH:assert property(@(posedge clk) rst |=> (state==idle));

    STATE_THR_RST_HIGH:assert property(@(posedge clk) $rose(rst) |=> ((state == idel)[*1:18]) within (rst[*1:18] ##1 !rst));


/////////////////    (3) Behavior on rst low


    sequence s1;
        (next_state==idle) ##1 (next_state==s0);
    endsequence

    sequence s2;
        (next_state==s0) ##1 (next_state==s1);
    endsequence 

    sequence s3;
        (next_state==s1) ##1 (next_state==s0);
    endsequence

    STATE_DIN_HIGH:assert property(@(posedge clk) disable iff(rst) din|-> s1 or s2 or s3);

    sequence s4;
        (next_state==idle) ##1 (next_state==s0);
    endsequence

    sequence s5;
        (next_state==s0) ##1 (next_state==s0);
    endsequence 

    sequence s6;
        (next_state==s1) ##1 (next_state==s1);
    endsequence

    STATE_DIN_LOW:assert property(@(posedge clk) disable iff(rst) !din |-> s4 or s5 or s6 );

///////////////   (4) all states are cover

    initial assert property(@(posedge clk) disable iff(rst) (state ==idle) [->1] |-> ##[1:18] (state==s0) ##[1:18] (state=s1));

    /*initial means the assertion is activated once at time 0 to check a single expected sequence through simulation, 
    instead of continuously checking every clock cycle.*/

////////////////// (5) output check

    assert property(@(posedge clk) disable iff(rst) (next_state ==s0 ) && ($past(next_state)==s1) |-> (dout==1))
endmodule : top_assert

module bind;

    bind top top_assert sva_ins(.clk    (clk),.rst       (rst),.next_state(next_state),.state     (state),.dout      (dout),.din       (din));

endmodule : bind

