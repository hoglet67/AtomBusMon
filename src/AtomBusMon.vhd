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


entity AtomBusMon is
    port (clock49         : in    std_logic;
          
          -- 6502 Signals
          Addr            : in    std_logic_vector(15 downto 0);
          Phi2            : in    std_logic;
          RNW             : in    std_logic;
          Sync            : in    std_logic;
          Rdy             : out   std_logic;
          nRST            : inout std_logic;
                    
          -- HD44780 LCD
          lcd_rs          : out   std_logic;
          lcd_rw          : out   std_logic;
          lcd_e           : out   std_logic;
          lcd_db          : inout std_logic_vector(7 downto 4);

          -- AVR Serial Port
          avr_RxD         : in    std_logic;
          avr_TxD         : out   std_logic;

          -- GODIL Switches
          sw1             : in    std_logic;
          nsw2            : in    std_logic;

          -- GODIL LEDs
          led3            : out   std_logic;
          led6            : out   std_logic;
          led8            : out   std_logic;

          -- OHO_DY1 connected to test connector
          tmosi           : out   std_logic;
          tdin            : out   std_logic;
          tcclk           : out   std_logic
    );
end AtomBusMon;

architecture behavioral of AtomBusMon is

    signal clock_avr   : std_logic;
    signal nrst_avr    : std_logic;
    signal lcd_rw_int  : std_logic;
    signal lcd_db_in   : std_logic_vector(7 downto 4);
    signal lcd_db_out  : std_logic_vector(7 downto 4);
    signal dy_counter  : std_logic_vector(31 downto 0);
    signal dy_data     : y2d_type ;

    signal addr_sync   : std_logic_vector(15 downto 0);
    signal addr_inst   : std_logic_vector(15 downto 0);

    signal single : std_logic;
    signal reset  : std_logic;
    signal step   : std_logic;
    signal step1  : std_logic;
    signal step2  : std_logic;
    
    signal brkpt_enable  : std_logic;
    signal brkpt_clock   : std_logic;
    signal brkpt_clock1  : std_logic;
    signal brkpt_clock2  : std_logic;
    signal brkpt_data    : std_logic;
    signal brkpt_active  : std_logic;
    signal brkpt_active1 : std_logic;

    signal brkpt_0   : std_logic_vector(15 downto 0);
    signal brkpt_1   : std_logic_vector(15 downto 0);
    signal brkpt_2   : std_logic_vector(15 downto 0);
    signal brkpt_3   : std_logic_vector(15 downto 0);
    signal brkpt_reg : std_logic_vector(63 downto 0);
    
begin

    inst_dcm5 : entity work.DCM0 port map(
        CLKIN_IN          => clock49,
        CLK0_OUT          => clock_avr,
        CLK0_OUT1         => open,
        CLK2X_OUT         => open
    );    

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

    
    Inst_AVR8: entity work.AVR8 port map(
        clk16M               => clock_avr,
        nrst                 => nrst_avr,

        portain(0)           => '0',
        portain(1)           => '0',
        portain(2)           => '0',
        portain(3)           => '0',
        portain(4)           => lcd_db_in(4),
        portain(5)           => lcd_db_in(5),
        portain(6)           => lcd_db_in(6),
        portain(7)           => lcd_db_in(7),

        portaout(0)          => lcd_rs,
        portaout(1)          => lcd_rw_int,
        portaout(2)          => lcd_e,
        portaout(3)          => open,
        portaout(4)          => lcd_db_out(4),
        portaout(5)          => lcd_db_out(5),
        portaout(6)          => lcd_db_out(6),
        portaout(7)          => lcd_db_out(7),

        portbin(0)           => '0',
        portbin(1)           => '0',
        portbin(2)           => '0',
        portbin(3)           => '0',
        portbin(4)           => '0',
        portbin(5)           => '0',
        portbin(6)           => sw1,
        portbin(7)           => brkpt_active1,
        portbout(0)          => step,
        portbout(1)          => single,
        portbout(2)          => reset,
        portbout(3)          => brkpt_enable,
        portbout(4)          => brkpt_clock,
        portbout(5)          => brkpt_data,
        portbout(6)          => open,
        portbout(7)          => open,
        
        
        portdin              => addr_inst(7 downto 0),
        portdout             => open,

        portein              => addr_inst(15 downto 8),
        porteout             => open,
                
        spi_mosio            => open,
        spi_scko             => open,
        spi_misoi            => '0',
     
        rxd                  => avr_RxD,
        txd                  => avr_TxD
    );

    lcd_rw    <= lcd_rw_int;
    lcd_db    <= lcd_db_out when lcd_rw_int = '0' else (others => 'Z');
    lcd_db_in <= lcd_db;

    led3 <= '0';               -- red
    led6 <= '0';               -- red
    led8 <= not brkpt_active;  -- green

    nrst_avr <= nsw2;
    
    -- OHO DY1 Display for Testing
    dy_data(0) <= hex & "0000" & Addr(3 downto 0);
    dy_data(1) <= hex & "0000" & Addr(7 downto 4);
    dy_data(2) <= hex & "0000" & "00" & (not nsw2) & sw1;
  
    brkpt_0 <= brkpt_reg(15 downto 0);
    brkpt_1 <= brkpt_reg(31 downto 16);
    brkpt_2 <= brkpt_reg(47 downto 32);
    brkpt_3 <= brkpt_reg(63 downto 48);


    brkpt_active <= '1' when brkpt_enable = '1' and Sync = '1' and
        ((Addr = brkpt_0) or (Addr = brkpt_1) or (Addr = brkpt_2) or (Addr = brkpt_3))
        else '0';
        
    -- 6502 Control
    syncProcess: process (Phi2)
    begin
        if rising_edge(Phi2) then
            -- Address monitoring
            addr_sync <= Addr;          
            if (Sync = '1') then
                addr_inst <= Addr;
            end if;
            -- Reset
            if (reset = '1') then
                nRST <= '0';
            else
                nRST <= 'Z';
            end if;
            -- Breakpoints
            brkpt_clock1 <= brkpt_clock;
            brkpt_clock2 <= brkpt_clock1;
            if (brkpt_enable = '0' and brkpt_clock2 = '0' and brkpt_clock1 = '1') then
                brkpt_reg <= brkpt_data & brkpt_reg(63 downto 1);
            end if;
            brkpt_active1 <= brkpt_active;
            -- Single Stepping
            step1 <= step;
            step2 <= step1;
            if ((single = '0') or (step2 = '0' and step1 = '1')) then
                Rdy <= (not brkpt_active);
            else
                Rdy <= (not Sync);
            end if;
        end if;
    end process;

end behavioral;


