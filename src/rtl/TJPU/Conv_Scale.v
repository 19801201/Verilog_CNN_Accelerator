`timescale 1ns / 1ps

`include"../Para.v"
module Conv_Scale#(parameter
    CHANNEL_OUT_NUM           =  8,
    WIDTH_DATA_ADD            =  32
)(
    input  clk,
    input  rst,
    
    input  [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]   S_Data,
    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0]           Scale_Data_In,
    output [`PICTURE_NUM*CHANNEL_OUT_NUM*WIDTH_DATA_ADD-1:0]   Scale_Data_Out
);

generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    for(j =0;j<CHANNEL_OUT_NUM;j=j+1)begin
    mult_32_32 mult_32_32 (
  .CLK(clk),  // input wire CLK
  .A(S_Data[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:
        (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD]),      // input wire [31 : 0] A
  .B(Scale_Data_In[(j+1)*WIDTH_DATA_ADD-1:j*WIDTH_DATA_ADD]),      // input wire [31 : 0] B
  .P(Scale_Data_Out[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:
        (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD])      // output wire [31 : 0] P
);
    end
   end
endgenerate

endmodule
