`timescale 1ns / 1ps

`include"./Para.v"
module Conv_Norm#(parameter
KERNEL_NUM                   =       9,
CONV_TYPE                    =       "CONV_3_3",//CONV_3_3
//COMPUTE_CHANNEL_IN_NUM       =       8,
COMPUTE_CHANNEL_IN_NUM       =       16,  //************************************
COMPUTE_CHANNEL_OUT_NUM      =       8,
WIDTH_RAM_ADDR_SIZE          =       13,
WIDTH_TEMP_RAM_ADDR_SIZE     =       8,//temp save feature ram
WIDTH_FEATURE_SIZE           =       12,
WIDTH_CHANNEL_NUM_REG        =       10,
WIDTH_DATA_ADD               =       32,
WIDTH_WEIGHT_NUM             =       15,
WIDTH_BIAS_RAM_ADDRA         =       7
)(  
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start_Cu,
    input  Start_Pa,
    //weight ram
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Para_Data,
    input   S_Para_Valid,
    output  S_Para_Ready,
    output  Write_Block_Complete,
    input [WIDTH_CHANNEL_NUM_REG-1:0] Weight_Channel_In_REG,
    input [WIDTH_CHANNEL_NUM_REG-1:0] Weight_Channel_Out_REG,
    input CONV_11_REG,
//    input CONV_11_Weight_REG,
    input CONV_11_Parallel,
//    input CONV_11_Weight_Parallel,  
    
//    output[WIDTH_RAM_ADDR_TURE-1:0] Bram_Addrb,
    output Compute_Complete,
   
//    input  [`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*KERNEL_NUM*`WIDTH_DATA-1:0]   S_Data,  
    input  [`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*KERNEL_NUM*`WIDTH_DATA-1:0]   S_Data,
    input  [KERNEL_NUM  -   1   :   0]   S_Valid,
    output     S_Ready,
    
    output [`PICTURE_NUM*COMPUTE_CHANNEL_OUT_NUM*WIDTH_DATA_ADD-1:0]   M_Data_out,
    input   M_ready,
    output  reg M_Valid,
    

//    input  [WIDTH_RAM_ADDR_TURE-1'b1:0] Ram_Read_Addrb_Base,
    
    input  [WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,
//    input  [WIDTH_FEATURE_SIZE-1:0] RowNum_After_Padding,
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_In_Num_REG,
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_Out_Num_REG,
    
    input  [WIDTH_WEIGHT_NUM-1:0] Weight_Single_Num_REG,
    input  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Num_REG,
    input  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Addrb,  
    output [32*`Channel_Out_Num-1:0]Data_Out_Bias,  //bias
    output [32*`Channel_Out_Num-1:0]Data_Out_Scale,  //scale
    output [32*`Channel_Out_Num-1:0]Data_Out_Shift  //shift

    );

//localparam  WIDTH_TOTAL_DATA_8 = `PICTURE_NUM*8*`WIDTH_DATA;  // 64
localparam  WIDTH_TOTAL_DATA = `PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA;
 wire [WIDTH_FEATURE_SIZE-1:0]   COMPUTE_TIMES_CHANNEL_IN_REG;
 wire [WIDTH_FEATURE_SIZE-1:0]   Conv11_Parallelism;
 wire [WIDTH_FEATURE_SIZE-1:0]   COMPUTE_TIMES_CHANNEL_OUT_REG;
 wire [WIDTH_FEATURE_SIZE-1:0]   S_Count_Fifo,M_Count_Fifo;
//assign COMPUTE_TIMES_CHANNEL_IN_REG  = Channel_In_Num_REG>>4; 
//assign COMPUTE_TIMES_CHANNEL_IN_REG  = Channel_In_Num_REG>>6;  

assign Conv11_Parallelism = CONV_11_Parallel ? Channel_In_Num_REG>>6 : Channel_In_Num_REG>>7; // 64 or 128
assign COMPUTE_TIMES_CHANNEL_IN_REG  = (CONV_11_REG) ? Conv11_Parallelism : Channel_In_Num_REG>>4;
assign COMPUTE_TIMES_CHANNEL_OUT_REG = Channel_Out_Num_REG>>3;
 
//===========wire_load,control part=========

wire [WIDTH_RAM_ADDR_SIZE-1:0] Weight_Addrb;
wire [9*COMPUTE_CHANNEL_IN_NUM*COMPUTE_CHANNEL_OUT_NUM*8-1:0]  Data_Out_Weight;
//wire [9*COMPUTE_CHANNEL_IN_NUM*COMPUTE_CHANNEL_OUT_NUM*8-1:0]  Data_Out_Weight_q;
//wire [32*`Channel_Out_Num-1:0]Data_Out_Bias_q;  //bias
//wire [32*`Channel_Out_Num-1:0]Data_Out_Scale_q;  //scale
//wire [32*`Channel_Out_Num-1:0]Data_Out_Shift_q;  //shift

