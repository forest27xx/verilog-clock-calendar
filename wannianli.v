module wannianli(CLK_50, nCR,system_clk,pulse_day,day_add,month_add,year_add,day,month,year,day_bcd,month_bcd,year_bcd,runnian,xqj);
		input system_clk,day_add,month_add,year_add;
      input pulse_day;
		input  CLK_50, nCR;  
		output [4:0] day;//最大31
		output [3:0] month;//最大12
		output [13:0] year;// 使用 14 位来存储年份
		output reg runnian=1'b0;  // 输出闰年标志
      output reg [2:0] xqj=3'd2 ; // 输出星期几 (0-6)
		output reg [9:0] day_bcd;  // BCD representation of day (0-9)
      output reg [7:0] month_bcd;  // BCD representation of month (1-12)
      output reg [15:0] year_bcd;  // 用于存储年份的 BCD 编码
		wire _4Hz, _2Hz , _1Hz,  _500Hz,_1kHzIN;         //分频器的输出信号  
		//调用分频模块
	   CP_1kHz_500kHz_1Hz_2Hz_4Hz U0 (CLK_50, nCR, _1kHzIN, _500Hz,_1Hz,_2Hz,_4Hz); 
		wire pulse_day ;//天脉冲
		reg [4:0] day=5'd12;
		reg [4:0] day_set=12;
		reg [3:0] day_month;
		reg [13:0] day_year;
		wire pulse_month;//月脉冲
		reg [3:0] month=4'd12;
		reg [3:0] month_set=1;
		wire pulse_year;//年脉冲
		reg [13:0] year=14'd2023;
		reg [13:0] year_set=1;
		
		//天部分
		always@(posedge system_clk)
		begin
			
				if(pulse_day) //天脉冲
					if(month==1 || month==3 ||month==5 || month==7 || month==8 || month==10 || month==12)
						if(day>=31)
							day<=1;
						else
							day<=day+1;
					else if(month==4 || month==6 ||month==9 || month==11)
						if(day>=30)
							day<=1;
						else
							day<=day+1;
					else if(month==2 && (year%4==0))
						if(day>=29)
							day<=1;
						else
							day<=day+1;
					else
						if(day>=28)
							day<=1;
						else
							day<=day+1;	
				else if(day_add)
					day<=day_set;
				else
					day<=day;
		end
		//月脉冲的生成
		assign pulse_month=((day==5'd28 && month==4'd2 && (year%4!=0)&& pulse_day==1'b1)
		||(day==5'd29 && month==4'd2 && (year%4==0) && pulse_day==1'b1) 
		||(day==5'd30 && (month==4'd4 || month==4'd6 ||month==4'd9 || month==4'd11) && pulse_day==1'b1) 
		||(day==5'd31 && (month==4'd1 || month==4'd3 ||month==4'd5 || month==4'd7 || month==4'd8 || month==4'd10 || month==4'd12) && pulse_day==1'b1));
		//天的设置
		always@(day_add)
		begin
				day_set=day;
				day_month=month;
				day_year=year;
				if(day_month==1 || day_month==3 ||day_month==5 || day_month==7 || day_month==8 || day_month==10 || day_month==12)
					if(day_set>=31)
						day_set<=1;
					else
						day_set<=day_set+1;
				else if(day_month==4 || day_month==6 ||day_month==9 || day_month==11)
					if(day_set>=30)
						day_set<=1;
					else
						day_set<=day_set+1;
				else if(day_month==2 && (day_year%4==0))   //闰年
					if(day_set>=29)
						day_set<=1;
					else
						day_set<=day_set+1;
				else
					if(day_set>=28)
						day_set<=1;
					else
						day_set<=day_set+1;
		end
				
		//月部分
		always@(posedge system_clk)
		begin
			
				if(pulse_month)
					if(month>=12)
						month<=1;
					else
						month<=month+1;
				else if(month_add)
					month<=month_set;
				else
					month<=month;
		end
		//年脉冲的生成
		assign pulse_year=(month==4'd12 && pulse_month==1'b1);
		//月设置
		always@(month_add)
		begin
				month_set=month;
				if(month_set>=12)
					month_set=1;
				else
					month_set=month_set+1;
		end
		//年部分
		always@(posedge system_clk)
		begin
		
				if(pulse_year)
					if(year>=9999)
						year<=1;
					else
						year<=year+1;
				else if(year_add)
					year<=year_set;
				else
					year<=year;
		end
		//年设置
		always@(year_add)
		begin
				year_set=year;
				if(year_set>=9999)
					year_set=1;
				else
					year_set=year_set+1;
		end
	
		integer i,j,k,p, q;
		
		// Double dabble algorithm for day
		always @* begin
			 day_bcd = 10'b0; // 初始化为10位BCD
			 for (i = 4; i >= 0; i = i - 1) begin
				  if (day_bcd[3:0] >= 5)
						day_bcd[3:0] = day_bcd[3:0] + 3;
				  if (day_bcd[7:4] >= 5)
						day_bcd[7:4] = day_bcd[7:4] + 3;
		
				  day_bcd = day_bcd << 1;
				  day_bcd[0] = day[i];
			 end
		end
	
		// Double dabble algorithm for month
		always @* begin
			 month_bcd = 8'b0; // 初始化为8位BCD
			 for (j = 3; j >= 0; j = j - 1) begin
				  if (month_bcd[3:0] >= 5)
						month_bcd[3:0] = month_bcd[3:0] + 3;
		
				  month_bcd = month_bcd << 1;
				  month_bcd[0] = month[j];
			 end
		end
		
		// 年份的 BCD 转换
		always @(year) begin
			 year_bcd = 16'b0; // 初始化为 16 位 BCD
			 for (i = 13; i >= 0; i = i - 1) begin
				  // 在每一步之前，如果任何高位数字大于或等于 5，则加 3
				  if (year_bcd[3:0] >= 5)
						year_bcd[3:0] = year_bcd[3:0] + 3;
				  if (year_bcd[7:4] >= 5)
						year_bcd[7:4] = year_bcd[7:4] + 3;
				  if (year_bcd[11:8] >= 5)
						year_bcd[11:8] = year_bcd[11:8] + 3;
				  if (year_bcd[15:12] >= 5)
						year_bcd[15:12] = year_bcd[15:12] + 3;
		
				  // 将年份左移一位，然后将最低位设为当前处理位
				  year_bcd = year_bcd << 1;
				  year_bcd[0] = year[i];
			 end
		end
		//闰年及星期判断
		always @(posedge _500Hz) begin
			 if (year_add || pulse_year) begin
				  // 标准闰年判断
				  runnian <= (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
			 end
		end
		
		//星期判断

    reg [15:0] y;
    reg [7:0] m;
    

    always @(*) begin
        // 调整月份和年份
        if (month == 1 || month == 2) begin
            m = month + 12;
            y = year - 1;
        end else begin
            m = month;
            y = year;
        end

        k = y % 100;
        p = y / 100;
        q = day;

        // 使用蔡勒公式计算星期几//
        xqj = (q + (13 * (m + 1) / 5) + k + (k / 4) + (p / 4) - 2 * p) % 7 - 1;
        // 将结果调整为0到6范围内
        if (xqj < 0) xqj = xqj + 7;
    end

endmodule