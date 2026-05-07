library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ASM is
    Port (
        clk   : in  STD_LOGIC;
        ini   : in  STD_LOGIC;
        reset : in  STD_LOGIC;

        -- Puerto memoria valores (memi_val 3 bits)
        we_val  : out STD_LOGIC_VECTOR(0 downto 0);
        ab_val  : out STD_LOGIC_VECTOR(11 downto 0);
        dbi_val : out STD_LOGIC_VECTOR(2 downto 0);
        dbo_val : in  STD_LOGIC_VECTOR(2 downto 0);

        -- Puerto memoria avalanchas (memi_av 1 bit)
        we_av   : out STD_LOGIC_VECTOR(0 downto 0);
        ab_av   : out STD_LOGIC_VECTOR(11 downto 0);
        dbi_av  : out STD_LOGIC_VECTOR(0 downto 0);

        -- Control
        cinit : in  STD_LOGIC;
        op    : in  STD_LOGIC;
        gran  : in  STD_LOGIC;

        -- PRNG
        rx    : in  STD_LOGIC_VECTOR(5 downto 0);
        ry    : in  STD_LOGIC_VECTOR(5 downto 0);
        rval  : in  STD_LOGIC_VECTOR(1 downto 0);
        en    : out STD_LOGIC
    );
end ASM;

architecture Behavioral of ASM is

signal px, py      : unsigned(5 downto 0) := (others=>'0');
signal gx, gy      : unsigned(5 downto 0) := (others=>'0');
signal dir         : unsigned(11 downto 0) := (others=>'0');

signal timer       : integer range 0 to 20000000 := 0;
signal active      : std_logic := '0';

-- NUEVA SEÑAL para guardar el valor exacto de la celda que colapsa
signal val_actual  : unsigned(2 downto 0) := (others=>'0');
signal granos      : unsigned(2 downto 0) := (others=>'0');
signal sum_val     : unsigned(2 downto 0) := (others=>'0');

-- flag toppling iterativo
signal hubo_colapso : std_logic := '0';

type state is (
    -- INIT
    s_init, s_init_val_wr, s_init_av_wr, s_init_next,

    -- IDLE
    s_idle, s_idle_on_wait, s_idle_off_wait,

    -- CLEAR avalanche memory
    s_clr_addr, s_clr_wr, s_clr_next,

    -- Deposit grain
    s_dep_sel, s_dep_prng_wait, s_dep_addr, s_dep_wait, s_dep_eval, s_dep_wr, s_dep_av_wr,

    -- Toppling scan iterativo
    s_top_inicio, s_top_addr, s_top_wait, s_top_eval,

    -- North
    s_n_addr, s_n_wait, s_n_wr,
    -- South
    s_s_addr, s_s_wait, s_s_wr,
    -- West
    s_w_addr, s_w_wait, s_w_wr,
    -- East
    s_e_addr, s_e_wait, s_e_wr,

    -- Collapse current cell
    s_zero_val, s_zero_av,

    -- Next cell
    s_next_cell,

    -- Check si hubo colapso → repetir scan
    s_top_check,

    -- Timer
    s_timer
);

signal st : state := s_init;

begin

process(clk, reset)
begin
if reset = '1' then

    st           <= s_init;
    px           <= (others=>'0');
    py           <= (others=>'0');
    gx           <= (others=>'0');
    gy           <= (others=>'0');
    dir          <= (others=>'0');
    timer        <= 0;
    active       <= '0';
    val_actual   <= (others=>'0');
    granos       <= to_unsigned(1, 3);
    sum_val      <= (others=>'0');
    hubo_colapso <= '0';

    we_val  <= "0";
    ab_val  <= (others=>'0');
    dbi_val <= (others=>'0');
    we_av   <= "0";
    ab_av   <= (others=>'0');
    dbi_av  <= "0";
    en      <= '0';

