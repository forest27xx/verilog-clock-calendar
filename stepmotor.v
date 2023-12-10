module stepmotor(clk,rst,StepDrive);
    input clk,rst;
	 output [3:0] StepDrive;
	 
	 StepMotorPorts U0 (StepDrive,clk,1'b1,1'b1,rst);

endmodule

module StepMotorPorts (StepDrive, clk, Dir, StepEnable, rst);
     parameter[31:0] StepLockOut = 32'd50000000;             //250HZ
     input clk; 
     input Dir; 
     input StepEnable; 
     input rst; 
   
     output reg [3:0] StepDrive;  
     reg[2:0] state; 
     reg[31:0] StepCounter = 32'b0; 
     reg InternalStepEnable; 
 
     always @(posedge clk or negedge rst)
     begin 
         if (!rst)    
         begin 
             StepDrive <= 4'b0;
             state  <= 3'b0;
             StepCounter <= 32'b0;
				 InternalStepEnable <= 1'b1 ;
         end
         else if (StepEnable == 1'b1) 
			begin
                StepCounter <= StepCounter + 31'b1 ;
             if (StepCounter >= StepLockOut)
				 begin
                 StepCounter <= 32'b0 ; 
                 InternalStepEnable <= 1'b1 ;
             end					  
                 if (InternalStepEnable == 1'b1)
                 begin
                     InternalStepEnable <= 1'b1 ; 
                     if (Dir == 1'b1) 
							begin
                         if(state < 3'b111)
                            state <= state + 3'b001 ; 
                         else
                            state <= 3'b000;
                         end
                     else if (Dir == 1'b0) 
							begin
                          if(state > 3'b000)
                             state <= state - 3'b001 ; 
                          else
                             state <= 3'b111;
                          end
                     case (state)
                         3'b000 :    StepDrive <= 4'b0001 ; 
                         3'b001 :    StepDrive <= 4'b0011 ; 
                         3'b010 :    StepDrive <= 4'b0010 ; 
                         3'b011 :    StepDrive <= 4'b0110 ; 
                         3'b100 :    StepDrive <= 4'b0100 ; 
                         3'b101 :    StepDrive <= 4'b1100 ; 
                         3'b110 :    StepDrive <= 4'b1000 ;
							    3'b111 :    StepDrive <= 4'b1001 ;	 
                     endcase 
                 end 
             end 
       end     
 endmodule
