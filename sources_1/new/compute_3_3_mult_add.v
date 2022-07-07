`timescale 1ns / 1ps

`include  "./Para.v"
module compute_3_3_mult_add#(parameter
KERNEL_NUM      =       9)
(
input                        clk,
input  [`PICTURE_NUM*KERNEL_NUM*`WIDTH_DATA-1:0]   data_in,
input  [KERNEL_NUM*`WIDTH_DATA-1:0]                weight_in,
output [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]            data_out
 );    
wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0] data_out_mult [0:KERNEL_NUM - 1];
generate
genvar i;
for(i=0;i<KERNEL_NUM;i=i+1)begin
mult_simd mult (
  .clk(clk),  // input wire CLK
  .data_in(data_in[`PICTURE_NUM*`WIDTH_DATA*(i+1)-1:`PICTURE_NUM*`WIDTH_DATA*i]),// input wire [31 : 0] A
  .weight_in(weight_in[`WIDTH_DATA*(i+1)-1:`WIDTH_DATA*i]),      // input wire [7 : 0] B
  .data_out(data_out_mult[i])      // output wire [63 : 0] P      
);    
end
endgenerate

 reg  [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]    data_out_mult_delay_0         [0:7];
 reg  [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]    data_out_mult_delay_1         [0:7];
 wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]    data_out_after_first_add      [0:7];
generate
genvar j;
    for(j=1;j<8;j=j+1)begin
    always@(posedge clk)begin
        data_out_mult_delay_0[j]    <=  data_out_mult  [j+1];
        data_out_mult_delay_1[j]    <=  data_out_mult_delay_0[j];
       end
    end
endgenerate

 generate
 genvar k;
 for(k=1;k<8;k=k+1)begin
 assign data_out_after_first_add[k] = data_out_mult_delay_1[k];
 end
 endgenerate

add_simd add_0 (
  .data_one_in(data_out_mult[0]),      // input wire [63 : 0] A
  .data_two_in(data_out_mult[1]),      // input wire [63 : 0] B
  .clk(clk),  // input wire CLK
  .data_out(data_out_after_first_add[0])      // output wire [15 : 0] S
);

wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]    data_out_after_second_add  [0:3];
generate
genvar x;
    for(x=0;x<4;x=x+1)begin
add_simd add_1 (
         .data_one_in(data_out_after_first_add[2*x]),     
         .data_two_in(data_out_after_first_add[2*x+1]),    
         .clk(clk),  // input wire CLK
         .data_out(data_out_after_second_add[x])      
);
    end        
 endgenerate

wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0]  data_out_after_third_add  [0:1];
generate
genvar y;
    for(y=0;y<2;y=y+1)begin
       add_simd  add_2 (
            .data_one_in(data_out_after_second_add[2*y]),      
            .data_two_in(data_out_after_second_add[2*y+1]),      
            .clk(clk),  // input wire CLK
            .data_out(data_out_after_third_add[y])     
    );
    end        
 endgenerate


       add_simd  add_3 (
            .data_one_in(data_out_after_third_add[0]),      
            .data_two_in(data_out_after_third_add[1]),     
            .clk(clk),  // input wire CLK
            .data_out(data_out)     
    );
    
endmodule

