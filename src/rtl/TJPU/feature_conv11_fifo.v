`timescale 1ns / 1ps


module feature_conv11_fifo#(parameter
        WIDTH_8     = 64,
        WIDTH       = 256,
        ADDR_BITS   = 10
    )(
     input clk,
     input rst,
     input Next_Reg,
     input [WIDTH_8-1:0] din,
     input wr_en,
 
     input rd_en,
     output [WIDTH-1:0] dout,
   
     input [ADDR_BITS:0] M_count,  //back
     output reg M_Ready,
     input [ADDR_BITS:0] S_count,   //front
     output reg S_Ready
);  
wire [12:0]  data_count;
wire [8:0]  rd_data_count;
wire [10:0]  wr_data_count;
conv11_fifo_temp conv11_fifo (
  .clk(clk),                      // input wire clk
  .srst(rst||Next_Reg),                    // input wire srst
  .din(din),                      // input wire [63 : 0] din
  .wr_en(wr_en),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(dout),                    // output wire [255 : 0] dout
  .full(),                    // output wire full
  .empty(),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [10 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [12 : 0] wr_data_count
);

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
    else if (rd_data_count<250)
        S_Ready <= 1'b1;
    else 
        S_Ready <= 1'b0;
end
 
endmodule

