module Modulo_counter(CP, RSTn, En, Qbcd);
	parameter MOD=60;		//模数
	input CP, RSTn, En;
	reg [7:0] Q;
	reg [3:0] QH, QL;
	output wire [7:0] Qbcd;
	always@(posedge CP or negedge RSTn)
		if (!RSTn)	
		begin
		      QH <= 0; 
		      QL <= 0;
				Q<=0;
		end
		else if (En) begin
			if (Q == MOD-1) begin 
			    Q <= 0;
				 QH <= 0;
				 QL <= 0;
		   end
			else	begin 
			    Q <= Q + 1'b1; 
				 if (QL == 4'b1001) begin
				     QL <=0;
					  QH <= QH + 1'b1;
				 end 
				 else begin
				     QL <= QL + 1'b1;
				 end
			end
		end
	assign Qbcd = {QH, QL};
endmodule

