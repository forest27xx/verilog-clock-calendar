module dongtaishumaguan(clk,rst,data,sel,seg);
    input clk;
	 input rst;
	 input [31:0] data;
	 output reg [7:0] sel;
	 output reg [7:0] seg;
	 reg [2:0] cnt;
	 always @(posedge clk or negedge rst)
	   begin
	    if(!rst)
	      cnt <= 0;
	    else
	      cnt <= cnt+1'b1;
	   end
	 always @(*)begin
	  case(cnt)
	   0:sel = 8'b0000_0001;
	   1:sel = 8'b0000_0010;
	   2:sel = 8'b0000_0100;
	   3:sel = 8'b0000_1000;
	   4:sel = 8'b0001_0000;
	   5:sel = 8'b0010_0000;
	   6:sel = 8'b0100_0000;
	   7:sel = 8'b1000_0000;
	  endcase
	end
	 reg [3:0] data_1;
	always@(*)begin
	  case(cnt)
	    0:data_1 = data[31:28];
		1:data_1 = data[27:24];
		2:data_1 = data[23:20];
		3:data_1 = data[19:16];
		4:data_1 = data[15:12];
		5:data_1 = data[11:8];
		6:data_1 = data[7:4];
		7:data_1 = data[3:0];
	  endcase
	end
	always @(*)begin
	  case(data_1)
	     0:seg = 8'hc0;
		 1:seg = 8'hf9;
		 2:seg = 8'ha4;
		 3:seg = 8'hb0;
		 4:seg = 8'h99;
		 5:seg = 8'h92;
		 6:seg = 8'h82;
		 7:seg = 8'hf8;
		 8:seg = 8'h80;
		 9:seg = 8'h90;
	 4'ha:seg = 8'h88;
	 4'hb:seg = 8'h83;
	 4'hc:seg = 8'hc6;
	 4'hd:seg = 8'ha1;
	 4'he:seg = 8'h86;
	 4'hf:seg = 8'hbf;//显示横杠
	  endcase
	end
endmodule