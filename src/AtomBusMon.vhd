--------------------------------------------------------------------------------
-- Copyright (c) 2015 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : AtomBusMon.vhd
-- /___/   /\     Timestamp : 30/05/2015
-- \   \  /  \
--  \___\/\___\
--
--Design Name: AtomBusMon
--Device: XC3S250E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AtomBusMon is
    generic (
       LEDsActiveHigh : boolean := false;    -- default value correct for GODIL
       SW1ActiveHigh  : boolean := true;     -- default value correct for GODIL
       SW2ActiveHigh  : boolean := false     -- default value correct for GODIL
       );
    port (
        clock49         : in    std_logic;

        -- 6502 Signals
        Addr             : in    std_logic_vector(15 downto 0);
        Phi2             : in    std_logic;
        RNW              : in    std_logic;
        Sync             : in    std_logic;
        Rdy              : out   std_logic;
        nRST             : inout std_logic;

        -- External trigger inputs
        trig             : in    std_logic_vector(1 downto 0);

        -- HD44780 LCD
        --lcd_rs           : out   std_logic;
        --lcd_rw           : out   std_logic;
        --lcd_e            : out   std_logic;
        --lcd_db           : inout std_logic_vector(7 downto 4);

        -- AVR Serial Port
        avr_RxD          : in    std_logic;
        avr_TxD          : out   std_logic;

        -- GODIL Switches
        sw1              : in    std_logic;
        sw2              : in    std_logic;

        -- GODIL LEDs
        led3             : out   std_logic;
        led6             : out   std_logic;
        led8             : out   std_logic;

        -- OHO_DY1 connected to test connector
        tmosi            : out   std_logic;
        tdin             : out   std_logic;
        tcclk            : out   std_logic
    );
end AtomBusMon;

architecture behavioral of AtomBusMon is

signal clock_avr : std_logic;
signal Rdy_int   : std_logic;
signal nRSTin    : std_logic;
signal nRSTout   : std_logic;

    signal led3_n         : std_logic;  -- led to indicate ext trig 0 is active
    signal led6_n         : std_logic;  -- led to indicate ext trig 1 is active
    signal led8_n         : std_logic;  -- led to indicate CPU has hit a breakpoint (and is stopped)
    signal sw_interrupt_n : std_logic;  -- switch to pause the CPU
    signal sw_reset_n     : std_logic;  -- switch to reset the CPU

begin

    -- Generics allows polarity of switches/LEDs to be tweaked from the project file
    sw_reset_n     <= not sw1 when SW1ActiveHigh else sw1;
    sw_interrupt_n <= not sw2 when SW2ActiveHigh else sw2;
    led3           <= not led3_n when LEDsActiveHigh else led3_n;
    led6           <= not led6_n when LEDsActiveHigh else led6_n;
    led8           <= not led8_n when LEDsActiveHigh else led8_n;

    inst_dcm0 : entity work.DCM0 port map(
        CLKIN_IN          => clock49,
        CLKFX_OUT         => clock_avr
    );

    mon : entity work.BusMonCore
    generic map (
        avr_prog_mem_size => 1024 * 8
    )
    port map (
        clock_avr    => clock_avr,
        busmon_clk   => Phi2,
        busmon_clken => '1',
        cpu_clk      => not Phi2,
        cpu_clken    => '1',
        Addr         => Addr,
        Data         => (others => '0'),
        Rd_n         => not RNW,
        Wr_n         => RNW,
        RdIO_n       => '1',
        WrIO_n       => '1',
        Sync         => Sync,
        Rdy          => Rdy_int,
        nRSTin       => nRSTin,
        nRSTout      => nRSTout,
        CountCycle   => Rdy_int,
        Regs         => (others => '0'),
        RdMemOut     => open,
        WrMemOut     => open,
        RdIOOut      => open,
        WrIOOut      => open,
        AddrOut      => open,
        DataOut      => open,
        DataIn       => (others => '0'),
        Done         => '1',
        trig         => trig,
        lcd_rs       => open,
        lcd_rw       => open,
        lcd_e        => open,
        lcd_db       => open,
        avr_RxD      => avr_RxD,
        avr_TxD      => avr_TxD,
        sw1          => not sw_reset_n,
        nsw2         => sw_interrupt_n,
        led3         => led3_n,
        led6         => led6_n,
        led8         => led8_n,
        tmosi        => tmosi,
        tdin         => tdin,
        tcclk        => tcclk,
        SS_Step      => open,
        SS_Single    => open
    );
    Rdy <= Rdy_int;

    -- Tristate buffer driving reset back out
    nRSTin <= nRST;
    nRST <= '0' when nRSTout <= '0' else 'Z';

end behavioral;


