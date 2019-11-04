#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <avr/pgmspace.h>

#include "AtomBusMon.h"

/********************************************************
 * VERSION and NAME are used in the start-up message
 ********************************************************/

#define VERSION "0.90"

#if defined(CPU_Z80)
  #define NAME "ICE-Z80"
#elif defined(CPU_6502)
  #define NAME "ICE-6502"
#elif defined(CPU_65C02)
  #define NAME "ICE-65C02"
#elif defined(CPU_6809)
  #define NAME "ICE-6809"
#else
  #error "Unsupported CPU type"
#endif

/********************************************************
 * User Command Definitions
 ********************************************************/

#define NUM_CMDS (sizeof(cmdStrings) / sizeof (char *))

// The command process accepts abbreviated forms, for example
// if h is entered, then help will match.

// Must be kept in step with cmdFuncs (just below)
char *cmdStrings[] = {
  "help",
  "continue",
  "next",
  "step",
  "regs",
  "dis",
  "fill",
  "crc",
  "mem",
  "rdm",
  "wrm",
#if defined(CPU_Z80)
  "io",
  "rdi",
  "wri",
#endif
  "test",
  "srec",
  "special",
  "reset",
  "trace",
  "blist",
  "breakx",
  "watchx",
  "breakrm",
  "watchrm",
  "breakwm",
  "watchwm",
#if defined(CPU_Z80)
  "breakri",
  "watchri",
  "breakwi",
  "watchwi",
#endif
  "clear",
  "trigger"
};

// Must be kept in step with cmdStrings (just above)
void (*cmdFuncs[])(char *params) = {
  doCmdHelp,
  doCmdContinue,
  doCmdNext,
  doCmdStep,
  doCmdRegs,
  doCmdDis,
  doCmdFill,
  doCmdCrc,
  doCmdMem,
  doCmdReadMem,
  doCmdWriteMem,
#if defined(CPU_Z80)
  doCmdIO,
  doCmdReadIO,
  doCmdWriteIO,
#endif
  doCmdTest,
  doCmdSRec,
  doCmdSpecial,
  doCmdReset,
  doCmdTrace,
  doCmdList,
  doCmdBreakI,
  doCmdWatchI,
  doCmdBreakRdMem,
  doCmdWatchRdMem,
  doCmdBreakWrMem,
  doCmdWatchWrMem,
#if defined(CPU_Z80)
  doCmdBreakRdIO,
  doCmdWatchRdIO,
  doCmdBreakWrIO,
  doCmdWatchWrIO,
#endif
  doCmdClear,
  doCmdTrigger
};

/********************************************************
 * AVR Control Register Definitions
 ********************************************************/

// The control register allows commands to be sent to the AVR
#define CTRL_PORT         PORTB
#define CTRL_DDR          DDRB
#define CTRL_DIN          PINB

// A 0->1 transition on bit 5 actually sends a command
#define CMD_EDGE          0x20

// Commands are placed on bits 4..0
#define CMD_MASK          0x1F

// Bits 7..6 are the special function output bits
// On the 6502, these are used to mask IRQ and NMI
#define SPECIAL_0            6
#define SPECIAL_1            7
#define SPECIAL_MASK      ((1<<SPECIAL_0) | (1<<SPECIAL_1))

// Hardware Commands:
//
// 0000x Enable/Disable single strpping
// 0001x Enable/Disable breakpoints / watches
// 0010x Load breakpoint / watch register
// 0011x Reset CPU
// 01000 Singe Step CPU
// 01001 Read FIFO
// 01010 Reset FIFO
// 01011 Unused
// 0110x Load address/data register
// 0111x Unused
// 10000 Read Memory
// 10001 Read Memory and Auto Inc Address
// 10010 Write Memory
// 10011 Write Memory and Auto Inc Address
// 10000 Read Memory
// 10001 Read Memory and Auto Inc Address
// 10010 Write Memory
// 10011 Write Memory and Auto Inc Address
// 1x1xx Unused
// 11xxx Unused

#define CMD_SINGLE_ENABLE 0x00
#define CMD_BRKPT_ENABLE  0x02
#define CMD_LOAD_BRKPT    0x04
#define CMD_RESET         0x06
#define CMD_STEP          0x08
#define CMD_WATCH_READ    0x09
#define CMD_FIFO_RST      0x0A
#define CMD_LOAD_MEM      0x0C
#define CMD_RD_MEM        0x10
#define CMD_RD_MEM_INC    0x11
#define CMD_WR_MEM        0x12
#define CMD_WR_MEM_INC    0x13
#define CMD_RD_IO         0x14
#define CMD_RD_IO_INC     0x15
#define CMD_WR_IO         0x16
#define CMD_WR_IO_INC     0x17

/********************************************************
 * AVR Status Register Definitions
 ********************************************************/

// The status register shares the same port as the mux select register
// Bits 5..0 are the mux select bits (outputs)
// Bits 7..6 are the status bist (inputs)

