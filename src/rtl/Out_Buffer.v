`timescale 1ns / 1ps

module Out_Buffer(
    input           clk,
    input           rst,
    input [255:0]   S_Data,
    input           S_Valid,
    output reg      S_Ready,
    output [255:0]  M_Data,
    output reg      M_Valid,
    input           M_Ready,
    input           Last
    );

wire empty;
wire full;
reg [1:0]  Current_State;
reg [1:0]  Next_State; 
localparam Idle_State  = 2'b00;
localparam Read_State  = 2'b01;

always@( posedge clk )	begin
	if(rst)begin
		Current_State <= Idle_State;
	end
	else begin
		Current_State <= Next_State;
	end
end 

always@(*)begin
    case(Current_State)
      Idle_State:
          if(Last==1'b1)begin
              Next_State = Read_State;
          end
          else begin
              Next_State = Idle_State;
          end
      Read_State:
          if (empty)begin
              Next_State = Idle_State;
          end
          else begin
              Next_State = Read_State; 
          end
      default: Next_State = Idle_State;
    endcase
end

URAM_FIFO #(
    .DATA_WIDTH         (256),
    .FIFO_DEPTH         (65536),
    .DATA_COUNT_WIDTH   (17)
)URAM_FIFO_1(
    .clk            (clk),
    .rst            (rst),
    .wr_en          (S_Valid && S_Ready),
    .din            (S_Data),
    .rd_en          (M_Valid && M_Ready),
    .dout           (M_Data),
    .empty          (empty),
    .full           (full)
);
//assign S_Ready = !full; // 这个则不需要顾及那么多，几乎等于一直准备接收

// 这种情况是必须要把所有的数据全部写入 Input_Buffer 之后，才准备接收 TJPU 计算的结果
always@(posedge clk)begin
    if(rst)begin
        S_Ready <= 1'b1;
    end
    else begin
        if(Current_State == Idle_State)begin
            S_Ready <= 1'b1;
        end
        else begin
            S_Ready <= 1'b0;
        end
    end
end

always@(posedge clk)begin
    if(rst)begin
        M_Valid <= 1'b0;
    end
    else begin
        if(Current_State == Read_State)begin
            M_Valid <= 1'b1;
        end
        else begin
            M_Valid <= 1'b0;
        end
    end
end

endmodule
