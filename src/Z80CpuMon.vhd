--------------------------------------------------------------------------------
-- Copyright (c) 2015 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : Z80CpuMon.vhd
-- /___/   /\     Timestamp : 22/06/2015
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: Z80CpuMon
--Device: XC3S250E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.OhoPack.all ;

entity Z80CpuMon is
    generic (
       UseT80Core    : boolean := true
       );
    port (
        clock49         : in    std_logic;
          
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

        -- External trigger inputs
        trig            : in    std_logic_vector(1 downto 0);
        
        -- Serial Console
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
        tcclk           : out   std_logic;
        
        -- Debugging signals
        test1           : out   std_logic;
        test2           : out   std_logic;
        test3           : out   std_logic;
        test4           : out   std_logic
        
    );
end Z80CpuMon;

architecture behavioral of Z80CpuMon is

signal RESET_n_int : std_logic;
signal cpu_clk : std_logic;
signal busmon_clk : std_logic;

signal Addr_int : std_logic_vector(15 downto 0);        
signal RD_n_int : std_logic;
signal WR_n_int : std_logic;
signal MREQ_n_int : std_logic;
signal IORQ_n_int : std_logic;
signal M1_n_int : std_logic;
signal WAIT_n_int : std_logic;
signal TState : std_logic_vector(2 downto 0);        
signal SS_Single : std_logic;
signal SS_Step : std_logic;
signal SS_Step_held : std_logic;

signal Regs : std_logic_vector(63 downto 0);        
signal Write : std_logic;

signal INT_n_sync : std_logic;
signal NMI_n_sync : std_logic;

signal Rdy        : std_logic;
signal Read_n     : std_logic;
signal Read_n0    : std_logic;
signal Read_n1    : std_logic;
signal Write_n    : std_logic;
signal Write_n0   : std_logic;
signal Sync       : std_logic;
signal Sync0      : std_logic;
signal nRST       : std_logic;

signal ex_data : std_logic_vector(7 downto 0);
signal rd_data : std_logic_vector(7 downto 0);
signal mon_data : std_logic_vector(7 downto 0);

begin

      mon : entity work.BusMonCore
      generic map (
        num_comparators => 8
      )
      port map (  
        clock49 => clock49,
        Addr    => Addr_int,
        Data    => mon_data,
        Phi2    => busmon_clk,
        Rd_n    => Read_n,
        Wr_n    => Write_n,
        Sync    => Sync,
        Rdy     => Rdy,
        SS_Single => SS_Single,
        SS_Step => SS_Step,
        nRSTin    => RESET_n_int,
        nRSTout    => nRST,
        trig    => trig,
        lcd_rs  => open,
        lcd_rw  => open,
        lcd_e   => open,
        lcd_db  => open,
        avr_RxD => avr_RxD,
        avr_TxD => avr_TxD,
        sw1     => '0',
        nsw2    => nsw2,
        led3    => led3,
        led6    => led6,
        led8    => led8,
        tmosi   => tmosi,
        tdin    => tdin,
        tcclk   => tcclk,
        Regs    => Regs(63 downto 0),
        RdOut   => open,
        WrOut   => open,
        AddrOut => open,
        DataOut => open,
        DataIn  => (others => '0')
    );

    GenT80Core: if UseT80Core generate
        inst_t80: entity work.T80a port map (
            TS      => TState,
            Regs    => Regs,
            RESET_n => RESET_n_int,
            CLK_n   => cpu_clk,
            WAIT_n  => WAIT_n_int,
            INT_n   => INT_n_sync,
            NMI_n   => NMI_n_sync,
            BUSRQ_n => BUSRQ_n,
            M1_n    => M1_n_int,
            MREQ_n  => MREQ_n_int,
            IORQ_n  => IORQ_n_int,
            RD_n    => RD_n_int,
            WR_n    => WR_n_int,
            RFSH_n  => RFSH_n,
            HALT_n  => HALT_n,
            BUSAK_n => BUSAK_n,
            A       => Addr_int,
            D       => Data            
        );
    end generate;
 
    WAIT_n_int <= WAIT_n when SS_Single = '0'
                  else WAIT_n and SS_Step_held;
            
    
    sync_gen : process(CLK_n, RESET_n_int)
    begin
        if RESET_n_int = '0' then
            NMI_n_sync <= '1';
            INT_n_sync <= '1';
            SS_Step_held <= '1';
        elsif rising_edge(CLK_n) then
            NMI_n_sync <= NMI_n;
            INT_n_sync <= INT_n;
            if (M1_n_int = '0' and TState = "001") then
                -- stop at the end of T1 instruction fetch
                SS_Step_held <= '0';
            elsif (SS_Step = '1') then
                -- start again when the single step command is issues
                SS_Step_held <= '1';
            end if;
        end if;
    end process;

    
    -- Make the monitoring decision in the middle of T2, but only if WAIT_n is '1'
    Sync0    <=     (WAIT_n_int and (not RD_n_int) and (not MREQ_n_int) and (not M1_n_int)) when TState = "010" else '0'; 
    Read_n0  <= not (WAIT_n_int and (not RD_n_int) and (not MREQ_n_int) and     (M1_n_int)) when TState = "010" else '1'; 
    Write_n0 <= not (WAIT_n_int and (not WR_n_int) and (not MREQ_n_int) and     (M1_n_int)) when TState = "010" else '1'; 

    -- These are useful for debugging IO Requests:
    -- Read_n0  <= not (WAIT_n_int and (not RD_n_int) and (not IORQ_n_int) and     (M1_n_int)) when TState = "010" else '1'; 
    -- Write_n0 <= not (               (    RD_n_int) and (not IORQ_n_int) and     (M1_n_int)) when TState = "011" else '1'; 

    -- Hold the monitoring decision so it is valid on the rising edge of the clock
    -- For instruction fetches and writes, the monitor sees these at the start of T3
    -- For reads, the data can arrive in the middle of T3 so delay until end of T3
    watch_gen : process(CLK_n)
    begin
        if falling_edge(CLK_n) then
            Sync <= Sync0;
            Read_n1 <= Read_n0;
            Read_n <= Read_n1;
            Write_n <= Write_n0;
        end if;
    end process;

    -- Register the exec/write data on the rising at the end of T2
    ex_data_latch : process(CLK_n)
    begin
        if rising_edge(CLK_n) then
            if (Sync = '1' or Write_n = '0') then            
                ex_data <= Data;
            end if;
        end if;
    end process;
    
    -- Register the read data on the falling edge of clock in the middle of T3
    rd_data_latch : process(CLK_n)
    begin
        if falling_edge(CLK_n) then
            if (Read_n1 = '0') then            
                rd_data <= Data;
            end if;
        end if;
    end process;

    -- Mux the data seen by the bus monitor appropriately
    mon_data <= rd_data when Read_n <= '0' else ex_data;

    Addr <= Addr_int;
    WR_n <= WR_n_int;
    RD_n <= RD_n_int;
    MREQ_n <= MREQ_n_int;
    IORQ_n <= IORQ_n_int;
    M1_n <= M1_n_int;
    RESET_n_int <= RESET_n and (not sw1) and nRST;
    
    test1 <= TState(0);
    test2 <= TState(1);
    test3 <= TState(2);
    test4 <= CLK_n;
    
    cpu_clk <= CLK_n;
    busmon_clk <= CLK_n;
    
end behavioral;
