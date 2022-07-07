`timescale 1ns / 1ps


`include"./Para.v"
module accumulation #(parameter
    WIDTH_DATA_ADD = 32
 )
(
    input clk,
    input rst,
    input [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0] data_result_temp,
    input First_Compute_Complete,
    output  reg [`PICTURE_NUM*WIDTH_DATA_ADD-1:0]   M_Data_out
    
    );
    wire [`PICTURE_NUM*WIDTH_DATA_ADD-1:0] data_result;
generate
    genvar i;
for(i=0;i<`PICTURE_NUM;i=i+1)begin
assign data_result[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD] =
                {{12{data_result_temp[(i+1)*`WIDTH_DATA_OUT*2-1]}},
                data_result_temp[(i+1)*`WIDTH_DATA_OUT*2-1:i*`WIDTH_DATA_OUT*2]};
   always @ (posedge clk)
      if (rst)
         M_Data_out[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD] <={WIDTH_DATA_ADD{1'b0}};
       else if(First_Compute_Complete==1'b1)
        M_Data_out[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD]
        <=data_result[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD];
      else 
         M_Data_out[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD]
          <=  M_Data_out[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD]
          + data_result[(i+1)*WIDTH_DATA_ADD-1:i*WIDTH_DATA_ADD];
end
endgenerate
endmodule 