elsif rising_edge(clk) then

    we_val  <= "0";
    we_av   <= "0";
    dbi_val <= (others=>'0');
    dbi_av  <= "0";
    en      <= '0';

    case st is

    -- =====================================================
    -- INIT
    -- =====================================================

    when s_init =>
        dir <= (others=>'0');
        en  <= '1';
        st  <= s_init_val_wr;

    when s_init_val_wr =>
        ab_val <= std_logic_vector(dir);
        we_val <= "1";
        if cinit = '0' then
            dbi_val <= "000";
        else
            -- valores aleatorios 0-3 (bit2=0 siempre)
            dbi_val <= '0' & rval;
            en      <= '1';
        end if;
        st <= s_init_av_wr;

    when s_init_av_wr =>
        ab_av  <= std_logic_vector(dir);
        dbi_av <= "0";
        we_av  <= "1";
        st     <= s_init_next;

    when s_init_next =>
        if dir = to_unsigned(4095, 12) then
            -- deposita grano inicial en centro (31,31)
            ab_val  <= std_logic_vector(to_unsigned(31,6) & to_unsigned(31,6));
            dbi_val <= "001";
            we_val  <= "1";
            st      <= s_idle;
        else
            dir <= dir + 1;
            st  <= s_init_val_wr;
        end if;

    -- =====================================================
    -- IDLE
    -- =====================================================

    when s_idle =>
        if active = '0' then
            if ini = '1' then
                st <= s_idle_on_wait;
            end if;
        else
            if ini = '1' then
                st <= s_idle_off_wait;
            else
                dir <= (others=>'0');
                st  <= s_clr_addr;
            end if;
        end if;

    when s_idle_on_wait =>
        if ini = '0' then
            active <= '1';
            st     <= s_idle;
        end if;

    when s_idle_off_wait =>
        if ini = '0' then
            active <= '0';
            st     <= s_idle;
        end if;

    -- =====================================================
    -- CLEAR: borra memi_av
    -- =====================================================

    when s_clr_addr =>
        ab_av  <= std_logic_vector(dir);
        dbi_av <= "0";
        we_av  <= "1";
        st     <= s_clr_next;

    when s_clr_next =>
        if dir = to_unsigned(4095, 12) then
            st <= s_dep_sel;
        else
            dir <= dir + 1;
            st  <= s_clr_addr;
        end if;

    -- =====================================================
    -- DEPOSIT
    -- =====================================================

    when s_dep_sel =>
        en <= '1';
        if gran = '1' then
            granos <= ('0' & unsigned(rval)) + 1;
        else
            granos <= to_unsigned(1, 3);
        end if;
        st <= s_dep_prng_wait;

   -- when s_dep_prng_wait =>
     --   if op = '0' then
       --     gx <= to_unsigned(31, 6);
         --   gy <= to_unsigned(31, 6);
        --else
          --  gx <= unsigned(rx);
            --gy <= unsigned(ry);
       -- end if;
        --st <= s_dep_addr;
		  when s_dep_prng_wait =>
        if op = '0' then
            gx <= to_unsigned(32, 6); -- Cae en el Centro
            gy <= to_unsigned(32, 6); 
        else
            -- HACK DE PRUEBA: Forzamos la caída cerca de la esquina en vez del PRNG
            gx <= unsigned(rx); 
            gy <= unsigned(ry); 
        end if;
        st <= s_dep_addr;

    when s_dep_addr =>
        ab_val <= std_logic_vector(gy & gx);
        st     <= s_dep_wait;

    when s_dep_wait =>
        -- Solo esperamos 1 ciclo para la latencia de memoria
        st      <= s_dep_eval;

    when s_dep_eval =>
        -- Aquí dbo_val ya es válido
        sum_val <= unsigned(dbo_val) + granos;
        st      <= s_dep_wr;

    when s_dep_wr =>
        ab_val <= std_logic_vector(gy & gx);
        dbi_val <= std_logic_vector(sum_val);
        we_val  <= "1";
        
        -- si ya hay desborde marca avalancha
        if sum_val >= to_unsigned(4, 3) then
            st <= s_dep_av_wr;
        else
            px           <= (others=>'0');
            py           <= (others=>'0');
            hubo_colapso <= '0';
            st           <= s_top_inicio;
        end if;

    when s_dep_av_wr =>
        ab_av  <= std_logic_vector(gy & gx);
        dbi_av <= "1";
        we_av  <= "1";
        px           <= (others=>'0');
        py           <= (others=>'0');
        hubo_colapso <= '0';
        st           <= s_top_inicio;

    -- =====================================================
    -- TOPPLING ITERATIVO
    -- =====================================================

    when s_top_inicio =>
        px           <= (others=>'0');
        py           <= (others=>'0');
        hubo_colapso <= '0';
        st           <= s_top_addr;

    when s_top_addr =>
        ab_val <= std_logic_vector(py & px);
        st     <= s_top_wait;

    when s_top_wait =>
        -- Solo quemamos 1 ciclo de reloj
        st      <= s_top_eval;

    when s_top_eval =>
        if unsigned(dbo_val) >= 4 then
            -- celda tiene >= 4 granos → colapsa
            hubo_colapso <= '1';
            val_actual   <= unsigned(dbo_val); -- ¡NUEVO! Guardamos la celda crítica
            st           <= s_n_addr;
        else
            st <= s_next_cell;
        end if;

    -- ----- NORTH -----
    when s_n_addr =>
        if py > 0 then
            ab_val <= std_logic_vector((py-1) & px);
        end if;
        st <= s_n_wait;

    when s_n_wait =>
        st      <= s_n_wr;

    when s_n_wr =>
        if py > 0 then
            ab_val  <= std_logic_vector((py-1) & px);
            -- Sumamos 1 al dato seguro que acaba de escupir la RAM
            dbi_val <= std_logic_vector(unsigned(dbo_val) + 1);
            we_val  <= "1";
        end if;
        st <= s_s_addr;

    -- ----- SOUTH -----
    when s_s_addr =>
        if py < 63 then
            ab_val <= std_logic_vector((py+1) & px);
        end if;
        st <= s_s_wait;

    when s_s_wait =>
        st      <= s_s_wr;

    when s_s_wr =>
        if py < 63 then
            ab_val  <= std_logic_vector((py+1) & px);
            dbi_val <= std_logic_vector(unsigned(dbo_val) + 1);
            we_val  <= "1";
        end if;
        st <= s_w_addr;

    -- ----- WEST -----
    when s_w_addr =>
        if px > 0 then
            ab_val <= std_logic_vector(py & (px-1));
        end if;
        st <= s_w_wait;

    when s_w_wait =>
        st      <= s_w_wr;

    when s_w_wr =>
        if px > 0 then
            ab_val  <= std_logic_vector(py & (px-1));
            dbi_val <= std_logic_vector(unsigned(dbo_val) + 1);
            we_val  <= "1";
        end if;
        st <= s_e_addr;

    -- ----- EAST -----
    when s_e_addr =>
        if px < 63 then
            ab_val <= std_logic_vector(py & (px+1));
        end if;
        st <= s_e_wait;

    when s_e_wait =>
        st      <= s_e_wr;

    when s_e_wr =>
        if px < 63 then
            ab_val  <= std_logic_vector(py & (px+1));
            dbi_val <= std_logic_vector(unsigned(dbo_val) + 1);
            we_val  <= "1";
        end if;
        st <= s_zero_val;

    -- ----- COLAPSO CELDA ACTUAL (resta 4) -----
    when s_zero_val =>
        ab_val  <= std_logic_vector(py & px);
        -- Restamos 4 usando el valor capturado al inicio del colapso
        dbi_val <= std_logic_vector(val_actual - 4);
        we_val  <= "1";
        st      <= s_zero_av;

    when s_zero_av =>
        ab_av  <= std_logic_vector(py & px);
        dbi_av <= "1";
        we_av  <= "1";
        st     <= s_next_cell;

    -- ----- SIGUIENTE CELDA -----
    when s_next_cell =>
        if px = 63 then
            px <= (others=>'0');
            if py = 63 then
                py <= (others=>'0');
                st <= s_top_check;
            else
                py <= py + 1;
                st <= s_top_addr;
            end if;
        else
            px <= px + 1;
            st <= s_top_addr;
        end if;

    -- ----- VERIFICA SI REPETIR SCAN -----
    when s_top_check =>
        if hubo_colapso = '1' then
            -- hubo colapsos → repetir scan completo
            px           <= (others=>'0');
            py           <= (others=>'0');
            hubo_colapso <= '0';
            st           <= s_top_addr;
        else
            -- sin colapsos → iteracion completa, saltamos al timer
            st <= s_timer;
        end if;

    -- =====================================================
    -- TIMER
    -- =====================================================

    when s_timer =>
        if timer = 500000 then
            timer <= 0;
            st    <= s_idle;
        else
            timer <= timer + 1;
        end if;

    when others =>
        st <= s_init;

    end case;
end if;
end process;

end Behavioral;