#define STATUS_PORT       PORTD
#define STATUS_DDR        DDRD
#define STATUS_DIN        PIND

// This bit changing indicates the command has been completed
#define CMD_ACK_MASK      0x40

// This bit indicates the hardware FIFO contains data
// which will be either a watch or a breakpoint event
#define BW_ACTIVE_MASK    0x80

/********************************************************
 * AVR MUX Select Register Definitions
 ********************************************************/

// The mux select register shares the same port as the status register
// This register controls what data is visible through the mux data register
// Bits 5..0 are the mux select bits (outputs)
// Bits 7..6 are the status bist (inputs)

#define MUXSEL_PORT       PORTD
#define MUXSEL_MASK       0x3F
#define MUXSEL_BIT        0

// Additional hardware registers defined below are accessed by writing the offset
// to the MUX Select register, waiting a couple of microseconds, then reading
// the MUX Data register

// Offsets 0-15 are defined below
// Offsets 16-31 are used to return the processor registers

// Instruction Address register: address of the last executed instruction
#define OFFSET_IAL        0
#define OFFSET_IAH        1

// Data register: Memory and IO read/write commands return data via this register
#define OFFSET_DATA       2

// Cycle count register: a 24 bit register that runs while the CPU is running
// this gives visibility of how long (in cycles) each instruction takes
#define OFFSET_CNTH       3
#define OFFSET_CNTL       4
#define OFFSET_CNTM       5

// Watch/Breakpoint Event FIFO
//
// Watch and breakpoint events are queued in a 512 (deep) x 72 (wide) FIFO
//
// Status register BW_ACTIVE indicates the FIFO is non empty.  There is currently
// no indication if events are lost due overflow.
//
// The CMD_WATCH_READ command reads the next word from this FIFO.
//
// The following 9 register provide read access to the word at the head of the
// FIFO, i.e. the FIFO is write-through:

// Instruction address of the watch/breakpoint
#define OFFSET_BW_IAL     6
#define OFFSET_BW_IAH     7

// IO or Memory Read/write address of the watch/breakpoint
#define OFFSET_BW_BAL     8
#define OFFSET_BW_BAH     9

// IO or Memory Read/write data of the watch/breakpoint
#define OFFSET_BW_BD      10

// Type of event, see the watch/breakpoint modes below
// Only bits 0-3 are currently used
#define OFFSET_BW_M       11

// Cycle count at the start of the instruction that caused the event
#define OFFSET_BW_CNTL    12
#define OFFSET_BW_CNTM    13
#define OFFSET_BW_CNTH    14

// Offset 15 is currently unused

/********************************************************
 * AVR MUX Data Register Definitions
 ********************************************************/

// The mux data register is used for reading back the 8-bit register
// addressed by the mux select register.

// This port is input only
#define MUX_PORT          PORTE
#define MUX_DDR           DDRE
#define MUX_DIN           PINE

/********************************************************
 * Watch/Breakpoint Definitions
 ********************************************************/

#define MAXBKPTS 8

// The current number of watches/breakpoints
int numbkpts = 0;

// Watches/Breakpoints are loaded into a massive shift register by the
// continue command. The following variables in the AVR track what the
// user has requested. These are updated by the watch/break/clear/trigger
// commands.

// Each watch/breakpoint is defined with 46 bits in the shift register
// MS Bit ............................................ LS Bit
// <Trigger:4> <Mode:10> <Address Mask:16> <Address Value:16>

// A 16 bit breakpoint address
unsigned int breakpoints[MAXBKPTS];

// A 16 bit breakpoint address mask
unsigned int       masks[MAXBKPTS];

// The type (aka mode) of breakpoint (a 10 bit values), allowing
// multiple types to be defined. The bits correspond to the mode
// definitions below.
unsigned int       modes[MAXBKPTS];

// The number of different watch/breakpoint modes
#define NUM_MODES   11

// The following watch/breakpoint modes are defined
#define BRKPT_MEM_READ  0
#define WATCH_MEM_READ  1
#define BRKPT_MEM_WRITE 2
#define WATCH_MEM_WRITE 3
#define BRKPT_IO_READ   4
#define WATCH_IO_READ   5
#define BRKPT_IO_WRITE  6
#define WATCH_IO_WRITE  7
#define BRKPT_EXEC      8
#define WATCH_EXEC      9
#define TRANSIENT      10

// Breakpoint Mode Strings, should match the modes above
char *modeStrings[NUM_MODES] = {
  "Mem Rd Brkpt",
  "Mem Rd Watch",
  "Mem Wr Brkpt",
  "Mem Wr Watch",
  "IO Rd Brkpt",
  "IO Rd Watch",
  "IO Wr Brkpt",
  "IO Wr Watch",
  "Ex Brkpt",
  "Ex Watch",
  "Transient"
};

// For convenience, several masks are defined that group similar types of breakpoint/watch

