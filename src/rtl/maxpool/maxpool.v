`timescale 1ns / 1ps

`include"../Para.v"

module maxpool#(parameter
     RE_CHANNEL_IN_NUM       = 16,
     WIDTH_CHANNEL_NUM_REG   = 10,
     WIDTH_FEATURE_SIZE      = 11
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
    output Last_Maxpool,
    output reg MaxPool_Complete,
    input  M_Ready,
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    output M_Valid
    );


    reg  [9:0]  Cnt_Row;
    reg  [9:0]  Cnt_Column,Cnt_Column_2; 
    reg  [10:0] Cnt_Cin,Cnt_Cin_2;        
    reg  S_Valid_2,S_Valid_3;
    reg rd_en_1,rd_en_2;
    wire [`AXI_WIDTH_DATA_IN-1:0] dout_buffer_1,dout_buffer_2;
    
    reg EN_Last_Cin_q,EN_Last_Column_q;
    wire EN_Last_Cin,EN_Last_Cin_2;
    wire EN_Last_Column,EN_Last_Column_2,EN_Judge_Row;
    
    wire [WIDTH_CHANNEL_NUM_REG-1'b1:0] Channel_Times;                               
    assign Channel_Times      = Channel_Out_Num_REG>>4;                                                  
    assign EN_Last_Column     = (Cnt_Column+1'b1 == Row_Num_Out_REG && EN_Last_Cin == 1'b1)?1'b1:1'b0; 
    assign EN_Last_Column_2   = (Cnt_Column_2+1'b1 == Row_Num_Out_REG >> 1 && EN_Last_Cin_2 == 1'b1)?1'b1:1'b0;
    assign EN_Judge_Row       = (Cnt_Row+1'b1    == Row_Num_Out_REG && EN_Last_Column_2 == 1'b1)?1'b1:1'b0;                        
    assign EN_Last_Cin        = (Cnt_Cin    == Channel_Times-1'b1)?1'b1:1'b0;  
    assign EN_Last_Cin_2      = (Cnt_Cin_2  == Channel_Times-1'b1)?1'b1:1'b0; 

//********* Buffer_1 **********
wire empty_1;

maxpool_read_fifo  #(                              
        .WIDTH(`AXI_WIDTH_DATA_IN),                                 
        .ADDR_BITS(WIDTH_FEATURE_SIZE+1)     // 12                           
)
maxpool_read_fifo                                 
(                                                   
     .clk(clk),                                     
     .rst(rst),                                     
     .din(S_Data),                               
     .wr_en(S_Valid),                               
     .rd_en(rd_en_1 && !empty_1),                             
     .dout(dout_buffer_1),                                   
//     .M_count(S_Count_Fifo),                        
//     .M_Ready(Row_Full),         
//     .S_count(16),    
     .empty(empty_1),
     .S_Ready(S_Ready)        
);   

