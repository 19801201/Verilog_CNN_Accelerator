`timescale 1ns / 1ps

//////   split (route)  tb  //////   4,64,104,104


module TB_Split#(parameter
    FILTER_SIZE               =  3,//????????
    CHANNEL_IN_NUM            =  8 ,
    CHANNEL_OUT_NUM           =  8,
    WEIGHT_IN_NUM             =  8,
    WIDTH_RAM_SIZE            =  12,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_WEIGHT_SIZE         =  20,
    WIDTH_OTHERS_SIZE         =  10,
    CONV_CONTROL              =  32'h0000_0001,//3X3??
    KERNEL_NUM                =  9,
    WIDTH_CHANNEL_NUM         =  10 
    
);
reg  clk;
reg  rst;

wire [3:0] State_3_3;
wire [3:0] State_1_1;
wire [3:0] State_RE;
reg [3:0] Control_3_3;
reg [3:0] Control_1_1;
reg [7:0] Control_RE;
reg [3:0] Switch;

reg [31:0] Reg_4;
reg [31:0] Reg_5;
reg [31:0] Reg_6;
reg [31:0] Reg_7;
wire DMA_read_feature,DMA_read_para;
wire DMA_write_valid;
wire   [127:0]  S_Data;
wire S_Valid,S_Ready;
reg EN;
wire     [127:0]M_Data ;
wire M_Valid;
reg M_Ready;
//DMA
wire DMA_Read_Start,DMA_Write_Start;
// wire [3:0]State;    
reg introut_3x3_Wr;
 simulation_weight_feature_stream  www
(
.clk(clk),
.rst(rst),
.EN(EN),
.DMA_read_para(DMA_read_para),
.DMA_read_feature(DMA_read_feature),
.DMA_write_valid(DMA_write_valid),
.S_Data(S_Data),
.S_Valid(S_Valid),
.S_Ready(S_Ready)
    );
TJPU tjpu(
    .clk(clk),
    .rst(rst),
    .State_3_3(State_3_3),
    .State_1_1(State_1_1),
    .Control_3_3(Control_3_3),
    .Control_1_1(Control_1_1),
    .Control_RE(Control_RE),
    .State_RE(State_RE),
    .Switch(Switch),
    .Reg_4(Reg_4),
    .Reg_5(Reg_5),
    .Reg_6(Reg_6),
    .Reg_7(Reg_7),
    //DMA 
    .DMA_Read_Start(DMA_Read_Start),
    .DMA_Write_Start(DMA_Write_Start),
    
    /////////////////////////////////
    //Stream read
    .S_Data(S_Data),
    .S_Valid(S_Valid),
    .S_Ready(S_Ready),
    /////////////////////////////////
    //Stream write
    .M_Data(M_Data),
    .M_Ready(M_Ready),
    .M_Valid(M_Valid),
    .introut_3x3_Wr(introut_3x3_Wr)

);

assign DMA_read_para  =(EN==1'b1)? DMA_Read_Start:0;
assign DMA_read_feature =(EN==1'b0)?DMA_Read_Start:0;

always#5 clk=~clk; 
  
initial  begin 
    M_Ready=1'b1;
    EN=1'b1;
    clk=0;
    #10 rst=1;
    #10 rst=0;
//  Switch[3:0]              :4'b0001:Conv33 4'b0010:Conv11 4'b1000:ReShape
//  Control_1_1、Control_3_3 :4'b0001:para , 4'b0010:计算  4'b1111: 清中断 --> 全部自清0
//  Control_RE[3:0]          :4'b0001:concat 4'b0010:route  4'b0100 maxpool 4'b1000 upsample    
//  Control_RE[7:4]   concat :4'b0001 para   4'b0010  sdata  4'b1111: 清中断 --> 全部自清0
//  Switch = 32'b0000_0000_0000_0000_0000_0000_0001_0001;   
    
    //////      split  逻辑   //////  
    #10
    EN=1'b0;
    Switch = 4'b1000;
    Control_RE[3:0] = 4'b0010;
 
	Reg_4=32'b0000_0000_0000_0000_0000_0000_0000_0000; //  
	Reg_5=32'b0000_0000_0000_0000_0000_0000_0000_0000;  // 
	Reg_6=32'b0000_0000_0000_0000_0000_0000_0000_0000;//    
	Reg_7=32'b0000_0000_0000_0100_0000_0000_0011_0100; //   128  52
    

	#10
	Control_RE[3:0] = 4'b0000;
    #60;
    while(State_RE!=4'b1111) begin
        #10  Control_RE[3:0] = 4'b0000;
    end
    
    #10  Control_RE[3:0] =4'b1111;
    
    #100;
    while(State_RE!=4'b0000)  begin
        #10  ;
    end
   
end   


integer end_out_data;
initial
begin
end_out_data=$fopen("11_split_out_data.txt");

end
always@(posedge clk)begin
if(M_Valid)
    $fwrite(end_out_data,"%h\n",M_Data);
end


endmodule