// Mask for all breakpoint types
#define B_MASK       ((1<<BRKPT_MEM_READ) | (1<<BRKPT_MEM_WRITE) | (1<<BRKPT_IO_READ) | (1<<BRKPT_IO_WRITE) | (1<<BRKPT_EXEC))

// Mask for all watch types
#define W_MASK       ((1<<WATCH_MEM_READ) | (1<<WATCH_MEM_WRITE) | (1<<WATCH_IO_READ) | (1<<WATCH_IO_WRITE) | (1<<WATCH_EXEC))

// Mask for all breakpoints/watches that read memory or IO
#define BW_RD_MASK   ((1<<BRKPT_MEM_READ) | (1<<WATCH_MEM_READ) | (1<<BRKPT_IO_READ) | (1<<WATCH_IO_READ))

// Mask for all breakpoints/watches that write memory or IO
#define BW_WR_MASK   ((1<<BRKPT_MEM_WRITE) | (1<<WATCH_MEM_WRITE) | (1<<BRKPT_IO_WRITE) | (1<<WATCH_IO_WRITE))

// Mask for all breakpoint or watches that read/write Memory or IO
#define BW_RDWR_MASK (BW_RD_MASK | BW_WR_MASK)

// Mask for all breakpoints that read/write Memory or IO
#define B_RDWR_MASK  (BW_RDWR_MASK & B_MASK)

/********************************************************
 * External Trigger definitions
 ********************************************************/

// A boolean function of the external trigger inputs that
// is used to gate the watch/breakpoint.
unsigned char triggers[MAXBKPTS];

#define NUM_TRIGGERS 16

char * triggerStrings[NUM_TRIGGERS] = {
  "Never",
  "~T0 and ~T1",
  "T0 and ~T1",
  "~T1",
  "~T0 and T1",
  "~T0",
  "T0 xor T1",
  "~T0 or ~T1",
  "T0 and T1",
  "T0 xnor T1",
  "T0",
  "T0 or ~T1",
  "T1",
  "~T0 or T1",
  "T0 or T1",
  "Always",
};

#define TRIGGER_ALWAYS 15

#define TRIGGER_UNDEFINED 31

/********************************************************
 * Other global variables
 ********************************************************/

// The current memory address (e.g. used when disassembling)
unsigned int memAddr = 0;

// The address of the next instruction
unsigned int nextAddr = 0;

// When single stepping, trace (i.e. log) event N instructions
// Setting this to 0 will disable logging
long trace;

/********************************************************
 * User Command Processor
 ********************************************************/

void readCmd(char *cmd) {
  char c;
  int i = 0;
  log0(">> ");
  while (1) {
    c = Serial_RxByte0();
    if (c == 8) {
      // Handle backspace/delete
      if (i > 0) {
        i--;
        Serial_TxByte0(c);
        Serial_TxByte0(32);
        Serial_TxByte0(c);
      }
    } else if (c == 13) {
      // Handle return
      if (i == 0) {
        while (cmd[i]) {
          Serial_TxByte0(cmd[i++]);
        }
      } else {
        cmd[i] = 0;
      }
      Serial_TxByte0(10);
      Serial_TxByte0(13);
      return;
    } else if (c >= 32) {
      // Handle any other non-control character
      Serial_TxByte0(c);
      cmd[i] = c;
      i++;
    }
  }
}

/********************************************************
 * Low-level hardware commands
 ********************************************************/

// Send a single hardware command
void hwCmd(unsigned int cmd, unsigned int param) {
  unsigned int status = STATUS_DIN;
  cmd |= param;
  CTRL_PORT &= ~CMD_MASK;
  CTRL_PORT ^= cmd | CMD_EDGE;
  // Wait for the CMD_ACK bit to toggle
  while (!((STATUS_DIN ^ status) & CMD_ACK_MASK));
}

// Read an 8-bit register via the Mux
unsigned int hwRead8(unsigned int offset) {
  MUXSEL_PORT &= ~MUXSEL_MASK;
  MUXSEL_PORT |= offset << MUXSEL_BIT;
  Delay_us(1); // fixed 1us delay is needed here
  return MUX_DIN;
}

// Read an 16-bit register via the Mux
unsigned int hwRead16(unsigned int offset) {
  unsigned int lsb;
  MUXSEL_PORT &= ~MUXSEL_MASK;
  MUXSEL_PORT |= offset << MUXSEL_BIT;
  Delay_us(1); // fixed 1us delay is needed here
  lsb = MUX_DIN;
  MUXSEL_PORT |= 1 << MUXSEL_BIT;
  Delay_us(1); // fixed 1us delay is needed here
  return (MUX_DIN << 8) | lsb;
}

// Shift a breakpoint definition into the breakpoint shift register

void shift(unsigned int value, int numbits) {
  while (numbits-- > 0) {
    hwCmd(CMD_LOAD_BRKPT, value & 1);
    value >>= 1;
  }
}

void shiftBreakpointRegister(unsigned int addr, unsigned int mask, unsigned int mode, unsigned char trigger) {
  shift(addr, 16);
  shift(mask, 16);
  shift(mode, 10);
  shift(trigger, 4);
}

