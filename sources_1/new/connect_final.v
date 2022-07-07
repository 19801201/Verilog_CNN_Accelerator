`timescale 1ns / 1ps
`include"./Para.v"

module connect_final#(parameter
    RE_CHANNEL_IN_NUM= 16,
    RE_WIDTH_WEIGHT_NUM = 16,
    RE_WIDTH_FEATURE_SIZE = 11,
    RE_WIDTH_CHANNEL_NUM_REG= 10,
    RE_WIDTH_CONNECT_TIMES =15
    )
    (
    input   clk,
    input   rst,
    input   Next_Reg,
    input   Start,
    input   [RE_WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,
    input   [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_Ram_Part,
    input   [RE_WIDTH_CHANNEL_NUM_REG-1:0] Channel_Direct_Part,
    input   [RE_WIDTH_FEATURE_SIZE-1:0] Row_Num_In_REG,
    output   reg    Connect_Complete,
    //Stream read
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data_1,
    input  S_Valid_1,
    output S_Ready_1,
    
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data_2,
    input  S_Valid_2,
    output S_Ready_2,

    
    input	[31:0]	Concat1_ZeroPoint,     // para  zero point
    input	[31:0]	Concat2_ZeroPoint,        //   s_data zero point
    input	[31:0]	Concat1_Scale,        // para scale
    input	[31:0]	Concat2_Scale,      //  s_data scale
    
    output    M_Valid,
    input     M_Ready,
    output   [`AXI_WIDTH_DATA_IN-1:0]  M_Data,
    output    Last_Concat     
    );
//-----------------FSM_PARAM-------------
reg  [7:0]      Current_State;
reg  [7:0]      Next_State;


localparam     Idle_State                         = 8'b0000_0000;
localparam     Wait_State                         = 8'b0000_0001;
localparam     Judge_Fifo_State                   = 8'b0000_0010;
localparam     FIFO_Judge_State                   = 8'b0000_0100;    
localparam     Ram_Data_State                     = 8'b0000_1000;            
localparam     Delay_State                        = 8'b0001_0000;            
localparam     Direct_Data_State                  = 8'b0010_0000;            
localparam     Judge_Col_State                    = 8'b0100_0000;    
localparam	   Judge_Row_State					  = 8'b1000_0000;        

/////////////////////////////
reg  [5:0]     wait_cnt;
wire           wait_en;
/////////////////////////////

reg [RE_WIDTH_CHANNEL_NUM_REG-1'b1:0] Ram_Channel_Times;
reg [RE_WIDTH_CHANNEL_NUM_REG-1'b1:0] Direct_Channel_Times;

reg [RE_WIDTH_CONNECT_TIMES-1:0]  Ram_Channel_Cnt;
reg [RE_WIDTH_CONNECT_TIMES-1:0]  Direct_Channel_Cnt;
reg [RE_WIDTH_CONNECT_TIMES-1:0]  Row_Cnt; 
reg [RE_WIDTH_CONNECT_TIMES-1:0]  Col_Cnt; 

//  FIFO 
wire [RE_WIDTH_FEATURE_SIZE:0] S_Count_Fifo_1;
wire [RE_WIDTH_FEATURE_SIZE:0] S_Count_Fifo_2;
reg [RE_WIDTH_FEATURE_SIZE:0] S_Count_Fifo_3;
wire [`AXI_WIDTH_DATA_IN-1:0] First_dout_1;
wire [`AXI_WIDTH_DATA_IN-1:0] First_dout_2;
reg rd_en_fifo_1;
reg rd_en_fifo_2;

/////////////////////      para  data  8bit --->  32bit
reg	     [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]	Ram_Data_Trans;
wire     [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]	Ram_Data_AfterZero;
wire	 [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]	Ram_Data_AfterScale;
wire	 [`AXI_WIDTH_DATA_IN-1:0]	                Ram_Data_Final;

/////////////////////      s_data  8bit --->  32bit
reg     [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]     S_Data_Trans;
wire    [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]     S_Data_AfterZero;
wire    [`PICTURE_NUM*RE_CHANNEL_IN_NUM*32-1:0]     S_Data_AfterScale;
wire    [`AXI_WIDTH_DATA_IN-1:0]                    S_Data_Final;


 wire Fifo_S_Ready,Ram_Complete,Direct_Complete;
 reg  [`AXI_WIDTH_DATA_IN-1:0] M_Fifo_Data;
 reg sign,sign_delay ,Enough_Delay; 
 reg  [7:0] Enough_Delay1;

 reg	[7:0]	Fifo_En_Write_Delay;  
 reg    [7:0]   sign_delaydelay;   
 
concat_read_fifo_1  #(                              
        .WIDTH(`AXI_WIDTH_DATA_IN),                                 
        .ADDR_BITS(RE_WIDTH_FEATURE_SIZE)     // 11                           
)                       
Concat_Read_FIFO_1                                 
(                                                   
     .clk(clk),                                     
     .rst(rst),                                     
     .din(S_Data_1),                               
     .wr_en(S_Valid_1&&S_Ready_1),                               
     .rd_en(rd_en_fifo_1),                             
     .dout(First_dout_1),                                   
     .M_count(S_Count_Fifo_1),                        
     .M_Ready(Row_Full_1),         
     .S_count(16),                   
     .S_Ready(S_Ready_1)        
);  
concat_read_fifo_2  #(                              
        .WIDTH(`AXI_WIDTH_DATA_IN),                                 
        .ADDR_BITS(RE_WIDTH_FEATURE_SIZE)     // 11                           
)                       
Concat_Read_FIFO_2                                 
(                                                   
     .clk(clk),                                     
     .rst(rst),                                     
     .din(S_Data_2),                               
     .wr_en(S_Valid_2),                               
     .rd_en(rd_en_fifo_2),                             
     .dout(First_dout_2),                                   
     .M_count(S_Count_Fifo_2),                        
     .M_Ready(Row_Full_2),         
     .S_count(16),                   
     .S_Ready(S_Ready_2)        
);  

 always @ (posedge clk) begin 
    Ram_Channel_Times <= Channel_Ram_Part>>4;
 end

always @ (posedge clk) begin 
    Direct_Channel_Times <= Channel_Direct_Part>>4;
end
 

assign Ram_Complete   =(Ram_Channel_Cnt+1'b1==Ram_Channel_Times)?1'b1:1'b0; 
assign Direct_Complete =(Direct_Channel_Cnt+1'b1==Direct_Channel_Times)?1'b1:1'b0; 


wire[RE_WIDTH_CONNECT_TIMES-1:0] Row_Num;
wire[RE_WIDTH_CONNECT_TIMES-1:0] Col_Num;
wire		Col_Complete;
wire        empty;

assign Row_Num = {{3'b0},Row_Num_In_REG};     
assign Col_Num = {{3'b0},Row_Num_Out_REG}; 

assign	Col_Complete = (Col_Cnt == Col_Num - 1'b1)?1'b1:1'b0;

// --------------------------FSM---------------------------------------
 always@( posedge clk  )begin  
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
       		if( Start==1'b1)
                Next_State   =   Wait_State;
            else 
                Next_State   =   Idle_State; 
        Wait_State:
            if (wait_en)
                Next_State   =   Judge_Fifo_State;
            else
                Next_State   =   Wait_State;
    	Judge_Fifo_State:
    	    if (Row_Full_1 && Row_Full_2)
                Next_State   =   FIFO_Judge_State;
        	else
                Next_State   =   Judge_Fifo_State;
    	FIFO_Judge_State:
            if (empty == 1'b1)
                Next_State   =   Ram_Data_State;
        	else
                Next_State   =   FIFO_Judge_State;
       	Ram_Data_State:
            if(Ram_Complete==1'b1)  
                Next_State   =   Delay_State; 
            else 
                Next_State   =   Ram_Data_State;   
       	Delay_State:   
       		if(Enough_Delay1[7])
            	Next_State   =   Direct_Data_State; 
            else
                Next_State   =   Delay_State; 
    	Direct_Data_State:
            if(Direct_Complete==1'b1)  
                Next_State   =   Judge_Col_State; 
            else 
                Next_State   =   Direct_Data_State;     
       	Judge_Col_State:
       		if (Col_Complete == 1'b1) 
       			Next_State   =   Judge_Row_State;
       		else
       			Next_State   =   FIFO_Judge_State;
       	Judge_Row_State:
            if(Row_Cnt == Row_Num - 1'b1) 
                Next_State   =   Idle_State; 
            else 
                Next_State   =   FIFO_Judge_State;                                 
       default:
                Next_State  =    Idle_State;
    endcase    
end

//////////////////////
always @ (posedge clk) begin 
    if (rst)
        wait_cnt <= 6'd0;
    else if (Current_State == Wait_State) begin
        if (wait_cnt > 6'd10)
            wait_cnt <= wait_cnt;
        else
            wait_cnt <= wait_cnt + 1'b1;
    end else if(Current_State == Judge_Row_State && Next_State==Idle_State) begin
        wait_cnt<=6'd0;
    end else begin
        wait_cnt <= wait_cnt; 
    end
end

assign wait_en = (wait_cnt + 1'b1 == 6'd10)?1'b1:1'b0;

/////////////////////
//-----------------------sign-------------------------
reg Cnt_Delay_Time;
always@(posedge clk)
    if(Current_State==Delay_State)
        Cnt_Delay_Time<=Cnt_Delay_Time+1'b1;
    else
        Cnt_Delay_Time<=1'b0;
always@(posedge clk)
    if(Cnt_Delay_Time==1'b1)
           Enough_Delay<=1'b1;
    else
           Enough_Delay<=1'b0;
always @ (posedge clk) begin 
	Enough_Delay1[0] <= Enough_Delay;
end           

generate
genvar k;
    for (k = 0;k < 7; k = k + 1) begin 
    	always @ (posedge clk) begin
    		Enough_Delay1[k+1] <= Enough_Delay1[k];
    	end
    end
endgenerate
           
always@(posedge clk)
    if(Current_State==Ram_Data_State)
        sign<=1'b1;
    else 
        sign<=1'b0;

always@(posedge clk) begin
	sign_delay<=sign;
end


always @ (posedge clk) begin 
	sign_delaydelay[0] <= sign_delay;
end

generate
genvar n;
	for (n = 0;n < 7;n = n + 1 ) begin
		always @ (posedge clk) begin 
			sign_delaydelay[n+1] <= sign_delaydelay[n];
		end
	end
endgenerate


//////////////////  Ram data compute  ///////////////
///////   bit change   resume  1 clk 
generate
genvar i,j;
	for (i = 0;i < `PICTURE_NUM;i = i+1) begin 
		for (j = 0;j < RE_CHANNEL_IN_NUM;j = j + 1) begin 
			always @ (posedge clk) begin 
				Ram_Data_Trans[(j*`PICTURE_NUM+i+1)*32-1:(j*`PICTURE_NUM+i)*32] <= {{8{1'b0}},{First_dout_1[(j*`PICTURE_NUM+i+1)*`WIDTH_DATA-1:(j*`PICTURE_NUM+i)*`WIDTH_DATA]},{16{1'b0}}};
			end
		end
	end
endgenerate

//  2 clk
Concat_Zero   #(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
)   concat_zero1 (
	.clk(clk),
	.concat_data_in(Ram_Data_Trans),
	.zero_data_in(Concat1_ZeroPoint),
	.data_out(Ram_Data_AfterZero)
);

//  4 clk
Concat_Scale   #(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
)   concat_scale1 (
	.clk(clk),
	.Concat_Data_In(Ram_Data_AfterZero),
	.Scale_Data_In(Concat1_Scale),
	.Scale_Data_Out(Ram_Data_AfterScale)
);

