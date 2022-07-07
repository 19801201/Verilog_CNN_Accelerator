`timescale 1ns / 1ps

`include"./Para.v"
module reshape#(parameter 
    RE_WIDTH_FEATURE_SIZE = 11,
    RE_WIDTH_CHANNEL_NUM_REG= 10,
    RE_WIDTH_WEIGHT_NUM =16,
    RE_CHANNEL_IN_NUM=16,
    RE_WIDTH_CONNECT_TIMES=15
 )(
    input clk,
    input rst,
    input [3:0] Control_Reshape,
    input [3:0] Control_Concat, 
    output[7:0] ReshapeState, 
    input [31:0] Reg_4,
    input [31:0] Reg_5,
    input [31:0] Reg_6,
    input [31:0] Reg_7,
    input [31:0] Reg_8,
    input [31:0] Reg_9,
    /////////////////////////////
    //DMA 
    output DMA_read_valid,
    output DMA_write_valid,
    output DMA_read_valid_2,
    /////////////////////////////////
    //Stream read
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data,
    input  S_Valid,
    output S_Ready,
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data_1,
    input  S_Valid_1,
    output S_Ready_1,
    /////////////////////////////////
    //Stream write
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    input  M_Ready,
    output M_Valid,
    output Write_DDR_REG,
    output Read_DDR_REG,
    //DMA
    input   inter_reshape,
    output  Last_Reshape      
    );