/********************************************************
 * Host Memory/IO Access helpers
 ********************************************************/

void log_char(int c) {
  if (c < 32 || c > 126) {
    c = '.';
  }
  log0("%c", c);
}

void log_addr_data(int a, int d) {
  log0(" %04X = %02X  ", a, d);
  log_char(d);
}

void loadData(unsigned int data) {
  int i;
  for (i = 0; i <= 7; i++) {
    hwCmd(CMD_LOAD_MEM, data & 1);
    data >>= 1;
  }
}

void loadAddr(unsigned int addr) {
  int i;
  for (i = 0; i <= 15; i++) {
    hwCmd(CMD_LOAD_MEM, addr & 1);
    addr >>= 1;
  }
}

unsigned int readMemByte() {
  hwCmd(CMD_RD_MEM, 0);
  return hwRead8(OFFSET_DATA);
}

unsigned int readMemByteInc() {
  hwCmd(CMD_RD_MEM_INC, 0);
  return hwRead8(OFFSET_DATA);
}

void writeMemByte() {
  hwCmd(CMD_WR_MEM, 0);
}

void writeMemByteInc() {
  hwCmd(CMD_WR_MEM_INC, 0);
}

unsigned int readIOByte() {
  hwCmd(CMD_RD_IO, 0);
  return hwRead8(OFFSET_DATA);
}

unsigned int readIOByteInc() {
  hwCmd(CMD_RD_IO_INC, 0);
  return hwRead8(OFFSET_DATA);
}

void writeIOByte() {
  hwCmd(CMD_WR_IO, 0);
}

void writeIOByteInc() {
  hwCmd(CMD_WR_IO_INC, 0);
}

unsigned int disMem(unsigned int addr) {
  loadAddr(addr);
  return disassemble(addr);
}

void genericDump(char *params, unsigned int (*readFunc)()) {
  int i, j;
  unsigned int row[16];
  sscanf(params, "%x", &memAddr);
  loadAddr(memAddr);
  for (i = 0; i < 0x100; i+= 16) {
    for (j = 0; j < 16; j++) {
      row[j] = (*readFunc)();
    }
    log0("%04X ", memAddr + i);
    for (j = 0; j < 16; j++) {
      log0("%02X ", row[j]);
    }
    log0(" ");
    for (j = 0; j < 16; j++) {
      unsigned int c = row[j];
      log_char(c);
    }
    log0("\n");
  }
  memAddr += 0x100;
}

void genericWrite(char *params, void (*writeFunc)()) {
  unsigned int data;
  long count = 1;
  sscanf(params, "%x %x %ld", &memAddr, &data, &count);
  log0("Wr: ");
  log_addr_data(memAddr, data);
  log0("\n");
  loadData(data);
  loadAddr(memAddr);
  while (count-- > 0) {
    (*writeFunc)();
  }
  memAddr++;
}

void genericRead(char *params, unsigned int (*readFunc)()) {
  unsigned int data;
  unsigned int data2;
  long count = 1;
  sscanf(params, "%x %ld", &memAddr, &count);
  loadAddr(memAddr);
  data = (*readFunc)();
  log0("Rd: ");
  log_addr_data(memAddr, data);
  log0("\n");
  while (count-- > 1) {
    data2 = (*readFunc)();
    if (data2 != data) {
      log0("Inconsistent Rd: %02X <> %02X\n", data2, data);
    }
    data = data2;
  }
  memAddr++;
}

/********************************************************
 * Logging Helpers
 ********************************************************/

void logCycleCount(int offsetLow, int offsetHigh) {
  unsigned long count = (((unsigned long) hwRead8(offsetHigh)) << 16) | hwRead16(offsetLow);
  unsigned long countSecs = count / 1000000;
  unsigned long countMicros = count % 1000000;
  log0("%02ld.%06ld: ", countSecs, countMicros);
}

void logMode(unsigned int mode) {
  int i;
  int first = 1;
  for (i = 0; i < NUM_MODES; i++) {
    if (mode & 1) {
      if (!first) {
        log0(", ");
      }
      log0("%s", modeStrings[i]);
      first = 0;
    }
    mode >>= 1;
  }
}

void logTrigger(unsigned char trigger) {
  if (trigger < NUM_TRIGGERS) {
    log0("trigger: %s", triggerStrings[trigger]);
  } else {
    log0("trigger: ILLEGAL");
  }
}

