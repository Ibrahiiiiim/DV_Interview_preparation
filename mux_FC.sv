module MUX (input logic a,b,c,d,e,f,g,h,[2:0]sel,output logic y);
	always @(*) begin 
		case (sel)
		
			0:y=a;
			1:y=b;
			2:y=c;
			3:y=d;
			4:y=e;
			5:y=f;
			6:y=g;
			7:y=h;

			default :y=0;
		endcase
		
	end
endmodule : MUX
module tb;
	logic a,b,c,d,e,f,g,h;
	logic [2:0]sel;
	logic y;

	MUX dut(.*);

	covergroup cg;
		option.per_instance = 1;
		coverpoint a{
			bins a_low={0};
			bins a_high={1};
		}
		coverpoint b{
			bins b_low={0};
			bins b_high={1};
		}
		coverpoint c{
			bins c_low={0};
			bins c_high={1};
		}
		coverpoint d{
			bins d_low={0};
			bins d_high={1};
		}
		coverpoint e{
			bins e_low={0};
			bins e_high={1};
		}
		coverpoint f{
			bins f_low={0};
			bins f_high={1};
		}
		coverpoint g{
			bins g_low={0};
			bins g_high={1};
		}
		coverpoint h{
			bins h_low={0};
			bins h_high={1};
		}

		coverpoint y;
		coverpoint sel;

		cross_sel_a:cross sel,a{

			illegal_bins sel_other= binsof(sel) intersect{[1:7]};
		}

		
		cross_sel_b:cross sel,b{

			illegal_bins sel_other= binsof(sel) intersect{0,[2:7]};
		}

		
		cross_sel_c:cross sel,c{

			illegal_bins sel_other= binsof(sel) intersect{[0:1],[3:7]};
		}

		
		cross_sel_d:cross sel,d{

			illegal_bins sel_other= binsof(sel) intersect{[0:2],[4:7]};
		}

		
		cross_sel_e:cross sel,e{

			illegal_bins sel_other= binsof(sel) intersect{[0:3],[5:7]};
		}

		
		cross_sel_f:cross sel,f{

			illegal_bins sel_other= binsof(sel) intersect{[0:4],[6:7]};
		}

		
		cross_sel_g:cross sel,g{

			illegal_bins sel_other= binsof(sel) intersect{[0:5],7};
		}
		
		cross_sel_h:cross sel,h{

			illegal_bins sel_other= binsof(sel) intersect{[0:6]};
		}

		
	endgroup : cg

	cg c1=new();

	initial begin

		for (int i = 0; i < 100; i++) begin
			sel=$urandom();
			{a,b,c,d,e,f,g,h} = $urandom();
			c1.sample();
			
			#10ns;
		end
		

	end
endmodule : tb