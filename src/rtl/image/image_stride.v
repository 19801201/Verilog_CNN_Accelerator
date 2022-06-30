`timescale 1ns / 1ps
`include "../Para.v"

module image_stride#(parameter
	COMPUTE_CHANNEL_OUT_NUM	  =	 8,
	WIDTH_CHANNEL_NUM_REG   =  10,
	WIDTH_FEATURE_SIZE = 10
)(
	input  			      clk,
	input			      rst,
	input			      Start,
	input                 EN_Stride_REG,
	input   [10:0]        Row_Num_Out_REG,
	input   [7:0]         Channel_Out_Num_REG,
	input			      S_Valid,
	output			      S_Ready,
	input	[COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0]	      S_Data,
	output	[COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0]	      M_Data,
	output			      M_Valid,
	input			      M_Ready,
	output		reg       Stride_Complete,          // 步长操作完成的标忿
    output                Img_Last
    );
    
localparam	Idle_State = 3'b000;
localparam	Stride_State = 3'b001;    
wire Img_Last_stride_2;
reg		[WIDTH_FEATURE_SIZE-1:0]	Cnt_Column;
reg		[WIDTH_FEATURE_SIZE-1:0]	Cnt_Row;
reg		[2:0]						Cnt_Cout;

wire	En_Stride,En_Last_Col,En_Last_Row,En_Last_Cout;
wire	[2:0]	Channel_Times;

