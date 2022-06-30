`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/23 14:27:11
// Design Name: 
// Module Name: Conv_PW
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
module Conv_1_1#(parameter 
    COMPUTE_CHANNEL_IN_NUM    =  8,
    COMPUTE_CHANNEL_OUT_NUM   =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,//channel_out_in_reg width
    KERNEL_NUM                =  1,
    WIDTH_WEIGHT_NUM          =  16,//weight num reg width
    WIDTH_DATA_ADD            =  32,//data add width
    WIDTH_BIAS_RAM_ADDRA      =   9,//bias ram size
    WIDTH_RAM_ADDR_TURE       =  16,//para block ram size   
    CONV_TYPE                 = "CONV_1_1", 
    WIDTH_RAM_ADDR_SIZE       =  16  //configure ram size  
)(
    input clk,
    input rst,
    input [3:0] Control,
    output[3:0] State,
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,
    /////////////////////////////
    //DMA 
    output DMA_read_valid,
    output DMA_write_valid,
    
    /////////////////////////////////
    //Stream read
    input  [`AXI_WIDTH_DATA-1:0] S_Data,
    input  S_Valid,
    output S_Ready,
    /////////////////////////////////
    //Stream write
    output [`AXI_WIDTH_DATA-1:0] M_Data,
    input  M_Ready,
    output M_Valid,
    input introut_1x1_Wr,
    output Last_11
    );

    wire [`AXI_WIDTH_DATA*2-1:0]  Switch_Data_11;
    wire [1:0]  Switch_Ready_11;
    wire [1:0]  Switch_Valid_11; 
    reg   [1:0] dest;
