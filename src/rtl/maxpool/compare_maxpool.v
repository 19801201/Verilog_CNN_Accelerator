`timescale 1ns / 1ps

`include"../Para.v"

module compare_maxpool#(
    parameter RE_CHANNEL_IN_NUM = 16
)(
    input  clk,
    input  rst,
    input  [`AXI_WIDTH_DATA_IN-1:0]data_1,
    input  [`AXI_WIDTH_DATA_IN-1:0]data_2,
    output [`AXI_WIDTH_DATA_IN-1:0]data_out
    );
    
    generate
    genvar i;
        for(i=0;i<RE_CHANNEL_IN_NUM*`PICTURE_NUM;i=i+1)begin
    compare_maxpool_1 compare_maxpool_1(
            .clk(clk),
            .rst(rst),
            .data_1(data_1[(i+1)*8-1:i*8]),
            .data_2(data_2[(i+1)*8-1:i*8]),
            .data_out(data_out[(i+1)*8-1:i*8])
        );
        end
    endgenerate
  
endmodule
