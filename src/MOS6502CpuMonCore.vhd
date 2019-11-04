------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : MOS6502CpuMonCore.vhd
-- /___/   /\     Timestamp : 3/11/2019
-- \   \  /  \
--  \___\/\___\
--
--Design Name: MOS6502CpuMonCore
--Device: multiple

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity MOS6502CpuMonCore is
    generic (
       UseT65Core        : boolean;
       UseAlanDCore      : boolean;
       -- default sizing is used by Electron/Beeb Fpga
       num_comparators   : integer := 8;
       avr_prog_mem_size : integer := 1024 * 8
    );
    port (
        clock_avr       : in    std_logic;

        busmon_clk      : in    std_logic;
        busmon_clken    : in    std_logic;
        cpu_clk         : in    std_logic;
        cpu_clken       : in    std_logic;

        -- 6502 Signals
        IRQ_n           : in    std_logic;
        NMI_n           : in    std_logic;
        Sync            : out   std_logic;
        Addr            : out   std_logic_vector(15 downto 0);
        R_W_n           : out   std_logic;
        Din             : in    std_logic_vector(7 downto 0);
        Dout            : out   std_logic_vector(7 downto 0);
        SO_n            : in    std_logic;
        Res_n           : in    std_logic;
        Rdy             : in    std_logic;

        -- External trigger inputs
        trig            : in    std_logic_vector(1 downto 0);

        -- Serial Console
        avr_RxD         : in     std_logic;
        avr_TxD         : out    std_logic;

        -- Switches
        sw_reset_cpu    : in    std_logic;
        sw_reset_avr    : in    std_logic;

        -- LEDs
        led_bkpt        : out   std_logic;
        led_trig0       : out   std_logic;
        led_trig1       : out   std_logic;

        -- OHO_DY1 connected to test connector
        tmosi           : out   std_logic;
        tdin            : out   std_logic;
        tcclk           : out   std_logic
    );
end MOS6502CpuMonCore;

architecture behavioral of MOS6502CpuMonCore is

    type state_type is (idle, nop0, nop1, rd, wr);

    signal state  : state_type;

    signal cpu_clken_ss  : std_logic;
    signal Data          : std_logic_vector(7 downto 0);
    signal Dout_int      : std_logic_vector(7 downto 0);
    signal R_W_n_int     : std_logic;
    signal Rd_n_int      : std_logic;
    signal Wr_n_int      : std_logic;
    signal Sync_int      : std_logic;
    signal Addr_int      : std_logic_vector(23 downto 0);

    signal cpu_addr_us   : unsigned (15 downto 0);
    signal cpu_dout_us   : unsigned (7 downto 0);
    signal cpu_reset_n   : std_logic;

    signal Regs          : std_logic_vector(63 downto 0);
    signal Regs1         : std_logic_vector(255 downto 0);
    signal last_PC       : std_logic_vector(15 downto 0);
    signal SS_Single     : std_logic;
    signal SS_Step       : std_logic;
    signal SS_Step_held  : std_logic;
    signal CountCycle    : std_logic;
    signal special       : std_logic_vector(1 downto 0);

    signal memory_rd     : std_logic;
    signal memory_rd1    : std_logic;
    signal memory_wr     : std_logic;
    signal memory_wr1    : std_logic;
    signal memory_addr   : std_logic_vector(15 downto 0);
    signal memory_dout   : std_logic_vector(7 downto 0);
    signal memory_din    : std_logic_vector(7 downto 0);
    signal memory_done   : std_logic;

    signal NMI_n_masked  : std_logic;
    signal IRQ_n_masked  : std_logic;

