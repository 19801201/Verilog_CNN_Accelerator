`timescale 1ns / 1ps
`include "../Para.v"

module image_four2three(
   input clk,
   input rst,
   input Start,
   output reg Start_Row,   
   input  [9:0] Row_Num_After_Padding,
   input  [`IMAGE_WIDTH_DATA-1:0] S_Data,    // padding into four bram
   input  S_Valid,
   output S_Ready, 
   input  M_Ready,
   output reg [`IMAGE_WIDTH_DATA*3-1:0] M_Data,
   input  [9:0] M_Addr
    );
    localparam      Idle_State           = 6'b00_0000;
    localparam      Judge_Fifo_State     = 6'b00_0010;
    localparam      Read_State           = 6'b00_0100;
    localparam      Judge_Compute_State  = 6'b00_1000;
    localparam      Start_Compute_State  = 6'b01_0000;
    localparam      Wait_End_State       = 6'b10_0000;
    
    reg  [5:0] Current_State;
    reg  [5:0] Next_State;
    
    reg  [3:0]  Ena_Ram;
    reg  [9:0]  addra_ram;
    reg  [9:0]  Cnt_Row;
    reg  [9:0]  Cnt_Column;
    reg  [2:0]  Cnt_Start_Row ;
    wire [`IMAGE_WIDTH_DATA-1:0]Out_Data_Ram[3:0];
    wire [`IMAGE_WIDTH_DATA-1:0]Out_Data_fifo;
    wire EN_Write;        //
    wire EN_Read_State;   //
    wire EN_Start_Row;       //
    wire EN_Middle;      //
    wire EN_Fifo_Row;    //
    reg [3:0] Four_To_Three;
    reg EN_First; 
    reg[10:0]      S_Count_Fifo  ;
    always@(posedge clk)begin
        S_Count_Fifo <= Row_Num_After_Padding;
    end
    //
    assign EN_Write     =(Current_State==Read_State)?1'b1:1'b0;//
    assign EN_Read_State=(Cnt_Column+1'b1==Row_Num_After_Padding)?1'b1:1'b0;//
    assign EN_Start_Row =(Cnt_Start_Row < 2'b10)?1'b1:1'b0;//
    assign EN_Middle    =(Cnt_Row+2'b11<Row_Num_After_Padding)?1'b1:1'b0;//
    //===============fifo===================
    image_four2three_fifo  #(
            .WIDTH(`IMAGE_WIDTH_DATA),
            .ADDR_BITS(10)
    )
    image_four2three_fifo
    (
         .clk(clk),
         .rst(rst),
         .din(S_Data),
         .wr_en(S_Valid),
         .rd_en(EN_Write),
         .dout(Out_Data_fifo),
         .M_Count(S_Count_Fifo),  //back
         .M_Valid(EN_Fifo_Row),//
         .S_Count(S_Count_Fifo),   //front
         .S_Ready(S_Ready)//
    );   
    
    generate
    genvar i;
    for(i = 0; i < 4; i = i + 1)begin
    image_Configurable_RAM  #(
         .WIDTH(`IMAGE_WIDTH_DATA),
         .ADDR_BITS(10)         
    )
    Image_Feature_Write_Ram(  //
        .clk(clk),
        .read_address(M_Addr),
        .write_address(addra_ram),
        .input_data(Out_Data_fifo),
        .write_enable(EN_Write&Ena_Ram[i]),
        .output_data(Out_Data_Ram[i])
        );
    end
    endgenerate
    // ====================================================================
     always@( posedge clk  )begin  //   
        if( rst )begin
            Current_State <= Idle_State;
        end
        else begin
            Current_State <= Next_State;
        end
     end
     always @ (*) begin//    
        Next_State = Idle_State; //
        case(Current_State)    
           Idle_State: if( Start==1'b1)begin
                            Next_State  =   Judge_Fifo_State;     //
                            end
                       else 
                           Next_State   =   Idle_State;  
           Judge_Fifo_State:if(EN_Fifo_Row==1'b1)
                                 Next_State  = Read_State;
                             else 
                                  Next_State  =   Judge_Fifo_State;                                               
           Read_State: if( EN_Read_State==1'b1 ) begin//
                            Next_State  = Judge_Compute_State;
                            end 
                       else 
                            Next_State  = Read_State;
           Judge_Compute_State:begin
                        if(M_Ready==1'b0) begin //
                            if(EN_Start_Row==1'b1) //
                                 Next_State  = Judge_Fifo_State;                           
                            else                //   
                                 Next_State  = Start_Compute_State;   
                            end                      
                       else 
                            Next_State  = Judge_Compute_State;//
                    end
           Start_Compute_State:  begin   
                         if  (EN_Middle==1'b1)                               
                            Next_State  =  Judge_Fifo_State; 
                         else    
                            Next_State  =   Wait_End_State;                                                   
                            end
           Wait_End_State:begin             //
                       if(M_Ready==1'b1)
                         Next_State  =   Idle_State;  
                       else
                         Next_State  =   Wait_End_State; 
           end
           default:  Next_State  =    Idle_State;
        endcase    
    end 
    //=====================
    always@( posedge clk  )begin    
       if( rst )
           Cnt_Column <=  {10{1'b0}};
       else begin
           case(Current_State)
               Read_State:                    
                    Cnt_Column <=  Cnt_Column +   1'b1;  
               default:   Cnt_Column <=  {10{1'b0}};                         
           endcase
       end
    end
    //=====================
    always@( posedge clk  )begin    
       if( rst )
           Cnt_Row <=  {10{1'b0}};
       else begin
           case(Current_State)
               Start_Compute_State:   Cnt_Row <= Cnt_Row + 1'b1;
               Idle_State: Cnt_Row <=  {10{1'b0}};
               default:   Cnt_Row <= Cnt_Row ;
           endcase
       end
    end
    //======================
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
    //=======================
    always@( posedge clk  )begin    
       if( rst )
           addra_ram   <=   {10{1'b0}};
       else begin
           case(Current_State)
               Read_State: addra_ram <=  addra_ram +   1'b1;
               default: addra_ram <=  {10{1'b0}};
           endcase
       end
    end
    //===========================
    always@(posedge clk)begin    
       if( rst )
          Start_Row=1'b0;
       else if (Next_State==Start_Compute_State) begin
                    Start_Row=1'b1;
        end
        else   Start_Row=1'b0;//Stride=
     end
    
    //==================================
    always@( posedge clk  )begin    
       if(rst)
          Ena_Ram<=4'b0001;
       else begin
           if(Current_State==Read_State&Next_State==Judge_Compute_State)
                Ena_Ram<={Ena_Ram[2:0],Ena_Ram[3]};   // 1000_t_0100  next 0100_t_0010
           else if(Next_State==Idle_State)
                  Ena_Ram<=4'b0001;
           else 
                 Ena_Ram<= Ena_Ram;
        end
    end
    //========================================
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
    //==========================================================
    //==========EN_First=================
    always@( posedge clk  )begin    
       if( rst )
          EN_First<= 1'b0;
       else if(EN_First==1'b0&Current_State==Start_Compute_State)//
            EN_First<= 1'b1;
       else if(Current_State==Idle_State) 
            EN_First<= 1'b0;
       else  EN_First<= EN_First;
    end
    //===========================
    always@(posedge clk)begin    
    if( rst )
          Four_To_Three<=4'b0001;//4'b0001
    else begin
          if(Current_State==Idle_State)//
                Four_To_Three<=4'b0001;
          else  if(EN_First==1'b1)begin //
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