always@(posedge clk)begin    
   if(rst)begin
       Cnt_Cin <=  {11{1'b0}};
   end
   else if(S_Valid)begin
        if(EN_Last_Cin)
            Cnt_Cin <=  {11{1'b0}};
        else
            Cnt_Cin <=  Cnt_Cin+1;
   end
   else begin
        Cnt_Cin <=  Cnt_Cin;
   end
end  

always@(posedge clk)begin    
   if(rst)
        Cnt_Column <= {10{1'b0}};
   else begin
        if(EN_Last_Column)
              Cnt_Column <= {10{1'b0}};         
        else if(EN_Last_Cin)
             Cnt_Column <= Cnt_Column+1;
        else
             Cnt_Column <= Cnt_Column; 
   end
end    

always@(posedge clk)begin    
   if(rst)
        S_Valid_2 <= 1'b0;
   else begin
        if(Cnt_Column[0])
            S_Valid_2 <= 1'b1;
        else
            S_Valid_2 <= 1'b0;
   end
end 

always@(posedge clk)begin  
    EN_Last_Cin_q <= EN_Last_Cin;
end

always@(posedge clk)begin    
   if(rst)
        rd_en_1 <= 1'b0;
   else begin
        if(EN_Last_Cin == 1 && EN_Last_Cin_q == 0)
            rd_en_1 <= 1'b1;
        else
            rd_en_1 <= rd_en_1;
   end
end 

wire [`AXI_WIDTH_DATA_IN-1:0] data_out_1;
compare_maxpool#(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
)compare_1(
    .clk          (clk     ),
    .rst          (rst     ),
    .data_1       (dout_buffer_1),
    .data_2       (S_Data  ),
    .data_out     (data_out_1)
);

reg wr_en_2;
always@(posedge clk)begin 
    wr_en_2 <= S_Valid;
end

//********* Buffer_2 **********
wire empty_2;
reg rd_en_2_q;
Buffer_2 Buffer_2 (
  .clk(clk),      // input wire clk
  .srst(rst),    // input wire srst
  .din(data_out_1),      // input wire [127 : 0] din
  .wr_en(wr_en_2),  // input wire wr_en
  .rd_en(rd_en_2_q && !empty_2),  // input wire rd_en
  .dout(dout_buffer_2),    // output wire [127 : 0] dout
  .full(),    // output wire full
  .empty(empty_2)  // output wire empty
);


always@(posedge clk)begin    
   if(rst)begin
       Cnt_Cin_2 <=  {11{1'b0}};
   end
   else if(S_Valid_2)begin
        if(EN_Last_Cin_2)
            Cnt_Cin_2 <=  {11{1'b0}};
        else
            Cnt_Cin_2 <=  Cnt_Cin_2+1;
   end
   else begin
        Cnt_Cin_2 <=  Cnt_Cin_2;
   end
end  

always@(posedge clk)begin    
   if(rst)
        Cnt_Column_2 <= {10{1'b0}};
   else begin
        if(EN_Last_Column_2)
              Cnt_Column_2 <= {10{1'b0}};         
        else if(EN_Last_Cin_2)
             Cnt_Column_2 <= Cnt_Column_2 + 1'b1;
        else
             Cnt_Column_2 <= Cnt_Column_2; 
   end
end  

always@(posedge clk)begin    
   if(rst)
        Cnt_Row <= {10{1'b0}};
   else begin
        if(EN_Judge_Row)
              Cnt_Row <= {10{1'b0}};         
        else if(EN_Last_Column_2)
             Cnt_Row <= Cnt_Row + 1'b1;
        else
             Cnt_Row <= Cnt_Row; 
   end
end 

always@(posedge clk)begin    
   if(rst)
        S_Valid_3 <= 1'b0;
   else
        S_Valid_3 <= Cnt_Row[0] && S_Valid_2;
end 

always@(posedge clk)begin  
    EN_Last_Column_q <= EN_Last_Column;
end

always@(posedge clk)begin    
   if(rst)
        rd_en_2 <= 1'b0;
   else begin
        if(EN_Last_Column == 1 &&EN_Last_Column_q == 0)
            rd_en_2 <= 1'b1;
        else
            rd_en_2 <= rd_en_2;
   end
end 

always@(posedge clk)begin  
    rd_en_2_q <= rd_en_2;
end

wire [`AXI_WIDTH_DATA_IN-1:0] data_out_2;
compare_maxpool #(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
)compare_2(
    .clk          (clk     ),
    .rst          (rst     ),
    .data_1       (dout_buffer_2),
    .data_2       (data_out_1  ),
    .data_out     (data_out_2)
);

wire empty;
maxpool_write_fifo  #(
        .WIDTH(`AXI_WIDTH_DATA_IN),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
maxpool_write_fifo
(
     .clk(clk),
     .rst(rst),
     .din(data_out_2),
     .wr_en(S_Valid_3),
     .rd_en(M_Ready&M_Valid),
     .dout(M_Data),
     .M_count(Row_Num_Out_REG*Channel_Times>>1),   
     .M_Ready(),
     .S_count(Row_Num_Out_REG*Channel_Times>>1),   
     .S_Ready(),
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
assign  M_En_Last_Col = (M_Cnt_Column + 1'b1 == Row_Num_Out_REG >> 1)?1'b1:1'b0;
assign  M_En_Last_Row = (M_Cnt_Row + 1'b1 == Row_Num_Out_REG >> 1)?1'b1:1'b0;

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

assign  Last_Maxpool = (M_En_Last_Cout&&M_En_Last_Col&&M_En_Last_Row)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
       MaxPool_Complete <= 1'b0;
    else if (Last_Maxpool) 
       MaxPool_Complete <= 1'b1;
    else
       MaxPool_Complete <= 1'b0;
end

endmodule
