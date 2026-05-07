library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GU is
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
end GU;

architecture Behavioral of GU is

signal hc      : unsigned(10 downto 0);
signal vc      : unsigned(9 downto 0);

signal h_off1  : unsigned(10 downto 0);
signal h_off2  : unsigned(10 downto 0);
signal v_off   : unsigned(9 downto 0);

signal col1    : unsigned(5 downto 0);
signal col2    : unsigned(5 downto 0);
signal row     : unsigned(5 downto 0);

signal in_t1   : std_logic;
signal in_t2   : std_logic;
signal in_t1_r : std_logic;
signal in_t2_r : std_logic;

begin

hc <= unsigned(hcount);
vc <= unsigned(vcount);

-- =====================================================
-- ZONAS DE PANTALLA
-- Tablero 1 (valores):    h  64-319, v 112-367
-- Separador:              h 320-323
-- Tablero 2 (avalanchas): h 324-579, v 112-367
-- =====================================================

in_t1 <= '1' when (hc >= 64  and hc < 320 and
                   vc >= 112 and vc < 368) else '0';

in_t2 <= '1' when (hc >= 324 and hc < 580 and
                   vc >= 112 and vc < 368) else '0';

-- =====================================================
-- REGISTRO DE ZONAS - compensa latencia BRAM 1 ciclo
-- =====================================================
process(clk)
begin
    if rising_edge(clk) then
        in_t1_r <= in_t1;
        in_t2_r <= in_t2;
    end if;
end process;

-- =====================================================
-- OFFSETS
-- =====================================================
h_off1 <= hc - 64  when in_t1 = '1' else (others => '0');
h_off2 <= hc - 324 when in_t2 = '1' else (others => '0');
v_off  <= vc - 112 when (in_t1 = '1' or in_t2 = '1')
          else (others => '0');

col1 <= h_off1(7 downto 2);
col2 <= h_off2(7 downto 2);
row  <= v_off(7 downto 2);

-- =====================================================
-- DIRECCIONES INDEPENDIENTES
-- =====================================================
dir_val <= std_logic_vector(row & col1) when in_t1 = '1'
           else (others => '0');

dir_av  <= std_logic_vector(row & col2) when in_t2 = '1'
           else (others => '0');

-- =====================================================
-- COLOR
-- Tablero 1: data_val(1:0) → 4 colores (0-3 granos)
--   "00" → negro   (0 granos)
--   "01" → azul    (1 grano)
--   "10" → verde   (2 granos)
--   "11" → rojo    (3 granos)
--   valores >= 4 (transitorio toppling) → amarillo
--
-- Tablero 2: data_av(0) → 2 colores
--   '0'  → negro
--   '1'  → blanco (avalancha)
-- =====================================================

process(in_t1_r, in_t2_r, data_val, data_av)
begin
    if in_t1_r = '1' then
        -- usa los 3 bits para detectar valores transitorios
        case data_val is
            when "000"  => rgb <= "000000000000"; -- negro  (0)
            when "001"  => rgb <= "000000001111"; -- azul   (1)
            when "010"  => rgb <= "000011110000"; -- verde  (2)
            when "011"  => rgb <= "111100000000"; -- rojo   (3)
            when "100"  => rgb <= "111111110000"; -- amarillo (4 transitorio)
            when "101"  => rgb <= "111111110000"; -- amarillo (5)
            when "110"  => rgb <= "111111110000"; -- amarillo (6)
            when "111"  => rgb <= "111111110000"; -- amarillo (7)
            when others => rgb <= "000000000000";
        end case;

    elsif in_t2_r = '1' then
        if data_av(0) = '1' then
            rgb <= "111111111111"; -- blanco → avalancha
        else
            rgb <= "000000000000"; -- negro  → sin avalancha
        end if;

    else
        rgb <= "000000000000"; -- negro fuera de tableros
    end if;
end process;

end Behavioral;






