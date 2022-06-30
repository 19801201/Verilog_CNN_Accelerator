`timescale 1ns / 1ps

`include"../Para.v"
module Cin_Convert#(parameter
    CHANNEL_IN_NUM            =  16
)(
    input  clk,
    output S_Ready,
    input  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0]  S_Feature,
    input  S_Valid,
    input  M_Ready,
    output  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0]  M_Feature,
    output  M_Valid,
    input  EN_Cin_Select_REG
    
    );

localparam   Half_Channel_Out_Num =   `Channel_Out_Num >> 1; 
    
wire [`PICTURE_NUM*Half_Channel_Out_Num*8-1:0] M_Feature_Temp;
wire M_Valid_temp;
wire S_Ready_temp;

assign M_Feature=EN_Cin_Select_REG?{{{`PICTURE_NUM*Half_Channel_Out_Num*8}{1'b0}},M_Feature_Temp}:S_Feature;
assign M_Valid=EN_Cin_Select_REG?M_Valid_temp:S_Valid;
assign S_Ready=EN_Cin_Select_REG?S_Ready_temp:M_Ready;


Cin_Converter_test  Cin_Converter_test  (
      .clk(clk),
      .S_Ready(S_Ready_temp),
      .S_Feature(S_Feature),
      .S_Valid(S_Valid),
      .M_Ready(M_Ready),
      .M_Feature(M_Feature_Temp),
      .M_Valid(M_Valid_temp)
      );
endmodule
