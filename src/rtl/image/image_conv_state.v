`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/12 10:17:06
// Design Name: 
// Module Name: image_conv_state
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include  "../Para.v"


module image_conv_state(
    input  clk,
    input  rst,
    input  [3:0]Control,//[4]
    output reg [3:0] State,//4//������λ�����ź�
    input  [1:0]Complete,
    output reg [1:0] Start,
    output reg DMA_read_valid,
    output reg DMA_write_valid,
    output reg Next_Reg  
    );

    
    localparam Idle_State                   = 4'b0000;
    localparam Para_State                   = 4'b0001;
    localparam Compute_State                = 4'b0010;
    localparam Irq_State                    = 4'b1111;
    reg [3:0]  Current_State;
    reg [3:0]  Next_State;
    
    always@( posedge clk )    begin
        if( rst )begin
            Current_State       <=          Idle_State;
        end
        else begin
            Current_State       <=          Next_State;
        end
    end 
    always@(*)begin
        Next_State = Idle_State;
          case(Current_State)
          Idle_State:begin
                if(Control == 4'b0010)begin
                    Next_State = Compute_State;
                end
                else if(Control == 4'b0001)begin
                    Next_State = Para_State;
                end
                else begin
                    Next_State = Idle_State;
                end
           end
           Para_State: begin
                if(Complete[0] == 1'b1)begin
                    Next_State = Irq_State;
                end
                else begin
                     Next_State = Para_State;
                end
            end 
           Compute_State: begin
                if(Complete[1] == 1'b1)begin
                    Next_State = Irq_State;
                end
                else begin
                     Next_State = Compute_State;
                end
            end    
           Irq_State:
                if(Control == 4'b1111) begin
                     Next_State = Idle_State;
                end
                else begin
                        Next_State = Irq_State;
                end
           default:Next_State = Idle_State;
          endcase
    end
    //--------------para����--------
    always@(posedge clk )begin
        if(rst)begin      
            State       <=  4'b0000; 
        end
        else begin
            case(Current_State)
             Idle_State:
                State  <=  4'b0000; 
             Para_State:
                State  <=  4'b0001;
             Compute_State:
                State  <=  4'b0010; 
             Irq_State:
                State  <=  4'b1111; 
            default:  State <=  4'b0000; 
            endcase
        end
    end
    

always@(posedge clk )begin
    if(rst)begin
        DMA_read_valid <= 1'b0;
        DMA_write_valid <= 1'b0;
    end
    else if(Current_State ==Idle_State & Next_State == Para_State)
    begin
       DMA_read_valid <= 1'b1;
       DMA_write_valid <= 1'b0;  
    end
    else if(Current_State ==Idle_State & Next_State == Compute_State)
    begin
       DMA_read_valid <= 1'b1;
       DMA_write_valid <= 1'b1;  
    end
    else begin
      DMA_read_valid <= 1'b0;
      DMA_write_valid <= 1'b0;
    end
end 

always@(posedge clk )begin
    if(rst)begin
      Start <= 2'b00;
    end
    else if(Current_State ==Idle_State & Next_State == Para_State)
    begin
      Start <= 2'b01;   
    end
    else if(Current_State ==Idle_State & Next_State == Compute_State)
    begin
      Start <= 2'b10;   
    end
    else begin
      Start <= 2'b00;
    end
end   

always @ (posedge clk)begin 
    if (rst)
        Next_Reg <= 1'b0;
    else if (Current_State == Irq_State & Next_State == Idle_State)
        Next_Reg <= 1'b1;
    else
        Next_Reg <= 1'b0;
end

endmodule
