`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/30 14:38:57
// Design Name: 
// Module Name: image_Configurable_RAM
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


module image_Configurable_RAM#(parameter
    WIDTH            =  8,
    ADDR_BITS        =  10 
)(
    input clk,
    input [ADDR_BITS-1:0] read_address,
    input [ADDR_BITS-1:0] write_address,
    input [WIDTH-1:0] input_data,
    input write_enable,
    output [WIDTH-1:0] output_data
    );

   (* ram_style="distributed" *)
   reg [WIDTH-1:0] distributed_ram [(2**ADDR_BITS)-1:0];
   always @(posedge clk)
      if (write_enable)
         distributed_ram [write_address] <= input_data;
   assign output_data = distributed_ram[read_address];
endmodule
