`timescale 1ns / 1ps

`include"./Para.v"
module shift#(parameter
WIDTH_DATA_ADD            =  32
)(
    input clk,
    input rst,
    input [WIDTH_DATA_ADD-1'b1:0] shift_data_in,
    input [WIDTH_DATA_ADD-1'b1:0] data_in,
    output reg [15:0] shift_data_out
);

reg [WIDTH_DATA_ADD-1'b1:0] data;

always@(posedge clk)begin
    data <= data_in >>> shift_data_in;
end

always@( posedge clk )	begin
	if( rst )begin
		shift_data_out <= 16'b0;
	end
	else if(data[0]==1'b1) 
	     shift_data_out<={data[31],data[15:1]}+1'b1;
	else shift_data_out<={data[31],data[15:1]};		
end 

endmodule