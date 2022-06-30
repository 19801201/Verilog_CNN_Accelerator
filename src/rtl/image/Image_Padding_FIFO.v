`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/21 15:29:08
// Design Name: 
// Module Name: Image_Padding_FIFO
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


module Image_Padding_FIFO#(parameter
	WIDTH = 8,
	ADDR_BITS = 11
)(
	input					clk,
	input					rst,
	input	[WIDTH-1:0] 	din,
	input					wr_en,
	input					rd_en,
	input	[ADDR_BITS-1:0]	M_Count,      
	input	[ADDR_BITS-1:0]	S_Count,
	output	reg				M_Valid,      //  xia ceng
	output	reg				S_Ready,      //  shang ceng  
	output	[WIDTH-1:0]		dout			
);

wire	[10:0]	data_count;

always @ (posedge clk) begin 
	if (rst)
		M_Valid <= 1'b0;
	else if (data_count >= M_Count)
		M_Valid <= 1'b1;
	else
		M_Valid <= 1'b0;
end

always @ (posedge clk) begin 
	if (rst)
		S_Ready <= 1'b1;
	else if (data_count  < 1000)
		S_Ready <= 1'b1;
	else
		S_Ready <= 1'b0;
end


image_fifo_32_2048  fifo_32_2048_padding (
  .clk(clk),                // input wire clk
  .srst(rst),              // input wire srst
  .din(din),                // input wire [7 : 0] din
  .wr_en(wr_en),            // input wire wr_en
  .rd_en(rd_en),            // input wire rd_en
  .dout(dout),              // output wire [7 : 0] dout
  .full(),              // output wire full
  .empty(),            // output wire empty
  .data_count(data_count)  // output wire [10 : 0] data_count
);

endmodule
