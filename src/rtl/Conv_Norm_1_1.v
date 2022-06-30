`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/23 14:58:29
// Design Name: 
// Module Name: Conv_Norm
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
module Conv_Norm_1_1  #(parameter
KERNEL_NUM                   =       1,
CONV_TYPE                    =       "CONV_1_1",//CONV_3_3
//COMPUTE_CHANNEL_IN_NUM       =       8,
COMPUTE_CHANNEL_IN_NUM       =       32,  //************************************
COMPUTE_CHANNEL_OUT_NUM      =       8,
WIDTH_RAM_ADDR_SIZE          =       16,
WIDTH_TEMP_RAM_ADDR_SIZE     =       12,//temp save feature ram
WIDTH_FEATURE_SIZE           =       12,
WIDTH_CHANNEL_NUM_REG        =       10,
WIDTH_DATA_ADD               =       32,
WIDTH_RAM_ADDR_TURE          =       14,
WIDTH_WEIGHT_NUM             =       17,
WIDTH_BIAS_RAM_ADDRA         =       9
)(  
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start_Cu,
    input  Start_Pa,
    //weight ram
    input  [`AXI_WIDTH_DATA-1:0] S_Para_Data,
    input   S_Para_Valid,
    output  S_Para_Ready,
    output  Write_Block_Complete,
    
//    output[WIDTH_RAM_ADDR_TURE-1:0] Bram_Addrb,   // ´Ó Compute_Para µÄ¶ÁµØÖ·
    output Compute_Complete,//
