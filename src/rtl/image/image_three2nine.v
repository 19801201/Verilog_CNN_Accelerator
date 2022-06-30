`timescale 1ns / 1ps
`include "../Para.v"

module image_three2nine(
    input  clk,
    input  rst,
    input  Start,
    input  [`IMAGE_WIDTH_DATA*3-1:0] S_Feature,//8*3-1'b1
    output reg[9:0] Addr,//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ö·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ ï¿½Ó³ï¿½ï¿½ï¿½2ï¿½ï¿½ï¿½ï¿½
    input  [9 :0]Row_Num_After_Padding, //ï¿½Ð¶ï¿½ï¿½ï¿½/ï¿½ï¿½ï¿½ï¿½    
    input  Row_Compute_Sign,
    output [`IMAGE_WIDTH_DATA*3*3-1:0] M_Data, // 8*9
    input  M_Ready,
    output reg [8:0]M_EN_Write,
    output reg S_Ready
    );
    localparam Idle_State              =   12'b0000_0000_0001;//0
    localparam Start_Wait_State        =   12'b0000_0000_0010;//1
    localparam Judge_FIFO_State        =   12'b0000_0000_0100;//2
    localparam ComputeRow_Read_State   =   12'b0000_0000_1000;//3
    localparam Judge_LastRow_State     =   12'b0000_0100_0000;//6
