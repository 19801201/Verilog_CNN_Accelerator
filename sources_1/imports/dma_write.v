`timescale 1ns / 1ps

module dma_write(
    input clk,
    input rst,
    input start,
    input [31:0]DA_DATA,
    input [31:0]LENGTH_DATA,
    input introut,
    input s_axi_lite_awready,
    input s_axi_lite_wready,
    input [1 : 0]s_axi_lite_bresp,
    input s_axi_lite_bvalid,
    output reg [9:0]s_axi_lite_awaddr,
    output reg [31 : 0] s_axi_lite_wdata,
    output reg s_axi_lite_awvalid,      // input wire s_axi_lite_awvalid
    output reg s_axi_lite_wvalid,               // input wire s_axi_lite_wvalid
    output reg s_axi_lite_bready              // input wire s_axi_lite_bready
);

localparam DMA_CR = 32'h30;
localparam MM2S_SA = 32'h48;
localparam S2MM_DA_MSB = 32'h4C;

localparam MM2S_LENGTH = 32'h58;
localparam MM2S_SR = 32'h34;

localparam CR_DATA = 32'h00011003;  
localparam DA_MSB_DATA = 32'h00000000;
//localparam LENGTH_DATA = 32'h00000010;
localparam SR_DATA = 32'h00011001;
//Custom
reg writing;
reg [3:0]cnt;
reg [2:0]status;
reg clear_int;

always @(posedge clk )
begin
    if(rst)
    begin
        writing <= 1'b0;
    end
    else if(start)
    begin
        writing <= 1'b1;
    end
    else if(status == 3'b011 && cnt == 4'b1010)
    begin
        writing <= 1'b0;
    end
end

always @(posedge clk )
begin
    if(rst)
    begin
        cnt <=4'b0;
    end
    else if(writing || clear_int)
    begin
        if(cnt < 4'b1010)
        begin
            cnt <= cnt+1'b1;
        end
        else
        begin
            cnt <= 4'b0;
        end
    end
    else 
           cnt <=4'b0;
end

always @(posedge clk )
begin
    if(rst)
    begin
        status <=3'b0;
    end
    else if(writing)
    begin
        if(cnt == 4'b1010)
        begin
            if(status < 3'b100)
            begin
                status <= status + 1'b1;
            end
        end
    end
    else
    begin
        status <=3'b0;
    end
end

always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_awaddr<=10'b0;
        s_axi_lite_wdata<=32'b0;
    end
    else if(writing)
    begin
        case(status)
            3'b000:
            begin
                s_axi_lite_awaddr<=DMA_CR;
                s_axi_lite_wdata<=CR_DATA;
            end
            3'b001:
            begin
                s_axi_lite_awaddr<=MM2S_SA;
                s_axi_lite_wdata<=DA_DATA;
            end
             3'b010:
            begin
                s_axi_lite_awaddr<=S2MM_DA_MSB;
                s_axi_lite_wdata<=DA_MSB_DATA;
            end
            3'b011:
            begin
                s_axi_lite_awaddr<=MM2S_LENGTH;
                s_axi_lite_wdata<=LENGTH_DATA;
            end
        endcase
    end
    else if(clear_int)
    begin
        s_axi_lite_awaddr<=MM2S_SR;
        s_axi_lite_wdata<=SR_DATA;
    end
end

always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_awvalid<=1'b0;
    end
    else if(writing || clear_int)
    begin
	    if(cnt == 4'b0)
        begin
			s_axi_lite_awvalid<=1'b1;
        end
        if(s_axi_lite_awready)
        begin
			s_axi_lite_awvalid<=1'b0;
        end
    end
    else
    begin
        s_axi_lite_awvalid<=1'b0;
    end
end

always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_wvalid<=1'b0;
    end
    else if(writing || clear_int)
    begin
	    if(cnt == 4'b0)
        begin
			s_axi_lite_wvalid<=1'b1;
        end
        if(s_axi_lite_wready)
        begin
			s_axi_lite_wvalid<=1'b0;
        end
    end
    else
    begin
        s_axi_lite_wvalid<=1'b0;
    end
end

always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_bready<=1'b0;
    end
    else if(writing || clear_int)
    begin
	    if(cnt == 4'b0)
        begin
			s_axi_lite_bready<=1'b1;
        end
        if(s_axi_lite_bvalid)
        begin
			s_axi_lite_bready<=1'b0;
        end
    end
    else
    begin
        s_axi_lite_bready<=1'b0;
    end
end

//Clear Introut
always @(posedge clk )
begin
    if(rst)
    begin
        clear_int<=1'b0;
    end
    else if(introut)
    begin
	    clear_int<=1'b1;
    end
    else
    begin
        clear_int<=1'b0;
    end
end
endmodule