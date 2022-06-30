`timescale 1ns / 1ps
`include  "../Para.v"

module image_compute_control#(parameter
	WIDTH_FEATURE_SIZE 				= 10,
	WIDTH_RAM_ADDR_SIZE             = 6
)(
	input											clk,
	input											rst,
	input											Start,
	input   [10:0]                                  Row_Num_Out_REG,
	input   [7:0]                                   Channel_Out_Num_REG,
	input											compute_fifo_ready,		// feature fifo 
	input											M_Ready,
	output	reg										Compute_Complete,		// ?????????????   状态机中卷积卷积计算完成标志
	output  										Conv_Complete,     //  卷积计算后数据都输出的标志
	output	reg										rd_en_fifo,				// feature fifo ?????
	output											M_Valid,
	output  reg	[WIDTH_RAM_ADDR_SIZE-1:0]			weight_addrb,
    output 	reg [3:0]								weight_select
    
    );
//============================================
localparam      Idle_State                     = 6'b00_0000;
localparam      Judge_Before_Fifo_State        = 6'b00_0001;
localparam      Judge_After_Fifo_State         = 6'b00_0010;
localparam      Load_Weight_State              = 6'b00_0100;
localparam      Compute_State                  = 6'b00_1000;
localparam      Judge_Row_State                = 6'b01_0000;
//
reg  [5:0] Current_State;
reg  [5:0] Next_State;
wire En_Compute_Column;
wire En_Compute_Row;
reg  [WIDTH_FEATURE_SIZE-1:0]      Cnt_Column ;
reg  [WIDTH_FEATURE_SIZE-1:0]      Cnt_Row ;
wire 							   Load_Weight_Complete;

///  32 层输出通道数，故需要进行4次的  8  出才可以
wire [2:0]   COMPUTE_TIMES_CHANNEL_OUT_REG = Channel_Out_Num_REG >> 3;

// 0: reg  1-32: 权重    33-36：bias     37-40：scale     41-44：shift
assign Load_Weight_Complete=(weight_addrb==44)?1'b1:1'b0;
 ///  输出通道数计数  /// 
