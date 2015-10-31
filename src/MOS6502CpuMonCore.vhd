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

entity MOS6502CpuMonCore is
    generic (
       UseT65Core    : boolean;
       UseAlanDCore  : boolean
       );
    port (
        clock_avr        : in    std_logic;

        busmon_clk       : in    std_logic;
        busmon_clken     : in    std_logic;
        cpu_clk          : in    std_logic;
        cpu_clken        : in    std_logic;
        
        -- 6502 Signals
        IRQ_n           : in    std_logic;
        NMI_n           : in    std_logic;
        Sync            : out   std_logic;                
        Addr            : out   std_logic_vector(15 downto 0);
        R_W_n           : out   std_logic;
        Din             : in    std_logic_vector(7 downto 0);
        Dout            : out   std_logic_vector(7 downto 0);
        SO_n            : in    std_logic;
        Res_n_in        : in    std_logic;
        Res_n_out       : out   std_logic;
        Rdy             : in    std_logic;

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
end MOS6502CpuMonCore;

architecture behavioral of MOS6502CpuMonCore is

    signal cpu_clken_ss  : std_logic;
    signal Data          : std_logic_vector(7 downto 0);
    signal Dout_int      : std_logic_vector(7 downto 0);
    signal R_W_n_int     : std_logic;
    signal Sync_int      : std_logic;
    signal hold          : std_logic;
    signal Addr_int      : std_logic_vector(15 downto 0);
    signal IRQ_n_sync    : std_logic;
    signal NMI_n_sync    : std_logic;

    signal cpu_addr_us: unsigned (15 downto 0);
    signal cpu_dout_us: unsigned (7 downto 0);

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
    
    mon : entity work.BusMonCore port map (
        clock_avr    => clock_avr,
        busmon_clk   => busmon_clk,
        busmon_clken => busmon_clken,
        cpu_clk      => cpu_clk,
        cpu_clken    => cpu_clken,
        Addr         => Addr_int,
        Data         => Data,
        Rd_n         => not R_W_n_int,
        Wr_n         => R_W_n_int,
        RdIO_n       => '1',
        WrIO_n       => '1',
        Sync         => Sync_int,
        Rdy          => open,
        nRSTin       => Res_n_in,
        nRSTout      => Res_n_out,
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
    Data <= Din when R_W_n_int = '1' else Dout_int;

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
            if (cpu_clken = '1') then
                if (hold = '0') then
                    last_PC <= Regs(63 downto 48);
                end if;
            end if;
        end if;
    end process;
    
    Regs1( 47 downto  0) <= Regs( 47 downto   0);
    Regs1( 63 downto 48) <= last_PC;
    Regs1(255 downto 64) <= (others => '0');

    cpu_clken_ss <= (not hold) and cpu_clken;

    GenT65Core: if UseT65Core generate
        inst_t65: entity work.T65 port map (
            mode            => "00",
            Abort_n         => '1',
            SO_n            => SO_n,
            Res_n           => Res_n_in,
            Enable          => cpu_clken_ss,
            Clk             => cpu_clk,
            Rdy             => '1',
            IRQ_n           => IRQ_n,
            NMI_n           => NMI_n,
            R_W_n           => R_W_n_int,
            Sync            => Sync_int,
            A(23 downto 16) => open,
            A(15 downto 0)  => Addr_int,
            DI              => Din,
            DO              => Dout_int,
            Regs            => Regs
        );
    end generate;    
    
    GenAlanDCore: if UseAlanDCore generate
        inst_r65c02: entity work.r65c02 port map (
            reset    => Res_n_in,
            clk      => cpu_clk,
            enable   => cpu_clken_ss,
            nmi_n    => NMI_n,
            irq_n    => IRQ_n,
            di       => unsigned(Din),
            do       => cpu_dout_us,
            addr     => cpu_addr_us,
            nwe      => R_W_n_int,
            sync     => Sync_int,
            sync_irq => open,
            Regs     => Regs            
        );
        Dout_int <= std_logic_vector(cpu_dout_us);
        Addr_int <= std_logic_vector(cpu_addr_us);
    end generate;


    -- This block generates a hold signal that acts as the inverse of a clock enable
    -- for the CPU. See comments above for why this is a cycle delayed a cycle.
    hold_gen : process(cpu_clk)
    begin
        if rising_edge(cpu_clk) then
            if (cpu_clken = '1') then
                if (Sync_int = '1') then
                    -- stop after the opcode has been fetched
                    hold <= SS_Single;
                elsif (SS_Step = '1') then
                    -- start again when the single step command is issues
                    hold <= '0';
                end if;
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
            if (cpu_clken = '1') then
                memory_rd1   <= memory_rd;
                memory_wr1   <= memory_wr;
                memory_addr1 <= memory_addr;
            end if;
        end if;
    end process;
    
    R_W_n <= '1' when memory_rd1 = '1' else '0' when memory_wr1 = '1' else R_W_n_int;
    Addr <= memory_addr1 when (memory_rd1 = '1' or memory_wr1 = '1') else Addr_int;
    Sync <= Sync_int;
    
    Dout   <= memory_dout when memory_wr1 = '1' else Dout_int;
  
    memory_done <= memory_rd1 or memory_wr1;

    memory_din <= Din;
 
end behavioral;
    