always@(posedge clk)begin
    if(rst)
        dest <= 2'b00;
    else if(Control == 4'b0001)       //  加载数据   用 Switch_Data中的 [255:0]
        dest <= 2'b00;
    else if(Control == 4'b0010)        //  进行数据生成+卷积+量化计算  用 Switch_Data中的 [511:256]
        dest <= 2'b01;
    else    
        dest <=dest; 
end   

PE_switch_11   PE_switch_11   (
  .aclk(clk),                    // input wire aclk
  .aresetn(!rst),              // input wire aresetn
  .s_axis_tvalid(S_Valid),  // input wire [0 : 0] s_axis_tvalid
  .s_axis_tready(S_Ready),  // output wire [0 : 0] s_axis_tready
  .s_axis_tdata(S_Data),    // input wire [255 : 0] s_axis_tdata
  .s_axis_tdest(dest),    // input wire [0 : 0] s_axis_tdest
  .m_axis_tvalid(Switch_Valid_11),  // output wire [1 : 0] m_axis_tvalid
  .m_axis_tready(Switch_Ready_11),  // input wire [1 : 0] m_axis_tready
  .m_axis_tdata (Switch_Data_11),    // output wire [511 : 0] m_axis_tdat
  .m_axis_tdest(),    // output wire [1 : 0] m_axis_tdest
  .s_decode_err()    // output wire [0 : 0] s_decode_err
);

wire  Next_Reg;      //  下次操作开始时的复位       
reg  Next_Reg_Temp [1:0];               
wire [3:0] Complete;
wire [3:0] Sign;
conv_1x1_state   conv_1x1_state
(
    .clk(clk),
    .rst(rst),
    .Control(Control),//[4]
    .State(State),//4
    .Complete(Complete),
    .Sign(Sign),
    .Next_Reg(Next_Reg),
    .DMA_read_valid(DMA_read_valid),
    .DMA_write_valid(DMA_write_valid) 
); 
 
//////  下一下图片复位信号  延迟
always @ (posedge clk) begin 
    Next_Reg_Temp[0] <= Next_Reg;
    Next_Reg_Temp[1] <= Next_Reg_Temp[0];
end  
 
 reg Start_Cu,Start_Pa;
 reg Start_Cu_reg,Start_Pa_reg;
 reg Start_Cu_reg1,Start_Pa_reg1;
 reg Start_Cu_reg2,Start_Pa_reg2;
 reg Complete_reg;
 always@(posedge clk)begin
     Start_Cu_reg2 <= Sign[1];    // Sign = 0010 -> Sign[1] = 1 -> 开始卷积操作 
     Start_Pa_reg2 <= Sign[0];    //  Sign = 0001 -> Sign[0] = 1 -> 开始加载参数操作
     Start_Cu_reg1<=Start_Cu_reg2;
     Start_Pa_reg1<=Start_Pa_reg2;
     Start_Cu_reg<=Start_Cu_reg1;
     Start_Pa_reg<=Start_Pa_reg1;
     Start_Cu<=Start_Cu_reg;
     Start_Pa<=Start_Pa_reg;
     Complete_reg<=introut_1x1_Wr;
end

assign  Complete[2] = Complete_reg;

wire S_Ready_P,S_Ready_C;
wire S_Ready_C_Switch,S_Ready_P_Switch;
assign S_Ready_C_Switch = S_Ready_C;
assign S_Ready_P_Switch = S_Ready_P;
assign Switch_Ready_11 ={S_Ready_C_Switch,S_Ready_P_Switch};
//============Switch_Valid===========
wire S_Valid_P_Switch,S_Valid_C_Switch;
assign S_Valid_P_Switch=Switch_Valid_11[0]&S_Ready_P_Switch;
assign S_Valid_C_Switch=Switch_Valid_11[1]&S_Ready_C_Switch;

wire [WIDTH_RAM_ADDR_TURE-1:0] Ram_Write_Num;
wire [WIDTH_RAM_ADDR_TURE-1:0]Ram_Write_Addra_Base;
//----------------------Para----------------
//wire [`AXI_WIDTH_DATA-1:0]        Data_Weight_One;
//wire [`AXI_WIDTH_DATA-1:0]        Data_Weight_Two;
//wire [`AXI_WIDTH_DATA-1:0]        Data_Weight_Three;
//wire [`AXI_WIDTH_DATA-1:0]        Data_Weight_Four;

//wire [WIDTH_RAM_ADDR_TURE-1:0]    Ram_Addrb;
//Compute_1_1_Para  #(
//    .WIDTH_RAM_ADDR_TURE(WIDTH_RAM_ADDR_TURE)  

//)  Compute_1_1_Para
//(
//    .clk                  (clk),
//    .rst                  (rst||Next_Reg_Temp[1]),
//    .Start                (Start_Pa),
//    .Write_Block_Complete (Complete[0]),
//    //Stream read
//    .S_Data                  (Switch_Data_11[`AXI_WIDTH_DATA-1:0]),
//    .S_Valid                 (S_Valid_P_Switch),
//    .S_Ready                 (S_Ready_P),
//    .Ram_Addrb               (Ram_Addrb),
//    .Ram_Write_Num           ( Ram_Write_Num  ),
//    .Ram_Write_Addra_Base    ( Ram_Write_Addra_Base  ),
//    .Ram_Data_Out_One        (Data_Weight_One)  ,//weight
//    .Ram_Data_Out_Two        (Data_Weight_Two )  ,//weight
//    .Ram_Data_Out_Three      (Data_Weight_Three  ),  //weight
//    .Ram_Data_Out_Four       (Data_Weight_Four  )  //weight
//); 
  
wire TB_Stride_Complete;
Compute_1_1   #(
    .COMPUTE_CHANNEL_IN_NUM   (COMPUTE_CHANNEL_IN_NUM),
    .COMPUTE_CHANNEL_OUT_NUM  (COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_FEATURE_SIZE       (WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM_REG    (WIDTH_CHANNEL_NUM_REG),
    .KERNEL_NUM               (KERNEL_NUM),
    .WIDTH_WEIGHT_NUM         (WIDTH_WEIGHT_NUM),
    .WIDTH_DATA_ADD           (WIDTH_DATA_ADD),
    .WIDTH_BIAS_RAM_ADDRA     (WIDTH_BIAS_RAM_ADDRA),
    .WIDTH_RAM_ADDR_TURE      (WIDTH_RAM_ADDR_TURE),
    .CONV_TYPE                (CONV_TYPE),
    .WIDTH_RAM_ADDR_SIZE      (WIDTH_RAM_ADDR_SIZE)
)
Compute_1_1  (
    .clk     (clk),
    .rst     (rst||Next_Reg_Temp[1]),
    .Next_Reg  (Next_Reg_Temp[1]),
    .Conv_Complete(Complete[1]),
    .Stride_Complete(TB_Stride_Complete),
    .Write_Block_Complete (Complete[0]),     //  para   计算完成
    .Sign    (Sign),
    .Reg_4   (Reg_4),
    .Reg_5   (Reg_5),
    .Reg_6   (Reg_6),
    .Reg_7   (Reg_7),
    .S_Data   (Switch_Data_11[`AXI_WIDTH_DATA*2-1:`AXI_WIDTH_DATA]),
    .S_Valid  (S_Valid_C_Switch),
    .S_Ready_C (S_Ready_C),
    
    .S_Para_Data(Switch_Data_11[`AXI_WIDTH_DATA-1:0]),    
    .S_Para_Valid(S_Valid_P_Switch),
    .S_Para_Ready(S_Ready_P),
    
    .M_Data (M_Data),
    .M_Ready(M_Ready),
    .M_Valid(M_Valid),
//    .Bram_Data_In_One(Data_Weight_One),
//    .Bram_Data_In_Two(Data_Weight_Two),
//    .Bram_Data_In_Three(Data_Weight_Three),
//    .Bram_Data_In_Four(Data_Weight_Four),
//    .Bram_Addrb(Ram_Addrb),
//    .Ram_Write_Num(Ram_Write_Num),
//    .Ram_Write_Addra_Base(Ram_Write_Addra_Base),
    .Start_Pa(Start_Pa),
    .Start_Cu(Start_Cu),
    .Last_11(Last_11)
);
endmodule

