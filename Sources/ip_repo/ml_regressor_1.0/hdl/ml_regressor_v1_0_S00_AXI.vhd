library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fpupack.all;

entity ml_regressor_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


        -- Ports of Axi Slave Bus Interface S00_AXI
        -- Clock and Reset
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
        -- Write Address Channel
        s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
        -- Write Data Channel
        s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
        -- Write Response Channel
        s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
        -- Read Address Channel
        s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
        -- Read Data Channel
        s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic
	);
end ml_regressor_v1_0_S00_AXI;

architecture arch_imp of ml_regressor_v1_0_S00_AXI is

    constant SINGLE_FRAC_WIDTH : integer := 23;
    constant SINGLE_EXP_WIDTH : integer := 8;
    constant SINGLE_FP_WIDTH : integer:= SINGLE_FRAC_WIDTH + SINGLE_EXP_WIDTH + 1;
    
-- Functions
    function single2custom (single_in : STD_LOGIC_VECTOR(SINGLE_FP_WIDTH-1 downto 0))
    return STD_LOGIC_VECTOR is
        constant EXP_S2C_IH : integer := SINGLE_FP_WIDTH - 2;
        constant EXP_S2C_IL : integer := SINGLE_FRAC_WIDTH;
        
        constant FRAC_S2C_IH : integer := SINGLE_FRAC_WIDTH - 1;
        constant FRAC_S2C_IL : integer := SINGLE_FRAC_WIDTH - 1 - FRAC_WIDTH + 1;

        constant single_max_exp : integer := 2**(SINGLE_EXP_WIDTH-1);
        constant custom_max_exp : integer := 2**(EXP_WIDTH-1);
        
        variable single_exp_val : integer;
        variable single_exp_new_val : integer;
        
        variable custom_out : STD_LOGIC_VECTOR(FP_WIDTH-1 downto 0);
        variable custom_sign : STD_LOGIC;
        variable custom_exp : STD_LOGIC_VECTOR(EXP_WIDTH-1 downto 0);
        variable custom_frac : STD_LOGIC_VECTOR(FRAC_WIDTH-1 downto 0);
    begin
        custom_sign := single_in(SINGLE_FP_WIDTH-1);
        single_exp_val  :=  to_integer(signed(single_in(EXP_S2C_IH downto  EXP_S2C_IL)));
        if (single_in(EXP_S2C_IH) = '0') then
            single_exp_new_val :=  custom_max_exp - (single_max_exp - single_exp_val);
        else
            single_exp_new_val := -custom_max_exp + (single_max_exp + single_exp_val);
        end if;
        if ((single_exp_new_val > custom_max_exp) or (-single_exp_new_val < -custom_max_exp)) then
            custom_out := (others => '0');
        else
            custom_exp := std_logic_vector(to_unsigned(single_exp_new_val, custom_exp'length));
            custom_frac := single_in(FRAC_S2C_IH downto FRAC_S2C_IL);
            custom_out := custom_sign & custom_exp & custom_frac;
        end if;   
        return custom_out;
    end single2custom; 

    function custom2single (custom_in : STD_LOGIC_VECTOR(FP_WIDTH-1 downto 0))
    return STD_LOGIC_VECTOR is
        constant EXP_C2S_IH : integer := FP_WIDTH - 2;
        constant EXP_C2S_IL : integer := FRAC_WIDTH;
        
        constant FRAC_C2S_OH : integer := SINGLE_FRAC_WIDTH - 1;
        constant FRAC_C2S_OL : integer := SINGLE_FRAC_WIDTH - 1 - FRAC_WIDTH + 1;

        constant single_max_exp : integer := 2**(SINGLE_EXP_WIDTH-1);
        constant custom_max_exp : integer := 2**(EXP_WIDTH-1);
        
        variable custom_exp_val : integer;
        variable custom_exp_new_val : integer;
        
        variable single_out : STD_LOGIC_VECTOR(SINGLE_FP_WIDTH-1 downto 0);
        variable single_sign : STD_LOGIC;
        variable single_exp : STD_LOGIC_VECTOR(SINGLE_EXP_WIDTH-1 downto 0);
        variable single_frac : STD_LOGIC_VECTOR(SINGLE_FRAC_WIDTH-1 downto 0);
    begin
        single_sign := custom_in(FP_WIDTH-1);
        custom_exp_val  :=  to_integer(signed(custom_in(EXP_C2S_IH downto EXP_C2S_IL)));
        if (custom_in(EXP_C2S_IH) = '0') then
            custom_exp_new_val :=  single_max_exp - (custom_max_exp - custom_exp_val);
        else
            custom_exp_new_val := -single_max_exp + (custom_max_exp + custom_exp_val);
        end if;
        single_exp  := std_logic_vector(to_unsigned(custom_exp_new_val, single_exp'length));
        single_frac(FRAC_C2S_OH downto FRAC_C2S_OL) := custom_in(FRAC_WIDTH - 1 downto 0);
        if (FRAC_WIDTH < SINGLE_FRAC_WIDTH) then
            single_frac(FRAC_C2S_OL-1 downto 0) := (others => '0');                 
        end if;
        
        single_out := single_sign & single_exp & single_frac;
        return single_out;
    end custom2single; 

-- component declaration
component wrapper_regressor is
    Port ( clk : in std_logic;
           rst : in std_logic;
           
           data_in : in STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           ready_in : in STD_LOGIC;
           
           data_out : out STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
           ready_out : out STD_LOGIC);
end component wrapper_regressor;	

-- AXI4LITE signals
signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_awready	: std_logic;
signal axi_wready	: std_logic;
signal axi_bresp	: std_logic_vector(1 downto 0);
signal axi_bvalid	: std_logic;
signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_arready	: std_logic;
signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rresp	: std_logic_vector(1 downto 0);
signal axi_rvalid	: std_logic;

-- Example-specific design signals
-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
-- ADDR_LSB is used for addressing 32/64 bit registers/memories
-- ADDR_LSB = 2 for 32 bits (n downto 2)
-- ADDR_LSB = 3 for 64 bits (n downto 3)
constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
constant OPT_MEM_ADDR_BITS : integer := 1;

--------------------------------------------------
---- Signals for user logic register space example
--------------------------------------------------

signal slv_reg	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg_rden	: std_logic;
signal slv_reg_wren	: std_logic;
signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal byte_index	: integer;
signal aw_en	: std_logic;

-- Signals for Modules
signal clk : std_logic;
signal rst : std_logic;
signal data_in : STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
signal ready_in : STD_LOGIC;
signal data_out : STD_LOGIC_VECTOR (FP_WIDTH-1 downto 0);
signal ready_out : STD_LOGIC;

begin

    -- Instantiation of module
    my_regressor: wrapper_regressor Port Map(
        clk     => clk,
        rst     => rst,
        data_in => data_in,
        ready_in=> ready_in,
        data_out=> data_out,
        ready_out=> ready_out
    );

    -- I/O Connections assignments

    S_AXI_AWREADY	<= axi_awready;
    S_AXI_WREADY	<= axi_wready;
    S_AXI_BRESP	<= axi_bresp;
    S_AXI_BVALID	<= axi_bvalid;
    S_AXI_ARREADY	<= axi_arready;
    S_AXI_RDATA	<= axi_rdata;
    S_AXI_RRESP	<= axi_rresp;
    S_AXI_RVALID	<= axi_rvalid;
    
    data_in <= single2custom(slv_reg);
    rst <= not(s_axi_aresetn);
    clk <= s_axi_aclk;

    -- Implement axi_awready generation
    -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    -- de-asserted when reset is low.

    process (S_AXI_ACLK)
    begin
    if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
        axi_awready <= '0';
        aw_en <= '1';
        else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            -- slave is ready to accept write address when
            -- there is a valid write address and write data
            -- on the write address and data bus. This design 
            -- expects no outstanding transactions. 
            axi_awready <= '1';
        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
            aw_en <= '1';
            axi_awready <= '0';
        else
            axi_awready <= '0';
        end if;
        end if;
    end if;
    end process;

    -- Implement axi_awaddr latching
    -- This process is used to latch the address when both 
    -- S_AXI_AWVALID and S_AXI_WVALID are valid. 

    process (S_AXI_ACLK)
    begin
    if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
        axi_awaddr <= (others => '0');
        else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            -- Write Address latching
            axi_awaddr <= S_AXI_AWADDR;
        end if;
        end if;
    end if;                   
    end process; 

    -- Implement axi_wready generation
    -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    -- de-asserted when reset is low. 

    process (S_AXI_ACLK)
    begin
    if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
        axi_wready <= '0';
        else
        if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
            -- slave is ready to accept write data when 
            -- there is a valid write address and write data
            -- on the write address and data bus. This design 
            -- expects no outstanding transactions.           
            axi_wready <= '1';
        else
            axi_wready <= '0';
        end if;
        end if;
    end if;
    end process; 

    -- Implement memory mapped register select and write logic generation
    -- The write data is accepted and written to memory mapped registers when
    -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    -- select byte enables of slave registers while writing.
    -- These registers are cleared when reset (active low) is applied.
    -- Slave register write enable is asserted when valid address and data are available
    -- and the slave is ready to accept the write address and write data.
    slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

    process (S_AXI_ACLK)
    variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
    begin
    if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
        slv_reg <= (others => '0');
        ready_in <= '0';
        else
        loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        if (slv_reg_wren = '1') then
            case loc_addr is
            when b"00" =>
                --if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- slave registor
                    slv_reg <= S_AXI_WDATA;
                    -- start module
                    ready_in <= '1';
                --end if;
            when others =>
                slv_reg <= slv_reg;
                ready_in <= '0';
            end case;
        end if;
        end if;
    end if;                   
    end process; 

    -- Implement write response logic generation
    -- The write response and response valid signals are asserted by the slave 
    -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    -- This marks the acceptance of address and indicates the status of 
    -- write transaction.

    process (S_AXI_ACLK)
    begin
    if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
        axi_bvalid  <= '0';
        axi_bresp   <= "00"; --need to work more on the responses
        else
        if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
            axi_bvalid <= '1';
            axi_bresp  <= "00"; 
        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
            axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
        end if;
        end if;
    end if;                   
    end process; 

    -- Implement axi_arready generation
    -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
    -- S_AXI_ARVALID is asserted. axi_awready is 
    -- de-asserted when reset (active low) is asserted. 
    -- The read address is also latched when S_AXI_ARVALID is 
    -- asserted. axi_araddr is reset to zero on reset assertion.

    process (S_AXI_ACLK)
    begin
    if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_araddr  <= (others => '1');
        else
        if (axi_arready = '0' and S_AXI_ARVALID = '1') then
            -- indicates that the slave has acceped the valid read address
            axi_arready <= '1';
            -- Read Address latching 
            axi_araddr  <= S_AXI_ARADDR;           
        else
            axi_arready <= '0';
        end if;
        end if;
    end if;                   
    end process; 

    -- Implement axi_arvalid generation
    -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    -- data are available on the axi_rdata bus at this instance. The 
    -- assertion of axi_rvalid marks the validity of read data on the 
    -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
    -- cleared to zero on reset (active low).  
    process (S_AXI_ACLK)
    begin
    if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
        axi_rvalid <= '0';
        axi_rresp  <= "00";
        else
        if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
            -- Valid read data is available at the read data bus
            axi_rvalid <= '1';
            axi_rresp  <= "00"; -- 'OKAY' response
        elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            -- Read data is accepted by the master
            axi_rvalid <= '0';
        end if;            
        end if;
    end if;
    end process;

    -- Implement memory mapped register select and read logic generation
    -- Slave register read enable is asserted when valid address is available
    -- and the slave is ready to accept the read address.
    slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

    process (axi_araddr, S_AXI_ARESETN, slv_reg_rden, ready_out, data_out)
    variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
        -- Address decoding for reading registers
        loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        case loc_addr is
        when b"00" =>
            reg_data_out <= custom2single(data_out); 
--            reg_data_out <= data_out;
        when others =>
            reg_data_out <= (others => '0');
        end case;
    end process; 

    -- Output register or memory read data
    process( S_AXI_ACLK ) is
    begin
    if (rising_edge (S_AXI_ACLK)) then
        if ( S_AXI_ARESETN = '0' ) then
        axi_rdata  <= (others => '0');
        else
        if (slv_reg_rden = '1') then
            -- When there is a valid read address (S_AXI_ARVALID) with 
            -- acceptance of read address by the slave (axi_arready), 
            -- output the read dada 
            -- Read address mux
            axi_rdata <= reg_data_out;     -- register read data
        end if;   
        end if;
    end if;
    end process;

end arch_imp;