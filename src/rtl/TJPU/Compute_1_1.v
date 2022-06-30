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
reg [63:0] Para_Instruction;//��
reg [127:0]Cu_Instruction;
//�����Reg�б�
//��������
//wire EN_Cin_Select_REG;                         //************
//wire Padding_REG;   //�Ƿ�����     ***********
wire Stride_REG;
//wire [2:0] Zero_Num_REG;     //�����Ȧ��???//3x3 2 5x5.   ***********
wire Leaky_REG;
wire [WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG;// ����ͼƬ�ĳߴ磨416��
//wire [`WIDTH_DATA-1:0]         Zero_Point_REG1;     //************
wire [`WIDTH_DATA-1:0]         Zero_Point_REG3;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG;
wire [WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG;
wire [WIDTH_CHANNEL_NUM_REG-1:0] Channel_Out_Num_REG;
wire [WIDTH_WEIGHT_NUM-1:0] Weight_Addr_REG;
wire [WIDTH_WEIGHT_NUM-1:0] Weight_Num_REG;  
wire [WIDTH_BIAS_RAM_ADDRA-1: 0] Bias_Num_REG;

wire [31:0] Temp_REG;

///////////////        Conv  �� REG7 �Ĳ���                ///////////////////////// 
//assign Zero_Point_REG1    =Cu_Instruction [127:120];     // 8λ Padding  ����0��ֵ (��Z1��Ϊ0������0��ֵ����Z1)
assign Zero_Point_REG3    =Cu_Instruction [119:112];     // 8λ Z3 ��ֵ
//assign Weight_Num_REG     =Cu_Instruction  [111:96];    // 16λ  ,  1������������ͨ����������

////////////////////   Conv  �� REG6 �Ĳ���          /////////////////////////////
//assign Weight_Addr_REG    =Cu_Instruction  [95:80];  //  16λ Load_Weight ��˫��RAM��Ȩ�صĶ�����ַ
//assign Bias_Num_REG       ={Cu_Instruction [71],Cu_Instruction [79:72]};    //9λ Bias �� coe  �е�����
//assign Bias_Num_REG       =Cu_Instruction  [79:72];    //8λ Bias �� coe  �е�����
assign Temp_REG           =Cu_Instruction  [95:64];
////////////////////   Conv  �� REG5 �Ĳ���          /////////////////////////////
assign EN_Cin_Select_REG  =Cu_Instruction  [63:63];   //1λ  �Ƿ���Ҫͨ����0 (�����̲��ã�������ά����RGB��ͨ��������Ҫͨ����0)
assign Padding_REG        =Cu_Instruction  [62:62];   //1λ  �Ƿ���Ҫ padding ���ź�
assign Stride_REG         =Cu_Instruction  [61:61];   // 1 λ  �Ƿ���Ҫ  stride  ���ź�
assign Zero_Num_REG       =Cu_Instruction  [60:58];   // 3 λ   padding �����Ȧ��  (��� 5*5 �������Ƶ�) ��������Ϊ1
assign Leaky_REG          =Cu_Instruction  [57:57];    // 1λ   �Ƿ���Ҫ leakyrelu �� 1 Ϊ���ã�0 Ϊ��
assign Row_Num_In_REG     =Cu_Instruction  [42:32];   // 11λ  ͼƬ����Ŀ����

////////////////////   Conv  �� REG4 �Ĳ���          /////////////////////////////
assign Channel_In_Num_REG =Cu_Instruction  [31:22];   // 10 λ��ͼƬ����ͨ����
assign Row_Num_Out_REG    =Cu_Instruction  [21:11];    // 11λ  ����������ͼƬ�����
assign Channel_Out_Num_REG=Cu_Instruction  [9 :0 ];   // 10 λ��ͼƬ���ͨ����

//////////////////////     Para   �е�  REG4  ����      ///////////////////////
//assign Ram_Write_Num       =Para_Instruction[63:48];    //  16λ weight coe �ļ��е�������
//assign Ram_Write_Addra_Base=Para_Instruction[47:32];     // 16 λ  Load_Weight ģ����д˫��RAM��д����ַ

assign Weight_Num_REG     = Para_Instruction[63:48];         // 16λ  ,  1������������ͨ����������
assign Bias_Num_REG       = {Para_Instruction[39],Para_Instruction[47:40]};          //  9λ   Bias �� coe  �е�����
/////////////////////      Para  ��  REG5 ��Ϊ0  (0-31bit)                                      
////////////////////////////////////////////////////////////////
//Data_Generate�ӿ�
//wire [`WIDTH_DATA*`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`CONV_3_3-1:0] M_TTN_Data;
//wire [`CONV_3_3-1:0] M_TTN_Valid;
//wire M_Conv_Norm_Ready;
//wire [WIDTH_FEATURE_SIZE-1 :0]RowNum_After_Padding;
reg [63:0] Para_Instruction_reg;//��
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

//-------------------����------------------
wire [`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*WIDTH_DATA_ADD-1:0] M_Conv_Data;
wire M_Conv_Valid;
wire M_Conv_Ready;
//------------------------����stride---------------------
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
//    .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM),//       =       8,//֧��8��4��2��1
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
    .Start_Cu(Start_Cu),// ��ʼ�������
    .Start_Pa(Start_Pa),  // ��ʼ���ز�������
    //  para  data
    .S_Para_Data(S_Para_Data),
    .S_Para_Valid(S_Para_Valid),
    .S_Para_Ready(S_Para_Ready),
    
//    .Bram_Data_In_One(Bram_Data_In_One),
//    .Bram_Data_In_Two(Bram_Data_In_Two),
//    .Bram_Data_In_Three(Bram_Data_In_Three),
//    .Bram_Data_In_Four(Bram_Data_In_Four),
    
//    .Bram_Addrb(Bram_Addrb),
    .Write_Block_Complete(Write_Block_Complete),   //  ���ز�����ɱ�־
    .Compute_Complete(Conv_Complete),//����ļ�������ź�
    //�Դ�fifo����
    .S_Data(S_Data),//����ͼƬ��*һ�μ���C_in*�������???*λ��
    .S_Valid(S_Valid),//дʹ�� 1*1��ʱ��ǰ��λ����
    .S_Ready(S_Ready_C),//��дһ��

    //�¸�fifo
    .M_Data_out(M_Conv_Data),
    .M_ready(M_Conv_Ready),
    .M_Valid(M_Conv_Valid),
    
    //����
    .Row_Num_Out_REG(Row_Num_Out_REG),      //feature�Ĵ�С��Padding��ģ�???
//    .RowNum_After_Padding(RowNum_After_Padding),
    .Channel_In_Num_REG(Channel_In_Num_REG),//����ͨ����//reg  4/4  1
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
    //bias_fifo����
    .S_Data             (M_Conv_Data ),//1024 8ͨ������ͼ32λ
    .S_Valid            (M_Conv_Valid),
    .S_Ready            (M_Conv_Ready),//��дһ��
    .Leaky_REG          (Leaky_REG),
    .Temp_REG           (Temp_REG),

    .bias_data_in       (Data_Out_Bias ),
    .scale_data_in      (Data_Out_Scale),
    .shift_data_in      (Data_Out_Shift),
    .Zero_Point_REG3    (Zero_Point_REG3),
    .bias_addrb         (Bias_Addrb),
    //�¸�fifo
    .M_Data              (M_Quan_Data ),
    .M_Ready             (S_Stride_Ready),
    .M_Valid             (M_Quan_Valid),
    //����
    .Row_Num_Out_REG     (Row_Num_Out_REG    ),      //feature�Ĵ�С��Padding��ģ�???
    .Channel_Out_Num_REG (Channel_Out_Num_REG)//���ͨ����???//reg  16/1 16
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

