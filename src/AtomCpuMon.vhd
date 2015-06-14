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
use work.OhoPack.all ;


entity AtomCpuMon is
    port (
        clock49         : in    std_logic;
          
        -- 6502 Signals
        Rdy             : in    std_logic;
        Phi0            : in    std_logic;
        Phi1            : out   std_logic;
        Phi2            : out   std_logic;
        IRQ_n           : in    std_logic;
        NMI_n           : in    std_logic;
        Sync            : out   std_logic;                
        Addr            : out   std_logic_vector(15 downto 0);
        R_W_n           : out    std_logic;
        Data            : inout std_logic_vector(7 downto 0);
        SO_n            : in    std_logic;
        Res_n           : in    std_logic;
        
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
end AtomCpuMon;

architecture behavioral of AtomCpuMon is

    

    signal Din           : std_logic_vector(7 downto 0);
    signal Dout          : std_logic_vector(7 downto 0);
    signal dy_counter    : std_logic_vector(31 downto 0);
    signal dy_data       : y2d_type ;
    signal R_W_n_int     : std_logic;
    signal Addr_int      : std_logic_vector(15 downto 0);
begin

    
  

    cpu : entity work.T65 port map (
        mode           => "00",
        Abort_n        => '1',
        SO_n           => SO_n,
        Res_n          => Res_n,
        Enable         => '1',
        Clk            => not Phi0,
        Rdy            => Rdy,
        IRQ_n          => IRQ_n,
        NMI_n          => NMI_n,
        R_W_n          => R_W_n_int,
        Sync           => Sync,
        A(23 downto 16) => open,
        A(15 downto 0) => Addr_int(15 downto 0),
        DI(7 downto 0) => Din(7 downto 0),
        DO(7 downto 0) => Dout(7 downto 0)

    );
    
    Addr <= Addr_int;
    R_W_n <= R_W_n_int;
        

    Phi1 <= not Phi0;
    Phi2 <= Phi0;
    
    Din <= Data;

    Data <= Dout when R_W_n_int = '0' else (others => 'Z');

    -- OHO DY1 Display for Testing
    inst_oho_dy1 : entity work.Oho_Dy1 port map (
        dy_clock       => clock49,
        dy_rst_n       => '1',
        dy_data        => dy_data,
        dy_update      => '1',
        dy_frame       => open,
        dy_frameend    => open,
        dy_frameend_c  => open,
        dy_pwm         => "1010",
        dy_counter     => dy_counter,
        dy_sclk        => tdin,
        dy_ser         => tcclk,
        dy_rclk        => tmosi
    );
    
    dy_data(0) <= hex & "0000" & Addr_int(3 downto 0);
    dy_data(1) <= hex & "0000" & Addr_int(7 downto 4);
    dy_data(2) <= hex & "0000" & "00" & (not nsw2) & sw1;
    
    led3 <= not sw1;
    led6 <= nsw2;
    led8 <= RES_n;
    
end behavioral;
    
