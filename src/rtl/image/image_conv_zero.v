`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/02 21:16:33
// Design Name: 
// Module Name: Conv_Zero
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
module image_conv_zero#(parameter
    CHANNEL_OUT_NUM           =  8
)
(
input   clk,
input   [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA*2-1:0] shift_data_in,
input   [7:0 ] zero_data_in,
output  [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0] data_out
    );
wire [2*`WIDTH_DATA-1:0] data_out_temp[0:`PICTURE_NUM*CHANNEL_OUT_NUM-1'b1];
reg  [`WIDTH_DATA-1:0]   data_out_relu[0:`PICTURE_NUM*CHANNEL_OUT_NUM-1'b1];
wire [7:0]data_out_judge[0:`PICTURE_NUM*CHANNEL_OUT_NUM-1'b1];
generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    for(j =0;j<CHANNEL_OUT_NUM;j=j+1)begin
add_16_u8_16   add_16_u8_16 (
  .A(shift_data_in[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA*2-1:
        (j*`PICTURE_NUM+i)*`WIDTH_DATA*2]),      // input wire [15 : 0] A
  .B(zero_data_in),      // input wire [7 : 0] B
  .CLK(clk),  // input wire CLK
  .S(data_out_temp[j*`PICTURE_NUM+i])      // output wire [15 : 0] S
  );
//----------------------relu--------------------
assign data_out_judge[j*`PICTURE_NUM+i]=data_out_temp[j*`PICTURE_NUM+i][14:8];
always@(posedge clk)begin
    if(data_out_temp[j*`PICTURE_NUM+i][15])
        data_out_relu[j*`PICTURE_NUM+i]<={8{1'b0}};
    else begin
        if(data_out_judge[j*`PICTURE_NUM+i]>1'b0)
            data_out_relu[j*`PICTURE_NUM+i]<={8{1'b1}};
         else
            data_out_relu[j*`PICTURE_NUM+i]<=data_out_temp[j*`PICTURE_NUM+i][`WIDTH_DATA-1:0];
    end            
end  
assign data_out[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA-1'b1:(j*`PICTURE_NUM+i)*`WIDTH_DATA] = data_out_relu[j*`PICTURE_NUM+i];
//-----------
    end
  end
endgenerate

endmodule
