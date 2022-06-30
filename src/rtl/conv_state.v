`timescale 1ns / 1ps
`include"../Para.v"

module conv_state(
    input  clk,
    input  rst,
    input  [3:0] Control,
    output reg [3:0] State,
    input  [3:0] Complete,
    output reg [3:0] Sign,
    output reg  Next_Reg,
    output reg DMA_read_valid,
    output reg DMA_write_valid  
    );
localparam Idle_State                   = 4'b0000;
localparam Compute_State                = 4'b0010;
localparam Para_State                   = 4'b0001;
localparam Para_Irq_State               = 4'b0011;
localparam Feature_Irq_State            = 4'b1111;
reg [3:0]  Current_State;
reg [3:0]  Next_State;

always@( posedge clk )	begin
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
      Idle_State:
            if(Control == 4'b0010)begin
                Next_State = Compute_State;
            end
            else if(Control == 4'b0001)begin
               Next_State = Para_State;
            end
            else begin
                Next_State = Idle_State;
            end
       Compute_State: begin
            if(Complete[2] == 1'b1)begin
                Next_State = Feature_Irq_State;
            end
            else begin
                 Next_State = Compute_State;
            end
        end    
       Para_State: 
           if(Complete[0] == 1'b1)begin
                Next_State = Para_Irq_State;
            end
            else begin
                 Next_State = Para_State;
            end   
       Para_Irq_State:
            if(Control == 4'b1111) begin
                 Next_State = Idle_State;
            end
            else begin
                    Next_State = Para_Irq_State;
            end
       Feature_Irq_State:
           if (Control == 4'b1111) begin
               Next_State = Idle_State;    
           end    
           else begin 
               Next_State = Feature_Irq_State;
           end
       default:Next_State = Idle_State;
      endcase
end

always@(posedge clk )begin
    if(rst)begin
      Sign<= 4'b0000;
    end
    else if(Current_State ==Idle_State & Next_State == Compute_State)
    begin
       Sign <= 4'b0010;   
    end
    else if(Current_State ==Idle_State & Next_State == Para_State)
    begin
       Sign <= 4'b0001; 
    end
    else begin
       Sign<= 4'b0000;
    end
end

always@(posedge clk )begin
    if(rst)begin      
        State          <=  4'b0000; 
    end
    else begin
        case(Current_State)
         Idle_State:
            State    <=  4'b0000; 
         Compute_State:
            State  <=  4'b0010; 
         Para_State:
            State  <=  4'b0001; 
         Feature_Irq_State:
            State  <=  4'b1111; 
         Para_Irq_State:
            State <= 4'b1111;
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

always @ (posedge clk)begin 
    if (rst)
        Next_Reg <= 1'b0;
    else if (Current_State == Feature_Irq_State & Next_State == Idle_State)
        Next_Reg <= 1'b1;
    else
        Next_Reg <= 1'b0;
end


endmodule
