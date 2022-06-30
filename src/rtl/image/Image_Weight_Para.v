`timescale 1ns / 1ps
`include"../Para.v"



module Image_Weight_Para#(parameter
WIDTH_RAM_ADDR_TURE    =   11
    )
    (
    input   clk,
    input   rst,
    input   Start,
    output  reg Write_Block_Complete,
    input  [`IMAGE_WIDTH_DATA-1:0] S_Data,
    input        S_Valid,
    output reg   S_Ready,
    input  [5:0]   weight_addrb,
    output [255:0] Data_Out_Weight   //weight
    );

reg  Inter_Write_Complete;
//-----------------FSM_PARAM-------------
reg  [5:0]      Current_State;
reg  [5:0]      Next_State;
localparam      Idle_State                     = 6'b00_0000;
localparam      Block_State                    = 6'b00_0010;                  

// --------------------------FSM---------------------------------------
 always@( posedge clk  )begin  
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
            if( Start==1'b1)
                Next_State   =   Block_State;
            else 
                Next_State   =   Idle_State; 
       Block_State:
            if(Inter_Write_Complete==1'b1)  
                Next_State   =   Idle_State; 
            else 
                Next_State   =   Block_State;                                 
       default:
                Next_State  =    Idle_State;
    endcase    
end

reg  [WIDTH_RAM_ADDR_TURE-1:0]    Ram_Addra;
wire En_ram;
assign En_ram=(Current_State==Block_State)?1'b1:1'b0;

always@( posedge clk  )begin    
   if( rst )
       Ram_Addra <=  {WIDTH_RAM_ADDR_TURE{1'b0}};
   else begin
       case(Current_State)
          Idle_State:           
                Ram_Addra <=  {WIDTH_RAM_ADDR_TURE{1'b0}};
          Block_State:
                if(S_Valid==1'b1)
                Ram_Addra <=  Ram_Addra+1;
                else
                Ram_Addra <=  Ram_Addra;
          default:
                Ram_Addra <=  {WIDTH_RAM_ADDR_TURE{1'b0}};
       endcase
   end
end

//wire  [`AXI_WIDTH_DATA-1:0] Ram_Data_Out;
//-----------Block_Ram-------------------
image_weight_para image_weight_para (
  .clka(clk),    // input wire clka
  .ena(1),      // input wire ena
  .wea(S_Valid&En_ram),      // input wire [0 : 0] wea
  .addra(Ram_Addra),  // input wire [10 : 0] addra
  .dina(S_Data),    // input wire [7 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(weight_addrb),  // input wire [5 : 0] addrb
  .doutb(Data_Out_Weight)  // output wire [255 : 0] doutb
);

always@( posedge clk  )begin    
   if( rst )
       Inter_Write_Complete <=  1'b0;
   else if (Ram_Addra==1440-1) 
       Inter_Write_Complete <=  1'b1;
    else
       Inter_Write_Complete <=  1'b0;
end

always@( posedge clk  )begin    
   if( rst )
       S_Ready <=  1'b0;
   else if (Current_State==Block_State&&Next_State==Idle_State) 
    begin
       S_Ready <=  1'b0;
    end
   else if(Current_State==Idle_State&&Next_State==Block_State)
       S_Ready <=  1'b1;
   else 
       S_Ready <= S_Ready;
end



always@( posedge clk  )begin    
   if( rst )
       Write_Block_Complete <=  1'b0;
   else if (Current_State==Block_State&&Next_State==Idle_State) 
    begin
       Write_Block_Complete <=  1'b1;
    end
    else
       Write_Block_Complete <=  1'b0;
end

endmodule

