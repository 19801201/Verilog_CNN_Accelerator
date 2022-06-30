`timescale 1ns / 1ps
`include  "../Para.v"



module upsampling#(parameter
     CHANNEL_OUT_NUM      =  16,
     WIDTH_CHANNEL_NUM_REG   =  10,
     WIDTH_FEATURE_SIZE  = 11
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start,
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data, //256
    input  S_Valid,
    output S_Ready,
    input  [WIDTH_FEATURE_SIZE-1 :0]    Row_Num_Out_REG,    
    input  [WIDTH_CHANNEL_NUM_REG-1 :0] Channel_Out_Num_REG, 
    input  M_Ready,
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    output M_Valid,
    output	reg   Upsample_Complete,
    output   Last_Upsample
    );
    
    localparam      Idle_State               = 7'b000_0000;
    localparam      Wait_State               = 7'b000_0001;
    localparam      Judge_Fifo_State         = 7'b000_0010;
    localparam      Write_Fifo_State         = 7'b000_0100;
    localparam      Read1_2_State            = 7'b000_1000;
    localparam      Read3_4_State            = 7'b001_0000;
    localparam      Judge_M_Fifo_State       = 7'b010_0000;
    localparam      Judge_LastRow_State      = 7'b100_0000;
    
    //////
    reg [5:0]    wait_cnt;
    wire         wait_en;
    //////
    
    reg  [8:0]  Current_State;
    reg  [8:0]  Next_State; 
    reg  [9:0]  Cnt_Row;
    reg  [9:0]  Cnt_Column; 
    reg  [10:0] Cnt_Cin; 
    reg  rd_en_fifo;
    
    wire [`AXI_WIDTH_DATA_IN-1:0] First_dout,dout_1,dout_2,dout_3,dout_4;
    wire Row_Full,EN_Row_Read,EN_Judge_Row,EN_Last_Cin;
    wire EN_Row_Read_2; 
    wire EN_Row_Read_3;
    wire Write_Ready;
    wire empty;
    
    wire [WIDTH_FEATURE_SIZE-1:0]         S_Count_Fifo;
    wire [WIDTH_CHANNEL_NUM_REG-1'b1:0]   Channel_Times;    
    wire [WIDTH_FEATURE_SIZE-1:0]         Row1;    // Row*2
    wire [WIDTH_FEATURE_SIZE-1:0]         Row2;     // Row*4
                               
    assign Channel_Times      = Channel_Out_Num_REG>>4;                                                  
    assign EN_Row_Read        = (Cnt_Column == Row_Num_Out_REG-1'b1 && EN_Last_Cin == 1'b1)?1'b1:1'b0; 
    assign EN_Judge_Row       = (Cnt_Row    == Row_Num_Out_REG-1'b1)?1'b1:1'b0;                        
    assign EN_Last_Cin        = (Cnt_Cin    == Channel_Times-1'b1)?1'b1:1'b0;                          
    

    
    always@( posedge clk  )begin    
        if( rst )begin
            Current_State <= Idle_State;
        end
        else begin
            Current_State <= Next_State;
        end
     end
     always@(*) begin
        Next_State = Idle_State;   
        case(Current_State)    
           Idle_State:
                if(Start==1'b1)
                    Next_State = Wait_State;   
                else 
                    Next_State = Idle_State;
           Wait_State:
               if (wait_en)
                   Next_State = Judge_Fifo_State;
               else
                   Next_State = Wait_State;
            Judge_Fifo_State:
                if(Row_Full==1'b1)
                    Next_State = Write_Fifo_State;
                else 
                    Next_State = Judge_Fifo_State;
            Write_Fifo_State:   
                if(EN_Row_Read==1'b1)
                    Next_State = Judge_M_Fifo_State ;
                else 
                    Next_State = Write_Fifo_State; 
            Judge_M_Fifo_State :
                if(empty==1'b1)
                    Next_State = Read1_2_State ;
                else 
                    Next_State = Judge_M_Fifo_State;     
            Read1_2_State: 
                if(EN_Row_Read_2)       //  80                 
                    Next_State = Read3_4_State;
                else
                    Next_State = Read1_2_State;
            Read3_4_State: 
                if(EN_Row_Read_3)      //     160               
                    Next_State = Judge_LastRow_State;
                else
                    Next_State = Read3_4_State;
            Judge_LastRow_State:
                if(EN_Judge_Row)
                    Next_State = Idle_State;
                else
                    Next_State = Judge_Fifo_State;
            default:
                Next_State = Idle_State;
        endcase  
    end    
    
       
//////////////////
always @ (posedge clk) begin 
    if (rst)
        wait_cnt <= 6'd0;
    else if (Current_State == Wait_State) begin
        if (wait_cnt > 6'd10)
            wait_cnt <= wait_cnt;
        else
            wait_cnt <= wait_cnt + 1'b1;
    end else if(Current_State == Judge_LastRow_State && Next_State==Idle_State) begin
        wait_cnt<=6'd0;
    end else begin
        wait_cnt <= wait_cnt; 
    end
end

assign wait_en = (wait_cnt + 1'b1 == 6'd10)?1'b1:1'b0;    

mult_up mult_upsample   (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [10 : 0] A
  .B(Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo)      // output wire [10 : 0] P
);    


mult_upsample mult_upsample1 (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [10 : 0] A
  .B(3'd2),      // input wire [2 : 0] B
  .P(Row1)      // output wire [10 : 0] P
);

mult_upsample mult_upsample2 (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [10 : 0] A
  .B(3'd4),      // input wire [2 : 0] B
  .P(Row2)      // output wire [10 : 0] P
);
////////////////////////////////////////////    
    
always@(posedge clk)begin
    if(rst)begin
        rd_en_fifo <= 1'b0; 
    end
    if(Next_State == Write_Fifo_State)begin
        rd_en_fifo <= 1'b1; 
    end
    else begin
        rd_en_fifo <= 1'b0; 
    end
end    
   
Upsampling_Read_FIFO  #(                              
        .WIDTH(`AXI_WIDTH_DATA_IN),                                 
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)                              
)    read_fifo(                                                   
     .clk(clk),                                     
     .rst(rst),                                     
     .din(S_Data), 
     .wr_en(S_Valid&S_Ready),   
  //     .wr_en(S_Valid),                           
     .rd_en(rd_en_fifo), 
     .dout(First_dout),      
     .M_count(S_Count_Fifo),                        
     .M_Ready(Row_Full),         
     .S_count(16),                   
     .S_Ready(S_Ready)        
);    
    