int logDetails() {
  unsigned int i_addr = hwRead16(OFFSET_BW_IAL);
  unsigned int b_addr = hwRead16(OFFSET_BW_BAL);
  unsigned int b_data = hwRead8(OFFSET_BW_BD);
  unsigned int mode   = hwRead8(OFFSET_BW_M);
  unsigned int watch  = mode & 1;

  // Convert from 4-bit compressed to 10 bit expanded mode representation
  mode = 1 << mode;

  // Update the serial console
  if (mode & W_MASK) {
    logCycleCount(OFFSET_BW_CNTL, OFFSET_BW_CNTH);
  }
  logMode(mode);
  log0(" hit at %04X", i_addr);
  if (mode & BW_RDWR_MASK) {
    if (mode & BW_WR_MASK) {
      log0(" writing");
    } else {
      log0(" reading");
    }
    log_addr_data(b_addr, b_data);
  }
  log0("\n");
  if (mode & B_RDWR_MASK) {
    // It's only safe to do this for brkpts, as it makes memory accesses
    logCycleCount(OFFSET_BW_CNTL, OFFSET_BW_CNTH);
    disMem(i_addr);
  }
  return watch;
}

void logAddr() {
  memAddr = hwRead16(OFFSET_IAL);
  // Update the serial console
  logCycleCount(OFFSET_CNTL, OFFSET_CNTH);
  //log0("%04X\n", i_addr);
  nextAddr = disMem(memAddr);
  return;
}

void version() {
  log0("%s In-Circuit Emulator version %s\n", NAME, VERSION);
  log0("Compiled at %s on %s\n",__TIME__,__DATE__);
  log0("%d watches/breakpoints implemented\n",MAXBKPTS);
}

/********************************************************
 * Watch/Breakpoint helpers
 ********************************************************/

// Return the index of a breakpoint from the user specified address
int lookupBreakpointN(int n) {
  int i;
  // First, look assume n is an address, and try to map to an index
  for (i = 0; i < numbkpts; i++) {
    if (breakpoints[i] == n) {
      n = i;
      break;
    }
  }
  if (n < numbkpts) {
    return n;
  } else {
    return -1;
  }
}

int lookupBreakpoint(char *params) {
  int addr = -1;
  sscanf(params, "%x", &addr);
  int n = lookupBreakpointN(addr);
  if (n < 0) {
    log0("Breakpoint/watch not set at %04X\n", addr);
  }
  return n;
}

// Enable/Disable single stepping
void setSingle(int single) {
  hwCmd(CMD_SINGLE_ENABLE, single ? 1 : 0);
}

// Enable/Disable tracing
void setTrace(long i) {
  trace = i;
  if (trace) {
    log0("Tracing every %ld instructions while single stepping\n", trace);
  } else {
    log0("Tracing disabled\n");
  }
}

// Set the breakpoint state variables

void logBreakpoint(unsigned int addr, unsigned int mode) {
  logMode(mode);
  log0(" set at %04X\n", addr);
}

void logTooManyBreakpoints() {
  log0("All %d breakpoints are already set\n", numbkpts);
}

void uploadBreakpoints() {
  int i;
  // Disable breakpoints to allow loading
  hwCmd(CMD_BRKPT_ENABLE, 0);

  // Load breakpoints into comparators
  for (i = 0; i < numbkpts; i++) {
    shiftBreakpointRegister(breakpoints[i], masks[i], modes[i], triggers[i]);
  }
  for (i = numbkpts; i < MAXBKPTS; i++) {
    shiftBreakpointRegister(0, 0, 0, 0);
  }
  // Enable breakpoints
  hwCmd(CMD_BRKPT_ENABLE, 1);
}

void setBreakpoint(int n, unsigned int addr, unsigned int mask, unsigned int mode, unsigned char trigger) {
  breakpoints[n] = addr & mask;
  masks[n] = mask;
  modes[n] = mode;
  triggers[n] = trigger;
  // Update the hardware copy of the breakpoints
  uploadBreakpoints();
}

void clearBreakpoint(int n) {
  int i;
  for (i = n; i < numbkpts; i++) {
    breakpoints[i] = breakpoints[i + 1];
    masks[i] = masks[i + 1];
    modes[i] = modes[i + 1];
    triggers[i] = triggers[i + 1];
  }
  numbkpts--;
  // Update the hardware copy of the breakpoints
  uploadBreakpoints();
}

// A generic helper that does most of the work of the watch/breakpoint commands
void genericBreakpoint(char *params, unsigned int mode) {
  int i;
  unsigned int addr;
  unsigned int mask = 0xFFFF;
  unsigned char trigger = TRIGGER_UNDEFINED;
  sscanf(params, "%x %x %hhx", &addr, &mask, &trigger);
  // First, see if a breakpoint with this address already exists
  for (i = 0; i < numbkpts; i++) {
    if (breakpoints[i] == addr) {
      if (modes[i] & mode) {
        logMode(mode);
        log0(" already set at %04X\n", addr);
        return;
      } else {
        // Preserve the existing trigger, unless it is overridden
        if (trigger == TRIGGER_UNDEFINED) {
          trigger = triggers[i];
        }
        // Preserve the existing modes
        mode |= modes[i];
        break;
      }
    }
  }
  // If existing breakpoint not find, then create a new one
  if (i == numbkpts) {
    if (numbkpts == MAXBKPTS) {
      logTooManyBreakpoints();
      return;
    }
    // New breakpoint, so if trigger not specified, set to ALWAYS
    if (trigger == TRIGGER_UNDEFINED) {
      trigger = TRIGGER_ALWAYS;
    }
    // Maintain the breakpoints in order of address
    while (i > 0 && breakpoints[i - 1] > addr) {
        breakpoints[i] = breakpoints[i - 1];
        masks[i] = masks[i - 1];
        modes[i] = modes[i - 1];
        triggers[i] = triggers[i - 1];
        i--;
    }
    numbkpts++;
  }
  // At this point, i contains the index of the new breakpoint
  logBreakpoint(addr, mode);
  setBreakpoint(i, addr, mask, mode, trigger);
}

