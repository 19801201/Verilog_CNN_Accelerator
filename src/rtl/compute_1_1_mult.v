`timescale 1ns / 1ps

`include"../Para.v"
module compute_1_1_mult#(parameter
KERNEL_NUM      =       1
)
(
input                                              clk,
input  [`PICTURE_NUM*KERNEL_NUM*`WIDTH_DATA-1:0]   data_in,
input  [KERNEL_NUM*`WIDTH_DATA-1:0]                weight_in,
output [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]            data_out
    );
wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]            data_out_0;
mult_simd  compute_1_1_mult (
  .clk(clk),  
  .data_in(data_in),      
  .weight_in(weight_in),     
  .data_out(data_out_0)      
);
reg  [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]   data_out_reg [0:7];
always@(posedge clk)
  data_out_reg[0] <= data_out_0;
generate
genvar i;
for(i=0;i<7;i=i+1)begin
always@(posedge clk)
  data_out_reg[i+1] <= data_out_reg[i];
  end
endgenerate
assign data_out=data_out_reg[7];
endmodule