//always@(posedge clk)begin
//    Data_Out_Weight <= Data_Out_Weight_q;
//    Data_Out_Bias <= Data_Out_Bias_q;
//    Data_Out_Scale <= Data_Out_Scale_q;
//    Data_Out_Shift <= Data_Out_Shift_q;
//end


wire rd_en_fifo;
wire fifo_compute_ready;
wire [WIDTH_TEMP_RAM_ADDR_SIZE-1:0] ram_temp_read_address;
wire [WIDTH_TEMP_RAM_ADDR_SIZE-1:0] ram_temp_write_address;
wire First_Compute_Complete_Temp;
wire [`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:0] data_result_temp[0:COMPUTE_CHANNEL_OUT_NUM-1];
//wire M_Valid_Temp;
 compute_control #(
    .WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE),   
    .WIDTH_FEATURE_SIZE(WIDTH_FEATURE_SIZE),  
    .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG),
    .WIDTH_TEMP_RAM_ADDR_SIZE(WIDTH_TEMP_RAM_ADDR_SIZE)
)
 compute_control(
    .clk(clk),
    .rst(rst),
    .Start_Cu(Start_Cu),

    .Compute_Complete(Compute_Complete),//
    .First_Compute_Complete(First_Compute_Complete_Temp),//
    //
    .compute_fifo_ready(fifo_compute_ready),
    .rd_en_fifo(rd_en_fifo),    
    //
    .M_ready(M_ready),      
    .M_Valid(M_Valid_Temp),//out
    //
    .weight_addrb(Weight_Addrb),
    //
    .ram_temp_read_address(ram_temp_read_address),
    .ram_temp_write_address(ram_temp_write_address),
    //
    .COMPUTE_TIMES_CHANNEL_IN_REG(COMPUTE_TIMES_CHANNEL_IN_REG) ,//
//    .COMPUTE_TIMES_CHANNEL_IN_REG_8(COMPUTE_TIMES_CHANNEL_IN_REG_8),
    .COMPUTE_TIMES_CHANNEL_OUT_REG(COMPUTE_TIMES_CHANNEL_OUT_REG),//
    .ROW_NUM_CHANNEL_OUT_REG(Row_Num_Out_REG),
    .S_Count_Fifo(S_Count_Fifo),
    .M_Count_Fifo(M_Count_Fifo)
    );
//-----------------Instant_Load_Weight----------------
always@(posedge clk)
M_Valid<=M_Valid_Temp;
reg First_Compute_Complete;
always@(posedge clk)
First_Compute_Complete<=First_Compute_Complete_Temp;
Load_Weight_Bias #(
   .WIDTH_WEIGHT_NUM (WIDTH_WEIGHT_NUM),
   .WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE),
   .WIDTH_BIAS_RAM_ADDRA(WIDTH_BIAS_RAM_ADDRA),
   .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG),
   .KERNEL_NUM              (KERNEL_NUM),
   .COMPUTE_CHANNEL_IN_NUM  (COMPUTE_CHANNEL_IN_NUM),
   .COMPUTE_CHANNEL_OUT_NUM (COMPUTE_CHANNEL_OUT_NUM)
    )
    Load_Weight_Bias
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
    .Weight_Channel_In_REG(Weight_Channel_In_REG),
    .Weight_Channel_Out_REG(Weight_Channel_Out_REG),
    .CONV_11_Weight_REG(CONV_11_REG),
    .CONV_11_Weight_Parallel(CONV_11_Parallel),
//    .Ram_Read_Addrb_Base(Ram_Read_Addrb_Base),
 
    .Data_Out_Weight (Data_Out_Weight),   //weight

    .Bias_Addrb (Bias_Addrb),  
    .Data_Out_Bias (Data_Out_Bias),  //bias
    .Data_Out_Scale (Data_Out_Scale),  //scale
    .Data_Out_Shift (Data_Out_Shift)  //shift
    );
   
    

wire  [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0] data_fifo_out;  //  128 * 9 
wire  [KERNEL_NUM - 1 : 0]   S_Ready_temp,fifo_compute_ready_temp;
assign S_Ready              =   S_Ready_temp[0];
assign fifo_compute_ready   =   fifo_compute_ready_temp[0];
generate 
  genvar i;
  for(i=0;i<KERNEL_NUM;i=i+1)begin
    Configurable_FIFO #(
            .WIDTH(WIDTH_TOTAL_DATA),
            .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
            )
        fifo_feature      
    (    
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(S_Data[(i+1)*WIDTH_TOTAL_DATA-1:i*WIDTH_TOTAL_DATA]),
     .wr_en(S_Valid[i]),
 
     .rd_en(rd_en_fifo),
     .dout(data_fifo_out[(i+1)*WIDTH_TOTAL_DATA-1:i*WIDTH_TOTAL_DATA]),
   
     .M_count(M_Count_Fifo),  //back
     .M_Ready(fifo_compute_ready_temp[i]),
     .S_count(S_Count_Fifo),   //front
     .S_Ready(S_Ready_temp[i])
    ); 

//    assign data_fifo_out[(i+1)*128-1:i*128] = {data_fifo_out_q[i*128+64-1:i*128],data_fifo_out_q[(i+1)*128-1:i*128+64]};
end
endgenerate 

wire [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0]ram_temp_output_data;
reg [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0]ram_temp_output_data_delay_one;
reg [WIDTH_TOTAL_DATA*KERNEL_NUM-1:0]ram_temp_output_data_delay_two;
Configurable_RAM_Norm #(
WIDTH_TOTAL_DATA*KERNEL_NUM,WIDTH_TEMP_RAM_ADDR_SIZE
)Configurable_RAM_Norm(
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


reg [`PICTURE_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_data_in [0:COMPUTE_CHANNEL_IN_NUM-1];

generate 
  genvar d;
    genvar c;
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
//  genvar d;
//    genvar c;
//  for(d=0;d<COMPUTE_CHANNEL_IN_NUM;d=d+1)begin
//    for(c=0;c<KERNEL_NUM;c=c+1)begin
//    assign compute_data_in[d][(c+1)*`PICTURE_NUM*`WIDTH_DATA-1:c*`PICTURE_NUM*`WIDTH_DATA]
//           = ram_temp_output_data[(c*COMPUTE_CHANNEL_IN_NUM+d+1)*`PICTURE_NUM*`WIDTH_DATA-1:
//             (c*COMPUTE_CHANNEL_IN_NUM+d)*`PICTURE_NUM*`WIDTH_DATA];
//    end
//end
//endgenerate

reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] compute_weight_in [0:COMPUTE_CHANNEL_OUT_NUM-1];
generate 
genvar x;
  genvar y;
    genvar z;
  for(x=0;x<COMPUTE_CHANNEL_OUT_NUM;x=x+1)begin
    for(y=0;y<COMPUTE_CHANNEL_IN_NUM;y=y+1)begin
      for(z=0;z<KERNEL_NUM;z=z+1)begin
      always@(posedge clk)
   compute_weight_in[x][(y*KERNEL_NUM+z+1)*`WIDTH_DATA-1:(y*KERNEL_NUM+z)*`WIDTH_DATA]
        <= Data_Out_Weight[(z*COMPUTE_CHANNEL_OUT_NUM*COMPUTE_CHANNEL_IN_NUM+x*COMPUTE_CHANNEL_IN_NUM+y+1)*`WIDTH_DATA-1
           :(z*COMPUTE_CHANNEL_OUT_NUM*COMPUTE_CHANNEL_IN_NUM+x*COMPUTE_CHANNEL_IN_NUM+y)*`WIDTH_DATA];
  end
 end
