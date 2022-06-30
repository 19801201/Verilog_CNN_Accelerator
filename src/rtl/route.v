`timescale 1ns / 1ps
`include"../Para.v"

module route#(parameter
     CHANNEL_OUT_NUM      =  16,
     WIDTH_CHANNEL_NUM_REG   =  11,
     WIDTH_FEATURE_SIZE  = 12
)(
    input  clk,
    input  rst,
    input  Next_Reg,
    input  Start,
    input  [`AXI_WIDTH_DATA_IN-1:0] S_Data, //256
    input  S_Valid,
    output S_Ready,
    input  [WIDTH_FEATURE_SIZE-1 :0]    Row_Num_Out_REG,    
    input  [WIDTH_CHANNEL_NUM_REG-1 :0] Channel_Out_Num_REG,   
    input  M_Ready,
    output [`AXI_WIDTH_DATA_IN-1:0] M_Data,
    output M_Valid,
    output reg	Route_Complete,
    output Last_Route
    );
    reg  [5:0]  Current_State;
    reg  [5:0]  Next_State; 
    reg  [9:0]  Cnt_Row;
    reg  [9:0]  Cnt_Column; 
    reg  [10:0] Cnt_Cin;
    reg     Valid_Out;
 
    wire Row_Full,EN_Row_Read,EN_Judge_Row,EN_Last_Cin; 
    reg rd_en_fifo;
    wire Write_Ready;
    wire empty;
    
    localparam      Idle_State                = 5'b0_0000;
    localparam      Judge_Fifo_State          = 5'b0_0001;
    localparam      Write_Fifo_State          = 5'b0_0100;
    localparam      Judge_Last_Row_State      = 5'b0_1000;

    wire [WIDTH_CHANNEL_NUM_REG-1'b1:0] Channel_Times,Channel_Times_Out;
    assign Channel_Times      = Channel_Out_Num_REG >> 4;
    assign Channel_Times_Out  = Channel_Times >> 1;
    assign EN_Row_Read        = (Cnt_Column == Row_Num_Out_REG-1'b1 && EN_Last_Cin == 1'b1)?1'b1:1'b0;
    assign EN_Judge_Row       = (Cnt_Row    == Row_Num_Out_REG-1'b1)?1'b1:1'b0;
    assign EN_Last_Cin        = (Cnt_Cin    == Channel_Times-1'b1)?1'b1:1'b0;
    
    wire [`AXI_WIDTH_DATA_IN-1:0] First_dout;
    reg  [`AXI_WIDTH_DATA_IN-1:0] First_dout_temp;
    
    always@(posedge clk)begin
        First_dout_temp <= First_dout;
    end
    
    Route_Read_FIFO  #(                              
            .WIDTH(`AXI_WIDTH_DATA_IN),                                 
            .ADDR_BITS(WIDTH_FEATURE_SIZE-1)                              
    )                                                   
    route_read_fifo                                  
    (                                                   
         .clk(clk),                                     
         .rst(rst),                                     
         .din(S_Data),                               
         .wr_en(S_Valid),                               
         .rd_en(rd_en_fifo),                             
         .dout(First_dout),                                   
         .M_count(Row_Num_Out_REG*Channel_Times),                        
         .M_Ready(Row_Full),         
         .S_count(16),                   
         .S_Ready(S_Ready)        
    );   
    

      always@( posedge clk  )begin    
        if( rst )begin
            Current_State <= Idle_State;
        end
        else begin
            Current_State <= Next_State;
        end
     end
     always @ (*)begin 
        Next_State = Idle_State; //
        case(Current_State)    
           Idle_State: 
                    if(Start==1'b1)
                        Next_State  =  Judge_Fifo_State;     //
                    else 
                        Next_State  =  Idle_State;  
           Judge_Fifo_State:                   
                    if((Row_Full&&empty)==1'b1)
                        Next_State  =  Write_Fifo_State;
                    else 
                        Next_State  =  Judge_Fifo_State;                                          
           Write_Fifo_State:   
                    if(EN_Row_Read==1'b1)     
                        Next_State  =  Judge_Last_Row_State; 
                    else    
                        Next_State  =  Write_Fifo_State;         
           Judge_Last_Row_State:             
                    if(EN_Judge_Row==1'b1)
                        Next_State  =   Idle_State;  
                    else
                        Next_State  =   Judge_Fifo_State; 
           default:     Next_State  =   Idle_State;
        endcase    
    end 
    
    
    always@(posedge clk)begin
        if(rst)begin
            rd_en_fifo <= 1'b0; 
        end
        if(Next_State == Write_Fifo_State)begin
            rd_en_fifo <= 1'b1; 
        end
        else begin
            rd_en_fifo <= 1'b0; 
        end
    end


always@(posedge clk)begin
    if(rst)begin 
        Cnt_Cin <= {11{1'b0}};
    end
    else begin
    case(Current_State) 
        Idle_State:      
            Cnt_Cin <= {11{1'b0}};
        Write_Fifo_State:   
            if(EN_Last_Cin)
                Cnt_Cin <={11{1'b0}};
            else 
                Cnt_Cin <= Cnt_Cin+1'b1;
      default:  Cnt_Cin<=  {11{1'b0}};
      endcase
      end
end

always@(posedge clk)begin
    if(rst) 
        Cnt_Column <= {10{1'b0}};
    else begin
    case(Current_State)
        Idle_State:
            Cnt_Column <= {10{1'b0}};
        Write_Fifo_State:
            if(EN_Last_Cin)
                Cnt_Column <= Cnt_Column+1'b1;
            else 
                Cnt_Column <= Cnt_Column;
        default:Cnt_Column <= {10{1'b0}};
    endcase
    end
end

always@(posedge clk)begin
    if(rst)
        Cnt_Row <= {10{1'b0}};
    else begin
    case(Current_State)
        Idle_State:
             Cnt_Row <= {10{1'b0}};
        Judge_Last_Row_State:
             Cnt_Row <= Cnt_Row + 1'b1; 
        default:
             Cnt_Row <= Cnt_Row;
    endcase
    end
end 
       
always@(posedge clk)begin
    if(rst)
      Valid_Out<=  1'b0;
    else begin
    case(Current_State)
        Idle_State:
            Valid_Out <= 1'b0;
        Write_Fifo_State:
            if (Cnt_Cin >= Channel_Times_Out)begin
                Valid_Out <= 1'b1;
            end
            else begin
                Valid_Out <= 1'b0;
            end
        default:Valid_Out <= 1'b0;
    endcase 
   end   
end    

    
reg [WIDTH_FEATURE_SIZE-1:0]   data_count;
always@(posedge clk)begin
    data_count <=Row_Num_Out_REG*Channel_Times_Out;
end  
    
Route_Write_FIFO  #(
        .WIDTH(`AXI_WIDTH_DATA_IN),
        .ADDR_BITS(WIDTH_FEATURE_SIZE-1)
)
route_write_fifo
(
     .clk(clk),
     .rst(rst),
     .din(First_dout_temp),
     .wr_en(Valid_Out),
     .rd_en(M_Ready&M_Valid),
     .dout(M_Data),
     .M_count(data_count), 
     .M_Ready(),
     .S_count(16),   
     .S_Ready(Write_Ready),
     .empty(empty)
); 
assign M_Valid = !empty;

////////////////////        Last_Logic              /////////////////////////
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Row;
reg		 [WIDTH_FEATURE_SIZE-1:0]	        M_Cnt_Column;
reg      [WIDTH_CHANNEL_NUM_REG-1:0]	    M_Cnt_Cout;

wire                                       M_En_Last_Cout;   
wire                                       M_En_Last_Col;   
wire                                       M_En_Last_Row;   


assign  M_En_Last_Cout = (M_Cnt_Cout + 1'b1 == Channel_Times_Out)?1'b1:1'b0;
assign  M_En_Last_Col = (M_Cnt_Column + 1'b1 == Row_Num_Out_REG)?1'b1:1'b0;
assign  M_En_Last_Row = (M_Cnt_Row + 1'b1 == Row_Num_Out_REG)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst||Next_Reg)
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
    if (rst||Next_Reg)
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
    if (rst||Next_Reg)
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

assign  Last_Route = (M_En_Last_Cout&&M_En_Last_Col&&M_En_Last_Row)?1'b1:1'b0;

always @ (posedge clk) begin 
    if (rst)
       Route_Complete <= 1'b0;
    else if (Last_Route) 
       Route_Complete <= 1'b1;
    else
       Route_Complete <= 1'b0;
end
      
endmodule