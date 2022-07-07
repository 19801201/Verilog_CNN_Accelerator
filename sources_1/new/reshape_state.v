`timescale 1ns / 1ps
`include"./Para.v"



module reshape_state(
    input  					clk,
    input  					rst,
    input   [3:0] 			Control_Reshape,
//    input   [3:0]			Control_Concat, 
    output reg [3:0] 		Start_Reshape,
//    output reg [1:0]        Start_Concat,        /////////// concat
    output reg [7:0] 		 State,           
    input		[3:0]		Complete,   //   Complete[1]: Split Down ,Complete[2]: Maxpool Down  ,Complete[3]:Upsample_Down
//    input       [1:0]       Concat_Complete,       //////////////  concat  
    output reg              Next_Reg,
    output reg 				DMA_read_valid,
    output reg 				DMA_write_valid, 
    output reg 				DMA_read_valid_2,
    output reg [3:0]		End_Control
    );



localparam Idle_State                     = 8'b0000_0000;
localparam Concat_State                   = 8'b0000_0001;

//localparam Start_Concat_State             = 8'b0000_0001;
//localparam Concat_Para_State              = 8'b0001_0001;
//localparam Concat_Compute_State           = 8'b0010_0001;
//localparam Concat_Para_Irq_State          = 8'b0011_0001;
//localparam Concat_Compute_Irq_State       = 8'b1111_0001;
localparam Split_State                    = 8'b0000_0010;
localparam Maxpool_State                  = 8'b0000_0100;
localparam Upsample_State                 = 8'b0000_1000;
localparam Irq_State                      = 8'b0000_1111;


