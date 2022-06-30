`timescale 1ns / 1ps

`include"../Para.v"
module Conv_3_3#(parameter 
    COMPUTE_CHANNEL_IN_NUM    =  16,
    COMPUTE_CHANNEL_OUT_NUM   =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,//channel_out_in_reg width
    KERNEL_NUM                =  9,
    WIDTH_RAM_SIZE            =  12,//feature ram size 
    WIDTH_WEIGHT_NUM          =  15,//weight num reg width
    WIDTH_DATA_ADD            =  32,//data add width
    WIDTH_BIAS_RAM_ADDRA      =   7,//bias ram size 
    CONV_TYPE                 = "CONV_3_3", 
    WIDTH_RAM_ADDR_SIZE       =  13  //configure ram size  
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
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data,
    input   S_Valid,
    output  S_Ready,
    /////////////////////////////////
    //Stream write
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    input  M_Ready,
    output M_Valid,
    output Write_DDR_REG,
    output Read_DDR_REG,
    output Weight_Read_REG,
    input introut_3x3_Wr,
    output Last_33
    );


wire [`AXI_WIDTH_DATA_IN*2-1:0]  Switch_Data;
wire [1:0]  Switch_Ready;
wire [1:0]  Switch_Valid; 
reg   [1:0] dest;
always@(posedge clk)begin
    if(rst)
        dest <= 2'b00;
    else if(Control == 4'b0001)
        dest <= 2'b00;
    else if(Control == 4'b0010)
        dest <= 2'b01;
    else    
        dest <=dest; 
end   

PE_switch   PE_switch   (
  .aclk(clk),                    // input wire aclk
  .aresetn(!rst),              // input wire aresetn
  .s_axis_tvalid(S_Valid),  // input wire [0 : 0] s_axis_tvalid
  .s_axis_tready(S_Ready),  // output wire [0 : 0] s_axis_tready
  .s_axis_tdata(S_Data),    // input wire [127 : 0] s_axis_tdata
  .s_axis_tdest(dest),    // input wire [0 : 0] s_axis_tdest
  .m_axis_tvalid(Switch_Valid),  // output wire [1 : 0] m_axis_tvalid
  .m_axis_tready(Switch_Ready),  // input wire [1 : 0] m_axis_tready
  .m_axis_tdata (Switch_Data),    // output wire [255 : 0] m_axis_tdat
  .m_axis_tdest(),    // output wire [1 : 0] m_axis_tdest
  .s_decode_err()    // output wire [0 : 0] s_decode_err
);


wire S_Ready_P,S_Ready_C;
wire S_Ready_C_Switch,S_Ready_P_Switch;
assign S_Ready_C_Switch = S_Ready_C;
assign S_Ready_P_Switch = S_Ready_P;
assign Switch_Ready ={S_Ready_C_Switch,S_Ready_P_Switch};
//============Switch_Valid===========
wire S_Valid_P_Switch,S_Valid_C_Switch;
assign S_Valid_P_Switch=Switch_Valid[0]&S_Ready_P_Switch;
assign S_Valid_C_Switch=Switch_Valid[1]&S_Ready_C_Switch;
                          
           
wire Next_Reg;   
reg  Next_Reg_Temp [1:0];                
wire [3:0] Complete;
wire [3:0] Sign;
wire TB_Stride_Complete;
wire Stride_REG;
conv_state conv_3x3_state
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
     Start_Cu_reg2 <= Sign[1];    // Sign = 0010 -> Sign[1] = 1 -> 
     Start_Pa_reg2 <= Sign[0];    //  Sign = 0001 -> Sign[0] = 1 -> 
     Start_Cu_reg1<=Start_Cu_reg2;
     Start_Pa_reg1<=Start_Pa_reg2;
     Start_Cu_reg<=Start_Cu_reg1;
     Start_Pa_reg<=Start_Pa_reg1;
     Start_Cu<=Start_Cu_reg;
     Start_Pa<=Start_Pa_reg;
 end
 
 assign Weight_Read_REG = Sign[0];
 
 always @(posedge clk) begin
     if(Stride_REG)begin
         Complete_reg<=TB_Stride_Complete;
     end
     else begin
         Complete_reg<=introut_3x3_Wr;
     end
 end
assign  Complete[2] = Complete_reg;

  
Compute_3_3 #(
    .COMPUTE_CHANNEL_IN_NUM   (COMPUTE_CHANNEL_IN_NUM),
    .COMPUTE_CHANNEL_OUT_NUM  (COMPUTE_CHANNEL_OUT_NUM),
    .WIDTH_FEATURE_SIZE       (WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM_REG    (WIDTH_CHANNEL_NUM_REG),
    .KERNEL_NUM               (KERNEL_NUM),
    .WIDTH_RAM_SIZE           (WIDTH_RAM_SIZE),
    .WIDTH_WEIGHT_NUM         (WIDTH_WEIGHT_NUM),
    .WIDTH_DATA_ADD           (WIDTH_DATA_ADD),
    .WIDTH_BIAS_RAM_ADDRA     (WIDTH_BIAS_RAM_ADDRA),
    .CONV_TYPE                (CONV_TYPE),
    .WIDTH_RAM_ADDR_SIZE      (WIDTH_RAM_ADDR_SIZE)
)
compute_3_3(
    .clk     (clk),
    .rst     (Next_Reg_Temp[1]||rst),
    .Next_Reg  (Next_Reg_Temp[1]),
    .Conv_Complete(Complete[1]),
    .Stride_Complete(TB_Stride_Complete),
    .Write_Block_Complete (Complete[0]),
    .Sign    (Sign),
    .Reg_4   (Reg_4),
    .Reg_5   (Reg_5),
    .Reg_6   (Reg_6),
    .Reg_7   (Reg_7),
    .S_Data   (Switch_Data[`AXI_WIDTH_DATA_IN*2-1:`AXI_WIDTH_DATA_IN]),
    .S_Valid  (S_Valid_C_Switch),
    .S_Ready  (S_Ready_C),
    .S_Para_Data(Switch_Data[`AXI_WIDTH_DATA_IN-1:0]),    
    .S_Para_Valid(S_Valid_P_Switch),
    .S_Para_Ready(S_Ready_P),
    .M_Data (M_Data),
    .M_Ready(M_Ready),
    .M_Valid(M_Valid),
    .Stride_REG(Stride_REG),
    .Write_DDR_REG(Write_DDR_REG),
    .Read_DDR_REG(Read_DDR_REG),
    .Start_Pa(Start_Pa),
    .Start_Cu(Start_Cu),
    .Last_33(Last_33)
);
endmodule
