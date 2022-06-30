`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/26 16:05:08
// Design Name: 
// Module Name: Stride_1_1
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

module Stride_1_1#(parameter
     CHANNEL_OUT_NUM      =  8,
     WIDTH_CHANNEL_NUM_REG   =  10,
     WIDTH_FEATURE_SIZE  = 12
)
(
    input clk,
    input rst,
    input Next_Reg,
    input Start,
    input EN_Stride_REG, 
    input Valid_In,
    input [WIDTH_FEATURE_SIZE-1 :0]Row_Num_Out_REG,
    input [WIDTH_CHANNEL_NUM_REG-1  :0]Channel_Out_Num_REG,
    input [`AXI_WIDTH_DATA-1:0]Feature,
    output[`AXI_WIDTH_DATA-1:0]M_Data,
    output M_Valid,
    output S_Ready,
    input M_Ready,
    
    /////////////////////  输出结果计数，充当 dma read 中传入的  introut_3x3_Wr  信号
    output	 reg   Stride_Complete,
    output         Last
    );
localparam      Idle_State               = 6'b00_0000;
localparam      Stride_State             = 6'b00_0001;
reg [WIDTH_FEATURE_SIZE-1'b1:0] Cnt_Column, Cnt_Row;
reg  [WIDTH_CHANNEL_NUM_REG-1'b1:0]Cnt_Cin;
wire EN_Stride,EN_Column_End,EN_Row_End,EN_Last_Cin;
reg Start_reg,Start_reg1;
always@(posedge clk)begin
    Start_reg <= Start;
    Start_reg1<=Start_reg;
end
wire [WIDTH_CHANNEL_NUM_REG-1'b1:0] Channel_Times;
//assign Channel_Times = Channel_Out_Num_REG/CHANNEL_OUT_NUM;
assign Channel_Times = Channel_Out_Num_REG>>3;
assign EN_Stride = (Start_reg1==1'b1&& EN_Stride_REG == 1'b1)?1'b1:1'b0;
assign EN_Column_End  =  (Cnt_Column == Row_Num_Out_REG-1'b1)?1'b1:1'b0;
assign EN_Row_End     =  (Cnt_Row==Row_Num_Out_REG-1'b1)?1'b1:1'b0;
assign EN_Last_Cin    =(Cnt_Cin==Channel_Times-1'b1)?1'b1:1'b0;
reg  [5:0] Current_State;
reg  [5:0] Next_State;
reg [`AXI_WIDTH_DATA-1:0]End_Feature;
reg Valid_Out;


////////////////////   用来进行输出的个数的结果计数

always@( posedge clk  )begin  //   
    if( rst )begin
        Current_State <= Idle_State;
    end
    else begin
        Current_State <= Next_State;
    end
 end
always @ (*) begin
    Next_State = Idle_State;
    case(Current_State) 
        Idle_State:
            if(EN_Stride)
                Next_State   =   Stride_State;     //锟斤拷锟斤拷??????
            else 
                Next_State   =   Idle_State;  
        Stride_State:
            if(EN_Column_End&&EN_Row_End&&EN_Last_Cin)
                Next_State   =   Idle_State;
            else 
                Next_State   =   Stride_State;
        default:Next_State  =    Idle_State;
    endcase 
end

