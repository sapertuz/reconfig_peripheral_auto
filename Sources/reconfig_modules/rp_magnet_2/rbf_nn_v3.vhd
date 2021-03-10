----------------------------------------------------------------------------------
-- Company: UnB/PUCPR
-- Engineers: Daniel Munoz, Helon Ayala and Renato Sampaio
-- 
-- Create Date: 04-Mar-2021 | 2h22min4.7754sec
-- Design Name:  
-- Module Name:    rbf_nn_v1 - Behavioral   
-- Project Name:  
-- Target Devices:  
-- Tool versions:  
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
use IEEE.STD_LOGIC_arith.ALL; 
use IEEE.STD_LOGIC_unsigned.ALL; 
use work.entities.all; -- possui todas as entidades necessarias (gerada em MATLAB) 
use work.fpupack.all;  -- define os tipos e constantes  

entity rbf_nn_v3 is
    Port ( clk : in  STD_LOGIC;
           i_reset : in  STD_LOGIC;
           i_start : in  STD_LOGIC;
           in1 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in2 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in3 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in4 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in5 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in6 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in7 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in8 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in9 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           in10 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           rbf_nn_out : out  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           ready : out  STD_LOGIC);
end rbf_nn_v3;

architecture Behavioral of rbf_nn_v3 is

-- sinais

signal phi1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi3  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi4  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi5  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi6  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi7  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi8  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal phi   : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');

signal ready_nn1 : std_logic := '0'; 
signal ready_nn2 : std_logic := '0'; 
signal ready_nn3 : std_logic := '0'; 
signal ready_nn4 : std_logic := '0'; 
signal ready_nn5 : std_logic := '0'; 
signal ready_nn6 : std_logic := '0'; 
signal ready_nn7 : std_logic := '0'; 
signal ready_nn8 : std_logic := '0'; 

signal out_mul : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');

signal ready_mul : std_logic := '0';

signal start_as : std_logic := '0';
signal start_mul : std_logic := '0';
signal opA_as  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_as  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_as  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_as : std_logic := '0';

-- sinais usados no mux
signal sel_mux1   : std_logic_vector(3 downto 0) := (others=>'0');
constant bias : std_logic_vector(FP_WIDTH-1 downto 0) := "000000000000000000000";

constant w1 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001010000001101001";
constant w2 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001010010110000011";
constant w3 : std_logic_vector(FP_WIDTH-1 downto 0) := "110001111000101000010";
constant w4 : std_logic_vector(FP_WIDTH-1 downto 0) := "010000110001011011111";
constant w5 : std_logic_vector(FP_WIDTH-1 downto 0) := "010000110010101101000";
constant w6 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001111000110111101";
constant w7 : std_logic_vector(FP_WIDTH-1 downto 0) := "110010000000001001011";
constant w8 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001110101000110110";
signal w : std_logic_vector(FP_WIDTH-1 downto 0);

constant c1_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010000010011100";
constant c1_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101011011011010";
constant c1_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111100111110100101";
constant c1_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100000010111100";
constant c1_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100111000110011";
constant c1_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111000010010011";
constant c1_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000011111111100";
constant c1_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111110010011101";
constant c1_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001011100110110";
constant c1_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100011011111011";

constant c2_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110110000111110100";
constant c2_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111001101010001110";
constant c2_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111100010101011100";
constant c2_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110110001110110010";
constant c2_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100111110010101";
constant c2_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010000001001001";
constant c2_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000101001111011";
constant c2_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000101101010001";
constant c2_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101100101100101010";
constant c2_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101110001001100111";

constant c3_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110110010010000010";
constant c3_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111010101110001010";
constant c3_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111100001100011101";
constant c3_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100111100111011";
constant c3_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011000100100011";
constant c3_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010000101100111";
constant c3_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000111001111001";
constant c3_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111011111110110";
constant c3_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "101101111101111001100";
constant c3_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011001011010110";

