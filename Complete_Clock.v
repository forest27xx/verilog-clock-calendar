//****************  Complete_Clock.v  *****************
module Complete_Clock (state_led,page_key,sel,seg, ALARM,pulse_day, CLK_50, AdjMinKey, AdjHrKey,day_add,month_add,year_add,SetMinKey, SetHrKey, CtrlBell, Mode, nCR,runnian_out,xqj_out);
    input  CLK_50, nCR;    
    input  AdjMinKey, AdjHrKey,day_add,month_add,year_add;
    input  SetHrKey, SetMinKey; //设定闹钟小时、分钟的输入按键
	 
    input CtrlBell; //控制闹钟的声音是否输出的按键
    input page_key,Mode;  //控制显示模式切换的按键。
	 wire Mode_1,flag;
    wire [7:0] LED_Hr, LED_Min, LED_Sec,  LED_Mon, LED_Day; //输出BCD码
	 wire [15:0]LED_Year;
	 wire [31:0] data,data_1;
	 wire [9:0] day,day_bcd;//最大31
	 wire [7:0] month,month_bcd;//最大12
	 wire [15:0] year,year_bcd;//最大99
	 wire [2:0] xqj;
	 wire runnian;
	 output wire [15:0]runnian_out;  // 新增闰年输出
    output wire [15:0] xqj_out;
    output ALARM,pulse_day;       //仿电台或闹钟的声音信号输出
	 output [7:0] sel;
	 output [7:0] seg;
	 output [1:0] state_led;
    wire _4Hz, _2Hz , _1Hz,  _500Hz,_1kHzIN;         //分频器的输出信号  
    wire [7:0] Hour, Minute, Second, Month, Day; //计时器的输出信号
	 wire [15:0]Year;
    wire [7:0] Set_Hr, Set_Min,Set_Hr_Delayed, Set_Min_Delayed;  //设定的闹钟时间输出信号
    wire  ALARM_Radio;  //仿电台报时信号输出
    wire  ALARM_Clock;  //闹钟的信号输出
	 wire  pulse_day;//计时器的天脉冲输出
	 //调用分频模块
	 CP_1kHz_500kHz_1Hz_2Hz_4Hz U0 (CLK_50, nCR, _1kHzIN, _500Hz,_1Hz,_2Hz,_4Hz); 
	 //计时主体电路
	 Top_Clock U1(.pulse_day(pulse_day),.Hour(Hour), .Minute(Minute), .Second(Second), ._1Hz(_4Hz), .nCR(nCR), .AdjMinKey(AdjMinKey), .AdjHrKey(AdjHrKey)); 
	 //仿电台整点报时
	 Radio U2(ALARM_Radio , Minute, Second, _1kHzIN, _500Hz); 
	 //定时闹钟模块
	 Bell U3(ALARM_Clock, Set_Hr, Set_Min,Hour, Minute, Second, SetHrKey, SetMinKey, _4Hz,_2Hz, _500Hz, _2Hz, CtrlBell); 
    assign ALARM = ALARM_Radio||ALARM_Clock; 
	 //按键切换模块
	 reg [1:0] state,state_led;
    wire page_key_pressed;

    // 边沿检测模块
    edge_detect page_key_edge_detect (
        .clk(CLK_50),
        .reset(nCR),
        .signal_in(page_key),
        .signal_edge(page_key_pressed)
    );

    // 状态机
    always @(posedge CLK_50 or negedge nCR) begin
        if (!nCR) 
            state <= 2'b00;
        else if (page_key_pressed) begin
            case(state)
                2'b00: state <= 2'b01;
                2'b01: state <= 2'b11;
                2'b11: state <= 2'b00;
            endcase
        end
    end

    assign Mode_1 = state[1];
    assign flag = state[0]; 
    //万年历模块
	 wannianli U4(.CLK_50(CLK_50), .nCR(nCR),.system_clk(_2Hz),.pulse_day(pulse_day),.day_add(day_add),.month_add(month_add),.year_add(year_add),
	 .day(day),.month(month),.year(year),.day_bcd(day_bcd),.month_bcd(month_bcd),.year_bcd(year_bcd),.runnian(runnian),.xqj(xqj));
    _2to1MUX MU1(LED_Hr,  Mode, Set_Hr, Hour);
    _2to1MUX MU2(LED_Min, Mode, Set_Min, Minute);
    _2to1MUX MU3(LED_Sec, Mode, 8'h00, Second);
	 //数码管
	 assign Year={8'b00100000,year_bcd};
	 assign Month=month_bcd;
	 assign Day=day_bcd;
    assign runnian_out = {15'b111111111111000,runnian};
    assign xqj_out =(xqj==7)?6:xqj;


	 _2to1MUX16 MU4(LED_Year,  Mode_1,runnian_out, Year);
    _2to1MUX MU5(LED_Mon, Mode_1, 8'h00, Month );
    _2to1MUX MU6(LED_Day, Mode_1, xqj_out, Day);
	 assign data_1={LED_Year, LED_Mon, LED_Day};
	 assign data = flag ? data_1 : {LED_Hr, 4'hf, LED_Min, 4'hf, LED_Sec};
	 // dongtaishumaguan U4(_1kHzIN,nCR,data,sel,seg);
	 scan_dig U5(.clk(_1kHzIN), .rstn(nCR), .enable(1'b1), .data(data), .dig(sel), .seg(seg));
	 //led点阵模块
	  always @(posedge _1Hz or negedge nCR) begin
        if (!nCR) 
            state_led <= 2'b01;
        else  if(state==00)begin
		  state_led <= 2'b01;
            case(state_led)
                2'b01: state_led <= 2'b10;
                2'b10: state_led <= 2'b01;
            endcase
        end
		  else  if(state==01)begin
		  state_led <= 2'b10;
            case(state_led)
                2'b01: state_led <= 2'b10;
                2'b10: state_led <= 2'b01;
            endcase
        end
		   else  if(state==01)begin
		  state_led <= 2'b11;
            case(state_led)
                2'b11: state_led <= 2'b10;
                2'b10: state_led <= 2'b01;
            endcase
        end
    end
endmodule

module _2to1MUX(OUT,SEL,X,Y);
    input [7:0] X, Y;
    input SEL;
    output[7:0] OUT;
    assign OUT = SEL ? X : Y;
endmodule

module _2to1MUX16(OUT,SEL,X,Y);
    input [15:0] X, Y;
    input SEL;
    output[15:0] OUT;
    assign OUT = SEL ? X : Y;
endmodule

module edge_detect(input clk, input reset, input signal_in, output reg signal_edge);
    reg signal_last;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            signal_last <= 1'b0;
            signal_edge <= 1'b0;
        end else begin
            signal_edge <= signal_in & ~signal_last;
            signal_last <= signal_in;
        end
    end
endmodule