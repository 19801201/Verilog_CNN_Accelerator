`timescale 1ns / 1ps

`include"./Para.v"
module channel_in_thirty_two_times_acc  #(parameter
COMPUTE_CHANNEL_IN_NUM       =      32 
) (
    input  clk,
    input  [`PICTURE_NUM * COMPUTE_CHANNEL_IN_NUM* `WIDTH_DATA_OUT* 2 -1 : 0] data_in,
    output [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]                       data_out 
    );
wire [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out_0; 
//32------------->16
wire [16 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_0 ;
generate
genvar i;
for(i=0;i<16;i=i+1)begin
 add_simd add_0 (
  .data_one_in(data_in[(2*i+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*i*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(data_in[(2*i+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*i+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(add_data_out_0[(i+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:i*`PICTURE_NUM*`WIDTH_DATA_OUT*2])      
);
end
endgenerate
//16------------->8
wire [8 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_1 ;
generate
genvar n;
for(n=0;n<8;n=n+1)begin
 add_simd add_0 (
  .data_one_in(add_data_out_0[(2*n+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*n*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(add_data_out_0[(2*n+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*n+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(add_data_out_1[(n+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:n*`PICTURE_NUM*`WIDTH_DATA_OUT*2])      
);
end
endgenerate
//8------------->4
wire [4 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_2 ;
generate
genvar j;
for(j=0;j<4;j=j+1)begin
 add_simd add_0 (
  .data_one_in(add_data_out_1[(2*j+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*j*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(add_data_out_1[(2*j+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*j+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(add_data_out_2[(j+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:j*`PICTURE_NUM*`WIDTH_DATA_OUT*2])      
);
end
endgenerate
//--------------------------------4->2-----------------
wire [2 *`PICTURE_NUM * `WIDTH_DATA_OUT* 2 -1 : 0] add_data_out_3 ;
generate
genvar k;
for(k=0;k<2;k=k+1)begin
 add_simd add_0 (
  .data_one_in(add_data_out_2[(2*k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:2*k*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .data_two_in(add_data_out_2[(2*k+1+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:(2*k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(add_data_out_3[(k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:k*`PICTURE_NUM*`WIDTH_DATA_OUT*2])      
);
end
endgenerate
//2----------->1
 add_simd add_0 (
  .data_one_in(add_data_out_3[`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]),      
  .data_two_in(add_data_out_3[2*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:`PICTURE_NUM*`WIDTH_DATA_OUT*2]),      
  .clk(clk),  
  .data_out(data_out)      
);


endmodule