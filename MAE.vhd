library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MAE is
    Port (
        clk    : in  STD_LOGIC;
        clk_25 : in  STD_LOGIC;
        ini    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        dir_val  : in  STD_LOGIC_VECTOR(11 downto 0);
        data_val : out STD_LOGIC_VECTOR(2 downto 0);
        dir_av   : in  STD_LOGIC_VECTOR(11 downto 0);
        data_av  : out STD_LOGIC_VECTOR(0 downto 0);
        bt       : in  STD_LOGIC_VECTOR(2 downto 0)
    );
end MAE;

architecture Behavioral of MAE is

signal we_val  : std_logic_vector(0 downto 0);
signal ab_val  : std_logic_vector(11 downto 0);
signal dbi_val : std_logic_vector(2 downto 0);
signal dbo_val : std_logic_vector(2 downto 0);

signal we_av   : std_logic_vector(0 downto 0);
signal ab_av   : std_logic_vector(11 downto 0);
signal dbi_av  : std_logic_vector(0 downto 0);

signal rx      : std_logic_vector(5 downto 0);
signal ry      : std_logic_vector(5 downto 0);
signal rval    : std_logic_vector(1 downto 0);
signal en      : std_logic;

begin

-- ASM (El Cerebro)
c0: entity work.ASM
port map (
    clk     => clk,
    ini     => ini,
    reset   => reset,
    
    we_val  => we_val,
    ab_val  => ab_val,
    dbi_val => dbi_val,
    dbo_val => dbo_val,
    
    we_av   => we_av,
    ab_av   => ab_av,
    dbi_av  => dbi_av,
    
    -- PUENTE DE LOS SWITCHES FÍSICOS
    cinit   => bt(0),
    op      => bt(1),  -- Conectado de forma segura
    gran    => bt(2),
    
    rx      => rx,
    ry      => ry,
    rval    => rval,
    en      => en
);

-- MEMORIA VALORES (3 bits)
c1: entity work.memi_val
port map (
    clka  => clk,
    wea   => we_val,
    addra => ab_val,
    dina  => dbi_val,
    douta => dbo_val,
    clkb  => clk_25,
    web   => "0",
    addrb => dir_val,
    dinb  => "000",
    doutb => data_val
);

-- MEMORIA AVALANCHAS (1 bit)
c2: entity work.memi_av
port map (
    clka  => clk,
    wea   => we_av,
    addra => ab_av,
    dina  => dbi_av,
    douta => open,
    clkb  => clk_25,
    web   => "0",
    addrb => dir_av,
    dinb  => "0",
    doutb => data_av
);

-- PRNG
c3: entity work.PRNG
port map (
    clk   => clk,
    reset => reset,
    en    => en,
    rx    => rx,
    ry    => ry,
    rval  => rval
);

end Behavioral;
