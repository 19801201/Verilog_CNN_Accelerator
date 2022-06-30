`timescale 1ns / 1ps
`include  "../Para.v"


module image_padding(
    input  clk,
    input  rst,
    input  Start,
    input  Padding_REG,
    input  [2:0] Zero_Num_REG,
    input  [10:0] Row_Num_In_REG,
    input  [`IMAGE_WIDTH_DATA-1:0] S_Feature,
    input  S_Valid,
    output S_Ready,
    input  M_Ready,
    output reg[`IMAGE_WIDTH_DATA-1:0] M_Data,
    output reg M_Write_EN,
    output [9:0] Row_Num_After_Padding
    );
    reg S_Read_En; 
    reg [8:0]  Current_State;
    reg [8:0]  Next_State; 
    reg  [9:0]  Cnt_Row;
    reg  [9:0]  Cnt_Column; 
    reg  [9:0]  In_Size;
    reg  [9:0]  Out_Size;
    wire  EN_Row0 ;
    wire  EN_Row1 ;
    wire  EN_Col0 ;
    wire  EN_Col1 ;  
    wire S_Row_Full,EN_Row_Read,EN_Judge_Row,EN_Left_Padding; 
    assign Row_Num_After_Padding =  Out_Size;
    localparam Idle_State              = 9'b0_0000_0000;   //0
    localparam M_Row_Wait_State        = 9'b0_0000_0001;//1��һ��FIFO�ܷ��һ������??
    localparam S_Left_Padding_State    = 9'b0_0000_0010;//2�������??
    localparam S_Row_Wait_State        = 9'b0_0000_0100;//5
    localparam M_Up_Down_Padding_State = 9'b0_0000_1000;//3
    localparam M_Right_Padding_State   = 9'b0_0001_0000;//4
    localparam M_Row_Read_State        = 9'b0_0010_0000;//6
    localparam Judge_Row_State         = 9'b0_0100_0000;//7
    assign EN_Row_Read        = (Cnt_Column == In_Size-1'b1)?1'b1:1'b0;
    assign EN_Judge_Row       = (Cnt_Row == Out_Size-1'b1)?1'b1:1'b0;
    assign EN_Left_Padding    =((EN_Row0&Cnt_Row < Zero_Num_REG )|| (EN_Row1&(Cnt_Row > Out_Size - Zero_Num_REG -1'b1)));
    wire [`IMAGE_WIDTH_DATA-1:0] dout;
    
    Image_Padding_FIFO  #(
            .WIDTH(`IMAGE_WIDTH_DATA),
            .ADDR_BITS(11)
    )
    Image_Padding_FIFO
    (
         .clk(clk),
         .rst(rst),
         .din(S_Feature),
         .wr_en(S_Valid),
         .rd_en(S_Read_En),
         .dout(dout),
         .M_Count(Row_Num_In_REG),  //back
         .M_Valid(S_Row_Full),//有没有一行数�??
         .S_Count(Row_Num_In_REG),   //front
         .S_Ready(S_Ready)//能不能存下一行数�??
    ); 
    
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


//always@(posedge clk)begin
//     In_Size <= Row_Num_In_REG;
//     Out_Size<= Row_Num_In_REG+2*Zero_Num_REG;
//     {EN_Row0,EN_Row1,EN_Col0,EN_Col1}<=4'b1111;
//end
    always@( posedge clk )    begin
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
                    Next_State = M_Row_Wait_State;
                end
                else begin
                    Next_State = Idle_State;
                end
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
                        Next_State = M_Up_Down_Padding_State;
                end
                else begin                     
                        Next_State = S_Row_Wait_State;
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
                    Next_State = Judge_Row_State;               
            default:
                Next_State = Idle_State;
          endcase
    end
    
    
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
            Cnt_Column <= {10{1'b0}};
        end
        else if (Current_State == M_Row_Read_State||Current_State == M_Up_Down_Padding_State )begin
                Cnt_Column   <=  Cnt_Column  +1'b1;
        end
        else begin
            Cnt_Column <= {10{1'b0}};
        end
    end
    always@(posedge clk)begin
        case(Current_State)
            Idle_State:
                 Cnt_Row <= {10{1'b0}};
            Judge_Row_State:
                 Cnt_Row <= Cnt_Row + 1'b1; 
            default:
                Cnt_Row <= Cnt_Row;
        endcase
    end 
       
    wire [`IMAGE_WIDTH_DATA-1:0] Zero_Point;
    
    assign Zero_Point = {`IMAGE_WIDTH_DATA{1'b0}};

//    genvar i;
//    generate
//             for(i=0;i<4;i=i+1)begin
//             assign Zero_Point[(i+1)*8-1:i*8]=8'b0000_0000;
//         end
//    endgenerate
    
    
    always@(posedge clk)begin
        if(Current_State == S_Left_Padding_State || Current_State == M_Right_Padding_State ||Current_State == M_Up_Down_Padding_State)begin
            M_Data <= Zero_Point;       
        end
        else if(Current_State == M_Row_Read_State)begin
            M_Data <= dout;
        end
        else begin
            M_Data <={`IMAGE_WIDTH_DATA{1'b0}};
        end 
    end    
endmodule
