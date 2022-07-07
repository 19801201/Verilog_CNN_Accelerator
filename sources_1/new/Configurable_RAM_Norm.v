`timescale 1ns / 1ps

module Configurable_RAM_Norm#(parameter
    WIDTH            =  8,
    ADDR_BITS        =  10 
)(
    input clk,
    input [ADDR_BITS-1:0] read_address,
    input [ADDR_BITS-1:0] write_address,
    input [WIDTH-1:0] input_data,
    input write_enable,
    output [WIDTH-1:0] output_data   //  64 
//    output [WIDTH*4-1:0] output_data   //  64 * 4 = 256
    );
    
//Conv_Norm_1_1_RAM Conv_Norm_1_1_RAM (
//  .clka(clk),    // input wire clka
//  .ena(1),      // input wire ena
//  .wea(write_enable),      // input wire [0 : 0] wea
//  .addra(write_address),  // input wire [11 : 0] addra
//  .dina(input_data),    // input wire [63 : 0] dina
//  .clkb(clk),    // input wire clkb
//  .enb(1),      // input wire enb
//  .addrb(read_address),  // input wire [9 : 0] addrb
//  .doutb(output_data)  // output wire [255 : 0] doutb
//);


   (* ram_style="distributed" *)
   reg [WIDTH-1:0] distributed_ram [(2**ADDR_BITS)-1:0];
   always @(posedge clk)
      if (write_enable)
         distributed_ram [write_address] <= input_data;
   assign output_data = distributed_ram[read_address];
    
endmodule