//wire  [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_In_REG;
wire  [RE_WIDTH_FEATURE_SIZE-1 :0] Row_Num_Out_REG;
wire  [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_In_Num_REG;


reg   [1:0]dest;


//=======================concat===============
wire [`AXI_WIDTH_DATA_IN-1:0]  S_Concat_Data;
wire S_Concat_Valid;
wire S_Concat_Ready;

wire  [`AXI_WIDTH_DATA_IN-1:0]  M_Concat_Data;
wire  M_Concat_Valid;
wire  M_Concat_Ready;

// ===================split===================
wire [`AXI_WIDTH_DATA_IN-1:0]  S_Split_Data;
wire S_Split_Valid;
wire S_Split_Ready;

wire [`AXI_WIDTH_DATA_IN-1:0]  M_Split_Data;
wire M_Split_Valid;
wire M_Split_Ready;

//  =================maxpooling=============
wire [`AXI_WIDTH_DATA_IN-1:0]S_Maxpool_Data;
wire S_Maxpool_Valid;
wire S_Maxpool_Ready;

wire [`AXI_WIDTH_DATA_IN-1:0]M_Maxpool_Data;
wire M_Maxpool_Valid;
wire M_Maxpool_Ready;

//  ===================upsample================
wire [`AXI_WIDTH_DATA_IN-1:0]  S_Upsample_Data;
wire S_Upsample_Valid;
wire S_Upsample_Ready;

wire [`AXI_WIDTH_DATA_IN-1:0]  M_Upsample_Data;
wire M_Upsample_Valid;
wire M_Upsample_Ready;


wire	[3:0]	Start_Reshape;
//wire	[1:0]	Start_Concat;  
wire	[3:0]   Complete;     
//wire	[1:0]   Concat_Complete; 
wire	[3:0]	End_Control;  

wire        Last_Concat;
wire        Last_Route;
wire        Last_Maxpool;
wire        Last_Upsample;
assign      Last_Reshape  = (Last_Concat||Last_Route||Last_Maxpool||Last_Upsample)?1'b1:1'b0;

wire Read_DDR_REG_1,Read_DDR_REG_2;
wire Write_DDR_REG_1,Write_DDR_REG_2;

assign Write_DDR_REG = Write_DDR_REG_1 || Write_DDR_REG_2;
assign Read_DDR_REG = Read_DDR_REG_1 || Read_DDR_REG_2;

always@(posedge clk)begin
    if(Control_Reshape == 4'b0001)        // Control_Reshape = 0001 -> concat -> dest 00
        dest <= 2'b00;
    else if(Control_Reshape == 4'b0010)        //  Control_Reshape = 0010 ->  split -> dest 01
        dest <= 2'b01;
    else if(Control_Reshape == 4'b0100)        // Control_Reshape = 0100 -> maxpooling -> dtest 10
        dest <= 2'b10;
    else if(Control_Reshape == 4'b1000)        //  Control_Reshape = 1000 -> route  -> dtest 11
    	dest <= 2'b11;
    else    
        dest <=dest; 
end    
//============switch===========
wire [3 : 0]     m_axis_tvalid;   
wire [3 : 0]     m_axis_tready ;   
wire [`AXI_WIDTH_DATA_IN*4-1 : 0]  m_axis_tdata ; 
 top_reshape top_reshape (
  .aclk(clk),                    // input wire aclk
  .aresetn(!rst),              // input wire aresetn
  .s_axis_tvalid(S_Valid),  // input wire [0 : 0] s_axis_tvalid
  .s_axis_tready(S_Ready),  // output wire [0 : 0] s_axis_tready
  .s_axis_tdata(S_Data),    // input wire [127 : 0] s_axis_tdata
  .s_axis_tdest(dest),    // input wire [1 : 0] s_axis_tdest
  .m_axis_tvalid(m_axis_tvalid),  // output wire [3 : 0] m_axis_tvalid
  .m_axis_tready(m_axis_tready),  // input wire [3 : 0] m_axis_tready
  .m_axis_tdata(m_axis_tdata),    // output wire [511 : 0] m_axis_tdata
  .m_axis_tdest(),    // output wire [7 : 0] m_axis_tdest
  .s_decode_err()    // output wire [0 : 0] s_decode_err
);

wire Next_Reg;     
reg  Next_Reg_Temp [1:0];      
reg Complete_reg[1:0];
always @ (posedge clk) begin 
    Complete_reg[0] <= inter_reshape;
    Complete_reg[1] <= Complete_reg[0];
end

assign Complete[0] = Complete_reg[1];
assign Complete[1] = Complete_reg[1];
assign Complete[2] = Complete_reg[1];
assign Complete[3] = Complete_reg[1];

reshape_state   reshape_state(
    .clk(clk),
    .rst(rst),
    .Control_Reshape(Control_Reshape),//[4]
//    .Control_Concat(Control_Concat),
    .Start_Reshape(Start_Reshape),
//    .Start_Concat(Start_Concat),
    .State(ReshapeState),//4
    .Complete(Complete),
//    .Concat_Complete(Concat_Complete),
    .Next_Reg(Next_Reg),
    .DMA_read_valid(DMA_read_valid),
    .DMA_write_valid(DMA_write_valid),
    .DMA_read_valid_2(DMA_read_valid_2),
    .End_Control(End_Control)
    );

always @ (posedge clk) begin 
    Next_Reg_Temp[0] <= Next_Reg;
    Next_Reg_Temp[1] <= Next_Reg_Temp[0];
end
 
reshape_define  #(
    .RE_WIDTH_FEATURE_SIZE(RE_WIDTH_FEATURE_SIZE),
    .RE_WIDTH_CHANNEL_NUM_REG(RE_WIDTH_CHANNEL_NUM_REG)
)  reshape_define 
(
    .clk(clk),
    .rst(rst),
    .Sign (Start_Reshape),
    .Reg_4(Reg_4),
    .Reg_5(Reg_5),
    .Reg_6(Reg_6),
    .Reg_7(Reg_7),
    .Write_DDR_REG(Write_DDR_REG_1),
    .Read_DDR_REG(Read_DDR_REG_1),
//    .Row_Num_In_REG(Row_Num_In_REG),
    .Row_Num_Out_REG(Row_Num_Out_REG),
    .Channel_In_Num_REG(Channel_In_Num_REG)
  );

assign  S_Concat_Data =  m_axis_tdata[`AXI_WIDTH_DATA_IN-1:0];     
assign  S_Concat_Valid = m_axis_tvalid[0]&S_Concat_Ready;

assign  S_Split_Data =   m_axis_tdata[`AXI_WIDTH_DATA_IN*2-1:`AXI_WIDTH_DATA_IN];      
assign  S_Split_Valid =  m_axis_tvalid[1]&S_Split_Ready;

assign 	S_Maxpool_Data = m_axis_tdata[`AXI_WIDTH_DATA_IN*3-1:`AXI_WIDTH_DATA_IN*2];     
assign  S_Maxpool_Valid = m_axis_tvalid[2]&S_Maxpool_Ready;

assign 	S_Upsample_Data = m_axis_tdata[`AXI_WIDTH_DATA_IN*4-1:`AXI_WIDTH_DATA_IN*3];      
assign	S_Upsample_Valid =  m_axis_tvalid[3]&S_Upsample_Ready;

assign  m_axis_tready = {S_Upsample_Ready,S_Maxpool_Ready,S_Split_Ready,S_Concat_Ready};


reg [`AXI_WIDTH_DATA_IN-1:0]  S_Data_11;
reg S_Valid_11;
wire S_Ready_11;
//always@(posedge clk)begin
//    S_Data_11 <= S_Data_1;
//    S_Valid_11 <= S_Valid_1;
//    S_Ready_1 <= S_Ready_11;
//end
//assign S_Ready_1 = S_Ready_11;

//////////////           concat     /////////////////////////////
concat  #(
    .RE_WIDTH_FEATURE_SIZE(RE_WIDTH_FEATURE_SIZE),
    .RE_WIDTH_CHANNEL_NUM_REG(RE_WIDTH_CHANNEL_NUM_REG),
    .RE_WIDTH_WEIGHT_NUM(RE_WIDTH_WEIGHT_NUM),
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM),
    .RE_WIDTH_CONNECT_TIMES(RE_WIDTH_CONNECT_TIMES)
 )  concat  (
    . clk(clk),
    . rst(rst||Next_Reg_Temp[1]),
    . Next_Reg(Next_Reg_Temp[1]),
    . Start_Concat  (Start_Reshape[3]),
//    . Write_Block_Complete(Concat_Complete[0]),
    . Reg_4(Reg_4),
    . Reg_5(Reg_5),
    . Reg_6(Reg_6),
    . Reg_7(Reg_7),
    . Reg_8(Reg_8),
    . Reg_9(Reg_9),
    .Write_DDR_REG(Write_DDR_REG_2),
    .Read_DDR_REG(Read_DDR_REG_2),
    //Stream read
    .S_Data_1(S_Data_1),
    .S_Valid_1(S_Valid_1),
    .S_Ready_1(S_Ready_1),
    
    .S_Data_2(S_Concat_Data),
    .S_Valid_2(S_Concat_Valid),
    .S_Ready_2(S_Concat_Ready),
    /////////////////////////////////
    //Stream write
    .M_Data (M_Concat_Data),
    .M_Ready(M_Concat_Ready),
    .M_Valid(M_Concat_Valid),
    //DMA
    .Last_Concat(Last_Concat)
    );

wire Route_Complete;
wire Maxpool_Complete;
wire Upsample_Complete;
//////////////////////   split  //////////////
route#(
     .CHANNEL_OUT_NUM						  (RE_CHANNEL_IN_NUM),
     .WIDTH_CHANNEL_NUM_REG                   (RE_WIDTH_CHANNEL_NUM_REG),
     .WIDTH_FEATURE_SIZE                      (RE_WIDTH_FEATURE_SIZE)
)  route(
    .clk								(clk),
    .rst								(rst||Next_Reg_Temp[1]),
    .Next_Reg                           (Next_Reg_Temp[1]),
    .Start                              (Start_Reshape[0]),
    .S_Data                             (S_Split_Data),
    .S_Valid                            (S_Split_Valid),
    .S_Ready                            (S_Split_Ready),
    .Row_Num_Out_REG                    (Row_Num_Out_REG),  
    .Channel_Out_Num_REG                (Channel_In_Num_REG),
    .M_Ready                            (M_Split_Ready),
    .M_Data                             (M_Split_Data),
    .M_Valid                            (M_Split_Valid),
//    .Route_Complete						(Complete[0]),
    .Route_Complete						(Route_Complete),
    .Last_Route                          (Last_Route)
 );


////////////     maxpool       ////////////
maxpool #(
	.WIDTH_FEATURE_SIZE             (RE_WIDTH_FEATURE_SIZE),
    .WIDTH_CHANNEL_NUM_REG          (RE_WIDTH_CHANNEL_NUM_REG),
	.RE_CHANNEL_IN_NUM        		(RE_CHANNEL_IN_NUM)
) maxpool(
	.clk								(clk),
	.rst                                (rst||Next_Reg_Temp[1]),
	.Next_Reg                           (Next_Reg_Temp[1]),
	.Start                              (Start_Reshape[1]),
	.S_Data                             (S_Maxpool_Data),
	.S_Valid                            (S_Maxpool_Valid),
	.S_Ready                            (S_Maxpool_Ready),
	.M_Ready                            (M_Maxpool_Ready),
	.M_Valid                            (M_Maxpool_Valid),
	.M_Data                             (M_Maxpool_Data),
//	.MaxPool_Complete                   (Complete[1]),
	.MaxPool_Complete                   (Maxpool_Complete),
	.Row_Num_Out_REG                    (Row_Num_Out_REG),
	.Channel_Out_Num_REG                (Channel_In_Num_REG),
	.Last_Maxpool                        (Last_Maxpool) 
);

////////////       upsampling                 ////////////
upsampling#(
     .CHANNEL_OUT_NUM 						(RE_CHANNEL_IN_NUM),
     .WIDTH_CHANNEL_NUM_REG                 (RE_WIDTH_CHANNEL_NUM_REG),
     .WIDTH_FEATURE_SIZE                    (RE_WIDTH_FEATURE_SIZE)
)  upsampling  (
     .clk										(clk),
     .rst                                       (rst||Next_Reg_Temp[1]),
     .Next_Reg                                  (Next_Reg_Temp[1]),
     .Start                                     (Start_Reshape[2]),
     .S_Data                                    (S_Upsample_Data),
     .S_Valid                                   (S_Upsample_Valid),
     .S_Ready                                   (S_Upsample_Ready),
     .Row_Num_Out_REG                           (Row_Num_Out_REG),
     .Channel_Out_Num_REG                       (Channel_In_Num_REG),
     .M_Ready                                   (M_Upsample_Ready),
     .M_Data                                    (M_Upsample_Data),
     .M_Valid                                   (M_Upsample_Valid),
//     .Upsample_Complete							(Complete[2]),
     .Upsample_Complete							(Upsample_Complete),
     .Last_Upsample                             (Last_Upsample)
   );

wire [3:0]			                  S_Reshape_end_Valid;
wire [3:0]			                  S_Reshape_end_Ready;
wire [`AXI_WIDTH_DATA_IN*4-1:0]		  S_Reshape_end_Data;


assign	S_Reshape_end_Valid = {M_Upsample_Valid,M_Maxpool_Valid,M_Split_Valid,M_Concat_Valid};

assign  M_Concat_Ready    =	 S_Reshape_end_Ready[0];
assign  M_Split_Ready     =  S_Reshape_end_Ready[1];
assign	M_Maxpool_Ready   =  S_Reshape_end_Ready[2];
assign	M_Upsample_Ready  =	 S_Reshape_end_Ready[3];

assign	S_Reshape_end_Data = {M_Upsample_Data,M_Maxpool_Data,M_Split_Data,M_Concat_Data};

end_reshape   end_reshape (
  .aclk(clk),                      // input wire aclk
  .aresetn(!rst),                // input wire aresetn
  .s_axis_tvalid(S_Reshape_end_Valid),    // input wire [3 : 0] s_axis_tvalid
  .s_axis_tready(S_Reshape_end_Ready),    // output wire [3 : 0] s_axis_tready
  .s_axis_tdata(S_Reshape_end_Data),      // input wire [1023 : 0] s_axis_tdata
  .m_axis_tvalid(M_Valid),    // output wire [0 : 0] m_axis_tvalid
  .m_axis_tready(M_Ready),    // input wire [0 : 0] m_axis_tready
  .m_axis_tdata(M_Data),      // output wire [255 : 0] m_axis_tdata
  .s_req_suppress(End_Control),  // input wire [3 : 0] s_req_suppress
  .s_decode_err()     // output wire [3 : 0] s_decode_err
);

//assign       M_Valid = (M_Concat_Valid||M_Split_Valid||M_Maxpool_Valid||M_Upsample_Valid)?1'b1:1'b0;


endmodule