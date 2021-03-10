----------------------------------------------------------------------------------
-- Company: UnB/PUCPR
-- Engineers: Daniel Munoz, Helon Ayala and Renato Sampaio
-- 
-- Create Date: 04-Mar-2021 | 2h22min5.564sec
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

constant w1 : std_logic_vector(FP_WIDTH-1 downto 0) := "110001011101111010101";
constant w2 : std_logic_vector(FP_WIDTH-1 downto 0) := "010010000101010011110";
constant w3 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001110101010011101";
constant w4 : std_logic_vector(FP_WIDTH-1 downto 0) := "110001100010000101110";
constant w5 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001010101100011010";
constant w6 : std_logic_vector(FP_WIDTH-1 downto 0) := "110010000001011110000";
constant w7 : std_logic_vector(FP_WIDTH-1 downto 0) := "110001110101101001001";
constant w8 : std_logic_vector(FP_WIDTH-1 downto 0) := "010001001110111011010";
signal w : std_logic_vector(FP_WIDTH-1 downto 0);

constant c1_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111010000101110001";
constant c1_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001110100111110";
constant c1_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101101101000011111";
constant c1_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111010110111110001";
constant c1_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010110101110110";
constant c1_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100010111010111";
constant c1_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001000110001101";
constant c1_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101100110100011";
constant c1_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000111010101100";
constant c1_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111011010011110";

constant c2_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111010101000101011";
constant c2_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101110000010111";
constant c2_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011000101111011";
constant c2_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111011101000010000";
constant c2_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011000101110000";
constant c2_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100100010001111";
constant c2_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000010100111100";
constant c2_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010011100011011";
constant c2_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000101011001010";
constant c2_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "101101100010011011100";

constant c3_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101101110110011";
constant c3_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110110101000010111";
constant c3_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011101000001001";
constant c3_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111100111101100000";
constant c3_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011010000011111";
constant c3_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110010011010101000";
constant c3_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000000010001100";
constant c3_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100101000100001";
constant c3_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000001010011010";
constant c3_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100011100110101";

constant c4_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110001101011111001";
constant c4_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111010101111000100";
constant c4_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000000001111010";
constant c4_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110111001011110100";
constant c4_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001011101111110";
constant c4_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110010110001101010";
constant c4_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111101101111110";
constant c4_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110110110110010100";
constant c4_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001000001000001";
constant c4_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101110100000101011";

constant c5_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111010100100100000";
constant c5_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000001000010000";
constant c5_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000011101111010";
constant c5_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111100010011001101";
constant c5_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010101000101000";
constant c5_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101111000011100";
constant c5_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000011110000100";
constant c5_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110010100110000010";
constant c5_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101110111111010111";
constant c5_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100100011001110";

constant c6_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111010011000000111";
constant c6_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110111101111010001";
constant c6_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110010000110100110";
constant c6_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111001001000110111";
constant c6_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010101001110010";
constant c6_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101011110001111";
constant c6_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001011110010111";
constant c6_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000000100110111";
constant c6_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000111010100101";
constant c6_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000110101001100";

constant c7_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101110000110001";
constant c7_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110011101001010110";
constant c7_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001011000010111";
constant c7_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111101000011001101";
constant c7_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110010110110000100";
constant c7_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001001011110110";
constant c7_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110001011000101011";
constant c7_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110110111101001000";
constant c7_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110000101010011010";
constant c7_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110101001011001010";

constant c8_1 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110101111101011001";
constant c8_2 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110111101101111110";
constant c8_3 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110010001110000110";
constant c8_4 : std_logic_vector(FP_WIDTH-1 downto 0) := "101111001000101000111";
constant c8_5 : std_logic_vector(FP_WIDTH-1 downto 0) := "001110100000101110100";
constant c8_6 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110111100101010010";
constant c8_7 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101110010001011100";
constant c8_8 : std_logic_vector(FP_WIDTH-1 downto 0) := "101110010010001001110";
constant c8_9 : std_logic_vector(FP_WIDTH-1 downto 0) := "001101111010011011001";
constant c8_10 : std_logic_vector(FP_WIDTH-1 downto 0) := "101101010101110101000";


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
