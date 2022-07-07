`timescale 1ns / 1ps

module DMA_FIFO#(parameter
        WIDTH       = 64,
        WIDTH_16    = 128,
        ADDR_BITS   = 10
    )(
     input clk,
     input rst,
     input  Next_Reg_Temp,
     input [WIDTH-1:0] din,
     input wr_en,
 
     input rd_en,
     output [WIDTH_16-1:0] dout,
   
     input [ADDR_BITS:0] M_count,  //back
     output reg M_Ready,
     input [ADDR_BITS:0] S_count,   //front
     output reg S_Ready,
     output empty
);  
//wire   [10:0]  data_count;
wire [9:0]  rd_data_count;
wire [10:0] wr_data_count;
wire [WIDTH_16-1:0] dout_q;
stride_fifo stride_fifo (
  .clk(clk),                  // input wire clk
  .srst(rst||Next_Reg_Temp),                // input wire srst
  .din(din),                  // input wire [255 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(dout_q),                // output wire [255 : 0] dout
  .full(),                // output wire full
  .empty(empty),              // output wire empty
  .rd_data_count(rd_data_count),  // output wire [9 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [10 : 0] wr_data_count
//  .data_count(data_count)  // output wire [9 : 0] data_count
);
assign dout = {dout_q[63:0],dout_q[127:64]};

always@(posedge clk) begin
    if(rst) begin
       M_Ready <= 1'b0;
    end
    else if(wr_data_count>=M_count) 
        M_Ready <= 1'b1;
    else 
       M_Ready <= 1'b0;
end
always@(posedge clk) begin
    if(rst) begin
       S_Ready <= 1'b1;
    end
    else if(rd_data_count+S_count<512)
        S_Ready <= 1'b1;
    else 
       S_Ready <= 1'b0;
end
 
endmodule