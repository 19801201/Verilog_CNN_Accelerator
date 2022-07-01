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
    CONV_CONTROL              =  32'h0000_0001,
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
wire   [255:0]  S_Data;
wire S_Valid,S_Ready;
reg EN;
wire   [255:0]  M_Data ;
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

    Switch = 4'b0001;
    Control_3_3 = 4'b0001;
    EN=1'b1;
    
    Reg_4=32'b0000_0000_0010_0000_0000_1000_0000_0000;  //  32  8      
    Reg_5=32'b0000_0000_0000_0000_0000_0000_0000_0000;
    
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
    
    // conv1
	Reg_4=32'h040D0020; // 32  208  64
    Reg_5=32'hE40001A0; //  1  1  1   208
    Reg_6=32'h00880015; //   
    Reg_7=32'h004E0040; //  66  66 


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
end_out_data=$fopen("11_out_conv33_data.txt");

end
always@(posedge clk)begin
if(M_Valid)
    $fwrite(end_out_data,"%h\n",M_Data);
end

endmodule
