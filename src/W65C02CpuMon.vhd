--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : W65C02CpuMon.vhd
-- /___/   /\     Timestamp : 20/09/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: W65C02CpuMon
--Device: XC6SLX9
--
--
-- This is a small wrapper around AtomCpuMon that add the following signals:
--   OEAH_n
--   OEAL_n
--   OED_n
--   DIRD
--   BE
--   ML_n
--   VP_n
-- (these are not fully implemented yet)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity W65C02CpuMon is
   generic (
       UseT65Core     : boolean := true;
       UseAlanDCore   : boolean := false;
       LEDsActiveHigh : boolean := true;     -- default value for EEPIZZA
       SW1ActiveHigh  : boolean := false;    -- default value for EEPIZZA
       SW2ActiveHigh  : boolean := false;    -- default value for EEPIZZA
       ClkMult        : integer :=  8;       -- default value for EEPIZZA
       ClkDiv         : integer := 25;       -- default value for EEPIZZA
       ClkPer         : real    := 16.000    -- default value for EEPIZZA
       );
    port (
        clock           : in    std_logic;

        -- 6502 Signals
        PhiIn           : in    std_logic;
        Phi1Out         : out   std_logic;
        Phi2Out         : out   std_logic;
        IRQ_n           : in    std_logic;
        NMI_n           : in    std_logic;
        Sync            : out   std_logic;
        Addr            : out   std_logic_vector(15 downto 0);
        R_W_n           : out   std_logic_vector(1 downto 0);
        Data            : inout std_logic_vector(7 downto 0);
        SO_n            : in    std_logic;
        Res_n           : inout std_logic;
        Rdy             : in    std_logic;

        -- 65C02 Signals
        BE              : in    std_logic;
        ML_n            : out   std_logic;
        VP_n            : out   std_logic;

        -- Level Shifter Controls
        OERW_n          : out   std_logic;
        OEAH_n          : out   std_logic;
        OEAL_n          : out   std_logic;
        OED_n           : out   std_logic;
        DIRD            : out   std_logic;

        -- External trigger inputs
        trig            : in    std_logic_vector(1 downto 0);

        -- ID/mode inputs
        mode            : in    std_logic;
        id              : in    std_logic_vector(3 downto 0);

        -- Serial Console
        avr_RxD         : in    std_logic;
        avr_TxD         : out   std_logic;

        -- Switches
        sw1              : in   std_logic;
        sw2              : in   std_logic;

        -- LEDs
        led1             : out  std_logic;
        led2             : out  std_logic;
        led3             : out  std_logic;

        -- OHO_DY1 LED display
        tmosi            : out  std_logic;
        tdin             : out  std_logic;
        tcclk            : out  std_logic
    );
end W65C02CpuMon;

architecture behavioral of W65C02CpuMon is

    signal R_W_n_int     : std_logic;

begin

    acm : entity work.AtomCpuMon
    generic map (
       UseT65Core     => UseT65Core,
       UseAlanDCore   => UseAlanDCore,
       LEDsActiveHigh => LEDsActiveHigh,
       SW1ActiveHigh  => SW1ActiveHigh,
       SW2ActiveHigh  => SW2ActiveHigh,
       ClkMult        => ClkMult,
       ClkDiv         => ClkDiv,
       ClkPer         => ClkPer
    )
    port map (
        clock49         => clock,

        -- 6502 Signals
        Phi0            => PhiIn,
        Phi1            => Phi1Out,
        Phi2            => Phi2Out,
        IRQ_n           => IRQ_n,
        NMI_n           => NMI_n,
        Sync            => Sync,
        Addr            => Addr,
        R_W_n           => R_W_n_int,
        Data            => Data,
        SO_n            => SO_n,
        Res_n           => Res_n,
        Rdy             => Rdy,

        -- External trigger inputs
        trig            => trig,

        -- Jumpers
        fakeTube_n      => '1',

        -- Serial Console
        avr_RxD         => avr_RxD,
        avr_TxD         => avr_TxD,

        -- Switches
        sw1              => sw1,
        sw2              => sw2,

        -- LEDs
        led3             => led2, -- trig 0
        led6             => led3, -- trig 1
        led8             => led1, -- break

        -- OHO_DY1 LED display
        tmosi            => tmosi,
        tdin             => tdin,
        tcclk            => tcclk
    );

    -- 6502 Outputs
    R_W_n <= R_W_n_int & R_W_n_int;

    -- 65C02 Outputs
    ML_n   <= '1';
    VP_n   <= '1';

    -- Level Shifter Controls
    OERW_n <= not (BE);
    OEAH_n <= not (BE);
    OEAL_n <= not (BE);
    OED_n  <= not (BE and PhiIn); -- TODO: might need to use a slightly delayed version of Phi2 here
    DIRD   <= R_W_n_int;

end behavioral;
