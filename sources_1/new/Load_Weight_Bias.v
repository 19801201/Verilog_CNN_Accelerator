`timescale 1ns / 1ps

`include"./Para.v"
module Load_Weight_Bias#(parameter
WIDTH_WEIGHT_NUM        =   15,
WIDTH_RAM_ADDR_SIZE     =   13-1,
WIDTH_BIAS_RAM_ADDRA    =   8,
WIDTH_CHANNEL_NUM_REG   =   10,
KERNEL_NUM              =   9,
COMPUTE_CHANNEL_IN_NUM  =   16,
COMPUTE_CHANNEL_OUT_NUM =   8

    )
    (
    input   clk,
    input   rst,
    input   Start_Pa,

    input  [WIDTH_WEIGHT_NUM-1:0] Weight_Single_Num_REG,    //
    input  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Num_REG,     //
    output reg Write_Block_Complete,
    //Stream read
//    output reg [WIDTH_RAM_ADDR_TURE-1:0]    Bram_Addrb,
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Para_Data,
    input   S_Para_Valid,
    output  reg S_Para_Ready,
    input [WIDTH_CHANNEL_NUM_REG-1:0] Weight_Channel_In_REG,
    input [WIDTH_CHANNEL_NUM_REG-1:0] Weight_Channel_Out_REG,
    input CONV_11_Weight_REG,
    input CONV_11_Weight_Parallel,
//    input  [WIDTH_RAM_ADDR_TURE-1:0]     Ram_Read_Addrb_Base,
    
    
    input  [WIDTH_RAM_ADDR_SIZE-1:0]  Weight_Addrb,    
    output [9*1024-1:0]   Data_Out_Weight,

    input  [WIDTH_BIAS_RAM_ADDRA-1:0] Bias_Addrb,  
    output [32*8-1:0]Data_Out_Bias,  //bias
    output [32*8-1:0]Data_Out_Scale,  //scale
    output [32*8-1:0]Data_Out_Shift  //shift

    );

