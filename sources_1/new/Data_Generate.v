`timescale 1ns / 1ps

`include"./Para.v"
module Data_Generate#(parameter
    KERNEL_NUM                =  9,//     
    CHANNEL_IN_NUM            =  16,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM         =  10, 
    WIDTH_RAM_SIZE            =  12,//feature 
    CONV                      =  "CONV_3_3" 
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start,
    input  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] S_Feature,//4x4x8=128  fifo
    input  S_Valid,
    output S_Ready,
    input  [WIDTH_FEATURE_SIZE-1 :0]Row_Num_In_REG,
    input  Padding_REG,
    input  [`WIDTH_DATA-1:0] Zero_Point_REG,
    input  [2:0] Zero_Num_REG,
    output [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*KERNEL_NUM-1:0] M_Feature,
    output [KERNEL_NUM-1:0]M_Valid,
    input  [WIDTH_CHANNEL_NUM-1'b1  :0]Channel_In_Num_REG,  
    input  EN_Cin_Select_REG, 
    input  M_Ready
    );
    wire S_FTT_Ready;
    wire Start_Row;
    wire [WIDTH_RAM_SIZE-1:0]TTN_Addr;
    wire S_TTN_Ready;
    wire  M_Write_EN;
    wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] M_Padding_Data;
    wire [WIDTH_FEATURE_SIZE-1:0] Row_Num_After_Padding;
    wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*3-1:0] M_FTT_Data;
   
generate
    case (CONV)
        "CONV_3_3": begin
        
wire  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] M_Feature_2_Padding; 
wire  M_Ready_2_Padding;
wire  M_Valid_2_Padding;     
Cin_Convert # (
    .CHANNEL_IN_NUM(CHANNEL_IN_NUM)
)Cin_Convert(
    .clk(clk),
    .S_Ready(S_Ready),
    .S_Feature(S_Feature),
    .S_Valid(S_Valid),
    .M_Ready(M_Ready_2_Padding),
    .M_Feature(M_Feature_2_Padding),
    .M_Valid(M_Valid_2_Padding),
    .EN_Cin_Select_REG(EN_Cin_Select_REG)
    ); 

padding # (
    .CHANNEL_IN_NUM(CHANNEL_IN_NUM) ,
    .WIDTH_FEATURE_SIZE (WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM(WIDTH_CHANNEL_NUM) 
)padding(
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    .Start(Start),
    .S_Feature(M_Feature_2_Padding),//4x8x8=256  fifo
    .S_Valid(M_Valid_2_Padding),
    .S_Ready(M_Ready_2_Padding),
    .Row_Num_In_REG(Row_Num_In_REG),
    .Channel_In_Num_REG(Channel_In_Num_REG),
    .Padding_REG(Padding_REG),        //1
    .Zero_Point_REG(Zero_Point_REG),
    .Zero_Num_REG(Zero_Num_REG),
    .M_Ready(S_FTT_Ready),
    .M_Data(M_Padding_Data),
    .M_Write_EN(M_Write_EN),
    .Row_Num_After_Padding(Row_Num_After_Padding)
    );

four2three #(
    .CHANNEL_IN_NUM(CHANNEL_IN_NUM) ,
    .WIDTH_RAM_SIZE(WIDTH_RAM_SIZE),
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM(WIDTH_CHANNEL_NUM)
)four2three(   
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    .Start(Start),
    .Start_Row(Start_Row),
    .Row_Num_After_Padding(Row_Num_After_Padding),
    .S_Data(M_Padding_Data),
    .S_Valid(M_Write_EN),
    .S_Ready(S_FTT_Ready),
    .Channel_In_Num_REG(Channel_In_Num_REG),
    .M_Ready(S_TTN_Ready),
    .M_Data(M_FTT_Data),
    .M_Addr(TTN_Addr)
    );

three2nine # (
    .CHANNEL_IN_NUM (CHANNEL_IN_NUM),
    .WIDTH_RAM_SIZE(WIDTH_RAM_SIZE),
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM(WIDTH_CHANNEL_NUM) 
)three2nine(
    .clk(clk),
    .rst(rst),
    .Start(Start),
    .S_Feature(M_FTT_Data),
    .Addr(TTN_Addr),
    .Row_Num_After_Padding(Row_Num_After_Padding), 
    .Channel_In_Num_REG(Channel_In_Num_REG),
    .Row_Compute_Sign(Start_Row),
    .M_Data(M_Feature),
    .M_Ready(M_Ready),
    .M_EN_Write(M_Valid),
    .S_Ready(S_TTN_Ready)
    );
end
         "CONV_1_1": begin
//               assign  M_Feature= S_Feature;
//               assign  M_Valid  = S_Valid;
//               assign  S_Ready   =M_Ready;

end
    endcase
endgenerate 


endmodule   
