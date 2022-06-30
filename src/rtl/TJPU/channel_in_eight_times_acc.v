`timescale 1ns / 1ps

`include"../Para.v"
module channel_in_eight_times_acc  #(parameter
COMPUTE_CHANNEL_IN_NUM       =      8 
) (
    input  clk,
    input  [`PICTURE_NUM * COMPUTE_CHANNEL_IN_NUM* `WIDTH_DATA_OUT* 2 -1 : 0] data_in,
    output [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]                       data_out 
    );
wire [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out_0; 
//8------------->4
wire [4 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_0 ;
generate
genvar i;
for(i=0;i<4;i=i+1)begin
 add_simd add_0 (
  .data_one_in(data_in[(2*i+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*i*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(data_in[(2*i+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*i+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(add_data_out_0[(i+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:i*`PICTURE_NUM*`WIDTH_DATA_OUT*2])      
);
end
endgenerate
//--------------------------------4->2-----------------
wire [2 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_1 ;
generate
genvar k;
for(k=0;k<2;k=k+1)begin
 add_simd add_0 (
  .data_one_in(add_data_out_0[(2*k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*k*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(add_data_out_0[(2*k+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
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

reg  [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]    data_out_reg [0:3];
always@(posedge clk)
  data_out_reg[0] <= data_out_0;
generate
genvar m;
for(m=0;m<3;m=m+1)begin
always@(posedge clk)
  data_out_reg[m+1] <= data_out_reg[m];
  end
endgenerate
assign data_out=data_out_reg[3];

endmodule