//    localparam Width_Data = 8;
    reg   [11:0]  Current_State;
    reg   [11:0]  Next_State; 
    reg   [9:0]       Cnt_Column;
    reg   [9:0]       Cnt_Row;
    wire  EN_ComputeRow_Read,EN_Judge_LastRow,EN_Image_Stride;
    assign EN_ComputeRow_Read =(Cnt_Column == Row_Num_After_Padding)?1'b1:1'b0;
    assign EN_Judge_LastRow = (Cnt_Row == Row_Num_After_Padding-2'b11)?1'b1:1'b0;
    always@(posedge clk)begin
        if(rst)begin
            Current_State <= Idle_State;
        end
        else begin
            Current_State <= Next_State;
        end  
    end
    always@(*)begin
        Next_State = Idle_State;
        case(Current_State)
            Idle_State://0
                if(Start == 1'b1)begin
                    Next_State = Start_Wait_State;
                end
                else begin
                    Next_State = Idle_State;
                end
            Start_Wait_State://1
                if(Row_Compute_Sign==1'b1)begin 
                    Next_State = Judge_FIFO_State;
                end 
                else begin 
                    Next_State = Start_Wait_State;
                end 
            Judge_FIFO_State://2
                if(M_Ready == 1'b1)begin
                    Next_State = ComputeRow_Read_State;
                end
                else begin
                    Next_State = Judge_FIFO_State;
                end
            ComputeRow_Read_State://3
                if(EN_ComputeRow_Read)begin
                    Next_State = Judge_LastRow_State;
                 end
                else begin
                    Next_State = ComputeRow_Read_State;
                end
            Judge_LastRow_State://6
                if(EN_Judge_LastRow) begin
                    Next_State = Idle_State;
                end
                else begin
                    Next_State = Start_Wait_State;
                end 
            default:
                Next_State = Idle_State;
        endcase  
    end    
    always@(posedge clk)begin
        case(Current_State)
                Idle_State: 
                    Cnt_Column <={10{1'b0}};
                ComputeRow_Read_State:
                    Cnt_Column <=Cnt_Column+1'b1;
                Judge_LastRow_State:
                    Cnt_Column <={10{1'b0}};
                default:
                    Cnt_Column <= Cnt_Column;  
        endcase
    end
    always@(posedge clk)begin
        case(Current_State)
            Idle_State: 
                Cnt_Row <={10{1'b0}};
            Judge_LastRow_State:
                Cnt_Row <= Cnt_Row + 1'b1;
            default:
                Cnt_Row <= Cnt_Row;
        endcase
    end
    always@(posedge clk)begin
        if(rst)begin 
            Addr <=  {10{1'b0}};
        end
        else if(Current_State == ComputeRow_Read_State) begin
            Addr <=  Addr+1'b1;
        end
        else begin
            Addr <= {10{1'b0}};
        end
    end
    
    wire [`IMAGE_WIDTH_DATA*3-1:0] Feature[0:2];
    assign  Feature[0]   = S_Feature;//Ê¹ï¿½ï¿½0ï¿½ï¿½ï¿½Î?
    assign  Feature[1]   = S_Feature;//Ê¹ï¿½ï¿½1
    assign  Feature[2]   = S_Feature;//Ê¹ï¿½ï¿½2ï¿½ï¿½ï¿½Î?
    //12-30------------------------------------------
    
    //      assign M_Data = {S_Feature[3*Width_Data-1'b1:2*Width_Data],S_Feature[3*Width_Data-1'b1:2*Width_Data],S_Feature[3*Width_Data-1'b1:2*Width_Data],
    //                    S_Feature[2*Width_Data-1'b1:Width_Data],S_Feature[2*Width_Data-1'b1:Width_Data],S_Feature[2*Width_Data-1'b1:Width_Data],
    //                    S_Feature[Width_Data-1'b1:0],S_Feature[Width_Data-1'b1:0],S_Feature[Width_Data-1'b1:0]};
             
    //------------------------------------------------
    always@(posedge clk)begin
        if(rst)begin
            M_EN_Write <= 9'b0_0000_0000;
        end
        else if(Current_State == ComputeRow_Read_State) begin
          if(Cnt_Column >1&&Cnt_Column<Row_Num_After_Padding)begin
                M_EN_Write[2] <= 1'b1;
                M_EN_Write[5] <= 1'b1;
                M_EN_Write[8] <= 1'b1;
          end
          else begin
                M_EN_Write[2] <= 1'b0;
                M_EN_Write[5] <= 1'b0;
                M_EN_Write[8] <= 1'b0;
         end
         if(Cnt_Column >0&&Cnt_Column<Row_Num_After_Padding-1'b1)begin
                M_EN_Write[1] <= 1'b1;
                M_EN_Write[4] <= 1'b1;
                M_EN_Write[7] <= 1'b1;
          end
          else begin
                M_EN_Write[1] <= 1'b0; 
                M_EN_Write[4] <= 1'b0; 
                M_EN_Write[7] <= 1'b0; 
          end
         if(Cnt_Column<Row_Num_After_Padding-2'b10)begin
                M_EN_Write[0] <= 1'b1;
                M_EN_Write[3] <= 1'b1;
                M_EN_Write[6] <= 1'b1;
          end 
          else begin
                M_EN_Write[0] <= 1'b0;
                M_EN_Write[3] <= 1'b0;
                M_EN_Write[6] <= 1'b0;
          end       
        end
        else begin
            M_EN_Write  <= 9'b0_0000_0000;
        end
    end
    
    // ¿ÉÄÜÒª¸Ä
    genvar i;
    generate
         for(i=0;i<3;i=i+1)begin
         assign   M_Data[(i+1)*3*`IMAGE_WIDTH_DATA-1'b1:i*3*`IMAGE_WIDTH_DATA] = {Feature[2][(i+1)*`IMAGE_WIDTH_DATA-1'b1:i*`IMAGE_WIDTH_DATA],Feature[1][(i+1)*`IMAGE_WIDTH_DATA-1'b1:i*`IMAGE_WIDTH_DATA],Feature[0][(i+1)*`IMAGE_WIDTH_DATA-1'b1:i*`IMAGE_WIDTH_DATA]};
         end
    endgenerate
    
    always@(posedge clk)begin
        case(Next_State)
            Idle_State: 
                S_Ready <= 1'b1;
            Start_Wait_State:
                S_Ready <= 1'b0;////0ï¿½Ç²ï¿½ï¿½Ú¼ï¿½ï¿½ã£¬1ï¿½ï¿½ï¿½Ú¼ï¿½ï¿½ï¿½
            default:
                S_Ready <= 1'b1;
        endcase
    end   
endmodule
