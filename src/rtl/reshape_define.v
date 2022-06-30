`timescale 1ns / 1ps



module reshape_define  #(parameter 
    RE_WIDTH_FEATURE_SIZE = 11,
    RE_WIDTH_CHANNEL_NUM_REG = 10
)(
    input clk,
    input rst,
    input [2:0]  Sign ,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,
    output Write_DDR_REG,
    output Read_DDR_REG,
    
//    output  [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG,
    output  [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG,
    output  [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG
  );
  
reg [127:0] Re_Instruction;

///////////////////////////   Reg 4   ///////////////////////////////////
assign Write_DDR_REG           = Re_Instruction [1:1];
assign Read_DDR_REG            = Re_Instruction [0:0];

///////////////////////////   Reg 7   ///////////////////////////////////
//assign Row_Num_In_REG          = Re_Instruction  [63:53];       //  11 bit   split,maxpool,upsample 
assign Channel_In_Num_REG      = Re_Instruction [116:107];       // 10 bit Input feature map channel
assign Row_Num_Out_REG         = Re_Instruction [106:96];        // 11 bit Input feature map width and height

always@(posedge clk )begin
	case (Sign)
		4'b001:
			Re_Instruction <={Reg_7,Reg_6,Reg_5,Reg_4};           // split
		4'b010:
			Re_Instruction <={Reg_7,Reg_6,Reg_5,Reg_4};            // maxpooling
		4'b100:
			Re_Instruction <={Reg_7,Reg_6,Reg_5,Reg_4};               // upsample
		default:
			Re_Instruction <= Re_Instruction;
	endcase   
end  
  
endmodule