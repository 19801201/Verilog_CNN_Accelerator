`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/07 19:00:27
// Design Name: 
// Module Name: BIAS_FIFO_11
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


module BIAS_FIFO_11  #(parameter
        WIDTH       = 8,
        ADDR_BITS   = 10
    )(
     input clk,
     input rst,
     input Next_Reg,
     input [WIDTH-1:0] din,
     input wr_en,
 
     input rd_en,
     output [WIDTH-1:0] dout,
   
     input [ADDR_BITS:0] M_count,  //back
     output reg M_Ready,
     input [ADDR_BITS:0] S_count,   //front
     output reg S_Ready
);  
wire   [10:0]     data_count;
fifo_bias_1_1   fifo_bias_1_1 (
  .clk(clk),                  // input wire clk
  .srst(rst||Next_Reg),                // input wire srst
  .din(din),                  // input wire [255 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(dout),                // output wire [255 : 0] dout
  .full(),                // output wire full
  .empty(),              // output wire empty
  .data_count(data_count)   // output wire [10 : 0] data_count

);

always@(posedge clk) begin
    if(rst) begin
       M_Ready <= 1'b0;
    end
    else if(data_count>=M_count) 
        M_Ready <= 1'b1;
    else 
       M_Ready <= 1'b0;
end
always@(posedge clk) begin
    if(rst) begin
       S_Ready <= 1'b1;
    end
    else if(data_count+S_count<1024) 
        S_Ready <= 1'b1;
    else 
       S_Ready <= 1'b0;
end
 
endmodule

