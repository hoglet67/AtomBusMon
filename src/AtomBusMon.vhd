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
        nsw2             : in    std_logic;

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

begin

    mon : entity work.BusMonCore port map (  
        clock49 => clock49,
        Addr    => Addr,
        Data    => (others => '0'),
        Phi2    => Phi2,
        Rd_n    => not RNW,
        Wr_n    => RNW,
        Sync    => Sync,
        Rdy     => Rdy,
        nRSTin  => nRST,
        nRSTout => nRST,
        Regs    => (others => '0'),
        RdOut   => open,
        WrOut   => open,
        AddrOut => open,
        DataOut => open,
        DataIn  => (others => '0'),        
        trig    => trig,
        lcd_rs  => open,
        lcd_rw  => open,
        lcd_e   => open,
        lcd_db  => open,
        avr_RxD => avr_RxD,
        avr_TxD => avr_TxD,
        sw1     => sw1,
        nsw2    => nsw2,
        led3    => led3,
        led6    => led6,
        led8    => led8,
        tmosi   => tmosi,
        tdin    => tdin,
        tcclk   => tcclk,
        SS_Step => open,
        SS_Single => open
    );

end behavioral;


