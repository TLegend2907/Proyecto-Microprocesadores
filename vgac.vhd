
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vgac is
    Port ( 
        clk    : in  STD_LOGIC; -- clk_25
        reset  : in  STD_LOGIC;
        hsync  : out STD_LOGIC;
        vsync  : out STD_LOGIC;
        dir    : out STD_LOGIC_VECTOR (11 downto 0);
        hcount : out STD_LOGIC_VECTOR (10 downto 0);
        vcount : out STD_LOGIC_VECTOR (9 downto 0)
    );
end vgac;

architecture Behavioral of vgac is

signal hc : unsigned(10 downto 0) := (others => '0');
signal vc : unsigned(9 downto 0)  := (others => '0');

begin

-- ================= CONTADOR HORIZONTAL =================
process(clk, reset)
begin
    if reset = '1' then
        hc <= (others => '0');
    elsif rising_edge(clk) then
        if hc = 799 then
            hc <= (others => '0');
        else
            hc <= hc + 1;
        end if;
    end if;
end process;

-- ================= CONTADOR VERTICAL =================
process(clk, reset)
begin
    if reset = '1' then
        vc <= (others => '0');
    elsif rising_edge(clk) then
        if hc = 799 then
            if vc = 524 then
                vc <= (others => '0');
            else
                vc <= vc + 1;
            end if;
        end if;
    end if;
end process;

-- ================= SINCRONIZACIÓN VGA =================

-- Pulso horizontal (96 clocks)
hsync <= '0' when (hc >= 656 and hc < 752) else '1';

-- Pulso vertical (2 líneas)
vsync <= '0' when (vc >= 490 and vc < 492) else '1';

-- ================= SALIDAS =================

hcount <= std_logic_vector(hc);
vcount <= std_logic_vector(vc);

-- ================= DIRECCIONAMIENTO =================
-- Mapeo a matriz 64x64 (cada pixel grande)

dir <= std_logic_vector(vc(7 downto 2) & hc(7 downto 2));

end Behavioral;