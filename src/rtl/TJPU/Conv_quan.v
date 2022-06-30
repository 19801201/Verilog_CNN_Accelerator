`timescale 1ns / 1ps


`include"../Para.v"
module Conv_quan#(parameter
    CHANNEL_OUT_NUM           =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,
    WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
    WIDTH_BIAS_RAM_ADDRA      =   8
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    
    input  Start,
    input  [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]   S_Data,
    input           S_Valid,
    output          S_Ready,
    input           Leaky_REG,

    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] bias_data_in,
    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] scale_data_in,
    input [WIDTH_DATA_ADD * CHANNEL_OUT_NUM - 1 : 0] shift_data_in,
    input [`WIDTH_DATA-1 : 0] Zero_Point_REG3,
    output[WIDTH_BIAS_RAM_ADDRA-1:0] bias_addrb,
    
    output [`PICTURE_NUM*CHANNEL_OUT_NUM*`WIDTH_DATA-1:0]   M_Data,
    input            M_Ready,
    output           M_Valid,
    
    input  [WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,      
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_Out_Num_REG
    );

wire  [WIDTH_FEATURE_SIZE-1:0] S_Count_Fifo;

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

reg M_Valid_Temp_Delay[0:31];
wire M_Valid_Temp;
always@(posedge clk )begin
M_Valid_Temp_Delay[0]<=M_Valid_Temp;     // 1 clk delay
end
generate 
genvar m;          
for(m=0;m<31;m=m+1)begin            
    always@(posedge clk)begin
        M_Valid_Temp_Delay[m+1]<=M_Valid_Temp_Delay[m];          
    end                   
end
endgenerate

assign M_Valid_Zero=M_Valid_Temp_Delay[10]; 

assign M_Valid_Leaky=M_Valid_Temp_Delay[15];
wire rd_en_fifo,fifo_ready;
wire [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]bias_data_out;
wire [`PICTURE_NUM*WIDTH_DATA_ADD*CHANNEL_OUT_NUM-1:0]scale_data_out;
wire [`PICTURE_NUM*`WIDTH_DATA*2*CHANNEL_OUT_NUM -1:0]shift_data_out;

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
    
    .Row_Num_Out_REG(Row_Num_Out_REG),
    .Channel_Out_Num_REG(Channel_Out_Num_REG),  
    .S_Count_Fifo(S_Count_Fifo)
    );

 Conv_Bias#(
           .CHANNEL_OUT_NUM      (CHANNEL_OUT_NUM), //=  8,
           .WIDTH_FEATURE_SIZE   (WIDTH_FEATURE_SIZE), //=  12,
           .WIDTH_DATA_ADD       (WIDTH_DATA_ADD), //=  32,
           .WIDTH_CHANNEL_NUM_REG(WIDTH_CHANNEL_NUM_REG)
)Conv_Bias(
    .clk(clk),
    .rst(rst),
    .Next_Reg(Next_Reg),
    
    .S_Data(S_Data),
    .S_Valid(S_Valid),
    .S_Ready(S_Ready),
    .fifo_ready(fifo_ready),
    .rd_en_fifo(rd_en_fifo),

    .bias_data_in(bias_data_in),
    
    .M_Data(bias_data_out),
    .Channel_Out_Num_REG(Channel_Out_Num_REG),
    
    .Row_Num_Out_REG(Row_Num_Out_REG),
    .S_Count_Fifo(S_Count_Fifo)
    );
//------------------scale--------------------
Conv_Scale#(
           .CHANNEL_OUT_NUM      (CHANNEL_OUT_NUM), //=  8,
           .WIDTH_DATA_ADD       (WIDTH_DATA_ADD) //=  32,
)Conv_Scale(
           .clk(clk),
           .rst(rst),
           .S_Data(bias_data_out),
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

wire   [`AXI_WIDTH_DATA-1:0]   M_Zero_Data;
wire   [`AXI_WIDTH_DATA-1:0]   M_Leaky_Data;

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
leakyrelu leakyrelu_u(
	.clk						(clk),
	.leaky_data_in              (M_Zero_Data),
	.zero_data_in               (Zero_Point_REG3),
	.leaky_data_out             (M_Leaky_Data)
); 

assign  M_Data = (Leaky_REG == 1'b1)?M_Zero_Data:M_Leaky_Data;
assign  M_Valid = (Leaky_REG == 1'b1)? M_Valid_Zero:M_Valid_Leaky;

endmodule
