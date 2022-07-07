`timescale 1ns / 1ps
`include  "./Para.v"


module Concat_Scale#(parameter
    RE_CHANNEL_IN_NUM           = 16
)(
    input  clk,
    input  [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]   Concat_Data_In,
    
    input [31 : 0]           Scale_Data_In,

    output  [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]   Scale_Data_Out

    );

wire		[`PICTURE_NUM*RE_CHANNEL_IN_NUM*33-1:0]   Scale_Data_Temp;    
//    resume  3 clk
generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    	for(j =0;j<RE_CHANNEL_IN_NUM;j=j+1)begin
    		concat_mult_32_u32 concat_mult_32_u32 (
    		  .CLK(clk),  // input wire CLK
    		  .A(Concat_Data_In[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32]),      // input wire [31 : 0] A
    		  .B(Scale_Data_In[31:0]),      // input wire [31 : 0] B
    		  .P(Scale_Data_Temp[(j*`PICTURE_NUM+i+1)*33-1:(j*`PICTURE_NUM+i)*33])      // output wire [32 : 0] P
    		);
    		
    	end
   	end
endgenerate

//////   resume  1 clk
generate
genvar x,y;
	for (x = 0;x < `PICTURE_NUM;x = x + 1) begin 
		for (y = 0;y < RE_CHANNEL_IN_NUM;y = y + 1) begin 
			Concat_Scale_Judge  concat_scale_judge(
				.clk(clk),
    			.Scale_Data_Temp(Scale_Data_Temp[(y*`PICTURE_NUM+x+1)*33-1:(y*`PICTURE_NUM+x)*33]),
				.Scale_Data_Out(Scale_Data_Out[(y*`PICTURE_NUM+x+1)*32-1:(y*`PICTURE_NUM+x)*32])
    			);
		end
	end
endgenerate
   	
	   	

endmodule