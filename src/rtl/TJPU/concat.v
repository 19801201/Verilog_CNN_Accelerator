`timescale 1ns / 1ps
`include"../Para.v"



module concat#(parameter 
    RE_WIDTH_FEATURE_SIZE = 11,
    RE_WIDTH_CHANNEL_NUM_REG= 10,
    RE_WIDTH_WEIGHT_NUM = 16,
    RE_CHANNEL_IN_NUM=16,
    RE_WIDTH_CONNECT_TIMES=15
 )(
    input clk,
    input rst,
    input Next_Reg,
    input Start_Concat,
    output Write_Block_Complete,
//    output  Connect_Complete,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,
    input [31:0] Reg_8,
    input [31:0] Reg_9,
    output Write_DDR_REG,
    output Read_DDR_REG,
    /////////////////////////////

    //Stream read
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data_1,
    input  S_Valid_1,
    output S_Ready_1,
    
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data_2,
    input  S_Valid_2,
    output S_Ready_2,
    /////////////////////////////////
    //Stream write
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    input  M_Ready,
    output M_Valid,
    //DMA

    output  Last_Concat
    );


 //===================reshape_instruction=============
wire [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG;
wire [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_RAM_Num_REG;
wire [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG;
wire [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG;
//wire [RE_WIDTH_WEIGHT_NUM-1:0] Ram_Write_Addra_Base;
//wire [RE_WIDTH_WEIGHT_NUM-1:0] Ram_Write_Num;
wire [31:0]	Concat1_ZeroPoint;
wire [31:0]	Concat2_ZeroPoint;
wire [31:0]	Concat1_Scale;
wire [31:0]	Concat2_Scale;
reshape_instruction#(
    .RE_WIDTH_FEATURE_SIZE(RE_WIDTH_FEATURE_SIZE),
    .RE_WIDTH_CHANNEL_NUM_REG(RE_WIDTH_CHANNEL_NUM_REG),
    .RE_WIDTH_WEIGHT_NUM(RE_WIDTH_WEIGHT_NUM)
)
reshape_instruction
(
    .clk(clk),
    .rst(rst),
    .Start (Start_Concat),
    .Reg_4(Reg_4),
    .Reg_5(Reg_5),
    .Reg_6(Reg_6),
    .Reg_7(Reg_7),
    .Reg_8(Reg_8),
    .Reg_9(Reg_9),
    .Write_DDR_REG(Write_DDR_REG),
    .Read_DDR_REG(Read_DDR_REG),
    
    .Row_Num_In_REG(Row_Num_In_REG),
    .Channel_RAM_Num_REG(Channel_RAM_Num_REG),
    .Row_Num_Out_REG(Row_Num_Out_REG),
    .Channel_In_Num_REG(Channel_In_Num_REG),
//    .Ram_Write_Addra_Base(Ram_Write_Addra_Base),
//    .Ram_Write_Num(Ram_Write_Num),
    .Concat1_ZeroPoint(Concat1_ZeroPoint),
    .Concat2_ZeroPoint(Concat2_ZeroPoint),
    .Concat1_Scale(Concat1_Scale),
    .Concat2_Scale(Concat2_Scale)  
    );

 //=================connect==================
 connect_final  #(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM),
    .RE_WIDTH_WEIGHT_NUM (RE_WIDTH_WEIGHT_NUM),
    .RE_WIDTH_FEATURE_SIZE(RE_WIDTH_FEATURE_SIZE),
    .RE_WIDTH_CHANNEL_NUM_REG(RE_WIDTH_CHANNEL_NUM_REG),
    .RE_WIDTH_CONNECT_TIMES(RE_WIDTH_CONNECT_TIMES)
    )
 connect_final
    (
    .   clk(clk),
    .   rst(rst),
    .   Next_Reg(Next_Reg),
    .   Start(Start_Concat),
    .   Row_Num_Out_REG(Row_Num_Out_REG),
    .   Channel_Ram_Part(Channel_RAM_Num_REG),
    .   Channel_Direct_Part(Channel_In_Num_REG),
    .   Row_Num_In_REG(Row_Num_In_REG),
//    .   Connect_Complete(Connect_Complete),
    //Stream read
    .   S_Data_1(S_Data_1),
    .   S_Valid_1(S_Valid_1),
    .   S_Ready_1(S_Ready_1),
    .   S_Data_2(S_Data_2),
    .   S_Valid_2(S_Valid_2),
    .   S_Ready_2(S_Ready_2),
    
//    .   Ram_Addrb(Ram_Addrb),
//    .   Ram_Data_In (Ram_Data_Out) , //ram_data,
    
    .   Concat1_ZeroPoint(Concat1_ZeroPoint), 	
    .   Concat2_ZeroPoint(Concat2_ZeroPoint),
    .   Concat1_Scale(Concat1_Scale),     
    .   Concat2_Scale(Concat2_Scale),    

    .   M_Valid(M_Valid),
    .   M_Ready(M_Ready),
    .   M_Data(M_Data),
    .   Last_Concat(Last_Concat)
    );   
 
endmodule
