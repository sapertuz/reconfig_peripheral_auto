----------------------------------------------------------------------------------
-- Company: UnB
-- Engineer: Sergio Pertuz
-- 
-- Create Date: 04-Mar-2021 02:22:04
-- Design Name: 
-- Module Name: linear_regressor_pack - Behavioral
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
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.all;

use work.fpupack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package linR_pkg is

-- Configuration Constant Definitions 
constant Number_of_Variables : positive :=25; --  deve ser par (intercept nao eh uma variavel)
constant Number_of_Op : positive := 8; -- possiveis valores = [2, 4, 8, 16, 32, 64, 128] 
                                         -- (Number_of_Variables mod Number_of_Op = 0)
constant Number_of_Cycles : positive := Number_of_Variables/Number_of_Op;

-- Types Definitions
type input_array_type is array (1 to Number_of_Variables) of std_logic_vector(FP_WIDTH-1 downto 0); -- Array para todas as variaveis
type regressor_array_type is array (1 to Number_of_Op) of std_logic_vector(FP_WIDTH-1 downto 0); -- Array para todas as entradas do regressor
type coeff_array_type is array (1 to Number_of_Variables) of std_logic_vector(FP_WIDTH-1 downto 0); -- Array para todos os coeff + intercept
type positions_array is array (1 to Number_of_Cycles + 1) of positive; 

-- Regressor Constants Definitions ---------------------------------
constant coeff_array : coeff_array_type := ( -- coeff values 
"101111110100000000011", 
"001111100111001101101", 
"101111101001010110101", 
"101111101100001011010", 
"001111001001100010111", 
"101111001011001111000", 
"001111100011001111111", 
"001111110111001011001", 
"101111110101110001101", 
"101111101000100010001", 
"001111110000111110100", 
"010000000011110000010", 
"001111010011000110011", 
"001111110000010010000", 
"101111101110010101011", 
"101111110101001110101", 
"010000001011001001101", 
"001111111010010001111", 
"101111110101011001101", 
"001111110110001011111", 
"101111010000111000110", 
"101111111100100111100", 
"110000111000101001110", 
"001111101000101011100", 
"001111110100101111111"); 
constant intercept : std_logic_vector(FP_WIDTH-1 downto 0) :="001111010000010011010"; --  intercept
constant cycle_pos : positions_array; -- positions of coeff for cycles, assign is deferred

-- Constant Files
file coeff_file : text;

-- Functions Declarations
function to_regr_array (
    input_array : coeff_array_type;
    constant first, last : positive)
    return regressor_array_type;


-- Component Declarations
component linear_regressor is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        
        data_sensor_vector : in regressor_array_type;
        data_coeff_vector : in regressor_array_type;
        data_intercept : in std_logic_vector(FP_WIDTH-1 downto 0);
        data_ready_in : in std_logic;
        
        data_output_vector  : out std_logic_vector(FP_WIDTH-1 downto 0);
        data_valid          : out std_logic;
        data_ready_out      : out std_logic;
        data_busy           : out std_logic );
end component;

end package;

package body linR_pkg is
    
-- Function to init positions of cycles
  impure function pos_init return positions_array is
    variable cycle_pos_tmp : positions_array; 
  begin
    for I in 1 to Number_of_Cycles+1 loop
      cycle_pos_tmp(I) := Number_of_Op*(I-1) + 1;
    end loop;
    return cycle_pos_tmp;
  end function; 
  -- Init pos
  constant cycle_pos : positions_array := pos_init;
  -- to_reg_array()
  -- return regressor_array from bigger coeff array
  function to_regr_array (
    input_array : coeff_array_type; 
    constant first, last : positive)
    return regressor_array_type is
  variable regr_array_out : regressor_array_type;
  constant N_I : positive := last - first;
  begin
    for I in 0 to N_I-1 loop
      regr_array_out(I) := input_array(first+I);
    end loop;
    return regr_array_out;
  end function;
                          
end package body;
