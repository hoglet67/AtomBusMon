--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : Z80CpuMonALS.vhd
-- /___/   /\     Timestamp : 29/09/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: Z80CpuMon
--Device: XC6SLX9

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Z80CpuMonALS is
    port (
        clock           : in    std_logic;

        -- Z80 Signals
        RESET_n         : in    std_logic;
        CLK_n           : in    std_logic;
        WAIT_n          : in    std_logic;
        INT_n           : in    std_logic;
        NMI_n           : in    std_logic;
        BUSRQ_n         : in    std_logic;
        M1_n            : out   std_logic;
        MREQ_n          : out   std_logic;
        IORQ_n          : out   std_logic;
        RD_n            : out   std_logic;
        WR_n            : out   std_logic;
        RFSH_n          : out   std_logic;
        HALT_n          : out   std_logic;
        BUSAK_n         : out   std_logic;
        Addr            : out   std_logic_vector(15 downto 0);
        Data            : inout std_logic_vector(7 downto 0);

        -- Level Shifers Controls
        OEC_n           : out   std_logic;
        OEA1_n          : out   std_logic;
        OEA2_n          : out   std_logic;
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
        sw1             : in    std_logic;
        sw2             : in    std_logic;

        -- LEDs
        led1            : out   std_logic;
        led2            : out   std_logic;
        led3            : out   std_logic;

        -- Optional OHO_DY1 connected to test connector
        tmosi           : out   std_logic;
        tdin            : out   std_logic;
        tcclk           : out   std_logic;

        -- Optional Debugging signals
        test            : out   std_logic_vector(9 downto 0)

    );
end Z80CpuMonALS;

architecture behavioral of Z80CpuMonALS is

    signal MREQ_n_int  : std_logic;
    signal IORQ_n_int  : std_logic;
    signal M1_n_int    : std_logic;
    signal RD_n_int    : std_logic;
    signal WR_n_int    : std_logic;
    signal RFSH_n_int  : std_logic;
    signal HALT_n_int  : std_logic;
    signal BUSAK_n_int : std_logic;
    signal DOE_n       : std_logic;

begin

    MREQ_n  <= MREQ_n_int;
    IORQ_n  <= IORQ_n_int;
    M1_n    <= M1_n_int;
    RD_n    <= RD_n_int;
    WR_n    <= WR_n_int;
    RFSH_n  <= RFSH_n_int;
    HALT_n  <= HALT_n_int;
    BUSAK_n <= BUSAK_n_int;

    test(0) <= M1_n_int;
    test(1) <= RD_n_int;
    test(2) <= WR_n_int;
    test(3) <= MREQ_n_int;
    test(4) <= IORQ_n_int;
    test(5) <= WAIT_n;
    test(6) <= RESET_n;
    test(7) <= CLK_n;
    test(8) <= RFSH_n_int;
    test(9) <= INT_n;

    OEC_n   <= not BUSAK_n_int;
    OEA1_n  <= not BUSAK_n_int;
    OEA2_n  <= not BUSAK_n_int;

    OED_n   <= not BUSAK_n_int;
    DIRD    <= DOE_n;

    wrapper : entity work.Z80CpuMon
        generic map (
            UseT80Core        => true,
            LEDsActiveHigh    => true,
            SW1ActiveHigh     => false,
            SW2ActiveHigh     => false,
            ClkMult           => 8,
            ClkDiv            => 25,
            ClkPer            => 20.000,
            num_comparators   => 4,
            avr_prog_mem_size => 1024 * 16
            )
      port map (
          clock49         => clock,

          -- Z80 Signals
          RESET_n         => RESET_n,
          CLK_n           => CLK_n,
          WAIT_n          => WAIT_n,
          INT_n           => INT_n,
          NMI_n           => NMI_n,
          BUSRQ_n         => BUSRQ_n,
          M1_n            => M1_n_int,
          MREQ_n          => MREQ_n_int,
          IORQ_n          => IORQ_n_int,
          RD_n            => RD_n_int,
          WR_n            => WR_n_int,
          RFSH_n          => RFSH_n_int,
          HALT_n          => HALT_n_int,
          BUSAK_n         => BUSAK_n_int,
          Addr            => Addr,
          Data            => Data,
          DOE_n           => DOE_n,

          -- Mode jumper, tie low to generate NOPs when paused
          mode            => mode,

          -- External trigger inputs
          trig            => trig,

          -- Serial Console
          avr_RxD         => avr_RxD,
          avr_TxD         => avr_TxD,

          -- Switches
          sw1             => sw1,
          sw2             => sw2,

          -- LEDs
          led3            => led2, -- trig 0
          led6            => led3, -- trig 1
          led8            => led1, -- break

          -- OHO_DY1 connected to test connector
          tmosi           => tmosi,
          tdin            => tdin,
          tcclk           => tcclk,

          -- Debugging signals
          test1           => open,
          test2           => open,
          test3           => open,
          test4           => open
          );

end behavioral;
