`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/02 16:48:23
// Design Name: 
// Module Name: Conv_Bias
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include"../Para.v"
module Conv_Bias_11  #(parameter
    CHANNEL_OUT_NUM           =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
    WIDTH_CHANNEL_NUM_REG     =  10
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    //�Դ�fifo����
    input  [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]   S_Data,//1024 8ͨ������ͼ32λ
    input           S_Valid,
    output          S_Ready,//��дһ��
    output          fifo_ready,//�㹻һ��
    input           rd_en_fifo,
    
    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] bias_data_in,
    //�¸�fifo
    output [`PICTURE_NUM*CHANNEL_OUT_NUM*WIDTH_DATA_ADD_TEMP-1:0]   M_Data,
    //����
    input  [WIDTH_CHANNEL_NUM_REG-1'b1:0] Channel_Out_Num_REG,
    input  [WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,      //feature�Ĵ�С��Padding��ģ�?  
    input  [WIDTH_FEATURE_SIZE-1:0]  S_Count_Fifo
    );
wire [WIDTH_CHANNEL_NUM_REG-1'b1:0] Channel_Times;
//assign Channel_Times = Channel_Out_Num_REG/CHANNEL_OUT_NUM;
assign Channel_Times = Channel_Out_Num_REG>>3;
wire  [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0] data_fifo_out;
BIAS_FIFO_11   #(
            .WIDTH(`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM),
            .ADDR_BITS(WIDTH_FEATURE_SIZE)
            )
        fifo_feature      
    (    
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(S_Data),
     .wr_en(S_Valid),
 
     .rd_en(rd_en_fifo),
     .dout(data_fifo_out),
   
     .M_count({{1'b0},S_Count_Fifo}),  //back
     .M_Ready(fifo_ready),
     .S_count({{1'b0},S_Count_Fifo}),   //front
     .S_Ready(S_Ready)
    ); 
//--------------------bias�ӷ�------------------
generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    for(j =0;j<CHANNEL_OUT_NUM;j=j+1)begin
conv_bias_add conv_bias_add (
  .clk(clk),
  .norm_data_out(data_fifo_out[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:
  (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD]),  
  .bias_data_in(bias_data_in[(j+1)*WIDTH_DATA_ADD-1:j*WIDTH_DATA_ADD]),
  .data_out(M_Data[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD_TEMP-1:
        (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD_TEMP]) 
);
    end
   end
endgenerate
//generate
//genvar i,j;
//    for(i =0;i<`PICTURE_NUM;i=i+1)begin
//    for(j =0;j<CHANNEL_OUT_NUM;j=j+1)begin
//add_32_32 add_32_32 (
//  .A(data_fifo_out[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:
//  (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD]),      // input wire [31 : 0] A
//  .B(bias_data_in[(j+1)*WIDTH_DATA_ADD-1:j*WIDTH_DATA_ADD]),      // input wire [31 : 0] B
//  .CLK(clk),  // input wire CLK
//  .S(M_Data[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:
//        (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD])      // output wire [31 : 0] S
//);
//    end
//   end
//endgenerate

endmodule
