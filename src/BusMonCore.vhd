--------------------------------------------------------------------------------
-- Copyright (c) 2015 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : BusMonCore.vhd
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


entity BusMonCore is
    generic (
        num_comparators : integer := 8;
        reg_width       : integer := 42;
        fifo_width      : integer := 72
    );
    port (
        clock49         : in    std_logic;

        -- 6502 Signals
        Addr             : in    std_logic_vector(15 downto 0);
        Data             : in    std_logic_vector(7 downto 0);
        Phi2             : in    std_logic;
        Rd_n             : in    std_logic;
        Wr_n             : in    std_logic;
        Sync             : in    std_logic;
        Rdy              : out   std_logic;
        nRSTin           : in    std_logic;
        nRSTout          : out   std_logic;

        CountCycle       : in    std_logic;
        
        -- 6502 Registers
        -- unused in pure bus monitor mode
        Regs             : in    std_logic_vector(255 downto 0);

        -- 6502 Memory Read/Write
        -- unused in pure bus monitor mode
        RdOut            : out std_logic;
        WrOut            : out std_logic;
        AddrOut          : out std_logic_vector(15 downto 0);
        DataOut          : out std_logic_vector(7 downto 0);
        DataIn           : in std_logic_vector(7 downto 0);
        Done             : in std_logic;
        
        -- Single Step interface
        SS_Single        : out std_logic;
        SS_Step          : out std_logic;
        
        -- External trigger inputs
        trig             : in    std_logic_vector(1 downto 0);
                    
        -- HD44780 LCD
        lcd_rs           : out   std_logic;
        lcd_rw           : out   std_logic;
        lcd_e            : out   std_logic;
        lcd_db           : inout std_logic_vector(7 downto 4);

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
end BusMonCore;

architecture behavioral of BusMonCore is

    signal clock_avr       : std_logic;
    signal nrst_avr        : std_logic;
    signal lcd_rw_int      : std_logic;
    signal lcd_db_in       : std_logic_vector(7 downto 4);
    signal lcd_db_out      : std_logic_vector(7 downto 4);
    signal dy_counter      : std_logic_vector(31 downto 0);
    signal dy_data         : y2d_type ;

    signal mux             : std_logic_vector(7 downto 0);
    signal muxsel          : std_logic_vector(5 downto 0);
    signal cmd_edge        : std_logic;
    signal cmd_edge1       : std_logic;
    signal cmd_edge2       : std_logic;
    signal cmd             : std_logic_vector(4 downto 0);

    signal addr_sync       : std_logic_vector(15 downto 0);
    signal addr_inst       : std_logic_vector(15 downto 0);
    signal Addr1           : std_logic_vector(15 downto 0);
    signal Data1           : std_logic_vector(7 downto 0);

    signal cycleCount      : std_logic_vector(23 downto 0);
    signal cycleCount_inst : std_logic_vector(23 downto 0);

    signal single          : std_logic;
    signal reset           : std_logic;
    signal step            : std_logic;

    signal bw_status       : std_logic_vector(3 downto 0);
    signal bw_status1      : std_logic_vector(3 downto 0);
    
    signal auto_inc        : std_logic;
    
    signal brkpt_reg       : std_logic_vector(num_comparators * reg_width - 1 downto 0);
    signal brkpt_enable    : std_logic;
    signal brkpt_active    : std_logic;
    signal brkpt_active1   : std_logic;
    signal watch_active    : std_logic;
    
    signal fifo_din        : std_logic_vector(fifo_width - 1 downto 0);
    signal fifo_dout       : std_logic_vector(fifo_width - 1 downto 0);
    signal fifo_empty      : std_logic;
    signal fifo_rd         : std_logic;
    signal fifo_wr         : std_logic;
    signal fifo_rst        : std_logic;

    signal memory_rd       : std_logic;
    signal memory_wr       : std_logic;
    signal addr_dout_reg   : std_logic_vector(23 downto 0);
    signal din_reg         : std_logic_vector(7 downto 0);

    signal Rdy_int         : std_logic;
    
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
        portbout(4)          => cmd(4),
        portbout(5)          => cmd_edge,
        portbout(6)          => open,
        portbout(7)          => open,
        
        -- Status Port
        portdin(0)           => '0',
        portdin(1)           => '0',
        portdin(2)           => '0',
        portdin(3)           => '0',
        portdin(4)           => '0',
        portdin(5)           => '0',
        portdin(6)           => sw1,
        portdin(7)           => not fifo_empty,
        
        portdout(0)           => muxsel(0),
        portdout(1)           => muxsel(1),
        portdout(2)           => muxsel(2),
        portdout(3)           => muxsel(3),
        portdout(4)           => muxsel(4),
        portdout(5)           => muxsel(5),
        portdout(6)           => open,
        portdout(7)           => open,

        -- Mux Port
        portein              => mux,
        porteout             => open,
                
        spi_mosio            => open,
        spi_scko             => open,
        spi_misoi            => '0',
     
        rxd                  => avr_RxD,
        txd                  => avr_TxD
    );

    WatchEvents_inst : entity work.WatchEvents port map(
        clk    => Phi2,
        srst   => fifo_rst,
        din    => fifo_din,
        wr_en  => fifo_wr,
        rd_en  => fifo_rd,
        dout   => fifo_dout,
        full   => open,
        empty  => fifo_empty
    );
  
    -- The fifo is writen the cycle after the break point
    -- Addr1 is the address bus delayed by 1 cycle
    -- DataWr1 is the data being written delayed by 1 cycle
    -- DataRd is the data being read, that is already one cycle late
    -- bw_state1(1) is 1 for writes, and 0 for reads
    fifo_din <= cycleCount_inst & "0000" & bw_status1 & Data1 & Addr1 & addr_inst;

    lcd_rw    <= lcd_rw_int;
    lcd_db    <= lcd_db_out when lcd_rw_int = '0' else (others => 'Z');
    lcd_db_in <= lcd_db;

    led3 <= not trig(0);       -- red
    led6 <= not trig(1);       -- red
    led8 <= not brkpt_active;  -- green

    nrst_avr <= nsw2;
    
    -- OHO DY1 Display for Testing
    dy_data(0) <= hex & "0000" & Addr(3 downto 0);
    dy_data(1) <= hex & "0000" & Addr(7 downto 4);
    dy_data(2) <= hex & "0000" & "00" & (not nsw2) & sw1;

    mux <= addr_inst(7 downto 0)            when muxsel = 0 else
           addr_inst(15 downto 8)           when muxsel = 1 else
           din_reg                          when muxsel = 2 else
           cycleCount(23 downto 16)         when muxsel = 3 else
           cycleCount(7 downto 0)           when muxsel = 4 else
           cycleCount(15 downto 8)          when muxsel = 5 else

           fifo_dout(7 downto 0)            when muxsel = 6 else
           fifo_dout(15 downto 8)           when muxsel = 7 else
           fifo_dout(23 downto 16)          when muxsel = 8 else
           fifo_dout(31 downto 24)          when muxsel = 9 else          
           fifo_dout(39 downto 32)          when muxsel = 10 else
           fifo_dout(47 downto 40)          when muxsel = 11 else
           fifo_dout(55 downto 48)          when muxsel = 12 else
           fifo_dout(63 downto 56)          when muxsel = 13 else
           fifo_dout(71 downto 64)          when muxsel = 14 else
           
           Regs(8 * to_integer(unsigned(muxsel(4 downto 0))) + 7 downto 8 * to_integer(unsigned(muxsel(4 downto 0))));

