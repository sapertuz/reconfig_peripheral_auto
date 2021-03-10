----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.10.2019 12:12:10
-- Design Name: 
-- Module Name: wrapper_linear_regressor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.fpupack.all;
use work.linR_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wrapper_regressor is
    Port ( clk : in std_logic;
           rst : in std_logic;
           
           data_in : in STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           ready_in : in STD_LOGIC;
           
           --data_ack : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           --busy_out : out STD_LOGIC;
           ready_out : out STD_LOGIC);
end wrapper_regressor;

architecture Behavioral of wrapper_regressor is

-- Buffer signals
signal op_full : std_logic;
--signal cycle_full : std_logic_vector(1 to Number_of_Cycles);
signal data_in_buffer : regressor_array_type;
signal coeff_buffer : regressor_array_type;
--signal data_in_module : regressor_array_type;

-- Linear Module signals
signal data_sensor_vector  : regressor_array_type;
signal data_coeff_vector   : regressor_array_type;
signal data_intercept      : std_logic_vector(FP_WIDTH-1 downto 0);
signal data_ready_in       : std_logic; 
signal data_output_vector  : std_logic_vector(FP_WIDTH-1 downto 0);
signal data_valid          : std_logic;
signal data_ready_out      : std_logic;
signal data_busy           : std_logic;

begin 

-- Linear regressor module
lin_mod: linear_regressor Port Map(
clk                => clk                ,
rst                => rst                ,

data_sensor_vector => data_sensor_vector ,
data_coeff_vector  => data_coeff_vector  ,
data_intercept     => data_intercept,
data_ready_in      => data_ready_in      ,

data_output_vector => data_output_vector ,
data_valid         => open         ,
data_ready_out     => data_ready_out     ,
data_busy          => data_busy          
);
data_intercept <= intercept;
ready_out <= data_ready_out;
--busy_out <= data_busy;
data_out <= data_output_vector;

-- FIFO buffer
FIFO_buffer: process(clk)
  variable x : positive range 1 to Number_of_Op + 1;
  variable y : positive range 1 to Number_of_Variables + 1;
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      data_in_buffer <= (others =>(others=>'0'));
      coeff_buffer <= (others =>(others=>'0'));
      op_full <= '0';
      x := 1;
      y := 1;
    else
      if (ready_in = '1') then
        data_in_buffer(x) <= data_in;
        coeff_buffer(x) <= coeff_array(y);
        x := x+1;
        --if (x > Number_of_Op) then x := 1;  end if;
        y := y+1;
        if (y > Number_of_Variables) then y := 1;  end if;
      end if;
      if (x > Number_of_op) then
        op_full <= '1';
        x := 1;
      else
        op_full <= '0';
      end if;
      
    end if;
  end if;
end process;

-- Cycles Sequence
cycles: process(clk)
  variable x : positive range 1 to Number_of_Cycles + 1;
begin
if (rising_edge(clk)) then
    if (rst = '1') then
      x := 1;
    else
      if (op_full = '1') then
        data_sensor_vector <= data_in_buffer;
        data_coeff_vector <= coeff_buffer;
        data_ready_in <= '1';
        x := x+1;
        if (x <= Number_of_Cycles) then x := 1;  end if;
      else
          data_ready_in <= '0';
      end if;
    end if;
end if;
end process;

end Behavioral;
