`timescale 1ns / 1ps
`include  "../Para.v"



module Bias_ram  #(parameter
    ADDR_BITS        = 8 
)(
    input clk,
    input [`AXI_WIDTH_DATA_IN-1:0] input_data,
    input [ADDR_BITS-1:0] write_address,
    input write_enable,
    input [ADDR_BITS-1:0] read_address,
    output [`Channel_Out_Num*32-1:0] output_data
    );
  

bias_ram bias_ram (
  .clka(clk),    // input wire clka
  .ena(1),      // input wire ena
  .wea(write_enable),      // input wire [0 : 0] wea
  .addra(write_address),  // input wire [8 : 0] addra
  .dina(input_data),    // input wire [127 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(read_address[ADDR_BITS-2:0]),  // input wire [6 : 0] addrb
  .doutb(output_data)  // output wire [255 : 0] doutb
);

endmodule