//   1  clk
generate
genvar x,y;
	for (x = 0;x < `PICTURE_NUM;x = x+1) begin
		for (y = 0; y < RE_CHANNEL_IN_NUM;y = y + 1)  begin
			Concat_32to8   #(
			    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
			)   concat_32to8_1 (
				.clk(clk),
				.Concat_Data_In(Ram_Data_AfterScale[(y*`PICTURE_NUM+x+1)*32-1:(y*`PICTURE_NUM+x)*32]),
				.Concat_Data_Out(Ram_Data_Final[(y*`PICTURE_NUM+x+1)*`WIDTH_DATA-1:(y*`PICTURE_NUM+x)*`WIDTH_DATA])
			);
		end
	end
endgenerate


///////////////////////////////////////////////////

//////////////////  direct data compute  ///////////////
///////   bit change   resume  1 clk        8bit --> 32bit
generate
genvar a,b;
	for (a = 0;a < `PICTURE_NUM;a = a+1) begin 
		for (b = 0;b < RE_CHANNEL_IN_NUM;b = b + 1) begin 
			always @ (posedge clk) begin 
				S_Data_Trans[(b*`PICTURE_NUM+a+1)*32-1:(b*`PICTURE_NUM+a)*32] <= {{8{1'b0}},{First_dout_2[(b*`PICTURE_NUM+a+1)*`WIDTH_DATA-1:(b*`PICTURE_NUM+a)*`WIDTH_DATA]},{16{1'b0}}};
			end
		end
	end
