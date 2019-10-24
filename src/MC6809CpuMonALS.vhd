--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : MC6809CpuMonALS.vhd
-- /___/   /\     Timestamp : 24/10/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: MC6809CpuMonALS
--Device: XC6SLX9

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity MC6809CpuMonALS is
    generic (
       ClkMult           : integer := 8;        -- default value correct for ALS
       ClkDiv            : integer := 25;       -- default value correct for ALS
       ClkPer            : real    := 20.0;     -- default value correct for ALS
       num_comparators   : integer := 8;        -- default value correct for ALS
       avr_prog_mem_size : integer := 1024 * 9  -- default value correct for ALS
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
        R_W_n            : out   std_logic_vector(1 downto 0);

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

        -- GODIL Switches
        sw_reset_n       : in    std_logic;
        sw_interrupt_n   : in    std_logic;

        -- GODIL LEDs
        led_bkpt         : out   std_logic;
        led_trig0        : out   std_logic;
        led_trig1        : out   std_logic

    );
end MC6809CpuMonALS;

architecture behavioral of MC6809CpuMonALS is

    signal sw_reset      : std_logic;
    signal sw_interrupt  : std_logic;
    signal R_W_n_int     : std_logic;

begin

    sw_reset <= not sw_reset_n;
    sw_interrupt <= not sw_interrupt_n;

    wrapper : entity work.MC6809CpuMonCore
      generic map (
          UseCPU09Core      => true,
          ClkMult           => ClkMult,
          ClkDiv            => ClkDiv,
          ClkPer            => ClkPer,
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
        sw_interrupt    => sw_interrupt,
        sw_reset        => sw_reset,

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
    R_W_n <= R_W_n_int & R_W_n_int;

    -- Level Shifter Controls
    OERW_n  <= TSC;
    OEAH_n  <= TSC;
    OEAL_n  <= TSC;
    OED_n   <= TSC or not (Q or E);
    DIRD    <= R_W_n_int;

end behavioral;
