`timescale 1ns / 1ps

`include"./Para.v"
module channel_in_one_times_acc#(parameter
COMPUTE_CHANNEL_IN_NUM       =       1
) (
    input  clk,
    input  [`PICTURE_NUM *COMPUTE_CHANNEL_IN_NUM* `WIDTH_DATA_OUT* 2 -1 : 0] data_in,
    output [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out 
    );
 reg  [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]    data_out_reg [0:5];
always@(posedge clk)
   data_out_reg[0] <= data_in;
generate
genvar i;
for(i=0;i<6;i=i+1)begin
always@(posedge clk)
  data_out_reg[i+1] <= data_out_reg[i];
  end
endgenerate
assign data_out=data_out_reg[5];
endmodule
