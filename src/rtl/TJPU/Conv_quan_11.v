`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/02 17:57:03
// Design Name: 
// Module Name: Conv_quan
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
module Conv_quan_11    #(parameter
    CHANNEL_OUT_NUM           =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,
    WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
    WIDTH_BIAS_RAM_ADDRA      =   9
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start,
    //bias_fifo����
    input  [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]   S_Data,//1024 8ͨ������ͼ32λ
    input           S_Valid,
    output          S_Ready,//��дһ��
    input           Leaky_REG,
    input [31:0]     Temp_REG,

    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] bias_data_in,
    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] scale_data_in,
    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] shift_data_in,
    input [`WIDTH_DATA-1 : 0] Zero_Point_REG3,
    output[WIDTH_BIAS_RAM_ADDRA-1:0] bias_addrb,
    //�¸�fifo
    output [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0]   M_Data,
    input            M_Ready,
    output           M_Valid,
    //����
    input  [WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,      //feature�Ĵ�С��Padding��ģ�??
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_Out_Num_REG//���ͨ����??//reg  16/1 16
    );


wire  [WIDTH_FEATURE_SIZE-1:0] S_Count_Fifo;

//-----------------�ӳٲ���-----------------
//----������bias������scaleģ����Ҫ����ʱ������
reg [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] scale_data_in_temp[0:2];
always@(posedge clk)begin
scale_data_in_temp[0]<=scale_data_in;
end
always@(posedge clk)begin
scale_data_in_temp[1]<=scale_data_in_temp[0];
end
always@(posedge clk)begin
scale_data_in_temp[2]<=scale_data_in_temp[1];
end

//---���ݴ�scaleģ�������Ҫ����ʱ������??
reg [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] shift_data_in_temp[0:10];
always@(posedge clk)begin
shift_data_in_temp[0]<=shift_data_in;
end
generate 
genvar k;
for(k=0;k<10;k=k+1)begin
always@(posedge clk)begin
shift_data_in_temp[k+1]<=shift_data_in_temp[k];
end
end
endgenerate
//-----------------valid�ӳٲ���------------
//reg   M_Valid_Temp_Delay[0:14];         //   û�� leakyrelu 
reg M_Valid_Temp_Delay[0:31];            // ���� leakyrelu 0.1

wire M_Valid_Temp;
wire M_Valid_Zero;
wire M_Valid_Leaky;
always@(posedge clk )begin
M_Valid_Temp_Delay[0]<=M_Valid_Temp;
end
generate 
genvar m;
for(m=0;m<31;m=m+1)begin
always@(posedge clk)begin
M_Valid_Temp_Delay[m+1]<=M_Valid_Temp_Delay[m];
end
end
endgenerate
//assign M_Valid_Zero=M_Valid_Temp_Delay[14]; // ԭ�� 14
assign M_Valid_Zero=M_Valid_Temp_Delay[20]; // bias �� case + 1��scale �˷��� + 5
// leaky = 0.1
//assign M_Valid_Leaky=M_Valid_Temp_Delay[24];  //   ԭ�� 24
//assign M_Valid_Leaky=M_Valid_Temp_Delay[25];  // leaky���case    +1 = 25 
//assign M_Valid_Leaky=M_Valid_Temp_Delay[26];  // leaky���case �� bias���case  +2 = 26
assign M_Valid_Leaky=M_Valid_Temp_Delay[31];  // leaky���case �� bias���case  +2 = 26 ��  scale �˷��� + 5

