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
end AtomCpuMon;

architecture behavioral of AtomCpuMon is

    signal clock_avr     : std_logic;
    
    signal Din           : std_logic_vector(7 downto 0);
    signal Dout          : std_logic_vector(7 downto 0);
    signal R_W_n_int     : std_logic;
    signal Sync_int      : std_logic;
    signal hold          : std_logic;
    signal Addr_int      : std_logic_vector(15 downto 0);
    signal IRQ_n_sync    : std_logic;
    signal NMI_n_sync    : std_logic;

    signal cpu_addr_us: unsigned (15 downto 0);
    signal cpu_dout_us: unsigned (7 downto 0);

    signal Phi0_a        : std_logic;
    signal Phi0_b        : std_logic;
    signal Phi0_c        : std_logic;
    signal Phi0_d        : std_logic;
    signal cpu_clk       : std_logic;
    signal busmon_clk    : std_logic;
    
    signal Regs          : std_logic_vector(63 downto 0);
    signal Regs1         : std_logic_vector(255 downto 0);
    signal last_PC       : std_logic_vector(15 downto 0);
    signal SS_Single     : std_logic;
    signal SS_Step       : std_logic;
    signal CountCycle    : std_logic;

    signal memory_rd     : std_logic;
    signal memory_rd1    : std_logic;
    signal memory_wr     : std_logic;
    signal memory_wr1    : std_logic;
    signal memory_addr   : std_logic_vector(15 downto 0);
    signal memory_addr1  : std_logic_vector(15 downto 0);
    signal memory_dout   : std_logic_vector(7 downto 0);
    signal memory_din    : std_logic_vector(7 downto 0);
    signal memory_done   : std_logic;
    
begin

    inst_dcm0 : entity work.DCM0 port map(
        CLKIN_IN          => clock49,
        CLK0_OUT          => clock_avr,
        CLK0_OUT1         => open,
        CLK2X_OUT         => open
    );
    
    mon : entity work.BusMonCore port map (
        clock_avr    => clock_avr,
        busmon_clk   => busmon_clk,
        busmon_clken => '1',
        cpu_clk      => cpu_clk,
        cpu_clken    => '1',
        Addr         => Addr_int,
        Data         => Data,
        Rd_n         => not R_W_n_int,
        Wr_n         => R_W_n_int,
        RdIO_n       => '1',
        WrIO_n       => '1',
        Sync         => Sync_int,
        Rdy          => open,
        nRSTin       => Res_n,
        nRSTout      => Res_n,
        CountCycle   => CountCycle,
        trig         => trig,
        lcd_rs       => open,
        lcd_rw       => open,
        lcd_e        => open,
        lcd_db       => open,
        avr_RxD      => avr_RxD,
        avr_TxD      => avr_TxD,
        sw1          => sw1,
        nsw2         => nsw2,
        led3         => led3,
        led6         => led6,
        led8         => led8,
        tmosi        => tmosi,
        tdin         => tdin,
        tcclk        => tcclk,
        Regs         => Regs1,
        RdMemOut     => memory_rd,
        WrMemOut     => memory_wr,
        RdIOOut      => open,
        WrIOOut      => open,
        AddrOut      => memory_addr,
        DataOut      => memory_dout,
        DataIn       => memory_din,
        Done         => memory_done,
        SS_Step      => SS_Step,
        SS_Single    => SS_Single
    );

    -- The CPU is slightly pipelined and the register update of the last
    -- instruction overlaps with the opcode fetch of the next instruction.
    --
    -- If the single stepping stopped on the opcode fetch cycle, then the registers
    -- valued would not accurately reflect the previous instruction.
    --
    -- To work around this, when single stepping, we stop on the cycle after
    -- the opcode fetch, which means the program counter has advanced.
    --
    -- To hide this from the user single stepping, all we need to do is to
    -- also pipeline the value of the program counter by one stage to compensate.
    
    last_pc_gen : process(cpu_clk)
    begin
        if rising_edge(cpu_clk) then
            if (hold = '0') then
                last_PC <= Regs(63 downto 48);
            end if;
        end if;
    end process;
    
    Regs1( 47 downto  0) <= Regs( 47 downto   0);
    Regs1( 63 downto 48) <= last_PC;
    Regs1(255 downto 64) <= (others => '0');

    GenT65Core: if UseT65Core generate
        inst_t65: entity work.T65 port map (
            mode            => "00",
            Abort_n         => '1',
            SO_n            => SO_n,
            Res_n           => Res_n,
            Enable          => not hold,
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
    end generate;    
    
    GenAlanDCore: if UseAlanDCore generate
        inst_r65c02: entity work.r65c02 port map (
            reset    => RES_n,
            clk      => cpu_clk,
            enable   => not hold,
            nmi_n    => NMI_n_sync,
            irq_n    => IRQ_n_sync,
            di       => unsigned(Din),
            do       => cpu_dout_us,
            addr     => cpu_addr_us,
            nwe      => R_W_n_int,
            sync     => Sync_int,
            sync_irq => open,
            Regs     => Regs            
        );
        Dout <= std_logic_vector(cpu_dout_us);
        Addr_int <= std_logic_vector(cpu_addr_us);
    end generate;

    sync_gen : process(cpu_clk)
    begin
        if rising_edge(cpu_clk) then
          NMI_n_sync <= NMI_n;
          IRQ_n_sync <= IRQ_n;            
        end if;
    end process;

    -- This block generates a hold signal that acts as the inverse of a clock enable
    -- for the CPU. See comments above for why this is a cycle delayed a cycle.
    hold_gen : process(cpu_clk)
    begin
        if rising_edge(cpu_clk) then
            if (Sync_int = '1') then
                -- stop after the opcode has been fetched
                hold <= SS_Single;
            elsif (SS_Step = '1') then
                -- start again when the single step command is issues
                hold <= '0';
            end if;
        end if;
    end process;
    
    -- Only count cycles when the 6809 is actually running
    CountCycle <= not hold;

    -- this block delays memory_rd, memory_wr, memory_addr until the start of the next cpu clk cycle
    -- necessary because the cpu mon block is clocked of the opposite edge of the clock
    -- this allows a full cpu clk cycle for cpu mon reads and writes
    mem_gen : process(cpu_clk)
    begin
        if rising_edge(cpu_clk) then
            memory_rd1   <= memory_rd;
            memory_wr1   <= memory_wr;
            memory_addr1 <= memory_addr;
        end if;
    end process;
    
    R_W_n <= '1' when memory_rd1 = '1' else '0' when memory_wr1 = '1' else R_W_n_int;
    Addr <= memory_addr1 when (memory_rd1 = '1' or memory_wr1 = '1') else Addr_int;
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
    
    Data       <= memory_dout when Phi0_c = '1' and memory_wr1 = '1' else
                         Dout when Phi0_c = '1' and R_W_n_int = '0' and memory_rd1 = '0' else
               (others => 'Z');

    memory_done <= memory_rd1 or memory_wr1;
    
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
    