reg  [`AXI_WIDTH_DATA_IN-1:0]           S_Data_One;
//reg  [`AXI_WIDTH_DATA_IN-1:0]           S_Data_Two;
//reg  [`AXI_WIDTH_DATA_IN-1:0]           S_Data_Three;
reg  [`AXI_WIDTH_DATA_IN-1:0]           S_Data_Four;


reg [WIDTH_BIAS_RAM_ADDRA-1:0]      Cnt_Bias;
reg  [WIDTH_WEIGHT_NUM-1:0]    Cnt_Single_Weight;
reg  [3 :0]    Cnt_Ram_Weight_Num;

//-----------------FSM_PARAM-------------
reg  [5:0]      Current_State;
reg  [5:0]      Next_State;
localparam      Idle_State                     = 6'b00_0000;                
localparam      Copy_Weight_State              = 6'b00_0100;
localparam      Copy_Bias_State                = 6'b00_1000;
localparam      Copy_Scale_State               = 6'b01_0000;
localparam      Copy_Shift_State               = 6'b10_0000;

wire En_Weight,En_Weight_Temp,En_Bias;
reg  En_Single_Ram_Temp;
wire En_Single_Ram;
assign En_Weight_Temp=(Cnt_Single_Weight+1==Weight_Single_Num_REG&&Cnt_Ram_Weight_Num==4'b1000)?1'b1:1'b0;
assign En_Bias  =(Cnt_Bias+1==Bias_Num_REG)?1'b1:1'b0;
assign En_Single_Ram=(Cnt_Single_Weight+1==Weight_Single_Num_REG)?1'b1:1'b0;
always@(posedge clk)begin
    if(Cnt_Single_Weight+1==Weight_Single_Num_REG)
        En_Single_Ram_Temp<=1'b1;
    else
        En_Single_Ram_Temp<=1'b0;
end
// -----------------------------------FSM---------------------------------------
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
            if( Start_Pa==1'b1)
                Next_State   =   Copy_Weight_State;
            else 
                Next_State   =   Idle_State; 
       Copy_Weight_State:
            if(En_Weight==1'b1)
                Next_State   =   Copy_Bias_State;
            else 
                Next_State   =   Copy_Weight_State; 
       Copy_Bias_State:
            if(En_Bias==1'b1)
                Next_State  =  Copy_Scale_State;
            else
                Next_State  =  Copy_Bias_State; 
       Copy_Scale_State:
            if(En_Bias==1'b1)
                Next_State  =  Copy_Shift_State;
            else
                Next_State  =  Copy_Scale_State; 
       Copy_Shift_State:
            if(En_Bias==1'b1)
                Next_State  =  Idle_State;
            else
                Next_State  =  Copy_Shift_State;                                  
       default:Next_State  =    Idle_State;
    endcase    
end

/////////      Data  Trans      ////////
always @ (posedge clk) begin 
    S_Data_One <= S_Para_Data;
end

//always @ (posedge clk) begin 
//    S_Data_Two <= S_Para_Data;
//end

//always @ (posedge clk) begin 
//    S_Data_Three <= S_Para_Data;
//end

always @ (posedge clk) begin 
    S_Data_Four <= S_Para_Data;
end
//************************ conv3_3 ******************************

//-----------Single Weight cnt-------------
always@( posedge clk  )begin    
   if( rst )
       Cnt_Single_Weight <=  {WIDTH_WEIGHT_NUM{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
               Cnt_Single_Weight <=  {WIDTH_WEIGHT_NUM{1'b0}};
          Copy_Weight_State:
             if(En_Single_Ram)
                Cnt_Single_Weight <=  {WIDTH_WEIGHT_NUM{1'b0}};
             else if (S_Para_Valid)
                Cnt_Single_Weight <=  Cnt_Single_Weight+1;
             else
                Cnt_Single_Weight <= Cnt_Single_Weight;
          default:
                Cnt_Single_Weight <=  {WIDTH_WEIGHT_NUM{1'b0}};
       endcase
   end 
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Ram_Weight_Num <=  {4{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Cnt_Ram_Weight_Num <=  {4{1'b0}};
          Copy_Weight_State:
             if(En_Single_Ram)
                Cnt_Ram_Weight_Num <=  Cnt_Ram_Weight_Num+1;
             else
                Cnt_Ram_Weight_Num <=  Cnt_Ram_Weight_Num;
          default:
                Cnt_Ram_Weight_Num <=  {4{1'b0}};
       endcase
   end
end

always@( posedge clk  )begin    
   if( rst )
       Cnt_Bias <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Cnt_Bias <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
          Copy_Bias_State:begin
                if(En_Bias)
                    Cnt_Bias <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
                else if (S_Para_Valid)
                    Cnt_Bias <=  Cnt_Bias+1;
                else
                    Cnt_Bias <= Cnt_Bias;
                end
          Copy_Scale_State:begin
                if(En_Bias)
                    Cnt_Bias <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
                else if (S_Para_Valid)
                    Cnt_Bias <=  Cnt_Bias+1;
                else
                    Cnt_Bias <= Cnt_Bias;
                end
          Copy_Shift_State:begin
                if(En_Bias)
                    Cnt_Bias <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
                else if (S_Para_Valid)
                    Cnt_Bias <=  Cnt_Bias+1;
                else
                    Cnt_Bias <= Cnt_Bias;
                end
          default:
                    Cnt_Bias <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
       endcase
   end
end

always@(posedge clk)begin
    if(Current_State==Copy_Shift_State&&Next_State==Idle_State)
        Write_Block_Complete <= 1'b1;
    else
        Write_Block_Complete <= 1'b0;
end


always@( posedge clk  )begin    
   if( rst )
       S_Para_Ready <=  1'b0;
   else if (Current_State == Idle_State)begin
       case(Next_State)
          Idle_State:           
                S_Para_Ready <= 1'b0;
          Copy_Weight_State:
                S_Para_Ready <=  1'b1;
          Copy_Bias_State:
                S_Para_Ready <=  1'b1;
          Copy_Scale_State:
                S_Para_Ready <=  1'b1;
          Copy_Shift_State:
                S_Para_Ready <=  1'b1;
          default:
                S_Para_Ready <=  S_Para_Ready;
       endcase
   end
   else if (Current_State == Copy_Shift_State && Next_State == Idle_State )
       S_Para_Ready <= 1'b0;
   else
       S_Para_Ready <= S_Para_Ready;     
end

//---------------Weight_Ram_addra--------Part
reg [WIDTH_RAM_ADDR_SIZE-1:0]     Weight_Addra_Temp;
//reg [WIDTH_RAM_ADDR_SIZE-1:0]     Weight_Addra;
reg [WIDTH_RAM_ADDR_SIZE-1:0]     Weight_Addra [0:KERNEL_NUM-1];
wire    last_bit;
assign   last_bit=Cnt_Single_Weight[0];
//-----------------block_ram_test---------------
always@( posedge clk  )begin    
   if( rst )
       Weight_Addra_Temp <=  {WIDTH_RAM_ADDR_SIZE{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Weight_Addra_Temp <=  {WIDTH_RAM_ADDR_SIZE{1'b0}};
          Copy_Weight_State:
              if(En_Single_Ram)
                  Weight_Addra_Temp <=  {WIDTH_RAM_ADDR_SIZE{1'b0}};
              else if (S_Para_Valid)
                  Weight_Addra_Temp <=  Weight_Addra_Temp+1;
              else 
                  Weight_Addra_Temp <=  Weight_Addra_Temp;
          default:
                Weight_Addra_Temp <=  {WIDTH_RAM_ADDR_SIZE{1'b0}};
       endcase
   end
end

//always @(posedge clk ) begin
//    Weight_Addra<=  Weight_Addra_Temp;
//end

//---------------------EN_Weight--------------------
reg En_Wr_Weight,En_Wr_Bias,En_Wr_Scale,En_Wr_Shift;
always@(posedge clk)begin 
    if(Current_State==Copy_Weight_State)begin
        if (S_Para_Valid)
            En_Wr_Weight<=1'b1;
        else
            En_Wr_Weight <= 1'b0;
    end
    else 
        En_Wr_Weight<=1'b0;
 end

wire [8:0] En_Weight_Nine_Temp;
reg  [8:0] En_Weight_Nine_33;
wire [8:0] En_Weight_Nine;
always@( posedge clk  )begin    
   if( rst )
       En_Weight_Nine_33 <=  9'b0_0000_0001;
   else begin
       case(Current_State)
          Idle_State:           
               En_Weight_Nine_33 <=  9'b0_0000_0001;
          Copy_Weight_State:
              if(En_Single_Ram_Temp)
               En_Weight_Nine_33 <=  {En_Weight_Nine_33[7:0],En_Weight_Nine_33[8]};
               else
               En_Weight_Nine_33 <=  En_Weight_Nine_33;
          default:
               En_Weight_Nine_33 <=  9'b0_0000_0001;
       endcase
   end
end

//wire  write_address_help;
//assign write_address_help=~last_bit;
//--------------delay---weight---part---------------
//reg [8:0] En_Weight_Nine_Delay,En_Weight_Nine_Delay_Two;
//reg [WIDTH_RAM_ADDR_SIZE-1:0] Weight_Addra_Delay,Weight_Addra_Delay_Two;
//reg write_address_help_Delay;
//always@(posedge clk)
//En_Weight_Nine_Delay<= En_Weight_Nine;
//always@(posedge clk)
//En_Weight_Nine_Delay_Two<= En_Weight_Nine_Delay;

//always@(posedge clk)
//Weight_Addra_Delay<= Weight_Addra;

//always@(posedge clk)
//Weight_Addra_Delay_Two<= Weight_Addra_Delay;
//always@(posedge clk)
//write_address_help_Delay<= write_address_help;


//************************ conv1_1 ******************************  begin
wire [3:0] COMPUTE_CHANNEL_IN_NUM_11;
//localparam  COMPUTE_CHANNEL_IN_NUM_11 = 64 >> 4; 
assign  COMPUTE_CHANNEL_IN_NUM_11 = CONV_11_Weight_Parallel ? 64 >> 4 : 128 >> 4;

reg  [8:0] En_Weight_Nine_11;
reg [WIDTH_RAM_ADDR_SIZE-1:0] Weight_Addra_q [0:8-1];

reg  [3:0] Cnt_Cin_64;
reg  [3:0] Cnt_Cin;
reg  [WIDTH_CHANNEL_NUM_REG-1'b1:0] Cnt_Cout;
wire EN_Last_Cin_64;
wire EN_Last_Cin;
wire EN_Last_Cout;

wire [3:0] Channel_Times;
//assign Channel_Times = Weight_Channel_In_REG >> 6; 
assign Channel_Times = CONV_11_Weight_Parallel ? Weight_Channel_In_REG >> 6 : Weight_Channel_In_REG >> 7; 
assign EN_Last_Cin_64   = (Cnt_Cin_64 == COMPUTE_CHANNEL_IN_NUM_11 - 1'b1)?1'b1:1'b0;
assign EN_Last_Cin      = (Cnt_Cin == Channel_Times - 1'b1 && EN_Last_Cin_64)?1'b1:1'b0;
assign EN_Last_Cout     = (Cnt_Cout == Weight_Channel_Out_REG - 1'b1 && EN_Last_Cin)?1'b1:1'b0;

always @(posedge clk ) begin
    if(rst)begin
        Cnt_Cin_64 <= {4{1'b0}};
    end else begin
        case (Current_State)
            Idle_State: 
                Cnt_Cin_64 <= {4{1'b0}};
            Copy_Weight_State:begin
                if(S_Para_Valid)begin
                    if(EN_Last_Cin_64)begin
                        Cnt_Cin_64 <={4{1'b0}};
                    end
                    else begin
                        Cnt_Cin_64 <= Cnt_Cin_64+1'b1;
                    end
                end
                else begin
                    Cnt_Cin_64 <= Cnt_Cin_64; 
                end
            end
            default: Cnt_Cin_64 <= {4{1'b0}};
        endcase
    end
end

always @(posedge clk ) begin
    if(rst)begin
        Cnt_Cin <= {4{1'b0}};
    end else begin
        case (Current_State)
            Idle_State: 
                Cnt_Cin <= {4{1'b0}};
            Copy_Weight_State:begin
                if(EN_Last_Cin_64)begin
                    if(EN_Last_Cin)begin
                        Cnt_Cin <={4{1'b0}};
                    end
                    else begin
                        Cnt_Cin <= Cnt_Cin+1'b1;
                    end
                end
                else begin
                    Cnt_Cin <= Cnt_Cin; 
                end
            end
            default: Cnt_Cin <= {4{1'b0}};
        endcase
    end
end

always @(posedge clk ) begin
    if(rst)begin
        Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG*{1'b0}};
    end else begin
        case (Current_State)
            Idle_State: 
                Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG*{1'b0}};
            Copy_Weight_State:begin
                if(EN_Last_Cin)begin
                    if(EN_Last_Cout)begin
                        Cnt_Cout <={WIDTH_CHANNEL_NUM_REG*{1'b0}};
                    end
                    else begin
                        Cnt_Cout <= Cnt_Cout+1'b1;
                    end
                end
                else begin
                    Cnt_Cout <= Cnt_Cout; 
                end
            end
            default: Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG*{1'b0}};
        endcase
    end
end

always @(posedge clk) begin
    if (rst) begin
        En_Weight_Nine_11 <= 9'b0_0000_0001;
    end else begin
        case (Cnt_Cin_64)
            0:  En_Weight_Nine_11 <= 9'b0_0000_0001;
            1:  En_Weight_Nine_11 <= 9'b0_0000_0010;
            2:  En_Weight_Nine_11 <= 9'b0_0000_0100;
            3:  En_Weight_Nine_11 <= 9'b0_0000_1000;
            4:  En_Weight_Nine_11 <= 9'b0_0001_0000;
            5:  En_Weight_Nine_11 <= 9'b0_0010_0000;
            6:  En_Weight_Nine_11 <= 9'b0_0100_0000;
            7:  En_Weight_Nine_11 <= 9'b0_1000_0000;
            default: En_Weight_Nine_11 <= 9'b0_0000_0001;
    endcase
    end
end

generate 
  genvar j;
  for(j=0;j<8;j=j+1)begin   // 4  8
        always @(posedge clk ) begin
            if (rst) begin
                Weight_Addra_q[j] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
            end else begin
                case (Current_State)
                    Idle_State: 
                        Weight_Addra_q[j] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
                    Copy_Weight_State:
                        if (S_Para_Valid && Cnt_Cin_64 == j ) begin
                            Weight_Addra_q[j] <= Weight_Addra_q[j] + 1'b1;
                        end else begin
                            Weight_Addra_q[j] <= Weight_Addra_q[j];
                        end
                    default: Weight_Addra_q[j] <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
                endcase
            end
        end
end
endgenerate

//************************ conv1_1 ******************************  end
generate 
  genvar i;
  for(i=0;i<KERNEL_NUM;i=i+1)begin
        always @(posedge clk ) begin
            if(CONV_11_Weight_REG == 0)begin
                Weight_Addra[i]<=  Weight_Addra_Temp;
            end else begin
                Weight_Addra[i]<=  Weight_Addra_q[i];
            end
        end
end
endgenerate

assign En_Weight_Nine_Temp = (CONV_11_Weight_REG)? En_Weight_Nine_11 : En_Weight_Nine_33;
assign En_Weight_Nine=(En_Wr_Weight==1'b1)? En_Weight_Nine_Temp : 9'b0_0000_0000;
assign En_Weight = (CONV_11_Weight_REG)? EN_Last_Cout : En_Weight_Temp;

generate 
genvar k;
for(k=0;k<KERNEL_NUM;k=k+1)begin
    COMPUTE_3_3_WEIGHT_INS weight_ram (
      .clka(clk),    // input wire clka
      .ena(1),      // input wire ena
      .wea(En_Weight_Nine[k]),      // input wire [0 : 0] wea
      .addra(Weight_Addra[k]),  // input wire [12 : 0] addra
      .dina(S_Data_One),    // input wire [127 : 0] dina
      .clkb(clk),    // input wire clkb
      .enb(1),      // input wire enb
      .addrb(Weight_Addrb[WIDTH_RAM_ADDR_SIZE-2:0]),  // input wire [9 : 0] addrb
      .doutb(Data_Out_Weight[COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *(k+1)-1:
                       COMPUTE_CHANNEL_OUT_NUM * COMPUTE_CHANNEL_IN_NUM * `WIDTH_DATA *k ])  // output wire [511 : 0] doutb
    );
