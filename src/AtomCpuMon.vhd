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
        --Rdy             : in    std_logic;
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
        Res_n           : inout std_logic;

        -- External trigger inputs
        trig             : in    std_logic_vector(1 downto 0);
        
        -- Jumpers
        fakeTube_n      : in     std_logic;

        -- Serial Console
        avr_RxD         : in     std_logic;
        avr_TxD         : out    std_logic;
        
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
    signal R_W_n_int     : std_logic;
    signal Sync_int      : std_logic;
    signal Rdy_int       : std_logic;
    signal Addr_int      : std_logic_vector(15 downto 0);
    signal IRQ_n_sync    : std_logic;
    signal NMI_n_sync    : std_logic;
    
    signal Phi0_a        : std_logic;
    signal Phi0_b        : std_logic;
    signal Phi0_c        : std_logic;
    signal Phi0_d        : std_logic;
    signal cpu_clk       : std_logic;
    signal busmon_clk    : std_logic;
    
    signal Regs          : std_logic_vector(63 downto 0);
    signal memory_rd     : std_logic;
    signal memory_wr     : std_logic;
    signal memory_addr   : std_logic_vector(15 downto 0);
    signal memory_dout   : std_logic_vector(7 downto 0);
    signal memory_din    : std_logic_vector(7 downto 0);
    
begin

    mon : entity work.BusMonCore port map (  
        clock49 => clock49,
        Addr    => Addr_int,
        Phi2    => busmon_clk,
        RNW     => R_W_n_int,
        Sync    => Sync_int,
        Rdy     => Rdy_int,
        nRST    => Res_n,
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
        Regs    => Regs,
        RdOut   => memory_rd,
        WrOut   => memory_wr,
        AddrOut => memory_addr,
        DataOut => memory_dout,
        DataIn  => memory_din        
    );

    cpu_t65 : entity work.T65 port map (
        mode            => "00",
        Abort_n         => '1',
        SO_n            => SO_n,
        Res_n           => Res_n,
        Enable          => Rdy_int,
        Clk             => cpu_clk,
        Rdy             => '1',
        IRQ_n           => IRQ_n_sync,
        NMI_n           => NMI_n_sync,
        R_W_n           => R_W_n_int,
        Sync            => Sync_int,
        A(23 downto 16) => open,
        A(15 downto 0)  => Addr_int,
        DI              => Din,
        DO              => Dout,
        Regs            => Regs
    );

    sync_gen : process(cpu_clk, Res_n)
    begin
        if Res_n = '0' then
          NMI_n_sync <= '1';
          IRQ_n_sync <= '1';
        elsif rising_edge(cpu_clk) then
          NMI_n_sync <= NMI_n;
          IRQ_n_sync <= IRQ_n;            
        end if;
    end process;
    
    R_W_n <= '1' when memory_rd = '1' else '0' when memory_wr = '1' else R_W_n_int;
    Addr <= memory_addr when (memory_rd = '1' or memory_wr = '1') else Addr_int;
    Sync <= Sync_int;

    data_latch : process(Phi0)
    begin
        if falling_edge(Phi0) then
            if (fakeTube_n = '0' and Addr_int = x"FEE0") then
                Din        <= x"FE";
            else 
                Din        <= Data;
            end if;
            memory_din <= Data;
        end if;
    end process;
    
    Data       <= memory_dout when Phi0_c = '1' and memory_wr = '1' else
                         Dout when Phi0_c = '1' and R_W_n_int = '0' and memory_rd = '0' else
               (others => 'Z');

    clk_gen : process(clock49)
    begin
        if rising_edge(clock49) then
          Phi0_a <= Phi0;
          Phi0_b <= Phi0_a;
          Phi0_c <= Phi0_b;
          Phi0_d <= Phi0_c;
        end if;
    end process;

    Phi1       <= not (Phi0_b or Phi0_d);
    Phi2       <= Phi0_b and Phi0_d;
    cpu_clk    <= not Phi0_d;
    busmon_clk <= Phi0_d;

end behavioral;
    
