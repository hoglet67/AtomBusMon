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
        reg_width       : integer := 46;
        fifo_width      : integer := 72
    );
    port (
        clock_avr        : in    std_logic;

        busmon_clk       : in    std_logic;
        busmon_clken     : in    std_logic;
        cpu_clk          : in    std_logic;
        cpu_clken        : in    std_logic;

        -- CPU Signals
        Addr             : in    std_logic_vector(15 downto 0);
        Data             : in    std_logic_vector(7 downto 0);
        Rd_n             : in    std_logic;
        Wr_n             : in    std_logic;
        RdIO_n           : in    std_logic;
        WrIO_n           : in    std_logic;
        Sync             : in    std_logic;
        Rdy              : out   std_logic;
        nRSTin           : in    std_logic;
        nRSTout          : out   std_logic;

        CountCycle       : in    std_logic;
        
        -- CPU Registers
        -- unused in pure bus monitor mode
        Regs             : in    std_logic_vector(255 downto 0);

        -- CPU Memory Read/Write
        -- unused in pure bus monitor mode
        RdMemOut         : out std_logic;
        WrMemOut         : out std_logic;
        RdIOOut          : out std_logic;
        WrIOOut          : out std_logic;
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
    signal fifo_rd_en      : std_logic;
    signal fifo_wr         : std_logic;
    signal fifo_wr_en      : std_logic;
    signal fifo_rst        : std_logic;

    signal memory_rd       : std_logic;
    signal memory_wr       : std_logic;
    signal io_rd           : std_logic;
    signal io_wr           : std_logic;
    signal addr_dout_reg   : std_logic_vector(23 downto 0);
    signal din_reg         : std_logic_vector(7 downto 0);

    signal Rdy_int         : std_logic;

    signal unused_a3       : std_logic;
    signal unused_b6       : std_logic;
    signal unused_b7       : std_logic;
    signal unused_d6       : std_logic;
    signal unused_d7       : std_logic;
    
begin

    inst_oho_dy1 : entity work.Oho_Dy1 port map (
        dy_clock       => clock_avr,
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
        portaout(3)          => unused_a3,
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
        portbout(6)          => unused_b6,
        portbout(7)          => unused_b7,
        
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
        portdout(6)           => unused_d6,
        portdout(7)           => unused_d7,

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
        clk    => busmon_clk,
        srst   => fifo_rst,
        din    => fifo_din,
        wr_en  => fifo_wr_en,
        rd_en  => fifo_rd_en,
        dout   => fifo_dout,
        full   => open,
        empty  => fifo_empty
    );
    fifo_wr_en <= fifo_wr and busmon_clken;
    fifo_rd_en <= fifo_rd and busmon_clken;
  
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

    -- Combinatorial set of comparators to decode breakpoint/watch addresses
    brkpt_active_process: process (brkpt_reg, brkpt_enable, Addr, Sync, Rd_n, Wr_n, RdIO_n, WrIO_n, trig)
        variable i            : integer;
        variable reg_addr     : std_logic_vector(15 downto 0);
        variable reg_mask     : std_logic_vector(15 downto 0);
        variable reg_mode_bmr : std_logic;
        variable reg_mode_bmw : std_logic;
        variable reg_mode_bir : std_logic;
        variable reg_mode_biw : std_logic;
        variable reg_mode_bx  : std_logic;
        variable reg_mode_wmr : std_logic;
        variable reg_mode_wmw : std_logic;        
        variable reg_mode_wir : std_logic;
        variable reg_mode_wiw : std_logic;
        variable reg_mode_wx  : std_logic;
        variable reg_mode_all : std_logic_vector(9 downto 0);
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
                reg_mode_bmr := brkpt_reg(i * reg_width + 32);
                reg_mode_wmr := brkpt_reg(i * reg_width + 33);
                reg_mode_bmw := brkpt_reg(i * reg_width + 34);
                reg_mode_wmw := brkpt_reg(i * reg_width + 35);
                reg_mode_bir := brkpt_reg(i * reg_width + 36);
                reg_mode_wir := brkpt_reg(i * reg_width + 37);
                reg_mode_biw := brkpt_reg(i * reg_width + 38);
                reg_mode_wiw := brkpt_reg(i * reg_width + 39);
                reg_mode_bx  := brkpt_reg(i * reg_width + 40);
                reg_mode_wx  := brkpt_reg(i * reg_width + 41);
                reg_mode_all := brkpt_reg(i * reg_width + 41 downto i * reg_width + 32);
                trigval      := brkpt_reg(i * reg_width + 42 + to_integer(unsigned(trig)));
                if (trigval = '1' and ((Addr and reg_mask) = reg_addr or (reg_mode_all = "0000000000"))) then
                    if (Sync = '1') then
                        if (reg_mode_bx = '1') then
                            bactive := '1';
                            status  := "1000";
                        elsif (reg_mode_wx = '1') then
                            wactive := '1';
                            status  := "1001";
                        end if;
                    elsif (Rd_n = '0') then
                        if (reg_mode_bmr = '1') then
                            bactive := '1';
                            status  := "0000";
                        elsif (reg_mode_wmr = '1') then
                            wactive := '1';
                            status  := "0001";
                        end if;
                    elsif (Wr_n = '0') then
                        if (reg_mode_bmw = '1') then
                            bactive := '1';
                            status  := "0010";
                        elsif (reg_mode_wmw = '1') then
                            wactive := '1';
                            status  := "0011";
                        end if;
                    elsif (RdIO_n = '0') then
                        if (reg_mode_bir = '1') then
                            bactive := '1';
                            status  := "0100";
                        elsif (reg_mode_wir = '1') then
                            wactive := '1';
                            status  := "0101";
                        end if;
                    elsif (WrIO_n = '0') then
                        if (reg_mode_biw = '1') then
                            bactive := '1';
                            status  := "0110";
                        elsif (reg_mode_wiw = '1') then
                            wactive := '1';
                            status  := "0111";
                        end if;
                    end if;
                end if;
            end loop;
        end if;
        watch_active <= wactive;
        brkpt_active <= bactive;
        bw_status    <= status;
    end process;
   
    -- CPU Control Commands
    -- 0000x Enable/Disable single strpping
    -- 0001x Enable/Disable breakpoints / watches
    -- 0010x Load breakpoint / watch register
    -- 0011x Reset CPU
    -- 01000 Singe Step CPU
    -- 01001 Read FIFO
    -- 01010 Reset FIFO
    -- 01011 Unused
    -- 0110x Load address/data register
    -- 0111x Unused
    -- 10000 Read Memory
    -- 10001 Read Memory and Auto Inc Address
    -- 10010 Write Memory
    -- 10011 Write Memory and Auto Inc Address
    -- 10000 Read Memory
    -- 10001 Read Memory and Auto Inc Address
    -- 10010 Write Memory
    -- 10011 Write Memory and Auto Inc Address
    -- 1x1xx Unused
    -- 11xxx Unused

    cpuProcess: process (busmon_clk)
    begin
        if rising_edge(busmon_clk) then
            if busmon_clken = '1' then
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
                io_rd     <= '0';
                io_wr     <= '0';
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

                    if (cmd(4 downto 1) = "1010") then
                        io_rd <= '1';
                        auto_inc  <= cmd(0); 
                    end if;

                    if (cmd(4 downto 1) = "1011") then
                        io_wr <= '1';
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
                    SS_Step <= (not brkpt_active);            
                else
                    Rdy_int <= (not Sync);
                end if;
                
                nRSTout <= not reset;
                
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
        end if;
    end process;

    dataProcess: process (cpu_clk)
    begin
        if rising_edge(cpu_clk) then
            if cpu_clken = '1' then
                -- Latch the data bus for use in watches
                Data1 <= Data;
                -- Latch memory read in response to a read command
                if (Done = '1') then
                    din_reg <= DataIn;
                end if;
            end if;
        end if;
    end process;
    
    Rdy <= Rdy_int;
    RdMemOut <= memory_rd;
    WrMemOut <= memory_wr;
    RdIOOut <= io_rd;
    WrIOOut <= io_wr;
    AddrOut <= addr_dout_reg(23 downto 8);
    DataOut <= addr_dout_reg(7 downto 0);
    SS_Single <= single;

end behavioral;


