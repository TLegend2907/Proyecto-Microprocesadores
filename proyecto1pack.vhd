library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package proyecto1pack is

-- ASM
component ASM is
    Port (
        clk     : in  STD_LOGIC;
        ini     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        we_val  : out STD_LOGIC_VECTOR(0 downto 0);
        ab_val  : out STD_LOGIC_VECTOR(11 downto 0);
        -- ¡CORRECCIÓN! Ajustado a 3 bits
        dbi_val : out STD_LOGIC_VECTOR(2 downto 0);
        dbo_val : in  STD_LOGIC_VECTOR(2 downto 0);
        we_av   : out STD_LOGIC_VECTOR(0 downto 0);
        ab_av   : out STD_LOGIC_VECTOR(11 downto 0);
        dbi_av  : out STD_LOGIC_VECTOR(0 downto 0);
        cinit   : in  STD_LOGIC;
        op      : in  STD_LOGIC;
        gran    : in  STD_LOGIC;
        rx      : in  STD_LOGIC_VECTOR(5 downto 0);
        ry      : in  STD_LOGIC_VECTOR(5 downto 0);
        rval    : in  STD_LOGIC_VECTOR(1 downto 0);
        en      : out STD_LOGIC
    );
end component;

-- MAE
component MAE is
    Port (
        clk      : in  STD_LOGIC;
        clk_25   : in  STD_LOGIC;
        ini      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        dir_val  : in  STD_LOGIC_VECTOR(11 downto 0);
        data_val : out STD_LOGIC_VECTOR(2 downto 0);
        dir_av   : in  STD_LOGIC_VECTOR(11 downto 0);
        data_av  : out STD_LOGIC_VECTOR(0 downto 0);
        bt       : in  STD_LOGIC_VECTOR(2 downto 0)
    );
end component;

-- GU
component GU is
    Port (
        clk      : in  STD_LOGIC;
        data_val : in  STD_LOGIC_VECTOR(2 downto 0);
        data_av  : in  STD_LOGIC_VECTOR(0 downto 0);
        hcount   : in  STD_LOGIC_VECTOR(10 downto 0);
        vcount   : in  STD_LOGIC_VECTOR(9 downto 0);
        rgb      : out STD_LOGIC_VECTOR(11 downto 0);
        dir_val  : out STD_LOGIC_VECTOR(11 downto 0);
        dir_av   : out STD_LOGIC_VECTOR(11 downto 0)
    );
end component;

-- VGAC
component vgac is
    Port ( 
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        hsync  : out STD_LOGIC;
        vsync  : out STD_LOGIC;
        dir    : out STD_LOGIC_VECTOR (11 downto 0);
        hcount : out STD_LOGIC_VECTOR (10 downto 0);
        vcount : out STD_LOGIC_VECTOR (9 downto 0)
    );
end component;

end proyecto1pack;