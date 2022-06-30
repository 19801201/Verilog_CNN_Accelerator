`timescale 1ns / 1ps
`include  "../Para.v"

module image_conv_norm_33#(parameter
	KERNEL_NUM	=	9,
	CONV_TYPE	=	"CONV_3_3",
	COMPUTE_CHANNEL_IN_NUM	=	1,   // 几入，一次进几个输入通道
	COMPUTE_CHANNEL_OUT_NUM	=	8,   // 几出，出几个通道
	WIDTH_FEATURE_SIZE	=	10,
	CHANNEL_IN_NUM	=	1,
	WIDTH_RAM_ADDR_SIZE = 6,
	Width_Data_out = 32		  //  1pic,1batch  进行3*3(1*1)卷积操作后的数据位宽bit
)(
	input																	clk,
	input																	rst,
	input																	Start,
	input   [10:0]                                                          Row_Num_Out_REG,
	input   [7:0]                                                           Channel_Out_Num_REG,
	output  [255:0]                                                         REG_Para,
	input	[KERNEL_NUM-1:0]												S_Valid,
	input	[`PICTURE_NUM *COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0]			S_Feature,
	input																	M_Ready,
	output																	S_Ready,
	output																	Conv_Complete,
    output  [WIDTH_RAM_ADDR_SIZE-1:0]			                            weight_addrb,
    input   [255:0]                                                         weight_data_in,
	output	reg	[Width_Data_out*`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM-1:0]	M_Out_Data,
	output																	M_Valid		
);

//localparam	Width_Data_in = `PICTURE_NUM * COMPUTE_CHANNEL_IN_NUM * 8; //32
localparam	Width_After_Conv = 20;     // 9 feature point * 9 weight conv,每两两点相乘位宽 = 8*8 = 16,做4次加法 : 16+4 = 20 (防溢出)

wire	compute_fifo_ready;
wire	rd_en_fifo;
wire	[3:0]	weight_select;

////////////   define weight    ////////////////
reg [KERNEL_NUM*8-1:0] weight_define [COMPUTE_CHANNEL_OUT_NUM-1:0];

//reg   [KERNEL_NUM*8-1:0] weight_0 =72'h3ae95581a1cbd4be01;//[3 3]
//reg   [KERNEL_NUM*8-1:0] weight_1 =72'h0a767fdbccae81ce8d;
//reg   [KERNEL_NUM*8-1:0] weight_2 =72'h027f20f2561301f3b3;
//reg   [KERNEL_NUM*8-1:0] weight_3 =72'h0ad4ce7ff2c56e4a2d;
//reg   [KERNEL_NUM*8-1:0] weight_4 =72'h94e5eff34a7fd9016e;
//reg   [KERNEL_NUM*8-1:0] weight_5 =72'hc41b9a30908141b9d7;
//reg   [KERNEL_NUM*8-1:0] weight_6 =72'h0819c67880b45ad6d7;
//reg   [KERNEL_NUM*8-1:0] weight_7 =72'he53cea2b7fd13019e1;
//reg   [KERNEL_NUM*8-1:0] weight_8 =72'h7f3fdafe262cf8af91;
//reg   [KERNEL_NUM*8-1:0] weight_9 =72'h38442ce45d7fa4e01d;
//reg   [KERNEL_NUM*8-1:0] weight_10=72'hd481be1763fc586edf;
//reg   [KERNEL_NUM*8-1:0] weight_11=72'hd8fd22800016e42c72;
//reg   [KERNEL_NUM*8-1:0] weight_12=72'h02c48018d8934043d8;
//reg   [KERNEL_NUM*8-1:0] weight_13=72'h80d05bf6d238d6623f;
//reg   [KERNEL_NUM*8-1:0] weight_14=72'h0480179589e816ea1e;
//reg   [KERNEL_NUM*8-1:0] weight_15=72'h437f25daf6f2c617ba;
//reg   [KERNEL_NUM*8-1:0] weight_16=72'h4c7f78e48c0b979b11; //[3 3]
//reg   [KERNEL_NUM*8-1:0] weight_17=72'hcdf6804647fe15dbd4;
//reg   [KERNEL_NUM*8-1:0] weight_18=72'h81bf1801ebdd2b5d16;
//reg   [KERNEL_NUM*8-1:0] weight_19=72'hf4b4813fcdf824684a;
//reg   [KERNEL_NUM*8-1:0] weight_20=72'h10a607d480d80fe712;
//reg   [KERNEL_NUM*8-1:0] weight_21=72'h10d1357fc5f62ce59e;
//reg   [KERNEL_NUM*8-1:0] weight_22=72'h9e99db80b10b03fe14;
//reg   [KERNEL_NUM*8-1:0] weight_23=72'h8ccde61bc225566e7f;
//reg   [KERNEL_NUM*8-1:0] weight_24=72'h80ad2c110b41214175;
//reg   [KERNEL_NUM*8-1:0] weight_25=72'h49c5eb0f537fb9c1a2;
//reg   [KERNEL_NUM*8-1:0] weight_26=72'ha8f71d80f3e90d0840;
//reg   [KERNEL_NUM*8-1:0] weight_27=72'h49533f37f07fc5ddcf;
//reg   [KERNEL_NUM*8-1:0] weight_28=72'hb21514fce17fb40c18;
//reg   [KERNEL_NUM*8-1:0] weight_29=72'h7f01825f67945729dc;
//reg   [KERNEL_NUM*8-1:0] weight_30=72'hcd6cff26c8b2aef47f;
//reg   [KERNEL_NUM*8-1:0] weight_31=72'h12ea553b31fb80adc0;

