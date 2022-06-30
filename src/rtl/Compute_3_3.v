`timescale 1ns / 1ps

`include"../Para.v"
module Compute_3_3#(parameter 
    COMPUTE_CHANNEL_IN_NUM    =  16,
    COMPUTE_CHANNEL_OUT_NUM   =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,
    KERNEL_NUM                =  9,
    WIDTH_RAM_SIZE            =  12,//feature
    WIDTH_WEIGHT_NUM          =  15,
    WIDTH_DATA_ADD            =  32,
    WIDTH_BIAS_RAM_ADDRA      =   8, 
    CONV_TYPE                 = "CONV_3_3", 
    WIDTH_RAM_ADDR_SIZE       =  13       

)(
    input clk,
    input rst,
    input Next_Reg,
    output Conv_Complete,
    output Stride_Complete,
    output Write_Block_Complete,
    input [3:0] Sign ,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,

    /////////////////////////////
    //     Feature  Data
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data,
    input   S_Valid,
    output  S_Ready,
    /////////////////////////////////
    //       Para   Data
    input  [`AXI_WIDTH_DATA_IN-1:0]   S_Para_Data,
    input   S_Para_Valid,
    output  S_Para_Ready,
    //Stream write
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    input  M_Ready,
    output M_Valid,

    output Stride_REG,
    output Write_DDR_REG,
    output Read_DDR_REG,
    input   Start_Pa,
    input   Start_Cu,
    output  Last_33
    );


//localparam Num  = 256;
reg [63:0] Para_Instruction;
reg [127:0]Cu_Instruction;
wire EN_Cin_Select_REG;
wire Padding_REG;   
//wire Stride_REG;
wire [2:0] Zero_Num_REG; 
wire [WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG;
wire [`WIDTH_DATA-1:0]         Zero_Point_REG1;
wire [`WIDTH_DATA-1:0]         Zero_Point_REG3;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG;
wire [WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Channel_Out_Num_REG;

wire [WIDTH_CHANNEL_NUM_REG-1:0] Weight_Channel_In_REG;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Weight_Channel_Out_REG;

//wire [WIDTH_WEIGHT_NUM-1:0] Weight_Addr_REG;
wire [WIDTH_WEIGHT_NUM-1:0] Weight_Num_REG;  
wire [WIDTH_BIAS_RAM_ADDRA-1: 0] Bias_Num_REG;

wire CONV_11_REG;
wire CONV_11_Parallel;
wire Leaky_REG;

wire S_Ready_33,S_Ready_11;

///////////////        Conv   REG7 
assign Zero_Point_REG1    =Cu_Instruction [127:120];  // 8
assign Zero_Point_REG3    =Cu_Instruction [119:112];  // 8
assign Write_DDR_REG      =Cu_Instruction [97:97];    // 1
assign Read_DDR_REG       =Cu_Instruction [96:96];    // 1
////////////////////   Conv   REG6 

////////////////////   Conv   REG5 
assign EN_Cin_Select_REG  =Cu_Instruction  [63:63];   // 1 
assign Padding_REG        =Cu_Instruction  [62:62];   // 1 
assign Stride_REG         =Cu_Instruction  [61:61];   // 1 
assign Zero_Num_REG       =Cu_Instruction  [60:58];   // 3 
assign Leaky_REG          =Cu_Instruction  [57:57];   // 1
assign Row_Num_In_REG     =Cu_Instruction  [42:32];   // 11    

////////////////////   Conv   REG4 
assign Channel_In_Num_REG =Cu_Instruction  [31:22];  // 10 
assign Row_Num_Out_REG    =Cu_Instruction  [21:11];  // 11      
assign Channel_Out_Num_REG=Cu_Instruction  [9 :0 ];  // 10


//////////////////////     Para     REG4  
assign Weight_Num_REG    = Para_Instruction[63:48];  // 16
assign Bias_Num_REG      = Para_Instruction[47:40];  // 8
assign CONV_11_Parallel  = Para_Instruction[33:33];  // 1
assign CONV_11_REG       = Para_Instruction[32:32];  // 1

/////////////////////      Para    REG5          
assign Weight_Channel_In_REG =Para_Instruction  [31:22];      // 10
assign Weight_Channel_Out_REG=Para_Instruction  [9 :0 ];      // 10 
////////////////////////////////////////////////////////////////

wire [`WIDTH_DATA*`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`CONV_3_3-1:0] M_TTN_Data;
wire [`WIDTH_DATA*`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`CONV_3_3-1:0] M_TTN_Data_33;
wire [`WIDTH_DATA*`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`CONV_3_3-1:0] M_TTN_Data_11;

wire [`CONV_3_3-1:0] M_TTN_Valid;
wire [`CONV_3_3-1:0] M_TTN_Valid_33;
wire [`CONV_3_3-1:0] M_TTN_Valid_11;
wire M_Conv_Norm_Ready;
//wire [WIDTH_FEATURE_SIZE-1 :0]RowNum_After_Padding;
reg [63:0] Para_Instruction_reg;
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
//----------------------Data_Generate----------------
Data_Generate #(
    .CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM),          //  8,
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE),  //  12,
    .WIDTH_CHANNEL_NUM(WIDTH_CHANNEL_NUM_REG),    //  10, 
    .WIDTH_RAM_SIZE(WIDTH_RAM_SIZE),          //  12,
    .CONV("CONV_3_3")                        //  
)Data_Generate_3x3(
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    .Start(Start_Cu),
    .S_Feature(S_Data),
    .S_Valid(S_Valid),
    .S_Ready(S_Ready_33),
    .Row_Num_In_REG(Row_Num_In_REG),
    .Padding_REG(Padding_REG),
    .Zero_Point_REG(Zero_Point_REG1),
    .Zero_Num_REG(Zero_Num_REG),
    .Channel_In_Num_REG(Channel_In_Num_REG),
    .EN_Cin_Select_REG(EN_Cin_Select_REG),
    .M_Feature(M_TTN_Data_33),
    .M_Valid(M_TTN_Valid_33), 
    .M_Ready(M_Conv_Norm_Ready)
);

Data_Convert#(
    .KERNEL_NUM                (KERNEL_NUM),
    .CHANNEL_IN_NUM            (COMPUTE_CHANNEL_IN_NUM),
    .WIDTH_FEATURE_SIZE        (WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM         (WIDTH_CHANNEL_NUM_REG)
)Data_Convert_1x1(
    .clk                     (clk),
    .rst                     (rst),
    .Next_Reg                (Next_Reg),
    .Start                   (Start_Cu),
    .S_Feature               (S_Data),
    .S_Valid                 (S_Valid),
    .S_Ready                 (S_Ready_11),
    .Row_Num_In_REG          (Row_Num_In_REG),
    .CONV_11_Parallel        (CONV_11_Parallel),
    .M_Feature               (M_TTN_Data_11),
    .M_Valid                 (M_TTN_Valid_11),
    .Channel_In_Num_REG      (Channel_In_Num_REG),
    .M_Ready                 (M_Conv_Norm_Ready)
    );

assign S_Ready = (CONV_11_REG) ? S_Ready_11 : S_Ready_33;
assign M_TTN_Data = (CONV_11_REG) ? M_TTN_Data_11 : M_TTN_Data_33;
assign M_TTN_Valid = (CONV_11_REG) ? M_TTN_Valid_11 : M_TTN_Valid_33;


wire [`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*WIDTH_DATA_ADD-1:0] M_Conv_Data;
wire M_Conv_Valid;
wire M_Conv_Ready;

wire [`PICTURE_NUM*`Channel_Out_Num*8-1:0]   M_Quan_Data;
wire M_Quan_Valid;
wire S_Stride_Ready;

wire  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Addrb;
wire  [32*`Channel_Out_Num-1:0] Data_Out_Bias;
wire  [32*`Channel_Out_Num-1:0] Data_Out_Scale;
wire  [32*`Channel_Out_Num-1:0] Data_Out_Shift;

Conv_Norm#(
    .KERNEL_NUM(KERNEL_NUM),//                  =       1,
    .CONV_TYPE("CONV_3_3") ,//                  
    .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM),//       =       16,
    .COMPUTE_CHANNEL_OUT_NUM(COMPUTE_CHANNEL_OUT_NUM) ,//     =       8,
    .WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE),//          =       14,
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE) ,//          =       12,
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG), //           =       10
    .WIDTH_DATA_ADD          (WIDTH_DATA_ADD),
    .WIDTH_WEIGHT_NUM        (WIDTH_WEIGHT_NUM),
    .WIDTH_BIAS_RAM_ADDRA    (WIDTH_BIAS_RAM_ADDRA)
                             
)
Conv_Norm
(
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    .Start_Cu(Start_Cu),
    .Start_Pa(Start_Pa),
    //  para  data
    .S_Para_Data(S_Para_Data),
    .S_Para_Valid(S_Para_Valid),
    .S_Para_Ready(S_Para_Ready),
    .Weight_Channel_In_REG(Weight_Channel_In_REG),
    .Weight_Channel_Out_REG(Weight_Channel_Out_REG),
    .CONV_11_REG(CONV_11_REG),
    .CONV_11_Parallel(CONV_11_Parallel),
    //////
    .Write_Block_Complete(Write_Block_Complete),
    .Compute_Complete(Conv_Complete),
    //  fature  data
    .S_Data(M_TTN_Data),
    .S_Valid(M_TTN_Valid),
    .S_Ready(M_Conv_Norm_Ready),


    .M_Data_out(M_Conv_Data),
    .M_ready(M_Conv_Ready),
    .M_Valid(M_Conv_Valid),
    

    .Row_Num_Out_REG(Row_Num_Out_REG),
    .Channel_In_Num_REG(Channel_In_Num_REG),
    .Channel_Out_Num_REG(Channel_Out_Num_REG),
    
    .Weight_Single_Num_REG(Weight_Num_REG),
    .Bias_Num_REG(Bias_Num_REG),
    .Bias_Addrb(Bias_Addrb),  
    .Data_Out_Bias(Data_Out_Bias),  //bias
    .Data_Out_Scale(Data_Out_Scale),  //scale
    .Data_Out_Shift(Data_Out_Shift)  //shift
);
Conv_quan#(
    .CHANNEL_OUT_NUM      (COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_FEATURE_SIZE   (WIDTH_FEATURE_SIZE),
    .WIDTH_DATA_ADD       (WIDTH_DATA_ADD),
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG),
    .WIDTH_BIAS_RAM_ADDRA (WIDTH_BIAS_RAM_ADDRA)
)Conv_quan(
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    .Start(Start_Cu),
    .S_Data (M_Conv_Data ),
    .S_Valid(M_Conv_Valid),
    .S_Ready(M_Conv_Ready),

    .bias_data_in   (Data_Out_Bias ),
    .scale_data_in  (Data_Out_Scale),
    .shift_data_in  (Data_Out_Shift),
    .Zero_Point_REG3(Zero_Point_REG3),
    .bias_addrb     (Bias_Addrb),
    .Leaky_REG          (Leaky_REG),
    
    .M_Data (M_Quan_Data ),
    .M_Ready(S_Stride_Ready),
    .M_Valid(M_Quan_Valid),
    
    .Row_Num_Out_REG    (Row_Num_Out_REG    ),
    .Channel_Out_Num_REG(Channel_Out_Num_REG)
    );

Stride#(
    .CHANNEL_OUT_NUM(COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG),
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE)
)
Stride_3_3(
    .clk         (clk),
    .rst         (rst),
    .Next_Reg     (Next_Reg),
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
    .Last       (Last_33)
);

endmodule