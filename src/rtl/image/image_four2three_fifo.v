`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/18 17:31:02
// Design Name: 
// Module Name: image_four2three_fifo
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


module image_four2three_fifo#(parameter
	WIDTH = 8,
	ADDR_BITS = 10
)(
	input						clk,
	input						rst,
	input	[WIDTH-1'b1:0]		din,
	input 						rd_en,
	input						wr_en,
	input	[ADDR_BITS:0]	    M_Count,
	input	[ADDR_BITS:0]	    S_Count,
	output	[WIDTH-1'b1:0]		dout,
	output 	reg					M_Valid,
	output	reg					S_Ready
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
	else if (data_count + S_Count < 1024)
		S_Ready <= 1'b1;
	else
		S_Ready <= 1'b0;
end


image_fifo_4_3 image_fifo_4_3 (
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