always@(posedge clk)begin
    if(rst)
      Cnt_Column<=  {WIDTH_FEATURE_SIZE{1'b0}};
    else begin
      case(Current_State)
        Idle_State:      
            Cnt_Column<=  {WIDTH_FEATURE_SIZE{1'b0}};
        Stride_State:
            if(Valid_In == 1'b1)begin
                if(EN_Column_End&&EN_Last_Cin)begin
                    Cnt_Column <={WIDTH_FEATURE_SIZE{1'b0}};
                end
                else if (EN_Last_Cin )begin
                    Cnt_Column <= Cnt_Column + 1'b1;
                end
                else 
                    Cnt_Column <= Cnt_Column;
             end
            else
                Cnt_Column <= Cnt_Column;
        default:Cnt_Column<=  {WIDTH_FEATURE_SIZE{1'b0}};
        endcase          
    end
end

always@(posedge clk)begin
    if(rst)
      Cnt_Row<=  {WIDTH_FEATURE_SIZE{1'b0}};
    else begin
      case(Current_State)
        Idle_State:      
            Cnt_Row<=  {WIDTH_FEATURE_SIZE{1'b0}};
        Stride_State:
            if(EN_Column_End&&EN_Last_Cin)
                Cnt_Row <= Cnt_Row + 1'b1;
            else
                Cnt_Row <= Cnt_Row;
        default:Cnt_Row<=  {WIDTH_FEATURE_SIZE{1'b0}};
        endcase          
    end
end
always@(posedge clk)begin
    if(rst)
      Valid_Out<=  1'b0;
    else begin
    case(Current_State)
        Idle_State:
            Valid_Out <= Valid_In;
        Stride_State:
            if (Cnt_Column[0] == 1'b0&&Cnt_Row[0] == 1'b0&&Valid_In ==1'b1)begin
                Valid_Out <= 1'b1;
            end
            else begin
                Valid_Out <= 1'b0;
            end
    endcase 
   end   
end    

always@(posedge clk)begin
    if(rst)begin 
        Cnt_Cin <= {WIDTH_CHANNEL_NUM_REG*{1'b0}};
    end
    else begin
    case(Current_State) 
        Idle_State:      
            Cnt_Cin <= {WIDTH_CHANNEL_NUM_REG*{1'b0}};
        Stride_State:
            if( Valid_In == 1'b1)begin
                if(EN_Last_Cin)begin
                    Cnt_Cin <={WIDTH_CHANNEL_NUM_REG*{1'b0}};
                end
                else begin
                    Cnt_Cin <= Cnt_Cin+1'b1;
                end
            end
            else begin
                Cnt_Cin <= Cnt_Cin; 
            end
      default:Cnt_Cin<=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
      endcase
      end
end


always@(posedge clk)begin
       End_Feature <= Feature;
end 
reg [WIDTH_FEATURE_SIZE-1 :0]row_num_out;
always@(posedge clk)begin
    case(EN_Stride_REG)
        1'b1:row_num_out<=Row_Num_Out_REG>>1;
        1'b0:row_num_out<=Row_Num_Out_REG;
        default:row_num_out<=Row_Num_Out_REG;
    endcase
end
wire empty;
reg [WIDTH_FEATURE_SIZE-1:0]data_count;
always@(posedge clk)begin
    data_count <=row_num_out*Channel_Times;
end
Stride_1_1_FIFO  #(
        .WIDTH(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_OUT_NUM),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
Stride_1_1_FIFO
(
     .clk(clk),
     .rst(rst||Next_Reg),
     .din(End_Feature),
     .wr_en(Valid_Out),
     .rd_en(M_Ready&M_Valid),
     .dout(M_Data),
     .M_count(data_count),  //back
     .M_Ready(),//鏈夋病鏈変竴琛屾暟鎹?
     .S_count(data_count),   //front
     .S_Ready(S_Ready),//鑳戒笉鑳藉瓨涓嬩竴琛屾暟鎹?
     .empty(empty)
); 
//assign M_Valid = M_Ready&&!empty;
assign M_Valid = !empty;



////////////////////        Last_Logic              /////////////////////////
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Row;
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Column;
reg      [WIDTH_CHANNEL_NUM_REG-1:0]	    M_Cnt_Cout;

wire                                       M_En_Last_Cout;   
wire                                       M_En_Last_Col;   
wire                                       M_En_Last_Row;   


assign  M_En_Last_Cout = (M_Cnt_Cout + 1'b1 == Channel_Times)?1'b1:1'b0;
assign  M_En_Last_Col = (M_Cnt_Column + 1'b1 == row_num_out)?1'b1:1'b0;
assign  M_En_Last_Row = (M_Cnt_Row + 1'b1 == row_num_out)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst||Next_Reg)
        M_Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
    else if (M_Ready&M_Valid) begin
        if (M_En_Last_Cout)
            M_Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
        else
            M_Cnt_Cout <= M_Cnt_Cout + 1'b1;
    end
    else
        M_Cnt_Cout <= M_Cnt_Cout;
end

always @ (posedge clk) begin 
    if (rst||Next_Reg)
        M_Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
    else if (M_En_Last_Cout&M_Ready&M_Valid) begin
        if (M_En_Last_Col)
            M_Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
        else
            M_Cnt_Column <= M_Cnt_Column + 1'b1;
    end
    else
        M_Cnt_Column <= M_Cnt_Column;
end


always @ (posedge clk) begin 
    if (rst||Next_Reg)
        M_Cnt_Row <= {WIDTH_FEATURE_SIZE{1'b0}};
    else if (M_Ready&M_Valid) begin
        if (M_En_Last_Col&&M_En_Last_Cout)
            M_Cnt_Row <= M_Cnt_Row + 1'b1;
        else
            M_Cnt_Row <= M_Cnt_Row;
    end
    else
        M_Cnt_Row <= M_Cnt_Row;
end

assign  Last = (M_En_Last_Cout&&M_En_Last_Col&&M_En_Last_Row)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
       Stride_Complete <= 1'b0;
    else if (Last) 
       Stride_Complete <= 1'b1;
    else
       Stride_Complete <= 1'b0;
end

endmodule