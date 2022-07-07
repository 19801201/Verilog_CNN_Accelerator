`timescale 1ns / 1ps

`include"./Para.v"
module channel_in_two_times_acc#(parameter
COMPUTE_CHANNEL_IN_NUM       =       2
) (
    input  clk,
    input  [`PICTURE_NUM * COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA_OUT* 2 -1 : 0] data_in,
    output [`PICTURE_NUM * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out 
    );
wire [`PICTURE_NUM * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out_0; 
 add_simd add_0 (
  .data_one_in(data_in[2*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(data_in[`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]),      
  .clk(clk),  
  .data_out(data_out_0)      
);
reg  [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]    data_out_reg [0:3];
always@(posedge clk)
  data_out_reg[0] <= data_out_0;
generate
genvar i;
for(i=0;i<4;i=i+1)begin
always@(posedge clk)
  data_out_reg[i+1] <= data_out_reg[i];
  end
endgenerate
assign data_out=data_out_reg[3];
endmodule
