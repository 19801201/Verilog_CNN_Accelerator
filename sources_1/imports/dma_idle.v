`timescale 1ns / 1ps

module dma_idle(//read idle
    input clk,
    input rst,
    input start,
    //Reading
    input [31:0]s_axi_lite_rdata,
    input s_axi_lite_arready,
    input [1:0]s_axi_lite_rresp,
    input s_axi_lite_rvalid,
    output reg [9:0]s_axi_lite_araddr,
    output reg s_axi_lite_arvalid,
    output reg s_axi_lite_rready,
    output idle
    );

//Custom
reg checking;
reg [3:0]cnt;
reg idle_reg;

assign idle = idle_reg;

always @(posedge clk )
begin
   if(rst)
   begin
       checking <= 1'b0;
   end
   else if(start)
   begin
       checking <= 1'b1;
   end
   else if(idle_reg==1'b1)
   begin
       checking <= 1'b0;
   end
end

always @(posedge clk )
begin
    if(rst)
    begin
        cnt <=4'b0;
    end
    else if(checking)
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
end

always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_araddr<=10'b0;
    end
    else if(checking)
    begin
        s_axi_lite_araddr<=10'h04;//read 6'h04;write  10'h34
    end
end

always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_arvalid<=1'b0;
    end
    else if(checking)
    begin
	    if(cnt == 4'b0)
        begin
			s_axi_lite_arvalid<=1'b1;
        end
        if(s_axi_lite_arready)
        begin
			s_axi_lite_arvalid<=1'b0;
        end
    end
    else
    begin
        s_axi_lite_arvalid<=1'b0;
    end
end

//reg [5:0]s_axi_lite_araddr;
//reg s_axi_lite_arvalid;
//reg s_axi_lite_rready;
always @(posedge clk )
begin
    if(rst)
    begin
        s_axi_lite_rready<=1'b0;
    end
    else if(checking)
    begin
	    if(cnt == 4'b0)
        begin
			s_axi_lite_rready<=1'b1;
        end
        if(s_axi_lite_rvalid)
        begin
			s_axi_lite_rready<=1'b0;
        end
    end
    else
    begin
        s_axi_lite_rready<=1'b0;
    end
end

always @(posedge clk )
begin
   if(rst)
   begin
       idle_reg <= 1'b0;
   end
   else if(checking)
   begin
       if(s_axi_lite_rvalid)
       begin
           if(s_axi_lite_rdata[0:0]==1'b1 || s_axi_lite_rdata[1:0]==2'b10)
           begin
               idle_reg <=1'b1;
           end
           else
           begin
               idle_reg <=1'b0;
           end
       end
   end
   else
   begin
       idle_reg <=1'b0;
   end
end

endmodule
