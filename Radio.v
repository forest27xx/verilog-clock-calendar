module Radio (ALARM_Radio , Minute, Second, _2Hz, _500Hz);
  	input  _2Hz, _500Hz;   //定义输入端口变量
	input [7:0] Minute, Second;  
	output reg ALARM_Radio;    //定义输出端口变量
always @(Minute or Second)   //generat alarm signal
      if (Minute==8'h59)
	case (Second)
	    8'h55,
	   
	    8'h59:  ALARM_Radio = 1'b1;
	    default: ALARM_Radio = 1'b0;
	endcase
      else ALARM_Radio =1'b0;
endmodule