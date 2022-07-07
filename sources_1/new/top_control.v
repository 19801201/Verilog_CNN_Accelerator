`timescale 1ns / 1ps

module top_control(
    input clk,
    input rst,
    input [31:0]Switch,
    output reg [1:0] Switch0,
    output reg [3:0] Switch1,
    output DMA_Read_Start,
    output DMA_Write_Start,
    output M_Last,
    input  PE0_DMA_read_Start,
//    input  PE1_DMA_read_Start,
//    input  PE2_DMA_read_Start,
    input  PE3_DMA_read_Start,
    input  PE0_DMA_Write_Start,
//    input  PE1_DMA_Write_Start,
//    input  PE2_DMA_Write_Start,
    input  PE3_DMA_Write_Start,
    input Last_33,
    input Last_Reshape
    
    
    );

reg	[3:0]	Switch_encode;

assign DMA_Read_Start  = PE0_DMA_read_Start||PE3_DMA_read_Start;
assign DMA_Write_Start = PE0_DMA_Write_Start||PE3_DMA_Write_Start;
assign M_Last = Last_33||Last_Reshape;

always@(posedge clk)begin
    Switch_encode <= Switch[3:0];
end

always @ (posedge clk) begin 
	case (Switch_encode)
		4'b0001:
			Switch0 <= 2'b00;          // conv3x3
		4'b0010:
			Switch0 <= 2'b01;		    // conv1x1
		4'b0100:
			Switch0 <= 2'b10;			// reserved
		4'b1000:	
			Switch0 <= 2'b11;          // reshape 
	endcase
end

always @ (posedge clk) begin 
	case (Switch_encode)
		4'b0001:
			Switch1 <= 4'b1110;			// conv3x3
		4'b0010:
			Switch1 <= 4'b1101;		      // conv1x1
		4'b0100:
			Switch1 <= 4'b1011;           // reserved
		4'b1000:
			Switch1 <= 4'b0111;            // reshape
	endcase
end


endmodule
