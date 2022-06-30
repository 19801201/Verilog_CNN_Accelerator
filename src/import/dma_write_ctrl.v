`timescale 1ns / 1ps

module dma_write_ctrl(
    input clk,
    input rst,
    input introut,
    input [63:0]W_DMA_CMD,
    input W_DMA_Valid,
    //Write
    input s_axi_lite_awready,
    input s_axi_lite_wready,
    input [1 : 0]s_axi_lite_bresp,
    input s_axi_lite_bvalid,
    //Read
    input [31:0]s_axi_lite_rdata,
    input  s_axi_lite_arready,
    input  [1:0]s_axi_lite_rresp,
    input  s_axi_lite_rvalid,
    //Write
    output [9:0]s_axi_lite_awaddr,
    output [31 : 0] s_axi_lite_wdata,
    output s_axi_lite_awvalid,      // input wire s_axi_lite_awvalid
    output s_axi_lite_wvalid,               // input wire s_axi_lite_wvalid
    output s_axi_lite_bready,              // input wire s_axi_lite_bready
    //Read
    output [9:0]s_axi_lite_araddr,
    output s_axi_lite_arvalid,
    output s_axi_lite_rready,
    output reg [31:0]BYTE_TRANSPORT
    );

reg [31:0]DA_DATA;
reg [31:0]LENGTH_DATA;
wire idle;
reg start;
always @(posedge clk)begin
    if(rst)begin
        DA_DATA <= 32'd0;
        LENGTH_DATA <= 32'd0;
        BYTE_TRANSPORT <= 32'd0;
        start <= 1'b0;
    end else if(W_DMA_Valid == 1'b1)begin 
        DA_DATA <= W_DMA_CMD[63:32];
        LENGTH_DATA <=  W_DMA_CMD[31:0];
        BYTE_TRANSPORT <= {4'b0000,LENGTH_DATA[31:4]};
        start <= 1'b1;
    end else begin
        DA_DATA <= DA_DATA;
        LENGTH_DATA <= LENGTH_DATA;
        BYTE_TRANSPORT <= BYTE_TRANSPORT;
        start <= 1'b0;
    end
end
//assign DA_DATA =  W_DMA_Valid == 1'b1 ? W_DMA_CMD[63:32] : DA_DATA;
//assign LENGTH_DATA =  W_DMA_Valid == 1'b1 ? W_DMA_CMD[31:0] : LENGTH_DATA;
//assign BYTE_TRANSPORT =  W_DMA_Valid == 1'b1 ? {4'b0000,LENGTH_DATA[31:4]} : BYTE_TRANSPORT;

dma_write_idle check(
    .clk(clk),
    .rst(rst),
    .start(start),
    //Reading
    .s_axi_lite_rdata(s_axi_lite_rdata),
    .s_axi_lite_arready(s_axi_lite_arready),
    .s_axi_lite_rresp(s_axi_lite_rresp),
    .s_axi_lite_rvalid(s_axi_lite_rvalid),
    .s_axi_lite_araddr(s_axi_lite_araddr),
    .s_axi_lite_arvalid(s_axi_lite_arvalid),
    .s_axi_lite_rready(s_axi_lite_rready),
    .idle(idle)
      );
      
dma_write SS2M_DMA(
    .clk(clk),
    .rst(rst),
    .start(idle),
    .DA_DATA(DA_DATA),//Need Edit
    .LENGTH_DATA(LENGTH_DATA),//Need Edit
    .introut(introut),
    .s_axi_lite_awready(s_axi_lite_awready),
    .s_axi_lite_wready(s_axi_lite_wready),
    .s_axi_lite_bresp(s_axi_lite_bresp),
    .s_axi_lite_bvalid(s_axi_lite_bvalid),
    .s_axi_lite_awaddr(s_axi_lite_awaddr),
    .s_axi_lite_wdata(s_axi_lite_wdata),
    .s_axi_lite_awvalid(s_axi_lite_awvalid),      // input wire s_axi_lite_awvalid
    .s_axi_lite_wvalid(s_axi_lite_wvalid),             // input wire s_axi_lite_wvalid
    .s_axi_lite_bready(s_axi_lite_bready)              // input wire s_axi_lite_bready
);

endmodule
