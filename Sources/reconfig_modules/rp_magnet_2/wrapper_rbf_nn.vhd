library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fpupack.all;  -- define os tipos e constantes  

entity wrapper_regressor is
  port (clk      : in  std_logic;
        rst      : in  std_logic;
        data_in  : in  std_logic_vector (FP_WIDTH-1 downto 0);
        ready_in : in std_logic;
        data_out : out std_logic_vector (FP_WIDTH-1 downto 0);
        ready_out: out std_logic);
end wrapper_regressor;

architecture beh of wrapper_regressor is

-- Some constant declaration
constant n_in : positive := 10;

-- RBF component signals declaration
signal i_start : STD_LOGIC;
signal in1 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in2 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in3 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in4 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in5 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in6 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in7 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in8 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in9 : std_logic_vector(FP_WIDTH-1 downto 0);
signal in10 : std_logic_vector(FP_WIDTH-1 downto 0);
signal rbf_nn_out : STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
signal ready : STD_LOGIC;

-- Some signal declarations
signal start_reg : STD_LOGIC;

-- Buffer for data in
type buffer_in_type is array (1 to n_in) of STD_LOGIC_VECTOR(FP_WIDTH-1 downto 0);
signal buffer_in : buffer_in_type;

begin

rbf_nn: entity work.rbf_nn_v3 port map (
  clk     => clk    ,
  i_reset => rst    ,
  i_start => i_start,
  in1     => in1    ,
  in2     => in2    ,
  in3     => in3    ,
  in4     => in4    ,
  in5     => in5    ,
  in6     => in6    ,
  in7     => in7    ,
  in8     => in8    ,
  in9     => in9    ,
  in10     => in10    ,
  rbf_nn_out => rbf_nn_out,
  ready      => ready
);

-- Signals assignation
data_out <= rbf_nn_out;
ready_out <= ready;
in1 <= buffer_in(1);
in2 <= buffer_in(2);
in3 <= buffer_in(3);
in4 <= buffer_in(4);
in5 <= buffer_in(5);
in6 <= buffer_in(6);
in7 <= buffer_in(7);
in8 <= buffer_in(8);
in9 <= buffer_in(9);
in10 <= buffer_in(10);

-- In this process a buffer with all the input variables is filled
buffer_fill: process(clk)
  variable x : positive range 1 to n_in+1;
begin
  if rising_edge(clk) then
    if rst = '1' then
      buffer_in <= (others => (others => '1'));
      x := 1;
      start_reg <= '0';
    else
      if ready_in = '1' then
        buffer_in(x) <= data_in;
        x := x+1;
      end if;
      if x = n_in+1 then
        start_reg <= '1';
        x := 1;
      else
        start_reg <= '0';
      end if;   
    end if;
  end if;
end process;

-- This process synchronizes the start signal of the rbf module
start_proc : process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      i_start <= '0';
    else
      if start_reg = '1' then
        i_start <= '1';
      else
        i_start <= '0'; 
      end if;  
    end if;
  end if;
end process;

end beh ;
