-- -----------------------------------------------------------------------------
-- 'Yolo_v4' Register Component
-- Revision: 105
-- -----------------------------------------------------------------------------
-- Generated on 2021-05-23 at 03:22 (UTC) by airhdl version 2021.05.1
-- -----------------------------------------------------------------------------
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Yolo_v4_regs_pkg.all;

entity Yolo_v4_regs is
    generic(
        AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address bus
        BASEADDR : std_logic_vector(31 downto 0) := x"00000000" -- the register file's system base address
    );
    port(
        -- Clock and Reset
        axi_aclk    : in  std_logic;
        axi_aresetn : in  std_logic;
        -- AXI Write Address Channel
        s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_awprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
        s_axi_awvalid : in  std_logic;
        s_axi_awready : out std_logic;
        -- AXI Write Data Channel
        s_axi_wdata   : in  std_logic_vector(31 downto 0);
        s_axi_wstrb   : in  std_logic_vector(3 downto 0);
        s_axi_wvalid  : in  std_logic;
        s_axi_wready  : out std_logic;
        -- AXI Read Address Channel
        s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_arprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
        s_axi_arvalid : in  std_logic;
        s_axi_arready : out std_logic;
        -- AXI Read Data Channel
        s_axi_rdata   : out std_logic_vector(31 downto 0);
        s_axi_rresp   : out std_logic_vector(1 downto 0);
        s_axi_rvalid  : out std_logic;
        s_axi_rready  : in  std_logic;
        -- AXI Write Response Channel
        s_axi_bresp   : out std_logic_vector(1 downto 0);
        s_axi_bvalid  : out std_logic;
        s_axi_bready  : in  std_logic;
        -- User Ports
        -- user2regs     : in user2regs_t;
        -- regs2user     : out regs2user_t
		image_state_value : in std_logic_vector(31 downto 0); -- value of register 'Image_State', field 'value'
        tjpu_state_conv2d : in std_logic_vector(3 downto 0); -- value of register 'TJPU_State', field 'Conv2d'
        tjpu_state_pw :  in std_logic_vector(3 downto 0); -- value of register 'TJPU_State', field 'PW'
        tjpu_state_reshape : in std_logic_vector(7 downto 0); -- value of register 'TJPU_State', field 'Reshape'
		
		image_control_strobe : 		out std_logic; -- Strobe signal for register 'Image_Control' (pulsed when the register is written from the bus}
        image_control_value : 		out std_logic_vector(31 downto 0); -- Value of register 'Image_Control', field 'value'
        image_state_strobe : 		out std_logic; -- Strobe signal for register 'Image_State' (pulsed when the register is read from the bus}
        image_reg0_strobe : 		out std_logic; -- Strobe signal for register 'Image_Reg0' (pulsed when the register is written from the bus}
        image_reg0_value : 			out std_logic_vector(31 downto 0); -- Value of register 'Image_Reg0', field 'value'
        image_reg1_strobe : 		out std_logic; -- Strobe signal for register 'Image_Reg1' (pulsed when the register is written from the bus}
        image_reg1_value : 			out std_logic_vector(31 downto 0); -- Value of register 'Image_Reg1', field 'value'
        tjpu_control_strobe : 		out std_logic; -- Strobe signal for register 'TJPU_Control' (pulsed when the register is written from the bus}
        tjpu_control_conv2d : 		out std_logic_vector(3 downto 0); -- Value of register 'TJPU_Control', field 'Conv2d'
        tjpu_control_pw : 			out std_logic_vector(3 downto 0); -- Value of register 'TJPU_Control', field 'PW'
        tjpu_control_reshape : 		out std_logic_vector(7 downto 0); -- Value of register 'TJPU_Control', field 'Reshape'
        tjpu_state_strobe : 		out std_logic; -- Strobe signal for register 'TJPU_State' (pulsed when the register is read from the bus}
        tjpu_switch_strobe : 		out std_logic; -- Strobe signal for register 'TJPU_Switch' (pulsed when the register is written from the bus}
        tjpu_switch_value : 		out std_logic_vector(31 downto 0); -- Value of register 'TJPU_Switch', field 'value'
        tjpu_dma_read_addr_strobe : out std_logic; -- Strobe signal for register 'TJPU_DMA_Read_Addr' (pulsed when the register is written from the bus}
        tjpu_dma_read_addr_value : 	out std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Read_Addr', field 'value'
        tjpu_dma_read_num_strobe :  out std_logic; -- Strobe signal for register 'TJPU_DMA_Read_Num' (pulsed when the register is written from the bus}
        tjpu_dma_read_num_value :   out std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Read_Num', field 'value'
        tjpu_dma_write_addr_strobe :out std_logic; -- Strobe signal for register 'TJPU_DMA_Write_Addr' (pulsed when the register is written from the bus}
        tjpu_dma_write_addr_value : out std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Write_Addr', field 'value'
        tjpu_dma_write_num_strobe : out std_logic; -- Strobe signal for register 'TJPU_DMA_Write_Num' (pulsed when the register is written from the bus}
        tjpu_dma_write_num_value :  out std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Write_Num', field 'value'
        tjpu_reg4_strobe : 			out std_logic; -- Strobe signal for register 'TJPU_Reg4' (pulsed when the register is written from the bus}
        tjpu_reg4_value : 			out std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg4', field 'value'
        tjpu_reg5_strobe : 			out std_logic; -- Strobe signal for register 'TJPU_Reg5' (pulsed when the register is written from the bus}
        tjpu_reg5_value : 			out std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg5', field 'value'
        tjpu_reg6_strobe : 			out std_logic; -- Strobe signal for register 'TJPU_Reg6' (pulsed when the register is written from the bus}
        tjpu_reg6_value : 			out std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg6', field 'value'
        tjpu_reg7_strobe : 			out std_logic; -- Strobe signal for register 'TJPU_Reg7' (pulsed when the register is written from the bus}
        tjpu_reg7_value : 			out std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg7', field 'value'
        tjpu_reg8_strobe : 			out std_logic; -- Strobe signal for register 'TJPU_Reg8' (pulsed when the register is written from the bus}
        tjpu_reg8_value : 			out std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg8', field 'value'
        tjpu_reg9_strobe : 			out std_logic; -- Strobe signal for register 'TJPU_Reg9' (pulsed when the register is written from the bus}
        tjpu_reg9_value : 			out std_logic_vector(31 downto 0) -- Value of register 'TJPU_Reg9', field 'value'
    );
