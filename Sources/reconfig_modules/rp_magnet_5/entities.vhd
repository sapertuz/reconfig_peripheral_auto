----------------------------------------------------------------------------------
-- Company: UnB/PUCPR
-- Engineers: Daniel Munoz, Helon Ayala, Renato Sampaio, Carlos Eduardo Santos e Guillermo Alvarez
-- 
-- Create Date: 04-Mar-2021 | 2h22min5.6111sec
-- Module name:   entities
-- Description:   package defining IO of the components
-- Automatically generated using the entities_gen.m 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

package Entities is

component neuron_rbf_v3
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           x1 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x2 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x3 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x4 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x5 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x6 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x7 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x8 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x9 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           x10 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c1 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c2 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c3 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c4 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c5 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c6 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c7 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c8 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c9 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           c10 : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           delta : in  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0); -- espalhamento -> delta = 1/sigma^2
           phi : out  STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0); -- saida do neuronio
           ready : out  STD_LOGIC);
end component;

component lfsr_fixtofloat_20bits	is
port (reset     :  in std_logic;
      clk       :  in std_logic;
      start     :  in std_logic;
      istart    :  in std_logic;
      init      :  in std_logic_vector(15 downto 0);
      lfsr_out  : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready     : out std_logic);
end component;

component addsubfsm_v6 is
port (reset     :  in std_logic;
      clk       :  in std_logic;
      op        :  in std_logic;
      op_a    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      op_b    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      start_i	 :  in std_logic;
      addsub_out : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready_as  : out std_logic);
end component;

component multiplierfsm_v2 is
port (reset     :  in std_logic;
      clk       :  in std_logic;
      op_a    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      op_b    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      start_i	 :  in std_logic;
      mul_out   : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready_mul : out std_logic);
end component;

component cordic_exp
	port(reset	:  in std_logic;
	     clk	:  in std_logic;
		 start	:  in std_logic;
		 Ain	:  in std_logic_vector(FP_WIDTH-1 downto 0);
		 exp    : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready  : out std_logic);
end component;

component decFP is
port (reset    :  in std_logic;
      start	   :  in std_logic;
      clk      :  in std_logic;
      Xin      :  in std_logic_vector(FP_WIDTH-1 downto 0);
      intX     : out std_logic_vector(EXP_WIDTH-1 downto 0);
      decX     : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready    : out std_logic);
end component;

component serialcom
port( reset		:  in std_logic;
	   clk 			:  in std_logic;
	   start   	  	:  in std_logic;
        d1          :  in std_logic_vector(FP_WIDTH-1 downto 0);
		din     	:  in std_logic;
		data        : out std_logic_vector(7 downto 0);
		rdy_data    : out std_logic;
		dout        : out std_logic);
end component;

component divNR is
  port (reset      :  in std_logic;
      clk        :  in std_logic;
      op_a     :  in std_logic_vector(FP_WIDTH-1 downto 0);
      op_b     :  in std_logic_vector(FP_WIDTH-1 downto 0);
      start_i    :  in std_logic;
      div_out    : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready_div  : out std_logic);
end component;

component fixMul
port (op_a    	 :  in std_logic_vector(FRAC_WIDTH downto 0);
      op_b    	 :  in std_logic_vector(FRAC_WIDTH downto 0);
      mul_out   : out std_logic_vector(FRAC_WIDTH*2+1 downto 0));
end component;
end Entities;
