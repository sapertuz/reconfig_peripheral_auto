----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/09/2019 02:35:58 PM
-- Design Name: 
-- Module Name: linear_regressor - Behavioral
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
use IEEE.NUMERIC_STD;

use work.fpupack.all;
use work.entities.all;
use work.linR_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity linear_regressor is
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
end linear_regressor;

architecture Behavioral of linear_regressor is

-- Types
--type data_vector_type is array (1 to Number_of_Op) of std_logic_vector(FP_WIDTH-1 downto 0);
--type data_vector_type_show is array (1 to Number_of_Op) of std_logic_vector(32-1 downto 0);

-- FUnctions
function f_log2(arg : positive) return natural is
    variable tmp : positive     := 1;
    variable log : natural      := 0;
begin
    while arg > tmp loop
        tmp := tmp * 2;
        log := log + 1;
    end loop;
    return log;
end function;

constant n_inter_layers : integer := f_log2(Number_of_Op);
type row_type is array (2 to n_inter_layers+2) of integer;

function f_row_creator(arg: integer) return row_type is
    constant n_inter_layers : integer := f_log2(Number_of_Op);
    variable tmp : natural range 0 to Number_of_Op := Number_of_Op;
    variable rows: row_type;
begin
    rows(2) := 1;
    tmp := Number_of_Op;
    for I in 3 to n_inter_layers+2 loop
        if tmp=1 then
            tmp := 1;
        else
            tmp := tmp/2;
        end if;
        rows(I) := rows(I-1) + tmp;
    end loop;
    return rows;
end function;

--signal opA_as_show   : data_vector_type_show;
--signal opB_as_show   : data_vector_type_show;
--signal out_as_show   : data_vector_type_show;
--signal opA_mul_show   : data_vector_type_show;
--signal opB_mul_show   : data_vector_type_show;
--signal out_mul_show   : data_vector_type_show;
--signal data_output_vector_show : std_logic_vector(31 downto 0);

-- AddSub signals
signal opA_as   : regressor_array_type;
signal opB_as   : regressor_array_type;
signal start_as : std_logic_vector(1 to Number_of_Op);
signal out_as   : regressor_array_type;
signal ready_as : std_logic_vector(1 to Number_of_Op);

-- Multiplier signals
signal start_mul:std_logic_vector(1 to Number_of_Op);
signal opA_mul : regressor_array_type;
signal opB_mul : regressor_array_type;
signal out_mul : regressor_array_type;
signal ready_mul:std_logic_vector(1 to Number_of_Op);

-- Registers
--signal register_vector : data_vector_type;
signal opB_as_final_layer : std_logic_vector(FP_WIDTH-1 downto 0);
signal data_ready_out_reg : std_logic;
signal ready_as_reg : std_logic_vector(1 to Number_of_Op);
signal ready_mul_reg : std_logic_vector(1 to Number_of_Op);
signal data_ready_in_reg : std_logic;

-- Constant
constant rows : row_type := f_row_creator(Number_of_Op);

begin

-- Adders
Adder: for I in 1 to Number_of_Op generate
    op: addsubfsm_v6
    port map (reset         => rst,
              clk           => clk,
              op            => '0',
              op_a          => opA_as(I),
              op_b          => opB_as(I),
              start_i       => start_as(I),
              addsub_out    => out_as(I),
              ready_as      => ready_as_reg(I));
end generate;

-- Multipliers
Multiplier: for I in 1 to Number_of_Op generate
    op: multiplierfsm_v2
    port map (reset         => rst,
              clk           => clk,
              op_a          => opA_mul(I),
              op_b          => opB_mul(I),
              start_i       => start_mul(I),
              mul_out       => out_mul(I),
              ready_mul     => ready_mul_reg(I));
end generate;

-- input, second, second last, and final layers
layers: process(clk, rst)
variable msb_data, lsb_data : integer;
constant add_start: integer := (Number_of_Op / 2);
constant add_end: integer := Number_of_Op - 1;
variable cont_out_as: integer range 1 to add_end := 1;
variable cont_adder: integer range add_start to add_end := add_start;
begin
    if rst = '1' then
        opA_mul <= (others=>(others=>'0'));
        opB_mul <= (others=>(others=>'0'));
        opA_as <= (others=>(others=>'0'));
        opB_as <= (others=>(others=>'0'));
        
--        opA_as_show <= (others=>(others=>'0'));
--        opB_as_show <= (others=>(others=>'0'));
--        out_as_show <= (others=>(others=>'0'));
--        opA_mul_show <= (others=>(others=>'0'));
--        opB_mul_show <= (others=>(others=>'0'));
--        out_mul_show <= (others=>(others=>'0'));

    elsif rising_edge(clk) then

