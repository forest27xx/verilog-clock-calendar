module scan_dig(clk, rstn, enable, data, dig, seg);		
	input clk, rstn, enable;
	input[31:0] data;		
	output[7:0] dig, seg ;	//dig片选 选择数码管，seg段选
	reg[7:0] seg_r, dig_r;	
	reg[3:0] disp_dat;		//用来显示的数值 bcd码
	reg[2:0] count;			//计数器 3位

	assign dig = dig_r;		
	assign seg = seg_r;		

	always @(posedge clk or negedge rstn)   //计数器加一
	begin
		if (!rstn)
			count <= 0;
		else if (enable)
			count <= count + 1'b1;
	end
always @(count or data)   		
	begin
		case(count)			//根据计数器的值进行片选
			3'b000: begin
				disp_dat = data[31:28];				//数码管显示数据为data[31:28]
				dig_r = 8'b01111111;		//第一个数码管为0，选择该数码管
			end
			3'b001: begin
				disp_dat = data[27:24];		
				dig_r = 8'b10111111;
			end
			3'b010: begin
				disp_dat = data[23:20];	
				dig_r = 8'b11011111;		
			end
			3'b011: begin
				disp_dat = data[19:16];		
				dig_r = 8'b11101111;
			end
			3'b100: begin
				disp_dat = data[15:12];
				dig_r = 8'b11110111;		
			end
			3'b101: begin
				disp_dat = data[11:8];		
				dig_r = 8'b11111011;
			end
			3'b110: begin
				disp_dat = data[7:4];	
				dig_r = 8'b11111101;	
			end
			3'b111: begin
				disp_dat = data[3:0];		
				dig_r = 8'b11111110;
			end
			default: begin
				disp_dat = 4'hx;
				dig_r = 8'hxx;
			end
		endcase
	end
always @(disp_dat)
	begin
		case(disp_dat)	
			4'h0:seg_r = ~(8'hc0);	
			4'h1:seg_r = ~(8'hf9);//1
			4'h2:seg_r = ~(8'ha4);//2
			4'h3:seg_r = ~(8'hb0);//3
			4'h4:seg_r = ~(8'h99);//4
			4'h5:seg_r = ~(8'h92);//5
			4'h6:seg_r = ~(8'h82);//6
			4'h7:seg_r = ~(8'hf8);//7
			4'h8:seg_r = ~(8'h80);//8
		   4'h9:seg_r = ~(8'h90);//9
			4'ha:seg_r = ~(8'h88);//a
			4'hb:seg_r = ~(8'h83);//b
			4'hc:seg_r = ~(8'hc6);//c
			4'hd:seg_r = ~(8'ha1);//d
			4'he:seg_r = ~(8'h86);//e
			4'hf:seg_r = ~(8'hbf);//-
			default: seg_r = 8'hxx;
		endcase
	end
endmodule