assign	Channel_Times = Channel_Out_Num_REG >> 3;  // 32陿8
assign	En_Stride = (Start == 1'b1 && EN_Stride_REG == 1'b1)?1'b1:1'b0;
//assign	En_Stride = (Start == 1'b1)?1'b1:1'b0;
assign	En_Last_Col = (Cnt_Column + 1'b1 == Row_Num_Out_REG)?1'b1:1'b0;
assign  En_Last_Cout = (Cnt_Cout + 1'b1 == Channel_Times)?1'b1:1'b0;
assign	En_Last_Row = (Cnt_Row + 1'b1 == Row_Num_Out_REG)?1'b1:1'b0;


reg	[2:0]	Current_State;
reg	[2:0]	Next_State;

reg		wr_en_fifo;
reg	[COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM-1:0] End_Feature;
reg [18:0]	Cnt_Stride_Complete;

always @ (posedge clk) begin 
	if (rst)
		Current_State <= Idle_State;
	else
		Current_State <= Next_State;
end

always @ (*) begin 
	Next_State = Idle_State;
	case(Current_State)
		Idle_State:
			if (En_Stride)
				Next_State = Stride_State;
			else
				Next_State = Idle_State;
		Stride_State:
			if (En_Last_Cout && En_Last_Col && En_Last_Row)
				Next_State = Idle_State;
			else
				Next_State = Stride_State;
		default:
			Next_State = Idle_State;
	endcase
end

always @ (posedge clk) begin 
	if (rst)
		Cnt_Cout <= 3'b000;
	else begin 
		case (Current_State)
			Idle_State:
				Cnt_Cout <= 3'b000;
			Stride_State:
				if (S_Valid == 1'b1) begin 
					if (En_Last_Cout)
						Cnt_Cout <= 3'b000;
					else
						Cnt_Cout <= Cnt_Cout + 1'b1;
				end
				else
					Cnt_Cout <= Cnt_Cout;
			default:
				Cnt_Cout <= 3'b000;
		endcase
	end
end   
    
always @ (posedge clk) begin 
	if (rst) 
		Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
	else begin 
		case (Current_State)
			Idle_State:
				Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
			Stride_State:
				if (S_Valid == 1'b1) begin 
					if (En_Last_Cout)begin 
						if (En_Last_Col)
							Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
						else
							Cnt_Column <= Cnt_Column + 1'b1;
					end
					else
						Cnt_Column <= Cnt_Column;
				end
				else
					Cnt_Column <= Cnt_Column;
			default:
				Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
		endcase
	end
end 
    
    
always @ (posedge clk) begin 
	if (rst)
		Cnt_Row <= {WIDTH_FEATURE_SIZE{1'b0}};
	else begin 
		case (Current_State)
			Idle_State:
				Cnt_Row <= {WIDTH_FEATURE_SIZE{1'b0}};
			Stride_State:
				if (En_Last_Col && En_Last_Cout)
					Cnt_Row <= Cnt_Row + 1'b1;
				else
					Cnt_Row <= Cnt_Row;
			default:
				Cnt_Row <= {WIDTH_FEATURE_SIZE{1'b0}};
		endcase
	end
end

always @ (posedge clk) begin 
	if (rst)
		wr_en_fifo <= 1'b0;
	else begin 
		case (Current_State)
			Idle_State:
				wr_en_fifo <= S_Valid;
			Stride_State:
				if (Cnt_Row[0] == 1'b0 && Cnt_Column[0] == 1'b0 && S_Valid == 1'b1)
					wr_en_fifo <= 1'b1;
				else
					wr_en_fifo <= 1'b0;
			default:
				wr_en_fifo <= 1'b0;
		endcase
	end
end
    ///    延迟丿个时钟周朿     ///
always @ (posedge clk) begin 
	End_Feature <= S_Data;
end    
reg  [WIDTH_FEATURE_SIZE-1 :0]  row_num_out;
always@(posedge clk)begin
    case(EN_Stride_REG)
        1'b1:row_num_out<=Row_Num_Out_REG>>1;
        1'b0:row_num_out<=Row_Num_Out_REG;
        default:row_num_out<=Row_Num_Out_REG;
    endcase
end

    
wire	empty;
reg	[11:0]	data_count;
always @ (posedge clk) begin 
	data_count <= row_num_out * Channel_Times;
end

image_Stride_FIFO  #(
	.WIDTH  		(COMPUTE_CHANNEL_OUT_NUM*`WIDTH_DATA*`PICTURE_NUM),
	.ADDR_BITS      (WIDTH_FEATURE_SIZE)
)	image_Stride_FIFO (  
     .clk			(clk),
     .rst           (rst),
     .din           (End_Feature),
     .wr_en         (wr_en_fifo),
     .rd_en         (M_Ready&M_Valid),
     .dout          (M_Data),
     .M_count       (data_count),
     .M_Ready       (),
     .S_count       (data_count),
     .S_Ready       (S_Ready),
     .empty         (empty)
);

assign	M_Valid = !empty; 

////////////////////        Last_Logic              /////////////////////////
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Row;
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Column;
reg      [WIDTH_CHANNEL_NUM_REG-1:0]	    M_Cnt_Cout;

wire                                       M_En_Last_Cout;   
wire                                       M_En_Last_Col;   
wire                                       M_En_Last_Row;   


assign  M_En_Last_Cout = (M_Cnt_Cout + 1'b1 == Channel_Times)?1'b1:1'b0;
assign  M_En_Last_Col = (M_Cnt_Column + 1'b1 == row_num_out)?1'b1:1'b0;
assign  M_En_Last_Row = (M_Cnt_Row + 1'b1 == row_num_out)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
        M_Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
    else if (M_Ready&M_Valid) begin
        if (M_En_Last_Cout)
            M_Cnt_Cout <= {WIDTH_CHANNEL_NUM_REG{1'b0}};
        else
            M_Cnt_Cout <= M_Cnt_Cout + 1'b1;
    end
    else
        M_Cnt_Cout <= M_Cnt_Cout;
end

always @ (posedge clk) begin 
    if (rst)
        M_Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
    else if (M_En_Last_Cout&M_Ready&M_Valid) begin
        if (M_En_Last_Col)
            M_Cnt_Column <= {WIDTH_FEATURE_SIZE{1'b0}};
        else
            M_Cnt_Column <= M_Cnt_Column + 1'b1;
    end
    else
        M_Cnt_Column <= M_Cnt_Column;
end


always @ (posedge clk) begin 
    if (rst)
        M_Cnt_Row <= {WIDTH_FEATURE_SIZE{1'b0}};
    else if (M_Ready&M_Valid) begin
        if (M_En_Last_Col&&M_En_Last_Cout)
            M_Cnt_Row <= M_Cnt_Row + 1'b1;
        else
            M_Cnt_Row <= M_Cnt_Row;
    end  
    else
        M_Cnt_Row <= M_Cnt_Row;      
end

assign  Img_Last = (M_En_Last_Cout&&M_En_Last_Col&&M_En_Last_Row)?1'b1:1'b0;
assign  Img_Last_stride_2 = (En_Last_Cout&&En_Last_Col&&En_Last_Row)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
       Stride_Complete <= 1'b0;
    else if (Img_Last_stride_2) 
       Stride_Complete <= 1'b1;
    else
       Stride_Complete <= 1'b0;
end

//always @ (posedge clk) begin 
//    if (rst)
//        Cnt_Stride_Complete <= 19'd0;
//    else if(Cnt_Stride_Complete + 1'b1 >= 19'd409600)begin
//        Cnt_Stride_Complete <= 19'd0;
//    end
//    else if (M_Ready&M_Valid)
//        Cnt_Stride_Complete <= Cnt_Stride_Complete + 1'b1;
//    else 
//        Cnt_Stride_Complete <= Cnt_Stride_Complete;
//end



//assign  Stride_Complete = (Cnt_Stride_Complete + 1'b1 == 19'd409600)?1'b1:1'b0;
//assign  Img_Last = (Cnt_Stride_Complete + 1'd1 == 19'd409600)?1'b1:1'b0;
    
endmodule