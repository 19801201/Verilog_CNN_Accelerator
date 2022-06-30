`timescale 1ns / 1ps

  
`include"../Para.v"
module four2three#(parameter
    CHANNEL_IN_NUM            =  16,
    WIDTH_RAM_SIZE            =  10,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM         =  10 
)(   
    input clk,
    input rst,
    input Next_Reg,
    input Start,
    output reg Start_Row,
    input  [WIDTH_FEATURE_SIZE-1 :0] Row_Num_After_Padding,
    input  [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0] S_Data,
    input  S_Valid,
    output S_Ready,
    input  [WIDTH_CHANNEL_NUM-1'b1   :0]Channel_In_Num_REG,
    input  M_Ready,
    output reg [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM*3-1:0] M_Data,
    input  [WIDTH_RAM_SIZE-1'b1:0] M_Addr
    );
  
localparam      Idle_State           = 6'b00_0000;
localparam      Wait_State           = 6'b00_0001;
localparam      Judge_Fifo_State     = 6'b01_0000;
localparam      Read_State           = 6'b00_0010;
localparam      Judge_Compute_State  = 6'b00_0100;
localparam      Start_Compute_State  = 6'b00_1000;
localparam      Wait_End_State       = 6'b10_0000;

reg  [5:0] Current_State;
reg  [5:0] Next_State;

/////////////////
reg [4:0]  wait_cnt;
wire       wait_en;
/////////////////

reg  [3:0] Ena_Ram;
(* keep="true" *) reg  [WIDTH_RAM_SIZE -1'b1:0]   addra_ram[0:3];
//reg  [WIDTH_RAM_SIZE -1'b1:0]   addra_ram;
reg  [WIDTH_FEATURE_SIZE-1:0]   Cnt_Row;
reg  [WIDTH_FEATURE_SIZE-1:0]   Cnt_Column;
reg  [WIDTH_CHANNEL_NUM-1'b1:0] Cnt_Cin;
reg  [2:0] Cnt_Start_Row ;
wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0 ]Out_Data_Ram[3:0];
wire [`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM-1:0 ]Out_Data_fifo;
wire EN_Write;        
wire EN_Read_State;
wire EN_Start_Row;
wire EN_Middle;
wire EN_Fifo_Row;
wire EN_Last_Cin;

reg [3:0] Four_To_Three;
reg EN_First;
wire [WIDTH_CHANNEL_NUM-1'b1:0] Channel_Times;
assign Channel_Times = Channel_In_Num_REG >> 4;
//8---27
wire   [WIDTH_FEATURE_SIZE-1'b1:0]      S_Count_Fifo  ;

assign EN_Write     =(Current_State==Read_State)?1'b1:1'b0;
assign EN_Read_State=(Cnt_Column+1'b1==Row_Num_After_Padding)?1'b1:1'b0;
assign EN_Start_Row =(Cnt_Start_Row < 2'b10)?1'b1:1'b0;
assign EN_Middle    =(Cnt_Row+2'b11<Row_Num_After_Padding)?1'b1:1'b0;
assign EN_Last_Cin  =(Cnt_Cin==Channel_Times-1'b1)?1'b1:1'b0;
//===============fifo===================
Four2three_FIFO  #(
        .WIDTH(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
Four2three_FIFO
(
     .clk(clk),
     .rst(rst),
     .Next_Reg(Next_Reg),
     .din(S_Data),
     .wr_en(S_Valid),
     .rd_en(EN_Write),
     .dout(Out_Data_fifo),
     .M_count(S_Count_Fifo),  //back
     .M_Ready(EN_Fifo_Row),
     .S_count(S_Count_Fifo),   //front
     .S_Ready(S_Ready)
);     

generate
genvar i;
for(i = 0; i < 4; i = i + 1)begin
    Configurable_RAM  #(
     .WIDTH(`WIDTH_DATA*`PICTURE_NUM*CHANNEL_IN_NUM),
     .ADDR_BITS(WIDTH_RAM_SIZE)
)
Feature_Write_Ram(
    .clk(clk),
    .read_address(M_Addr),
    .write_address(addra_ram[i]),
    .input_data(Out_Data_fifo),
    .write_enable(EN_Write&Ena_Ram[i]),
    .output_data(Out_Data_Ram[i])
    );
end
endgenerate

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
       Idle_State: if( Start==1'b1)begin
                        Next_State  =   Wait_State;
                        end
                   else 
                       Next_State   =   Idle_State;  
       Wait_State:
           if (wait_en)
               Next_State = Judge_Fifo_State;
           else
               Next_State = Wait_State;                     
       Judge_Fifo_State:if(EN_Fifo_Row==1'b1)
                             Next_State  = Read_State;
                         else 
                              Next_State  =   Judge_Fifo_State;                                               
       Read_State: if( EN_Read_State==1'b1 &&EN_Last_Cin) begin
                        Next_State  = Judge_Compute_State;
                        end 
                   else 
                        Next_State  = Read_State;
       Judge_Compute_State:begin
                    if(M_Ready==1'b0) begin
                        if(EN_Start_Row==1'b1)
                             Next_State  = Judge_Fifo_State;                           
                        else                
                             Next_State  = Start_Compute_State;   
                        end                      
                   else 
                        Next_State  = Judge_Compute_State;
                end
       Start_Compute_State:  begin   
                     if  (EN_Middle==1'b1)                               
                        Next_State  =  Judge_Fifo_State; 
                     else    
                        Next_State  =   Wait_End_State;                                                   
                        end
       Wait_End_State:begin 
                   if(M_Ready==1'b0)
                     Next_State  =   Idle_State;  
                   else
                     Next_State  =   Wait_End_State; 
       end
       default:  Next_State  =    Idle_State;
    endcase    
end 
//////////////////
always @ (posedge clk) begin 
    if (rst)
        wait_cnt <= 5'd0;
    else if (Current_State == Wait_State) begin
        if (wait_cnt > 5'd5)
            wait_cnt <= wait_cnt;
        else
            wait_cnt <= wait_cnt + 1'b1;
    end else if(Current_State == Wait_End_State && Next_State==Idle_State) begin
        wait_cnt<=5'd0;
    end else begin
        wait_cnt <= wait_cnt; 
    end
end

assign wait_en = (wait_cnt + 1'b1 == 5'd5)?1'b1:1'b0;

count_mult count_mult43 (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_After_Padding),      // input wire [11 : 0] A
  .B(Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo)      // output wire [11 : 0] P
);

always@( posedge clk  )begin    
   if(rst)
       Cnt_Cin <=  {WIDTH_CHANNEL_NUM{1'b0}};
   else begin
       case(Current_State)
           Read_State: 
                if(EN_Last_Cin)begin
                    Cnt_Cin <={WIDTH_CHANNEL_NUM*{1'b0}};
                end
                else begin
                    Cnt_Cin <= Cnt_Cin+1'b1;
                end
           default:   Cnt_Cin <=  {WIDTH_CHANNEL_NUM{1'b0}};                         
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Column <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
       case(Current_State)
           Read_State:  
                if(EN_Last_Cin==1'b1)begin
                     Cnt_Column <=  Cnt_Column +   1'b1;
                end
                else begin
                    Cnt_Column <= Cnt_Column;
                end
           default:   Cnt_Column <=  {WIDTH_FEATURE_SIZE{1'b0}};                         
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
       case(Current_State)
           Start_Compute_State:   Cnt_Row <= Cnt_Row + 1'b1;
           Idle_State: Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
           default:   Cnt_Row <= Cnt_Row ;
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Start_Row <=  3'b000;
   else begin
       case(Current_State)
             Idle_State: Cnt_Start_Row<= 3'b000;//0 1 2 
             Judge_Compute_State:if(Next_State==Judge_Fifo_State)
                            Cnt_Start_Row=Cnt_Start_Row+1;
                         else
                            Cnt_Start_Row<=Cnt_Start_Row;
             default:     Cnt_Start_Row <= Cnt_Start_Row;
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )begin
       addra_ram[0]   <=   {WIDTH_RAM_SIZE{1'b0}};
       addra_ram[1]   <=   {WIDTH_RAM_SIZE{1'b0}};
       addra_ram[2]   <=   {WIDTH_RAM_SIZE{1'b0}};
       addra_ram[3]   <=   {WIDTH_RAM_SIZE{1'b0}};
   end
   else begin
       case(Current_State)
           Read_State: begin
                addra_ram[0] <=  addra_ram[0] +   1'b1;
                addra_ram[1] <=  addra_ram[1] +   1'b1;
                addra_ram[2] <=  addra_ram[2] +   1'b1;
                addra_ram[3] <=  addra_ram[3] +   1'b1;
           end
           default: begin
                addra_ram[0] <=  {WIDTH_RAM_SIZE{1'b0}};
                addra_ram[1] <=  {WIDTH_RAM_SIZE{1'b0}};
                addra_ram[2] <=  {WIDTH_RAM_SIZE{1'b0}};
                addra_ram[3] <=  {WIDTH_RAM_SIZE{1'b0}};
           end
       endcase
   end
end

//always@( posedge clk  )begin    
//   if( rst )
//       addra_ram   <=   {WIDTH_RAM_SIZE{1'b0}};
//   else begin
//       case(Current_State)
//           Read_State: addra_ram <=  addra_ram +   1'b1;
//           default: addra_ram <=  {WIDTH_RAM_SIZE{1'b0}};
//       endcase
//   end
//end

always@(posedge clk)begin    
   if( rst )
      Start_Row=1'b0;
   else if (Next_State==Start_Compute_State) begin
                Start_Row=1'b1;
    end
    else   Start_Row=1'b0;
 end


always@( posedge clk  )begin    
   if(rst)
      Ena_Ram<=4'b0001;
   else begin
       if(Current_State==Read_State&Next_State==Judge_Compute_State)
            Ena_Ram<={Ena_Ram[2:0],Ena_Ram[3]};
       else if(Next_State==Idle_State)
              Ena_Ram<=4'b0001;
       else 
             Ena_Ram<= Ena_Ram;
    end
end

always@(posedge clk)begin
 if( rst )
       M_Data <= {Out_Data_Ram[0],Out_Data_Ram[1],Out_Data_Ram[2]};
 else begin
    case(Four_To_Three)
        4'b0001: 
             M_Data <= {Out_Data_Ram[2],Out_Data_Ram[1],Out_Data_Ram[0]};
        4'b0010: 
             M_Data <= {Out_Data_Ram[3],Out_Data_Ram[2],Out_Data_Ram[1]};
        4'b0100:
             M_Data <= {Out_Data_Ram[0],Out_Data_Ram[3],Out_Data_Ram[2]};
        4'b1000: 
             M_Data <= {Out_Data_Ram[1],Out_Data_Ram[0],Out_Data_Ram[3]}; 
        default:   M_Data <= M_Data;
        endcase
  end
end

always@( posedge clk  )begin    
   if( rst )
      EN_First<= 1'b0;
   else if(EN_First==1'b0&Current_State==Start_Compute_State)
        EN_First<= 1'b1;
   else if(Current_State==Idle_State) 
        EN_First<= 1'b0;
   else  EN_First<= EN_First;
end

always@(posedge clk)begin    
if( rst )
      Four_To_Three<=4'b0001;//4'b0001
else begin
      if(Current_State==Idle_State)
            Four_To_Three<=4'b0001;
      else  if(EN_First==1'b1)begin
                if(Current_State==Start_Compute_State) begin
                     Four_To_Three<={Four_To_Three[2:0],Four_To_Three[3]};
                end
            else
              Four_To_Three<=Four_To_Three;
            end
        else  
          Four_To_Three<=4'b0001;
         end
   end
   
endmodule
