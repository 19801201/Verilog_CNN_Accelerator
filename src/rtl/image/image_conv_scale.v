`timescale 1ns / 1ps
`include "../Para.v"


module image_conv_scale #(parameter
	WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
	COMPUTE_CHANNEL_OUT_NUM   =	 8,
	WIDTH_FEATURE_SIZE        =  10
)(
    input  clk,
    input  rst,
    //自带fifo所需
    input  [WIDTH_DATA_ADD_TEMP*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0]      S_Data,//1024 8通道四张图32位
    input  [`IMAGE_BIAS_WIDTH_DATA-1:0]      scale_data_in,
    output [WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0]      scale_data_out

    );

//--------------------乘法------------------

generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    	for(j =0;j<COMPUTE_CHANNEL_OUT_NUM;j=j+1)begin
    		mult_48_32 mult_48_32 (
  				.CLK(clk),  // input wire CLK
 				.A(S_Data[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD_TEMP-1:(j*`PICTURE_NUM+i)*WIDTH_DATA_ADD_TEMP]),      // input wire [31 : 0] A
  				.B(scale_data_in[(j+1)*WIDTH_DATA_ADD-1:j*WIDTH_DATA_ADD]),      // input wire [31 : 0] B
 		 		.P(scale_data_out[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:(j*`PICTURE_NUM+i)*WIDTH_DATA_ADD])      // output wire [31 : 0] P
			);
    	end
   end
endgenerate

//generate
//genvar i,j;
//    for(i =0;i<`PICTURE_NUM;i=i+1)begin
//    	for(j =0;j<8;j=j+1)begin
//    		mult_32_32 mult_32_32 (
//  				.CLK(clk),  // input wire CLK
// 				.A(S_Data[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32]),      // input wire [31 : 0] A
//  				.B(scale_data_in[(j+1)*32-1:j*32]),      // input wire [31 : 0] B
// 		 		.P(scale_data_out[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32])      // output wire [31 : 0] P
//			);
//    	end
//   end
//endgenerate

endmodule
