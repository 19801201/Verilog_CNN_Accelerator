`timescale 1ns / 1ps
`include "../Para.v"


module image_compute_33#(parameter
	WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
    WIDTH_DATA_ADD_SUB        =  16,
	COMPUTE_CHANNEL_OUT_NUM	  =	 8,
	WIDTH_FEATURE_SIZE        =  10
)(
    input			clk,
    input			rst,	  	
    input			Start,
    input	[`IMAGE_WIDTH_DATA-1:0]	S_Data,
    input			S_Valid,
    output			S_Ready,
    input			M_Stride_Ready,
    output			M_Stride_Valid,
    output	[COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0]	M_Stride_Data,  //  数据位宽*图片数*输出通道数
    output          Stride_Complete,
    
    input   [255:0] Data_Out_Weight,
    output  [5:0]   weight_addrb,
    output          Stride_REG,
    output          Img_Last                
);


wire [7:0] Zero_Point_REG3;
//wire [7:0] Bias_Num_REG;
//wire [7:0] Weight_Num_REG;
//wire [7:0] Ram_Weight_REG;
wire [31:0] Temp_REG;
wire Padding_REG;
//wire Stride_REG;
wire [2:0] Zero_Num_REG;
wire [10:0] Row_Num_In_REG;
wire [10:0] Row_Num_Out_REG;
wire [7:0] Channel_Out_Num_REG;

wire [255:0] REG_Para;  //  *******************************************************

///////////////        REG7 的参数              
assign Zero_Point_REG3    =REG_Para [127:120];   // 8位  Z3 的值
//assign Bias_Num_REG    	  =REG_Para [119:112];   // 8位  Bias在 256bit coe 中的行数
//assign Weight_Num_REG     =REG_Para [111:104];   // 8位  权重在255bit coe 中的行数
//assign Ram_Weight_REG     =REG_Para [103:96];    // 8位  255bit coe 中的总行数

////////////////////   REG6 的参数  
assign Temp_REG           =REG_Para  [95:64];    // leaky_relu 的reg

////////////////////   REG5 的参数 
assign Padding_REG        =REG_Para  [63:63];    // 1位   是否需要 padding 的信号
assign Stride_REG         =REG_Para  [62:62];    // 1位   是否需要 stride  的信号
assign Zero_Num_REG       =REG_Para  [61:59];    // 3位   padding 添零的圈数  (针对 5*5 卷积而设计的) ，本工程为1
        

////////////////////   REG4 的参数
assign Row_Num_In_REG	  =REG_Para  [31:21];    // 11位  图片输入的宽高数
assign Row_Num_Out_REG    =REG_Para  [20:10];    // 11位  卷积操作后的图片宽高数      
assign Channel_Out_Num_REG=REG_Para  [7 :0 ];    // 8位   图片输出通道数



wire	[`IMAGE_WIDTH_DATA-1:0]	M_Padding_Data;
wire			M_Padding_Ready;
wire			M_Write_EN;
wire	[9:0]	Row_Num_After_Padding;


    
image_padding	image_padding(
    .clk					   (clk),
    .rst                       (rst),
    .Start                     (Start),
    .Padding_REG               (Padding_REG),
    .Zero_Num_REG              (Zero_Num_REG),
    .Row_Num_In_REG            (Row_Num_In_REG),
    .S_Feature                 (S_Data),
    .S_Valid                   (S_Valid),
    .S_Ready                   (S_Ready),
    .M_Ready                   (M_Padding_Ready),
    .M_Data                    (M_Padding_Data),
    .M_Write_EN                (M_Write_EN),
    .Row_Num_After_Padding     (Row_Num_After_Padding)
);  
    
wire	Start_Row;
wire	M_four2three_Ready;
wire	[`IMAGE_WIDTH_DATA*3-1:0]	M_four2three_Data;
wire	[9:0]	M_four2three_Addr;

image_four2three	image_four2three(
	.clk						(clk),
	.rst                     (rst),
	.Start                   (Start),
	.Start_Row               (Start_Row),
	.Row_Num_After_Padding   (Row_Num_After_Padding),
	.S_Data                  (M_Padding_Data),
	.S_Valid                 (M_Write_EN),
	.S_Ready                 (M_Padding_Ready),
	.M_Ready                 (M_four2three_Ready),
	.M_Data                  (M_four2three_Data),
	.M_Addr                  (M_four2three_Addr)
);    

wire	[`IMAGE_WIDTH_DATA*3*3-1:0]			M_three2nine_Data;
wire					M_three2nine_Ready;
wire	[8:0]			M_EN_Write;   // nine fifo wr en 


image_three2nine    image_three2ninee(
	.clk						 (clk),
    .rst                         (rst),
    .Start                       (Start),
    .S_Ready                     (M_four2three_Ready),
    .Addr                        (M_four2three_Addr),
    .S_Feature                   (M_four2three_Data),
    .Row_Num_After_Padding       (Row_Num_After_Padding),
    .Row_Compute_Sign            (Start_Row),
    .M_Data                      (M_three2nine_Data),
    .M_Ready                     (M_three2nine_Ready),
    .M_EN_Write                  (M_EN_Write)
    );


wire	            Conv_Complete;
wire				M_Conv33_Ready;
wire	[32*8*`PICTURE_NUM-1:0]	M_Conv33_Data;  //  32*图片数*输出通道数(8出的8)
wire				M_Conv33_Valid;


image_conv_norm_33    image_conv_norm_33(
	.clk						(clk),
	.rst                        (rst),
	.Start                      (Start),
	.Row_Num_Out_REG            (Row_Num_Out_REG),
	.Channel_Out_Num_REG        (Channel_Out_Num_REG),
	.REG_Para                   (REG_Para),
	
	.S_Valid					(M_EN_Write),
	.S_Feature					(M_three2nine_Data),		
	.M_Ready					(M_Conv33_Ready),
	.S_Ready                    (M_three2nine_Ready),
	.Conv_Complete				(Conv_Complete),
	.weight_addrb               (weight_addrb),
	.weight_data_in             (Data_Out_Weight),
	.M_Out_Data					(M_Conv33_Data),	
	.M_Valid					(M_Conv33_Valid)		
);

wire				M_Quan_Ready;
wire				M_Quan_Valid;
wire	[COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0]		M_Quan_Data;  //  数据位宽*图片数*输出通道数(8出的8)
image_conv_quan 	image_conv_quan(
	.clk						(clk),
	.rst                     	(rst),
	.Start                      (Start),
	.Row_Num_Out_REG            (Row_Num_Out_REG),
	.Channel_Out_Num_REG        (Channel_Out_Num_REG),
	
	.S_Valid                 	(M_Conv33_Valid),
	.S_Data                  	(M_Conv33_Data),
	.S_Ready                 	(M_Conv33_Ready),
	.weight_addrb               (weight_addrb),
	.weight_data_in             (Data_Out_Weight),
	.Zero_Point_REG3            (Zero_Point_REG3),
	.Temp_REG                   (Temp_REG),
	.M_Ready                 	(M_Quan_Ready),
	.M_Data                  	(M_Quan_Data),
	.M_Valid                 	(M_Quan_Valid)
); 

image_stride  image_stride(
	.clk						(clk),
	.rst                        (rst),
	.Start                      (Start),
	.EN_Stride_REG              (Stride_REG),
	.Row_Num_Out_REG            (Row_Num_Out_REG),
	.Channel_Out_Num_REG        (Channel_Out_Num_REG),
	.S_Valid                    (M_Quan_Valid),
	.S_Ready                    (M_Quan_Ready),
	.S_Data                     (M_Quan_Data),
	.M_Data                     (M_Stride_Data),
	.M_Valid                    (M_Stride_Valid),
	.M_Ready                    (M_Stride_Ready),
	.Stride_Complete            (Stride_Complete),
	.Img_Last                   (Img_Last)
);    
    

    
endmodule