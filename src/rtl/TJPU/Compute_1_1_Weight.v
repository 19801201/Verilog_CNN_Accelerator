`timescale 1ns / 1ps
`include"../Para.v"



module Compute_1_1_Weight#(parameter
    KERNEL_NUM                   =       1,
    COMPUTE_CHANNEL_IN_NUM       =       32,
    COMPUTE_CHANNEL_OUT_NUM      =       8,
    WIDTH_RAM_ADDR_SIZE          =       14
)
(   
    input   clk,
    input  [`AXI_WIDTH_DATA - 1 : 0] weight_data_One,
//    input  [`AXI_WIDTH_DATA - 1 : 0] weight_data_Two,
//    input  [`AXI_WIDTH_DATA - 1 : 0] weight_data_Three,
    input  [KERNEL_NUM - 1 : 0]             weight_wr,
    input  [WIDTH_RAM_ADDR_SIZE-1:0]        weight_addra,
    input  [WIDTH_RAM_ADDR_SIZE-1-5:0]        weight_addrb,
    input                             write_address_help,
    output [COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA * KERNEL_NUM- 1 : 0] weight_ram_data_out
    );

// wire [COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA - 1 : 0] weight_ram_data_out_One;
// wire [COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA * 3- 1 : 0] weight_ram_data_out_Two;
// wire [COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA * 3- 1 : 0] weight_ram_data_out_Three;
//assign weight_ram_data_out = weight_ram_data_out_One;
//generate 
//genvar i;
//for(i=0;i<3;i=i+1)begin    
//================7----2--block_ram_test_0-2==============
COMPUTE_1_1_WEIGHT_INS weight_ram (
  .clka(clk),    // input wire clka
  .ena(1),      // input wire ena
  .wea(weight_wr),      // input wire [0 : 0] wea
  .addra(weight_addra),  // input wire [11 : 0] addra
  .dina(weight_data_One),    // input wire [63 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(weight_addrb),  // input wire [10 : 0] addrb
  .doutb(weight_ram_data_out)  // output wire [2047 : 0] doutb
);
//COMPUTE_3_3_WEIGHT_INS weight_ram (
//  .clka(clk),    // input wire clka
//  .ena(1),      // input wire ena
//  .wea(weight_wr[i]),      // input wire [0 : 0] wea
//  .addra(weight_addra),  // input wire [11 : 0] addra
//  .dina(weight_data_One),    // input wire [255 : 0] dina
//  .clkb(clk),    // input wire clkb
//  .enb(1),      // input wire enb
//  .addrb(weight_addrb[WIDTH_RAM_ADDR_SIZE-2:0]),  // input wire [10 : 0] addrb
//  .doutb(weight_ram_data_out_One[COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *(i+1)-1:
//                   COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *i ])  // output wire [511 : 0] doutb
//);
//end
//endgenerate



//generate 
//genvar j;
//for(j=0;j<3;j=j+1)begin    
////================7----2--block_ram_test_3-5==============

//COMPUTE_3_3_WEIGHT_INS weight_ram (
//  .clka(clk),    // input wire clka
//  .ena(1),      // input wire ena
//  .wea(weight_wr[j+3]),      // input wire [0 : 0] wea
//  .addra(weight_addra),  // input wire [11 : 0] addra
//  .dina(weight_data_Two),    // input wire [255 : 0] dina
//  .clkb(clk),    // input wire clkb
//  .enb(1),      // input wire enb
//  .addrb(weight_addrb[WIDTH_RAM_ADDR_SIZE-2:0]),  // input wire [10 : 0] addrb
//  .doutb(weight_ram_data_out_Two[COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *(j+1)-1:
//                   COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *j ])  // output wire [511 : 0] doutb
//);
//end
//endgenerate




//generate 
//genvar k;
//for(k=0;k<3;k=k+1)begin    
////================7----2--block_ram_test_0-2==============

//COMPUTE_3_3_WEIGHT_INS weight_ram (
//  .clka(clk),    // input wire clka
//  .ena(1),      // input wire ena
//  .wea(weight_wr[k+6]),      // input wire [0 : 0] wea
//  .addra(weight_addra),  // input wire [11 : 0] addra
//  .dina(weight_data_Three),    // input wire [255 : 0] dina
//  .clkb(clk),    // input wire clkb
//  .enb(1),      // input wire enb
//  .addrb(weight_addrb[WIDTH_RAM_ADDR_SIZE-2:0]),  // input wire [10 : 0] addrb
//  .doutb(weight_ram_data_out_Three[COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *(k+1)-1:
//                   COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *k ])  // output wire [511 : 0] doutb
//);
//end
//endgenerate
endmodule