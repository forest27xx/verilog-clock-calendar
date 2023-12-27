module Top_Clock (pulse_day,Hour, Minute, Second, _1Hz, nCR, AdjMinKey, AdjHrKey);
    input  _1Hz, nCR, AdjHrKey, AdjMinKey; //定义输入端口变量
    output [7:0] Hour, Minute, Second;  //定义输出端口变量
	 output pulse_day;
    wire [7:0] Hour, Minute, Second;    //说明输出变量类型
    supply1 Vdd;         //定义Vdd为高电平
    wire MinCP, HrCP;    //分钟、小时计数器时钟信号（中间变量）
     Counter60 UT1(Second, nCR, Vdd, _1Hz);           //秒计数器     
     Counter60 UT2 (Minute, nCR, Vdd, ~MinCP);    //分计数器
     Counter24 UT3(Hour[7:4], Hour[3:0], nCR, Vdd, ~HrCP); //小时
	 //Modulo_counter #(.MOD(60)) UT1(.CP(_1Hz), .RSTn(nCR), .En(Vdd), .Qbcd(Second));
	 //Modulo_counter #(.MOD(60)) UT2(.CP(~MinCP), .RSTn(nCR), .En(Vdd), .Qbcd(Minute));
	 //Modulo_counter #(.MOD(24)) UT3(.CP(~HrCP), .RSTn(nCR), .En(Vdd), .Qbcd(Hour));
    assign MinCP = AdjMinKey ? _1Hz : (Second==8'h59); //时间校正
    assign HrCP = AdjHrKey ? _1Hz: ({Minute, Second }==16'h5959); 
	 //产生天脉冲
	 assign pulse_day =({Hour,Minute, Second }==24'h235959)?1'b1:1'b0; 
endmodule