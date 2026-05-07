----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:18:01 04/26/2026 
-- Design Name: 
-- Module Name:    PRNG - Behavioral 
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

entity PRNG is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        en    : in  STD_LOGIC;
        rx    : out STD_LOGIC_VECTOR(5 downto 0);
        ry    : out STD_LOGIC_VECTOR(5 downto 0);
        rval  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end PRNG;

architecture Behavioral of PRNG is

-- ¡CORRECCIÓN CRÍTICA! Se fuerza la semilla para que no inicie en ceros
signal lfsr : STD_LOGIC_VECTOR(13 downto 0) := "11001010110101";
signal feedback : STD_LOGIC;

begin

feedback <= lfsr(13) xor lfsr(12) xor lfsr(11) xor lfsr(1);

process(clk, reset)
begin
    if reset = '1' then
        lfsr <= "11001010110101"; -- Reinicia con una semilla válida
    elsif rising_edge(clk) then
        if en = '1' then
            lfsr <= lfsr(12 downto 0) & feedback;
        end if;
    end if;
end process;

rx   <= lfsr(5 downto 0);
ry   <= lfsr(11 downto 6);
rval <= lfsr(1 downto 0);

end Behavioral;
