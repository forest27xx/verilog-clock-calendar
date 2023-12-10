//**************** counter10.v ( BCD: 0~9 ) **************
module Counter10(Q, nCR, EN, CP);
    input CP, nCR, EN;
    output [3:0]	Q;
    reg    [3:0] 	Q;
    always @(posedge CP or negedge nCR)
    begin
      if(~nCR)    Q <= 4'b0000;         // nCR＝0，计数器被异步清零
      else if(~EN)  Q <= Q;               //EN=0,暂停计数
      else if(Q == 4'b1001)  Q <= 4'b0000; 
      else 	Q <= Q + 1'b1;       //计数器增1计数
    end
endmodule 
//***************** counter6.v (BCD: 0~5)******************
module Counter6(Q, nCR, EN, CP);
    input CP, nCR, EN;
    output [3:0] Q;
    reg    [3:0] Q;
    always @(posedge CP or negedge nCR)
    begin
      if(~nCR)  Q <= 4'b0000;   // nCR＝0，计数器被异步清零
      else if(~EN)  Q <= Q;     //EN=0,暂停计数
      else if(Q == 4'b0101) Q <= 4'b0000;
      else 	Q <= Q + 1'b1;      //计数器增1计数
    end
endmodule 
//************* counter60.v (BCD: 00~59)***********
//60进制计数器：调用10进制和6进制底层模块构成
module Counter60(Cnt, nCR, EN, CP);
    input CP, nCR, EN;
    output wire [7:0] Cnt;       //模60计数器输出8421 BCD码
    wire  ENP;                 //计数器十位的使能信号（中间变量）

   Counter10 UC0 (Cnt[3:0], nCR, EN, CP);  //计数器的个位
   Counter6  UC1 (Cnt[7:4], nCR, ENP, CP); //计数器的十位
   assign  ENP = (Cnt[3:0]==4'h9) &EN;  
   //产生计数器十位的使能信号
endmodule 