// leaky = 0.125
//assign M_Valid_Leaky=M_Valid_Temp_Delay[21];  
//-----------------���ӱ���------------------
wire rd_en_fifo,fifo_ready;
wire [`PICTURE_NUM*WIDTH_DATA_ADD_TEMP*CHANNEL_OUT_NUM-1:0]bias_data_out;
wire [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]scale_data_out;
wire [`PICTURE_NUM*`WIDTH_DATA*2*CHANNEL_OUT_NUM -1:0]shift_data_out;
//-----------------��������ģ��---------------
wire   [`AXI_WIDTH_DATA-1:0]   M_Zero_Data;
wire   [`AXI_WIDTH_DATA-1:0]   M_Leaky_Data;

Conv_quan_control#(
           .CHANNEL_OUT_NUM      (CHANNEL_OUT_NUM), //=  8,
           .WIDTH_FEATURE_SIZE   (WIDTH_FEATURE_SIZE), //=  12,
           .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG), //=  10,
           .WIDTH_DATA_ADD       (WIDTH_DATA_ADD), //=  32,
           .WIDTH_BIAS_RAM_ADDRA (WIDTH_BIAS_RAM_ADDRA) //=   7
)Conv_quan_control
(  
    .clk(clk),
    .rst(rst),
    .Start(Start),
    .bias_addrb(bias_addrb),
    .EN_Rd_Fifo(rd_en_fifo),
    .Fifo_Ready(fifo_ready),
    .M_Ready(M_Ready),
    .M_Valid(M_Valid_Temp),
    //����
    .Row_Num_Out_REG(Row_Num_Out_REG),      //feature�Ĵ�С��Padding��ģ�??
    .Channel_Out_Num_REG(Channel_Out_Num_REG),//���ͨ����??//reg  16/1 16  
    .S_Count_Fifo(S_Count_Fifo)
    );
//-----------------����bias---------------
 Conv_Bias_11  #(
           .CHANNEL_OUT_NUM      (CHANNEL_OUT_NUM), //=  8,
           .WIDTH_FEATURE_SIZE   (WIDTH_FEATURE_SIZE), //=  12,
           .WIDTH_DATA_ADD       (WIDTH_DATA_ADD), //=  32,
           .WIDTH_DATA_ADD_TEMP  (WIDTH_DATA_ADD_TEMP), //= 48
           .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG)
)Conv_Bias_11(
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    //�Դ�fifo����
    .S_Data(S_Data),//1024 8ͨ������ͼ32λ
    .S_Valid(S_Valid),
    .S_Ready(S_Ready),//��дһ��
    .fifo_ready(fifo_ready),//�㹻һ��
    .rd_en_fifo(rd_en_fifo),

    .bias_data_in(bias_data_in),
    //�¸�fifo
    .M_Data(bias_data_out),
    .Channel_Out_Num_REG(Channel_Out_Num_REG),
    //����
    .Row_Num_Out_REG(Row_Num_Out_REG),     //feature�Ĵ�С��Padding��ģ�??
    .S_Count_Fifo(S_Count_Fifo)
    );
//------------------scale--------------------
Conv_Scale#(
           .CHANNEL_OUT_NUM      (CHANNEL_OUT_NUM), //=  8,
           .WIDTH_DATA_ADD       (WIDTH_DATA_ADD), //=  32,
           .WIDTH_DATA_ADD_TEMP  (WIDTH_DATA_ADD_TEMP) //= 48
)Conv_Scale(
           .clk(clk),
           .rst(rst),
           .S_Data(bias_data_out),//1024 8ͨ������ͼ32λ
           .Scale_Data_In(scale_data_in_temp[2]),
           .Scale_Data_Out(scale_data_out)
    );
//-----------------shift---------------
generate
genvar i,j;
    for(i =0;i<`PICTURE_NUM;i=i+1)begin
    for(j =0;j<CHANNEL_OUT_NUM;j=j+1)begin
shift#(
        .WIDTH_DATA_ADD(WIDTH_DATA_ADD)
    )
shift(
        .clk(clk),
        .rst(rst),
        .shift_data_in(shift_data_in_temp[10][(j+1)*WIDTH_DATA_ADD-1:j*WIDTH_DATA_ADD]),
        .data_in(scale_data_out[(j*`PICTURE_NUM+i+1)*WIDTH_DATA_ADD-1:
        (j*`PICTURE_NUM+i)*WIDTH_DATA_ADD]),
        .shift_data_out(shift_data_out[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA*2-1:
        (j*`PICTURE_NUM+i)*`WIDTH_DATA*2])
    );
    end
  end
endgenerate
//----------------zero_point--------------
//wire [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0] data_after_zero;

 Conv_Zero#(
    .CHANNEL_OUT_NUM(CHANNEL_OUT_NUM)
)Conv_Zero
(
        .clk(clk),
        .M_Valid_Temp(M_Valid_Temp),
        .shift_data_in(shift_data_out),
        .zero_data_in(Zero_Point_REG3),
        .data_out(M_Zero_Data)
    );


//  leakyrelu  ģ��ֱ�ӽ���  shift  ģ���  q3-z3  ��Ϊ��������
leakyrelu	 leakyrelu_u(
	.clk						(clk),
	.leaky_data_in              (M_Zero_Data),
	.zero_data_in               (Zero_Point_REG3),
	.Temp_REG                   (Temp_REG),
	.leaky_data_out             (M_Leaky_Data)
    );    

assign  M_Data = (Leaky_REG == 1'b1)?M_Zero_Data:M_Leaky_Data;   // Leaky_REG = 0 �� leaky, leaky_REG = 1 ���� leaky
assign  M_Valid = (Leaky_REG == 1'b1)? M_Valid_Zero:M_Valid_Leaky;


endmodule