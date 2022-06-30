`timescale 1ns / 1ps
`include  "../Para.v"


module image_conv_quan_control#(parameter
	WIDTH_FEATURE_SIZE = 10
)(
	input	clk,
	input 	rst,
	input	Start,
	input   [10:0] Row_Num_Out_REG,
	input   [7:0] Channel_Out_Num_REG,
	input	fifo_valid,         //////  fifo  计满一行信号
	input	M_Ready,             ///  下一模块数据响应信号
	output	rd_en_fifo,
	output	reg	[3:0]	para_select,
	output  [13:0]  S_Count_Fifo,
	output	M_Valid
   );
    
localparam	Idle_State               = 5'b00000;
localparam  Wait_State               = 5'b00001;
localparam  Judge_Before_FIFO_State  = 5'b00010;
localparam	Judge_After_FIFO_State   = 5'b00100;
localparam	Compute_State            = 5'b01000; 
localparam  Judge_State              = 5'b10000;

    
reg	[4:0]	Current_State;
reg	[4:0]	Next_State;

wire	M_Valid_Temp;
reg		M_Valid_Temp_Delay[0:32];
reg [WIDTH_FEATURE_SIZE-1:0]    Cnt_Column;
reg [WIDTH_FEATURE_SIZE-1:0]    Cnt_Row;
reg	[2:0]	Cnt_Cout;

wire    En_Last_Column;
wire    En_Last_Cout;
wire    EN_Row;

reg [4:0]  wait_cnt;
wire       wait_en;

wire [2:0] CHANNEL_OUT_TIMES = Channel_Out_Num_REG >> 3;

assign	En_Last_Cout = (Cnt_Cout + 1'b1 == CHANNEL_OUT_TIMES)?1'b1:1'b0;
assign	En_Last_Column = (Cnt_Column + 1'b1 == Row_Num_Out_REG && En_Last_Cout == 1'b1)?1'b1:1'b0;
assign	rd_en_fifo = (Current_State == Compute_State)?1'b1:1'b0;
assign  EN_Row  =   (Cnt_Row+1'b1 == Row_Num_Out_REG)?1'b1:1'b0;
assign	M_Valid_Temp = (Current_State == Compute_State)?1'b1:1'b0;

always @ (posedge clk)begin 
	if (rst)
		Current_State <= Idle_State;
	else
		Current_State <= Next_State;
end

always @ (*) begin
	Next_State = Idle_State;
	case (Current_State)
		Idle_State:
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
			if (fifo_valid == 1'b1)
				Next_State = Judge_After_FIFO_State;
			else
				Next_State = Judge_Before_FIFO_State;
		Judge_After_FIFO_State:
			if (M_Ready == 1'b1)
				Next_State = Compute_State;
			else
				Next_State = Judge_After_FIFO_State;
		Compute_State:
			if (En_Last_Column == 1'b1)
				Next_State = Judge_State;
			else
				Next_State = Compute_State;
		Judge_State:
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

image_quan_mult image_quan_mult (
  .CLK(clk),  // input wire CLK
  .A(Row_Num_Out_REG),      // input wire [10 : 0] A
  .B(CHANNEL_OUT_TIMES),      // input wire [2 : 0] B
  .P(S_Count_Fifo)      // output wire [13 : 0] P
);


always @ (posedge clk) begin 
	if (rst)
		Cnt_Cout <= 3'b000;
	else begin 
		case (Current_State)
			Idle_State:
				Cnt_Cout <= 3'b000;
			Compute_State:
				if (En_Last_Cout == 1'b1)
					Cnt_Cout <= 3'b000;
				else
					Cnt_Cout <= Cnt_Cout + 1'b1;
			default:
				Cnt_Cout <= 3'b000;
		endcase
	end
end

always @ (posedge clk) begin 
	if (rst)
		para_select <= 4'b0000;
	else if (Current_State == Compute_State)begin 
		case (Cnt_Cout)
			3'b000:
				para_select <= 4'b0001;
			4'b001:
				para_select <= 4'b0010;
			4'b010:
				para_select <= 4'b0100;
			4'b011:
				para_select <= 4'b1000;
		endcase
	end
	else 
		para_select <= 4'b0000;
end

always @ (posedge clk) begin 
	if (rst)
		Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
	else begin 
		case (Current_State)
			Idle_State:
				Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
			Compute_State:
				if (En_Last_Cout == 1'b1)
					Cnt_Column <= Cnt_Column + 1'b1;
				else
					Cnt_Column <= Cnt_Column;
			default:
				Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
		endcase
	end
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

//////////////////   对传出数据的请求进行延迟处理      /////////////////////////
///////    一共延迟26个时钟周期 : bias 2个(加法器) + 1个(对输入数据延迟了1个clk) + 1个(bias数据选择需要1clk，所以需要对输入数据再进行一个延迟)，scale  3个(乘法器) + 1(scale权重选择),shift 6个  , zero point 2 个(加法器)  leakyrelu 10 个延迟 //////
/// 此处延迟一个时钟周期 ///
always @ (posedge clk) begin
	M_Valid_Temp_Delay[0] <= M_Valid_Temp;	
end

/// 此处延迟25个时钟周期 ///
generate
genvar j;
	for (j = 0;j < 32;j = j + 1)begin
		always @ (posedge clk) begin
			M_Valid_Temp_Delay[j+1] <= M_Valid_Temp_Delay[j];
		end
	end
endgenerate

//assign M_Valid = M_Valid_Temp_Delay[25];    // 原本 25
//assign M_Valid = M_Valid_Temp_Delay[26];    // leaky里的case    +1 = 26   
//assign M_Valid = M_Valid_Temp_Delay[27];    // leaky里的case 和 bias里的case  +2 = 27
assign M_Valid = M_Valid_Temp_Delay[32];    // leaky里的case 和 bias里的case  +2 = 27  scale 乘法器 +5

endmodule