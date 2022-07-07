`timescale 1ns / 1ps

`include"./Para.v"
module reshape_instruction#(parameter 
    RE_WIDTH_FEATURE_SIZE = 11,
    RE_WIDTH_CHANNEL_NUM_REG= 10,
    RE_WIDTH_WEIGHT_NUM =16
)
(
     input clk,
    input rst,
    input Start ,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,
    input [31:0] Reg_8,
    input [31:0] Reg_9,
    output Write_DDR_REG,
    output Read_DDR_REG,
    
    output  [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG,
    output  [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_RAM_Num_REG,
    output  [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG, 
    output  [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG,

    output	[31:0]      			  Concat1_ZeroPoint,
    output	[31:0]      			  Concat2_ZeroPoint,
    output	[31:0]					  Concat1_Scale,
    output	[31:0]					  Concat2_Scale
    );
//localparam Num  = 256;
//reg [63:0] Para_Instruction;
reg [191:0] Re_Instruction;

////////////////           Reg 4        /////////////////////////
assign Channel_In_Num_REG      = Re_Instruction [31:22];
assign Write_DDR_REG           = Re_Instruction [1:1];
assign Read_DDR_REG            = Re_Instruction [0:0];
////////////////////////   Reg 5   ///////////////////////////////////
assign Row_Num_In_REG          = Re_Instruction  [63:53];
assign Channel_RAM_Num_REG     = Re_Instruction  [52:43];
assign Row_Num_Out_REG         = Re_Instruction  [42:32];


////////////////////     Reg 6      /////////////////////
assign	Concat1_Scale  		   = Re_Instruction  [95:64];         //  32 bit   para   scale
////////////////////////////////////////////////////////////////

///////////////////     Reg 7         ///////////////////
assign	Concat2_Scale		   = Re_Instruction  [127:96];        //  32 bit   direct  scale

////////////////////    Reg  8  ///////////////////////////////
assign	Concat1_ZeroPoint      = Re_Instruction  [159:128];          //  32 bit   para  zero point

////////////////////    Reg  9  //////////////////////////////////
assign	Concat2_ZeroPoint      = Re_Instruction  [191:160];         //  32 bit   data  zero point


always@(posedge clk )begin
    if(Start==1'b1) begin
       Re_Instruction <={Reg_9,Reg_8,Reg_7,Reg_6,Reg_5,Reg_4}; 
    end 
    else begin
       Re_Instruction <= Re_Instruction;
//       {Re_Instruction,Para_Instruction} <= {Re_Instruction,Para_Instruction} ;
    end
end


endmodule
