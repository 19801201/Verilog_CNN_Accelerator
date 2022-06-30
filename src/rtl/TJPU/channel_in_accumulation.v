`timescale 1ns / 1ps

`include"../Para.v"
module channel_in_accumulation#(parameter
COMPUTE_CHANNEL_IN_NUM       =       16 //8 4 2 1
)
(
    input  clk,
    input  [`PICTURE_NUM *COMPUTE_CHANNEL_IN_NUM* `WIDTH_DATA_OUT* 2 -1 : 0] data_in,
    output [`PICTURE_NUM  * `WIDTH_DATA_OUT * 2 -1 : 0]      data_out 
    );
generate
     case (COMPUTE_CHANNEL_IN_NUM)
   1:begin
    channel_in_one_times_acc  #(
        .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
   )channel_in_one_times_acc (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out) 
    ); 
    end
    2:begin
    channel_in_two_times_acc  #(
        .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
   )channel_in_two_times_acc (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out) 
    );    
    end    
    4:begin
    channel_in_four_times_acc  #(
        .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
   )channel_in_four_times_acc (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out) 
    );    
    end
    8:begin
    channel_in_eight_times_acc  #(
        .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
   )channel_in_eight_times_acc (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out) 
    );
    end
    16:begin
    channel_in_sixteen_times_acc  #(
        .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
   )channel_in_sixteen_times_acc (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out) 
    );
    end
    32:begin
    channel_in_thirty_two_times_acc  #(
        .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
   )channel_in_thirty_two_times_acc (
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out) 
    );
    end
    endcase
  endgenerate
endmodule
