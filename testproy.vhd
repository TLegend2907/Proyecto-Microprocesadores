--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:58:16 05/03/2019
-- Design Name:   
-- Module Name:   C:/admictemp/proyecto1bp/testproy.vhd
-- Project Name:  proyecto1bp
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: proy1
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
use ieee.std_logic_textio.all;
use std.textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testproy IS
END testproy;
 
ARCHITECTURE behavior OF testproy IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT proy1
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         rgb : OUT  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal rgb : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;

 
signal Red : std_logic_vector( 2 downto 0);
signal Green: std_logic_vector(2 downto 0);
signal Blue: std_logic_vector( 1 downto 0);

BEGIN
 
 Red <= rgb(11 downto 9);
 Green <= rgb(7 downto 5);
 Blue <= rgb( 3 downto 2);
 
	-- Instantiate the Unit Under Test (UUT)
   uut: proy1 PORT MAP (
          clk => clk,
          reset => reset,
          hsync => hsync,
          vsync => vsync,
          rgb => rgb
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
    reset <= '1';
	 wait for 50ns;
	 reset <='0';
	 wait;
   end process;
	
	
process (clk)
    file file_pointer: text is out "vga1.txt";
    variable line_el: line;
begin
    if rising_edge(clk) then
        -- Write the time
        write(line_el, now); -- write the line.
        write(line_el, ":"); -- write the line.
        -- Write the hsync
        write(line_el, " ");
        write(line_el, hsync); -- write the line.
        -- Write the vsync
        write(line_el, " ");
        write(line_el, vsync); -- write the line.
        -- Write the red
        write(line_el, " ");
        write(line_el, Red); -- write the line.
        -- Write the green
        write(line_el, " ");
        write(line_el, Green); -- write the line.
        -- Write the blue
        write(line_el, " ");
        write(line_el, Blue); -- write the line.
        writeline(file_pointer, line_el); -- write the contents into the file.
    end if;
end process;

END;