always@(posedge clk)begin    
   if(rst)
       Cnt_Cin <=  {11{1'b0}};
   else begin
       case(Current_State)
          Idle_State:     
            Cnt_Cin <=  {11{1'b0}};
          Write_Fifo_State: 
            if(EN_Last_Cin)//
                Cnt_Cin <=   {11{1'b0}};
              else 
                Cnt_Cin <=  Cnt_Cin+1;       
        default:
                Cnt_Cin <= {11{1'b0}};  
       endcase
   end
end    
    
always@(posedge clk)begin    
   if(rst)
       Cnt_Column <= {10{1'b0}};
   else begin
       case(Current_State)
           Idle_State:
                Cnt_Column <= {10{1'b0}};
           Write_Fifo_State:                    
               if(EN_Last_Cin)
                    Cnt_Column <= Cnt_Column+1;
               else
                    Cnt_Column <= Cnt_Column; 
           default: Cnt_Column <= {10{1'b0}};                         
       endcase
   end
end    
    
always@(posedge clk)begin
    if(rst)
        Cnt_Row <= {10{1'b0}};
    else begin
    case(Current_State)
        Idle_State:
             Cnt_Row <= {10{1'b0}};
        Judge_LastRow_State:
             Cnt_Row <= Cnt_Row + 1'b1; 
        default:
             Cnt_Row <= Cnt_Row;
    endcase
    end
end     

reg     rd_en_1,rd_en_3;
reg     [10:0] Cnt_Cin_2;  
reg     [9:0]  Cnt_Column_2;
wire    EN_Last_Cin_2;

reg     wr_en;

//assign EN_Row_Read_2 = (Cnt_Column_2+1'b1 == Row_Num_Out_REG*2 && EN_Last_Cin_2 == 1'b1)?1'b1:1'b0; 
assign EN_Row_Read_2 = (Cnt_Column_2+1'b1 == Row1 && EN_Last_Cin_2 == 1'b1)?1'b1:1'b0; 
//assign EN_Row_Read_3 = (Cnt_Column_2+1'b1 == Row_Num_Out_REG*4 && EN_Last_Cin_2 == 1'b1)?1'b1:1'b0; 
assign EN_Row_Read_3 = (Cnt_Column_2+1'b1 == Row2 && EN_Last_Cin_2 == 1'b1)?1'b1:1'b0; 
assign EN_Last_Cin_2 = (Cnt_Cin_2 == Channel_Times-1'b1)?1'b1:1'b0;
always@(posedge clk)begin    
   if(rst)
       Cnt_Cin_2 <=  {11{1'b0}};
   else begin
       case(Current_State)
          Idle_State:     
                Cnt_Cin_2 <=  {11{1'b0}};
          Read1_2_State: 
            if(EN_Last_Cin_2)
                Cnt_Cin_2 <=   {11{1'b0}};
              else                                                     
                Cnt_Cin_2 <=  Cnt_Cin_2+1;  
          Read3_4_State: 
            if(EN_Last_Cin_2)
                Cnt_Cin_2 <=   {11{1'b0}};
              else                                                     
                Cnt_Cin_2 <=  Cnt_Cin_2+1;           
          default:
                Cnt_Cin_2 <= {11{1'b0}};  
       endcase
   end
end  
always@(posedge clk)begin    
   if(rst)begin
       Cnt_Column_2 <= {10{1'b0}};
       rd_en_1 <= 1'b0;
       rd_en_3 <= 1'b0;
       end
   else begin
       case(Current_State)
           Idle_State:begin
                Cnt_Column_2 <= {10{1'b0}};
                rd_en_1 <= 1'b0;
                end
           Read1_2_State: 
               if(EN_Last_Cin_2)begin
                    Cnt_Column_2 <= Cnt_Column_2+1;
                    rd_en_1 <= ~rd_en_1;
                    end
               else begin
                    Cnt_Column_2 <= Cnt_Column_2; 
                    rd_en_1 <= rd_en_1;
               end
           Read3_4_State: 
               if(EN_Last_Cin_2)begin
                    Cnt_Column_2 <= Cnt_Column_2+1;
                    rd_en_3 <= ~rd_en_3;
                    end
               else begin
                    Cnt_Column_2 <= Cnt_Column_2; 
                    rd_en_3 <= rd_en_3;
               end
           default: begin
                Cnt_Column_2 <= {10{1'b0}};        
                rd_en_1 <= 1'b0;   
                rd_en_3 <= 1'b0;      
                end        
       endcase
   end
end

wire rd_en_2,rd_en_4;
assign rd_en_2 = (Current_State==Read1_2_State)?~rd_en_1:1'b0;
assign rd_en_4 = (Current_State==Read3_4_State)?~rd_en_3:1'b0;

always@(posedge clk)begin    
   if(rst)
       wr_en <=  1'b0;
   else begin
       case(Current_State)
          Idle_State:     
                wr_en <= 1'b0;
          Read1_2_State: 
                wr_en <=  1'b1;   
          Read3_4_State: 
                wr_en <=  1'b1;
          default:
                wr_en <= 1'b0;  
       endcase
   end
end  
reg [`AXI_WIDTH_DATA_IN-1:0] Last_din;

always@(posedge clk)begin
    case(Current_State)
        Idle_State:
            Last_din<={`AXI_WIDTH_DATA_IN{1'b0}};
        Read1_2_State:
            if(rd_en_1==1'b1)
                Last_din<=dout_1;
            else 
                Last_din<=dout_2;
        Read3_4_State:
            if(rd_en_3==1'b1)
                Last_din<=dout_3;
            else 
                Last_din<=dout_4;
        default:
            Last_din<={`AXI_WIDTH_DATA_IN{1'b0}};
    endcase
end

upsampling_fifo_1 fifo_1 (
  .clk(clk), 
  .srst(rst),
  .din(First_dout), 
  .wr_en(rd_en_fifo),
  .rd_en(rd_en_1), 
  .dout(dout_1),    
  .full(),    
  .empty()  
);
upsampling_fifo_1 fifo_2 (
  .clk(clk),     
  .srst(rst),    
  .din(First_dout),     
  .wr_en(rd_en_fifo), 
  .rd_en(rd_en_2), 
  .dout(dout_2),   
  .full(),   
  .empty()  
);
upsampling_fifo_1 fifo_3 (
  .clk(clk),    
  .srst(rst),   
  .din(First_dout),    
  .wr_en(rd_en_fifo),
  .rd_en(rd_en_3),
  .dout(dout_3),  
  .full(),  
  .empty() 
);
upsampling_fifo_1 fifo_4 (
  .clk(clk),     
  .srst(rst),    
  .din(First_dout),     
  .wr_en(rd_en_fifo), 
  .rd_en(rd_en_4), 
  .dout(dout_4),   
  .full(),   
  .empty()  
); 

reg [WIDTH_FEATURE_SIZE-1:0]    data_count_row;
reg [WIDTH_FEATURE_SIZE-1:0]    data_count1;
wire [WIDTH_FEATURE_SIZE-1:0]   data_count;


always@(posedge clk)begin
    data_count_row <=  Row1;
end  

always@(posedge clk)begin
    data_count1 <=  Row2;
end  

//always@(posedge clk)begin
//    data_count <=data_count1*Channel_Times;
//end  
mult_up   mult_upsample3   (
  .CLK(clk),  // input wire CLK
  .A(data_count1),      // input wire [10 : 0] A
  .B(Channel_Times),      // input wire [9 : 0] B
  .P(data_count)      // output wire [10 : 0] P
);    

Upsampling_Write_FIFO  #(
        .WIDTH(`AXI_WIDTH_DATA_IN),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
write_fifo
(
     .clk(clk),
     .rst(rst),
     .din(Last_din),
     .wr_en(wr_en),
     .rd_en(M_Ready&M_Valid),
     .dout(M_Data),
     .M_count(data_count),   
     .M_Ready(),
     .S_count(50),   
     .S_Ready(Write_Ready),
     .empty(empty)
); 
assign M_Valid = !empty;    

       
////////////////////        Last_Logic              /////////////////////////
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Row;
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Column;
reg      [WIDTH_CHANNEL_NUM_REG-1:0]	    M_Cnt_Cout;

wire                                       M_En_Last_Cout;   
wire                                       M_En_Last_Col;   
wire                                       M_En_Last_Row;   


assign  M_En_Last_Cout = (M_Cnt_Cout + 1'b1 == Channel_Times)?1'b1:1'b0;
assign  M_En_Last_Col = (M_Cnt_Column + 1'b1 == data_count_row)?1'b1:1'b0;
assign  M_En_Last_Row = (M_Cnt_Row + 1'b1 == data_count_row)?1'b1:1'b0;

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
    else if (M_En_Last_Cout&M_Ready&M_Valid)  begin
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
    else if (M_Ready&M_Valid)  begin
        if (M_En_Last_Col&&M_En_Last_Cout)
            M_Cnt_Row <= M_Cnt_Row + 1'b1;
        else
            M_Cnt_Row <= M_Cnt_Row;
    end
    else
        M_Cnt_Row <= M_Cnt_Row;
end

assign  Last_Upsample = (M_En_Last_Cout&&M_En_Last_Col&&M_En_Last_Row)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
       Upsample_Complete <= 1'b0;
    else if (Last_Upsample) 
       Upsample_Complete <= 1'b1;
    else
       Upsample_Complete <= 1'b0;
end
    
endmodule