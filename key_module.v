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

module KeyValue(
	CLK,
	nRST,
	KEY_ROW,
	KEY_COL,
	KEY_Value,
	Value_en
);
	input CLK;
	input nRST;
	input [3:0]KEY_COL;				//列
	output reg Value_en;
	output reg [3:0]KEY_ROW;		//行
	output reg [3:0]KEY_Value;		//矩阵键盘按下的值
	
	wire [3:0]key_flag;				//按键标志位
	wire [3:0]key_state;
	
	reg [4:0]state;
	reg row_flag;						//标识已定位到行
	reg [1:0]rowIndex;				//行索引
	reg [1:0]colIndex;				//列索引
	
	localparam
		NO_KEY		=	5'b00001,
		ROW_ONE		=	5'b00010,
		ROW_TWO		=	5'b00100,
		ROW_THREE	=	5'b01000,
		ROW_FOUR	=	5'b10000;
		
	KeyPress u0(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[0]),
		.KEY_FLAG(key_flag[0]),
		.KEY_STATE(key_state[0])
	);
	
	KeyPress u1(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[1]),
		.KEY_FLAG(key_flag[1]),
		.KEY_STATE(key_state[1])
	);
	
	KeyPress u2(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[2]),
		.KEY_FLAG(key_flag[2]),
		.KEY_STATE(key_state[2])
	);
	
	KeyPress u3(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[3]),
		.KEY_FLAG(key_flag[3]),
		.KEY_STATE(key_state[3])
	);

	//==========通过状态机判断行===========//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			begin
				state <= NO_KEY;
				row_flag <= 1'b0;
				KEY_ROW <= 4'b0000;
			end
		else
			case(state)
				NO_KEY: begin
					row_flag <= 1'b0;
					KEY_ROW <= 4'b0000;	
					if(key_flag != 4'b0000) begin
						state <= ROW_ONE;
						KEY_ROW <= 4'b1110;
					end
					else
						state <= NO_KEY;
				end
				
				ROW_ONE: begin
					//这里做判断只能用KEY_COL而不能用key_state
					//因为由于消抖模块使得key_state很稳定
					//不会因为KEY_ROW的短期变化而变化
					//而KEY_COL则会伴随KEY_ROW实时变化
					if(KEY_COL != 4'b1111) begin
						state <= NO_KEY;
						rowIndex <= 4'd0;
						row_flag <= 1'b1;
					end
					else begin
						state <= ROW_TWO;
						KEY_ROW <= 4'b1101;
					end						
				end
				
				ROW_TWO: begin
					if(KEY_COL != 4'b1111) begin
						state <= NO_KEY;
						rowIndex <= 4'd1;
						row_flag <= 1'b1;
					end
					else begin
						state <= ROW_THREE;
						KEY_ROW <= 4'b1011;
					end						
				end
				
				ROW_THREE: begin
					if(KEY_COL != 4'b1111) begin
						state <= NO_KEY;
						rowIndex <= 4'd2;
						row_flag <= 1'b1;
					end
					else begin
						state <= ROW_FOUR;
						KEY_ROW <= 4'b0111;
					end						
				end
				
				ROW_FOUR: begin
					if(KEY_COL != 4'b1111) begin
						rowIndex <= 4'd3;
						row_flag <= 1'b1;
					end
					state <= NO_KEY;
				end
			endcase
	
	//===========判断按键所在列=============//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			colIndex <= 2'd0;
		else if(key_state != 4'b1111)
			case(key_state)
				4'b1110: colIndex <= 2'd0;
				4'b1101: colIndex <= 2'd1;
				4'b1011: colIndex <= 2'd2;
				4'b0111: colIndex <= 2'd3;
			endcase
	
	//===========通过行列计算键值==========//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			Value_en <= 1'b0;
		else if(row_flag)
			begin
				Value_en <= 1'b1;
				KEY_Value <= 4*rowIndex + colIndex;
			end
		else
			Value_en <= 1'b0;
			
endmodule

