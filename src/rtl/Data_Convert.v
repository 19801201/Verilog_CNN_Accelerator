`timescale 1ns / 1ps


`include"Para.v"
module Data_Convert#(parameter
    KERNEL_NUM                =  9,//     
    CHANNEL_IN_NUM            =  16,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM         =  10
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start,
    input  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] S_Feature,
    input  S_Valid,
    output S_Ready,
    input  [WIDTH_FEATURE_SIZE-1 :0]Row_Num_In_REG,
    input  CONV_11_Parallel,
    output [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*KERNEL_NUM-1:0] M_Feature,
    output [KERNEL_NUM-1:0]M_Valid,
    input  [WIDTH_CHANNEL_NUM-1'b1  :0]Channel_In_Num_REG,  
    input  M_Ready
    );

wire [WIDTH_CHANNEL_NUM -1'b1:0] Channel_Times;
wire [WIDTH_FEATURE_SIZE-1'b1:0] S_Count_Fifo;

wire S_Ready_64,S_Ready_128;
wire [KERNEL_NUM-1:0] M_Valid_64,M_Valid_128;
wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*KERNEL_NUM-1:0] M_Feature_64,M_Feature_128;
wire empty_64,empty_128;

assign Channel_Times = Channel_In_Num_REG >> 4;

Data_Convert_FIFO  #(
        .WIDTH(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM),
        .WIDTH_OUT(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*KERNEL_NUM),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
Data_Convert_FIFO_64
(
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(S_Feature),
     .wr_en(S_Valid),
     .rd_en(M_Ready & !empty_64),
     .dout(M_Feature_64),
     .M_count(S_Count_Fifo),
     .M_Ready(),
     .S_count(S_Count_Fifo),
     .S_Ready(S_Ready_64),
     .empty(empty_64)
); 
assign M_Valid_64[0] = M_Ready & !empty_64;
assign M_Valid_64[1] = M_Ready & !empty_64;
assign M_Valid_64[2] = M_Ready & !empty_64;
assign M_Valid_64[3] = M_Ready & !empty_64;
assign M_Valid_64[4] = M_Ready & !empty_64;
assign M_Valid_64[5] = M_Ready & !empty_64;
assign M_Valid_64[6] = M_Ready & !empty_64;
assign M_Valid_64[7] = M_Ready & !empty_64;
assign M_Valid_64[8] = M_Ready & !empty_64;


Data_Convert_FIFO_128  #(
        .WIDTH(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM),
        .WIDTH_OUT(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*KERNEL_NUM),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
Data_Convert_FIFO_128
(
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(S_Feature),
     .wr_en(S_Valid),
     .rd_en(M_Ready & !empty_128),
     .dout(M_Feature_128),
     .M_count(S_Count_Fifo),
     .M_Ready(),
     .S_count(S_Count_Fifo),
     .S_Ready(S_Ready_128),
     .empty(empty_128)
); 

assign M_Valid_128[0] = M_Ready & !empty_128;
assign M_Valid_128[1] = M_Ready & !empty_128;
assign M_Valid_128[2] = M_Ready & !empty_128;
assign M_Valid_128[3] = M_Ready & !empty_128;
assign M_Valid_128[4] = M_Ready & !empty_128;
assign M_Valid_128[5] = M_Ready & !empty_128;
assign M_Valid_128[6] = M_Ready & !empty_128;
assign M_Valid_128[7] = M_Ready & !empty_128;
assign M_Valid_128[8] = M_Ready & !empty_128;


assign S_Ready      = CONV_11_Parallel ? S_Ready_64 : S_Ready_128;
assign M_Feature    = CONV_11_Parallel ? M_Feature_64 : M_Feature_128;
assign M_Valid      = CONV_11_Parallel ? M_Valid_64 : M_Valid_128;

count_mult count_padding (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_In_REG),      // input wire [11 : 0] A
  .B(Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo)      // output wire [11 : 0] P
);

endmodule