/********************************************************
 * Test Helpers
 ********************************************************/

char *testNames[6] = {
  "Fixed",
  "Checkerboard",
  "Inverse checkerboard",
  "Address pattern",
  "Inverse address pattern",
  "Random"
};

unsigned int getData(unsigned int addr, int data) {
  if (data == -1) {
    // checkerboard
    return (addr & 1) ? 0x55 : 0xAA;
  } else if (data == -2) {
    // inverse checkerboard
    return (addr & 1) ? 0xAA : 0x55;
  } else if (data == -3) {
    // address pattern
    return (0xC3 ^ addr ^ (addr >> 8)) & 0xff;
  } else if (data == -4) {
    // address pattern
    return (0x3C ^ addr ^ (addr >> 8)) & 0xff;
  } else if (data < 0) {
    // random data
    return rand() & 0xff;
  } else {
    // fixed data
    return data & 0xff;
  }
}

void test(unsigned int start, unsigned int end, int data) {
  long i;
  int name;
  int actual;
  int expected;
  unsigned int fail = 0;
  // Write
  srand(data);
  for (i = start; i <= end; i++) {
    loadData(getData(i, data));
    loadAddr(i);
    writeMemByteInc();
  }
  // Read
  srand(data);
  loadAddr(start);
  for (i = start; i <= end; i++) {
    actual = readMemByteInc();
    expected = getData(i, data);
    if (expected != actual) {
      log0("Fail at %04lX (Wrote: %02X, Read back %02X)\n", i, expected, actual);
      fail++;
    }
  }
  name = -data;
  if (name < 0) {
    name = 0;
  }
  if (name > 5) {
    name = 5;
  }
  log0("Memory test: %s", testNames[name]);
  if (data >= 0) {
    log0(" %02X", data);
  }
  if (fail) {
    log0(": failed: %d errors\n", fail);
  } else {
    log0(": passed\n");
  }
}

int pollForEvents() {
  int cont = 1;
  if (STATUS_DIN & BW_ACTIVE_MASK) {
    cont = logDetails();
    hwCmd(CMD_WATCH_READ, 0);
  }
  if (Serial_ByteRecieved0()) {
    // Interrupt on a return, ignore other characters
    if (Serial_RxByte0() == 13) {
      cont = 0;
    }
  }
  return cont;
}

// Applies a fixed 1ms long reset pulse to the CPU
// This should be good for clock rates down to ~10KHz
void resetCpu() {
  log0("Resetting CPU\n");
  hwCmd(CMD_RESET, 1);
  Delay_us(1000);
  hwCmd(CMD_RESET, 0);
}

/*******************************************
 * User Commands
 *******************************************/

void doCmdHelp(char *params) {
  int i;
  version();
  log0("Commands:\n");
  for (i = 0; i < NUM_CMDS; i++) {
    log0("    %s\n", cmdStrings[i]);
  }
}

void doCmdStep(char *params) {
  long instructions = 1;
  long i;
  long j;
  sscanf(params, "%ld", &instructions);
  if (instructions <= 0) {
    log0("Number of instuctions must be positive\n");
    return;
  }

  log0("Stepping %ld instructions\n", instructions);

  j = trace;
  for (i = 1; i <= instructions; i++) {
    // Step the CPU
    hwCmd(CMD_STEP, 0);
    // Output any watch/breakpoint messages
    if (!pollForEvents()) {
      log0("Interrupted after %ld instructions\n", i);
      i = instructions;
    }
    if (i == instructions || (trace && (--j == 0))) {
      logAddr();
      j = trace;
    }
  }
}

void doCmdReset(char *params) {
  resetCpu();
  logAddr();
}

// doCmdRegs is now in regs<cpu>.c

void doCmdDis(char *params) {
  int i;
  sscanf(params, "%x", &memAddr);
  loadAddr(memAddr);
  for (i = 0; i < 10; i++) {
    memAddr = disassemble(memAddr);
  }
}

void doCmdFill(char *params) {
  long i;
  unsigned int start;
  unsigned int end;
  unsigned int data;
  sscanf(params, "%x %x %x", &start, &end, &data);
  log0("Wr: %04X to %04X = %02X\n", start, end, data);
  loadData(data);
  loadAddr(start);
  for (i = start; i <= end; i++) {
    writeMemByteInc();
  }
}