reg [255:0]   weight    [0:44];

always @ (posedge clk) begin
	if (rst) begin
			weight_define[0][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[1][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[2][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[3][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[4][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[5][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[6][KERNEL_NUM*8-1:0] <= 72'h0;    
			weight_define[7][KERNEL_NUM*8-1:0] <= 72'h0;   
	end 
	else begin
		case(weight_select)
			4'b0001:begin
				weight_define[0][KERNEL_NUM*8-1:0] <= weight[1];
				weight_define[1][KERNEL_NUM*8-1:0] <= weight[2];
				weight_define[2][KERNEL_NUM*8-1:0] <= weight[3];
				weight_define[3][KERNEL_NUM*8-1:0] <= weight[4];
				weight_define[4][KERNEL_NUM*8-1:0] <= weight[5];
				weight_define[5][KERNEL_NUM*8-1:0] <= weight[6];
				weight_define[6][KERNEL_NUM*8-1:0] <= weight[7];
				weight_define[7][KERNEL_NUM*8-1:0] <= weight[8];
			end	
			4'b0010:begin
				weight_define[0][KERNEL_NUM*8-1:0] <= weight[9];
				weight_define[1][KERNEL_NUM*8-1:0] <= weight[10];
				weight_define[2][KERNEL_NUM*8-1:0] <= weight[11];
				weight_define[3][KERNEL_NUM*8-1:0] <= weight[12];
				weight_define[4][KERNEL_NUM*8-1:0] <= weight[13];
				weight_define[5][KERNEL_NUM*8-1:0] <= weight[14];
				weight_define[6][KERNEL_NUM*8-1:0] <= weight[15];
				weight_define[7][KERNEL_NUM*8-1:0] <= weight[16];
			end
			4'b0100:begin
				weight_define[0][KERNEL_NUM*8-1:0] <= weight[17]; 
			    weight_define[1][KERNEL_NUM*8-1:0] <= weight[18]; 
			    weight_define[2][KERNEL_NUM*8-1:0] <= weight[19];
			    weight_define[3][KERNEL_NUM*8-1:0] <= weight[20];
			    weight_define[4][KERNEL_NUM*8-1:0] <= weight[21];
			    weight_define[5][KERNEL_NUM*8-1:0] <= weight[22];
			    weight_define[6][KERNEL_NUM*8-1:0] <= weight[23];
			    weight_define[7][KERNEL_NUM*8-1:0] <= weight[24];
			end
			4'b1000:begin
				weight_define[0][KERNEL_NUM*8-1:0] <= weight[25]; 
			    weight_define[1][KERNEL_NUM*8-1:0] <= weight[26]; 
			    weight_define[2][KERNEL_NUM*8-1:0] <= weight[27];
			    weight_define[3][KERNEL_NUM*8-1:0] <= weight[28];
			    weight_define[4][KERNEL_NUM*8-1:0] <= weight[29];
			    weight_define[5][KERNEL_NUM*8-1:0] <= weight[30];
			    weight_define[6][KERNEL_NUM*8-1:0] <= weight[31];
			    weight_define[7][KERNEL_NUM*8-1:0] <= weight[32];
			end
			default:begin
				weight_define[0][KERNEL_NUM*8-1:0] <= weight[1];
				weight_define[1][KERNEL_NUM*8-1:0] <= weight[2];
				weight_define[2][KERNEL_NUM*8-1:0] <= weight[3];
				weight_define[3][KERNEL_NUM*8-1:0] <= weight[4];
				weight_define[4][KERNEL_NUM*8-1:0] <= weight[5];
				weight_define[5][KERNEL_NUM*8-1:0] <= weight[6];
				weight_define[6][KERNEL_NUM*8-1:0] <= weight[7];
				weight_define[7][KERNEL_NUM*8-1:0] <= weight[8];
			end		
		endcase
	end
end
//////////////////////       end define weight        /////////////////////////////
reg [WIDTH_RAM_ADDR_SIZE-1:0] weight_addrb_q;
always@(posedge clk)begin
    weight_addrb_q <= weight_addrb;
end
always@(posedge clk)begin
    weight[weight_addrb_q] <= weight_data_in;
end

assign REG_Para = weight[0];

wire	Compute_Complete;

image_compute_control    image_compute_control  (
	.clk				(clk),
	.rst				(rst), 
	.Start				(Start),
	.Row_Num_Out_REG    (Row_Num_Out_REG),
	.Channel_Out_Num_REG(Channel_Out_Num_REG),
	.compute_fifo_ready	(compute_fifo_ready),
	.M_Ready            (M_Ready),
	.Compute_Complete	(Compute_Complete),
	.Conv_Complete		(Conv_Complete),
	.rd_en_fifo			(rd_en_fifo),
	.M_Valid            (M_Valid),
	.weight_addrb       (weight_addrb),
	.weight_select 		(weight_select)
	);
	

///  load nine feature point ///
wire	[`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0]	fifo_out_data;
wire	[KERNEL_NUM-1:0]	compute_fifo_ready_count,S_Ready_count;

assign	compute_fifo_ready = compute_fifo_ready_count[0];
assign	S_Ready = S_Ready_count[0];



//////    4张图片的9个点  //////
generate
genvar i;
	for(i = 0;i < KERNEL_NUM;i = i + 1) begin 
		image_nine_fifo  #(
			.WIDTH(`IMAGE_WIDTH_DATA),
			.ADDR_BITS(10)
		)	image_nine_fifo(
			.clk		(clk),
			.rst		(rst),
			.din		(S_Feature[(i+1)*`IMAGE_WIDTH_DATA-1:i*`IMAGE_WIDTH_DATA]),
			.rd_en		(rd_en_fifo),
			.wr_en		(S_Valid[i]),
			.M_count	(Row_Num_Out_REG),
			.S_count	(Row_Num_Out_REG),
			.dout		(fifo_out_data[(i+1)*`IMAGE_WIDTH_DATA-1:i*`IMAGE_WIDTH_DATA]),
			.M_Ready	(compute_fifo_ready_count[i]),
			.S_Ready    (S_Ready_count[i])
		);
	end
endgenerate

 /////////     给  fifo data  做延迟处理   //////////////
reg	[`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0]	fifo_out_data_delay_0;
always @ (posedge clk) begin
	fifo_out_data_delay_0[`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0] <= fifo_out_data[`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0];
end

//generate
//genvar x;
//	for (x = 0;x < 3;x = x + 1) begin
//		always @ (posedge clk) begin
//			fifo_out_data_delay[x+1][`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0] <= fifo_out_data_delay[x][`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*8*KERNEL_NUM-1:0];
//		end
//	end
//endgenerate
 
//////    4张图片的9个特征点  和 8个输出通道的9个卷积点  做卷积操作  (同时进行的8出操作)  //////
//////     [79:0]       ///////
wire	[Width_After_Conv*`PICTURE_NUM-1:0]	after_conv_data	[0:COMPUTE_CHANNEL_OUT_NUM-1]; 
 
generate
genvar j;
	for (j = 0;j < COMPUTE_CHANNEL_OUT_NUM;j = j + 1) begin 
		 image_conv2d#(
//		 .BATCH_SIZE 			(`PICTURE_NUM),
		 .KERNEL_NUM 			(KERNEL_NUM),
		 .CONV_TYPE 			(CONV_TYPE)
		 ) image_conv2d(
		 .clk					(clk),
		 .data_in               (fifo_out_data_delay_0),
		 .weight_in             (weight_define[j]),
		 .data_out              (after_conv_data[j])
		 );
	end
endgenerate

///   将卷积后数据的位宽进行扩充操作  (每个输出通道的位宽由  80  扩充至  128)  
///	  即每个输出通道的每个 batch  的位宽由  20 bit 扩充至 32 bit ， 4 个 batch 就是 128 bit  
///   这么做目的是为了在进行后续的量化操作时匹配位宽
///         32      *      4								  8  
wire [Width_Data_out*`PICTURE_NUM-1:0]  changed_output [COMPUTE_CHANNEL_OUT_NUM-1:0];
//generate 
//genvar o,b;
//	for (o = 0;o < COMPUTE_CHANNEL_OUT_NUM;o = o + 1) begin 
//		for (b = 0;b < `PICTURE_NUM;b = b + 1) begin 
//			assign changed_output[o][(b+1)*Width_Data_out-1:b*Width_Data_out] = {{12{after_conv_data[o][(b+1)*Width_After_Conv-1]}},after_conv_data[o][(b+1)*Width_After_Conv-1:b*Width_After_Conv]};
//		end
	
//		always @ (posedge clk) begin 
//			if (rst)
//				M_Out_Data[(o+1)*Width_Data_out*`PICTURE_NUM-1:o*Width_Data_out*`PICTURE_NUM] <= {128{1'b0}};
//			else
//				M_Out_Data[(o+1)*Width_Data_out*`PICTURE_NUM-1:o*Width_Data_out*`PICTURE_NUM] <= changed_output[o];
//		end
//	end
//endgenerate



generate 
genvar o,b;
	for (o = 0;o < COMPUTE_CHANNEL_OUT_NUM;o = o + 1) begin 
		for (b = 0;b < `PICTURE_NUM;b = b + 1) begin 
			assign changed_output[o][(b+1)*Width_Data_out-1:b*Width_Data_out] = {{12{after_conv_data[o][(b+1)*Width_After_Conv-1]}},after_conv_data[o][(b+1)*Width_After_Conv-1:b*Width_After_Conv]};
		end
	
		always @ (posedge clk) begin 
			if (rst)
				M_Out_Data[(o+1)*Width_Data_out*`PICTURE_NUM-1:o*Width_Data_out*`PICTURE_NUM] <= {Width_Data_out{1'b0}};
			else
				M_Out_Data[(o+1)*Width_Data_out*`PICTURE_NUM-1:o*Width_Data_out*`PICTURE_NUM] <= changed_output[o];
		end
	end
endgenerate

integer end_out_data;
initial
begin
end_out_data=$fopen("11_image_conv.txt");

end
always@(posedge clk)begin
if(M_Valid)
    $fwrite(end_out_data,"%h\n",M_Out_Data);
end


endmodule
