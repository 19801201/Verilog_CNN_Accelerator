`timescale 1ns / 1ps
`include "../Para.v"


module image_conv_bias#(parameter
	WIDTH_DATA_ADD          = 32,
    WIDTH_DATA_ADD_TEMP     = 48,
	COMPUTE_CHANNEL_OUT_NUM	= 8,
	WIDTH_FEATURE_SIZE      = 10
)(
	input	clk,
	input	rst,
	input   [7:0] Channel_Out_Num_REG,
	input   [13:0]  S_Count_Fifo,
	input	[WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0] S_Data,
	input	S_Valid,
	input	rd_en_fifo,
	input	[`IMAGE_BIAS_WIDTH_DATA-1:0]	bias_data_in,
	output	S_Ready,
	output	fifo_valid,
	output	[WIDTH_DATA_ADD_TEMP*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0] M_Data
    );
    
wire	[WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0] data_out_fifo;
wire    [WIDTH_FEATURE_SIZE:0]  Channel_Times;

assign	Channel_Times = Channel_Out_Num_REG >>3;

image_bias_fifo #(
	.WIDTH(WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM),
	.ADDR_BITS(12)
)
	image_bias_fifo(    
     .clk(clk),
     .rst(rst),
     .din(S_Data),
     .wr_en(S_Valid),
 
     .rd_en(rd_en_fifo),
     .dout(data_out_fifo),
   
     .M_count(S_Count_Fifo),  //back
     .M_Valid(fifo_valid),
     .S_count(S_Count_Fifo),   //front
     .S_Ready(S_Ready)
    ); 
 
reg	[WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0] data_out_fifo_delay0;
reg	[WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0] data_out_fifo_delay1;


always @ (posedge clk) begin 
	if (rst)
		data_out_fifo_delay0 <= {WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM{1'b0}};
	else 
		data_out_fifo_delay0 <= data_out_fifo;
end 

always @ (posedge clk) begin 
	data_out_fifo_delay1 <= data_out_fifo_delay0;
end 

generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    	for(j =0;j<COMPUTE_CHANNEL_OUT_NUM;j=j+1)begin
			image_bias_add image_bias_add (
  				.clk(clk),
  				.norm_data_out(data_out_fifo_delay1[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:(j*`PICTURE_NUM+i)*WIDTH_DATA_ADD]),
  				.bias_data_in(bias_data_in[(j+1)*WIDTH_DATA_ADD-1:j*WIDTH_DATA_ADD]), 
  				.data_out(M_Data[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD_TEMP-1:(j*`PICTURE_NUM+i)*WIDTH_DATA_ADD_TEMP])
			);
    	end
   end
endgenerate  

//generate
//genvar i,j;
//    for(i =0;i<`PICTURE_NUM;i=i+1)begin
//    	for(j =0;j<8;j=j+1)begin
//			add_32_32 add_32_32 (
//  				.A(data_out_fifo_delay1[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32]),      // input wire [31 : 0] A
//  				.B(bias_data_in[(j+1)*32-1:j*32]),      // input wire [31 : 0] B
//  				.CLK(clk),  // input wire CLK
//  				.S(M_Data[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32])      // output wire [31 : 0] S
  				
//			);
//    	end
//   end
//endgenerate   
    
    
endmodule