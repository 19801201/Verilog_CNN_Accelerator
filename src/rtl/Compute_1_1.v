`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/23 14:38:53
// Design Name: 
// Module Name: Compute_PW
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

`include"../Para.v"
module Compute_1_1  #(parameter 
    COMPUTE_CHANNEL_IN_NUM    =  8,
    COMPUTE_CHANNEL_OUT_NUM   =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,
    WIDTH_TEMP_RAM_ADDR_SIZE  =  12,
    KERNEL_NUM                =  1,
    WIDTH_WEIGHT_NUM          =  16,
    WIDTH_DATA_ADD            =  32,
    WIDTH_BIAS_RAM_ADDRA      =   9,
    WIDTH_RAM_ADDR_TURE       =  16,   
    CONV_TYPE                 = "CONV_1_1", 
    WIDTH_RAM_ADDR_SIZE       =  16       

)(
    input clk,
    input rst,
    input  Next_Reg,
    output Conv_Complete,
    output Stride_Complete,
    output Write_Block_Complete,
    input [3:0] Sign ,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,

    /////////////////////////////
    //Stream read
    input  [`AXI_WIDTH_DATA-1:0] S_Data,
    input   S_Valid,
    output  S_Ready_C,
    
    input  [`AXI_WIDTH_DATA-1:0]   S_Para_Data,
    input   S_Para_Valid,
    output  S_Para_Ready,
    /////////////////////////////////
    //Stream write
    output [`AXI_WIDTH_DATA-1:0] M_Data,
    input  M_Ready,
    output M_Valid,
    
//    input [`AXI_WIDTH_DATA -1  : 0] Bram_Data_In_One,
//    input [`AXI_WIDTH_DATA -1  : 0] Bram_Data_In_Two,
//    input [`AXI_WIDTH_DATA -1  : 0] Bram_Data_In_Three,
//    input [`AXI_WIDTH_DATA -1  : 0] Bram_Data_In_Four,
//    output[WIDTH_RAM_ADDR_TURE-1:0] Bram_Addrb,
//    output  [WIDTH_RAM_ADDR_TURE-1:0]    Ram_Write_Num,
//    output  [WIDTH_RAM_ADDR_TURE-1:0]    Ram_Write_Addra_Base,
    input  Start_Cu,
    input  Start_Pa,
    output Last_11
    );

