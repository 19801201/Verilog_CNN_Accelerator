`timescale 1ns / 1ps

`include"../Para.v"
module padding#(parameter 
    CHANNEL_IN_NUM            =  16,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM         =  10 
)
(
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start,
    input  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] S_Feature,//4x8x8=256  fifo
    input  S_Valid,
    output S_Ready,
    input  [WIDTH_FEATURE_SIZE-1 :0]    Row_Num_In_REG,
    input  [WIDTH_CHANNEL_NUM-1'b1   :0]Channel_In_Num_REG,
    input  Padding_REG,        //1
    input  [`WIDTH_DATA-1:0] Zero_Point_REG,
    input  [2:0] Zero_Num_REG,
    input   M_Ready,
    output reg[`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] M_Data,
    output reg M_Write_EN,
    output [WIDTH_FEATURE_SIZE-1:0] Row_Num_After_Padding
    );


/////////////////
reg [4:0]  wait_cnt;
wire       wait_en;
/////////////////
 
reg S_Read_En; 
reg [8:0]  Current_State;
reg [8:0]  Next_State; 
reg  [WIDTH_CHANNEL_NUM-1'b1:0]Cnt_Cin;
reg  [WIDTH_FEATURE_SIZE-1:0]  Cnt_Row;
reg  [WIDTH_FEATURE_SIZE-1:0]  Cnt_Column; 
reg  [WIDTH_FEATURE_SIZE-1:0]  In_Size;
reg  [WIDTH_FEATURE_SIZE-1:0]  Out_Size;
//reg  [2:0] Cnt_Zero;
//reg  EN_Row0 ;
//reg  EN_Row1 ;
//reg  EN_Col0 ;
//reg  EN_Col1 ;  
wire  EN_Row0 ;
wire  EN_Row1 ;
wire  EN_Col0 ;
wire  EN_Col1 ;  
wire S_Row_Full,EN_Row_Read,EN_Judge_Row,EN_Left_Padding,EN_Last_Cin; 
assign Row_Num_After_Padding =  Out_Size;
localparam Idle_State              = 9'b0_0000_0000;   //0
localparam Wait_State              = 9'b0_0000_0001;
localparam M_Row_Wait_State        = 9'b0_0000_0010;//1
localparam S_Left_Padding_State    = 9'b0_0000_0100;//2
localparam S_Row_Wait_State        = 9'b0_0000_1000;//5
localparam M_Up_Down_Padding_State = 9'b0_0001_0000;//3
localparam M_Right_Padding_State   = 9'b0_0010_0000;//4
localparam M_Row_Read_State        = 9'b0_0100_0000;//6
localparam Judge_Row_State         = 9'b0_1000_0000;//7
wire [WIDTH_CHANNEL_NUM-1'b1:0] Channel_Times;
//assign Channel_Times = Channel_In_Num_REG/CHANNEL_IN_NUM;
assign Channel_Times = Channel_In_Num_REG >> 4;
assign EN_Last_Cin        =(Cnt_Cin==Channel_Times-1'b1)?1'b1:1'b0;
assign EN_Row_Read        = (Cnt_Column == In_Size-1'b1&&EN_Last_Cin)?1'b1:1'b0;
assign EN_Judge_Row       = (Cnt_Row == Out_Size-1'b1)?1'b1:1'b0;
assign EN_Left_Padding    =((EN_Row0&Cnt_Row < Zero_Num_REG )|| (EN_Row1&(Cnt_Row > Out_Size - Zero_Num_REG -1'b1)));
  wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1 :0] dout;


wire   [WIDTH_FEATURE_SIZE-1'b1:0]      S_Count_Fifo;
Padding_FIFO  #(
        .WIDTH(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
Padding_FIFO
(
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(S_Feature),
     .wr_en(S_Valid),
     .rd_en(S_Read_En),
     .dout(dout),
     .M_count(S_Count_Fifo),  //back
     .M_Ready(S_Row_Full),
     .S_count(S_Count_Fifo),   //front
     .S_Ready(S_Ready)
); 

//task NoPadding;
//begin
//        In_Size =Row_Num_In_REG;
//        Out_Size=Row_Num_In_REG;
//      {EN_Row0,EN_Row1,EN_Col0,EN_Col1}=4'b0000;
//end
//endtask
//task NormPadding;
//begin
//         In_Size = Row_Num_In_REG;
//         Out_Size=Row_Num_In_REG+2*Zero_Num_REG;
//      {EN_Row0,EN_Row1,EN_Col0,EN_Col1}=4'b1111;
//end
//endtask
 
//always@(*)begin
//     case(Padding_REG)
//       1'b0: NoPadding;
//       1'b1: NormPadding;
//       default:NoPadding; 
//       endcase
//end   
////////////////////////////////////////
always @ (posedge clk) begin 
     In_Size <= Row_Num_In_REG;          
end

always @ (posedge clk) begin 
     case (Padding_REG)       
         1'b0:
             Out_Size <= Row_Num_In_REG;
         1'b1:
             Out_Size <= Row_Num_In_REG+2*Zero_Num_REG;
    default:
        Out_Size <= Row_Num_In_REG;
     endcase   
end

assign EN_Row0 = (Padding_REG)?1'b1:1'b0;
assign EN_Row1 = (Padding_REG)?1'b1:1'b0;
assign EN_Col0 = (Padding_REG)?1'b1:1'b0;
assign EN_Col1 = (Padding_REG)?1'b1:1'b0;


/////////////////////////////////////



always@( posedge clk )	begin
	if( rst )begin
		Current_State       <=          Idle_State;
	end
	else begin
		Current_State       <=          Next_State;
	end
end 
always@(*)begin
      case(Current_State)
        Idle_State:
            if(Start==1'b1 )begin
                Next_State = Wait_State;
            end
            else begin
                Next_State = Idle_State;
            end
        Wait_State:
            if (wait_en)
                Next_State = M_Row_Wait_State;
            else
                Next_State = Wait_State; 
        M_Row_Wait_State://1
            if(M_Ready == 1'b1)begin//M_Row_Empty
                if(EN_Row0==1'b1 ) begin//|| EN_Left_Padding
                    Next_State = S_Left_Padding_State;
                    end
                else begin
                    Next_State = S_Row_Wait_State;
                end
            end
            else begin
                Next_State = M_Row_Wait_State;
            end
        S_Row_Wait_State://5
            if(S_Row_Full == 1'b1)begin
                     Next_State = M_Row_Read_State;
            end
            else begin
                    Next_State = S_Row_Wait_State;
            end
        M_Row_Read_State://6
            if(EN_Row_Read==1'b1)begin
                if(EN_Col1==1'b0)begin
                    Next_State = Judge_Row_State;
                end
                else begin
                    Next_State = M_Right_Padding_State;
                end
            end
            else begin
                Next_State = M_Row_Read_State;
            end
        Judge_Row_State://7
            if(EN_Judge_Row==1'b1)begin
                Next_State = Idle_State;
            end
            else begin
                Next_State = M_Row_Wait_State;
            end
        S_Left_Padding_State://2
            if(EN_Left_Padding == 1'b1)begin
                if(EN_Last_Cin)begin
                    Next_State = M_Up_Down_Padding_State;
                end
                else begin
                    Next_State = S_Left_Padding_State;
                end
            end
            else begin
                 if(EN_Last_Cin) begin
                    Next_State = S_Row_Wait_State;
                end
                 else begin
                    Next_State = S_Left_Padding_State;
                end
            end
        M_Up_Down_Padding_State://3
            if(EN_Row_Read==1'b1)begin
                if(EN_Col1==1'b0)begin
                    Next_State = Judge_Row_State;
                end
                else begin
                    Next_State = M_Right_Padding_State;
                end
            end
            else begin
                Next_State = M_Up_Down_Padding_State;
            end
        M_Right_Padding_State://4
            if(EN_Last_Cin)begin
                Next_State = Judge_Row_State;
            end
            else begin
               Next_State = M_Right_Padding_State;
            end
        default:
            Next_State = Idle_State;
      endcase
end

/////
always @ (posedge clk) begin 
    if (rst)
        wait_cnt <= 5'd0;
    else if (Current_State == Wait_State) begin
        if (wait_cnt > 5'd5)
            wait_cnt <= wait_cnt;
        else
            wait_cnt <= wait_cnt + 1'b1;
    end else if(Current_State == Judge_Row_State && Next_State==Idle_State) begin
        wait_cnt<=5'd0;
    end else begin
        wait_cnt <= wait_cnt; 
    end
end

assign wait_en = (wait_cnt + 1'b1 == 5'd5)?1'b1:1'b0;

count_mult count_padding (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_In_REG),      // input wire [11 : 0] A
  .B(Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo)      // output wire [11 : 0] P
);
/////
always@(posedge clk)begin
    if(rst)begin
        S_Read_En <= 1'b0; 
    end
    if(Next_State == M_Row_Read_State)begin
        S_Read_En <= 1'b1; 
    end
    else begin
        S_Read_En <= 1'b0; 
    end
end
always@(posedge clk)begin
    if(rst)begin
        M_Write_EN <= 1'b0; 
    end
    if(Current_State == S_Left_Padding_State||Current_State == M_Up_Down_Padding_State||Current_State ==M_Right_Padding_State||Current_State ==M_Row_Read_State)begin
        M_Write_EN <= 1'b1; 
    end
    else begin
        M_Write_EN <= 1'b0; 
    end
end

always@(posedge clk)begin
    if(rst)begin 
        Cnt_Cin <= {WIDTH_CHANNEL_NUM*{1'b0}};
    end
    if(Current_State == M_Row_Read_State||Current_State == M_Up_Down_Padding_State || Current_State == S_Left_Padding_State||Current_State == M_Right_Padding_State)begin
        if(EN_Last_Cin)begin
            Cnt_Cin <={WIDTH_CHANNEL_NUM*{1'b0}};
        end
        else begin
            Cnt_Cin <= Cnt_Cin+1'b1;
        end
    end
    else begin
        Cnt_Cin <= {WIDTH_CHANNEL_NUM*{1'b0}}; 
    end
end
always@(posedge clk)begin
    if(rst)begin 
        Cnt_Column <= {WIDTH_FEATURE_SIZE*{1'b0}};
    end
    else if (Current_State == M_Row_Read_State||Current_State == M_Up_Down_Padding_State )begin
        if (EN_Last_Cin == 1'b1)begin
            Cnt_Column   <=  Cnt_Column  +1'b1;
        end
        else begin
            Cnt_Column   <=  Cnt_Column ;
        end 
    end
    else begin
        Cnt_Column <= {WIDTH_FEATURE_SIZE*{1'b0}};
    end
end
always@(posedge clk)begin
    case(Current_State)
        Idle_State:
             Cnt_Row <= {WIDTH_FEATURE_SIZE*{1'b0}};
        Judge_Row_State:
             Cnt_Row <= Cnt_Row + 1'b1; 
        default:
            Cnt_Row <= Cnt_Row;
    endcase
end

//always@(posedge clk)begin
//    if(rst)begin
//        Cnt_Zero <= 3'b001;
//    end
//    else begin
//        if(Current_State == S_Left_Padding_State || Current_State == M_Right_Padding_State )begin
//            Cnt_Zero <= Cnt_Zero + 1'b1;
//        end
//        else begin
//            Cnt_Zero <= 3'b001;
//        end
//    end
//end

wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM - 1'b1:0] Zero_Point;

genvar i;
generate
         for(i=0;i<`PICTURE_NUM*CHANNEL_IN_NUM;i=i+1)begin
         assign Zero_Point[(i+1)*`WIDTH_DATA-1:i*`WIDTH_DATA]=Zero_Point_REG;
     end
endgenerate


always@(posedge clk)begin
    if(Current_State == S_Left_Padding_State || Current_State == M_Right_Padding_State ||Current_State == M_Up_Down_Padding_State)begin
            M_Data <= Zero_Point;       
    end
    else if(Current_State == M_Row_Read_State)begin
        M_Data <= dout;
    end
    else begin
        M_Data <={`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*{1'b0}};
    end 
end
endmodule

