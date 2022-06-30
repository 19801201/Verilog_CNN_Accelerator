`timescale 1ns / 1ps
`include  "../Para.v"



module Concat_Zero#(parameter
	RE_CHANNEL_IN_NUM = 16
)(
	input 		clk,
	input   [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0] concat_data_in,
	input   [31:0 ] zero_data_in,
	output  [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0] data_out
    );
    
generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    	for(j =0;j<RE_CHANNEL_IN_NUM;j=j+1)begin
			add_32_u32_32 add_32_u32_32 (
			  .A(concat_data_in[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32]),      // input wire [31 : 0] A
			  .B(zero_data_in),      // input wire [31 : 0] B
			  .CLK(clk),  // input wire CLK
			  .S(data_out[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32])          // output wire [31 : 0] S
			  );    
         end
     end
endgenerate

   
endmodule
