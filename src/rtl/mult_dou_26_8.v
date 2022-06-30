`timescale 1ns / 1ps


module mult_dou_26_8(
input clk,
input   [23:0] data_in,
input   [7:0] weight_in,
output [`WIDTH_DATA_OUT*2-1:0] result_a,
output [`WIDTH_DATA_OUT*2-1:0] result_b

    );
 wire [31:0]  result_temp;
Mult_26_8_34 Mult_2 (
                    .CLK(clk),
                    .A(data_in),   
                    .B(weight_in),      // input wire [8 : 0] B
                    .P(result_temp)      // output wire [34 : 0] P
                ); 
reg [15:0]final_a,final_b;
  
always@(posedge clk)
    if(result_temp[31]&result_temp[15] == 1'b1)
    	final_a  <= result_temp[31:16]+1'b1;
    else
       final_a  <=result_temp[31:16];
always@(posedge clk)
       final_b  <=result_temp[15:0];
       
assign result_a={{4{final_a[15]}},final_a};
assign result_b={{4{final_b[15]}},final_b};
endmodule