constant c4_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111001000001011011";
constant c4_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111010010000001011";
constant c4_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111000100110110010";
constant c4_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110001011010010001";
constant c4_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110110011010000010";
constant c4_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010000110011000";
constant c4_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000101011001011";
constant c4_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010000011100111";
constant c4_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111000101111110";
constant c4_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001010000101000";

constant c5_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111011000101110001";
constant c5_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110100101010101110";
constant c5_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111010000010100001";
constant c5_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110100011010101011";
constant c5_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000001110100011";
constant c5_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "101101101110101110000";
constant c5_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000110001101110";
constant c5_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000011101111110";
constant c5_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011010111010101";
constant c5_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101110100000001100";

constant c6_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111011001001001100";
constant c6_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110101001011101010";
constant c6_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111100011101111011";
constant c6_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110100010100000110";
constant c6_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000110011100011";
constant c6_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000001101001001";
constant c6_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100101111101";
constant c6_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001100110101100";
constant c6_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010111010010000";
constant c6_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101000001010111";

constant c7_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111011011101010011";
constant c7_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110110000001001010";
constant c7_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111000100101110010";
constant c7_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101101111101001010000";
constant c7_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010110001100101";
constant c7_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000110110111111";
constant c7_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001111110101101";
constant c7_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010010000110000";
constant c7_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010111101110101";
constant c7_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101010100001111110";

constant c8_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110110000001110000";
constant c8_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111010001110111001";
constant c8_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111010110000010100";
constant c8_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101100011001111010";
constant c8_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101110110100100";
constant c8_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010011100001001";
constant c8_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001000101100001";
constant c8_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001101110110111";
constant c8_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "101101010100110100001";
constant c8_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001010100010100";


constant delta1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";
constant delta8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000100011110101";

type t_state is (waiting, neuronio_peso, multiplica, multiplica_acumula, acumula);
signal state : t_state;

begin
n1: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c1_1,
           c2 => c1_2,
           c3 => c1_3,
           c4 => c1_4,
           c5 => c1_5,
           c6 => c1_6,
           c7 => c1_7,
           c8 => c1_8,
           c9 => c1_9,
           c10 => c1_10,
           delta => delta1,
           phi => phi1,
           ready => ready_nn1);

n2: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c2_1,
           c2 => c2_2,
           c3 => c2_3,
           c4 => c2_4,
           c5 => c2_5,
           c6 => c2_6,
           c7 => c2_7,
           c8 => c2_8,
           c9 => c2_9,
           c10 => c2_10,
           delta => delta2,
           phi => phi2,
           ready => ready_nn2);

n3: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c3_1,
           c2 => c3_2,
           c3 => c3_3,
           c4 => c3_4,
           c5 => c3_5,
           c6 => c3_6,
           c7 => c3_7,
           c8 => c3_8,
           c9 => c3_9,
           c10 => c3_10,
           delta => delta3,
           phi => phi3,
           ready => ready_nn3);

n4: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c4_1,
           c2 => c4_2,
           c3 => c4_3,
           c4 => c4_4,
           c5 => c4_5,
           c6 => c4_6,
           c7 => c4_7,
           c8 => c4_8,
           c9 => c4_9,
           c10 => c4_10,
           delta => delta4,
           phi => phi4,
           ready => ready_nn4);

n5: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c5_1,
           c2 => c5_2,
           c3 => c5_3,
           c4 => c5_4,
           c5 => c5_5,
           c6 => c5_6,
           c7 => c5_7,
           c8 => c5_8,
           c9 => c5_9,
           c10 => c5_10,
           delta => delta5,
           phi => phi5,
           ready => ready_nn5);

n6: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c6_1,
           c2 => c6_2,
           c3 => c6_3,
           c4 => c6_4,
           c5 => c6_5,
           c6 => c6_6,
           c7 => c6_7,
           c8 => c6_8,
           c9 => c6_9,
           c10 => c6_10,
           delta => delta6,
           phi => phi6,
           ready => ready_nn6);