reg [7:0]  Current_State;
reg [7:0]  Next_State;

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
      		if(Control_Reshape == 4'b0001)begin
                Next_State = Concat_State;
            end
            else if(Control_Reshape == 4'b0010)begin
               Next_State = Split_State;
            end
            else if(Control_Reshape == 4'b0100)begin
                 Next_State = Maxpool_State;
            end
            else if(Control_Reshape == 4'b1000)begin
            	Next_State = Upsample_State;
            end
            else begin
                Next_State = Idle_State;
            end
        Concat_State:begin
            if(Complete[3] == 1'b1)begin
                Next_State = Irq_State;
            end
            else begin
                 Next_State = Concat_State;
            end
        end  
            
//       Start_Concat_State: begin
//            if(Control_Concat_Delay[1] == 4'b0001)begin
//                Next_State = Concat_Para_State;
//            end
//            else if (Control_Concat_Delay[1] == 4'b0010) begin
//                Next_State = Concat_Compute_State;
//            end
//            else
//                Next_State = Start_Concat_State;
//        end
//        Concat_Para_State: begin
//            if (Concat_Complete[0])
//                Next_State = Concat_Para_Irq_State;
//            else
//                Next_State = Concat_Para_State;
//        end
//        Concat_Compute_State: begin
//            if (Concat_Complete[1])
//                Next_State = Concat_Compute_Irq_State;
//            else
//                Next_State = Concat_Compute_State;
//        end
//        Concat_Para_Irq_State:
//            if (Control_Concat_Delay[1] == 4'b1111)
//                Next_State = Irq_State;
//            else
//                Next_State = Concat_Para_Irq_State;
//        Concat_Compute_Irq_State:
//            if (Control_Concat_Delay[1] == 4'b1111)
//                Next_State = Irq_State;
//            else
//                Next_State = Concat_Compute_Irq_State;    
       Split_State: begin
            if(Complete[0] == 1'b1)begin
                Next_State = Irq_State;
            end
            else begin
                 Next_State = Split_State;
            end
        end    
       Maxpool_State: 
           if(Complete[1] == 1'b1)begin
                Next_State = Irq_State;
            end
            else begin
                 Next_State = Maxpool_State;
            end   
       Upsample_State:
       		if (Complete[2] == 1'b1) begin 
       			Next_State = Irq_State;
       		end
       		else begin
       			Next_State = Upsample_State;
       		end
       Irq_State:
            if(Control_Reshape == 4'b1111) begin
                Next_State = Idle_State;
            end
            else begin
                 Next_State = Irq_State;
            end
       default:Next_State = Idle_State;
      endcase
end

//always @ (posedge clk) begin 
//    Control_Concat_Delay[0][3:0] <= Control_Concat[3:0];
//    Control_Concat_Delay[1][3:0] <= Control_Concat_Delay[0][3:0];
//end


//--------------Concat Para  Start  Signal  -------

//always@(posedge clk )begin
//    if(rst)begin
//      Start_Concat[0] <= 1'b0;
//    end
//    else if(Current_State ==Start_Concat_State & Next_State == Concat_Para_State)
//    begin
//       Start_Concat[0] <= 1'b1;   
//    end
//    else begin
//       Start_Concat[0] <= 1'b0;
//    end
//end

//--------------Concat Compute  Start  Signal  ------------------

//always@(posedge clk )begin
//    if(rst)begin
//      Start_Concat[1] <= 1'b0;
//    end
//    else if(Current_State ==Start_Concat_State & Next_State == Concat_Compute_State)
//    begin
//       Start_Concat[1] <= 1'b1;   
//    end
//    else begin
//       Start_Concat[1] <= 1'b0;
//    end
//end


always@(posedge clk )begin
    if(rst)begin
      Start_Reshape[0] <= 1'b0;
    end
    else if(Current_State ==Idle_State & Next_State == Split_State)
    begin
       Start_Reshape[0] <= 1'b1;   
    end
    else begin
       Start_Reshape[0] <= 1'b0;
    end
end


always@(posedge clk )begin
    if(rst)begin
      Start_Reshape[1] <= 1'b0;
    end
    else if(Current_State ==Idle_State & Next_State == Maxpool_State)
    begin
       Start_Reshape[1] <= 1'b1;   
    end
    else begin
       Start_Reshape[1] <= 1'b0;
    end
end


always@(posedge clk )begin
    if(rst)begin
      Start_Reshape[2] <= 1'b0;
    end
    else if(Current_State ==Idle_State & Next_State == Upsample_State)
    begin
       Start_Reshape[2] <= 1'b1;   
    end
    else begin
       Start_Reshape[2] <= 1'b0;
    end
end
//  concat
always@(posedge clk )begin
    if(rst)begin
      Start_Reshape[3] <= 1'b0;
    end
    else if(Current_State ==Idle_State & Next_State == Concat_State)
    begin
       Start_Reshape[3] <= 1'b1;   
    end
    else begin
       Start_Reshape[3] <= 1'b0;
    end
end

always@(posedge clk )begin
    if(rst)begin      
        State          <=  8'b0000_0000; 
    end
    else begin
        case(Current_State)
         Idle_State:
            State    <=  8'b0000_0000; 
         Concat_State:
            State    <=  8'b0000_0001;
//         Concat_Para_State:
//            State    <=  8'b0001_0001;
//         Concat_Compute_State:
//            State    <=  8'b0010_0001;
//         Concat_Para_Irq_State:
//            State    <=  8'b1111_0001;
//         Concat_Compute_Irq_State:
//            State    <=  8'b1111_0001; 
         Split_State:
            State    <=  8'b0000_0010; 
         Maxpool_State:
            State    <=  8'b0000_0100;
         Upsample_State:
            State    <=  8'b0000_1000;
         Irq_State:
         	State    <=  8'b0000_1111;
        default:  State   <=  8'b0000_0000; 
        endcase
    end
end
//


//always @ (posedge clk) begin 
//	if (rst)
//		State_Cnt <= 3'b0;
//	else if (Current_State == Idle_State)
//		State_Cnt <= 3'b0;
//	else if (Current_State == Concat_Para_State && Next_State == Concat_Irq_State)
//		State_Cnt <= State_Cnt + 1'b1;
//	else if (Current_State == Concat_Compute_State && Next_State == Concat_Irq_State)
//		State_Cnt <= State_Cnt + 1'b1;
//	else
//		State_Cnt <= State_Cnt;
//end

//assign	State_Return = (State_Cnt == 3'd2)?1'b1:1'b0;
    //output DMA_read_valid,
    //output DMA_write_valid,
 always@(posedge clk )begin
    if(rst)begin
     DMA_read_valid <= 1'b0;
     DMA_write_valid <= 1'b0;
     DMA_read_valid_2 <= 1'b0;
    end
//    else if(Current_State == Start_Concat_State & Next_State == Concat_Para_State)
//    	begin
//    	   DMA_read_valid <= 1'b1;
//    	   DMA_write_valid <= 1'b0;
//    	end
    else if (Current_State == Idle_State & Next_State == Concat_State)
        begin 
            DMA_read_valid <= 1'b1;
            DMA_write_valid <= 1'b1;
            DMA_read_valid_2 <= 1'b1;
        end   
    else if(Current_State ==Idle_State & Next_State == Split_State)
    	begin
    	   DMA_read_valid <= 1'b1;
    	   DMA_write_valid <= 1'b1; 
    	   DMA_read_valid_2 <= 1'b0; 
    	end
    else if(Current_State ==Idle_State & Next_State == Maxpool_State)
    	begin
    	   DMA_read_valid <= 1'b1;
    	   DMA_write_valid <= 1'b1;  
    	   DMA_read_valid_2 <= 1'b0;
    	end
    else if(Current_State ==Idle_State & Next_State == Upsample_State)
    	begin
    	   DMA_read_valid <= 1'b1;
    	   DMA_write_valid <= 1'b1;  
    	   DMA_read_valid_2 <= 1'b0;
    	end
    else begin
    	DMA_read_valid <= 1'b0;
    	DMA_write_valid <= 1'b0;
    	DMA_read_valid_2 <= 1'b0;
    end
end   

always @ (posedge clk) begin 
	case (Control_Reshape)
		4'b0001:
			End_Control <= 4'b1110;
		4'b0010:
			End_Control <= 4'b1101;
		4'b0100:
			End_Control <= 4'b1011;
		4'b1000:
			End_Control <= 4'b0111;
	endcase
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