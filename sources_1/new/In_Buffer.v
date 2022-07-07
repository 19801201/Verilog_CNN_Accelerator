`timescale 1ns / 1ps

module In_Buffer(
    input           clk,
    input           rst,
    input [255:0]   S_Data,
    input           S_Valid,
    output          S_Ready,
    
    output [255:0]  M_Data,
    output          M_Valid,
    input           M_Ready
);

wire empty;
wire full;

assign S_Ready = !full;

URAM_FIFO #(
    .DATA_WIDTH         (256),
    .FIFO_DEPTH         (65536),
    .DATA_COUNT_WIDTH   (17)
)URAM_FIFO_2(
    .clk            (clk),
    .rst            (rst),
    .wr_en          (S_Data),
    .din            (S_Valid && S_Ready),
    .rd_en          (M_Ready && M_Valid),
    .dout           (M_Data),
    .empty          (empty),
    .full           (full)
);
assign M_Valid = !empty;

endmodule
