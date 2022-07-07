`timescale 1ns / 1ps

/////////////////   Concat  tb  ///////////////

module TB_Reshape();
reg  clk;
reg  rst;
reg [3:0] Switch;
reg [31:0] Reg_4;
reg [31:0] Reg_5;
reg [31:0] Reg_6;
reg [31:0] Reg_7;
reg [31:0] Reg_8;
reg [31:0] Reg_9;
wire DMA_read_feature,DMA_read_feature_2,DMA_read_para;
wire DMA_write_valid;
wire   [127:0]  S_Data;
wire S_Valid,S_Ready;
wire   [127:0]  S_Data_1;
wire S_Valid_1,S_Ready_1;
reg EN;
wire     [127:0]M_Data ;
wire M_Valid;
reg M_Ready;
//DMA
wire DMA_Read_Start,DMA_Write_Start;
reg  [7:0] Control_RE;
wire [7:0] State_RE;   
reg introut_3x3_Wr;
 simulation_concat  www
(
.clk(clk),
.rst(rst),
.EN(EN),
.DMA_read_para(DMA_read_para),
.DMA_read_feature(DMA_read_feature),
.DMA_read_feature_2(DMA_read_feature_2),
.DMA_write_valid(DMA_write_valid),

.S_Data_1(S_Data_1),
.S_Valid_1(S_Valid_1),
.S_Ready_1(S_Ready_1),

.S_Data(S_Data),
.S_Valid(S_Valid),
.S_Ready(S_Ready)
    );
TJPU tjpu(
    .clk(clk),
    .rst(rst),
    .Control_RE(Control_RE),
    .State_RE(State_RE),    
    .Switch(Switch),
    .Reg_4(Reg_4),
    .Reg_5(Reg_5),
    .Reg_6(Reg_6),
    .Reg_7(Reg_7),
    .Reg_8(Reg_8),
    .Reg_9(Reg_9),
    //DMA 
    .DMA_Read_Start(DMA_Read_Start),
    .DMA_Write_Start(DMA_Write_Start),
    .DMA_Read_Start_2(DMA_Read_Start_2),
    
    /////////////////////////////////
    //Stream read
    .S_Data(S_Data),
    .S_Valid(S_Valid),
    .S_Ready(S_Ready),
    
    .S_Data_1(S_Data_1),
    .S_Valid_1(S_Valid_1),
    .S_Ready_1(S_Ready_1),
    /////////////////////////////////
    //Stream write
    .M_Data(M_Data),
    .M_Ready(M_Ready),
    .M_Valid(M_Valid),
    .introut_3x3_Wr(introut_3x3_Wr)

);

assign DMA_read_para  =(EN==1'b1)? DMA_Read_Start:0;
assign DMA_read_feature =(EN==1'b0)?DMA_Read_Start:0;
assign DMA_read_feature_2 =(EN==1'b0)?DMA_Read_Start_2:0;

always#5 clk=~clk; 

//////     resblock3  第一个concat:     concat1     para:(1,256,40,40)  s_data:(1,256,40,40)   -->  (1,512,40,40) //////  
initial  begin 
    M_Ready=1'b1;
    EN=1'b1;
    clk=0;
    #10 rst=1;
    #10 rst=0;
//    //////         Para  状态   //////  
//    Control_RE = 8'b0001_0001;
//    Switch = 4'b1000;
//    EN=1'b1;
//	Reg_4=32'b1100_1000_0000_0000_0000_0000_0000_0000;           //  switch 中 para coe 文件的总行数   25600
//    Reg_5=32'b0000_0000_0000_0000_0000_0000_0000_0000;
//    #10  Switch = 4'b0000;
////    Control_RE = 8'b0000_0000;
    
//    ///////////  清第一次中断
//    while(State_RE[7:4]!=4'b1111) begin
//        #10  Control_RE= 8'b0000_0000;
//    end
//    #10  Control_RE[7:4] =4'b1111;
//    #100;
//    while(State_RE[7:4]!=4'b0000) begin
//        #10  ;
//    end
    
//    ///  清第二次中断
//     while(State_RE[3:0]!=4'b1111) begin
//        #10  Control_RE= 8'b0000_0000;
//    end
//    #10 Control_RE[3:0] = 4'b1111;
//    #100;
//    while(State_RE[7:4]!=4'b0000) begin
//        #10  ;
//    end
    
    
    //////  Connect  逻辑  //////
    #10
    EN = 1'b0;
    Switch = 4'b1000;
//    Control_RE[7:4] = 4'b0010;
    Control_RE = 8'b0000_0001;
 
//    rs1_cat
	Reg_4=32'b0000_1000_0000_0000_0000_0000_0000_0000;  //  32
	Reg_5=32'b0000_1101_0000_0001_0000_0000_0110_1000;  //  104  32  104
    Reg_6=32'h00020B33;			
    Reg_7=32'h000248CA;		
	Reg_8=32'hFFC3516C;	
	Reg_9=32'hFFBC7127;
    

///////////////////   清第一次中断

//    while(State_RE[7:4]!=4'b1111) begin
//        #10  Control_RE = 8'd0;
//    end
    
//    #10  Control_RE[7:4] =4'b1111;
    
//    #100;
//    while(State_RE[7:4]!=4'b0000)  begin
//        #10  ;
//    end
    
    ///////  清 第二次中断
    while(State_RE[3:0]!= 4'b1111) begin 
    	#10  Control_RE = 8'd0;
    end
    #10  Control_RE[3:0] =4'b1111;
    #100;
    while(State_RE[3:0]!=4'b0000)  begin
        #10  ;
    end
    
    #10
    Control_RE = 8'd0;
end   


integer end_out_data;
initial
begin
end_out_data=$fopen("11_concat_out_data.txt");

end
always@(posedge clk)begin
if(M_Valid&&M_Ready)
    $fwrite(end_out_data,"%h\n",M_Data);
end

endmodule