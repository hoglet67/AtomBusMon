--------------------------------------------------------------------------------
-- Copyright (c) 2015 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    
-- \   \   \/    
--  \   \         
--  /   /         Filename  : MC6808ECpuMon.vhd
-- /___/   /\     Timestamp : 02/07/2015
-- \   \  /  \ 
--  \___\/\___\ 
--
--Design Name: MC6808ECpuMon
--Device: XC3S250E

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.OhoPack.all ;

entity MC6809ECpuMon is
    generic (
       UseCPU09Core    : boolean := true
       );
    port (
        clock49         : in    std_logic;
          
        --6809 Signals
        E               : in    std_logic;
        Q               : in    std_logic;        
        RES_n           : inout std_logic;
        NMI_n           : in    std_logic;
        IRQ_n           : in    std_logic;
        FIRQ_n          : in    std_logic;
        HALT_n          : in    std_logic;
        TSC             : in    std_logic;
        BS              : out   std_logic;
        BA              : out   std_logic;
        BUSY            : out   std_logic;
        R_W_n           : out   std_logic;
        LIC             : out   std_logic;
        AVMA            : out   std_logic;

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
end MC6809ECpuMon;

architecture behavioral of MC6809ECpuMon is

signal cpu_clk       : std_logic;
signal busmon_clk    : std_logic;
signal R_W_n_int     : std_logic;
signal LIC_int       : std_logic;
signal NMI_sync      : std_logic;
signal IRQ_sync      : std_logic;
signal FIRQ_sync     : std_logic;
signal RES_sync      : std_logic;
signal HALT_sync     : std_logic;
signal Addr_int      : std_logic_vector(15 downto 0);
signal Din           : std_logic_vector(7 downto 0);
signal Dout          : std_logic_vector(7 downto 0);
signal Sync_int      : std_logic;
signal Rdy_int       : std_logic;

signal memory_rd     : std_logic;
signal memory_wr     : std_logic;
signal memory_addr   : std_logic_vector(15 downto 0);
signal memory_dout   : std_logic_vector(7 downto 0);
signal memory_din    : std_logic_vector(7 downto 0);
signal memory_done   : std_logic;

signal Regs          : std_logic_vector(111 downto 0);
signal Regs1         : std_logic_vector(255 downto 0);

signal clock7_3728   : std_logic;
signal clk_count     : std_logic_vector(1 downto 0);

begin

    inst_dcm1 : entity work.DCM1 port map(
        CLKIN_IN          => clock49,
        CLK0_OUT          => clock7_3728,
        CLK0_OUT1         => open,
        CLK2X_OUT         => open
    );
    
    mon : entity work.BusMonCore
      generic map (
        num_comparators => 4
      )
      port map (  
        clock49 => clock49,
        Addr    => Addr_int,
        Data    => Data,
        Phi2    => busmon_clk,
        Rd_n    => not R_W_n_int,
        Wr_n    => R_W_n_int,
        RdIO_n  => '1',
        WrIO_n  => '1',
        Sync    => Sync_int,
        Rdy     => Rdy_int,
        nRSTin  => RES_n,
        nRSTout => RES_n,
        CountCycle => Rdy_int,
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
        Regs    => Regs1,
        RdMemOut=> memory_rd,
        WrMemOut=> memory_wr,
        RdIOOut => open,
        WrIOOut => open,
        AddrOut => memory_addr,
        DataOut => memory_dout,
        DataIn  => memory_din,
        Done    => memory_done,
        SS_Step => open,
        SS_Single => open
    );
    
    Regs1(111 downto 0) <= Regs;
    Regs1(255 downto 112) <= (others => '0');

    GenCPU09Core: if UseCPU09Core generate
        inst_cpu09: entity work.cpu09 port map (
            clk      => cpu_clk,
            rst      => RES_sync,
            vma      => AVMA,
            lic_out  => LIC_int,
            ifetch   => open,
            opfetch  => open,
            ba       => BA,
            bs       => BS,
            addr     => Addr_int,
            rw       => R_W_n_int,
            data_out => Dout,
            data_in  => Din,
            irq      => IRQ_sync,
            firq     => FIRQ_sync,
            nmi      => NMI_sync,
            halt     => HALT_sync,
            hold     => not RDY_int,
            Regs     => Regs
        );
    end generate;

    clk_gen : process(clock7_3728)
    begin
        if rising_edge(clock7_3728) then
            clk_count <= clk_count + 1;
        end if;
    end process;

    irq_gen : process(cpu_clk)
    begin
        if falling_edge(cpu_clk) then
            NMI_sync   <= not NMI_n;
            IRQ_sync   <= not IRQ_n;
            FIRQ_sync  <= not FIRQ_n;
            RES_sync   <= not RES_n;
            HALT_sync  <= not HALT_n;
        end if;
    end process;
    
    sync_gen : process(cpu_clk)
    begin
        if rising_edge(cpu_clk) then
            if (RDY_int = '1') then
                Sync_int <= LIC_int;
            end if;
        end if;
    end process;    

    cpu_clk    <= not E;
    busmon_clk <= E;
    
    R_W_n <= 'Z' when TSC = '1' else
             '1' when memory_rd = '1' else
             '0' when memory_wr = '1' else
             R_W_n_int;

    Addr <=  (others => 'Z') when TSC = '1' else
             memory_addr when (memory_rd = '1' or memory_wr = '1') else
             Addr_int;

    Din        <= Data;
    memory_din <= Data;

    Data       <= memory_dout when TSC = '0' and E = '1' and memory_wr = '1' else
                         Dout when TSC = '0' and E = '1' and R_W_n_int = '0' and memory_rd = '0' else
                  (others => 'Z');
    
    memory_done <= memory_rd or memory_wr;
    
    BUSY    <= '0';
    LIC     <= LIC_int;
    
    test1   <= Sync_int;
    test2   <= RDY_int;
    test3   <= LIC_int;
    test4   <= clk_count(1);
    
end behavioral;