end
endgenerate


////-----------Weight_Ram--------------
// Compute_3_3_Weight#(
//.KERNEL_NUM(KERNEL_NUM),
//.COMPUTE_CHANNEL_IN_NUM(COMPUTE_CHANNEL_IN_NUM),
//.COMPUTE_CHANNEL_OUT_NUM(COMPUTE_CHANNEL_OUT_NUM),
//.WIDTH_RAM_ADDR_SIZE(WIDTH_RAM_ADDR_SIZE)
//)Compute_3_3_Weight
//(   
//        .clk(clk),
//        .weight_data_One(S_Data_One),
//        .weight_data_Two(S_Data_Two),
//        .weight_data_Three(S_Data_Three),
//        .weight_wr(En_Weight_Nine),
//        .weight_addra(Weight_Addra),
//        .write_address_help(write_address_help_Delay), 
//        .weight_addrb(Weight_Addrb),
//        .weight_ram_data_out(Data_Out_Weight)
//           );

always@(posedge clk)begin 
    if(Current_State==Copy_Bias_State)
        if (S_Para_Valid)
            En_Wr_Bias<= 1'b1;
        else
            En_Wr_Bias <= 1'b0;
    else 
        En_Wr_Bias<=1'b0;
 end
//----------Bias_Ram_addra
reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Bias_Addra_Temp;
reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Bias_Addra;
always@( posedge clk  )begin    
   if( rst )
       Bias_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Bias_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
          Copy_Bias_State:
              if (S_Para_Valid)
                  Bias_Addra_Temp <=  Bias_Addra_Temp+1;
              else
                  Bias_Addra_Temp <=  Bias_Addra_Temp;
          default:
                Bias_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
       endcase
   end
