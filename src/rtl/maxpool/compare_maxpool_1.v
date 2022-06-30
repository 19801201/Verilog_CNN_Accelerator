`timescale 1ns / 1ps

module compare_maxpool_1(
    input  clk,
    input  rst,
    input  [7:0]data_1,
    input  [7:0]data_2,
    output reg [7:0]data_out
    );
    
always@(posedge clk)begin
    if(rst)begin
        data_out <= 1'b0;
    end else if(data_1 > data_2)begin
        data_out <= data_1;
    end else begin
        data_out <= data_2;
    end       
end

    
endmodule
