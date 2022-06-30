`timescale 1ns / 1ps

module mult_dou_8_8(
input clk,
input   [7:0] data_in,
input   [7:0] weight_in,
output [`WIDTH_DATA_OUT*2-1:0] result_a

    );
 wire [15:0]  result_temp;
mult_8_8_16 mult_8_8_16 (
                    .CLK(clk),
                    .A(data_in),   
                    .B(weight_in),      // input wire [8 : 0] B
                    .P(result_temp)      // output wire [34 : 0] P
                ); 
reg [15:0]final_a;
  

always@(posedge clk)
       final_a  <= result_temp;
       
assign result_a={{4{final_a[15]}},final_a};
endmodule