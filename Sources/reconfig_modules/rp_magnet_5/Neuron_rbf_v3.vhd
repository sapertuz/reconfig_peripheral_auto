----------------------------------------------------------------------------------
-- Company: UnB/PUCPR
-- Engineers: Daniel Munoz, Helon Ayala and Renato Sampaio
-- 
-- Create Date: 04-Mar-2021 | 2h22min5.5446sec
-- Design Name:  
-- Module Name:    neuron_rbf_v3 - Behavioral  
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
entity neuron_rbf_v3 is
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
end neuron_rbf_v3;

architecture Behavioral of neuron_rbf_v3 is

type RAM is array (FP_WIDTH-1 downto 0) of std_logic;
type RRAM is array (0 to 26) of RAM;
constant MEM : RRAM := ("001111100001100100111",
                        "001111010000010110001",
                        "001111000000000101011",
                        "001110110000000001010",
                        "001110100000000000010",
                        "001110010000000000000",
                        "001110000000000000000",
                        "001101110000000000000",
                        "001101100000000000000",
                        "001101010000000000000",
                        "001101000000000000000",
                        "001100110000000000000",
                        "001100100000000000000",
                        "001100010000000000000",
                        "001100000000000000000",
                        "001011110000000000000",
                        "001011100000000000000",
                        "001011010000000000000",
                        "001011000000000000000",
                        "001010110000000000000",
                        "001010100000000000000",
                        "001010010000000000000",
                        "001010000000000000000",
                        "001001110000000000000",
                        "001001100000000000000",
                        "001001010000000000000",
                        "001001000000000000000");

-- somadores
signal start_as1: std_logic := '0';
signal op_as1      : std_logic := '0';
signal opA_as1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_as1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_as1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_as1: std_logic := '0';

signal start_as2: std_logic := '0';
signal op_as2      : std_logic := '0';
signal opA_as2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_as2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_as2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_as2: std_logic := '0';

signal ready_as1_perm : std_logic := '0';
signal ready_as2_perm : std_logic := '0';
-- multiplicadores
signal start_mul1: std_logic := '0';
signal opA_mul1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_mul1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_mul1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_mul1: std_logic := '0';


-- exponencial CORDIC-Taylor
signal start_decX : std_logic := '0';
signal intX        : std_logic_vector(EXP_WIDTH-1 downto 0) := (others=> '0');
signal decX       : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_decX : std_logic := '0';

signal signAin     : std_logic := '0';
signal dW : std_logic_vector(FP_WIDTH-1 downto 0) := (others => '0');
signal atanh : std_logic_vector(FP_WIDTH-1 downto 0)  := (others=> '0');
signal signW : std_logic := '0';
signal signZ : std_logic := '0';
signal Iter  : std_logic_vector(4 downto 0) := "00001";

signal Ain : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');

signal phi_temp : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');

type t_state is (waiting,subtrair1,subtrair2,subtrair3,subtrair4,subtrair5,subtrair6,subtrair7,subtrair8,subtrair9,subtrair10,acc,mult_delta,espalhamento,prepara_arg_cordic,exp_reduc1,exp_decFP,exp_reduc2,taylor,taylor_mul,taylor_add,cordic,rotation);
signal state : t_state;
signal res_sub2 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal mux_signZ : std_logic;

begin

   adsb1: addsubfsm_v6
   port map (reset         => reset,
             clk           => clk,
             op            => op_as1,
             op_a          => opA_as1,
             op_b          => opB_as1,
             start_i       => start_as1,
             addsub_out    => out_as1,
             ready_as      => ready_as1);

   adsb2: addsubfsm_v6
   port map (reset         => reset,
             clk           => clk,
             op            => op_as2,
             op_a          => opA_as2,
             op_b          => opB_as2,
             start_i       => start_as2,
             addsub_out    => out_as2,
             ready_as      => ready_as2);

   mul1: multiplierfsm_v2
   port map (reset         => reset,
             clk           => clk,
             op_a          => opA_mul1,
             op_b          => opB_mul1,
             start_i       => start_mul1,
             mul_out       => out_mul1,
             ready_mul     => ready_mul1);

   CdecX1: decFP
   port map(reset  => reset,
            clk    => clk,
            start  => start_decX,
            Xin    => out_mul1,
            intX    => intX,
            decX    => decX,
            ready     => ready_decX);


