`timescale 1ns / 1ps

`include "../Para.v"

module TJPU#(parameter
    COMPUTE_CHANNEL_IN_NUM    =  16,
    COMPUTE_CHANNEL_OUT_NUM   =  8,
    WIDTH_FEATURE_SIZE        =  12,   // padding/4_3 fifo/conv3-9fifo : [11:0]   (2048)     bias-fifo : [12:0] (4096)
    WIDTH_CHANNEL_NUM_REG     =  10,
    KERNEL_NUM_33             =  9,
    KERNEL_NUM_11             =  1,
    WIDTH_RAM_SIZE            =  10,//feature ram size    //   4_3ram :[10:0]  (1024)
    WIDTH_WEIGHT_NUM          =  15,//weight num reg width
    WIDTH_DATA_ADD            =  32,//data add width
    WIDTH_BIAS_RAM_ADDRA      =   8,// 3x3 bias ram size
//    WIDTH_RAM_ADDR_TURE       =  15,//para block ram size  
    WIDTH_RAM_ADDR_SIZE       =  12,  // load_weight_bias 9 weight ram  addr 
    CONV_TYPE_33              = "CONV_3_3", 
    CONV_TYPE_11              = "CONV_1_1", 
    
    WIDTH_WEIGHT_NUM_1_1      =  16,//weight num reg width
    WIDTH_BIAS_RAM_ADDRA_1_1  =   9,  // 1x1 bias ram size
    WIDTH_RAM_ADDR_TURE_1_1   =  16,  //para block ram size   
    WIDTH_RAM_ADDR_SIZE_1_1   =  14,  // load_weight_bias 1 weight ram  addr
    
    RE_WIDTH_FEATURE_SIZE     =  11,
    RE_WIDTH_CHANNEL_NUM_REG  =  10,
    RE_WIDTH_WEIGHT_NUM       =  16,
    RE_CHANNEL_IN_NUM         =  16,
    RE_WIDTH_CONNECT_TIMES    =  15
    
)(
    input clk,
    input rst,
    input [3:0] Control_3_3,
    output[3:0] State_3_3,
    input [3:0] Control_1_1,
    output [3:0] State_1_1,
    input [7:0] Control_RE,
    output [7:0] State_RE,
    input [31:0] Switch,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,
    input [31:0] Reg_8,
    input [31:0] Reg_9,
    
    output Write_DDR_REG,
    output Read_DDR_REG,
    output Weight_Read_REG,
    //DMA 
    output DMA_Read_Start,
    output DMA_Write_Start,
    output DMA_Read_Start_2,
    
    /////////////////////////////////
    //Stream read
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data,
    input  S_Valid,
    output S_Ready,
    
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data_1,
    input  S_Valid_1,
    output S_Ready_1,
    /////////////////////////////////
    //Stream write
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    input  M_Ready,
    output M_Valid,
    output Tlast,
    input introut_3x3_Wr

); 

 wire [1:0] Switch0;
 wire [3:0] Switch1;
 wire  PE0_DMA_read_Start;//3x3
// wire  PE1_DMA_read_Start;
// wire  PE2_DMA_read_Start;
 wire  PE3_DMA_read_Start;
 wire  PE0_DMA_Write_Start;//3x3
// wire  PE1_DMA_Write_Start;
// wire  PE2_DMA_Write_Start;
 wire  PE3_DMA_Write_Start;

wire Read_DDR_REG_1,Read_DDR_REG_2;
wire Write_DDR_REG_1,Write_DDR_REG_2; 
wire  Last_33;
wire  Last_Reshape;

assign Write_DDR_REG = Write_DDR_REG_1 || Write_DDR_REG_2;
assign Read_DDR_REG = Read_DDR_REG_1 || Read_DDR_REG_2;

