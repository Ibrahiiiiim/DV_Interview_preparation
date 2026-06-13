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
module tb;

	logic clk,rst,wr,rd;
	logic [7:0]din;
	logic empty,full;
	logic [7:0]dout;


	fifo dut (.*);


	initial clk=0;

	always #5ns clk=~clk;


		covergroup cg @ (posedge clk);

			option.per_instance = 1;
			
			coverpoint empty{
				bins empty_l={0};
				bins empty_h={1};
			}

			coverpoint full{
				bins full_l={0};
				bins full_h={1};
			}

			coverpoint rst{
				bins rst_l={0};
				bins rst_h={1};
			}

			coverpoint wr{
				bins wr_l={0};
				bins wr_h={1};
			}

	
			coverpoint rd{
				bins rd_l={0};
				bins rd_h={1};
			}


			coverpoint din{

				bins low={[0:84]};
				bins mid={[85:169]};
				bins high={[170:255]};
			}

			
			coverpoint dout{

				bins low={[0:84]};
				bins mid={[85:169]};
				bins high={[170:255]};
			}

			cross_rst_wr:cross rst,wr{
				ignore_bins unused_rst=binsof(rst)intersect{1};
				ignore_bins unused_wr=binsof(wr)intersect{0};
			}

			cross_rst_rd:cross rst,rd{
				ignore_bins unused_rst=binsof(rst)intersect{1};
				ignore_bins unused_rd=binsof(rd)intersect{0};
			}

			cross_wr_din:cross rst,wr,din{
				ignore_bins unused_rst=binsof(rst)intersect{1};
				ignore_bins unused_wr=binsof(wr)intersect{0};

			}
			cross_rd_dout:cross rst,rd,dout{
				ignore_bins unused_rst=binsof(rst)intersect{1};
				ignore_bins unused_rd=binsof(rd)intersect{0};

			}

			cross_wr_full:cross rst,wr,full{
				ignore_bins unused_rst=binsof(rst)intersect{1};
				ignore_bins unused_wr=binsof(wr)intersect{0};
				ignore_bins unused_full=binsof(full)intersect{0};

			}

			cross_rd_empty:cross rst,rd,empty{
				ignore_bins unused_rst=binsof(rst)intersect{1};
				ignore_bins unused_rd=binsof(rd)intersect{0};
				ignore_bins unused_empty=binsof(empty)intersect{0};

			}
			
			
		endgroup : cg
		cg c1 = new();
	


	task write();
		for (int i = 0; i < 20; i++) begin
			wr=1;
			rd=0;
			din=$urandom();
			@(posedge clk);
			$display("wr: %0d, addr : %0d, din : %0d full:%0d,coverage=%.02f", wr, i, din, full,c1.get_inst_coverage());
            wr = 0;
            @(posedge clk);
		end
	endtask : write


	task read();

	    for(int i = 0; i < 20; i++) begin   
		    wr = 1'b0;
		    rd = 1'b1;
		    din = 0;
		    @(posedge clk);
		    rd = 1'b0;
		    @(posedge clk);
		    $display("rd: %0d, addr : %0d, dout : %0d empty : %0d,coverage=%.02f", rd, i, dout,empty,c1.get_inst_coverage());
	    end 

    endtask


    initial begin
        rst = 1;
        wr = 0;
        rd = 0;
        repeat(5) @(posedge clk);
        rst = 0;
        write();
        read();
    end

    


endmodule : tb


