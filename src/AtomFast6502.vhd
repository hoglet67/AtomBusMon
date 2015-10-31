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
end AtomFast6502;

architecture behavioral of AtomFast6502 is
    
    signal Din           : std_logic_vector(7 downto 0);

    -- Signal from the internal core
    signal Dout0          : std_logic_vector(7 downto 0);
    signal Addr0          : std_logic_vector(15 downto 0);
    signal R_W_n0         : std_logic;
    signal Sync0          : std_logic;

    -- Delayed signals for the outside world
    signal Dout1          : std_logic_vector(7 downto 0);
    signal Addr1          : std_logic_vector(15 downto 0);
    signal R_W_n1         : std_logic;
    signal Sync1          : std_logic;
    signal Rdy_int        : std_logic;

    signal cpu_addr_us: unsigned (15 downto 0);
    signal cpu_dout_us: unsigned (7 downto 0);

    signal clock_16x     : std_logic;
    signal cpu_clk       : std_logic;
    signal busmon_clk    : std_logic;
    signal R_W_n_int     : std_logic;

    signal cpu_clken     : std_logic;
    signal cpu_dataen    : std_logic;
    
    signal clk_div       : std_logic_vector(3 downto 0);

    signal Phi1_int      : std_logic;
    signal Phi2_int      : std_logic;
    signal dcm_reset     : std_logic;
    signal dcm_count     : std_logic_vector(9 downto 0);
    signal dcm_locked    : std_logic;
    signal edge0         : std_logic;
    signal edge1         : std_logic;

    
    signal Regs          : std_logic_vector(63 downto 0);
    signal Regs1         : std_logic_vector(255 downto 0);
    signal memory_rd     : std_logic;
    signal memory_wr     : std_logic;
    signal memory_addr   : std_logic_vector(15 downto 0);
    signal memory_dout   : std_logic_vector(7 downto 0);
    signal memory_din    : std_logic_vector(7 downto 0);
    signal memory_done   : std_logic;
    
begin

    mon : entity work.BusMonCore port map (  
        clock49 => clock49,
        Addr    => Addr1,
        Data    => Data,
        Phi2    => busmon_clk,
        Rd_n    => not R_W_n1,
        Wr_n    => R_W_n1,
        RdIO_n  => '1',
        WrIO_n  => '1',
        Sync    => Sync1,
        Rdy     => Rdy_int,
        nRSTin  => Res_n,
        nRSTout => Res_n,
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
    Regs1(63 downto 0) <= Regs;
    Regs1(255 downto 64) <= (others => '0');

    GenT65Core: if UseT65Core generate
        inst_t65: entity work.T65 port map (
            mode            => "00",
            Abort_n         => '1',
            SO_n            => SO_n,
            Res_n           => Res_n,
            Enable          => cpu_clken,
            Clk             => clock_16x,
            Rdy             => Rdy_int,
            IRQ_n           => IRQ_n,
            NMI_n           => NMI_n,
            R_W_n           => R_W_n0,
            Sync            => Sync0,
            A(23 downto 16) => open,
            A(15 downto 0)  => Addr0,
            DI              => Din,
            DO              => Dout0,
            Regs            => Regs
        );
    end generate;
    
    GenAlanDCore: if UseAlanDCore generate
        inst_r65c02: entity work.r65c02 port map (
            reset    => RES_n,
            clk      => clock_16x,
            enable   => cpu_clken,
            nmi_n    => NMI_n,
            irq_n    => IRQ_n,
            di       => unsigned(Din),
            do       => cpu_dout_us,
            addr     => cpu_addr_us,
            nwe      => R_W_n0,
            sync     => Sync0,
            sync_irq => open,
            Regs     => Regs            
        );
        Dout0 <= std_logic_vector(cpu_dout_us);
        Addr0 <= std_logic_vector(cpu_addr_us);
    end generate;


    

    Phi1 <= Phi1_int;
    Phi2 <= Phi2_int;
    busmon_clk <= Phi2_int;
    Din <= Data;

    
    Addr <= memory_addr when (memory_rd = '1' or memory_wr = '1') else Addr1;
    R_W_n <= '1' when memory_rd = '1' else '0' when memory_wr = '1' else R_W_n1;
    Sync <= Sync1;
    
    Data       <= memory_dout when cpu_dataen = '1' and memory_wr = '1' else
                         Dout1 when cpu_dataen = '1' and R_W_n1 = '0' and memory_rd = '0' else
               (others => 'Z');

    memory_done <= memory_rd or memory_wr;



    
    inst_dcm2 : entity work.DCM2 port map(
        CLKIN_IN          => Phi0,
        CLKFX_OUT         => clock_16x,
        LOCKED            => dcm_locked,
        RESET             => dcm_reset
    ); 

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

--    -- for some reason this did not work reliably....
--    process(clock49)
--    begin
--        if rising_edge(clock49) then
--            edge0 <= dcm_locked;
--            edge1 <= edge0;
--            if (dcm_count = "0000000000") then
--                dcm_reset <= '0';
--                if (edge0 = '0' and edge1 = '1') then
--                    dcm_count <= dcm_count + 1;
--                end if;
--            else
--                dcm_reset <= '1';
--                dcm_count <= dcm_count + 1;
--            end if;            
--        end if;
--    end process;
    
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
            -- toggle Phi1/2 on cycles 0 and 8
            if (clk_div = "0000") then
                Phi1_int <= '1';
                Phi2_int <= '0';
                memory_din <= Data;
            elsif (clk_div = "1000") then
                Phi1_int <= '0';
                Phi2_int <= '1';
            end if;
            -- Skew address by one cycles, and hold for a complete cycle
            if (clk_div = "0001") then
                Addr1  <= Addr0;
                R_W_n1 <= R_W_n0;
                Sync1  <= Sync0;
            end if;        
            -- Skew data by one cycle
            if (clk_div = "1000") then
                cpu_dataen <= '1';
                Dout1  <= Dout0;
            elsif (clk_div = "0001") then
                cpu_dataen <= '0';
                Dout1  <= (others => '1');
            end if;
        end if;
    end process;
    
end behavioral;
    
