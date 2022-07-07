-- -----------------------------------------------------------------------------
-- 'Yolo_v4' Register Definitions
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

package Yolo_v4_regs_pkg is

    -- Type definitions
    type slv1_array_t is array(natural range <>) of std_logic_vector(0 downto 0);
    type slv2_array_t is array(natural range <>) of std_logic_vector(1 downto 0);
    type slv3_array_t is array(natural range <>) of std_logic_vector(2 downto 0);
    type slv4_array_t is array(natural range <>) of std_logic_vector(3 downto 0);
    type slv5_array_t is array(natural range <>) of std_logic_vector(4 downto 0);
    type slv6_array_t is array(natural range <>) of std_logic_vector(5 downto 0);
    type slv7_array_t is array(natural range <>) of std_logic_vector(6 downto 0);
    type slv8_array_t is array(natural range <>) of std_logic_vector(7 downto 0);
    type slv9_array_t is array(natural range <>) of std_logic_vector(8 downto 0);
    type slv10_array_t is array(natural range <>) of std_logic_vector(9 downto 0);
    type slv11_array_t is array(natural range <>) of std_logic_vector(10 downto 0);
    type slv12_array_t is array(natural range <>) of std_logic_vector(11 downto 0);
    type slv13_array_t is array(natural range <>) of std_logic_vector(12 downto 0);
    type slv14_array_t is array(natural range <>) of std_logic_vector(13 downto 0);
    type slv15_array_t is array(natural range <>) of std_logic_vector(14 downto 0);
    type slv16_array_t is array(natural range <>) of std_logic_vector(15 downto 0);
    type slv17_array_t is array(natural range <>) of std_logic_vector(16 downto 0);
    type slv18_array_t is array(natural range <>) of std_logic_vector(17 downto 0);
    type slv19_array_t is array(natural range <>) of std_logic_vector(18 downto 0);
    type slv20_array_t is array(natural range <>) of std_logic_vector(19 downto 0);
    type slv21_array_t is array(natural range <>) of std_logic_vector(20 downto 0);
    type slv22_array_t is array(natural range <>) of std_logic_vector(21 downto 0);
    type slv23_array_t is array(natural range <>) of std_logic_vector(22 downto 0);
    type slv24_array_t is array(natural range <>) of std_logic_vector(23 downto 0);
    type slv25_array_t is array(natural range <>) of std_logic_vector(24 downto 0);
    type slv26_array_t is array(natural range <>) of std_logic_vector(25 downto 0);
    type slv27_array_t is array(natural range <>) of std_logic_vector(26 downto 0);
    type slv28_array_t is array(natural range <>) of std_logic_vector(27 downto 0);
    type slv29_array_t is array(natural range <>) of std_logic_vector(28 downto 0);
    type slv30_array_t is array(natural range <>) of std_logic_vector(29 downto 0);
    type slv31_array_t is array(natural range <>) of std_logic_vector(30 downto 0);
    type slv32_array_t is array(natural range <>) of std_logic_vector(31 downto 0);

    -- User-logic ports (from user-logic to register file)
    -- type user2regs_t is record
    --     image_state_value : std_logic_vector(31 downto 0); -- value of register 'Image_State', field 'value'
    --     tjpu_state_conv2d : std_logic_vector(3 downto 0); -- value of register 'TJPU_State', field 'Conv2d'
    --     tjpu_state_pw : std_logic_vector(3 downto 0); -- value of register 'TJPU_State', field 'PW'
    --     tjpu_state_reshape : std_logic_vector(7 downto 0); -- value of register 'TJPU_State', field 'Reshape'
    -- end record;

    -- User-logic ports (from register file to user-logic)
    --type regs2user_t is record
    --    image_control_strobe : std_logic; -- Strobe signal for register 'Image_Control' (pulsed when the register is written from the bus}
    --    image_control_value : std_logic_vector(31 downto 0); -- Value of register 'Image_Control', field 'value'
    --    image_state_strobe : std_logic; -- Strobe signal for register 'Image_State' (pulsed when the register is read from the bus}
    --    image_reg0_strobe : std_logic; -- Strobe signal for register 'Image_Reg0' (pulsed when the register is written from the bus}
    --    image_reg0_value : std_logic_vector(31 downto 0); -- Value of register 'Image_Reg0', field 'value'
    --    image_reg1_strobe : std_logic; -- Strobe signal for register 'Image_Reg1' (pulsed when the register is written from the bus}
    --    image_reg1_value : std_logic_vector(31 downto 0); -- Value of register 'Image_Reg1', field 'value'
    --    tjpu_control_strobe : std_logic; -- Strobe signal for register 'TJPU_Control' (pulsed when the register is written from the bus}
    --    tjpu_control_conv2d : std_logic_vector(3 downto 0); -- Value of register 'TJPU_Control', field 'Conv2d'
    --    tjpu_control_pw : std_logic_vector(3 downto 0); -- Value of register 'TJPU_Control', field 'PW'
    --    tjpu_control_reshape : std_logic_vector(7 downto 0); -- Value of register 'TJPU_Control', field 'Reshape'
    --    tjpu_state_strobe : std_logic; -- Strobe signal for register 'TJPU_State' (pulsed when the register is read from the bus}
    --    tjpu_switch_strobe : std_logic; -- Strobe signal for register 'TJPU_Switch' (pulsed when the register is written from the bus}
    --    tjpu_switch_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Switch', field 'value'
    --    tjpu_dma_read_addr_strobe : std_logic; -- Strobe signal for register 'TJPU_DMA_Read_Addr' (pulsed when the register is written from the bus}
    --    tjpu_dma_read_addr_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Read_Addr', field 'value'
    --    tjpu_dma_read_num_strobe : std_logic; -- Strobe signal for register 'TJPU_DMA_Read_Num' (pulsed when the register is written from the bus}
    --    tjpu_dma_read_num_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Read_Num', field 'value'
    --    tjpu_dma_write_addr_strobe : std_logic; -- Strobe signal for register 'TJPU_DMA_Write_Addr' (pulsed when the register is written from the bus}
    --    tjpu_dma_write_addr_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Write_Addr', field 'value'
    --    tjpu_dma_write_num_strobe : std_logic; -- Strobe signal for register 'TJPU_DMA_Write_Num' (pulsed when the register is written from the bus}
    --    tjpu_dma_write_num_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_DMA_Write_Num', field 'value'
    --    tjpu_reg4_strobe : std_logic; -- Strobe signal for register 'TJPU_Reg4' (pulsed when the register is written from the bus}
    --    tjpu_reg4_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg4', field 'value'
    --    tjpu_reg5_strobe : std_logic; -- Strobe signal for register 'TJPU_Reg5' (pulsed when the register is written from the bus}
    --    tjpu_reg5_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg5', field 'value'
    --    tjpu_reg6_strobe : std_logic; -- Strobe signal for register 'TJPU_Reg6' (pulsed when the register is written from the bus}
    --    tjpu_reg6_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg6', field 'value'
    --    tjpu_reg7_strobe : std_logic; -- Strobe signal for register 'TJPU_Reg7' (pulsed when the register is written from the bus}
    --    tjpu_reg7_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg7', field 'value'
    --    tjpu_reg8_strobe : std_logic; -- Strobe signal for register 'TJPU_Reg8' (pulsed when the register is written from the bus}
    --    tjpu_reg8_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg8', field 'value'
    --    tjpu_reg9_strobe : std_logic; -- Strobe signal for register 'TJPU_Reg9' (pulsed when the register is written from the bus}
    --    tjpu_reg9_value : std_logic_vector(31 downto 0); -- Value of register 'TJPU_Reg9', field 'value'
    --end record;

    -- Revision number of the 'Yolo_v4' register map
    constant YOLO_V4_REVISION : natural := 105;

    -- Default base address of the 'Yolo_v4' register map
    constant YOLO_V4_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"00000000");

    -- Register 'Image_Control'
    constant IMAGE_CONTROL_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000000"); -- address offset of the 'Image_Control' register
    -- Field 'Image_Control.value'
    constant IMAGE_CONTROL_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant IMAGE_CONTROL_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant IMAGE_CONTROL_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'Image_State'
    constant IMAGE_STATE_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000004"); -- address offset of the 'Image_State' register
    -- Field 'Image_State.value'
    constant IMAGE_STATE_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant IMAGE_STATE_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant IMAGE_STATE_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'Image_Reg0'
    constant IMAGE_REG0_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'Image_Reg0' register
    -- Field 'Image_Reg0.value'
    constant IMAGE_REG0_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant IMAGE_REG0_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant IMAGE_REG0_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'Image_Reg1'
    constant IMAGE_REG1_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000000C"); -- address offset of the 'Image_Reg1' register
    -- Field 'Image_Reg1.value'
    constant IMAGE_REG1_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant IMAGE_REG1_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant IMAGE_REG1_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Control'
    constant TJPU_CONTROL_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000010"); -- address offset of the 'TJPU_Control' register
    -- Field 'TJPU_Control.Conv2d'
    constant TJPU_CONTROL_CONV2D_BIT_OFFSET : natural := 0; -- bit offset of the 'Conv2d' field
    constant TJPU_CONTROL_CONV2D_BIT_WIDTH : natural := 4; -- bit width of the 'Conv2d' field
    constant TJPU_CONTROL_CONV2D_RESET : std_logic_vector(3 downto 0) := std_logic_vector'("0000"); -- reset value of the 'Conv2d' field
    -- Field 'TJPU_Control.PW'
    constant TJPU_CONTROL_PW_BIT_OFFSET : natural := 4; -- bit offset of the 'PW' field
    constant TJPU_CONTROL_PW_BIT_WIDTH : natural := 4; -- bit width of the 'PW' field
    constant TJPU_CONTROL_PW_RESET : std_logic_vector(7 downto 4) := std_logic_vector'("0000"); -- reset value of the 'PW' field
    -- Field 'TJPU_Control.Reshape'
    constant TJPU_CONTROL_RESHAPE_BIT_OFFSET : natural := 8; -- bit offset of the 'Reshape' field
    constant TJPU_CONTROL_RESHAPE_BIT_WIDTH : natural := 8; -- bit width of the 'Reshape' field
    constant TJPU_CONTROL_RESHAPE_RESET : std_logic_vector(15 downto 8) := std_logic_vector'("00000000"); -- reset value of the 'Reshape' field

    -- Register 'TJPU_State'
    constant TJPU_STATE_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000014"); -- address offset of the 'TJPU_State' register
    -- Field 'TJPU_State.Conv2d'
    constant TJPU_STATE_CONV2D_BIT_OFFSET : natural := 0; -- bit offset of the 'Conv2d' field
    constant TJPU_STATE_CONV2D_BIT_WIDTH : natural := 4; -- bit width of the 'Conv2d' field
    constant TJPU_STATE_CONV2D_RESET : std_logic_vector(3 downto 0) := std_logic_vector'("0000"); -- reset value of the 'Conv2d' field
    -- Field 'TJPU_State.PW'
    constant TJPU_STATE_PW_BIT_OFFSET : natural := 4; -- bit offset of the 'PW' field
    constant TJPU_STATE_PW_BIT_WIDTH : natural := 4; -- bit width of the 'PW' field
    constant TJPU_STATE_PW_RESET : std_logic_vector(7 downto 4) := std_logic_vector'("0000"); -- reset value of the 'PW' field
    -- Field 'TJPU_State.Reshape'
    constant TJPU_STATE_RESHAPE_BIT_OFFSET : natural := 8; -- bit offset of the 'Reshape' field
    constant TJPU_STATE_RESHAPE_BIT_WIDTH : natural := 8; -- bit width of the 'Reshape' field
    constant TJPU_STATE_RESHAPE_RESET : std_logic_vector(15 downto 8) := std_logic_vector'("00000000"); -- reset value of the 'Reshape' field

    -- Register 'TJPU_Switch'
    constant TJPU_SWITCH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000018"); -- address offset of the 'TJPU_Switch' register
    -- Field 'TJPU_Switch.value'
    constant TJPU_SWITCH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_SWITCH_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_SWITCH_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_DMA_Read_Addr'
    constant TJPU_DMA_READ_ADDR_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000001C"); -- address offset of the 'TJPU_DMA_Read_Addr' register
    -- Field 'TJPU_DMA_Read_Addr.value'
    constant TJPU_DMA_READ_ADDR_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_DMA_READ_ADDR_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_DMA_READ_ADDR_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_DMA_Read_Num'
    constant TJPU_DMA_READ_NUM_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000020"); -- address offset of the 'TJPU_DMA_Read_Num' register
    -- Field 'TJPU_DMA_Read_Num.value'
    constant TJPU_DMA_READ_NUM_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_DMA_READ_NUM_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_DMA_READ_NUM_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_DMA_Write_Addr'
    constant TJPU_DMA_WRITE_ADDR_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000024"); -- address offset of the 'TJPU_DMA_Write_Addr' register
    -- Field 'TJPU_DMA_Write_Addr.value'
    constant TJPU_DMA_WRITE_ADDR_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_DMA_WRITE_ADDR_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_DMA_WRITE_ADDR_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_DMA_Write_Num'
    constant TJPU_DMA_WRITE_NUM_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000028"); -- address offset of the 'TJPU_DMA_Write_Num' register
    -- Field 'TJPU_DMA_Write_Num.value'
    constant TJPU_DMA_WRITE_NUM_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_DMA_WRITE_NUM_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_DMA_WRITE_NUM_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Reg4'
    constant TJPU_REG4_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000002C"); -- address offset of the 'TJPU_Reg4' register
    -- Field 'TJPU_Reg4.value'
    constant TJPU_REG4_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_REG4_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_REG4_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Reg5'
    constant TJPU_REG5_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000030"); -- address offset of the 'TJPU_Reg5' register
    -- Field 'TJPU_Reg5.value'
    constant TJPU_REG5_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_REG5_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_REG5_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Reg6'
    constant TJPU_REG6_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000034"); -- address offset of the 'TJPU_Reg6' register
    -- Field 'TJPU_Reg6.value'
    constant TJPU_REG6_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_REG6_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_REG6_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Reg7'
    constant TJPU_REG7_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000038"); -- address offset of the 'TJPU_Reg7' register
    -- Field 'TJPU_Reg7.value'
    constant TJPU_REG7_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_REG7_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_REG7_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Reg8'
    constant TJPU_REG8_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000003C"); -- address offset of the 'TJPU_Reg8' register
    -- Field 'TJPU_Reg8.value'
    constant TJPU_REG8_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_REG8_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_REG8_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'TJPU_Reg9'
    constant TJPU_REG9_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000040"); -- address offset of the 'TJPU_Reg9' register
    -- Field 'TJPU_Reg9.value'
    constant TJPU_REG9_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant TJPU_REG9_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant TJPU_REG9_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

end Yolo_v4_regs_pkg;