end      
//-------------bias----delay---part
always@(posedge clk)
    Bias_Addra<=  Bias_Addra_Temp;
//reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Bias_Addra_Delay,Bias_Addra_Delay_Two;
//reg En_Wr_Bias_Delay,En_Wr_Bias_Delay_Two;
//always@(posedge clk)
//Bias_Addra_Delay<=Bias_Addra;
//always@(posedge clk)
//Bias_Addra_Delay_Two<=Bias_Addra_Delay;
//always@(posedge clk)
//En_Wr_Bias_Delay<=En_Wr_Bias;
//always@(posedge clk)
//En_Wr_Bias_Delay_Two<=En_Wr_Bias_Delay;
//-------------bias----ram----part---------- 

 Bias_ram #(
 .ADDR_BITS(WIDTH_BIAS_RAM_ADDRA)
 ) Bias_ram(
    .clk(clk),
    .write_address(Bias_Addra),
    .input_data(S_Data_Four),
    .write_enable(En_Wr_Bias),
    .read_address(Bias_Addrb),
    .output_data(Data_Out_Bias)
    );
//--------------------sacle_part------------------
always@(posedge clk)begin 
    if(Current_State==Copy_Scale_State)
        if (S_Para_Valid)
            En_Wr_Scale<=1'b1;
        else
            En_Wr_Scale <= 1'b0;
    else 
        En_Wr_Scale<=1'b0;
 end