void doCmdCrc(char *params) {
  long i;
  int j;
  unsigned int start;
  unsigned int end;
  unsigned int data;
  unsigned long crc = 0;
  sscanf(params, "%x %x", &start, &end);
  loadAddr(start);
  for (i = start; i <= end; i++) {
    data = readMemByteInc();
    for (j = 0; j < 8; j++) {
      crc = crc << 1;
      crc = crc | (data & 1);
      data >>= 1;
      if (crc & 0x10000)
        crc = (crc ^ CRC_POLY) & 0xFFFF;
    }
  }
  log0("crc: %04X\n", crc);
}

void doCmdMem(char *params) {
  genericDump(params, readMemByteInc);
}

void doCmdReadMem(char *params) {
  genericRead(params, readMemByte);
}

void doCmdWriteMem(char *params) {
  genericWrite(params, writeMemByte);
}

#if defined(CPU_Z80)

void doCmdIO(char *params) {
  genericDump(params, readIOByteInc);
}

void doCmdReadIO(char *params) {
  genericRead(params, readIOByte);
}

void doCmdWriteIO(char *params) {
  genericWrite(params, writeIOByte);
}

#endif

void doCmdTest(char *params) {
  unsigned int start;
  unsigned int end;
  int data =-100;
  int i;
  sscanf(params, "%x %x %d", &start, &end, &data);
  if (data == -100) {
    test(start, end, 0x55);
    test(start, end, 0xAA);
    test(start, end, 0xFF);
    for (i = 0; i >= -7; i--) {
      test(start, end, i);
    }
  } else {
    test(start, end, data);
  }
}

int crc;

int getHex() {
   int i;
   char hex[2];
   hex[0] = Serial_RxByte0();
   hex[1] = Serial_RxByte0();
   sscanf(hex, "%2x", &i);
   crc += i;
   crc &= 0xff;
   return i;
}

// Simple SRecord command
//
// Deals with the following format:
//    S123A0004C10A0A94E8D0802A9A08D09024C33A0A9468D0402A9A08D0502A90F8D04B8A9A9
//    <S1><Count><Addr><Data>...<Data><CRC>
//
//

void doCmdSRec(char *params) {
   int c;
   int count;
   int data;
   int good_rec = 0;
   int bad_rec = 0;
   unsigned int addr;
   unsigned int total = 0;
   unsigned int timeout;

   unsigned int addrlo = 0xFFFF;
   unsigned int addrhi = 0x0000;


   log0("Send file now...\n");

   // Special case reading the first record, with no timeout
   c = Serial_RxByte0();

   while (1) {

      while (c != 'S') {

         // Wait for a character to be received, while testing for a timeout
         timeout = 65535;
         while (timeout > 0 && !Serial_ByteRecieved0()) {
            timeout--;
         }

         // If we have timed out, then exit
         if (timeout == 0) {
            log0("recieved %d good records, %d bad records\n", good_rec, bad_rec);
            log0("transferred %d bytes to 0x%04x - 0x%04x\n", total, addrlo, addrhi);
            return;
         }

         // Read the character
         c = Serial_RxByte0();
      }

      // Read the S record type
      c = Serial_RxByte0();

      // Skip to the next line
      if (c != '1') {
         log0("skipping S%d\n", c);
         continue;
      }

      // Process S1 record
      crc = 1;
      count = getHex() - 3;
      addr = (getHex() << 8) + getHex();
      while (count-- > 0) {
         data = getHex();
         if (addr < addrlo) {
            addrlo = addr;
         }
         if (addr > addrhi) {
            addrhi = addr;
         }
         loadData(data);
         loadAddr(addr++);
         writeMemByteInc();
         total++;
      }
      // Read the crc byte
      getHex();

      // Read the terminator byte
      c = Serial_RxByte0();

      if (crc) {
         bad_rec++;
      } else {
         good_rec++;
      }
   }

}

void logSpecial(char *function, int value) {
   log0("%s", function);
   if (value) {
      log0(" inhibited\n");
   } else {
      log0(" enabled\n");
   }
}

void doCmdSpecial(char *params) {
   int special = -1;
   sscanf(params, "%x", &special);
   if (special >= 0 && special <= 3) {
      CTRL_PORT = (CTRL_PORT & ~SPECIAL_MASK) | (special << SPECIAL_0);
   }
   logSpecial("NMI", CTRL_PORT & (1 << SPECIAL_1));
   logSpecial("IRQ", CTRL_PORT & (1 << SPECIAL_0));
}

void doCmdTrace(char *params) {
  long i;
  sscanf(params, "%ld", &i);
  setTrace(i);
}

void doCmdList(char *params) {
  int i;
  if (numbkpts) {
    for (i = 0; i < numbkpts; i++) {
      log0("%d: %04X mask %04X: ", i, breakpoints[i], masks[i]);
      logMode(modes[i]);
      log0(" (");
      logTrigger(triggers[i]);
      log0(")\n");
    }
  } else {
      log0("No breakpoints set\n");
  }
}

