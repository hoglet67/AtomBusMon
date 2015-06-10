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

    signal mux         : std_logic_vector(7 downto 0);
    signal muxsel      : std_logic_vector(2 downto 0);
    signal cmd_edge    : std_logic;
    signal cmd_edge1   : std_logic;
    signal cmd_edge2   : std_logic;
    signal cmd         : std_logic_vector(3 downto 0);

    signal addr_sync   : std_logic_vector(15 downto 0);

    signal addr_inst   : std_logic_vector(15 downto 0);
    signal addr_break  : std_logic_vector(15 downto 0);
    signal mode_break  : std_logic_vector(7 downto 0);
    signal addr_watch  : std_logic_vector(15 downto 0);
    signal mode_watch  : std_logic_vector(7 downto 0);

    signal single : std_logic;
    signal reset  : std_logic;
    signal step   : std_logic;
    
    signal brkpt_enable  : std_logic;
    signal brkpt_active  : std_logic;
    signal brkpt_active1 : std_logic;

    signal brkpt_reg : std_logic_vector(79 downto 0);
    
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

        -- Command Port
        portbin(0)           => '0',
        portbin(1)           => '0',
        portbin(2)           => '0',
        portbin(3)           => '0',
        portbin(4)           => '0',
        portbin(5)           => '0',
        portbin(6)           => '0',
        portbin(7)           => '0',
        portbout(0)          => cmd(0),
        portbout(1)          => cmd(1),
        portbout(2)          => cmd(2),
        portbout(3)          => cmd(3),
        portbout(4)          => cmd_edge,
        portbout(5)          => muxsel(0),
        portbout(6)          => muxsel(1),
        portbout(7)          => muxsel(2),
        
        -- Status Port
        portdin(0)           => '0',
        portdin(1)           => '0',
        portdin(2)           => '0',
        portdin(3)           => '0',
        portdin(4)           => '0',
        portdin(5)           => '0',
        portdin(6)           => sw1,
        portdin(7)           => brkpt_active1,
        portdout             => open,

        -- Mux Port
        portein              => mux,
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

    led3 <= nRST;              -- red
    led6 <= not single;        -- red
    led8 <= not brkpt_active;  -- green

    nrst_avr <= nsw2;
    
    -- OHO DY1 Display for Testing
    dy_data(0) <= hex & "0000" & Addr(3 downto 0);
    dy_data(1) <= hex & "0000" & Addr(7 downto 4);
    dy_data(2) <= hex & "0000" & "00" & (not nsw2) & sw1;

    mux <= addr_inst(7 downto 0)   when muxsel = 0 else
           addr_inst(15 downto 8)  when muxsel = 1 else
           addr_break(7 downto 0)  when muxsel = 2 else
           addr_break(15 downto 8) when muxsel = 3 else
           addr_watch(7 downto 0)  when muxsel = 4 else
           addr_watch(15 downto 8) when muxsel = 5 else
           mode_break              when muxsel = 6 else
           mode_watch              when muxsel = 7 else
           "10101010";
           
    brkpt_active_process: process (brkpt_reg, brkpt_enable, Addr, Sync)
        variable tmp : std_logic;
        variable i  : integer;
        variable brkpt_addr : std_logic_vector(15 downto 0);
        variable brkpt_mode_i : std_logic;
        variable brkpt_mode_ar : std_logic;
        variable brkpt_mode_aw : std_logic;
    begin
        tmp := '0';
        if (brkpt_enable = '1') then
            for i in 0 to 3 loop
                brkpt_addr := brkpt_reg(i * 20 + 15 downto i * 20);
                brkpt_mode_i := brkpt_reg(i * 20 + 16);
                brkpt_mode_ar := brkpt_reg(i * 20 + 17);
                brkpt_mode_aw := brkpt_reg(i * 20 + 18);
                if (Addr = brkpt_addr) then                
                    if (Sync = '1') then
                        if (brkpt_mode_i = '1') then
                            tmp := '1';
                        end if;
                    else
                        if (RNW = '1') then
                            if (brkpt_mode_ar = '1') then
                                tmp := '1';
                            end if;
                        else
                            if (brkpt_mode_aw = '1') then
                                tmp := '1';
                            end if;
                        end if;
                     end if;
                end if;
            end loop;
        end if;
        brkpt_active <= tmp;
    end process;
        
    -- 6502 Control
    syncProcess: process (Phi2)
    begin
        if rising_edge(Phi2) then
            -- Command processing
            cmd_edge1 <= cmd_edge;
            cmd_edge2 <= cmd_edge1;
            if (cmd_edge2 = '0' and cmd_edge1 = '1') then
                -- 000x Enable/Disable single strpping
                -- 001x Enable/Disable breakpoints / watches
                -- 010x Load register
                -- 011x Reset
                -- 1000 Singe Step
                
                if (cmd(3 downto 1) = "000") then
                    single <= cmd(0);
                end if;
                
                if (cmd(3 downto 1) = "001") then
                    brkpt_enable <= cmd(0);
                end if;
                
                if (cmd(3 downto 1) = "010") then
                    brkpt_reg <= cmd(0) & brkpt_reg(brkpt_reg'length - 1 downto 1);
                end if;
                
                if (cmd(3 downto 1) = "011") then
                    reset <= cmd(0);
                end if;
            end if;

            if (reset = '1') then
                 nRST <= '0';
            else
                 nRST <= 'Z';
            end if;
            
            -- Address monitoring
            addr_sync <= Addr;          
            if (Sync = '1') then
                addr_inst <= Addr;
            end if;
            
            brkpt_active1 <= brkpt_active;
            
            -- Single Stepping
            if ((single = '0') or (cmd_edge2 = '0' and cmd_edge1 = '1' and cmd = "1000")) then
                Rdy <= (not brkpt_active);
            else
                Rdy <= (not Sync);
            end if;
        end if;
    end process;

end behavioral;