//----------sacle_Ram_addra
reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Scale_Addra_Temp;
reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Scale_Addra;
always@( posedge clk  )begin    
   if( rst )
       Scale_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Scale_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
          Copy_Scale_State:
              if (S_Para_Valid)
                  Scale_Addra_Temp <=  Scale_Addra_Temp+1;
              else
                  Scale_Addra_Temp <= Scale_Addra_Temp;   
          default:
                Scale_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
       endcase
   end
end       
always@(posedge clk)
    Scale_Addra<=  Scale_Addra_Temp;
//scale---ram---delay---part
//reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Scale_Addra_Delay,Scale_Addra_Delay_Two;
//reg En_Wr_Scale_Delay,En_Wr_Scale_Delay_Two;
//always@(posedge clk)
//Scale_Addra_Delay<=Scale_Addra;
//always@(posedge clk)
//Scale_Addra_Delay_Two<=Scale_Addra_Delay;
//always@(posedge clk)
//En_Wr_Scale_Delay<=En_Wr_Scale;
//always@(posedge clk)
//En_Wr_Scale_Delay_Two<=En_Wr_Scale_Delay;

 Bias_ram #(
   .ADDR_BITS(WIDTH_BIAS_RAM_ADDRA)
   ) Scale_ram(
    .clk(clk), 
    .write_address(Scale_Addra),       //
    .input_data(S_Data_Four),
    .write_enable(En_Wr_Scale),
    .read_address(Bias_Addrb),
    .output_data(Data_Out_Scale)
    );