//    input  [`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*KERNEL_NUM*`WIDTH_DATA-1:0]   S_Data,
    input  [`PICTURE_NUM*8*KERNEL_NUM*`WIDTH_DATA-1:0]   S_Data,   //************************************
    input  [KERNEL_NUM - 1 : 0]   S_Valid,
    output     S_Ready,
    
    output [`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*WIDTH_DATA_ADD-1:0]   M_Data_out,
    input  M_ready,
    output reg M_Valid,
    
    
//    input  [WIDTH_RAM_ADDR_TURE-1'b1:0] Ram_Read_Addrb_Base,  // ´Ó Compute_Para µÄ¶Á»ùµØÖ·
    
    input  [WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,      //featureï¿½Ä´ï¿½Ð¡ï¿½ï¿½Paddingï¿½ï¿½Ä£ï¿???
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_In_Num_REG ,//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½ï¿½ï¿½//reg  4/4  1
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_Out_Num_REG,//ï¿½ï¿½ï¿½Í¨ï¿½ï¿½ï¿½ï¿???//reg  16/1 16
    
    input  [WIDTH_WEIGHT_NUM-1:0] Weight_Single_Num_REG,  // weightÒ»¸öµãµÄ×ÜÐÐÊý
    input  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Num_REG,    // bias µÄ×ÜÊýÁ¿
    input  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Addrb,    // bias scale shift RAM µÄ¶ÁµØÖ·
    output [32*8-1:0]Data_Out_Bias,  //bias
    output [32*8-1:0]Data_Out_Scale,  //scale
    output [32*8-1:0]Data_Out_Shift  //shift

    );
    
wire [WIDTH_FEATURE_SIZE-1:0]    S_Count_Fifo;
wire [WIDTH_FEATURE_SIZE-1:0]    M_Count_Fifo;
localparam  WIDTH_TOTAL_DATA_8 = `PICTURE_NUM*8*`WIDTH_DATA;  //1*8*8 = 64
localparam  WIDTH_TOTAL_DATA = `PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA;  //1*32*8 = 256
 wire [WIDTH_FEATURE_SIZE-1:0]   COMPUTE_TIMES_CHANNEL_IN_REG;//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿???//reg  4/4  1
 wire [WIDTH_FEATURE_SIZE-1:0]   COMPUTE_TIMES_CHANNEL_IN_REG_8;
 wire [WIDTH_FEATURE_SIZE-1:0]   COMPUTE_TIMES_CHANNEL_OUT_REG;//ï¿½ï¿½ï¿½Í¨ï¿½ï¿½Òªï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ù´ï¿½//reg  16/1 16
//assign COMPUTE_TIMES_CHANNEL_IN_REG = Channel_In_Num_REG/COMPUTE_CHANNEL_IN_NUM;
assign COMPUTE_TIMES_CHANNEL_IN_REG = Channel_In_Num_REG>>5;  //**************  8 -> 32  ***********************
assign COMPUTE_TIMES_CHANNEL_IN_REG_8 = Channel_In_Num_REG>>3;
//assign COMPUTE_TIMES_CHANNEL_OUT_REG =Channel_Out_Num_REG/COMPUTE_CHANNEL_OUT_NUM;
assign COMPUTE_TIMES_CHANNEL_OUT_REG =Channel_Out_Num_REG>>3; //***************  8  ****************************
      
//===========wire_load,control part=========
wire Load_Start,Load_Weight_Complete;
wire [WIDTH_RAM_ADDR_SIZE-1-5:0] Weight_Addrb;
//wire [1*512-1:0]  Data_Out_Weight;  
wire [4*512-1:0]  Data_Out_Weight;       //*******************************************
 
 //=============ï¿½ï¿½ï¿½ï¿½×´Ì¬ï¿½ï¿½Ä£ï¿½é£¬Ê¹ï¿½Ü¶ï¿½Ó¦================
wire rd_en_fifo;//fifoï¿½ï¿½Ê¹ï¿½ï¿½
wire fifo_compute_ready;//ï¿½ã¹»ï¿½ï¿½ï¿½ï¿½
wire [WIDTH_TEMP_RAM_ADDR_SIZE-1:0] ram_temp_read_address;//ï¿½ï¿½Ê±ramï¿½ï¿½ï¿½ï¿½Ö·
wire [WIDTH_TEMP_RAM_ADDR_SIZE-1:0] ram_temp_write_address;//ï¿½ï¿½Ê±ramÐ´ï¿½ï¿½Ö·
wire First_Compute_Complete_Temp;
wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0] data_result_temp[0:COMPUTE_CHANNEL_OUT_NUM-1];
wire M_Valid_Temp;
//ï¿½ï¿½ï¿½ï¿½×´Ì¬ï¿½ï¿½==================
 compute_control_1_1 #(
    .WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE),   
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE),  
    .WIDTH_TEMP_RAM_ADDR_SIZE(WIDTH_TEMP_RAM_ADDR_SIZE),
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG)
)
 compute_control_1_1(
    .clk(clk),
    .rst(rst),
    .Start(Start_Cu),//ï¿½ï¿½ï¿½ã¿ªÊ¼ï¿½Åºï¿½
//    .Load_Start(Load_Start),
//    .Load_Weight_Complete(Load_Weight_Complete),
    .Compute_Complete(Compute_Complete),//ï¿½ï¿½ï¿½ï¿½Ä¼ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Åºï¿½
    .First_Compute_Complete(First_Compute_Complete_Temp),//ï¿½ï¿½ï¿½ï¿½ï¿½Ò»Ò»ï¿½ï¿???
    //ï¿½Ô´ï¿½fifoï¿½ï¿½ï¿½ï¿½
    .compute_fifo_ready(fifo_compute_ready),
    .rd_en_fifo(rd_en_fifo),    
    //ï¿½Â¸ï¿½fifo
    .M_ready(M_ready),      
    .M_Valid(M_Valid_Temp),//out
    //Weight Ramï¿½Ë¿ï¿½
    .weight_addrb(Weight_Addrb),
    //ï¿½ï¿½Ê±ram
    .ram_temp_read_address(ram_temp_read_address),
    .ram_temp_write_address(ram_temp_write_address),
    //ï¿½ï¿½Òªï¿½ï¿½ï¿½ÃµÄ²ï¿½ï¿½ï¿½
    .COMPUTE_TIMES_CHANNEL_IN_REG(COMPUTE_TIMES_CHANNEL_IN_REG) ,//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿???//reg
    .COMPUTE_TIMES_CHANNEL_IN_REG_8(COMPUTE_TIMES_CHANNEL_IN_REG_8),
    .COMPUTE_TIMES_CHANNEL_OUT_REG(COMPUTE_TIMES_CHANNEL_OUT_REG),//ï¿½ï¿½ï¿½Í¨ï¿½ï¿½Òªï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ù´ï¿½//reg
    .ROW_NUM_CHANNEL_OUT_REG(Row_Num_Out_REG),
    .M_Count_Fifo(M_Count_Fifo),
    .S_Count_Fifo(S_Count_Fifo)
    );
