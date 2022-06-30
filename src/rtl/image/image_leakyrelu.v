`timescale 1ns / 1ps
`include "../Para.v"



module image_leakyrelu#(parameter
	WIDTH_DATA_ADD            =  32,
	COMPUTE_CHANNEL_OUT_NUM	  =	 8
)(
	input	clk,
	input	[`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA-1:0]	leaky_data_in,
	input	[7:0]	zero_data_in,
	input   [31:0]  Temp_REG,
	output	[`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA-1:0]	leaky_data_out
    );

    
generate
genvar i,j;
	for (i = 0;i < `PICTURE_NUM; i = i + 1) begin 
		for (j = 0;j < COMPUTE_CHANNEL_OUT_NUM;j = j + 1) begin
			subz3_leakyrelu_addz3  leakyrelu_logic(
				.clk						(clk),
				.data_in      		        (leaky_data_in[(j*`PICTURE_NUM+i+1)*COMPUTE_CHANNEL_OUT_NUM-1:(j*`PICTURE_NUM+i)*COMPUTE_CHANNEL_OUT_NUM]),
			    .Temp_REG                   (Temp_REG),
				.zero_data_in 		        (zero_data_in),
				.data_out	                (leaky_data_out[(j*`PICTURE_NUM+i+1)*COMPUTE_CHANNEL_OUT_NUM-1:(j*`PICTURE_NUM+i)*COMPUTE_CHANNEL_OUT_NUM])
			);
			
		end
	end
endgenerate    
    
    
endmodule
