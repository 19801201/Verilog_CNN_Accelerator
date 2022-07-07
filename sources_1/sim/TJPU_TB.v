`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


//////  conv 33 tb   //////
//////////////////////////////////////////////////////////////////////////////////


module TJPU_TB#(parameter
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
wire [128-1:0]S_Data;
wire S_Valid,S_Ready;
reg EN;
wire [128-1:0]M_Data;
wire M_Valid;
reg M_Ready;
//DMA
wire DMA_Read_Start,DMA_Write_Start;
//wire [3:0]State;    
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
//  Control_1_1��Control_3_3 :4'b0001:para , 4'b0010:����   4'b1111: ���ж� --> ȫ������0
//  Control_RE[3:0]          :4'b0001:concat 4'b0010:route  4'b0100 maxpool 4'b1000 upsample    
//  Control_RE[7:4]  concat  :4'b0001 para   4'b0010 sdata  4'b1111: ���ж� --> ȫ������0
//  Switch = 32'b0000_0000_0000_0000_0000_0000_0001_0001;
    Switch = 4'b0001;
    Control_3_3 = 4'b0001;
    EN=1'b1;
//     //conv1
//	Reg_4=32'b0000_0000_0100_0000_0001_0000_0000_0000;  //  64    16 
//    Reg_5=32'b0000_0000_0000_0000_0000_0000_0000_0000;

//    //conv2
//    Reg_4=32'b0000_0000_1000_0000_0001_0000_0000_0000;  //  128    16 
//    Reg_5=32'b0000_0000_0000_0000_0000_0000_0000_0000;

    //rs1_conv4
//    Reg_4=32'b0000_0001_0000_0000_0001_0000_0000_0011; // 256  16  1 1
//    Reg_5=32'b0001_0000_0000_0000_0000_0000_0100_0000; // 64  64
    
    //rs3_conv4
//    Reg_4=32'b0001_0000_0000_0000_0100_0000_0000_0001; // 4096  64  1
//    Reg_5=32'b0100_0000_0000_0000_0000_0001_0000_0000; // 256  256
    
    //rs2_conv4
    Reg_4=32'b0000_0100_0000_0000_0010_0000_0000_0001; // 1024  32  1
    Reg_5=32'b0010_0000_0000_0000_0000_0000_1000_0000; // 128  128
    
    #10  Control_3_3 =4'b0000;
    
    while(State_3_3!=4'b1111) begin
        #10  Control_3_3 =4'b0000;
    end
    #10  Control_3_3 =4'b1111;
    #10  Switch = 4'b0000;
    #100;
    while(State_3_3!=4'b0000) begin
        #10  ;
    end
    #10;

    Switch = 4'b0001;
    Control_3_3 = 4'b0010;
    EN=1'b0;
    
//    // conv1
//	Reg_4=32'b0000_0100_0000_1101_0000_0000_0010_0000; // 16  416  32
//    Reg_5=32'b1110_0100_0000_0000_0000_0001_1010_0000; //  1  1  1   416
//    Reg_6=32'b0000_0000_1000_1000_0000_0000_0001_0101; // 
//    Reg_7=32'b0000_0000_0100_1110_0000_0000_0000_0000; //  0  78 
 
    // conv2
//    Reg_4=32'b0000_1000_0000_0110_1000_0000_0100_0000; // 32  208  64
//    Reg_5=32'b0110_0110_0000_0000_0000_0000_1101_0000; //  1  1  1   208
//    Reg_6=32'b0000_1000_0000_0000_1000_1000_1001_0101; // 
//    Reg_7=32'b0100_1110_0100_1101_0000_0000_0000_0000; //  78  77 
    
//    rs1_conv4
//    Reg_4=32'b0001_0000_0000_0011_0100_0000_0100_0000;    // 64  104  64
//    Reg_5=32'b0000_0000_0000_0000_0000_0000_0110_1000;  //  0 104
//    Reg_6=32'b0000_0000_0000_1000_0000_1000_1001_0101; //   
//    Reg_7=32'b0000_0000_0101_1000_0000_0000_0000_0000; //    88
//    rs3_conv4
//    Reg_4=32'b0100_0000_0000_0000_1101_0001_0000_0000;    // 256  26  256
//    Reg_5=32'b0000_0010_0000_0000_0000_0000_0001_1010;  //  1 26
//    Reg_6=32'b0000_0000_1000_1001_0000_0000_0001_0101; //   
//    Reg_7=32'b0000_0000_0101_0011_0000_0000_0000_0000; //    83
    
 //    rs2_conv4
    Reg_4=32'b0010_0000_0000_0001_1010_0000_1000_0000;    // 128  52  128
    Reg_5=32'b0000_0000_0000_0000_0000_0000_0011_0100;  //  1 52
    Reg_6=32'b0001_0000_0000_0000_0000_1000_0001_0101; //   
    Reg_7=32'b0000_0000_0101_0010_0000_0000_0000_0000; //    82   

//    #60;
//    EN = 1'b0;
    while(State_3_3!=4'b1111) begin
        #10  Control_3_3 =4'b0000;
    end
    #10  Control_3_3 =4'b1111;
    
    #100;
    while(State_3_3!=4'b0000)  begin
        #10  ;
    end
    
end   


integer end_out_data;
initial
begin
end_out_data=$fopen("11_out_conv2_data.txt");

end
always@(posedge clk)begin
if(M_Valid)
    $fwrite(end_out_data,"%h\n",M_Data);
end

endmodule
