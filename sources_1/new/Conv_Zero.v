`timescale 1ns / 1ps

`include"./Para.v"
module Conv_Zero#(parameter
    CHANNEL_OUT_NUM           =  8
)
(
input   clk,
input	M_Valid_Temp,
input   [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA*2-1:0] shift_data_in,
input   [7:0 ] zero_data_in,
output  [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0] data_out
    );
////////////////////////////
reg Valid_Temp_Delay[0:13];    
wire	[`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA*2-1:0] zero_data_16;    
///////////////////////////    
    
wire [2*`WIDTH_DATA-1:0] data_out_temp[0:`PICTURE_NUM*CHANNEL_OUT_NUM-1'b1];
reg  [`WIDTH_DATA-1:0]   data_out_relu[0:`PICTURE_NUM*CHANNEL_OUT_NUM-1'b1];
wire [7:0]data_out_judge[0:`PICTURE_NUM*CHANNEL_OUT_NUM-1'b1];
generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    for(j =0;j<CHANNEL_OUT_NUM;j=j+1)begin
add_16_u8_16 add_16_u8_16 (
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
assign	zero_data_16[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA*2-1'b1:(j*`PICTURE_NUM+i)*`WIDTH_DATA*2] = data_out_temp[j*`PICTURE_NUM+i];
    end
  end
endgenerate

always@(posedge clk )begin
Valid_Temp_Delay[0]<=M_Valid_Temp;
end
generate 
genvar m;
for(m=0;m<13;m=m+1)begin
always@(posedge clk)begin
Valid_Temp_Delay[m+1]<=Valid_Temp_Delay[m];
end
end
endgenerate


endmodule