localparam Num  = 256;
reg [63:0] Para_Instruction;//锟斤拷
reg [127:0]Cu_Instruction;
//锟斤拷锟斤拷锟絉eg锟叫憋拷
//锟斤拷锟斤拷锟斤拷锟斤拷
//wire EN_Cin_Select_REG;                         //************
//wire Padding_REG;   //锟角凤拷锟斤拷锟斤拷     ***********
wire Stride_REG;
//wire [2:0] Zero_Num_REG;     //锟斤拷锟斤拷锟饺︼拷锟???//3x3 2 5x5.   ***********
wire Leaky_REG;
wire [WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG;// 锟斤拷锟斤拷图片锟侥尺寸（416锟斤拷
//wire [`WIDTH_DATA-1:0]         Zero_Point_REG1;     //************
wire [`WIDTH_DATA-1:0]         Zero_Point_REG3;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG;
wire [WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Channel_Out_Num_REG;
wire [WIDTH_WEIGHT_NUM-1:0] Weight_Addr_REG;
wire [WIDTH_WEIGHT_NUM-1:0] Weight_Num_REG;  
wire [WIDTH_BIAS_RAM_ADDRA-1: 0] Bias_Num_REG;

wire [31:0] Temp_REG;

///////////////        Conv  中 REG7 的参数                ///////////////////////// 
//assign Zero_Point_REG1    =Cu_Instruction [127:120];     // 8位 Padding  中填0的值 (若Z1不为0，则填0的值就是Z1)
assign Zero_Point_REG3    =Cu_Instruction [119:112];     // 8位 Z3 的值
//assign Weight_Num_REG     =Cu_Instruction  [111:96];    // 16位  ,  1个卷积点的所有通道数的行数

////////////////////   Conv  中 REG6 的参数          /////////////////////////////
//assign Weight_Addr_REG    =Cu_Instruction  [95:80];  //  16位 Load_Weight 中双口RAM读权重的读基地址
//assign Bias_Num_REG       ={Cu_Instruction [71],Cu_Instruction [79:72]};    //9位 Bias 在 coe  中的行数
//assign Bias_Num_REG       =Cu_Instruction  [79:72];    //8位 Bias 在 coe  中的行数
assign Temp_REG           =Cu_Instruction  [95:64];
////////////////////   Conv  中 REG5 的参数          /////////////////////////////
assign EN_Cin_Select_REG  =Cu_Instruction  [63:63];   //1位  是否需要通道补0 (本工程不用，当输入维度是RGB三通道，则需要通道补0)
assign Padding_REG        =Cu_Instruction  [62:62];   //1位  是否需要 padding 的信号
assign Stride_REG         =Cu_Instruction  [61:61];   // 1 位  是否需要  stride  的信号
assign Zero_Num_REG       =Cu_Instruction  [60:58];   // 3 位   padding 添零的圈数  (针对 5*5 卷积而设计的) ，本工程为1
assign Leaky_REG          =Cu_Instruction  [57:57];    // 1位   是否需要 leakyrelu 。 1 为不用，0 为用
assign Row_Num_In_REG     =Cu_Instruction  [42:32];   // 11位  图片输入的宽高数

////////////////////   Conv  中 REG4 的参数          /////////////////////////////
assign Channel_In_Num_REG =Cu_Instruction  [31:22];   // 10 位，图片输入通道数
assign Row_Num_Out_REG    =Cu_Instruction  [21:11];    // 11位  卷积操作后的图片宽高数
assign Channel_Out_Num_REG=Cu_Instruction  [9 :0 ];   // 10 位，图片输出通道数

//////////////////////     Para   中的  REG4  参数      ///////////////////////
//assign Ram_Write_Num       =Para_Instruction[63:48];    //  16位 weight coe 文件中的总行数
//assign Ram_Write_Addra_Base=Para_Instruction[47:32];     // 16 位  Load_Weight 模块中写双口RAM的写基地址

assign Weight_Num_REG     = Para_Instruction[63:48];         // 16位  ,  1个卷积点的所有通道数的行数
assign Bias_Num_REG       = {Para_Instruction[39],Para_Instruction[47:40]};          //  9位   Bias 在 coe  中的行数
/////////////////////      Para  中  REG5 都为0  (0-31bit)                                      
////////////////////////////////////////////////////////////////
//Data_Generate锟接匡拷
//wire [`WIDTH_DATA*`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`CONV_3_3-1:0] M_TTN_Data;
//wire [`CONV_3_3-1:0] M_TTN_Valid;
//wire M_Conv_Norm_Ready;
//wire [WIDTH_FEATURE_SIZE-1 :0]RowNum_After_Padding;
reg [63:0] Para_Instruction_reg;//锟斤拷
reg [127:0]Cu_Instruction_reg;
always@(posedge clk )begin
     Cu_Instruction_reg <={Reg_7,Reg_6,Reg_5,Reg_4};
     Para_Instruction_reg<={Reg_4,Reg_5};    
end
always@(posedge clk )begin
    case(Sign)
        4'b0010: Cu_Instruction <=Cu_Instruction_reg;
        4'b0001: Para_Instruction<=Para_Instruction_reg;
        default: {Cu_Instruction,Para_Instruction} <= {Cu_Instruction,Para_Instruction} ;
    endcase
end

//-------------------锟斤拷锟斤拷------------------
wire [`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*WIDTH_DATA_ADD-1:0] M_Conv_Data;
wire M_Conv_Valid;
wire M_Conv_Ready;
//------------------------锟斤拷锟斤拷stride---------------------
wire [`AXI_WIDTH_DATA-1:0] M_Quan_Data;
wire M_Quan_Valid;
wire S_Stride_Ready;

wire  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Addrb;
wire  [32*8-1:0] Data_Out_Bias;
wire  [32*8-1:0] Data_Out_Scale;
wire  [32*8-1:0] Data_Out_Shift;

Conv_Norm_1_1  #(
    .KERNEL_NUM(KERNEL_NUM),//                  =       1,
    .CONV_TYPE("CONV_1_1") ,//                   =       "CONV_1_1",//CONV_3_3
//    .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM),//       =       8,//支锟斤拷8锟斤拷4锟斤拷2锟斤拷1
    .COMPUTE_CHANNEL_OUT_NUM(COMPUTE_CHANNEL_OUT_NUM) ,//     =       8,
    .WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE),//          =       14,
    .WIDTH_TEMP_RAM_ADDR_SIZE(WIDTH_TEMP_RAM_ADDR_SIZE),
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE) ,//          =       12,
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG), //           =       10
    .WIDTH_DATA_ADD          (WIDTH_DATA_ADD),
    .WIDTH_RAM_ADDR_TURE     (WIDTH_RAM_ADDR_TURE),
    .WIDTH_WEIGHT_NUM        (WIDTH_WEIGHT_NUM),
    .WIDTH_BIAS_RAM_ADDRA    (WIDTH_BIAS_RAM_ADDRA)
                             
)
Conv_Norm_1_1
(
    .clk(clk),
    .rst(rst),
    .Next_Reg    (Next_Reg),
    .Start_Cu(Start_Cu),// 开始卷积操作
    .Start_Pa(Start_Pa),  // 开始加载参数操作
    //  para  data
    .S_Para_Data(S_Para_Data),
    .S_Para_Valid(S_Para_Valid),
    .S_Para_Ready(S_Para_Ready),
    
//    .Bram_Data_In_One(Bram_Data_In_One),
//    .Bram_Data_In_Two(Bram_Data_In_Two),
//    .Bram_Data_In_Three(Bram_Data_In_Three),
//    .Bram_Data_In_Four(Bram_Data_In_Four),
    
//    .Bram_Addrb(Bram_Addrb),
    .Write_Block_Complete(Write_Block_Complete),   //  加载参数完成标志
    .Compute_Complete(Conv_Complete),//锟斤拷锟斤拷募锟斤拷锟斤拷锟斤拷锟脚猴拷
    //锟皆达拷fifo锟斤拷锟斤拷
    .S_Data(S_Data),//锟斤拷锟斤拷图片锟斤拷*一锟轿硷拷锟斤拷C_in*锟斤拷锟斤拷锟斤拷锟???*位锟斤拷
    .S_Valid(S_Valid),//写使锟斤拷 1*1锟斤拷时锟斤拷前锟斤拷位锟斤拷锟斤拷
    .S_Ready(S_Ready_C),//锟斤拷写一锟斤拷

    //锟铰革拷fifo
    .M_Data_out(M_Conv_Data),
    .M_ready(M_Conv_Ready),
    .M_Valid(M_Conv_Valid),
    
    //锟斤拷锟斤拷
    .Row_Num_Out_REG(Row_Num_Out_REG),      //feature锟侥达拷小锟斤拷Padding锟斤拷模锟???
//    .RowNum_After_Padding(RowNum_After_Padding),
    .Channel_In_Num_REG(Channel_In_Num_REG),//锟斤拷锟斤拷通锟斤拷锟斤拷//reg  4/4  1
    .Channel_Out_Num_REG(Channel_Out_Num_REG),
    
    .Weight_Single_Num_REG(Weight_Num_REG),
    .Bias_Num_REG(Bias_Num_REG),
//    .Ram_Read_Addrb_Base(Weight_Addr_REG),
    .Bias_Addrb(Bias_Addrb),  
    .Data_Out_Bias(Data_Out_Bias),  //bias
    .Data_Out_Scale(Data_Out_Scale),  //scale
    .Data_Out_Shift(Data_Out_Shift)  //shift
);
Conv_quan_11    #(
    .CHANNEL_OUT_NUM      (COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_FEATURE_SIZE   (WIDTH_FEATURE_SIZE),
    .WIDTH_DATA_ADD       (WIDTH_DATA_ADD),
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG),
    .WIDTH_BIAS_RAM_ADDRA (WIDTH_BIAS_RAM_ADDRA)
)Conv_quan_11  (
    .clk                (clk),
    .rst                (rst),
    .Next_Reg           (Next_Reg),
    .Start              (Start_Cu),
    //bias_fifo锟斤拷锟斤拷
    .S_Data             (M_Conv_Data ),//1024 8通锟斤拷锟斤拷锟斤拷图32位
    .S_Valid            (M_Conv_Valid),
    .S_Ready            (M_Conv_Ready),//锟斤拷写一锟斤拷
    .Leaky_REG          (Leaky_REG),
    .Temp_REG           (Temp_REG),

    .bias_data_in       (Data_Out_Bias ),
    .scale_data_in      (Data_Out_Scale),
    .shift_data_in      (Data_Out_Shift),
    .Zero_Point_REG3    (Zero_Point_REG3),
    .bias_addrb         (Bias_Addrb),
    //锟铰革拷fifo
    .M_Data              (M_Quan_Data ),
    .M_Ready             (S_Stride_Ready),
    .M_Valid             (M_Quan_Valid),
    //锟斤拷锟斤拷
    .Row_Num_Out_REG     (Row_Num_Out_REG    ),      //feature锟侥达拷小锟斤拷Padding锟斤拷模锟???
    .Channel_Out_Num_REG (Channel_Out_Num_REG)//锟斤拷锟酵拷锟斤拷锟???//reg  16/1 16
    );

Stride_1_1  #(
    .CHANNEL_OUT_NUM(COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG),
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE)
)
Stride_1_1(
    .clk         (clk),
    .rst         (rst),
    .Next_Reg    (Next_Reg),
    .Start       (Start_Cu),
    .EN_Stride_REG(Stride_REG), 
    .Valid_In     (M_Quan_Valid),
    .Channel_Out_Num_REG(Channel_Out_Num_REG),
    .Row_Num_Out_REG(Row_Num_Out_REG),
    .Feature      (M_Quan_Data),
    .M_Data      (M_Data),
    .M_Valid     (M_Valid),
    .S_Ready      (S_Stride_Ready),
    .M_Ready      (M_Ready),
    .Stride_Complete  (Stride_Complete),
    .Last          (Last_11)
);


endmodule