--           Regs( 15 downto   8)             when muxsel = 33 else
--           Regs( 23 downto  16)             when muxsel = 34 else
--           Regs( 31 downto  24)             when muxsel = 35 else
--           Regs( 39 downto  32)             when muxsel = 36 else
--           Regs( 47 downto  40)             when muxsel = 37 else
--           Regs( 55 downto  48)             when muxsel = 38 else
--           Regs( 63 downto  56)             when muxsel = 39 else           
--           Regs(  7 downto  64)             when muxsel = 40 else
--           Regs( 15 downto  72)             when muxsel = 41 else
--           Regs( 23 downto  80)             when muxsel = 42 else
--           Regs( 31 downto  88)             when muxsel = 43 else
--           Regs( 39 downto  96)             when muxsel = 44 else
--           Regs( 47 downto 104)             when muxsel = 45 else
--           Regs( 55 downto 112)             when muxsel = 46 else
--           Regs( 63 downto 120)             when muxsel = 47 else           
--           Regs(  7 downto 128)             when muxsel = 48 else
--           Regs( 15 downto 136)             when muxsel = 49 else
--           Regs( 23 downto 144)             when muxsel = 50 else
--           Regs( 31 downto  24)             when muxsel = 51 else
--           Regs( 39 downto  32)             when muxsel = 52 else
--           Regs( 47 downto  40)             when muxsel = 53 else
--           Regs( 55 downto  48)             when muxsel = 54 else
--           Regs( 63 downto  56)             when muxsel = 55 else           
--           Regs(  7 downto   0)             when muxsel = 56 else
--           Regs( 15 downto   8)             when muxsel = 57 else
--           Regs( 23 downto  16)             when muxsel = 58 else
--           Regs( 31 downto  24)             when muxsel = 59 else
--           Regs( 39 downto  32)             when muxsel = 60 else
--           Regs( 47 downto  40)             when muxsel = 61 else
--           Regs( 55 downto  48)             when muxsel = 62 else
--           Regs( 63 downto  56)             when muxsel = 63 else           
--
--
--           "10101010";

    -- Combinatorial set of comparators to decode breakpoint/watch addresses
    brkpt_active_process: process (brkpt_reg, brkpt_enable, Addr, Sync)
        variable i            : integer;
        variable reg_addr     : std_logic_vector(15 downto 0);
        variable reg_mask     : std_logic_vector(15 downto 0);
        variable reg_mode_bi  : std_logic;
        variable reg_mode_bar : std_logic;
        variable reg_mode_baw : std_logic;
        variable reg_mode_wi  : std_logic;
        variable reg_mode_war : std_logic;
        variable reg_mode_waw : std_logic;
        variable bactive      : std_logic;
        variable wactive      : std_logic;
        variable status       : std_logic_vector(3 downto 0);
        variable trigval      : std_logic;
    begin
        bactive := '0';
        wactive := '0';
        status  := (others => '0');
        if (brkpt_enable = '1') then
            for i in 0 to num_comparators - 1 loop
                reg_addr     := brkpt_reg(i * reg_width + 15 downto i * reg_width);
                reg_mask     := brkpt_reg(i * reg_width + 31 downto i * reg_width + 16);
                reg_mode_bi  := brkpt_reg(i * reg_width + 32);
                reg_mode_bar := brkpt_reg(i * reg_width + 33);
                reg_mode_baw := brkpt_reg(i * reg_width + 34);
                reg_mode_wi  := brkpt_reg(i * reg_width + 35);
                reg_mode_war := brkpt_reg(i * reg_width + 36);
                reg_mode_waw := brkpt_reg(i * reg_width + 37);
                trigval      := brkpt_reg(i * reg_width + 38 + to_integer(unsigned(trig)));
                if (trigval = '1' and ((Addr and reg_mask) = reg_addr or
                   (reg_mode_bi = '0' and reg_mode_bar = '0' and reg_mode_baw = '0' and
                   (reg_mode_wi = '0' and reg_mode_war = '0' and reg_mode_waw = '0')))) then
                    if (Sync = '1') then
                        if (reg_mode_bi = '1') then
                            bactive := '1';
                            status  := "0001";
                        end if;
                        if (reg_mode_wi = '1') then
                            wactive := '1';
                            status  := "1001";
                        end if;
                    else
                        if (Rd_n = '0') then
                            if (reg_mode_bar = '1') then
                                bactive := '1';
                                status  := "0010";
                            end if;
                            if (reg_mode_war = '1') then
                                wactive := '1';
                                status  := "1010";
                            end if;
                        end if;
                        if (Wr_n = '0') then
                            if (reg_mode_baw = '1') then
                                bactive := '1';
                                status  := "0100";
                            end if;
                            if (reg_mode_waw = '1') then
                                wactive := '1';
                                status  := "1100";
                            end if;
                        end if;
                     end if;
                end if;
            end loop;
        end if;
        watch_active <= wactive;
        brkpt_active <= bactive;
        bw_status    <= status;
    end process;
   
    -- 6502 Control Commands
    -- 0000x Enable/Disable single stepping
    -- 0001x Enable/Disable breakpoints / watches
    -- 0010x Load breakpoint register
    -- 0011x Reset
    -- 01000 Single Step
    -- 01001 FIFO Read
    -- 01010 FIFO Reset
    -- 0110x Load memory address/data register
    -- 0111x Unused 
    -- 1000x Read memory
    -- 1001x Write memory
    -- 101xx Unused
    -- 11xxx Unused
    risingProcess: process (Phi2)
    begin
        if rising_edge(Phi2) then
        
            -- Cycle counter, wraps every 16s at 1MHz
            if (nRSTin = '0') then
                cycleCount <= (others => '0');
            elsif (CountCycle = '1') then
                cycleCount <= cycleCount + 1;
            end if;
        
            -- Command processing
            cmd_edge1 <= cmd_edge;
            cmd_edge2 <= cmd_edge1;
            fifo_rd   <= '0';
            fifo_wr   <= '0';
            fifo_rst  <= '0';
            memory_rd <= '0';
            memory_wr <= '0';
            SS_Step   <= '0';
            if (cmd_edge2 = '0' and cmd_edge1 = '1') then
                if (cmd(4 downto 1) = "0000") then
                    single <= cmd(0);
                end if;
                
                if (cmd(4 downto 1) = "0001") then
                    brkpt_enable <= cmd(0);
                end if;
                
                if (cmd(4 downto 1) = "0010") then
                    brkpt_reg <= cmd(0) & brkpt_reg(brkpt_reg'length - 1 downto 1);
                end if;

                if (cmd(4 downto 1) = "0110") then
                    addr_dout_reg <= cmd(0) & addr_dout_reg(addr_dout_reg'length - 1 downto 1);
                end if;
                
                if (cmd(4 downto 1) = "0011") then
                    reset <= cmd(0);
                end if;

                if (cmd(4 downto 0) = "01001") then
                    fifo_rd <= '1';
                end if;                

                if (cmd(4 downto 0) = "01010") then
                    fifo_rst <= '1';
                end if;

                if (cmd(4 downto 1) = "1000") then
                    memory_rd <= '1';
                    auto_inc  <= cmd(0); 
                end if;

                if (cmd(4 downto 1) = "1001") then
                    memory_wr <= '1';
                    auto_inc  <= cmd(0); 
                end if;
                
            end if;
            
            -- Auto increment the memory address reg the cycle after a rd/wr
            if (auto_inc = '1' and Done = '1') then
                addr_dout_reg(23 downto 8) <= addr_dout_reg(23 downto 8) + 1;
            end if;

            -- Single Stepping
            if (brkpt_active = '1') then
                single <= '1';
            end if;
            
            if ((single = '0') or (cmd_edge2 = '0' and cmd_edge1 = '1' and cmd = "01000")) then
                Rdy_int <= (not brkpt_active);
                SS_Step <= '1';
            else
                Rdy_int <= (not Sync);
            end if;
            
            -- 6502 Reset needs to be open collector
            if (reset = '1') then
                 nRSTout <= '0';
            else
                 nRSTout <= 'Z';
            end if;
            
            -- Latch instruction address for the whole cycle
            if (Sync = '1') then
                addr_inst <= Addr;
                cycleCount_inst <= cycleCount;
            end if;
            
            -- Breakpoints and Watches written to the FIFO
            brkpt_active1 <= brkpt_active;
            bw_status1    <= bw_status;
            if watch_active = '1' or (brkpt_active = '1' and brkpt_active1 = '0') then
                fifo_wr <= '1';
                Addr1 <= Addr;
            end if;
            
        end if;
    end process;

    fallingProcess: process (Phi2)
    begin
        if falling_edge(Phi2) then
            -- Latch the data bus for use in watches
            Data1 <= Data;
            -- Latch memory read in response to a read command
            if (Done = '1') then
                din_reg <= DataIn;
            end if;
        end if;
    end process;
    
    Rdy <= Rdy_int;
    RdOut <= memory_rd;
    WrOut <= memory_wr;
    AddrOut <= addr_dout_reg(23 downto 8);
    DataOut <= addr_dout_reg(7 downto 0);
    SS_Single <= single;

end behavioral;


