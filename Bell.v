module Bell (ALARM_Clock, Set_Hr, Set_Min, Hour, Minute, Second, SetHrkey, SetMinkey, _4Hz,_2Hz, _500Hz, _1Hz, CtrlBell);
    output wire ALARM_Clock;   //定义输出端口变量
    output wire [7:0] Set_Hr, Set_Min; //设定的闹铃时间(BCD码)
    input  _2Hz,_4Hz, _500Hz, _1Hz; //定义输入端口变量
    input SetHrkey, SetMinkey; //设定闹钟小时、分钟的输入键
    input CtrlBell; //控制闹钟的声音是否输出的按键
    input [7:0] Hour, Minute, Second;  
// 定义内部节点信号
    supply1 Vdd;         //定义Vdd为高电平
    wire HrH_EQU, HrL_EQU, MinH_EQU, MinL_EQU; //比较器的内部信号
    wire Time_EQU;  //相等比较电路的输出
//======== 闹时设定模块(Set Hour & Minute counter) =======
//60进制分计数器：用于闹时设定分钟
    Counter60 SU1(Set_Min, Vdd, SetMinkey, _1Hz);   
//24进制小时计数器：用于闹时设定小时
    Counter24 SU2(Set_Hr[7:4], Set_Hr[3:0], Vdd, SetHrkey, _1Hz);
//比较闹钟的设定时间和计时器的当前时间是否相等
    _4bitcomparator SU4(HrH_EQU, Set_Hr[7:4], Hour[7:4]);
    _4bitcomparator SU5(HrL_EQU, Set_Hr[3:0], Hour[3:0]);
    _4bitcomparator SU6(MinH_EQU, Set_Min[7:4], Minute[7:4]);
    _4bitcomparator SU7(MinL_EQU, Set_Min[3:0], Minute[3:0]);
    assign Time_EQU=(HrH_EQU && HrL_EQU && MinH_EQU && MinL_EQU);
    assign ALARM_Clock= CtrlBell ? (Time_EQU &&(((Second[0]==1'b1)&&_2Hz)||((Second[0]==1'b0)&&_500Hz))):1'b0;
endmodule
//***********  _4bitcomparator.v ***** *******
module _4bitcomparator (EQU, A, B); //4-bit comparator
    input [3:0] A, B;
    output  EQU;
    assign EQU = (A==B);
endmodule