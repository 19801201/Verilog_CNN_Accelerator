`timescale 1ns / 1ps

module compute_control #(parameter
WIDTH_RAM_ADDR_SIZE          =       13,
WIDTH_FEATURE_SIZE           =       12,
WIDTH_TEMP_RAM_ADDR_SIZE     =       7,
WIDTH_CHANNEL_NUM_REG        =       10,
//DELAY_TIMES                  =       21
DELAY_TIMES                  =       23    //*********************
)(
    input   clk,
    input   rst,
    input   Start_Cu,
//    output  reg Load_Start,
//    input   Load_Weight_Complete,
    output  reg  Compute_Complete,
    output  First_Compute_Complete,


    input   compute_fifo_ready,
    output  reg rd_en_fifo,    
    
    input   M_ready,      
    output  M_Valid,
    output  [WIDTH_RAM_ADDR_SIZE-1:0]  weight_addrb,    
    
    output  [WIDTH_TEMP_RAM_ADDR_SIZE-1:0]         ram_temp_read_address,
    output  reg  [WIDTH_TEMP_RAM_ADDR_SIZE-1:0]    ram_temp_write_address,
    input  [WIDTH_FEATURE_SIZE-1:0]    COMPUTE_TIMES_CHANNEL_IN_REG ,
//    input  [WIDTH_FEATURE_SIZE-1:0]    COMPUTE_TIMES_CHANNEL_IN_REG_8,
    input  [WIDTH_FEATURE_SIZE-1:0]    COMPUTE_TIMES_CHANNEL_OUT_REG,
    input  [WIDTH_FEATURE_SIZE-1:0]    ROW_NUM_CHANNEL_OUT_REG,
    output [WIDTH_FEATURE_SIZE-1:0]    S_Count_Fifo,
    output [WIDTH_FEATURE_SIZE-1:0]    M_Count_Fifo
    );

localparam      Idle_State                     = 6'b00_0000;
localparam      Wait_State                     = 6'b00_0001;
localparam      Judge_Before_Fifo_State        = 6'b00_0010;
localparam      Judge_After_Fifo_State         = 6'b00_0100;
localparam      Compute_State                  = 6'b00_1000;
localparam      Judge_Row_State                = 6'b01_0000;

/////////////////
reg [4:0]  wait_cnt;
wire       wait_en;
/////////////////

reg  [5:0] Current_State;
reg  [5:0] Next_State;
wire En_Compute_Column;
wire En_Compute_Row;
reg  [WIDTH_FEATURE_SIZE-1:0]          Cnt_Column ;
reg  [WIDTH_FEATURE_SIZE-1:0]          Cnt_Row ;
reg  [WIDTH_CHANNEL_NUM_REG-1:0]       Cnt_Channel_Out_Num;
reg  [WIDTH_CHANNEL_NUM_REG-1:0]       Cnt_Channel_In_Num;


assign En_Compute_Column=(Cnt_Column+1'b1==ROW_NUM_CHANNEL_OUT_REG
                &&Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG
                    &&Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG)?1'b1:1'b0;
assign En_Compute_Row=(Cnt_Row+1'b1==ROW_NUM_CHANNEL_OUT_REG)?1'b1:1'b0;

 always@( posedge clk  )begin  //   
    if( rst )begin
        Current_State <= Idle_State;
    end
    else begin
        Current_State <= Next_State;
    end
 end
 always @ (*)        begin
    Next_State = Idle_State;    
    case(Current_State)    
       Idle_State:
            if( Start_Cu==1'b1)
                Next_State   =   Wait_State;
            else 
                Next_State   =   Idle_State;
       Wait_State:
           if (wait_en)
               Next_State = Judge_Before_Fifo_State;
           else
               Next_State = Wait_State;                     
       Judge_Before_Fifo_State:
            if(compute_fifo_ready==1'b1)
                Next_State   =   Judge_After_Fifo_State;
            else 
                Next_State   =   Judge_Before_Fifo_State; 
       Judge_After_Fifo_State:
            if(M_ready==1'b1)
                Next_State  =  Compute_State;
            else
                Next_State  =  Judge_After_Fifo_State;                                                        
       Compute_State: 
            if( En_Compute_Column==1'b1 )
                Next_State  = Judge_Row_State;   
            else 
                Next_State  = Compute_State;
       Judge_Row_State: 
            if( En_Compute_Row==1'b1 )
               Next_State  = Idle_State;
            else 
               Next_State  = Judge_Before_Fifo_State;
       default:Next_State  =    Idle_State;
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
    end else if(Current_State == Judge_Row_State && Next_State==Idle_State) begin
        wait_cnt<=5'd0;
    end else begin
        wait_cnt <= wait_cnt; 
    end
end

assign wait_en = (wait_cnt + 1'b1 == 5'd5)?1'b1:1'b0;


count_conv2d  count_9fifo (
  .CLK(clk),  // input wire CLK
  .A(ROW_NUM_CHANNEL_OUT_REG),      // input wire [11 : 0] A
  .B(COMPUTE_TIMES_CHANNEL_IN_REG),      // input wire [11 : 0] B
  .P(M_Count_Fifo)      // output wire [11 : 0] P
);
assign S_Count_Fifo = M_Count_Fifo;

always@( posedge clk  )begin    
   if( rst )
       Cnt_Channel_In_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
   else begin
       case(Current_State)
          Idle_State:     
            Cnt_Channel_In_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
          Compute_State:
            if(Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG)
               Cnt_Channel_In_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
            else
               Cnt_Channel_In_Num <=  Cnt_Channel_In_Num+1;
          default:
             Cnt_Channel_In_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Channel_Out_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
   else begin
       case(Current_State)
          Idle_State:     
            Cnt_Channel_Out_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
          Compute_State:  
            if(Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG)begin
              if(Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG)
                  Cnt_Channel_Out_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
              else                                                  
                  Cnt_Channel_Out_Num <=  Cnt_Channel_Out_Num+1;
               end
            else
               Cnt_Channel_Out_Num <=  Cnt_Channel_Out_Num;
          default:
             Cnt_Channel_Out_Num <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Column <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
       case(Current_State)
          Idle_State:     Cnt_Column <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
          Compute_State:
             if(Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG&&Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG)
                Cnt_Column <=  Cnt_Column+1;
             else
                Cnt_Column <=  Cnt_Column;
          default:
                Cnt_Column <=  {WIDTH_CHANNEL_NUM_REG{1'b0}};
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
      case(Current_State)
        Judge_Row_State:Cnt_Row <= Cnt_Row + 1'b1;
        Idle_State:Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
        default:   Cnt_Row <= Cnt_Row;
      endcase
    end
end


always@( posedge clk  )begin    
   if( rst )
       Compute_Complete <=  1'b0;
   else begin
      case(Current_State)
        Idle_State:Compute_Complete <=  1'b0;
        Judge_Row_State:
            if(Next_State==Idle_State)
                 Compute_Complete <=  1'b1;
            else
                 Compute_Complete <=  1'b0;
        default:Compute_Complete <=  1'b0;
      endcase
    end
end

always@(posedge clk)begin
    if(rst)
      rd_en_fifo<=  1'b0;
    else begin
      case(Current_State)
        Compute_State:      
          if(Cnt_Channel_Out_Num=={WIDTH_CHANNEL_NUM_REG{1'b0}})  
              rd_en_fifo <=  1'b1;
          else 
              rd_en_fifo  <=  1'b0;
        default:rd_en_fifo   <=  1'b0;
        endcase          
    end
end

always@(posedge clk)begin
    if(rst)
        ram_temp_write_address  <=  {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
    else begin
          if(Cnt_Channel_Out_Num=={WIDTH_CHANNEL_NUM_REG{1'b0}}&&Cnt_Channel_In_Num=={WIDTH_CHANNEL_NUM_REG{1'b0}})  
              ram_temp_write_address <=  {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
          else if(rd_en_fifo==1'b1)  
              ram_temp_write_address <=  ram_temp_write_address+1'b1;
          else 
              ram_temp_write_address <=  {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
        end   
end


reg [WIDTH_TEMP_RAM_ADDR_SIZE-1:0]  ram_temp_read_address_temp [0:2];
always@( posedge clk  )begin    
   if( rst )
       ram_temp_read_address_temp[0] <= {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
   else begin
      case(Current_State)
        Idle_State:  ram_temp_read_address_temp[0] <= {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
        Compute_State:      
          if(Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG) 
             ram_temp_read_address_temp[0]<= {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
          else     
             ram_temp_read_address_temp[0] <= ram_temp_read_address_temp[0]+1;
        default:     ram_temp_read_address_temp[0]<= {WIDTH_TEMP_RAM_ADDR_SIZE{1'b0}};
      endcase
    end
end
always@(posedge clk)begin
        ram_temp_read_address_temp[1]<=ram_temp_read_address_temp[0];
        ram_temp_read_address_temp[2]<=ram_temp_read_address_temp[1];
    end 
assign  ram_temp_read_address = ram_temp_read_address_temp[2];

reg [WIDTH_RAM_ADDR_SIZE-1:0]  weight_addrb_temp [0:2];
always@( posedge clk  )begin    
   if( rst )
       weight_addrb_temp[0] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
   else begin
      case(Current_State)
        Idle_State:  weight_addrb_temp[0] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
        Compute_State:      
          if(Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG&&
                    Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG) 
             weight_addrb_temp[0] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
          else     
             weight_addrb_temp[0] <= weight_addrb_temp[0]+1;
        default:     weight_addrb_temp[0] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
      endcase
    end
end
always@(posedge clk)begin
        weight_addrb_temp[1]<=weight_addrb_temp[0];
        weight_addrb_temp[2]<=weight_addrb_temp[1];
    end 
assign  weight_addrb = weight_addrb_temp[2];

reg M_Fifo_Valid[0:26];
always@( posedge clk  )begin    
   if( rst )
      M_Fifo_Valid[0] <=  1'b0;
   else begin
    case(Current_State)
       Compute_State:begin
           if(Cnt_Channel_In_Num+1'b1==COMPUTE_TIMES_CHANNEL_IN_REG)
                  M_Fifo_Valid[0]<=  1'b1;
           else  
                  M_Fifo_Valid[0] <=  1'b0;
           end
      default:    M_Fifo_Valid[0] <=  1'b0;
      endcase
end
end

reg  First_Complete [0:25];
always@( posedge clk  )begin    
   if( rst )
      First_Complete[0] <=  1'b0;
   else begin
    case(Current_State)
       Compute_State:begin
           if(Cnt_Channel_In_Num=={WIDTH_CHANNEL_NUM_REG{1'b0}})
                  First_Complete[0]<=  1'b1;
           else  
                  First_Complete[0] <=  1'b0;
           end
      default:  First_Complete[0] <=  1'b0;
      endcase
end
end

generate
genvar i;
for(i=0;i<26;i=i+1)begin
    always@(posedge clk)begin
        M_Fifo_Valid[i+1]<=M_Fifo_Valid[i];
    end   
  end
endgenerate
assign M_Valid=M_Fifo_Valid[DELAY_TIMES+1];
generate
genvar g;
for(g=0;g<25;g=g+1)begin
    always@(posedge clk)begin
        First_Complete[g+1]<=First_Complete[g];
    end   
  end
endgenerate
assign First_Compute_Complete=First_Complete[DELAY_TIMES];

endmodule 