//-----------------Instant_Load_Weight----------------

always@(posedge clk)
M_Valid<=M_Valid_Temp;

(* keep="true" *) reg First_Compute_Complete[0:7];
always@(posedge clk)begin
    First_Compute_Complete[0]<=First_Compute_Complete_Temp;
    First_Compute_Complete[1]<=First_Compute_Complete_Temp;
    First_Compute_Complete[2]<=First_Compute_Complete_Temp;
    First_Compute_Complete[3]<=First_Compute_Complete_Temp;
    First_Compute_Complete[4]<=First_Compute_Complete_Temp;
    First_Compute_Complete[5]<=First_Compute_Complete_Temp;
    First_Compute_Complete[6]<=First_Compute_Complete_Temp;
    First_Compute_Complete[7]<=First_Compute_Complete_Temp;
end

Load_Weight_Bias_1_1 #(
   .WIDTH_RAM_ADDR_TURE (WIDTH_RAM_ADDR_TURE),
   .WIDTH_WEIGHT_NUM (WIDTH_WEIGHT_NUM),
   .WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE),
   .WIDTH_BIAS_RAM_ADDRA(WIDTH_BIAS_RAM_ADDRA),
   .KERNEL_NUM              (KERNEL_NUM),
   .COMPUTE_CHANNEL_IN_NUM  (COMPUTE_CHANNEL_IN_NUM),
   .COMPUTE_CHANNEL_OUT_NUM (COMPUTE_CHANNEL_OUT_NUM)
    )
    Load_Weight_Bias_1_1
    (
    .clk(clk),
    .rst(rst),
    .Start_Pa(Start_Pa),
    .Weight_Addrb(Weight_Addrb),
    .Weight_Single_Num_REG(Weight_Single_Num_REG),
    .Bias_Num_REG(Bias_Num_REG),
    .Write_Block_Complete(Write_Block_Complete),
//    .Bram_Addrb (Bram_Addrb),
    .S_Para_Data(S_Para_Data),
    .S_Para_Valid(S_Para_Valid),
    .S_Para_Ready(S_Para_Ready),
//    .S_Data_One (Bram_Data_In_One),
//    .S_Data_Two (Bram_Data_In_Two),
//    .S_Data_Three (Bram_Data_In_Three),
//    .S_Data_Four (Bram_Data_In_Four),
    
//    .Ram_Read_Addrb_Base(Ram_Read_Addrb_Base),
 
    .Data_Out_Weight (Data_Out_Weight),   //weight

    .Bias_Addrb (Bias_Addrb),  
    .Data_Out_Bias (Data_Out_Bias),  //bias
    .Data_Out_Scale (Data_Out_Scale),  //scale
    .Data_Out_Shift (Data_Out_Shift)  //shift
    );
   
    
 //fifoï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿???
wire  [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0] data_fifo_out;//  256
wire  [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0] data_fifo_out_q;//  256


feature_conv11_fifo #(
        .WIDTH_8(WIDTH_TOTAL_DATA_8),
        .WIDTH(WIDTH_TOTAL_DATA),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
        )
    feature_conv11_fifo (    
	 .clk(clk),
	 .rst(rst),
	 .Next_Reg(Next_Reg),
	 .din(S_Data),
	 .wr_en(S_Valid),
	
	 .rd_en(rd_en_fifo),
	 .dout(data_fifo_out_q),
	
	 .M_count(M_Count_Fifo),  //back
	 .M_Ready(fifo_compute_ready),
	 .S_count(S_Count_Fifo),   //front
	 .S_Ready(S_Ready)
	); 
assign data_fifo_out = {data_fifo_out_q[63:0],data_fifo_out_q[127:64],data_fifo_out_q[191:128],data_fifo_out_q[255:192]};
//=================ï¿½ï¿½Ê±ï¿½æ´¢ram=========
wire [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0]ram_temp_output_data;//ï¿½ï¿½Ê±ramï¿½ï¿½ï¿½Ý³ï¿½ï¿½ï¿½
reg [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0]ram_temp_output_data_delay_one;//ï¿½ï¿½Ê±ramï¿½ï¿½ï¿½Ý³ï¿½ï¿½ï¿½
reg [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0]ram_temp_output_data_delay_two;//ï¿½ï¿½Ê±ramï¿½ï¿½ï¿½Ý³ï¿½ï¿½ï¿½
Configurable_RAM_Norm #(
WIDTH_TOTAL_DATA*KERNEL_NUM,WIDTH_TEMP_RAM_ADDR_SIZE
)Compute_Temp_Ram(
    .clk(clk),
    .read_address(ram_temp_read_address),
    .write_address(ram_temp_write_address),
    .input_data(data_fifo_out),
    .write_enable(rd_en_fifo),
    .output_data(ram_temp_output_data)
    );
    
