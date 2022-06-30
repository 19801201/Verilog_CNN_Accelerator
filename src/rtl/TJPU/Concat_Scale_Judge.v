`timescale 1ns / 1ps
`include  "../Para.v"



module Concat_Scale_Judge(
	input  clk,
    input  [32:0]   		Scale_Data_Temp,

    output reg [31:0]   	Scale_Data_Out

);
  
//////  resume  1   clk
always @ (posedge clk) begin 
	if (Scale_Data_Temp[0] == 1)
		Scale_Data_Out <= Scale_Data_Temp[32:1] + 1'b1;
	else
		Scale_Data_Out <= Scale_Data_Temp[32:1];
end  
  
  
  
endmodule
