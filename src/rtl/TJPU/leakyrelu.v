`timescale 1ns / 1ps
`include "../Para.v"

module    leakyrelu  #(parameter
	CHANNEL_OUT_NUM = 8
)(
	input	clk,
	input	[`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0]	leaky_data_in,
	input	[7:0]											zero_data_in,
	output	[`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0]	leaky_data_out
    );

generate
genvar i,j;
	for (i = 0;i < `PICTURE_NUM; i = i + 1) begin 
		for (j = 0;j < CHANNEL_OUT_NUM;j = j + 1) begin
			subz3_leakyrelu_addz3  leakyrelu_logic(
				.clk						(clk),
				.data_in      		        (leaky_data_in[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA-1:(j*`PICTURE_NUM+i)*`WIDTH_DATA]),
				.zero_data_in 		        (zero_data_in),
				.data_out	                (leaky_data_out[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA-1:(j*`PICTURE_NUM+i)*`WIDTH_DATA])
			);
			
		end
	end
endgenerate    
    
endmodule
