`timescale 1ns / 1ps

`include"./Para.v"
module conv_2d #(parameter
CONV_TYPE       =       "CONV_3_3",//CONV_3_3
KERNEL_NUM      =       9//9
) (
    input  clk,
    input  [`PICTURE_NUM * KERNEL_NUM * `WIDTH_DATA -1 : 0]       data_in,
    input  [KERNEL_NUM * `WIDTH_DATA -1 : 0]                      weight_in,
    output [`PICTURE_NUM * `WIDTH_DATA_OUT * 2  -1 : 0]           data_out  
   );
    
 generate
      case (CONV_TYPE)
         "CONV_3_3": begin compute_3_3_mult_add #(KERNEL_NUM)
         compute_3_3_mult_add(
         .clk(clk),
         .data_in(data_in),
         .weight_in(weight_in),
         .data_out(data_out)
    ); 
         end
         "CONV_1_1": begin compute_1_1_mult #(KERNEL_NUM)
         compute_1_1_mult(
         .clk(clk),
         .data_in(data_in),
         .weight_in(weight_in),
         .data_out(data_out)
          );
         end
      endcase
   endgenerate 
endmodule
