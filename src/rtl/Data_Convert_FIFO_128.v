`timescale 1ns / 1ps


module Data_Convert_FIFO_128#(parameter
        WIDTH       = 128,
        WIDTH_OUT   = 1152,
        ADDR_BITS   = 10
)(
    input clk,
    input rst,
    input Next_Reg,
    input [WIDTH-1:0] din,
    input wr_en,
    
    input rd_en,
    output [WIDTH_OUT-1:0] dout,
    
    input [ADDR_BITS:0] M_count,  //back
    output reg M_Ready,
    input [ADDR_BITS:0] S_count,   //front
    output reg S_Ready,
    output empty
);  

wire full;
wire [1023 : 0] dout_q;     // 128 in

wire [7 : 0]  rd_data_count;    //128 in
wire [9 : 0] wr_data_count;
data_convert_128 data_convert_128 (
  .clk(clk),                      // input wire clk
  .srst(rst||Next_Reg),                    // input wire srst
  .din(din),                      // input wire [127 : 0] din
  .wr_en(wr_en),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(dout_q),                    // output wire [1023 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [7 : 0] rd_data_count
  .wr_data_count(wr_data_count)   // output wire [10 : 0] wr_data_count
);

//assign dout = {128'b0,dout_q[127:0],dout_q[255:128],dout_q[383:256],dout_q[511:384],dout_q[639:512],dout_q[767:640],dout_q[895:768],dout_q[1023:896]}; // 128 in
assign dout = {1280'b0,dout_q[255:0],dout_q[511:256],dout_q[767:512],dout_q[1023:768]};
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
   else if(rd_data_count<120)  // 128 in
        S_Ready <= 1'b1;
    else 
       S_Ready <= 1'b0;
end

endmodule
