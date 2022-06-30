`timescale 1ns / 1ps

`include"../Para.v"
module channel_in_four_times_acc  #(parameter
COMPUTE_CHANNEL_IN_NUM       =       4
) (
    input  clk,
    input  [`PICTURE_NUM *COMPUTE_CHANNEL_IN_NUM* `WIDTH_DATA_OUT* 2 -1 : 0] data_in,
    output [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out 
    );
    
wire [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out_0; 
//--------------------------------4->2-----------------
wire [2 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_1 ;
generate
genvar k;
for(k=0;k<2;k=k+1)begin
 add_simd add_0 (
  .data_one_in(data_in[(2*k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*k*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(data_in[(2*k+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(add_data_out_1[(k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:k*`PICTURE_NUM*`WIDTH_DATA_OUT*2])      
);
end
endgenerate
//2----------->1
 add_simd add_0 (
  .data_one_in(add_data_out_1[`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]),      
  .data_two_in(add_data_out_1[2*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(data_out_0)      
);
reg  [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]    data_out_reg [0:1];
always@(posedge clk)
  data_out_reg[0] <= data_out_0;

always@(posedge clk)
  data_out_reg[1] <= data_out_reg[0];

assign data_out=data_out_reg[1];
endmodule
