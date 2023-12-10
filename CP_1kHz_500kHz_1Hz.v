module CP_1kHz_500kHz_1Hz_2Hz_4Hz(CLK_50, nRST, _1kHz, _500Hz,_1Hz,_2Hz,_4Hz); 
   input CLK_50, nRST;                         
   output _4Hz,_2Hz,_1Hz,_500Hz,_1kHz;   
         
   Divider50MHz U0(.CLK_50M(CLK_50),                           
 	.nCLR(nRST),                
	.CLK_1HzOut(_1kHz));        
   defparam        U0.N=15,                                    
	          U0.CLK_Freq=50000000,                       
 	          U0.OUT_Freq=1000;   
        
    Divider50MHz U1(.CLK_50M(CLK_50),                           
	.nCLR(nRST),               
	 .CLK_1HzOut(_500Hz));
     defparam        U1.N=16,                
	            U1.CLK_Freq =50000000,                
	            U1.OUT_Freq =500;
    Divider50MHz U3(.CLK_50M(CLK_50),                           
	.nCLR(nRST),               
	 .CLK_1HzOut(_2Hz));
     defparam        U2.N=25,                
	            U2.CLK_Freq =50000000,                
	            U2.OUT_Freq =2;
	 Divider50MHz U4(.CLK_50M(CLK_50),                           
	.nCLR(nRST),               
	 .CLK_1HzOut(_4Hz));
     defparam        U2.N=25,                
	            U2.CLK_Freq =50000000,                
	            U2.OUT_Freq =4;
    Divider50MHz U2(.CLK_50M(CLK_50),                           
	.nCLR(nRST),               
	 .CLK_1HzOut(_1Hz));
     defparam        U2.N=30,                
	            U2.CLK_Freq =50000000,                
	            U2.OUT_Freq =1;
endmodule

module Divider50MHz #(parameter CLK_Freq=50000000,parameter OUT_Freq=1,parameter N=25)
       (input CLK_50M,nCLR,output reg CLK_1HzOut);
		 reg[N-1:0] Count_DIV;
		 always @(posedge CLK_50M,negedge nCLR)
		 begin
		    if(!nCLR) begin CLK_1HzOut<=0;Count_DIV<=0;end
			 else begin
			     if(Count_DIV<(CLK_Freq/(2*OUT_Freq)-1))
				    Count_DIV=Count_DIV+1'b1;
				  else begin
				      Count_DIV<=0;
						CLK_1HzOut<=~CLK_1HzOut;
				  end
			 end
		 end
endmodule