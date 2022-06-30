`timescale 1ns / 1ps
`include  "../Para.v"



module TJPU_image#(parameter
	WIDTH_DATA_ADD            =  32,
    WIDTH_DATA_ADD_TEMP       =  48,
    WIDTH_DATA_ADD_SUB        =  16,
	COMPUTE_CHANNEL_OUT_NUM	  =	 8,
	WIDTH_FEATURE_SIZE        =  10
)(
      input  clk,
      input  rst,
      input  [3:0] Control,
      input  [`IMAGE_WIDTH_DATA-1:0] S_Data,
      input  S_Valid,
      output S_Ready,
      input  M_Ready,
      output [COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0] M_Data,
      output M_Valid,
      output DMA_read_valid,
      output DMA_write_valid,
      input  DMA_Inter,
      output [3:0]State,
      output Img_Last                         //  tlast  信号
      
    );

wire [`IMAGE_WIDTH_DATA*2-1:0]  Switch_Data_Image;
wire [1:0]  Switch_Ready_Image;
wire [1:0]  Switch_Valid_Image; 
reg  [1:0] dest;
wire Next_Reg;

always@(posedge clk)begin
    if(rst)
        dest <= 2'b00;
    else if(Control == 4'b0001)       //  加载权重   用 Switch_Data中的 [7:0]
        dest <= 2'b00;
    else if(Control == 4'b0010)        //  进行计算  用 Switch_Data中的 [15:8]
        dest <= 2'b01;
    else    
        dest <=dest; 
end  

PE_switch_Image PE_switch_Image (
  .aclk(clk),                    // input wire aclk
  .aresetn(!rst),              // input wire aresetn
  .s_axis_tvalid(S_Valid),  // input wire [0 : 0] s_axis_tvalid
  .s_axis_tready(S_Ready),  // output wire [0 : 0] s_axis_tready
  .s_axis_tdata(S_Data),    // input wire [7 : 0] s_axis_tdata
  .s_axis_tdest(dest),    // input wire [1 : 0] s_axis_tdest
  .m_axis_tvalid(Switch_Valid_Image),  // output wire [1 : 0] m_axis_tvalid
  .m_axis_tready(Switch_Ready_Image),  // input wire [1 : 0] m_axis_tready
  .m_axis_tdata(Switch_Data_Image),    // output wire [15 : 0] m_axis_tdata
  .m_axis_tdest(),    // output wire [3 : 0] m_axis_tdest
  .s_decode_err()    // output wire [0 : 0] s_decode_err
);

wire [5:0]   weight_addrb;
wire [255:0] Data_Out_Weight;
wire [1:0] Start;    
wire [1:0] Complete;
wire Stride_Complete;
wire Stride_REG;
image_conv_state image_conv_state(
   .clk(clk),
   .rst(rst),
   .Control(Control),
   .State(State),
   .Complete(Complete),
   .Start(Start),
   .DMA_read_valid(DMA_read_valid),
   .DMA_write_valid(DMA_write_valid),
   .Next_Reg(Next_Reg)
);

reg  Next_Reg_Temp [1:0];

always @ (posedge clk) begin 
    Next_Reg_Temp[0] <= Next_Reg;
    Next_Reg_Temp[1] <= Next_Reg_Temp[0];
end 


wire S_Ready_P,S_Ready_C;
wire S_Valid_P,S_Valid_C;
reg Complete_reg;

assign Switch_Ready_Image ={S_Ready_C,S_Ready_P};
assign S_Valid_P=Switch_Valid_Image[0]&S_Ready_P;
assign S_Valid_C=Switch_Valid_Image[1]&S_Ready_C;

always @(posedge clk) begin
    if(Stride_REG)begin
        Complete_reg<=Stride_Complete;
    end
    else begin
        Complete_reg<=DMA_Inter;
    end
end

assign Complete[1] = Complete_reg;

Image_Weight_Para Image_Weight_Para
(
    .clk                  (clk),
    .rst                  (rst | Next_Reg_Temp[1]),
    .Start                (Start[0]),
    .Write_Block_Complete (Complete[0]),
    .S_Data               (Switch_Data_Image[`IMAGE_WIDTH_DATA-1:0]),
    .S_Valid              (S_Valid_P),
    .S_Ready              (S_Ready_P),
    .weight_addrb         (weight_addrb),
    .Data_Out_Weight      (Data_Out_Weight)
); 
     
image_compute_33 image_compute_33(
   .clk(clk),
   .rst(rst|Next_Reg_Temp[1]),
   .Start(Start[1]),
   .S_Data(Switch_Data_Image[`IMAGE_WIDTH_DATA*2-1:`IMAGE_WIDTH_DATA]),
   .S_Valid(S_Valid_C),
   .S_Ready(S_Ready_C),
   .M_Stride_Ready(M_Ready),
   .M_Stride_Data(M_Data),
   .M_Stride_Valid(M_Valid),
   .weight_addrb(weight_addrb),
   .Data_Out_Weight(Data_Out_Weight),
   .Stride_Complete(Stride_Complete),
   .Stride_REG(Stride_REG),
   .Img_Last(Img_Last)
);  
        
endmodule