-- Cordic uRotations
dW(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
dW(FP_WIDTH-2 downto FRAC_WIDTH) <= (out_as1(FP_WIDTH-2 downto FRAC_WIDTH) - Iter);
dW(FRAC_WIDTH-1  downto 0) <= out_as1(FRAC_WIDTH-1  downto 0);
signW <= '0' xor not(signZ);
mux_signZ <= out_as2(FP_WIDTH-1) when ((state = rotation)) else res_sub2(FP_WIDTH-1);
signZ <= '1' xor mux_signZ;
atanh <= STD_LOGIC_VECTOR(MEM(conv_integer(Iter-1)));
signAin <= Ain(FP_WIDTH-1);

process(clk,reset)
begin
    if rising_edge(clk) then
        if reset='1' then
            state <= waiting;
            start_as1  <= '0';
            start_as2  <= '0';
            start_mul1  <= '0';
            op_as1  <= '0';
            Iter <= "00001";
            start_decX <= '0';
            ready <= '0';
        else
        case state is
            when waiting =>
                  start_as1  <= '0';
                  start_as2  <= '0';
                  start_mul1 <= '0';
                  start_decX <= '0';
                  ready <= '0';
                  if start ='1' then
                  -- comeca o procedimento de excitamento do neuronio
                  -- passa para cada somatorio
                      opA_as1 <= x1;
                      opB_as1 <= c1;
                      start_as1 <= '1';
                      op_as1 <= '1';
                      state <= subtrair1;
                end if;

            when subtrair1 =>
                if ready_as1='1' then
                    opA_as1 <= x2;
                    opB_as1 <= c2;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    state <= subtrair2;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair1;
                end if;

            when subtrair2 =>
                if ready_mul1='1' then
                    opA_as1 <= x3;
                    opB_as1 <= c3;
                    res_sub2 <= out_as1;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= Zero;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair3;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair2;
                end if;

            when subtrair3 =>
                if ready_mul1='1' then
                    opA_as1 <= x4;
                    opB_as1 <= c4;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair4;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair3;
                end if;

            when subtrair4 =>
                if ready_mul1='1' then
                    opA_as1 <= x5;
                    opB_as1 <= c5;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair5;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair4;
                end if;

            when subtrair5 =>
                if ready_mul1='1' then
                    opA_as1 <= x6;
                    opB_as1 <= c6;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair6;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair5;
                end if;

            when subtrair6 =>
                if ready_mul1='1' then
                    opA_as1 <= x7;
                    opB_as1 <= c7;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair7;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair6;
                end if;

            when subtrair7 =>
                if ready_mul1='1' then
                    opA_as1 <= x8;
                    opB_as1 <= c8;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair8;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair7;
                end if;

            when subtrair8 =>
                if ready_mul1='1' then
                    opA_as1 <= x9;
                    opB_as1 <= c9;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair9;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair8;
                end if;

            when subtrair9 =>
                if ready_mul1='1' then
                    opA_as1 <= x10;
                    opB_as1 <= c10;
                    start_as1 <= '1';
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= subtrair10;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair9;
                end if;

            when subtrair10 =>
                if ready_mul1='1' then
                    opA_mul1 <= out_as1;
                    opB_mul1 <= out_as1;
                    start_mul1 <= '1';
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= acc;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= subtrair10;
                end if;

            when acc =>
                if ready_mul1='1' then
                    opA_as2 <= out_as2;
                    opB_as2 <= out_mul1;
                    start_as2 <= '1';
                    state <= mult_delta;
                else
                    start_as1 <= '0';
                    start_as2 <= '0';
                    start_mul1 <= '0';
                    state <= acc;
                end if;

            when mult_delta =>
                if ready_as2='1' then
                    opA_mul1 <= out_as2;
                    opB_mul1 <= delta;
                    start_mul1 <= '1';
                    state <= espalhamento;
                else
                    start_mul1 <= '0';
                    state <= mult_delta;
                end if;

            when espalhamento =>
                if ready_mul1='1' then
                    Ain(FP_WIDTH-1) <= '1';
                    Ain(FP_WIDTH-2 downto 0) <= out_mul1(FP_WIDTH-2 downto 0);
                    Iter <= "00001";
                    state <= prepara_arg_cordic;
                else
                    start_mul1 <= '0';
                    state <= espalhamento;
                end if;

            when prepara_arg_cordic =>
                if Ain = Zero then
                    phi_temp   <= s_one;
                    Iter  <= "00001";
                    ready <= '1';
                    state <= waiting;
                else
                    opA_mul1 <= Ain;
                    opB_mul1 <= log2e;
                    start_mul1 <= '1';
                    state <= exp_reduc1;
                end if;

            when exp_reduc1 =>
                start_mul1 <= '0';
                if ready_mul1='1' then
                    if out_mul1(FP_WIDTH-2 downto FRAC_WIDTH) > EXP_DF then
                        start_decX <= '0';
                       if Ain(FP_WIDTH-1)='0' then
                            phi_temp   <= Inf;
                        else
                           phi_temp   <= Zero;
                        end if;
                        Iter  <= "00001";
                        ready <= '1';
                        state <= waiting;
                    else
                        start_decX <= '1';
                        state <= exp_decFP;
                    end if;
                else
                    state <= exp_reduc1;
                end if;

            when exp_decFP =>
                start_decX <= '0';
                if ready_decX='1' then
                    opA_mul1 <= decX;
                    opB_mul1 <= ilog2e;
                    start_mul1 <= '1';
                    state <= exp_reduc2;
                else
                    state <= exp_decFP;
                end if;

            when exp_reduc2 =>
                start_mul1 <= '0';
                if ready_mul1='1' then
                    if out_mul1(FP_WIDTH-2 downto 0) < d_043(FP_WIDTH-2 downto 0) then  -- activa correccion por taylor
                        state <= taylor;
                    else
                        Iter <= "00001";
                        state <= cordic;
                    end if;
                else
                    state <= exp_reduc2;
                end if;

            when taylor =>
                if out_mul1 = Zero then
                    phi_temp     <= s_one;
                    ready   <= '1';
                    state   <= waiting;
                else
                    opA_mul1 <= out_mul1;
                    opB_mul1 <= out_mul1;
                    start_mul1 <= '1';
                    op_as1  <= '0';
                    opA_as1 <= s_one;
                    opB_as1 <= out_mul1;
                    start_as1 <= '1';
                    state <= taylor_mul;
                end if;

            when taylor_mul =>
                start_mul1 <= '0';
                start_as1 <= '0';
                if ready_as1 = '1' then
                    op_as1  <= '0';
                    opA_as1 <= out_as1;
                    opB_as1(FP_WIDTH-1) <= '0';
                    opB_as1(FP_WIDTH-2 downto FRAC_WIDTH) <= out_mul1(FP_WIDTH-2 downto FRAC_WIDTH) - '1';
                    opB_as1(FRAC_WIDTH-1 downto 0) <= out_mul1(FRAC_WIDTH-1 downto 0); 
                    start_as1 <= '1';
                    state   <= taylor_add;
                else 
                    state <= taylor_mul;
                end if;

            when taylor_add =>
                start_as1 <= '0';
                if ready_as1 = '1' then
                    phi_temp(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
                    if signAin = '0' then
                        phi_temp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) + intX;
                    else 
                        phi_temp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) - intX;
                    end if;
                    phi_temp(FRAC_WIDTH-1 downto 0) <= out_as1(FRAC_WIDTH-1 downto 0);
                    ready   <= '1';
                    state   <= waiting;
                else
                    state <= taylor_add;
                end if;

            when cordic =>
                start_as1 <= '0';
                start_as2 <= '0';
                if out_mul1 = Zero then
                    phi_temp     <= s_one;
                    ready <= '1';
                    state <= waiting;
                else
                    if out_mul1(FP_WIDTH-1) = '0' then 
                        op_as2 <= '1';
                        op_as1 <= '0';
                    else
                        op_as2 <= '0';
                        op_as1 <= '1';
                    end if;
                    opA_as1 <= Phyp;
                    opB_as1(FP_WIDTH-1) <= Phyp(FP_WIDTH-1);
                    opB_as1(FP_WIDTH-2 downto FRAC_WIDTH) <= (Phyp(FP_WIDTH-2 downto FRAC_WIDTH) - Iter);
                    opB_as1(FRAC_WIDTH-1 downto 0) <= Phyp(FRAC_WIDTH-1  downto 0);
                    start_as1 <= '1';
                    opA_as2 <= out_mul1;
                    opB_as2 <= atanh;
                    start_as2 <= '1';
                    Iter <= Iter+'1';
                    state <= rotation;
                end if;

            when rotation =>
                start_as1 <= '0';
                start_as2 <= '0';
                if ((ready_as1 = '1' and ready_as2 = '1') or (ready_as1_perm = '1' and ready_as2 = '1') or (ready_as1 = '1' and ready_as2_perm = '1') or (ready_as1_perm = '1' and ready_as2_perm = '1')) then
                    ready_as1_perm <= '0';
                    ready_as2_perm <= '0';
                    op_as1  <= signW;
                    opA_as1 <= out_as1;
                    opB_as1 <= dW;
                    op_as2  <= signZ;
                    opA_as2 <= out_as2;
                    opB_as2 <= atanh;
                    if Iter = MAX_ITER_CORDIC then
                        phi_temp(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
                        if signAin = '0' then
                            phi_temp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) + intX;
                        else 
                            phi_temp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) - intX;
                        end if;
                        phi_temp(FRAC_WIDTH-1 downto 0) <= out_as1(FRAC_WIDTH-1 downto 0);
                       ready <= '1';
                        state <= waiting;
                    else
                        Iter <= Iter+'1';
                        start_as1 <= '1';
                        start_as2 <= '1';
                        state <= rotation;
                    end if;
                else
                    state <= rotation;
                end if;

            when others => state <= waiting;
        end case;
        end if;
        if ready_as1 = '1' then
            ready_as1_perm <= '1';
        end if;
        if ready_as2 = '1' then
            ready_as2_perm <= '1';
        end if;
    end if;
end process;

phi <= phi_temp when phi_temp(FP_WIDTH-2) = '0' else s_one;

end Behavioral;
