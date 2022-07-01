`timescale 1ns / 1ps

module top(
    input sys_clk,
    input pcie_rst_n,
    
    // DDR
    output C0_DDR4_0_act_n,
    output [16:0]C0_DDR4_0_adr,
    output [1:0]C0_DDR4_0_ba,
    output [0:0]C0_DDR4_0_bg,
    output [0:0]C0_DDR4_0_ck_c,
    output [0:0]C0_DDR4_0_ck_t,
    output [0:0]C0_DDR4_0_cke,
    output [0:0]C0_DDR4_0_cs_n,
    inout [7:0]C0_DDR4_0_dm_n,
    inout [63:0]C0_DDR4_0_dq,
    inout [7:0]C0_DDR4_0_dqs_c,
    inout [7:0]C0_DDR4_0_dqs_t,
    output [0:0]C0_DDR4_0_odt,
    output C0_DDR4_0_reset_n,
    input C0_SYS_CLK_0_clk_n,
    input C0_SYS_CLK_0_clk_p,
    
    input  [7:0]pcie_mgt_rxn,
    input  [7:0]pcie_mgt_rxp,
    output [7:0]pcie_mgt_txn,
    output [7:0]pcie_mgt_txp,
    
    input pcie_diff_clock_clk_p,
    input pcie_diff_clock_clk_n
    );

wire clk_out_125;
wire clk_out_250;
wire [0:0]tjpu_rst;
wire c0_init_calib_complete;

////////  TJPU  write  read   data
wire    [255:0]Concat_READ_DATA_tdata;
wire    [31:0]Concat_READ_DATA_tkeep;
wire    Concat_READ_DATA_tlast;
wire    Concat_READ_DATA_tready;
wire    Concat_READ_DATA_tvalid;
wire    [63:0]Concat_READ_DMA_CMD;
wire    Concat_READ_DMA_Valid;
wire    [255:0]Conv_READ_DATA_tdata;
wire    [31:0]Conv_READ_DATA_tkeep;
wire    Conv_READ_DATA_tlast;
wire    Conv_READ_DATA_tready;
wire    Conv_READ_DATA_tvalid;
wire    [63:0]Conv_READ_DMA_CMD;
wire    Conv_READ_DMA_Valid;
wire    [255:0]Conv_WRITE_DATA_tdata;
wire    [31:0]Conv_WRITE_DATA_tkeep;
wire    Conv_WRITE_DATA_tlast;
wire    Conv_WRITE_DATA_tready;
wire    Conv_WRITE_DATA_tvalid;
wire    [63:0]Conv_WRITE_DMA_CMD;
wire    Conv_WRITE_DMA_Valid;

wire    concat_read_introut;
wire    conv_read_introut;
wire    conv_write_introut;
  
//////     reg  
wire    image_control_strobe_0;
wire    [31:0]image_control_value_0;
wire    image_read_introut;
wire    image_reg0_strobe_0;
wire    [31:0]image_reg0_value_0;
wire    image_reg1_strobe_0;
wire    [31:0]image_reg1_value_0;
wire    image_state_strobe_0;
wire    [3:0]image_state;
wire    [3:0]State_3_3;
wire    [3:0]State_1_1;
wire    [3:0]State_RE;
wire    image_write_introut;

wire   [3:0]tjpu_control_conv2d_0;
wire   [3:0]tjpu_control_pw_0;
wire   [7:0]tjpu_control_reshape_0;
wire   tjpu_control_strobe_0;
wire   tjpu_dma_read_addr_strobe_0;
wire   [31:0]tjpu_dma_read_addr_value_0;
wire   tjpu_dma_read_num_strobe_0;
wire   [31:0]tjpu_dma_read_num_value_0;
wire   tjpu_dma_write_addr_strobe_0;
wire   [31:0]tjpu_dma_write_addr_value_0;
wire   tjpu_dma_write_num_strobe_0;
wire   [31:0]tjpu_dma_write_num_value_0;
wire   tjpu_reg4_strobe_0;
wire   [31:0]tjpu_reg4_value_0;
wire   tjpu_reg5_strobe_0;
wire   [31:0]tjpu_reg5_value_0;
wire   tjpu_reg6_strobe_0;
wire   [31:0]tjpu_reg6_value_0;
wire   tjpu_reg7_strobe_0;
wire   [31:0]tjpu_reg7_value_0;
wire   tjpu_reg8_strobe_0;
wire   [31:0]tjpu_reg8_value_0;
wire   tjpu_reg9_strobe_0;
wire   [31:0]tjpu_reg9_value_0;
wire  [3:0]tjpu_state_conv2d_0;
wire  [3:0]tjpu_state_pw_0;
wire  [7:0]tjpu_state_reshape_0;
wire   tjpu_state_strobe_0;
wire   tjpu_switch_strobe_0;
wire   [31:0]tjpu_switch_value_0;

wire TJPU_READ_DMA_Valid,TJPU_WRITE_DMA_Valid;
wire [255:0] S_Data,S_Data_Middle,M_Data,M_Data_Middle,T_Data;
wire S_Valid,S_Valid_Middle,M_Valid,M_Valid_Middle,T_Valid;
wire S_Ready,S_Ready_Middle,M_Ready,M_Ready_Middle,T_Ready;
wire Tlast,T_Last_Middle;

wire Read_DDR_REG,Write_DDR_REG,Weight_Read_REG;
TJPU TJPU(
    .clk                 (clk_out_250),
    .rst                 (tjpu_rst),
    .Control_3_3         (tjpu_control_conv2d_0[3:0]),
    .State_3_3           (State_3_3),
    .Control_1_1         (tjpu_control_pw_0[3:0]),
    .State_1_1           (State_1_1),
    .Control_RE          (tjpu_control_reshape_0[3:0]),
    .State_RE            (State_RE),
    .Switch              (tjpu_switch_value_0[3:0]),
    .Reg_4               (tjpu_reg4_value_0),
    .Reg_5               (tjpu_reg5_value_0),
    .Reg_6               (tjpu_reg6_value_0),
    .Reg_7               (tjpu_reg7_value_0),
    .Reg_8               (tjpu_reg8_value_0),
    .Reg_9               (tjpu_reg9_value_0),
    .Read_DDR_REG        (Read_DDR_REG),
    .Write_DDR_REG       (Write_DDR_REG),
    .Weight_Read_REG     (Weight_Read_REG),
    .DMA_Read_Start      (TJPU_READ_DMA_Valid),
    .DMA_Write_Start     (TJPU_WRITE_DMA_Valid),
    .DMA_Read_Start_2    (Concat_READ_DMA_Valid),
    .S_Data              (S_Data),
    .S_Valid             (S_Valid),
    .S_Ready             (S_Ready),
    .S_Data_1            (Concat_READ_DATA_tdata),
    .S_Valid_1           (Concat_READ_DATA_tvalid),
    .S_Ready_1           (Concat_READ_DATA_tready),
    .M_Data              (M_Data),
    .M_Ready             (M_Ready),
    .M_Valid             (M_Valid),
    .Tlast               (Tlast),
    .introut_3x3_Wr      (conv_write_introut)
); 

// TJPU's input port 
assign S_Data  = (Read_DDR_REG || Weight_Read_REG) ? Conv_READ_DATA_tdata : M_Data_Middle;
assign S_Valid = (Read_DDR_REG || Weight_Read_REG) ? Conv_READ_DATA_tvalid : M_Valid_Middle;
assign Conv_READ_DATA_tready = (Read_DDR_REG || Weight_Read_REG) ? S_Ready : 1'b0;
assign M_Ready_Middle        = (Read_DDR_REG || Weight_Read_REG) ? 1'b0 : S_Ready;
assign Conv_READ_DMA_Valid   = (Read_DDR_REG || Weight_Read_REG) ? TJPU_READ_DMA_Valid : 1'b0;

// TJPU's output port 
assign M_Ready = Write_DDR_REG ? Conv_WRITE_DATA_tready : S_Ready_Middle;
assign S_Data_Middle         = Write_DDR_REG ? 256'b0 : M_Data;
assign Conv_WRITE_DATA_tdata = Write_DDR_REG ? M_Data : 256'b0;
assign S_Valid_Middle        = Write_DDR_REG ? 1'b0 : M_Valid;
assign Conv_WRITE_DATA_tvalid= Write_DDR_REG ? M_Valid : 1'b0;
assign Conv_WRITE_DATA_tkeep = Write_DDR_REG ? 32'hffff_ffff : 32'h0;
assign Conv_WRITE_DMA_Valid  = Write_DDR_REG ? TJPU_WRITE_DMA_Valid : 1'b0;
assign T_Last_Middle         = Write_DDR_REG ? 1'b0 : Tlast;
assign Conv_WRITE_DATA_tlast = Write_DDR_REG ? Tlast : 1'b0;

Out_Buffer Out_Buffer(
    .clk                (clk_out_250),
    .rst                (tjpu_rst),
    .S_Data             (S_Data_Middle ),
    .S_Valid            (S_Valid_Middle),
    .S_Ready            (S_Ready_Middle),
    .M_Data             (T_Data),
    .M_Ready            (T_Ready),
    .M_Valid            (T_Valid),
    .Last               (T_Last_Middle)
);

In_Buffer In_Buffer(
    .clk                (clk_out_250),
    .rst                (tjpu_rst),
    .S_Data             (T_Data),
    .S_Valid            (T_Valid),
    .S_Ready            (T_Ready),
    .M_Data             (M_Data_Middle ),
    .M_Ready            (M_Ready_Middle),
    .M_Valid            (M_Valid_Middle)
);

system_wrapper system_wrapper(
    .C0_DDR4_0_act_n                (C0_DDR4_0_act_n   ),
    .C0_DDR4_0_adr                  (C0_DDR4_0_adr     ),
    .C0_DDR4_0_ba                   (C0_DDR4_0_ba      ),
    .C0_DDR4_0_bg                   (C0_DDR4_0_bg      ),
    .C0_DDR4_0_ck_c                 (C0_DDR4_0_ck_c    ),
    .C0_DDR4_0_ck_t                 (C0_DDR4_0_ck_t    ),
    .C0_DDR4_0_cke                  (C0_DDR4_0_cke     ),
    .C0_DDR4_0_cs_n                 (C0_DDR4_0_cs_n    ),
    .C0_DDR4_0_dm_n                 (C0_DDR4_0_dm_n    ),
    .C0_DDR4_0_dq                   (C0_DDR4_0_dq      ),
    .C0_DDR4_0_dqs_c                (C0_DDR4_0_dqs_c   ),
    .C0_DDR4_0_dqs_t                (C0_DDR4_0_dqs_t   ),
    .C0_DDR4_0_odt                  (C0_DDR4_0_odt     ),
    .C0_DDR4_0_reset_n              (C0_DDR4_0_reset_n ),
    .C0_SYS_CLK_0_clk_n             (C0_SYS_CLK_0_clk_n),
    .C0_SYS_CLK_0_clk_p             (C0_SYS_CLK_0_clk_p),
    // *******************   TJPU 
    .Concat_READ_DATA_tdata         (Concat_READ_DATA_tdata ),
    .Concat_READ_DATA_tkeep         (Concat_READ_DATA_tkeep ),
    .Concat_READ_DATA_tlast         (Concat_READ_DATA_tlast ),
    .Concat_READ_DATA_tready        (Concat_READ_DATA_tready),
    .Concat_READ_DATA_tvalid        (Concat_READ_DATA_tvalid),
    .Concat_READ_DMA_CMD            ({image_reg0_value_0,image_reg1_value_0}),
    .Concat_READ_DMA_Valid          (Concat_READ_DMA_Valid  ),
    .Conv_READ_DATA_tdata           (Conv_READ_DATA_tdata   ),
    .Conv_READ_DATA_tkeep           (Conv_READ_DATA_tkeep   ),
    .Conv_READ_DATA_tlast           (Conv_READ_DATA_tlast   ),
    .Conv_READ_DATA_tready          (Conv_READ_DATA_tready  ),
    .Conv_READ_DATA_tvalid          (Conv_READ_DATA_tvalid  ),
    .Conv_READ_DMA_CMD              ({tjpu_dma_read_addr_value_0,tjpu_dma_read_num_value_0}),
    .Conv_READ_DMA_Valid            (Conv_READ_DMA_Valid    ),
    .Conv_WRITE_DATA_tdata          (Conv_WRITE_DATA_tdata  ),
    .Conv_WRITE_DATA_tkeep          (Conv_WRITE_DATA_tkeep  ),/////////
    .Conv_WRITE_DATA_tlast          (Conv_WRITE_DATA_tlast  ),
    .Conv_WRITE_DATA_tready         (Conv_WRITE_DATA_tready ),
    .Conv_WRITE_DATA_tvalid         (Conv_WRITE_DATA_tvalid ),
    .Conv_WRITE_DMA_CMD             ({tjpu_dma_write_addr_value_0,tjpu_dma_write_num_value_0}),
    .Conv_WRITE_DMA_Valid           (Conv_WRITE_DMA_Valid   ),
//    // *******************   image
//    .IMAGE_READ_DATA_tdata          (IMAGE_READ_DATA_tdata  ),
//    .IMAGE_READ_DATA_tkeep          (IMAGE_READ_DATA_tkeep  ),
//    .IMAGE_READ_DATA_tlast          (IMAGE_READ_DATA_tlast  ),
//    .IMAGE_READ_DATA_tready         (IMAGE_READ_DATA_tready ),
//    .IMAGE_READ_DATA_tvalid         (IMAGE_READ_DATA_tvalid ),
////    .IMAGE_READ_DMA_CMD             (IMAGE_READ_DMA_CMD     ),
//    .IMAGE_READ_DMA_CMD             ({tjpu_dma_read_addr_value_0,tjpu_dma_read_num_value_0}),
//    .IMAGE_READ_DMA_Valid           (IMAGE_READ_DMA_Valid   ),
//    .IMAGE_WRITE_DATA_tdata         (IMAGE_WRITE_DATA_tdata ),
//    .IMAGE_WRITE_DATA_tkeep         (IMAGE_WRITE_DATA_tkeep ),
//    .IMAGE_WRITE_DATA_tlast         (IMAGE_WRITE_DATA_tlast ),
//    .IMAGE_WRITE_DATA_tready        (IMAGE_WRITE_DATA_tready),
//    .IMAGE_WRITE_DATA_tvalid        (IMAGE_WRITE_DATA_tvalid),
////    .IMAGE_WRITE_DMA_CMD            (IMAGE_WRITE_DMA_CMD    ),
//    .IMAGE_WRITE_DMA_CMD            ({tjpu_dma_write_addr_value_0,tjpu_dma_write_num_value_0}),
//    .IMAGE_WRITE_DMA_Valid          (IMAGE_WRITE_DMA_Valid  ),
    .c0_init_calib_complete         (c0_init_calib_complete ),
    .sys_clk                        (sys_clk),
    .clk_out_125                    (clk_out_125),
    .clk_out_250                    (clk_out_250),
    .ddr_sys_rst                    (1'b0),
    .tjpu_rst                       (tjpu_rst),
    .concat_read_introut            (concat_read_introut),
    .conv_read_introut              (conv_read_introut),
    .conv_write_introut             (conv_write_introut),
//    .image_control_strobe_0         (image_control_strobe_0),
//    .image_control_value_0          (image_control_value_0 ),
//    .image_read_introut             (image_read_introut    ),
    .image_reg0_strobe_0            (image_reg0_strobe_0   ),
    .image_reg0_value_0             (image_reg0_value_0    ),
    .image_reg1_strobe_0            (image_reg1_strobe_0   ),
    .image_reg1_value_0             (image_reg1_value_0    ),
//    .image_state_strobe_0           (image_state_strobe_0  ),
//    .image_state_value              ({{28{1'b0}},image_state}),
//    .image_write_introut            (image_write_introut   ),
    
    .pcie_cfg_mgmt_addr             (19'h0 ),
    .pcie_cfg_mgmt_byte_en          (4'h0  ),
    .pcie_cfg_mgmt_read_data        (      ),
    .pcie_cfg_mgmt_read_en          (1'h0  ),
    .pcie_cfg_mgmt_read_write_done  (      ),
    .pcie_cfg_mgmt_write_data       (32'h0 ),
    .pcie_cfg_mgmt_write_en         (1'h0  ),
    
    .pcie_diff_clock_clk_n          (pcie_diff_clock_clk_n ),
    .pcie_diff_clock_clk_p          (pcie_diff_clock_clk_p ),
    .pcie_mgt_rxn                   (pcie_mgt_rxn),
    .pcie_mgt_rxp                   (pcie_mgt_rxp),
    .pcie_mgt_txn                   (pcie_mgt_txn),
    .pcie_mgt_txp                   (pcie_mgt_txp),
    .pcie_rst_n                     (pcie_rst_n),
    .tjpu_control_conv2d_0          (tjpu_control_conv2d_0       ),
    .tjpu_control_pw_0              (tjpu_control_pw_0           ),
    .tjpu_control_reshape_0         (tjpu_control_reshape_0      ),
    .tjpu_control_strobe_0          (tjpu_control_strobe_0       ),
    .tjpu_dma_read_addr_strobe_0    (tjpu_dma_read_addr_strobe_0 ),
    .tjpu_dma_read_addr_value_0     (tjpu_dma_read_addr_value_0  ),
    .tjpu_dma_read_num_strobe_0     (tjpu_dma_read_num_strobe_0  ),
    .tjpu_dma_read_num_value_0      (tjpu_dma_read_num_value_0   ),
    .tjpu_dma_write_addr_strobe_0   (tjpu_dma_write_addr_strobe_0),
    .tjpu_dma_write_addr_value_0    (tjpu_dma_write_addr_value_0 ),
    .tjpu_dma_write_num_strobe_0    (tjpu_dma_write_num_strobe_0 ),
    .tjpu_dma_write_num_value_0     (tjpu_dma_write_num_value_0  ),
    .tjpu_reg4_strobe_0             (tjpu_reg4_strobe_0          ),
    .tjpu_reg4_value_0              (tjpu_reg4_value_0           ),
    .tjpu_reg5_strobe_0             (tjpu_reg5_strobe_0          ),
    .tjpu_reg5_value_0              (tjpu_reg5_value_0           ),
    .tjpu_reg6_strobe_0             (tjpu_reg6_strobe_0          ),
    .tjpu_reg6_value_0              (tjpu_reg6_value_0           ),
    .tjpu_reg7_strobe_0             (tjpu_reg7_strobe_0          ),
    .tjpu_reg7_value_0              (tjpu_reg7_value_0           ),
    .tjpu_reg8_strobe_0             (tjpu_reg8_strobe_0          ),
    .tjpu_reg8_value_0              (tjpu_reg8_value_0           ),
    .tjpu_reg9_strobe_0             (tjpu_reg9_strobe_0          ),
    .tjpu_reg9_value_0              (tjpu_reg9_value_0           ),
    .tjpu_state_conv2d              ({{28{1'b0}},State_3_3}),
    .tjpu_state_pw                  ({{28{1'b0}},State_1_1}),
    .tjpu_state_reshape             ({{28{1'b0}},State_RE}),
    .tjpu_state_strobe_0            (tjpu_state_strobe_0         ),
    .tjpu_switch_strobe_0           (tjpu_switch_strobe_0        ),
    .tjpu_switch_value_0            (tjpu_switch_value_0         )
);

endmodule
