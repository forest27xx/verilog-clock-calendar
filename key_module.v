/*=====================================================
*****************************************************

*****************************************************
功能说明：
	    对输入按键消抖进行统一处理
*****************************************************
 
*****************************************************
端口信号说明：
in  clk               :50M时钟输入
in  rst_n             :复位信号输入
  
in  mode_key          :模式按键输入
in  move_key          :移位按键输入
in  add_key           :数值加键输入
in  switch_key        :显示选择按键输入
 
out filter_mode_key   :消抖模式按键输出
out filter_move_key   :消抖移位按键输出
out filter_add_key    :消抖数值加键输入
out filter_switch_key :消抖显示选择按键输出
*****************************************************
========================================================*/
module key_module
#(
	parameter WIPE_TIME = 1000_000
	//消抖时间参数定义，系统时钟50M,对应的20ms参数
)
(
	input  clk                ,               
	input  rst_n              ,             
	
	input  mode_key           ,         
	input  move_key           ,         
	input  add_key            ,           
	input  switch_key         ,        
	
	output filter_mode_key    ,  
	output filter_move_key    ,  
	output filter_add_key     ,   
	output filter_switch_key 
);
 
//filter_mode_key
wipe_key_shake 
#(
	.WIPE_TIME  (WIPE_TIME       )  //20ms/50Mhz
)
key_low_1
(								 		 
	.clk        (clk             ),		
	.rst_n      (rst_n           ),  	
	.key_in     (mode_key        ),
	.key_out    (filter_mode_key )   
);
 
//filter_move_key
wipe_key_shake 
#(
	.WIPE_TIME  (WIPE_TIME       )  //20ms/50Mhz
)
key_low_2
(								 		 
	.clk        (clk             ),		
	.rst_n      (rst_n           ),  	
	.key_in     (move_key        ),
	.key_out    (filter_move_key )   
);
 
//filter_add_key
wipe_key_shake 
#(
	.WIPE_TIME  (WIPE_TIME       )  //20ms/50Mhz
)
key_low_3
(								 		 
	.clk        (clk             ),		
	.rst_n      (rst_n           ),  	
	.key_in     (add_key         ),
	.key_out    (filter_add_key  )   
);
 
//filter_mode_key
wipe_key_shake 
#(
	.WIPE_TIME  (WIPE_TIME        )  //20ms/50Mhz
)
key_low_4
(								 		 
	.clk        (clk              ),		
	.rst_n      (rst_n            ),  	
	.key_in     (switch_key       ),
	.key_out    (filter_switch_key)   
);
 
endmodule