module eda_test01(state_led,page_key,sel,seg, ALARM, pulse_day,CLK_50, AdjMinKey, AdjHrKey, day_add,month_add,year_add,SetMinKey, SetHrKey, CtrlBell, Mode,nCR,StepDrive);
    input  CLK_50, nCR;    
    input  AdjMinKey, AdjHrKey,day_add,month_add,year_add;
    input  SetHrKey, SetMinKey; //设定闹钟小时、分钟的输入按键
    input CtrlBell; //控制闹钟的声音是否输出的按键
    input page_key,Mode;  //控制显示模式切换的按键。
    output ALARM,pulse_day;       //仿电台或闹钟的声音信号输出
	 output [7:0] sel;
	 output [7:0] seg;
	 output [1:0] state_led;//LED点阵
	 output [3:0] StepDrive;                //电机控制
    wire _4Hz,_2Hz,_1Hz,  _500Hz,_1kHzIN;         //分频器的输出信号  
    wire  ALARM_Radio;  //仿电台报时信号输出
    wire  ALARM_Clock;  //闹钟的信号输出 
	 	 //数字钟模块
     Complete_Clock MU0(state_led,page_key_1,sel,seg, ALARM,pulse_day, CLK_50, AdjMinKey, AdjHrKey_1, day_add,month_add,year_add_1,SetMinKey, SetHrKey, CtrlBell_1, Mode, nCR);
		 //调用分频模块
	  CP_1kHz_500kHz_1Hz_2Hz_4Hz U0 (CLK_50, nCR, _1kHzIN, _500Hz,_1Hz,_2Hz,_4Hz); 
		//步进电机模块
     stepmotor MU2(.clk(_1Hz),.rst(nCR),.StepDrive(StepDrive));
	  //按键消抖模块
	  key_module MU3(CLK_50,nCR,CtrlBell,page_key,year_add,AdjHrKey,CtrlBell_1,page_key_1,year_add_1,AdjHrKey_1);
	  //LED16*16
	 top_cpld( clk, rst_n,	[15:0] H_);
endmodule