void doCmdBreakI(char *params) {
  genericBreakpoint(params, 1 << BRKPT_EXEC);
}

void doCmdWatchI(char *params) {
  genericBreakpoint(params, 1 << WATCH_EXEC);
}

void doCmdBreakRdMem(char *params) {
  genericBreakpoint(params, 1 << BRKPT_MEM_READ);
}

void doCmdWatchRdMem(char *params) {
  genericBreakpoint(params, 1 << WATCH_MEM_READ);
}

void doCmdBreakWrMem(char *params) {
  genericBreakpoint(params, 1 << BRKPT_MEM_WRITE);
}

void doCmdWatchWrMem(char *params) {
  genericBreakpoint(params, 1 << WATCH_MEM_WRITE);
}

#if defined(CPU_Z80)

void doCmdBreakRdIO(char *params) {
  genericBreakpoint(params, 1 << BRKPT_IO_READ);
}

void doCmdWatchRdIO(char *params) {
  genericBreakpoint(params, 1 << WATCH_IO_READ);
}

void doCmdBreakWrIO(char *params) {
  genericBreakpoint(params, 1 << BRKPT_IO_WRITE);
}

void doCmdWatchWrIO(char *params) {
  genericBreakpoint(params, 1 << WATCH_IO_WRITE);
}

#endif

void doCmdClear(char *params) {
  int n = lookupBreakpoint(params);
  if (n < 0) {
    return;
  }
  log0("Removing ");
  logMode(modes[n]);
  log0(" at %04X\n", breakpoints[n]);
  clearBreakpoint(n);
}

void doCmdTrigger(char *params) {
  unsigned char trigger = TRIGGER_UNDEFINED;
  sscanf(params, "%*x %hhx", &trigger);
  if (trigger >= NUM_TRIGGERS) {
    log0("Trigger Codes:\n");
    for (trigger = 0; trigger < NUM_TRIGGERS; trigger++) {
      log0("    %X = %s\n", trigger, triggerStrings[trigger]);
    }
    return;
  }
  // Lookup the breakpoint
  int n = lookupBreakpoint(params);
  if (n < 0) {
    return;
  }
  // Update the trigger value
  triggers[n] = trigger;
  // Update the hardware copy of the breakpoints
  uploadBreakpoints();
}

// Set transient breakpoint on the next instruction
//
// This allows you to single step over a subroutine call, or
// continue exeuting until a loop exits.
//
void doCmdNext(char *params) {
  if (numbkpts == MAXBKPTS) {
    logTooManyBreakpoints();
    return;
  }
  numbkpts++;
  setBreakpoint(numbkpts - 1, nextAddr, 0xffff, (1 << BRKPT_EXEC) | (1 << TRANSIENT), TRIGGER_ALWAYS);
  doCmdContinue(params);
}

void doCmdContinue(char *params) {
  int reset = 0;
  sscanf(params, "%d", &reset);

  // Disable single stepping
  setSingle(0);

  // Reset if required
  if (reset) {
    resetCpu();
  }

  // Wait for breakpoint to become active
  log0("CPU free running...\n");
  while (pollForEvents());
  log0("Interrupted\n");

  // Enable single stepping
  setSingle(1);

  // Show current instruction
  logAddr();

  // If we have hit the transient breakpoint, clear it
  int n = lookupBreakpointN(memAddr);
  if ((n >= 0)  && (modes[n] & (1 << TRANSIENT))) {
    clearBreakpoint(n);
  }
}

void initialize() {
  PDC_DDR = 0;
  CTRL_DDR = 255;
  STATUS_DDR = MUXSEL_MASK;
  MUX_DDR = 0;
  CTRL_PORT = 0;
  Serial_Init(57600,57600);
  version();
  // Update the hardware copy of the breakpoints
  uploadBreakpoints();
  hwCmd(CMD_RESET, 0);
  hwCmd(CMD_FIFO_RST, 0);
  setSingle(1);
  setTrace(1);
}

void dispatchCmd(char *cmd) {
  int i;
  char *cmdString;
  int minLen;
  int cmdStringLen;
  int cmdLen = 0;
  while (cmd[cmdLen] >= 'a' && cmd[cmdLen] <= 'z') {
    cmdLen++;
  }
  for (i = 0; i < NUM_CMDS; i++) {
    cmdString = cmdStrings[i];
    cmdStringLen = strlen(cmdString);
    minLen = cmdLen < cmdStringLen ? cmdLen : cmdStringLen;
    if (strncmp(cmdString, cmd, minLen) == 0) {
      (*cmdFuncs[i])(cmd + cmdLen);
      return;
    }
  }
  log0("Unknown command %s\n", cmd);
}

int main(void) {
  static char command[32];
  initialize();
  doCmdContinue(NULL);
  while (1) {
    readCmd(command);
    dispatchCmd(command);
  }
  return 0;
}