-- input layer        
--        for I in 1 to Number_of_Op loop     
--            msb_data := Number_of_Op*FP_WIDTH-1 - ((I-1)*FP_WIDTH);
--            lsb_data := Number_of_Op*FP_WIDTH-1 - (I*FP_WIDTH-1);
--            --opA_mul(I) <= data_sensor_vector(msb_data downto lsb_data);
--            --opB_mul(I) <= data_coeff_vector(msb_data downto lsb_data);
--        end loop;
        opA_mul <= data_sensor_vector;
        opB_mul <= data_coeff_vector;
        
-- second layer
        for I in 1 to Number_of_Op/2 loop     
            opA_as(I) <= out_mul(I*2-1);    
            opB_as(I) <= out_mul(I*2);    
        end loop;
        
-- final layer
        opA_as(Number_of_Op) <= out_as(Number_of_Op-1);
        opB_as(Number_of_Op) <= opB_as_final_layer;
 
-- intermediate layers
        if (Number_of_Op > 2) then
            cont_adder := add_start;
            cont_out_as := 1;
            while (cont_adder < add_end)
            loop
                cont_adder := cont_adder + 1;
                opA_as(cont_adder) <= out_as(cont_out_as);
                opB_as(cont_adder) <= out_as(cont_out_as+1);
                cont_out_as := cont_out_as+2;
            end loop;
        end if;
 
 --Just for show
--        for I in 1 to Number_of_op loop
--            opA_as_show(I)  <= opA_as(I) & "00000";
--            opB_as_show(I)  <= opB_as(I) & "00000";
--            out_as_show(I)  <= out_as(I) & "00000";
--            opA_mul_show(I) <= opA_mul(I) & "00000";
--            opB_mul_show(I) <= opB_mul(I) & "00000";
--            out_mul_show(I) <= out_mul(I) & "00000";
--        end loop;
        
    end if;
end process layers;

-- Next state and Operations Decode  
STATES : process(clk,rst)
constant Number_of_Cycles : integer := Number_of_Variables/Number_of_Op;
variable cont_cycles : integer range 1 to Number_of_Cycles+1 := 1;
variable mul_busy : std_logic := '0';
begin
    if (rst = '1') then
        data_output_vector <= (others=>'0'); 
--        data_output_vector_show <= (others=>'0'); 
        data_valid         <= '0'; 
        data_ready_out_reg <= '0'; 
        data_busy          <= '0'; 
        mul_busy          := '0';
        opB_as_final_layer <= data_intercept;
        start_as <= (others=>'0');
        start_mul <= (others=>'0');
        cont_cycles := 1;
    elsif (rising_edge(clk)) then

-- First Layer (multiplication)
        if (data_ready_in_reg='1') and (mul_busy='0') then
            start_mul <= (others=>'1');
            mul_busy := '1';
        elsif (ready_mul(1) = '1') then
            mul_busy := '0';  
        else 
            start_mul <= (others=>'0');
        end if;

-- Second Layer
        if (ready_mul(1) = '1') then
            start_as(1 to Number_of_Op/2) <= (others=>'1');
        else
            start_as(1 to Number_of_Op/2) <= (others=>'0');
        end if;

-- Last Layer
        if (ready_as(Number_of_Op) = '1') then
            if cont_cycles = Number_of_Cycles then
                opB_as_final_layer <= data_intercept;
                data_output_vector <= out_as(Number_of_Op);
--                data_output_vector_show <= out_as(Number_of_Op) & "00000";
                data_ready_out_reg <= '1';
                cont_cycles := 1;
            else
                opB_as_final_layer <= out_as(Number_of_Op);
                cont_cycles := cont_cycles+1;
            end if;
        else
            data_ready_out_reg <= '0';
        end if;
        start_as(Number_of_Op) <= ready_as(Number_of_Op-1);

-- Rest (intermediate) layers
        for state in 3 to n_inter_layers + 1 loop
            for J in rows(state) to rows(state+1)-1 loop
                start_as(J) <= ready_as(rows(state-1));
            end loop;
        end loop;
        
    end if;
    data_busy <= mul_busy;
end process STATES;

-- Synchronization of adder start
Sync_Process: process(rst,clk)
begin
    if rst='1' then
        data_ready_out <= '0';
        
        ready_as <= (others=>'0');
        ready_mul <= (others=>'0');
        
        data_ready_in_reg <= '0'; 
    elsif falling_edge(clk) then
        data_ready_out <= data_ready_out_reg;
        
        ready_as <= ready_as_reg;
        ready_mul <= ready_mul_reg;
        
        data_ready_in_reg <= data_ready_in;
    end if;
end process Sync_Process;


end Behavioral;
