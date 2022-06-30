`timescale 1ns / 1ps
`include "../Para.v"


module image_conv_quan#(parameter
	WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
    WIDTH_DATA_ADD_SUB        =  16,
	COMPUTE_CHANNEL_OUT_NUM	  =	 8,
	WIDTH_FEATURE_SIZE        =  10
)(
	input	clk,
	input	rst,
	input	Start,
	input   [10:0] Row_Num_Out_REG,
	input   [7:0] Channel_Out_Num_REG,
	
	input	S_Valid,
	input	[WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0]	S_Data,
	output	S_Ready,
	
	input   [5:0]   weight_addrb,
    input   [255:0] weight_data_in,
    input   [7:0]   Zero_Point_REG3,
    input   [31:0]  Temp_REG,
	
	input	M_Ready,
//	output	[63:0]	M_Data,
	output	[COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0]	M_Data,
	output	M_Valid
    );
    
reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	bias_data_in;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	bias_data_0 = 256'h8a5e49240bb2bac109816de18b395b768a4f07a78a7099730aa4f2b50af44061;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	bias_data_1 = 256'h8c2316ad09914af58c7010880ab909668f5bee0a8c75cd078a1430b48d19f1b3;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	bias_data_2 = 256'h8b30dc8509a34d8f902ccbc30aed9c340ed763a10cf39a3b0bccc91390080a26;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	bias_data_3 = 256'h0b9e77270fe2e7688a5b7dda8d7569c68a208eb80a89d09d8d7d6f188a7ffac2;
   
reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]    scale_data_in;
//reg [`IMAGE_BIAS_WIDTH_DATA-1:0]	scale_data_0 = 256'h9081a1009c6814006028a8007242d8006b430400a0a4a9006d986980621aec80;
//reg [`IMAGE_BIAS_WIDTH_DATA-1:0]	scale_data_1 = 256'hb26ca600a675090075bf3d0071cad480b17612007bf28d80b2614d0087565d00;
//reg [`IMAGE_BIAS_WIDTH_DATA-1:0]	scale_data_2 = 256'h620e66806d985580b2258b00b013a3005de8a600ac71ea00acd98d007323ce80;
//reg [`IMAGE_BIAS_WIDTH_DATA-1:0]	scale_data_3 = 256'h7539b280b43299007f6ce380a325fc0065362b00aee988006752a480af316500;

reg [`IMAGE_BIAS_WIDTH_DATA-1:0]	shift_data_in;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	shift_data_0 = 256'h00000009000000090000000a0000000800000009000000090000000900000009;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	shift_data_1 = 256'h000000080000000a000000070000000900000007000000070000000a00000007;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	shift_data_2 = 256'h000000080000000a000000060000000a00000006000000080000000900000007;
//reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	shift_data_3 = 256'h0000000800000006000000090000000700000009000000090000000700000009;

// 0-31：权重   32-35：bias   36-39：scale  40-43：shift  44:zero_point   45: reg6
reg [255:0]   quan    [0:44];
reg [5:0] weight_addrb_q;
always@(posedge clk)begin
    weight_addrb_q <= weight_addrb;
end
always@(posedge clk)begin
    quan[weight_addrb_q] <= weight_data_in;
end

     
///////   先进行 bias 计算，在 scale,在shift  ////////    


//////////////////////////////   控制模块  /////////////////////////////

//  先将卷积模块中传入的数据缓存到  fifo  中，再逐个提取进行 与 bias 相加的操作
wire	rd_en_fifo;     //  读取缓存在 fifo 中的数据的读使能
wire	fifo_valid;		//  fifo 中数据写满一行的发送数据请求操作
wire    [3:0]	para_select;	//  选择 bias 的使能
wire    [13:0]  S_Count_Fifo;

image_conv_quan_control  image_conv_quan_control (
	.clk                   (clk),
	.rst				   (rst),
	.Start                 (Start),
	.Row_Num_Out_REG       (Row_Num_Out_REG),
	.Channel_Out_Num_REG   (Channel_Out_Num_REG),
	.fifo_valid    		   (fifo_valid),	
	.M_Ready               (M_Ready),
	.rd_en_fifo            (rd_en_fifo),
	.para_select           (para_select),
	.S_Count_Fifo          (S_Count_Fifo),
	.M_Valid               (M_Valid)
   );
 
 
 //////////////////////////////////  bias  模块  //////////////////////////////   
always @ (posedge clk) begin 
	if (rst) begin
		bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= 256'h0;
	end
	else begin
		case (para_select)
			4'b0000:
				bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= 256'h0;
			4'b0001:
				bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[33];
			4'b0010:
				bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[34];
			4'b0100:
				bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[35];
			4'b1000:
				bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[36];
			default:
				bias_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= bias_data_in;
		endcase
	end
end

 
wire	[WIDTH_DATA_ADD_TEMP*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0]	data_after_bias;

//reg	[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0]	S_Data_delay0;
//reg	[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0]	S_Data_delay1;

// ////////////     S_Data  在进入 bias 运算前加一个时钟周期延迟       ////////
//always @ (posedge clk) begin
//	if (rst)
//		S_Data_delay0[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0] <= 1024'h0;
//	else
//		S_Data_delay0[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0] <= S_Data[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0];
//end

//always @ (posedge clk) begin
//	S_Data_delay1[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0] <= S_Data_delay0[`PICTURE_NUM*`COMPUTE_CHANNEL_OUT_NUM*32-1:0];
//end
 
//////     bias 计算加法时每一批数据输入时 (4个图像8个输出通道)  有2个时钟周期延迟     //////
image_conv_bias  image_conv_bias(
	.clk					 (clk),	
	.rst                	 (rst),
	.Channel_Out_Num_REG     (Channel_Out_Num_REG),
	.S_Count_Fifo            (S_Count_Fifo),
	.S_Data             	 (S_Data),
	.S_Valid            	 (S_Valid),
	.rd_en_fifo         	 (rd_en_fifo),
	.bias_data_in       	 (bias_data_in),
	.S_Ready            	 (S_Ready),
	.fifo_valid         	 (fifo_valid),
	.M_Data             	 (data_after_bias)
    );
  
 /////////////////////////   scale  模块  ///////////////////////////// 
 
wire [WIDTH_DATA_ADD*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0] data_after_scale;
 

always @ (posedge clk) begin 
	if (rst) begin 
		scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= 256'h0;
	end
	else begin
		case (para_select)
			4'b0000:
				scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= 256'h0;
			4'b0001:
				scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[37];
			4'b0010:
				scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[38];
			4'b0100:
				scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[39];
			4'b1000:
				scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[40];
			default:
				scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0];
		endcase
	end
end

//////   对 scale data 进行延迟处理  延迟 2 个时钟周期等待  bias 计算完成 ///////    
reg	[`IMAGE_BIAS_WIDTH_DATA-1:0]	scale_data_in_delay [0:2];

