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
--
-- This desing uses a DCM to generate a 16x internal clock from Phi0
-- Output signals can be placed in units of 1/16th Phi0
--
-- There are two constraints to be aware of:
--
-- 1. There is no defined phase relationship between Phi0 and Phi1/2
-- This is because Phi is typically too slow for a Spartan -6 DLL
-- If the host system also uses Phi0, then this may cause problems.
--
-- 2. Phi0 must be a single frequency clock, or the DCM will not lock
-- This will not, therefore, work in a Beeb because of the clock
-- stretching when IO devices are accessed.
--
-- The Atom satisfies both of these constraints.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.OhoPack.all ;

entity AtomFast6502 is
    generic (
       UseT65Core    : boolean := true;
       UseAlanDCore  : boolean := false
       );
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
        R_W_n           : out   std_logic;
        Data            : inout std_logic_vector(7 downto 0);
        SO_n            : in    std_logic;
        Res_n           : inout std_logic;

        -- External trigger inputs
        trig             : in    std_logic_vector(1 downto 0);
        
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
end AtomFast6502;

architecture behavioral of AtomFast6502 is
        
    -- Clocking
    signal clock_avr     : std_logic;
    signal clock_16x     : std_logic;    
    signal clk_div       : std_logic_vector(3 downto 0);
    signal cpu_clken     : std_logic;
    signal cpu_dataen    : std_logic;
    signal busmon_clken  : std_logic;

    -- DCM watchdog
    signal dcm_reset     : std_logic;
    signal dcm_locked    : std_logic;
    signal dcm_count     : std_logic_vector(9 downto 0);
    signal edge0         : std_logic;
    signal edge1         : std_logic;

    signal Din           : std_logic_vector(7 downto 0);

    signal Addr0         : std_logic_vector(15 downto 0);
    signal R_W_n0        : std_logic;
    signal Sync0         : std_logic;
    signal Dout0         : std_logic_vector(7 downto 0);

    signal Addr1         : std_logic_vector(15 downto 0);
    signal R_W_n1        : std_logic;
    signal Sync1         : std_logic;
    signal Dout1         : std_logic_vector(7 downto 0);

    signal IRQ_n_sync    : std_logic;
    signal NMI_n_sync    : std_logic;

    signal Res_n_in      : std_logic;
    signal Res_n_out     : std_logic;
    
begin

    inst_dcm0 : entity work.DCM0 port map(
        CLKIN_IN          => clock49,
        CLKFX_OUT         => clock_avr
    );

    inst_dcm2 : entity work.DCM2 port map(
        CLKIN_IN          => Phi0,
        CLKFX_OUT         => clock_16x,
        LOCKED            => dcm_locked,
        RESET             => dcm_reset
    ); 
    
    core : entity work.MOS6502CpuMonCore
    generic map (
        UseT65Core        => UseT65Core,
        UseAlanDCore      => UseAlanDCore,
        avr_prog_mem_size => 1024 * 8
    )
    port map ( 
        clock_avr    => clock_avr,
        busmon_clk   => clock_16x,
        busmon_clken => busmon_clken,
        cpu_clk      => clock_16x,
        cpu_clken    => cpu_clken,
        IRQ_n        => IRQ_n_sync,
        NMI_n        => NMI_n_sync,
        Sync         => Sync0,
        Addr         => Addr0,
        R_W_n        => R_W_n0,
        Din          => Din,
        Dout         => Dout0,
        SO_n         => SO_n,
        Res_n_in     => Res_n_in,
        Res_n_out    => Res_n_out,
        Rdy          => '1',
        trig         => trig,
        avr_RxD      => avr_RxD,
        avr_TxD      => avr_TxD,
        sw1          => sw1,
        nsw2         => nsw2,
        led3         => led3,
        led6         => led6,
        led8         => led8,
        tmosi        => tmosi,
        tdin         => tdin,
        tcclk        => tcclk
    );

    -- Tristate buffer driving reset back out
    Res_n_in <= Res_n;
    Res_n <= '0' when Res_n_out <= '0' else 'Z';
    
    sync_gen : process(clock_16x)
    begin
        if rising_edge(clock_16x) then
          NMI_n_sync <= NMI_n;
          IRQ_n_sync <= IRQ_n;            
        end if;
    end process;

    Addr  <= Addr1;
    R_W_n <= R_W_n1;
    Sync  <= Sync1;
    Data  <= Dout1 when cpu_dataen = '1' and R_W_n1 = '0' else (others => 'Z');

    -- Din is registered in cpu_clken in BusMonCore
    Din <= Data;

    process(clock_16x)
    begin
        if rising_edge(clock_16x) then
            -- internal clock running 16x Phi0
            clk_div <= clk_div + 1;
            -- clock the CPU on cycle 0
            if (clk_div = "1111") then
                cpu_clken <= '1';
            else
                cpu_clken <= '0';        
            end if;
            -- clock the Busmon out of phase with the cpu
            -- exactly which cycle is not critical
            if (clk_div = "0111") then
                busmon_clken <= '1';
            else
                busmon_clken <= '0';        
            end if;
            -- toggle Phi1/2 on cycles 0 and 8
            if (clk_div = "0000") then
                Phi1 <= '1';
                Phi2 <= '0';
            elsif (clk_div = "1000") then
                Phi1 <= '0';
                Phi2 <= '1';
            end if;
            -- Skew address by one cycle wrt Phi1/2
            -- and hold for a complete cycle
            if (clk_div = "0001") then
                Addr1  <= Addr0;
                R_W_n1 <= R_W_n0;
                Sync1  <= Sync0;
            end if;        
            -- Skew data release by one cycle wrt Phi1/2
            if (clk_div = "1000") then
                cpu_dataen <= '1';
                Dout1  <= Dout0;
            elsif (clk_div = "0001") then
                cpu_dataen <= '0';
                Dout1  <= (others => '1');
            end if;
        end if;
    end process;

    -- This reset the DCM if is seems to have stopped outputting a clock
    process(clock49)
    begin
        if rising_edge(clock49) then
            edge0 <= clk_div(0);
            edge1 <= edge0;
            -- Look for an edge on the clock 
            if (edge0 /= edge1) then
                dcm_count <= (others => '0');
            elsif (dcm_count = "1111001111") then
                dcm_reset <= '0';
            elsif (dcm_count = "1000000000") then
                dcm_reset <= '1';
                dcm_count <= dcm_count + 1;
            else
                dcm_count <= dcm_count + 1;
            end if;            
        end if;
    end process;
    
end behavioral;
    