n7: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c7_1,
           c2 => c7_2,
           c3 => c7_3,
           c4 => c7_4,
           c5 => c7_5,
           c6 => c7_6,
           c7 => c7_7,
           c8 => c7_8,
           c9 => c7_9,
           c10 => c7_10,
           delta => delta7,
           phi => phi7,
           ready => ready_nn7);

n8: neuron_rbf_v3 port map (
		   clk => clk,
           reset => i_reset,
           start => i_start,
           x1 => in1,
           x2 => in2,
           x3 => in3,
           x4 => in4,
           x5 => in5,
           x6 => in6,
           x7 => in7,
           x8 => in8,
           x9 => in9,
           x10 => in10,
           c1 => c8_1,
           c2 => c8_2,
           c3 => c8_3,
           c4 => c8_4,
           c5 => c8_5,
           c6 => c8_6,
           c7 => c8_7,
           c8 => c8_8,
           c9 => c8_9,
           c10 => c8_10,
           delta => delta8,
           phi => phi8,
           ready => ready_nn8);

mul1 : multiplierfsm_v2
   port map (reset         => i_reset,
             clk           => clk,
             op_a          => phi,
             op_b          => w,
             start_i       => start_mul,
             mul_out       => out_mul,
             ready_mul     => ready_mul);

adsb1: addsubfsm_v6
   port map (reset         => i_reset,
             clk           => clk,
             op            => '0',
             op_a          => opA_as,
             op_b          => opB_as,
             start_i       => start_as,
             addsub_out    => out_as,
             ready_as      => ready_as);

process(clk,i_reset)
begin
      if rising_edge(clk) then
        if i_reset='1' then
            state<= waiting;
            ready <= '0';
            rbf_nn_out <= (others=>'0');
            sel_mux1 <= (others=>'0');
        else
          start_mul <= '0';
          start_as <= '0';
          case state is
            when waiting =>
              ready <= '0';
              if i_start='1' then
                state <= neuronio_peso;
              else
                state <= waiting;
              end if;
            when neuronio_peso =>
              ready <= '0';
              if ready_nn1 = '1' then
                start_mul <= '1';
                start_as <= '1';
                state<= multiplica;
              else
                state <= neuronio_peso;
              end if;
            when multiplica =>
                ready <= '0';
                if ready_mul = '1' then
                  sel_mux1 <= sel_mux1 + '1';
                  start_mul <= '1';
                  start_as <= '1';
                  state <= multiplica_acumula;
                else
                  state <= multiplica;
                  start_mul <= '0';
                  start_as <= '0';
                end if;
            when multiplica_acumula => 
              ready <= '0';
              if ready_mul = '1' then
                if sel_mux1 = "0111" then -- valor final dependente da quantidade de neuronios
                  start_mul <= '0';
                  start_as <= '1';            
                  state <= acumula;
                else
                  sel_mux1 <= sel_mux1 + '1';
                  start_mul <= '1';
                  start_as <= '1';
                  state <= multiplica_acumula;
                end if;
              else
                start_mul <= '0';
                start_as <= '0';
                state <= multiplica_acumula;
              end if;    
            when acumula =>
              start_as <= '0';
              start_mul <= '0';
              if ready_as = '1' then
                sel_mux1 <= (others=>'0');
                rbf_nn_out <= out_as;
                ready <= '1';
                state <= waiting;
              else
                state <= acumula;
              end if;
            when others => state <= waiting;
          end case;
        end if;
      end if;
    end process;

with state select
        opA_as <= (others => '0') when multiplica,
                    out_as when others;
with state select
        opB_as <= bias when multiplica,
                    out_mul when others;
with sel_mux1 select
   phi <= phi1 when "0000",
               phi2 when "0001",
               phi3 when "0010",
               phi4 when "0011",
               phi5 when "0100",
               phi6 when "0101",
               phi7 when "0110",
               phi8 when others;

with sel_mux1 select
   w <= w1 when "0000",
               w2 when "0001",
               w3 when "0010",
               w4 when "0011",
               w5 when "0100",
               w6 when "0101",
               w7 when "0110",
               w8 when others;

end Behavioral;
