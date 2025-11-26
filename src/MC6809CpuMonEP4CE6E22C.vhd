--------------------------------------------------------------------------------
-- Copyright (c) 2025 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : MC6809CpuMonEP4CE6E22C.vhd
-- /___/   /\     Timestamp : 24/10/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: MC6809CpuMonEP4CE6E22C
--Device: XC6SLX9

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity MC6809CpuMonEP4CE6E22C is
    generic (
       num_comparators   : integer := 8;        -- default value correct for EP4CE6E22C
       avr_prog_mem_size : integer := 1024 * 9  -- default value correct for EP4CE6E22C
       );
    port (
        clock            : in    std_logic;

        --6809 Signals
        BUSY             : out    std_logic;
        E                : in     std_logic;
        Q                : in     std_logic;
        AVMA             : out    std_logic;
        LIC              : out    std_logic;
        TSC              : in     std_logic;

        -- Signals common to both 6809 and 6809E
        RES_n            : in    std_logic;
        NMI_n            : in    std_logic;
        IRQ_n            : in    std_logic;
        FIRQ_n           : in    std_logic;
        HALT_n           : in    std_logic;
        BS               : out   std_logic;
        BA               : out   std_logic;
        R_W_n            : out   std_logic;

        Addr             : out   std_logic_vector(15 downto 0);
        Data             : inout std_logic_vector(7 downto 0);

        -- Level Shifers Controls
        OERW_n           : out   std_logic;
        OEAL_n           : out   std_logic;
        OEAH_n           : out   std_logic;
        OED_n            : out   std_logic;
        DIRD             : out   std_logic;

        -- External trigger inputs
        trig             : in    std_logic_vector(1 downto 0);

        -- ID/mode inputs
        mode            : in    std_logic;
        id              : in    std_logic_vector(3 downto 0);

        -- Serial Console
        avr_RxD          : in    std_logic;
        avr_TxD          : out   std_logic;

        -- Serial Flash
        flash_cs_n       : out   std_logic;
        flash_clk        : out   std_logic;
        flash_di         : out   std_logic;
        flash_do         : in    std_logic;

        -- Switches
        sw               : in    std_logic_vector(5 downto 1);

        -- LEDs
        led              : out   std_logic_vector(5 downto 1)

    );
end MC6809CpuMonEP4CE6E22C;

architecture behavioral of MC6809CpuMonEP4CE6E22C is

    signal R_W_n_int    : std_logic;

    signal sw_reset_cpu : std_logic;
    signal sw_reset_avr : std_logic;
    signal led_bkpt     : std_logic;
    signal led_trig0    : std_logic;
    signal led_trig1    : std_logic;

    -- 50MHz clock, toggle every 25,000,000 =
    signal blinky_count : unsigned(24 downto 0) := (others => '0');
    signal led_blinky   : std_logic := '0';

begin

    sw_reset_cpu <= not sw(1);
    sw_reset_avr <= not sw(2);
    led(1)       <= sw(1) and sw(2);
    led(2)       <= led_bkpt;
    led(3)       <= led_trig0;
    led(4)       <= led_trig1;
    led(5)       <= led_blinky;

    -- 1Hz Blinky LED
    process(clock)
    begin
        if rising_edge(clock) then
            if blinky_count = to_unsigned(24999999, blinky_count'length) then
                blinky_count <= (others => '0');
                led_blinky <= not led_blinky;
            else
                blinky_count <= blinky_count + 1;
            end if;
        end if;
    end process;

    wrapper : entity work.MC6809CpuMon
      generic map (
          ClkMult           => 12,
          ClkDiv            => 25,
          ClkPer            => 20.000,
          num_comparators   => num_comparators,
          avr_prog_mem_size => avr_prog_mem_size
      )
      port map (

        -- Fast clock
        clock           => clock,

        -- Quadrature clocks
        E               => E,
        Q               => Q,

        --6809 Signals
        DMA_n_BREQ_n    => '1',

        -- 6809E Signals
        TSC             => TSC,
        LIC             => LIC,
        AVMA            => AVMA,
        BUSY            => BUSY,

        -- Signals common to both 6809 and 6809E
        RES_n           => RES_n,
        NMI_n           => NMI_n,
        IRQ_n           => IRQ_n,
        FIRQ_n          => FIRQ_n,
        HALT_n          => HALT_n,
        BS              => BS,
        BA              => BA,
        R_W_n           => R_W_n_int,

        Addr            => Addr,
        Data            => Data,

        -- External trigger inputs
        trig            => trig,

        -- Serial Console
        avr_RxD         => avr_RxD,
        avr_TxD         => avr_TxD,

        -- Switches
        sw_reset_cpu    => sw_reset_cpu,
        sw_reset_avr    => sw_reset_avr,

        -- LEDs
        led_bkpt        => led_bkpt,
        led_trig0       => led_trig0,
        led_trig1       => led_trig1,

        -- OHO_DY1 connected to test connector
        tmosi           => open,
        tdin            => open,
        tcclk           => open,

        -- Debugging signals
        test1           => open,
        test2           => open
    );

    -- 6809 Outputs
    R_W_n <= R_W_n_int;

    -- Level Shifter Controls
    OERW_n  <= TSC;
    OEAH_n  <= TSC;
    OEAL_n  <= TSC;
    OED_n   <= TSC or not (Q or E);
    DIRD    <= R_W_n_int;

    -- Unused serial flash:
    flash_cs_n <= '1';
    flash_clk  <= '1';
    flash_di   <= '1';

end behavioral;