endgenerate

//  2 clk
Concat_Zero   #(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
)   concat_zero2 (
	.clk(clk),
	.concat_data_in(S_Data_Trans),
	.zero_data_in(Concat2_ZeroPoint),
	.data_out(S_Data_AfterZero)
);

//  4 clk
Concat_Scale   #(
    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
)   concat_scale2 (
	.clk(clk),
	.Concat_Data_In(S_Data_AfterZero),
	.Scale_Data_In(Concat2_Scale),
	.Scale_Data_Out(S_Data_AfterScale)
);

//   1  clk
generate
genvar c,d;
	for (c = 0;c < `PICTURE_NUM;c = c+1) begin
		for (d = 0; d < RE_CHANNEL_IN_NUM;d = d + 1)  begin
			Concat_32to8   #(
			    .RE_CHANNEL_IN_NUM(RE_CHANNEL_IN_NUM)
			)   concat_32to8_2 (
				.clk(clk),
				.Concat_Data_In(S_Data_AfterScale[(d*`PICTURE_NUM+c+1)*32-1:(d*`PICTURE_NUM+c)*32]),
				.Concat_Data_Out(S_Data_Final[(d*`PICTURE_NUM+c+1)*`WIDTH_DATA-1:(d*`PICTURE_NUM+c)*`WIDTH_DATA])
			);
		end
	end
endgenerate

//---------------Concat1--------Part
always@( posedge clk  )begin    
   if( rst )
       rd_en_fifo_1 <=  1'b0;
   else begin
       case(Current_State)
          Idle_State:           
                rd_en_fifo_1 <=  1'b0;
          Ram_Data_State:
                rd_en_fifo_1 <=  1'b1;
          default:
                rd_en_fifo_1 <=  1'b0;
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Ram_Channel_Cnt <=  {15{1'b0}};
   else begin
       case(Current_State)
          Ram_Data_State:
                Ram_Channel_Cnt <=  Ram_Channel_Cnt+1;
          default:
                Ram_Channel_Cnt <=  {15{1'b0}};
       endcase
   end
end
//------------Concat2 -------part
always@( posedge clk  )begin    
   if( rst )
       rd_en_fifo_2 <=  1'b0;
   else begin
       case(Current_State)
          Idle_State:           
                rd_en_fifo_2 <=  1'b0;
          Direct_Data_State:
                rd_en_fifo_2 <=  1'b1;
          default:
                rd_en_fifo_2 <=  1'b0;
       endcase
   end
end
always@( posedge clk  )begin    
   if( rst )
       Direct_Channel_Cnt <=  {15{1'b0}};
   else begin
       case(Current_State)
          Direct_Data_State: 
                Direct_Channel_Cnt <=  Direct_Channel_Cnt+1;
          default:
                Direct_Channel_Cnt <=  {15{1'b0}};
       endcase
   end
end
//-------------point_cnt--------part
always@( posedge clk  )begin    
   if( rst )
       Row_Cnt <=  {15{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                 Row_Cnt <=  {15{1'b0}};
          Judge_Row_State:           
                 Row_Cnt <=  Row_Cnt+1;
          default:
                 Row_Cnt <=  Row_Cnt;            
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Col_Cnt <=  {15{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                 Col_Cnt <=  {15{1'b0}};
          Judge_Col_State:       
              if (Col_Complete == 1'b1)
                  Col_Cnt <= {15{1'b0}};
              else    
                  Col_Cnt <=  Col_Cnt+1;
          default:
                 Col_Cnt <=  Col_Cnt;            
       endcase
   end
end

wire En_Write;
reg En_Write_1 [8:0];
reg En_Write_2 [8:0];

always@(posedge clk)begin
    En_Write_1[0] <= rd_en_fifo_1;
    En_Write_2[0] <= rd_en_fifo_2;
end

generate
genvar m;
	for (m = 0;m < 8;m = m + 1 ) begin
		always @ (posedge clk) begin 
			En_Write_1[m+1] <= En_Write_1[m];
			En_Write_2[m+1] <= En_Write_2[m];
		end
	end
endgenerate

assign En_Write = En_Write_1[8] || En_Write_2[8];

//assign M_Fifo_Data = (sign_delaydelay[7]==1'b1)?Ram_Data_Final:S_Data_Final;

always@(posedge clk)begin
    if(rst)
        M_Fifo_Data <= {`AXI_WIDTH_DATA_IN{1'b0}};
    else
        if(En_Write_1[7])
            M_Fifo_Data <= Ram_Data_Final;
        else if(En_Write_2[7])
            M_Fifo_Data <= S_Data_Final;
        else
            M_Fifo_Data <= {`AXI_WIDTH_DATA_IN{1'b0}};   
end



mult_concat mult_concat_1 (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [10 : 0] A
  .B(Ram_Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo_1)      // output wire [11 : 0] P
);

mult_concat mult_concat_2 (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [10 : 0] A
  .B(Direct_Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo_2)      // output wire [11 : 0] P
);

always@(posedge clk)begin
    S_Count_Fifo_3 <= S_Count_Fifo_1 + S_Count_Fifo_2;
end

reg     [RE_WIDTH_CHANNEL_NUM_REG-1:0]      data_count2;   // [9:0]
always @ (posedge clk) begin 
    data_count2 <= Ram_Channel_Times + Direct_Channel_Times;
end

FIFO_Concat  #(
        .WIDTH(`WIDTH_DATA*`PICTURE_NUM*RE_CHANNEL_IN_NUM),
        .ADDR_BITS(RE_WIDTH_FEATURE_SIZE)
)
FIFO_concat
(
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(M_Fifo_Data),
     .wr_en(En_Write),
     .rd_en(M_Ready&M_Valid),
     .dout(M_Data),
     .M_count(S_Count_Fifo_3), 
     .M_Ready(),
     .S_count(50), 
     .S_Ready(Fifo_S_Ready),
     .empty(empty)
);
assign M_Valid = !empty;

               /////////////////////////////////////////
reg		 [RE_WIDTH_FEATURE_SIZE-1:0]	          M_Cnt_Row;
reg		 [RE_WIDTH_FEATURE_SIZE-1:0]	          M_Cnt_Column;
reg      [RE_WIDTH_CHANNEL_NUM_REG-1:0]	          M_Cnt_Cout;

wire                                       M_En_Last_Cout;   
wire                                       M_En_Last_Col;   
wire                                       M_En_Last_Row;   


assign  M_En_Last_Cout = (M_Cnt_Cout + 1'b1 == data_count2)?1'b1:1'b0;
assign  M_En_Last_Col = (M_Cnt_Column + 1'b1 == Row_Num_Out_REG)?1'b1:1'b0;
assign  M_En_Last_Row = (M_Cnt_Row + 1'b1 == Row_Num_In_REG)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst||Next_Reg)
        M_Cnt_Cout <= {RE_WIDTH_CHANNEL_NUM_REG{1'b0}};
    else if (M_Ready&M_Valid) begin
        if (M_En_Last_Cout)
            M_Cnt_Cout <= {RE_WIDTH_CHANNEL_NUM_REG{1'b0}};
        else
            M_Cnt_Cout <= M_Cnt_Cout + 1'b1;
    end
    else
        M_Cnt_Cout <= M_Cnt_Cout;
end

always @ (posedge clk) begin 
    if (rst||Next_Reg)
        M_Cnt_Column <= {RE_WIDTH_FEATURE_SIZE{1'b0}};
    else if (M_En_Last_Cout&M_Ready&M_Valid) begin
        if (M_En_Last_Col)
            M_Cnt_Column <= {RE_WIDTH_FEATURE_SIZE{1'b0}};
        else
            M_Cnt_Column <= M_Cnt_Column + 1'b1;
    end
    else
        M_Cnt_Column <= M_Cnt_Column;
end


always @ (posedge clk) begin 
    if (rst||Next_Reg)
        M_Cnt_Row <= {RE_WIDTH_FEATURE_SIZE{1'b0}};
    else if (M_Ready&M_Valid) begin
        if (M_En_Last_Col&&M_En_Last_Cout)
            M_Cnt_Row <= M_Cnt_Row + 1'b1;
        else
            M_Cnt_Row <= M_Cnt_Row;
    end
    else
        M_Cnt_Row <= M_Cnt_Row;            
end

assign  Last_Concat = (M_En_Last_Cout&&M_En_Last_Col&&M_En_Last_Row)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
       Connect_Complete <= 1'b0;
    else if (Last_Concat) 
       Connect_Complete <= 1'b1;
    else
       Connect_Complete <= 1'b0;
end
   

endmodule