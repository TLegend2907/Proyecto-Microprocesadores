----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:40:26 02/13/2015 
-- Design Name: 
-- Module Name:    GM - Behavioral 
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

library work;
use work.proyecto1pack.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAE is
    Port ( clk : in  STD_LOGIC;
           dir : in  STD_LOGIC_VECTOR (11 downto 0);
           data : out  STD_LOGIC_VECTOR (0 downto 0));
end MAE;

architecture Behavioral of GM is

signal we : std_logic_vector( 0 downto 0);
signal adb : std_logic_vector (11 downto 0);
signal dbi : std_logic_vector (0 downto 0);
signal dbo : std_logic_vector (0 downto 0);

begin

c1: mem port map
( clk,we,adb,dbi,dbo,clk,"0",dir,"0",data);

end Behavioral;

