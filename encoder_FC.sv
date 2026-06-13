module encoder (
	input logic [7:0]y,
	output logic [2:0]a

);



	always_comb begin
		case (y)
			8'b00000001:a=3'b000;
			8'b0000001?:a=3'b001;
			8'b000001??:a=3'b010;
			8'b00001???:a=3'b011;
			8'b0001????:a=3'b100;
			8'b001?????:a=3'b101;
			8'b001?????:a=3'b101;
			8'b01??????:a=3'b110;
			8'b1???????:a=3'b111;
			default : a=3'bzzz;
		endcase
		
	end

endmodule : encoder
module tb;
	logic [7:0]y;
	logic[2:0]a;

	covergroup cg;
		option.per_instance = 1;
		coverpoint y{
			bins zero={8'b00000001};
			wildcard bins one={8'b0000001?};
			wildcard bins two={8'b000001??};
			wildcard bins three={8'b00001???};
			wildcard bins four={8'b0001????};
			wildcard bins five={8'b001?????};
			wildcard bins six={8'b01??????};
			wildcard bins seven={8'b1???????};

		}

	endgroup : cg

	cg c1=new();

	initial begin
		for (int i = 0; i < 300; i++) begin
			y=$urandom();
			c1.sample();
			$display("y=%b ,coverage=%.2f",y,c1.get_inst_coverage());
			#10ns;
		end
	end
endmodule : tb