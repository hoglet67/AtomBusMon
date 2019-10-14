--------------------------------------------------------------------------------
-- Copyright (c) 2019 David Banks
--
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/
--  \   \
--  /   /         Filename  : Z80CpuMon.vhd
-- /___/   /\     Timestamp : 14/10/2018
-- \   \  /  \
--  \___\/\___\
--
--Design Name: Z80CpuMon
--Device: multiple

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Z80CpuMon is
    generic (
       UseT80Core     : boolean := true;
       LEDsActiveHigh : boolean := false;    -- default value correct for GODIL
       SW1ActiveHigh  : boolean := true;     -- default value correct for GODIL
       SW2ActiveHigh  : boolean := false;    -- default value correct for GODIL
       ClkMult        : integer := 10;       -- default value correct for GODIL
       ClkDiv         : integer := 31;       -- default value correct for GODIL
       ClkPer         : real    := 20.345    -- default value correct for GODIL
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
        DOE_n           : out   std_logic;

        -- External trigger inputs
        trig            : in    std_logic_vector(1 downto 0);

        -- Serial Console
        avr_RxD         : in    std_logic;
        avr_TxD         : out   std_logic;

        -- GODIL Switches
        sw1             : in    std_logic;
        sw2             : in    std_logic;

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

type state_type is (idle, nop_t1, nop_t2, nop_t3, nop_t4, rd_t1, rd_wa, rd_t2, rd_t3, wr_t1, wr_wa, wr_t2, wr_t3);

    signal state  : state_type;

    signal clock_avr      : std_logic;

    signal RESET_n_int    : std_logic;
    signal cpu_clk        : std_logic;
    signal busmon_clk     : std_logic;

    signal Addr_int       : std_logic_vector(15 downto 0);
    signal RD_n_int       : std_logic;
    signal WR_n_int       : std_logic;
    signal MREQ_n_int     : std_logic;
    signal IORQ_n_int     : std_logic;
    signal M1_n_int       : std_logic;
    signal WAIT_n_int     : std_logic;
    signal TState         : std_logic_vector(2 downto 0);
    signal SS_Single      : std_logic;
    signal SS_Step        : std_logic;
    signal SS_Step_held   : std_logic;
    signal SS_Running     : std_logic;
    signal CountCycle     : std_logic;
    signal skipNextOpcode : std_logic;

    signal Regs           : std_logic_vector(255 downto 0);
    signal io_not_mem     : std_logic;
    signal io_rd          : std_logic;
    signal io_wr          : std_logic;
    signal memory_rd      : std_logic;
    signal memory_wr      : std_logic;
    signal memory_addr    : std_logic_vector(15 downto 0);
    signal memory_dout    : std_logic_vector(7 downto 0);
    signal memory_din     : std_logic_vector(7 downto 0);
    signal memory_done    : std_logic;

    signal io_rd1         : std_logic;
    signal io_wr1         : std_logic;
    signal memory_rd1     : std_logic;
    signal memory_wr1     : std_logic;
    signal mon_mreq_n     : std_logic;
    signal mon_iorq_n     : std_logic;
    signal mon_rd_n       : std_logic;
    signal mon_wr_n       : std_logic;
    signal mon_wait_n     : std_logic;

    signal INT_n_sync     : std_logic;
    signal NMI_n_sync     : std_logic;

    signal Rdy            : std_logic;
    signal Read_n         : std_logic;
    signal Read_n0        : std_logic;
    signal Read_n1        : std_logic;
    signal Write_n        : std_logic;
    signal Write_n0       : std_logic;
    signal ReadIO_n       : std_logic;
    signal ReadIO_n0      : std_logic;
    signal ReadIO_n1      : std_logic;
    signal WriteIO_n      : std_logic;
    signal WriteIO_n0     : std_logic;
    signal Sync           : std_logic;
    signal Sync0          : std_logic;
    signal Mem_IO_n       : std_logic;
    signal nRST           : std_logic;

    signal MemState       : std_logic_vector(2 downto 0);

    signal Din            : std_logic_vector(7 downto 0);
    signal Dout           : std_logic_vector(7 downto 0);
    signal Den            : std_logic;
    signal ex_data        : std_logic_vector(7 downto 0);
    signal rd_data        : std_logic_vector(7 downto 0);
    signal mon_data       : std_logic_vector(7 downto 0);

    signal led3_n         : std_logic;  -- led to indicate ext trig 0 is active
    signal led6_n         : std_logic;  -- led to indicate ext trig 1 is active
    signal led8_n         : std_logic;  -- led to indicate CPU has hit a breakpoint (and is stopped)
    signal sw_interrupt_n : std_logic;  -- switch to pause the CPU
    signal sw_reset_n     : std_logic;  -- switch to reset the CPU

    signal avr_TxD_int    : std_logic;

    signal clock_49_ctr   : std_logic_vector(23 downto 0);
    signal clock_avr_ctr  : std_logic_vector(23 downto 0);

    signal rfsh_addr      : std_logic_vector(15 downto 0);

begin

    -- Generics allows polarity of switches/LEDs to be tweaked from the project file
    sw_interrupt_n <= not sw1 when SW1ActiveHigh else sw1;
    sw_reset_n     <= not sw2 when SW2ActiveHigh else sw2;
    led3           <= not led3_n when LEDsActiveHigh else led3_n;
    led6           <= not led6_n when LEDsActiveHigh else led6_n;
    led8           <= not led8_n when LEDsActiveHigh else led8_n;

    --------------------------------------------------------
    -- Clocking
    --------------------------------------------------------

    inst_dcm0 : entity work.DCM0
      generic map (
        ClkMult      => ClkMult,
        ClkDiv       => ClkDiv,
        ClkPer       => ClkPer
      )
      port map(
        CLKIN_IN     => clock49,
        CLKFX_OUT    => clock_avr
      );

    cpu_clk <= CLK_n;
    busmon_clk <= CLK_n;

    --------------------------------------------------------
    -- BusMonCore
    --------------------------------------------------------

    mon : entity work.BusMonCore
      generic map (
        num_comparators => 4,
        avr_prog_mem_size => 1024 * 9
      )
      port map (
        clock_avr    => clock_avr,
        busmon_clk   => busmon_clk,
        busmon_clken => '1',
        cpu_clk      => cpu_clk,
        cpu_clken    => '1',
        Addr         => Addr_int,
        Data         => mon_data,
        Rd_n         => Read_n,
        Wr_n         => Write_n,
        RdIO_n       => ReadIO_n,
        WrIO_n       => WriteIO_n,
        Sync         => Sync,
        Rdy          => Rdy,
        nRSTin       => RESET_n_int,
        nRSTout      => nRST,
        CountCycle   => CountCycle,
        trig         => trig,
        lcd_rs       => open,
        lcd_rw       => open,
        lcd_e        => open,
        lcd_db       => open,
        avr_RxD      => avr_RxD,
        avr_TxD      => avr_TxD_int,
        sw1          => '0',
        nsw2         => sw_reset_n,
        led3         => led3_n,
        led6         => led6_n,
        led8         => led8_n,
        tmosi        => tmosi,
        tdin         => tdin,
        tcclk        => tcclk,
        Regs         => Regs,
        RdMemOut     => memory_rd,
        WrMemOut     => memory_wr,
        RdIOOut      => io_rd,
        WrIOOut      => io_wr,
        AddrOut      => memory_addr,
        DataOut      => memory_dout,
        DataIn       => memory_din,
        Done         => memory_done,
        SS_Single    => SS_Single,
        SS_Step      => SS_Step
    );

    --------------------------------------------------------
    -- T80
    --------------------------------------------------------

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
            Din     => Din,
            Dout    => Dout,
            DEn     => Den
        );
    end generate;

    --------------------------------------------------------
    -- Z80 specific single step / breakpoint logic
    --------------------------------------------------------

    WAIT_n_int <= WAIT_n and SS_Running;

    CountCycle <= '1' when SS_Single = '0' or SS_Running = '1' else '0';

    sync_gen : process(CLK_n, RESET_n_int)
    begin
        if RESET_n_int = '0' then
            NMI_n_sync <= '1';
            INT_n_sync <= '1';
            SS_Running <= '1';
            SS_Step_held <= '0';
        elsif rising_edge(CLK_n) then
            NMI_n_sync <= NMI_n;
            INT_n_sync <= INT_n;
            if Sync0 = '1' and SS_Single = '1' then
                -- stop at the end of T1 instruction fetch
                SS_Running <= '0';
            elsif SS_Step_held = '1' and state = nop_t4 then
                -- start again when the single step command is issued
                SS_Running <= '1';
            end if;
            if SS_Step = '1' then
                SS_Step_held <= '1';
            elsif SS_Running = '1' then
                SS_Step_held <= '0';
            end if;
        end if;
    end process;

    -- Logic to ignore the second M1 in multi-byte opcodes
    skip_opcode_latch : process(CLK_n)
    begin
        if rising_edge(CLK_n) then
            if (M1_n_int = '0' and WAIT_n_int = '1' and TState = "010") then
                if (skipNextOpcode = '0' and (Data = x"CB" or Data = x"DD" or Data = x"ED" or Data = x"FD")) then
                    skipNextOpcode <= '1';
                else
                    skipNextOpcode <= '0';
                end if;
            end if;
        end if;
    end process;

    -- For instruction breakpoints, we make the monitoring decision as early as possibe
    -- to allow time to stop the current instruction, which is possible because we don't
    -- really care about the data (it's re-read from memory by the disassembler).
    Sync0    <= '1' when M1_n_int = '0' and TState = "001" and skipNextOpcode = '0' else '0';

    -- For memory reads/write breakpoints we make the monitoring decision in the middle of T2
    -- but only if WAIT_n is '1' so we catch the right data.
    Read_n0  <= not (WAIT_n_int and (not RD_n_int) and (not MREQ_n_int) and     (M1_n_int)) when TState = "010" else '1';
    Write_n0 <= not (WAIT_n_int and (not WR_n_int) and (not MREQ_n_int) and     (M1_n_int)) when TState = "010" else '1';

    ReadIO_n0  <= not (WAIT_n_int and (not RD_n_int) and (not IORQ_n_int) and     (M1_n_int)) when TState = "010" else '1';
    WriteIO_n0 <= not (               (    RD_n_int) and (not IORQ_n_int) and     (M1_n_int)) when TState = "011" else '1';

    -- Hold the monitoring decision so it is valid on the rising edge of the clock
    -- For instruction fetches and writes, the monitor sees these at the start of T3
    -- For reads, the data can arrive in the middle of T3 so delay until end of T3
    watch_gen : process(CLK_n)
    begin
        if falling_edge(CLK_n) then
            Sync     <= Sync0;
            Read_n1  <= Read_n0;
            Read_n   <= Read_n1;
            Write_n  <= Write_n0;
            ReadIO_n1  <= ReadIO_n0;
            ReadIO_n   <= ReadIO_n1;
            WriteIO_n  <= WriteIO_n0;
        end if;
    end process;

    -- Register the exec/write data on the rising at the end of T2
    ex_data_latch : process(CLK_n)
    begin
        if rising_edge(CLK_n) then
            if (Sync = '1' or Write_n = '0' or WriteIO_n = '0') then
                ex_data <= Data;
            end if;
        end if;
    end process;

    -- Register the read data on the falling edge of clock in the middle of T3
    rd_data_latch : process(CLK_n)
    begin
        if falling_edge(CLK_n) then
            if (Read_n1 = '0' or ReadIO_n1 = '0') then
                rd_data <= Data;
            end if;
            memory_din <= Data;
        end if;
    end process;

    -- Mux the data seen by the bus monitor appropriately
    mon_data <= rd_data when Read_n <= '0' or ReadIO_n = '0' else ex_data;

    -- Mark the memory access as done when t3 is reached
    memory_done <= '1' when state = rd_t3 or state = wr_t3 else '0';

    -- Multiplex the bus control signals
    -- The _int versions come from the T80
    -- The mon_ versions come from the state machine below

    -- TODO: Also need to take account of BUSRQ_n/BUSAK_n

    MREQ_n <= MREQ_n_int  when state = idle else mon_mreq_n;
    IORQ_n <= IORQ_n_int  when state = idle else mon_iorq_n;
    WR_n   <= WR_n_int    when state = idle else mon_wr_n;
    RD_n   <= RD_n_int    when state = idle else mon_rd_n;
    M1_n   <= M1_n_int    when state = idle else '1';

    Addr   <= Addr_int    when state = idle else
              x"0000"     when state = nop_t1 or state = nop_t2 else
              rfsh_addr   when state = nop_t3 or state = nop_t4 else
              memory_addr;

    Data   <= memory_dout when state = wr_wa or state = wr_t2 or state = wr_t3 else
                     Dout when state = idle and Den = '1' else
              (others => 'Z');

    DOE_n  <= '0' when state = wr_wa or state = wr_t2 or state = wr_t3 else
              '0' when state = idle and Den = '1' else
              '1';

    Din    <= Data;

    men_access_machine_rising : process(CLK_n, RESET_n)
    begin
        if (RESET_n = '0') then
            state <= idle;
            memory_rd1 <= '0';
            memory_wr1 <= '0';
            io_rd1 <= '0';
            io_wr1 <= '0';

        elsif rising_edge(CLK_n) then

            -- Extend the 1-cycle long request strobes from BusMonCore
            -- until we are ready to generate a bus cycle
            if memory_rd = '1' then
                memory_rd1 <= '1';
            elsif state = rd_t1 then
                memory_rd1 <= '0';
            end if;
            if memory_wr = '1' then
                memory_wr1 <= '1';
            elsif state = wr_t1 then
                memory_wr1 <= '0';
            end if;
            if io_rd = '1' then
                io_rd1 <= '1';
            elsif state = rd_t1 then
                io_rd1 <= '0';
            end if;
            if io_wr = '1' then
                io_wr1 <= '1';
            elsif state = wr_t1 then
                io_wr1 <= '0';
            end if;

            -- Main state machine, generating refresh, read and write cycles
            -- (the timing should exactly match those of the Z80)
            case state is
                -- Idle is when T80 is running
                when idle =>
                    if SS_Running = '0' then
                        -- If the T80 is stopped, start genering refresh cycles
                        state <= nop_t1;
                        -- Load the initial refresh address from I/R in the T80
                        rfsh_addr <= Regs(199 downto 192) & Regs(207 downto 200);
                    end if;

                -- Refresh cycle
                when nop_t1 =>
                    state <= nop_t2;
                    -- Increment the refresh address (7 bits, just like the Z80)
                    rfsh_addr(6 downto 0) <= rfsh_addr(6 downto 0) + 1;
                when nop_t2 =>
                    state <= nop_t3;
                when nop_t3 =>
                    state <= nop_t4;
                when nop_t4 =>
                    if memory_wr1 = '1' or io_wr1 = '1' then
                        state <= wr_t1;
                        io_not_mem <= io_wr1;
                    elsif memory_rd1 = '1' or io_rd1 = '1' then
                        state <= rd_t1;
                        io_not_mem <= io_rd1;
                    elsif SS_Step_held = '1' or SS_Single = '0' then
                        state <= idle;
                    else
                        state <= nop_t1;
                    end if;

                -- Read cycle
                when rd_t1 =>
                    if io_not_mem = '1' then
                        state <= rd_wa;
                    else
                        state <= rd_t2;
                    end if;
                when rd_wa =>
                    state <= rd_t2;
                when rd_t2 =>
                    if mon_wait_n = '1' then
                        state <= rd_t3;
                    end if;
                when rd_t3 =>
                    state <= nop_t1;

                -- Write cycle
                when wr_t1 =>
                    if io_not_mem = '1' then
                        state <= wr_wa;
                    else
                        state <= wr_t2;
                    end if;
                when wr_wa =>
                    state <= wr_t2;
                when wr_t2 =>
                    if mon_wait_n = '1' then
                        state <= wr_t3;
                    end if;
                when wr_t3 =>
                    state <= nop_t1;
            end case;
        end if;
    end process;

    men_access_machine_falling : process(RESET_n)
    begin
        if falling_edge(CLK_n) then
            -- For memory access cycles, mreq/iorq/rd/wr all change in the middle of
            -- the t state, so retime these on the falling edge of clock
            if state = rd_t1 or state = rd_wa or state = rd_t2 or state = wr_t1 or state = wr_wa or state = wr_t2 then
                if io_not_mem = '0' then
                    -- Memory cycle
                    mon_mreq_n <= '0';
                    mon_iorq_n <= '1';
                else
                    -- IO cycle
                    mon_mreq_n <= '1';
                    mon_iorq_n <= '0';
                end if;
            elsif state = nop_t3 then
                -- Refresh cycle
                mon_mreq_n <= '0';
                mon_iorq_n <= '1';
            else
                -- Idle cycle
                mon_mreq_n <= '1';
                mon_iorq_n <= '1';
            end if;
            -- Read strobe
            if state = rd_t1 or state = rd_wa or state = rd_t2 then
                mon_rd_n <= '0';
            else
                mon_rd_n <= '1';
            end if;
            -- Write strobe
            if state = wr_wa or state = wr_t2 then
                mon_wr_n <= '0';
            else
                mon_wr_n <= '1';
            end if;
            -- Sample wait on the falling edge of the clock
            mon_wait_n <= WAIT_n;
        end if;
    end process;


    RESET_n_int <= RESET_n and sw_interrupt_n and nRST;

    avr_TxD <= avr_Txd_int;

    test1 <= sw_interrupt_n and sw_reset_n;

    process(clock_avr)
    begin
        if rising_edge(clock_avr) then
            clock_avr_ctr <= clock_avr_ctr + 1;
            test2 <= sw_interrupt_n or clock_avr_ctr(23);
        end if;
    end process;

    process(clock49)
    begin
        if rising_edge(clock49) then
            clock_49_ctr <= clock_49_ctr + 1;
            test3 <= sw_reset_n or clock_49_ctr(23);
        end if;
    end process;

    test4 <= not avr_TxD_int;

    --test1 <= TState(0);
    --test2 <= TState(1);
    --test3 <= TState(2);
    --test4 <= CLK_n;


end behavioral;