begin

    mon : entity work.BusMonCore
    generic map (
        num_comparators   => num_comparators,
        avr_prog_mem_size => avr_prog_mem_size
    )
    port map (
        clock_avr    => clock_avr,
        busmon_clk   => busmon_clk,
        busmon_clken => busmon_clken,
        cpu_clk      => cpu_clk,
        cpu_clken    => cpu_clken,
        Addr         => Addr_int(15 downto 0),
        Data         => Data,
        Rd_n         => Rd_n_int,
        Wr_n         => Wr_n_int,
        RdIO_n       => '1',
        WrIO_n       => '1',
        Sync         => Sync_int,
        Rdy          => open,
        nRSTin       => Res_n,
        nRSTout      => cpu_reset_n,
        CountCycle   => CountCycle,
        trig         => trig,
        avr_RxD      => avr_RxD,
        avr_TxD      => avr_TxD,
        sw_reset_cpu => sw_reset_cpu,
        sw_reset_avr => sw_reset_avr,
        led_bkpt     => led_bkpt,
        led_trig0    => led_trig0,
        led_trig1    => led_trig1,
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
        Special      => special,
        SS_Step      => SS_Step,
        SS_Single    => SS_Single
    );
    Wr_n_int <= R_W_n_int;
    Rd_n_int <= not R_W_n_int;
    Data <= Din when R_W_n_int = '1' else Dout_int;
    NMI_n_masked <= NMI_n or special(1);
    IRQ_n_masked <= IRQ_n or special(0);

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
            if cpu_clken = '1' then
                if state = idle then
                    last_PC <= Regs(63 downto 48);
                end if;
            end if;
        end if;
    end process;

    Regs1( 47 downto  0) <= Regs( 47 downto   0);
    Regs1( 63 downto 48) <= last_PC;
    Regs1(255 downto 64) <= (others => '0');

    cpu_clken_ss <= '1' when Rdy = '1' and (state = idle) and cpu_clken = '1' else '0';

    GenT65Core: if UseT65Core generate
        inst_t65: entity work.T65 port map (
            mode            => "00",
            Abort_n         => '1',
            SO_n            => SO_n,
            Res_n           => cpu_reset_n,
            Enable          => cpu_clken_ss,
            Clk             => cpu_clk,
            Rdy             => '1',
            IRQ_n           => IRQ_n_masked,
            NMI_n           => NMI_n_masked,
            R_W_n           => R_W_n_int,
            Sync            => Sync_int,
            A               => Addr_int,
            DI              => Din,
            DO              => Dout_int,
            Regs            => Regs
        );
    end generate;

    GenAlanDCore: if UseAlanDCore generate
        inst_r65c02: entity work.r65c02 port map (
            reset    => cpu_reset_n,
            clk      => cpu_clk,
            enable   => cpu_clken_ss,
            nmi_n    => NMI_n_masked,
            irq_n    => IRQ_n_masked,
            di       => unsigned(Din),
            do       => cpu_dout_us,
            addr     => cpu_addr_us,
            nwe      => R_W_n_int,
            sync     => Sync_int,
            sync_irq => open,
            Regs     => Regs
        );
        Dout_int <= std_logic_vector(cpu_dout_us);
        Addr_int(15 downto 0) <= std_logic_vector(cpu_addr_us);
    end generate;

    men_access_machine : process(cpu_clk, cpu_reset_n)
    begin
        if cpu_reset_n = '0' then
            state <= idle;
        elsif rising_edge(cpu_clk) then
            -- Extend the control signals from BusMonitorCore which
            -- only last one cycle.
            if SS_Step = '1' then
                SS_Step_held <= '1';
            elsif state = idle then
                SS_Step_held <= '0';
            end if;
            if memory_rd = '1' then
                memory_rd1 <= '1';
            elsif state = rd then
                memory_rd1 <= '0';
            end if;
            if memory_wr = '1' then
                memory_wr1 <= '1';
            elsif state = wr then
                memory_wr1 <= '0';
            end if;
            if cpu_clken = '1' and Rdy = '1' then
                case state is
                    -- idle is when the CPU is running normally
                    when idle =>
                        if Sync_int = '1' and SS_Single = '1' then
                            state <= nop0;
                        end if;
                    -- nop0 is the first state entered when the CPU is paused
                    when nop0 =>
                        if memory_rd1 = '1' then
                            state <= rd;
                        elsif memory_wr1 = '1' then
                            state <= wr;
                        elsif SS_Step_held = '1' then
                            state <= idle;
                        else
                            state <= nop1;
                        end if;
                    -- nop1 simulates a sync cycle
                    when nop1 =>
                        state <= nop0;
                    -- rd is a monitor initiated read cycle
                    when rd =>
                        state <= nop0;
                    -- wr is a monitor initiated write cycle
                    when wr =>
                        state <= nop0;
                end case;
            end if;
        end if;
    end process;

    -- Only count cycles when the 6502 is actually running
    -- TODO: Should this be qualified with cpu_clken and rdy?
    CountCycle <= '1' when state = idle else '0';

    R_W_n <= R_W_n_int when state = idle else
             '0'       when state = wr   else
             '1';

    Addr <= Addr_int(15 downto 0) when state = idle else
            memory_addr when state = rd or state = wr else
            (others => '0');

    Sync <= Sync_int when state = idle else
            '1'      when state = nop1 else
            '0';

    Dout   <= Dout_int when state = idle else
              memory_dout;

    -- Data is captured by the bus monitor on the rising edge of cpu_clk
    -- that sees done = 1.
    memory_done <= '1' when state = rd or state = wr else '0';

    memory_din <= Din;

end behavioral;