always@(posedge clk)
ram_temp_output_data_delay_one<=ram_temp_output_data;
always@(posedge clk)
ram_temp_output_data_delay_two<=ram_temp_output_data_delay_one;
//-------------featureÍ¼Æ¬ï¿½ï¿½ï¿½Ý¶ï¿½Ó¦---------

reg [`PICTURE_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_data_in [0:COMPUTE_CHANNEL_IN_NUM-1];

generate 
  genvar d;//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½
    genvar c;//ï¿½ï¿½ï¿½Úµï¿½ï¿½ï¿½?
  for(d=0;d<COMPUTE_CHANNEL_IN_NUM;d=d+1)begin
    for(c=0;c<KERNEL_NUM;c=c+1)begin
    always@(posedge clk)
     compute_data_in[d][(c+1)*`PICTURE_NUM*`WIDTH_DATA-1:c*`PICTURE_NUM*`WIDTH_DATA]
           <= ram_temp_output_data_delay_two[(c*COMPUTE_CHANNEL_IN_NUM+d+1)*`PICTURE_NUM*`WIDTH_DATA-1:
             (c*COMPUTE_CHANNEL_IN_NUM+d)*`PICTURE_NUM*`WIDTH_DATA];
    end
end
endgenerate








//wire [`PICTURE_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_data_in [0:COMPUTE_CHANNEL_IN_NUM-1];
//generate 
//  genvar d;//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½
//    genvar c;//ï¿½ï¿½ï¿½Úµï¿½ï¿½ï¿½?
//  for(d=0;d<COMPUTE_CHANNEL_IN_NUM;d=d+1)begin
//    for(c=0;c<KERNEL_NUM;c=c+1)begin
//    assign compute_data_in[d][(c+1)*`PICTURE_NUM*`WIDTH_DATA-1:c*`PICTURE_NUM*`WIDTH_DATA]
//           = ram_temp_output_data[(c*COMPUTE_CHANNEL_IN_NUM+d+1)*`PICTURE_NUM*`WIDTH_DATA-1:
//             (c*COMPUTE_CHANNEL_IN_NUM+d)*`PICTURE_NUM*`WIDTH_DATA];
//    end
//end
//endgenerate
//-------------È¨ï¿½ï¿½ï¿½ï¿½ï¿½Ý¶ï¿½Ó¦---------
//reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_weight_in [0:COMPUTE_CHANNEL_OUT_NUM-1];
//generate 
//genvar x;//ï¿½ï¿½ï¿½Í¨ï¿½ï¿???
//  genvar y;//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½
//    genvar z;//ï¿½ï¿½ï¿½Úµï¿½ï¿½ï¿½?
//  for(x=0;x<COMPUTE_CHANNEL_OUT_NUM;x=x+1)begin
//    for(y=0;y<COMPUTE_CHANNEL_IN_NUM;y=y+1)begin
//      for(z=0;z<KERNEL_NUM;z=z+1)begin
//      always@(posedge clk)
//   compute_weight_in[x][(y*KERNEL_NUM+z+1)*`WIDTH_DATA-1:(y*KERNEL_NUM+z)*`WIDTH_DATA]
//        <= Data_Out_Weight[(z*COMPUTE_CHANNEL_OUT_NUM*COMPUTE_CHANNEL_IN_NUM+x*COMPUTE_CHANNEL_IN_NUM+y+1)*`WIDTH_DATA-1
//           :(z*COMPUTE_CHANNEL_OUT_NUM*COMPUTE_CHANNEL_IN_NUM+x*COMPUTE_CHANNEL_IN_NUM+y)*`WIDTH_DATA];
//  end
// end
//end
//endgenerate
reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_weight_in [0:COMPUTE_CHANNEL_OUT_NUM-1];
generate 
genvar x;//ï¿½ï¿½ï¿½Í¨ï¿½ï¿???
  genvar y;//ï¿½ï¿½ï¿½ï¿½Í¨ï¿½ï¿½
  for(x=0;x<COMPUTE_CHANNEL_OUT_NUM;x=x+1)begin
    for(y=0;y<COMPUTE_CHANNEL_IN_NUM;y=y+1)begin
      always@(posedge clk)
   compute_weight_in[x][(y*KERNEL_NUM+1)*`WIDTH_DATA-1:(y*KERNEL_NUM)*`WIDTH_DATA]
        <= Data_Out_Weight[(x*COMPUTE_CHANNEL_IN_NUM+y+1)*`WIDTH_DATA-1
           :(x*COMPUTE_CHANNEL_IN_NUM+y)*`WIDTH_DATA];
  end
 end
endgenerate

reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_weight_in_one   [0:COMPUTE_CHANNEL_OUT_NUM-1];
generate
genvar delay_i;
    for(delay_i=0;delay_i<COMPUTE_CHANNEL_OUT_NUM;delay_i=delay_i+1)begin
always@(posedge clk)
compute_weight_in_one[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0];

end
endgenerate
//-----------------8-27-------------------
//reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0] compute_weight_in_one   [0:COMPUTE_CHANNEL_OUT_NUM-1];
//reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0] compute_weight_in_two   [0:COMPUTE_CHANNEL_OUT_NUM-1];
//reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0] compute_weight_in_three [0:COMPUTE_CHANNEL_OUT_NUM-1];
//generate
//genvar delay_i;
//    for(delay_i=0;delay_i<COMPUTE_CHANNEL_OUT_NUM;delay_i=delay_i+1)begin
//always@(posedge clk)
//compute_weight_in_one[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0];

//always@(posedge clk)
//compute_weight_in_two[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*6-1:COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3];

//always@(posedge clk)
//compute_weight_in_three[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*9-1:COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*6];

//end
//endgenerate


//---------------ï¿½ï¿½ï¿½ï¿½Ä£ï¿½ï¿½-------------
wire [`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA_OUT*2-1:0] compute_data_out  [0:COMPUTE_CHANNEL_OUT_NUM-1];
wire  [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] temp_weight_three_to_one[0:COMPUTE_CHANNEL_OUT_NUM-1];
generate
genvar j,k;
for(j=0;j<COMPUTE_CHANNEL_OUT_NUM;j=j+1)begin
assign  temp_weight_three_to_one[j]=compute_weight_in_one[j];
    for(k=0;k<COMPUTE_CHANNEL_IN_NUM;k=k+1)begin
        conv2d_1_1 #(
        .CONV_TYPE(CONV_TYPE),
        .KERNEL_NUM(KERNEL_NUM)
        ) conv2d_1_1(
          .clk(clk),
          .data_in(compute_data_in[k]),
          .weight_in(temp_weight_three_to_one[j][(k+1)*KERNEL_NUM*`WIDTH_DATA-1:k*KERNEL_NUM*`WIDTH_DATA]),
          .data_out(compute_data_out[j][(k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:k*`PICTURE_NUM*`WIDTH_DATA_OUT*2])  
         );
    end    
     channel_in_accumulation#(
            .COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM)
            )channel_in_accumulation
            (
             .clk(clk),
             .data_in(compute_data_out[j]),
             .data_out(data_result_temp[j])
    );
end
endgenerate  
//-------------ï¿½Û¼ï¿½-----------------------
generate
genvar m;
for(m=0;m<COMPUTE_CHANNEL_OUT_NUM;m=m+1)begin
accumulation  accumulation(
    .clk(clk),
    .rst(rst),
    .data_result_temp(data_result_temp[m]),
    .First_Compute_Complete(First_Compute_Complete[m]),
    .M_Data_out(M_Data_out[(m+1)*`PICTURE_NUM*WIDTH_DATA_ADD-1:m*`PICTURE_NUM*WIDTH_DATA_ADD])
    ); 
end
endgenerate


integer conv_out_data;
initial begin
	conv_out_data=$fopen("11_conv11_conv_data.txt");
end
always@(posedge clk)begin
	if(M_Valid)
    	$fwrite(conv_out_data,"%h\n",M_Data_out);
end


endmodule