reg [2:0]	Cnt_Channel_Out_Num;
assign En_Compute_Column=(Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG)&&(Cnt_Column+1'b1==Row_Num_Out_REG)?1'b1:1'b0;//
assign En_Compute_Row=(Cnt_Row+1'b1== Row_Num_Out_REG)?1'b1:1'b0;//

// --------------------------------------------------------------------------
 always@( posedge clk  )begin  //   
    if( rst )begin
        Current_State <= Idle_State;
    end
    else begin
        Current_State <= Next_State;
    end
 end
 always @ (*)        begin//     
    Next_State = Idle_State; //  
    case(Current_State)    
       Idle_State:
            if( Start==1'b1)
                Next_State   = Load_Weight_State;     //
            else 
                Next_State   =   Idle_State;
        Load_Weight_State:
                if(Load_Weight_Complete)
                    Next_State  =  Judge_Before_Fifo_State;
                else
                    Next_State  =  Load_Weight_State;  
       Judge_Before_Fifo_State:
            if(compute_fifo_ready==1'b1)//
                Next_State   =   Judge_After_Fifo_State;
            else 
                Next_State   =   Judge_Before_Fifo_State; 
       Judge_After_Fifo_State:
            if(M_Ready==1'b1)
                Next_State  =  Compute_State;
            else
                Next_State  =  Judge_After_Fifo_State;                                                        
       Compute_State: 
            if( En_Compute_Column==1'b1 ) //
                Next_State  = Judge_Row_State;   
            else 
                Next_State  = Compute_State;
       Judge_Row_State: 
            if( En_Compute_Row==1'b1 ) //
               Next_State  = Idle_State;
            else 
               Next_State  = Judge_Before_Fifo_State;
       default:Next_State  =    Idle_State;
    endcase    
end 
//==========================
always@( posedge clk  )begin    
   if( rst )
       Cnt_Column <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
       case(Current_State)
          Idle_State:     Cnt_Column <=  {WIDTH_FEATURE_SIZE{1'b0}};
          Compute_State:
          	if(Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG)
            	Cnt_Column <=  Cnt_Column+1;
          	else
             	Cnt_Column <=  Cnt_Column;
          default:
                Cnt_Column <=  {WIDTH_FEATURE_SIZE{1'b0}};
       endcase
   end
end
//==========================
always@( posedge clk  )begin    
	if( rst )
    	Cnt_Channel_Out_Num <=  3'b000;
    else begin
    	case(Current_State)
        	Idle_State:     
            	Cnt_Channel_Out_Num <=  3'b000;
          	Compute_State: 
             	if(Cnt_Channel_Out_Num+1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG)//?????
                  	Cnt_Channel_Out_Num <=   3'b000;
              	else                                                     //?
                  	Cnt_Channel_Out_Num <=  Cnt_Channel_Out_Num+1;              
			default:
        		Cnt_Channel_Out_Num <= 3'b000;
		endcase
	end
end


/////////    此处是为了等待批weight进来进行卷积计算时的逻辑操作，每批进来都要加13个延迟   (因为将权重写死在里面了，所以每一批 (8出)  延迟要手动加)       ///////


always@( posedge clk  )begin    
   if( rst )
       Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
   else begin
      case(Current_State)
        Judge_Row_State:
            Cnt_Row <= Cnt_Row + 1'b1;
        Idle_State:
            Cnt_Row <=  {WIDTH_FEATURE_SIZE{1'b0}};
        default:   Cnt_Row <= Cnt_Row;
      endcase
    end
end
//==========================
always@( posedge clk  )begin    
   if( rst )
       Compute_Complete <=  1'b0;
   else begin
      case(Current_State)
        Idle_State:Compute_Complete <=  1'b0;
        Judge_Row_State:
            if(Next_State==Idle_State)
                 Compute_Complete <=  1'b1;
            else
                 Compute_Complete <=  1'b0;
        default:Compute_Complete <=  1'b0;
      endcase
    end
end
//===============================
//
always@(posedge clk)begin
    if(rst)
      rd_en_fifo <=  1'b0;
    else begin
      case(Current_State)
        Compute_State:   //   
        	if (Cnt_Channel_Out_Num + 1'b1==COMPUTE_TIMES_CHANNEL_OUT_REG)  // 因为 rd_en_fifo 右移个时钟周期延迟，所以当下个时钟周期是0通道的时候，取下一个feature中的数据
             	rd_en_fifo <= 1'b1;
             else
             	rd_en_fifo <= 1'b0;
        default:rd_en_fifo   <=  1'b0;
        endcase          
    end
end
//==================================
always@( posedge clk  )begin  //   
    if( rst )begin
        weight_select <= 4'b0001;
        end
    else begin
    	case (Cnt_Channel_Out_Num)
    		3'b000:
    			weight_select <= 4'b0001;
    		3'b001:
    			weight_select <= 4'b0010;
    		3'b010:
    			weight_select <= 4'b0100;
    		3'b011:
    			weight_select <= 4'b1000;
    		default:
    			weight_select <= 4'b0001;
    	endcase
    end
end


always@( posedge clk  )begin    
	if( rst )
    	weight_addrb <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
    else begin
    	case(Current_State)
        	Idle_State:  
            	weight_addrb <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
        	Load_Weight_State:          
             	weight_addrb <= weight_addrb+1;
       		default:    
            	weight_addrb <= {WIDTH_RAM_ADDR_SIZE{1'b0}};
      	endcase
    end
end



reg M_Fifo_Valid[0:25];
always@( posedge clk  )begin    
	if( rst )
    	M_Fifo_Valid[0] <=  1'b0;
    else begin
    	case(Current_State)
        	Compute_State:begin
            	M_Fifo_Valid[0]<=  1'b1;
        	end
      		default:    M_Fifo_Valid[0] <=  1'b0;
      	endcase
	end
end


generate
genvar i;
	for(i=0;i<23;i=i+1)begin
    	always@(posedge clk)begin
        	M_Fifo_Valid[i+1]<=M_Fifo_Valid[i];
   		end   
  	end
endgenerate




///     13 + 1 个延迟 M_Valid , 乘法器3个延迟，4个加法器每个2个延迟，调整位宽1个延迟，权重赋值逻辑1个延迟 ， + 1 个延迟 总计 14 个延迟
assign M_Valid = M_Fifo_Valid[14];


///////////        设置卷积计算完成的标志   /////////
reg	[15:0]	Conv_Final_Complete;

always @ (posedge clk ) begin 
	if (rst)
		Conv_Final_Complete[0] <= 1'b0;
	else
		Conv_Final_Complete[0] <= Compute_Complete;
end

generate
genvar j;
	for(i=0;i<14;i=i+1)begin
    	always@(posedge clk)begin
        	Conv_Final_Complete[i+1]<=Conv_Final_Complete[i];
   		end   
  	end
endgenerate  

assign	Conv_Complete = Conv_Final_Complete[13];

endmodule 