top_control top_control(
    . clk(clk),
    . rst(rst),
    . Switch(Switch),
    . Switch0(Switch0),
    . Switch1(Switch1),
    . DMA_Read_Start(DMA_Read_Start),
    . DMA_Write_Start(DMA_Write_Start),
    . M_Last(Tlast),
    . PE0_DMA_read_Start(PE0_DMA_read_Start),
//    . PE1_DMA_read_Start(PE1_DMA_read_Start),
//    . PE2_DMA_read_Start(PE2_DMA_read_Start),
    . PE3_DMA_read_Start(PE3_DMA_read_Start),
    . PE0_DMA_Write_Start(PE0_DMA_Write_Start),
//    . PE1_DMA_Write_Start(PE1_DMA_Write_Start),
//    . PE2_DMA_Write_Start(PE2_DMA_Write_Start),
    . PE3_DMA_Write_Start(PE3_DMA_Write_Start),
    . Last_33 (Last_33),
    . Last_Reshape (Last_Reshape)
); 
//--------------------------TOP_switch------------------
wire [3:0]M_Switch_Valid;
wire S_Conv_3_3_Ready,M_Conv_3_3_Valid,S_Conv_RE_Ready,M_Conv_RE_Valid;
wire [3:0]M_Switch_Ready;
wire [`AXI_WIDTH_DATA_IN*4-1:0]  M_Switch_Data;
assign M_Switch_Ready = {{S_Conv_RE_Ready},{1'b0},{1'b0},{S_Conv_3_3_Ready}};
Top_switch Top_swtich (
  .aclk(clk),                    // input wire aclk
  .aresetn(!rst),              // input wire aresetn
  .s_axis_tvalid(S_Valid),  // input wire [0 : 0] s_axis_tvalid
  .s_axis_tready(S_Ready),  // output wire [0 : 0] s_axis_tready
  .s_axis_tdata(S_Data),    // input wire [127 : 0] s_axis_tdata
  .s_axis_tdest(Switch0),    // input wire [1 : 0] s_axis_tdest
  .m_axis_tvalid(M_Switch_Valid),  // output wire [3 : 0] m_axis_tvalid
  .m_axis_tready(M_Switch_Ready),  // input wire [3 : 0] m_axis_tready
  .m_axis_tdata(M_Switch_Data),    // output wire [511 : 0] m_axis_tdata
  .m_axis_tdest(),    // output wire [7 : 0] m_axis_tdest
  .s_decode_err()    // output wire [0 : 0] s_decode_err
);
assign M_Conv_3_3_Valid = M_Switch_Valid[0]&&S_Conv_3_3_Ready;
//assign M_Conv_1_1_Valid = M_Switch_Valid[1]&&S_Conv_1_1_Ready;
assign M_Conv_RE_Valid = M_Switch_Valid[3]&&S_Conv_RE_Ready;
//-------------------       Conv 33     -----------------------
wire [`AXI_WIDTH_DATA_IN-1:0]   M_Data_3_3;
wire M_Ready_3_3;
wire M_Valid_3_3;
Conv_3_3 #(
    .COMPUTE_CHANNEL_IN_NUM   (COMPUTE_CHANNEL_IN_NUM),
    .COMPUTE_CHANNEL_OUT_NUM  (COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_FEATURE_SIZE       (WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM_REG    (WIDTH_CHANNEL_NUM_REG),
    .KERNEL_NUM               (KERNEL_NUM_33),
    .WIDTH_RAM_SIZE           (WIDTH_RAM_SIZE),
    .WIDTH_WEIGHT_NUM         (WIDTH_WEIGHT_NUM),
    .WIDTH_DATA_ADD           (WIDTH_DATA_ADD),
    .WIDTH_BIAS_RAM_ADDRA     (WIDTH_BIAS_RAM_ADDRA),
    .CONV_TYPE                (CONV_TYPE_33),
    .WIDTH_RAM_ADDR_SIZE      (WIDTH_RAM_ADDR_SIZE)
)
Conv_3_3
(
    . clk    (clk),
    . rst    (rst),
    . Control(Control_3_3),   // Control[3:0]
    . State  (State_3_3),
    . Reg_4  (Reg_4),
    . Reg_5  (Reg_5),
    . Reg_6  (Reg_6),
    . Reg_7  (Reg_7),
    .DMA_read_valid(PE0_DMA_read_Start),
    .DMA_write_valid(PE0_DMA_Write_Start),
    
    /////////////////////////////
    //Stream read
    .S_Data (M_Switch_Data[`AXI_WIDTH_DATA_IN-1:0]),
    .S_Valid(M_Conv_3_3_Valid),
    .S_Ready(S_Conv_3_3_Ready),
    /////////////////////////////////
    //Stream write
    .M_Data (M_Data_3_3),
    .M_Ready(M_Ready_3_3),
    .M_Valid(M_Valid_3_3),
    .Write_DDR_REG(Write_DDR_REG_1),
    .Read_DDR_REG(Read_DDR_REG_1),
    .Weight_Read_REG(Weight_Read_REG),
    .introut_3x3_Wr(introut_3x3_Wr),
    .Last_33(Last_33)
);

//------------------------       reshape  ----------------------
wire [`AXI_WIDTH_DATA_IN-1:0]   M_Data_RE;
wire M_Ready_RE;
wire M_Valid_RE;


reshape#( 
    .RE_WIDTH_FEATURE_SIZE(RE_WIDTH_FEATURE_SIZE),
    .RE_WIDTH_CHANNEL_NUM_REG(RE_WIDTH_CHANNEL_NUM_REG),
    .RE_WIDTH_WEIGHT_NUM(RE_WIDTH_WEIGHT_NUM),
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM),
    .RE_WIDTH_CONNECT_TIMES(RE_WIDTH_CONNECT_TIMES)
 )reshape(
    . clk(clk),
    . rst(rst),
    . Control_Reshape(Control_RE[3:0]),
    . Control_Concat(Control_RE[7:4]),
    . ReshapeState(State_RE),
    . Reg_4(Reg_4),
    . Reg_5(Reg_5),
    . Reg_6(Reg_6),
    . Reg_7(Reg_7),
    . Reg_8(Reg_8),
    . Reg_9(Reg_9),
    /////////////////////////////
    //DMA 
    .DMA_read_valid(PE3_DMA_read_Start),
    .DMA_write_valid(PE3_DMA_Write_Start),
    .DMA_read_valid_2(DMA_Read_Start_2),
    /////////////////////////////////
    //Stream read
//    .S_Data(M_Switch_Data[`PICTURE_NUM*`Channel_Out_Num*8*4-1:`PICTURE_NUM*`Channel_Out_Num*8*3]),
    .S_Data(M_Switch_Data[`AXI_WIDTH_DATA_IN*4-1:`AXI_WIDTH_DATA_IN*3]),
    .S_Valid(M_Conv_RE_Valid),      //  input M_Conv_RE_Valid
    .S_Ready(S_Conv_RE_Ready),     // output  S_Conv_RE_Ready
    
    .S_Data_1(S_Data_1),
    .S_Valid_1(S_Valid_1),
    .S_Ready_1(S_Ready_1),
    /////////////////////////////////
    //Stream write
    .M_Data (M_Data_RE),
    .M_Ready(M_Ready_RE),
    .M_Valid(M_Valid_RE),
    .Write_DDR_REG(Write_DDR_REG_2),
    .Read_DDR_REG(Read_DDR_REG_2),
    //DMA
    .inter_reshape(introut_3x3_Wr),
    .Last_Reshape(Last_Reshape)
    );
//-----------------------------Top_switch_end----------
wire [3:0]S_Switch_end_Valid;
wire [3:0]S_Switch_end_Ready;
wire [`AXI_WIDTH_DATA_IN*4-1:0]  S_Switch_end_Data;
wire  switch_valid;

assign M_Ready_3_3 = S_Switch_end_Ready[0];
//assign M_Ready_1_1 = S_Switch_end_Ready[1];
assign M_Ready_RE = S_Switch_end_Ready[3];
assign S_Switch_end_Valid = {M_Valid_RE,{1'b0},{1'b0},M_Valid_3_3};
assign S_Switch_end_Data = {M_Data_RE,{`AXI_WIDTH_DATA_IN{1'b0}},{`AXI_WIDTH_DATA_IN{1'b0}},M_Data_3_3};
    Top_switch_end Top_switch_end (
      .aclk(clk),                      // input wire aclk
      .aresetn(!rst),                // input wire aresetn
      .s_axis_tvalid(S_Switch_end_Valid),    // input wire [3 : 0] s_axis_tvalid
      .s_axis_tready(S_Switch_end_Ready),    // output wire [3 : 0] s_axis_tready
      .s_axis_tdata(S_Switch_end_Data),      // input wire [511 : 0] s_axis_tdata
      .m_axis_tvalid(switch_valid),    // output wire [0 : 0] m_axis_tvalid
      .m_axis_tready(M_Ready),    // input wire [0 : 0] m_axis_tready
      .m_axis_tdata(M_Data),      // output wire [127 : 0] m_axis_tdata
      .s_req_suppress(Switch1),  // input wire [3 : 0] s_req_suppress
      .s_decode_err()      // output wire [3 : 0] s_decode_err
    ); 
    assign  M_Valid = switch_valid&M_Ready; 
endmodule