end
endgenerate
//-----------------8-27-------------------
reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0] compute_weight_in_one   [0:COMPUTE_CHANNEL_OUT_NUM-1];
reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0] compute_weight_in_two   [0:COMPUTE_CHANNEL_OUT_NUM-1];
reg [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0] compute_weight_in_three [0:COMPUTE_CHANNEL_OUT_NUM-1];
generate
genvar delay_i;
    for(delay_i=0;delay_i<COMPUTE_CHANNEL_OUT_NUM;delay_i=delay_i+1)begin
always@(posedge clk)
compute_weight_in_one[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3-1:0];

always@(posedge clk)
compute_weight_in_two[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*6-1:COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*3];

always@(posedge clk)
compute_weight_in_three[delay_i]<=compute_weight_in[delay_i][COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*9-1:COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*6];

end
endgenerate


//   
wire [`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA_OUT*2-1:0] compute_data_out  [0:COMPUTE_CHANNEL_OUT_NUM-1];
wire  [COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA*KERNEL_NUM-1:0] temp_weight_three_to_one[0:COMPUTE_CHANNEL_OUT_NUM-1];
//reg [`PICTURE_NUM*COMPUTE_CHANNEL_IN_NUM*`WIDTH_DATA_OUT*2-1:0] compute_data_out_delay  [0:COMPUTE_CHANNEL_OUT_NUM-1];


generate
genvar j,k;
for(j=0;j<COMPUTE_CHANNEL_OUT_NUM;j=j+1)begin         
assign  temp_weight_three_to_one[j]={compute_weight_in_three[j],compute_weight_in_two[j],compute_weight_in_one[j]};
    for(k=0;k<COMPUTE_CHANNEL_IN_NUM;k=k+1)begin
        conv_2d #(
        .CONV_TYPE(CONV_TYPE),
        .KERNEL_NUM(KERNEL_NUM)
        ) conv_2d(
          .clk(clk),
          .data_in(compute_data_in[k]),
          .weight_in(temp_weight_three_to_one[j][(k+1)*KERNEL_NUM*`WIDTH_DATA-1:k*KERNEL_NUM*`WIDTH_DATA]),
          .data_out(compute_data_out[j][(k+1)*`PICTURE_NUM*`WIDTH_DATA_OUT*2-1:k*`PICTURE_NUM*`WIDTH_DATA_OUT*2])  
         );
    end    
        // 16 channel in  add  logic  
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
//-------------8 channel out num add logic  -----------------------
generate
genvar m;
for(m=0;m<COMPUTE_CHANNEL_OUT_NUM;m=m+1)begin
accumulation  accumulation(
    .clk(clk),
    .rst(rst),
    .data_result_temp(data_result_temp[m]),
    .First_Compute_Complete(First_Compute_Complete),
    .M_Data_out(M_Data_out[(m+1)*`PICTURE_NUM*WIDTH_DATA_ADD-1:m*`PICTURE_NUM*WIDTH_DATA_ADD])
    ); 
end
endgenerate

integer conv33_data;
initial
begin
conv33_data=$fopen("11_conv33.txt");

end
always@(posedge clk)begin
if(M_Valid)
    $fwrite(conv33_data,"%h",M_Data_out,",\n");
end

endmodule