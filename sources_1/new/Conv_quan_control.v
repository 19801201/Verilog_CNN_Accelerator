`timescale 1ns / 1ps


module Conv_quan_control#(parameter
    CHANNEL_OUT_NUM           =  8,
    WIDTH_FEATURE_SIZE        =  12,
    WIDTH_CHANNEL_NUM_REG     =  10,
    WIDTH_DATA_ADD            =  32,
    WIDTH_BIAS_RAM_ADDRA      =   9
)(  
    input  clk,
    input  rst,
    input  Start,
    output[WIDTH_BIAS_RAM_ADDRA-1:0] bias_addrb,
    output  reg     EN_Rd_Fifo,
    input           Fifo_Ready,
    input           M_Ready,
    output          M_Valid,
    
    input  [WIDTH_FEATURE_SIZE-1:0] Row_Num_Out_REG,
    input  [WIDTH_CHANNEL_NUM_REG-1:0]  Channel_Out_Num_REG,  
    output [WIDTH_FEATURE_SIZE-1:0]  S_Count_Fifo
    );
localparam Idle_State              =   6'b00_0000;//0
localparam Wait_State              =   6'b00_0001;
localparam Judge_Before_FIFO_State =   6'b00_0010;//1
localparam Judge_After_FIFO_State  =   6'b00_0100;//2
localparam Compute_State           =   6'b00_1000;//4
localparam Judge_State             =   6'b01_0000;//4
reg   [5:0]  Current_State;
reg   [5:0]  Next_State;


/////////////////
reg [4:0]  wait_cnt;
wire       wait_en;
/////////////////

reg   [WIDTH_FEATURE_SIZE-1'b1 :0]Cnt_Row;
reg   [WIDTH_FEATURE_SIZE-1'b1 :0]Cnt_Column;
reg   [WIDTH_CHANNEL_NUM_REG -1'b1 :0]Cnt_Cout;
wire  EN_Row;
wire  EN_Last_Cout;
wire  fifo_rd_en_temp;
//===========================
//assign bias_addrb = Cnt_Cout[6:0];
assign bias_addrb = Cnt_Cout[WIDTH_BIAS_RAM_ADDRA-1:0];
assign fifo_rd_en_temp = (Current_State == Compute_State)?1'b1:1'b0;
assign M_Valid    = (Current_State == Compute_State)?1'b1:1'b0;
//===========================
//assign EN_Last_Cout = (Cnt_Cout+1'b1==Channel_Out_Num_REG/CHANNEL_OUT_NUM)?1'b1:1'b0;
assign EN_Last_Cout = (Cnt_Cout+1'b1==Channel_Out_Num_REG>>3)?1'b1:1'b0;
assign EN_Column  = (Cnt_Column+1'b1 == Row_Num_Out_REG &&EN_Last_Cout == 1'b1)?1'b1:1'b0;
assign EN_Row  =   (Cnt_Row+1'b1 == Row_Num_Out_REG)?1'b1:1'b0;
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
            if (Start)
                Next_State = Wait_State;
            else 
                Next_State = Idle_State;
        Wait_State:
            if (wait_en)
                Next_State = Judge_Before_FIFO_State;
            else
                Next_State = Wait_State;                    
       Judge_Before_FIFO_State:
            if(Fifo_Ready == 1'b1)begin
                Next_State = Judge_After_FIFO_State;
            end
            else begin
                Next_State = Judge_Before_FIFO_State;
            end 
        Judge_After_FIFO_State://1
            if(M_Ready==1'b1)begin 
                Next_State = Compute_State;
            end 
            else begin 
                Next_State = Judge_After_FIFO_State;
            end 
        
        Compute_State://2
            if(EN_Column == 1'b1)begin
                Next_State = Judge_State;
            end
            else begin
                Next_State = Compute_State;
            end
       Judge_State://2
            if(EN_Row == 1'b1)begin
                Next_State = Idle_State;
            end
            else begin
                Next_State = Judge_Before_FIFO_State;
            end
       default:
            Next_State = Idle_State;
    endcase  
end 

//////////////////
wire [WIDTH_CHANNEL_NUM_REG-1'b1:0] Channel_Times;
//assign Channel_Times = Channel_Out_Num_REG/CHANNEL_OUT_NUM;
assign Channel_Times = Channel_Out_Num_REG>>3;

always @ (posedge clk) begin 
    if (rst)
        wait_cnt <= 5'd0;
    else if (Current_State == Wait_State) begin
        if (wait_cnt > 5'd5)
            wait_cnt <= wait_cnt;
        else
            wait_cnt <= wait_cnt + 1'b1;
    end else if(Current_State == Judge_State && Next_State==Idle_State) begin
        wait_cnt<=5'd0;
    end else begin
        wait_cnt <= wait_cnt; 
    end
end

assign wait_en = (wait_cnt + 1'b1 == 5'd5)?1'b1:1'b0;

count_mult count_bias (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [11 : 0] A
  .B(Channel_Times),      // input wire [9 : 0] B
  .P(S_Count_Fifo)      // output wire [11 : 0] P
);
///////////////////////

always@(posedge clk)begin
    case(Current_State)
        Idle_State:
            Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
        Compute_State:
            if(EN_Last_Cout == 1'b1)begin
                Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
            end
            else begin
                 Cnt_Cout <= Cnt_Cout+1'b1;
            end
        default:
            Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
    endcase
end
always@(posedge clk)begin
    case(Current_State)
        Idle_State:
            Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
        Compute_State:
            if(EN_Last_Cout == 1'b1)begin
                Cnt_Column <= Cnt_Column+1'b1;
            end
            else begin
                 Cnt_Column <= Cnt_Column;
            end
        default:
            Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
    endcase
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
      case(Current_State)
        Judge_State:
            Cnt_Row <= Cnt_Row + 1'b1;
        Idle_State:
            Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
        default:   Cnt_Row <= Cnt_Row;
      endcase
    end
end

always @ (posedge clk) begin
    EN_Rd_Fifo  <= fifo_rd_en_temp;   
end 
    
endmodule
