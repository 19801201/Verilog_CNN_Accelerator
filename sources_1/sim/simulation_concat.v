`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 16:45:36
// Design Name: 
// Module Name: simulation_weight_feature_stream
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

module simulation_concat#(parameter
    FILTER_SIZE               =  3,//ï¿½ï¿½ï¿½ï¿½Ë´ï¿½ï¿½?
    CHANNEL_IN_NUM            =  16 ,
    CHANNEL_OUT_NUM           =  8,
    WEIGHT_IN_NUM             =  8,
    WIDTH_RAM_SIZE            =  12,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_WEIGHT_SIZE         =  20,
    WIDTH_OTHERS_SIZE         =  10,
    CONV_CONTROL              =  32'h0000_0001,//3X3ï¿½ï¿½
    WIDTH_CHANNEL_NUM         =  10 
    
)(
input clk,
input rst,
input EN,
input DMA_read_para,
input DMA_read_feature,
input DMA_read_feature_2,
input DMA_write_valid,
output [128-1:0] S_Data_1,
output  S_Valid_1,
input   S_Ready_1,
output [128-1:0] S_Data,
output  S_Valid,
input   S_Ready
    );

// **************************************************************
wire  [18:0] weight_num;
wire  [20:0] feature_num;
assign weight_num = 19'd21632;       // È¨ÖØÐÐÊý
assign feature_num = 21'd21632;      // Í¼Æ¬ÐÐÊý

// **************************************************************
////////////Control///////////////////
wire para_EN=EN;
wire feature_EN=!EN;
wire weight_Ready;
wire feature_Ready;
assign weight_Ready =feature_EN?S_Ready_1:0;
assign feature_Ready = feature_EN?S_Ready:0;

/////////////FIFO Out ////////////////////////////////////////////
wire weight_valid;
wire w_empty;
wire [8*1*CHANNEL_IN_NUM-1:0] w_data;
wire feature_Valid;
wire f_empty;
wire [8*1*CHANNEL_IN_NUM-1:0] feature_dout;
assign feature_Valid =(!f_empty == 1'b1)?1'b1:1'b0;
reg [3:0]feature_Valid_Delay;
always@(posedge clk)begin
feature_Valid_Delay[0]<=feature_Valid;
feature_Valid_Delay[1]<=feature_Valid_Delay[0];
feature_Valid_Delay[2]<=feature_Valid_Delay[1];
feature_Valid_Delay[3]<=feature_Valid_Delay[2];
end
assign weight_valid =(!w_empty == 1'b1)?1'b1:1'b0;
assign S_Data = EN ? 64'b0:feature_dout;
assign S_Valid= EN ? 1'b0:feature_Valid;

assign S_Data_1 = EN ? 64'b0:w_data;
assign S_Valid_1= EN ? 1'b0:weight_valid;

// //// Weight ram read/////////////////////////////////////////////////////
reg  [18:0] Weight_Addr;
reg Weight_Addr_EN;
wire w_almost_full;
always@(posedge clk )begin
    if(rst)
         Weight_Addr_EN<=1'b0;
    else if(DMA_read_feature_2 == 1'b1)
         Weight_Addr_EN<=1'b1;
    else if(Weight_Addr== weight_num)
         Weight_Addr_EN<=1'b0;
    else
          Weight_Addr_EN<=Weight_Addr_EN;   
end
always@(posedge clk )begin
    if(rst)
         Weight_Addr<=19'b0;
    else if(Weight_Addr == weight_num)
//         Weight_Addr <= 1'b0;
         Weight_Addr <= Weight_Addr;
    else if (Weight_Addr_EN==1'b0)
           Weight_Addr <= 19'b0;
    else if(!w_almost_full==1'b1)
         Weight_Addr<=Weight_Addr+1'b1;  
    else
         Weight_Addr<=Weight_Addr;
end
///////// Weight FIFO In/////////////////////////////////////////
wire wr_en_weight;
reg [18:0] Weight_Addr_reg;
always@(posedge clk )begin
    if(rst)
         Weight_Addr_reg<=19'b0;
    else  
         Weight_Addr_reg<=Weight_Addr;
end
assign wr_en_weight=(Weight_Addr!=Weight_Addr_reg)?1'b1:1'b0;
reg wr_en_weight_dely;
always@(posedge clk)begin
wr_en_weight_dely<=wr_en_weight;
end
//always@(posedge clk )begin
//    if(rst)
//         wr_en_weight<=1'b0;
//    else  if(Weight_Addr_reg!=Weight_Addr)
//         wr_en_weight<=1'b1;
//    else 
//         wr_en_weight<=1'b0;
//end
////////////////Weight /////////////////////////////////////////////////
wire [127:0] weight_data;
test_weight test_weight1 (
  .clka(clk),           // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(Weight_Addr), // input wire [10 : 0] addra
  .douta(weight_data)   // output wire [255 : 0] douta
);
test_FIFO test_fifo2 (
  .clk(clk),                    // input wire clk
  .srst(rst),                  // input wire srst
  .din(weight_data),                    // input wire [255 : 0] din
  .wr_en(wr_en_weight),                // input wire wr_en
  .rd_en(weight_Ready&weight_valid),                // input wire rd_en
  .dout(w_data),                  // output wire [255 : 0] dout
  .full(),                  // output wire full
  .almost_full(w_almost_full),
  .empty(w_empty) // output wire almost_empty
 
);
//////////////////Feature RAM read////////////////////////////////////

reg  [20:0] Feature_Addr;
reg Feature_Addr_EN;
wire f_almost_full;
always@(posedge clk )begin
    if(rst)
         Feature_Addr_EN<=1'b0;
    else if(DMA_read_feature == 1'b1)
         Feature_Addr_EN<=1'b1;
    else if(Feature_Addr == feature_num)
         Feature_Addr_EN<=1'b0;
    else
          Feature_Addr_EN<=Feature_Addr_EN;   
end
always@(posedge clk )begin
    if(rst)
         Feature_Addr<=19'b0;
    else if(Feature_Addr == feature_num)
//         Feature_Addr <= 1'b0;
         Feature_Addr <= Feature_Addr;
    else if (Feature_Addr_EN==1'b0)
           Feature_Addr <= 19'b0;
    else if(!f_almost_full==1'b1)
         Feature_Addr<=Feature_Addr+1'b1;  
    else
         Feature_Addr<=Feature_Addr;
end

//end 
//////////////fifo in////////////////////////////////////////////////////

reg [20:0] Feature_Addr_reg;
always@(posedge clk )begin
    if(rst)
         Feature_Addr_reg<=21'b0;
    else  
         Feature_Addr_reg<=Feature_Addr;
end
//test part
wire wr_en_feature;
assign wr_en_feature=(Feature_Addr!=Feature_Addr_reg)?1'b1:1'b0;

wire [8*1*CHANNEL_IN_NUM-1:0]S_Feature;
test_image test_image1 (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(Feature_Addr),  // input wire [17 : 0] addra
  .dina(),    // input wire [127 : 0] dina
  .douta(S_Feature)  // output wire [127 : 0] douta
);
test_FIFO test_fifo1 (
  .clk(clk),                    // input wire clk
  .srst(rst),                  // input wire srst
  .din(S_Feature),                    // input wire [255 : 0] din
  .wr_en(wr_en_feature),                // input wire wr_en
  .rd_en(feature_Ready&feature_Valid),                // input wire rd_en
  .dout(feature_dout),                  // output wire [255 : 0] dout
  .full(),                  // output wire full
  .almost_full(f_almost_full),
  .empty(f_empty) 
);
endmodule