always @(posedge clk)  begin
	scale_data_in_delay[0][`IMAGE_BIAS_WIDTH_DATA-1:0] <= scale_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0];
end  

always @(posedge clk)  begin
	scale_data_in_delay[1][`IMAGE_BIAS_WIDTH_DATA-1:0] <= scale_data_in_delay[0][`IMAGE_BIAS_WIDTH_DATA-1:0];
end

always @(posedge clk)  begin
	scale_data_in_delay[2][`IMAGE_BIAS_WIDTH_DATA-1:0] <= scale_data_in_delay[1][`IMAGE_BIAS_WIDTH_DATA-1:0];
end 
///    此处的计算每批数据 有 3 个时钟周期的延迟        ///   
image_conv_scale image_conv_scale(
    .clk						(clk),
    .rst						(rst),
    .S_Data                     (data_after_bias),
    .scale_data_in              (scale_data_in_delay[2]),
    .scale_data_out             (data_after_scale)
);    


///////////////////////  shift  模块  ////////////////////////
//wire [127:0]  data_after_shift;
wire [WIDTH_DATA_ADD_SUB*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0]  data_after_shift;

 always @ (posedge clk) begin 
    if (rst) begin 
    	shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= 256'h0;
    end
    else begin
		case (para_select)
			4'b0000:
				shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= 256'h0;
			4'b0001:
				shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[41];
			4'b0010:
				shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[42];
			4'b0100:
				shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[43];
			4'b1000:
				shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= quan[44];
			default:
				shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0] <= shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0];
		endcase
	end
end

    
//////   对  shift  data  进行延迟处理   延迟 5 个时钟周期  等待  bias 和 scale 计算完成//////
reg  [`IMAGE_BIAS_WIDTH_DATA-1:0] shift_data_in_delay  [0:10];
always @ (posedge clk) begin 
	shift_data_in_delay[0][`IMAGE_BIAS_WIDTH_DATA-1:0] <= shift_data_in[`IMAGE_BIAS_WIDTH_DATA-1:0];
end
    
generate
genvar i;
	for (i = 0;i < 10;i = i ++1) begin
		always @ (posedge clk) begin 
			shift_data_in_delay[i+1][`IMAGE_BIAS_WIDTH_DATA-1:0] <= shift_data_in_delay[i][`IMAGE_BIAS_WIDTH_DATA-1:0];
		end
	end
endgenerate    


generate
genvar j,k;
    for(j =0;j<`PICTURE_NUM;j=j+1)begin
   		for(k =0;k<COMPUTE_CHANNEL_OUT_NUM;k=k+1)begin
			image_shift    image_shift(
        		.clk(clk),
        		.rst(rst),
        		.shift_data_in(shift_data_in_delay[10][(k+1)*WIDTH_DATA_ADD-1:k*WIDTH_DATA_ADD]),
        		.data_in(data_after_scale[(k*`PICTURE_NUM+j+1)*WIDTH_DATA_ADD-1:
        		(k*`PICTURE_NUM+j)*WIDTH_DATA_ADD]),
        		.shift_data_out(data_after_shift[(k*`PICTURE_NUM+j+1)*WIDTH_DATA_ADD_SUB-1:
        		(k*`PICTURE_NUM+j)*WIDTH_DATA_ADD_SUB])
   			);
    	end
    end
endgenerate
    
//----------------zero_point--------------
wire [`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA-1:0] data_after_zero;

image_conv_zero  image_conv_zero
(
        .clk(clk),
        .shift_data_in(data_after_shift),
        .zero_data_in(Zero_Point_REG3),
        .data_out(data_after_zero)
    );   
    
//  leakyrelu  模块直接接收  shift  模块的  q3-z3  作为数据输入
image_leakyrelu	 image_leakyrelu_u(
	.clk						(clk),
	.leaky_data_in              (data_after_zero),
	.zero_data_in               (Zero_Point_REG3),
	.Temp_REG                   (Temp_REG),
	.leaky_data_out             (M_Data)
    );    
   
endmodule
