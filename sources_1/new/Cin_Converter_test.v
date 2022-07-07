`timescale 1ns / 1ps
`include "./Para.v"

module Cin_Converter_test #(parameter
    Half_Channel_Out_Num = `Channel_Out_Num >> 1
)(
    input  clk,
    output S_Ready,
    input  [`PICTURE_NUM*`Channel_Out_Num*8-1:0]S_Feature,
    input  S_Valid,
    input  M_Ready,
    output  [`PICTURE_NUM*Half_Channel_Out_Num*8-1:0]   M_Feature,
    output  M_Valid
    );
    
reg  [`PICTURE_NUM*`Channel_Out_Num*8-1:0] S_Feature_Delay;
always@(posedge clk)begin
    S_Feature_Delay<=S_Feature;
end
assign M_Feature=(S_Valid==1'b1)?S_Feature[`PICTURE_NUM*Half_Channel_Out_Num*8-1:0]:S_Feature_Delay[`PICTURE_NUM*Half_Channel_Out_Num*8*2-1:`PICTURE_NUM*Half_Channel_Out_Num*8];
reg M_Ready_Delay;
always@(posedge clk)begin
    M_Ready_Delay<=M_Ready;
end
reg cnt;
always@(posedge clk)begin
    if(M_Ready==1'b1)begin
        if(M_Ready_Delay==1'b0&&M_Ready==1'b1)
            cnt<=1'b1;
        else
            cnt<=cnt+1;
    end
    else
        cnt<=1'b0;
end
assign S_Ready = cnt;
reg S_Valid_Delay;
always@(posedge clk)begin
    S_Valid_Delay<=S_Valid;
end
assign M_Valid=(S_Valid==1'b1)?S_Valid:S_Valid_Delay;
endmodule