//--------------------shift_part-----------------
always@(posedge clk)begin 
    if(Current_State==Copy_Shift_State)
        if (S_Para_Valid)
            En_Wr_Shift<=1'b1;
        else
            En_Wr_Shift <= 1'b0;
    else 
        En_Wr_Shift<=1'b0;
 end
//----------sacle_Ram_addra
reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Shift_Addra_Temp;
reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Shift_Addra;
always@( posedge clk  )begin    
   if( rst )
       Shift_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Shift_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
          Copy_Shift_State:
              if (S_Para_Valid)
                  Shift_Addra_Temp <=  Shift_Addra_Temp+1;
              else
                  Shift_Addra_Temp <= Shift_Addra_Temp;
          default:
                Shift_Addra_Temp <=  {WIDTH_BIAS_RAM_ADDRA{1'b0}};
       endcase
   end
end       
always@(posedge clk)
    Shift_Addra<=  Shift_Addra_Temp;

//scale---ram---delay---part
//reg [WIDTH_BIAS_RAM_ADDRA-1:0]     Shift_Addra_Delay,Shift_Addra_Delay_Two;
//reg En_Wr_Shift_Delay,En_Wr_Shift_Delay_Two;
//always@(posedge clk)
// Shift_Addra_Delay<= Shift_Addra;
// always@(posedge clk)
// Shift_Addra_Delay_Two<= Shift_Addra_Delay;
 
//always@(posedge clk)
//En_Wr_Shift_Delay<=En_Wr_Shift;
//always@(posedge clk)
//En_Wr_Shift_Delay_Two<=En_Wr_Shift_Delay;

 Bias_ram #(
   .ADDR_BITS(WIDTH_BIAS_RAM_ADDRA)
   ) Shift_Ram(
    .clk(clk),
    .write_address(Shift_Addra),
    .input_data(S_Data_Four),
    .write_enable(En_Wr_Shift),
    .read_address(Bias_Addrb),
    .output_data(Data_Out_Shift)
    );
endmodule