end entity Yolo_v4_regs;

architecture RTL of Yolo_v4_regs is

    -- Constants
    constant AXI_OKAY           : std_logic_vector(1 downto 0) := "00";
    constant AXI_DECERR         : std_logic_vector(1 downto 0) := "11";

    -- Registered signals
    signal s_axi_awready_r    : std_logic;
    signal s_axi_wready_r     : std_logic;
    signal s_axi_awaddr_reg_r : unsigned(s_axi_awaddr'range);
    signal s_axi_bvalid_r     : std_logic;
    signal s_axi_bresp_r      : std_logic_vector(s_axi_bresp'range);
    signal s_axi_arready_r    : std_logic;
    signal s_axi_araddr_reg_r : unsigned(AXI_ADDR_WIDTH - 1 downto 0);
    signal s_axi_rvalid_r     : std_logic;
    signal s_axi_rresp_r      : std_logic_vector(s_axi_rresp'range);
    signal s_axi_wdata_reg_r  : std_logic_vector(s_axi_wdata'range);
    signal s_axi_wstrb_reg_r  : std_logic_vector(s_axi_wstrb'range);
    signal s_axi_rdata_r      : std_logic_vector(s_axi_rdata'range);

    -- User-defined registers
    signal s_image_control_strobe_r : std_logic;
    signal s_reg_image_control_value_r : std_logic_vector(31 downto 0);
    signal s_image_state_strobe_r : std_logic;
    signal s_reg_image_state_value : std_logic_vector(31 downto 0);
    signal s_image_reg0_strobe_r : std_logic;
    signal s_reg_image_reg0_value_r : std_logic_vector(31 downto 0);
    signal s_image_reg1_strobe_r : std_logic;
    signal s_reg_image_reg1_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_control_strobe_r : std_logic;
    signal s_reg_tjpu_control_conv2d_r : std_logic_vector(3 downto 0);
    signal s_reg_tjpu_control_pw_r : std_logic_vector(3 downto 0);
    signal s_reg_tjpu_control_reshape_r : std_logic_vector(7 downto 0);
    signal s_tjpu_state_strobe_r : std_logic;
    signal s_reg_tjpu_state_conv2d : std_logic_vector(3 downto 0);
    signal s_reg_tjpu_state_pw : std_logic_vector(3 downto 0);
    signal s_reg_tjpu_state_reshape : std_logic_vector(7 downto 0);
    signal s_tjpu_switch_strobe_r : std_logic;
    signal s_reg_tjpu_switch_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_dma_read_addr_strobe_r : std_logic;
    signal s_reg_tjpu_dma_read_addr_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_dma_read_num_strobe_r : std_logic;
    signal s_reg_tjpu_dma_read_num_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_dma_write_addr_strobe_r : std_logic;
    signal s_reg_tjpu_dma_write_addr_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_dma_write_num_strobe_r : std_logic;
    signal s_reg_tjpu_dma_write_num_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_reg4_strobe_r : std_logic;
    signal s_reg_tjpu_reg4_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_reg5_strobe_r : std_logic;
    signal s_reg_tjpu_reg5_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_reg6_strobe_r : std_logic;
    signal s_reg_tjpu_reg6_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_reg7_strobe_r : std_logic;
    signal s_reg_tjpu_reg7_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_reg8_strobe_r : std_logic;
    signal s_reg_tjpu_reg8_value_r : std_logic_vector(31 downto 0);
    signal s_tjpu_reg9_strobe_r : std_logic;
    signal s_reg_tjpu_reg9_value_r : std_logic_vector(31 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Inputs
    --
    s_reg_image_state_value <= image_state_value;
    s_reg_tjpu_state_conv2d <= tjpu_state_conv2d;
    s_reg_tjpu_state_pw <= tjpu_state_pw;
    s_reg_tjpu_state_reshape <= tjpu_state_reshape;

    ----------------------------------------------------------------------------
    -- Read-transaction FSM
    --
    read_fsm : process(axi_aclk, axi_aresetn) is
        constant MAX_MEMORY_LATENCY : natural := 5;
        type t_state is (IDLE, READ_REGISTER, WAIT_MEMORY_RDATA, READ_RESPONSE, DONE);
        -- registered state variables
        variable v_state_r          : t_state;
        variable v_rdata_r          : std_logic_vector(31 downto 0);
        variable v_rresp_r          : std_logic_vector(s_axi_rresp'range);
        variable v_mem_wait_count_r : natural range 0 to MAX_MEMORY_LATENCY;
        -- combinatorial helper variables
        variable v_addr_hit : boolean;
        variable v_mem_addr : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    begin
        if axi_aresetn = '0' then
            v_state_r          := IDLE;
            v_rdata_r          := (others => '0');
            v_rresp_r          := (others => '0');
            v_mem_wait_count_r := 0;
            s_axi_arready_r    <= '0';
            s_axi_rvalid_r     <= '0';
            s_axi_rresp_r      <= (others => '0');
            s_axi_araddr_reg_r <= (others => '0');
            s_axi_rdata_r      <= (others => '0');
            s_image_state_strobe_r <= '0';
            s_tjpu_state_strobe_r <= '0';

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_arready_r <= '0';
            s_image_state_strobe_r <= '0';
            s_tjpu_state_strobe_r <= '0';

            case v_state_r is

                -- Wait for the start of a read transaction, which is
                -- initiated by the assertion of ARVALID
                when IDLE =>
                    if s_axi_arvalid = '1' then
                        s_axi_araddr_reg_r <= unsigned(s_axi_araddr); -- save the read address
                        s_axi_arready_r    <= '1'; -- acknowledge the read-address
                        v_state_r          := READ_REGISTER;
                    end if;

                -- Read from the actual storage element
                when READ_REGISTER =>
                    -- defaults:
                    v_addr_hit := false;
                    v_rdata_r  := (others => '0');

                    -- register 'Image_State' at address offset 0x4
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + IMAGE_STATE_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_image_state_value;
                        s_image_state_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'TJPU_State' at address offset 0x14
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_STATE_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(3 downto 0) := s_reg_tjpu_state_conv2d;
                        v_rdata_r(7 downto 4) := s_reg_tjpu_state_pw;
                        v_rdata_r(15 downto 8) := s_reg_tjpu_state_reshape;
                        s_tjpu_state_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    --
                    if v_addr_hit then
                        v_rresp_r := AXI_OKAY;
                    else
                        v_rresp_r := AXI_DECERR;
                        -- pragma translate_off
                        report "ARADDR decode error" severity warning;
                        -- pragma translate_on
                        v_state_r := READ_RESPONSE;
                    end if;

                -- Wait for memory read data
                when WAIT_MEMORY_RDATA =>
                    if v_mem_wait_count_r = 0 then
                        v_state_r      := READ_RESPONSE;
                    else
                        v_mem_wait_count_r := v_mem_wait_count_r - 1;
                    end if;

                -- Generate read response
                when READ_RESPONSE =>
                    s_axi_rvalid_r <= '1';
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    --
                    v_state_r      := DONE;

                -- Write transaction completed, wait for master RREADY to proceed
                when DONE =>
                    if s_axi_rready = '1' then
                        s_axi_rvalid_r <= '0';
                        s_axi_rdata_r   <= (others => '0');
                        v_state_r      := IDLE;
                    end if;
            end case;
        end if;
    end process read_fsm;

    ----------------------------------------------------------------------------
    -- Write-transaction FSM
    --
    write_fsm : process(axi_aclk, axi_aresetn) is
        type t_state is (IDLE, ADDR_FIRST, DATA_FIRST, UPDATE_REGISTER, DONE);
        variable v_state_r  : t_state;
        variable v_addr_hit : boolean;
        variable v_mem_addr : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    begin
        if axi_aresetn = '0' then
            v_state_r          := IDLE;
            s_axi_awready_r    <= '0';
            s_axi_wready_r     <= '0';
            s_axi_awaddr_reg_r <= (others => '0');
            s_axi_wdata_reg_r  <= (others => '0');
            s_axi_wstrb_reg_r  <= (others => '0');
            s_axi_bvalid_r     <= '0';
            s_axi_bresp_r      <= (others => '0');
            --
            s_image_control_strobe_r <= '0';
            s_reg_image_control_value_r <= IMAGE_CONTROL_VALUE_RESET;
            s_image_reg0_strobe_r <= '0';
            s_reg_image_reg0_value_r <= IMAGE_REG0_VALUE_RESET;
            s_image_reg1_strobe_r <= '0';
            s_reg_image_reg1_value_r <= IMAGE_REG1_VALUE_RESET;
            s_tjpu_control_strobe_r <= '0';
            s_reg_tjpu_control_conv2d_r <= TJPU_CONTROL_CONV2D_RESET;
            s_reg_tjpu_control_pw_r <= TJPU_CONTROL_PW_RESET;
            s_reg_tjpu_control_reshape_r <= TJPU_CONTROL_RESHAPE_RESET;
            s_tjpu_switch_strobe_r <= '0';
            s_reg_tjpu_switch_value_r <= TJPU_SWITCH_VALUE_RESET;
            s_tjpu_dma_read_addr_strobe_r <= '0';
            s_reg_tjpu_dma_read_addr_value_r <= TJPU_DMA_READ_ADDR_VALUE_RESET;
            s_tjpu_dma_read_num_strobe_r <= '0';
            s_reg_tjpu_dma_read_num_value_r <= TJPU_DMA_READ_NUM_VALUE_RESET;
            s_tjpu_dma_write_addr_strobe_r <= '0';
            s_reg_tjpu_dma_write_addr_value_r <= TJPU_DMA_WRITE_ADDR_VALUE_RESET;
            s_tjpu_dma_write_num_strobe_r <= '0';
            s_reg_tjpu_dma_write_num_value_r <= TJPU_DMA_WRITE_NUM_VALUE_RESET;
            s_tjpu_reg4_strobe_r <= '0';
            s_reg_tjpu_reg4_value_r <= TJPU_REG4_VALUE_RESET;
            s_tjpu_reg5_strobe_r <= '0';
            s_reg_tjpu_reg5_value_r <= TJPU_REG5_VALUE_RESET;
            s_tjpu_reg6_strobe_r <= '0';
            s_reg_tjpu_reg6_value_r <= TJPU_REG6_VALUE_RESET;
            s_tjpu_reg7_strobe_r <= '0';
            s_reg_tjpu_reg7_value_r <= TJPU_REG7_VALUE_RESET;
            s_tjpu_reg8_strobe_r <= '0';
            s_reg_tjpu_reg8_value_r <= TJPU_REG8_VALUE_RESET;
            s_tjpu_reg9_strobe_r <= '0';
            s_reg_tjpu_reg9_value_r <= TJPU_REG9_VALUE_RESET;

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_awready_r <= '0';
            s_axi_wready_r  <= '0';
            s_image_control_strobe_r <= '0';
            s_image_reg0_strobe_r <= '0';
            s_image_reg1_strobe_r <= '0';
            s_tjpu_control_strobe_r <= '0';
            s_tjpu_switch_strobe_r <= '0';
            s_tjpu_dma_read_addr_strobe_r <= '0';
            s_tjpu_dma_read_num_strobe_r <= '0';
            s_tjpu_dma_write_addr_strobe_r <= '0';
            s_tjpu_dma_write_num_strobe_r <= '0';
            s_tjpu_reg4_strobe_r <= '0';
            s_tjpu_reg5_strobe_r <= '0';
            s_tjpu_reg6_strobe_r <= '0';
            s_tjpu_reg7_strobe_r <= '0';
            s_tjpu_reg8_strobe_r <= '0';
            s_tjpu_reg9_strobe_r <= '0';

            -- Self-clearing fields:
            s_reg_image_control_value_r <= (others => '0');
            s_reg_tjpu_control_conv2d_r <= (others => '0');
            s_reg_tjpu_control_pw_r <= (others => '0');
            s_reg_tjpu_control_reshape_r <= (others => '0');

            case v_state_r is

                -- Wait for the start of a write transaction, which may be
                -- initiated by either of the following conditions:
                --   * assertion of both AWVALID and WVALID
                --   * assertion of AWVALID
                --   * assertion of WVALID
                when IDLE =>
                    if s_axi_awvalid = '1' and s_axi_wvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r     <= '1'; -- acknowledge the write-data
                        v_state_r          := UPDATE_REGISTER;
                    elsif s_axi_awvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        v_state_r          := ADDR_FIRST;
                    elsif s_axi_wvalid = '1' then
                        s_axi_wdata_reg_r <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r    <= '1'; -- acknowledge the write-data
                        v_state_r         := DATA_FIRST;
                    end if;

                -- Address-first write transaction: wait for the write-data
                when ADDR_FIRST =>
                    if s_axi_wvalid = '1' then
                        s_axi_wdata_reg_r <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r    <= '1'; -- acknowledge the write-data
                        v_state_r         := UPDATE_REGISTER;
                    end if;

                -- Data-first write transaction: wait for the write-address
                when DATA_FIRST =>
                    if s_axi_awvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        v_state_r          := UPDATE_REGISTER;
                    end if;

                -- Update the actual storage element
                when UPDATE_REGISTER =>
                    s_axi_bresp_r               <= AXI_OKAY; -- default value, may be overriden in case of decode error
                    s_axi_bvalid_r              <= '1';
                    --
                    v_addr_hit := false;
                    -- register 'Image_Control' at address offset 0x0
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + IMAGE_CONTROL_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_image_control_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_control_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_control_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_control_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_control_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'Image_Reg0' at address offset 0x8
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + IMAGE_REG0_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_image_reg0_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg0_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg0_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg0_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg0_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'Image_Reg1' at address offset 0xC
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + IMAGE_REG1_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_image_reg1_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_image_reg1_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_image_reg1_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_image_reg1_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_image_reg1_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Control' at address offset 0x10
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_CONTROL_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_control_strobe_r <= '1';
                        -- field 'Conv2d':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_conv2d_r(0) <= s_axi_wdata_reg_r(0); -- Conv2d(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_conv2d_r(1) <= s_axi_wdata_reg_r(1); -- Conv2d(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_conv2d_r(2) <= s_axi_wdata_reg_r(2); -- Conv2d(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_conv2d_r(3) <= s_axi_wdata_reg_r(3); -- Conv2d(3)
                        end if;
                        -- field 'PW':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_pw_r(0) <= s_axi_wdata_reg_r(4); -- PW(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_pw_r(1) <= s_axi_wdata_reg_r(5); -- PW(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_pw_r(2) <= s_axi_wdata_reg_r(6); -- PW(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_control_pw_r(3) <= s_axi_wdata_reg_r(7); -- PW(3)
                        end if;
                        -- field 'Reshape':
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(0) <= s_axi_wdata_reg_r(8); -- Reshape(0)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(1) <= s_axi_wdata_reg_r(9); -- Reshape(1)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(2) <= s_axi_wdata_reg_r(10); -- Reshape(2)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(3) <= s_axi_wdata_reg_r(11); -- Reshape(3)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(4) <= s_axi_wdata_reg_r(12); -- Reshape(4)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(5) <= s_axi_wdata_reg_r(13); -- Reshape(5)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(6) <= s_axi_wdata_reg_r(14); -- Reshape(6)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_control_reshape_r(7) <= s_axi_wdata_reg_r(15); -- Reshape(7)
                        end if;
                    end if;
                    -- register 'TJPU_Switch' at address offset 0x18
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_SWITCH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_switch_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_switch_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_switch_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_switch_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_switch_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_DMA_Read_Addr' at address offset 0x1C
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_DMA_READ_ADDR_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_dma_read_addr_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_addr_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_DMA_Read_Num' at address offset 0x20
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_DMA_READ_NUM_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_dma_read_num_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_read_num_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_DMA_Write_Addr' at address offset 0x24
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_DMA_WRITE_ADDR_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_dma_write_addr_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_addr_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_DMA_Write_Num' at address offset 0x28
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_DMA_WRITE_NUM_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_dma_write_num_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_dma_write_num_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Reg4' at address offset 0x2C
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_REG4_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_reg4_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg4_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg4_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg4_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg4_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Reg5' at address offset 0x30
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_REG5_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_reg5_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg5_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg5_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg5_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg5_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Reg6' at address offset 0x34
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_REG6_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_reg6_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg6_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg6_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg6_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg6_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Reg7' at address offset 0x38
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_REG7_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_reg7_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg7_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg7_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg7_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg7_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Reg8' at address offset 0x3C
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_REG8_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_reg8_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg8_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg8_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg8_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg8_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    -- register 'TJPU_Reg9' at address offset 0x40
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + TJPU_REG9_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_tjpu_reg9_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_tjpu_reg9_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_tjpu_reg9_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_tjpu_reg9_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_tjpu_reg9_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    --
                    if not v_addr_hit then
                        s_axi_bresp_r <= AXI_DECERR;
                        -- pragma translate_off
                        report "AWADDR decode error" severity warning;
                        -- pragma translate_on
                    end if;
                    --
                    v_state_r := DONE;

                -- Write transaction completed, wait for master BREADY to proceed
                when DONE =>
                    if s_axi_bready = '1' then
                        s_axi_bvalid_r <= '0';
                        v_state_r      := IDLE;
                    end if;

            end case;


        end if;
    end process write_fsm;

    ----------------------------------------------------------------------------
    -- Outputs
    --
    s_axi_awready <= s_axi_awready_r;
    s_axi_wready  <= s_axi_wready_r;
    s_axi_bvalid  <= s_axi_bvalid_r;
    s_axi_bresp   <= s_axi_bresp_r;
    s_axi_arready <= s_axi_arready_r;
    s_axi_rvalid  <= s_axi_rvalid_r;
    s_axi_rresp   <= s_axi_rresp_r;
    s_axi_rdata   <= s_axi_rdata_r;

   image_control_strobe <= s_image_control_strobe_r;
   image_control_value <= s_reg_image_control_value_r;
   image_state_strobe <= s_image_state_strobe_r;
   image_reg0_strobe <= s_image_reg0_strobe_r;
   image_reg0_value <= s_reg_image_reg0_value_r;
   image_reg1_strobe <= s_image_reg1_strobe_r;
   image_reg1_value <= s_reg_image_reg1_value_r;
   tjpu_control_strobe <= s_tjpu_control_strobe_r;
   tjpu_control_conv2d <= s_reg_tjpu_control_conv2d_r;
   tjpu_control_pw <= s_reg_tjpu_control_pw_r;
   tjpu_control_reshape <= s_reg_tjpu_control_reshape_r;
   tjpu_state_strobe <= s_tjpu_state_strobe_r;
   tjpu_switch_strobe <= s_tjpu_switch_strobe_r;
   tjpu_switch_value <= s_reg_tjpu_switch_value_r;
   tjpu_dma_read_addr_strobe <= s_tjpu_dma_read_addr_strobe_r;
   tjpu_dma_read_addr_value <= s_reg_tjpu_dma_read_addr_value_r;
   tjpu_dma_read_num_strobe <= s_tjpu_dma_read_num_strobe_r;
   tjpu_dma_read_num_value <= s_reg_tjpu_dma_read_num_value_r;
   tjpu_dma_write_addr_strobe <= s_tjpu_dma_write_addr_strobe_r;
   tjpu_dma_write_addr_value <= s_reg_tjpu_dma_write_addr_value_r;
   tjpu_dma_write_num_strobe <= s_tjpu_dma_write_num_strobe_r;
   tjpu_dma_write_num_value <= s_reg_tjpu_dma_write_num_value_r;
   tjpu_reg4_strobe <= s_tjpu_reg4_strobe_r;
   tjpu_reg4_value <= s_reg_tjpu_reg4_value_r;
   tjpu_reg5_strobe <= s_tjpu_reg5_strobe_r;
   tjpu_reg5_value <= s_reg_tjpu_reg5_value_r;
   tjpu_reg6_strobe <= s_tjpu_reg6_strobe_r;
   tjpu_reg6_value <= s_reg_tjpu_reg6_value_r;
   tjpu_reg7_strobe <= s_tjpu_reg7_strobe_r;
   tjpu_reg7_value <= s_reg_tjpu_reg7_value_r;
   tjpu_reg8_strobe <= s_tjpu_reg8_strobe_r;
   tjpu_reg8_value <= s_reg_tjpu_reg8_value_r;
   tjpu_reg9_strobe <= s_tjpu_reg9_strobe_r;
   tjpu_reg9_value <= s_reg_tjpu_reg9_value_r;

end architecture RTL;
