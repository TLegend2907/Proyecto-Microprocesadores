library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proy1 is
    Port (
        clk   : in  STD_LOGIC;
        ini   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        -- ¡CORRECCIÓN! Reducido a 3 bits para coincidir con tu placa
        bt    : in  STD_LOGIC_VECTOR(2 downto 0);
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        rgb   : out STD_LOGIC_VECTOR(11 downto 0)
    );
end proy1;

architecture Behavioral of proy1 is

signal hcounti   : std_logic_vector(10 downto 0);
signal vcounti   : std_logic_vector(9 downto 0);
signal dir_val_i : std_logic_vector(11 downto 0);
signal dir_av_i  : std_logic_vector(11 downto 0);
signal data_val_i: std_logic_vector(2 downto 0);
signal data_av_i : std_logic_vector(0 downto 0);

signal clk_50    : std_logic := '0';
signal clk_25    : std_logic := '0';

begin

-- DIVISOR DE RELOJ
process(clk, reset)
begin
    if reset = '1' then
        clk_50 <= '0';
        clk_25 <= '0';
    elsif rising_edge(clk) then
        clk_50 <= not clk_50;
        if clk_50 = '1' then
            clk_25 <= not clk_25;
        end if;
    end if;
end process;

-- MAE (Máquina y Memorias)
c0: entity work.MAE
port map (
    clk      => clk,
    clk_25   => clk_25,
    ini      => ini,
    reset    => reset,
    dir_val  => dir_val_i,
    data_val => data_val_i,
    dir_av   => dir_av_i,
    data_av  => data_av_i,
    bt       => bt -- Aquí se transfiere el switch a los módulos internos
);

-- CONTROLADOR VGA
c1: entity work.vgac
port map (
    clk    => clk_25,
    reset  => reset,
    hsync  => hsync,
    vsync  => vsync,
    dir    => open,
    hcount => hcounti,
    vcount => vcounti
);

-- UNIDAD DE GRÁFICOS
c2: entity work.GU
port map (
    clk      => clk_25,
    data_val => data_val_i,
    data_av  => data_av_i,
    hcount   => hcounti,
    vcount   => vcounti,
    rgb      => rgb,
    dir_val  => dir_val_i,
    dir_av   => dir_av_i
);

end Behavioral;
