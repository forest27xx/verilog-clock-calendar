/*
file name: top_cpld.v

*/

module top_cpld(
input clk,			//50Hz
input rst_n,		
output [15:0] H_
);

//寄存器
reg[31:0] timer;
reg[15:0] led_H;

assign H_ = led_H;

always @(posedge clk or negedge rst_n)//时钟上升沿 复位下降沿
	if(~rst_n)
		timer <= 0;//复位 计数器清零
	else if(timer == 32'd00_140_000)
		timer <= 0;//计数器清零
	else
		timer <= timer + 1'b1;//计数器+1


always @(posedge clk or negedge rst_n)
	if(~rst_n)
		led_H <= 16'b1111_1111_0000_1111;
	else if(timer == 32'd00_020_000)
		led_H <= 16'b1111_1111_1110_1111;//竖
	else if(timer == 32'd00_040_000)
		led_H <= 16'b0000_0100_1000_0001;//横1
	else if(timer == 32'd00_070_000)
		led_H <= 16'b0010_0000_0000_0001;//横2
	else if(timer == 32'd00_100_000)
		led_H <= 16'b0000_0010_1111_1011;
	else if(timer == 32'd00_120_000)
		led_H <= 16'b0000_1000_1111_1110;
	else
		led_H <= led_H;
endmodule


