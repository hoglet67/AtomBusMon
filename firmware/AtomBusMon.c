#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <avr/pgmspace.h>

#define COMMAND_HISTORY

#include "AtomBusMon.h"

/********************************************************
 * VERSION and NAME are used in the start-up message
 ********************************************************/

#define VERSION "0.92"

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
#if defined(COMMAND_HISTORY)
  "history",
#endif
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
#if defined(COMMAND_HISTORY)
  doCmdHistory,
#endif
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
bknum_t numbkpts = 0;

// Watches/Breakpoints are loaded into a massive shift register by the
// continue command. The following variables in the AVR track what the
// user has requested. These are updated by the watch/break/clear/trigger
// commands.

// Each watch/breakpoint is defined with 46 bits in the shift register
// MS Bit ............................................ LS Bit
// <Trigger:4> <Mode:10> <Address Mask:16> <Address Value:16>

// A 16 bit breakpoint address
addr_t breakpoints[MAXBKPTS];

// A 16 bit breakpoint address mask
addr_t masks[MAXBKPTS];

// The type (aka mode) of breakpoint (a 10 bit values), allowing
// multiple types to be defined. The bits correspond to the mode
// definitions below.
modes_t modes[MAXBKPTS];

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


static const char MODE0[] PROGMEM = "Mem Rd Brkpt";
static const char MODE1[] PROGMEM = "Mem Rd Watch";
static const char MODE2[] PROGMEM = "Mem Wr Brkpt";
static const char MODE3[] PROGMEM = "Mem Wr Watch";
static const char MODE4[] PROGMEM = "IO Rd Brkpt";
static const char MODE5[] PROGMEM = "IO Rd Watch";
static const char MODE6[] PROGMEM = "IO Wr Brkpt";
static const char MODE7[] PROGMEM = "IO Wr Watch";
static const char MODE8[] PROGMEM = "Ex Brkpt";
static const char MODE9[] PROGMEM = "Ex Watch";
static const char MODE10[] PROGMEM = "Transient";

// Breakpoint Mode Strings, should match the modes above
static const char *modeStrings[NUM_MODES] = {
  MODE0,
  MODE1,
  MODE2,
  MODE3,
  MODE4,
  MODE5,
  MODE6,
  MODE7,
  MODE8,
  MODE9,
  MODE10
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
trigger_t triggers[MAXBKPTS];

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
addr_t memAddr = 0;

// The address of the next instruction
addr_t nextAddr = 0;

// When single stepping, trace (i.e. log) event N instructions
// Setting this to 0 will disable logging
long trace;

/********************************************************
 * Simple string logger, as log0 is expensive
 ********************************************************/

void logc(char c) {
  Serial_TxByte0(c);
  if (c == '\n') {
    Serial_TxByte0('\r');
  }
}

void logs(const char *s) {
  while (*s) {
    logc(*s++);
  }
}

#define logstr(s) logpgmstr(PSTR((s)))

void logpgmstr(const char *s) {
  char c;
  do {
    c = pgm_read_byte(s++);
    if (c) {
      logc(c);
    }
  } while (c);
}

void loghex1(uint8_t i) {
  i &= 0x0f;
  if (i < 10) {
    i += '0';
  } else {
    i += 'A';
  }
  logc(i);
}

void loghex2(uint8_t i) {
  loghex1(i >> 4);
  loghex1(i);
}

void loghex4(uint16_t i) {
  loghex2(i >> 8);
  loghex2(i);
}

//void loglong(long i) {
//  char buffer[16];
//  // ltoa adds 176 bytes
//  logs(ltoa(i, buffer, 10));
//}
//
//void logint(int i) {
//  char buffer[16];
//  // itoa adds 176 bytes
//  logs(itoa(i, buffer, 10));
//}

/********************************************************
 * User Command Processor
 ********************************************************/

#if defined(COMMAND_HISTORY)
int8_t readCmd(char *cmd, int8_t reuse) {
  uint8_t esc = 0;
#else
void readCmd(char *cmd) {
#endif
  char c;
  int i = 0;
#if defined(COMMAND_HISTORY)
  // Wipe out the last command
  Serial_TxByte0(13);
  for (i = 0; i < 32; i++) {
    Serial_TxByte0(32);
  }
  Serial_TxByte0(13);
#endif
  logstr(">> ");
#if defined(COMMAND_HISTORY)
  i = 0;
  if (reuse) {
    while (cmd[i]) {
      Serial_TxByte0(cmd[i++]);
    }
  }
#endif
  while (1) {
    c = Serial_RxByte0();
#if defined(COMMAND_HISTORY)
    // Handle Cursor Keys
    //   Cursor Up   - ESC [ A
    //   Cursor Down - ESC [ B
    if (esc == 2) {
      if (c == 65) {
        return -1;
      } else if (c == 66) {
        return 1;
      } else {
        esc = 0;
      }
    } else if (esc == 1) {
      if (c == 91) {
        esc++;
      } else {
        esc = 0;
      }
    } else if (c == 27) {
      esc++;
    } else
#endif
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
#if defined(COMMAND_HISTORY)
      cmd[i] = 0;
      Serial_TxByte0(10);
      Serial_TxByte0(13);
      return 0;
#else
      // Return repeats the previous command
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
#endif
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
void hwCmd(cmd_t cmd, cmd_t param) {
  uint8_t status = STATUS_DIN;
  cmd |= param;
  CTRL_PORT &= ~CMD_MASK;
  CTRL_PORT ^= cmd | CMD_EDGE;
  // Wait for the CMD_ACK bit to toggle
  while (!((STATUS_DIN ^ status) & CMD_ACK_MASK));
}

// Read an 8-bit register via the Mux
uint8_t hwRead8(offset_t offset) {
  MUXSEL_PORT &= ~MUXSEL_MASK;
  MUXSEL_PORT |= offset << MUXSEL_BIT;
  Delay_us(1); // fixed 1us delay is needed here
  return MUX_DIN;
}

// Read an 16-bit register via the Mux
uint16_t hwRead16(offset_t offset) {
  uint8_t lsb;
  MUXSEL_PORT &= ~MUXSEL_MASK;
  MUXSEL_PORT |= offset << MUXSEL_BIT;
  Delay_us(1); // fixed 1us delay is needed here
  lsb = MUX_DIN;
  MUXSEL_PORT |= 1 << MUXSEL_BIT;
  Delay_us(1); // fixed 1us delay is needed here
  return (MUX_DIN << 8) | lsb;
}

// Shift a breakpoint definition into the breakpoint shift register

void shift(uint16_t value, uint8_t numbits) {
  while (numbits-- > 0) {
    hwCmd(CMD_LOAD_BRKPT, value & 1);
    value >>= 1;
  }
}

void shiftBreakpointRegister(addr_t addr, addr_t mask, modes_t mode, trigger_t trigger) {
  shift(addr, 16);
  shift(mask, 16);
  shift(mode, 10);
  shift(trigger, 4);
}

/********************************************************
 * Host Memory/IO Access helpers
 ********************************************************/

void log_char(uint8_t c) {
  if (c < 32 || c > 126) {
    c = '.';
  }
  logc(c);
}

void log_addr_data(addr_t a, data_t d) {
  logc(' ');
  loghex4(a);
  logstr(" = ");
  loghex2(d);
  logstr("  ");
  log_char(d);
}

void loadData(data_t data) {
  uint8_t i;
  for (i = 0; i <= 7; i++) {
    hwCmd(CMD_LOAD_MEM, data & 1);
    data >>= 1;
  }
}

void loadAddr(addr_t addr) {
  uint8_t i;
  for (i = 0; i <= 15; i++) {
    hwCmd(CMD_LOAD_MEM, addr & 1);
    addr >>= 1;
  }
}

data_t readMemByte() {
  hwCmd(CMD_RD_MEM, 0);
  return hwRead8(OFFSET_DATA);
}

data_t readMemByteInc() {
  hwCmd(CMD_RD_MEM_INC, 0);
  return hwRead8(OFFSET_DATA);
}

void writeMemByte() {
  hwCmd(CMD_WR_MEM, 0);
}

void writeMemByteInc() {
  hwCmd(CMD_WR_MEM_INC, 0);
}

data_t readIOByte() {
  hwCmd(CMD_RD_IO, 0);
  return hwRead8(OFFSET_DATA);
}

data_t readIOByteInc() {
  hwCmd(CMD_RD_IO_INC, 0);
  return hwRead8(OFFSET_DATA);
}

void writeIOByte() {
  hwCmd(CMD_WR_IO, 0);
}

void writeIOByteInc() {
  hwCmd(CMD_WR_IO_INC, 0);
}

addr_t disMem(addr_t addr) {
  loadAddr(addr);
  return disassemble(addr);
}

void genericDump(char *params, data_t (*readFunc)()) {
  uint16_t i;
  uint16_t j;
  data_t row[16];
  sscanf(params, "%x", &memAddr);
  loadAddr(memAddr);
  for (i = 0; i < 0x100; i+= 16) {
    for (j = 0; j < 16; j++) {
      row[j] = (*readFunc)();
    }
    loghex4(memAddr + i);
    logc(' ');
    for (j = 0; j < 16; j++) {
      loghex2(row[j]);
      logc(' ');
    }
    logc(' ');
    for (j = 0; j < 16; j++) {
      data_t c = row[j];
      log_char(c);
    }
    logc('\n');
  }
  memAddr += 0x100;
}

void genericWrite(char *params, void (*writeFunc)()) {
  data_t data;
  long count = 1;
  sscanf(params, "%x %hhx %ld", &memAddr, &data, &count);
  logstr("Wr: ");
  log_addr_data(memAddr, data);
  logc('\n');
  loadData(data);
  loadAddr(memAddr);
  while (count-- > 0) {
    (*writeFunc)();
  }
  memAddr++;
}

void genericRead(char *params, data_t (*readFunc)()) {
  // Note: smaller types here increase the code size by 28 bytes
  uint16_t data;
  uint16_t data2;
  long count = 1;
  sscanf(params, "%x %ld", &memAddr, &count);
  loadAddr(memAddr);
  data = (*readFunc)();
  logstr("Rd: ");
  log_addr_data(memAddr, data);
  logc('\n');
  while (count-- > 1) {
    data2 = (*readFunc)();
    if (data2 != data) {
      logstr("Inconsistent Rd: ");
      loghex2(data2);
      logstr(" <> ");
      loghex2(data);
      logc('\n');
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

void logMode(modes_t mode) {
  uint8_t first = 1;
  // Note: smaller types here increase the code size by 8 bytes
  uint16_t i;
  for (i = 0; i < NUM_MODES; i++) {
    if (mode & 1) {
      if (!first) {
        logstr(", ");
      }
      logpgmstr(modeStrings[i]);
      first = 0;
    }
    mode >>= 1;
  }
}

void logTrigger(trigger_t trigger) {
  if (trigger < NUM_TRIGGERS) {
    logstr("trigger: ");
    logs(triggerStrings[trigger]);
  } else {
    logstr("trigger: ILLEGAL");
  }
}

uint8_t logDetails() {
  addr_t i_addr = hwRead16(OFFSET_BW_IAL);
  addr_t b_addr = hwRead16(OFFSET_BW_BAL);
  data_t b_data = hwRead8(OFFSET_BW_BD);
  modes_t mode  = hwRead8(OFFSET_BW_M);
  uint8_t watch = mode & 1;

  // Convert from 4-bit compressed to 10 bit expanded mode representation
  mode = 1 << mode;

  // Update the serial console
  if (mode & W_MASK) {
    logCycleCount(OFFSET_BW_CNTL, OFFSET_BW_CNTH);
  }
  logMode(mode);
  logstr(" hit at ");
  loghex4(i_addr);
  if (mode & BW_RDWR_MASK) {
    if (mode & BW_WR_MASK) {
      logstr(" writing");
    } else {
      logstr(" reading");
    }
    log_addr_data(b_addr, b_data);
  }
  logc('\n');
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
  nextAddr = disMem(memAddr);
  return;
}

void version() {
  logstr(NAME);
  logstr(" In-Circuit Emulator version ");
  logstr(VERSION);
  logstr("\nCompiled at ");
  logstr(__TIME__);
  logstr(" on ");
  logstr(__DATE__);
  logc('\n');
  loghex2(MAXBKPTS);
  logstr(" watches/breakpoints implemented\n");
}

/********************************************************
 * Watch/Breakpoint helpers
 ********************************************************/

// Return the index of a breakpoint from the user specified address
bknum_t lookupBreakpointN(addr_t n) {
  // Note: smaller types here increase the code size by 8 bytes
  bknum_t i;
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

bknum_t lookupBreakpoint(char *params) {
  int addr = -1;
  sscanf(params, "%x", &addr);
  bknum_t n = lookupBreakpointN(addr);
  if (n < 0) {
    logstr("Breakpoint/watch not set at ");
    loghex4(addr);
    logc('\n');
  }
  return n;
}

// Enable/Disable single stepping
void setSingle(uint8_t single) {
  hwCmd(CMD_SINGLE_ENABLE, single ? 1 : 0);
}

// Enable/Disable tracing
void setTrace(long i) {
  trace = i;
  if (trace) {
    log0("Tracing every %ld instructions while single stepping\n", trace);
  } else {
    logstr("Tracing disabled\n");
  }
}

// Set the breakpoint state variables

void logBreakpoint(addr_t addr, modes_t mode) {
  logMode(mode);
  logstr(" set at ");
  loghex4(addr);
  logc('\n');
}

void logTooManyBreakpoints() {
  log0("All %d breakpoints are already set\n", numbkpts);
}

void uploadBreakpoints() {
  // This should be bknum_t, but code increases by 40 bytes
  uint8_t i;
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

void setBreakpoint(bknum_t n, addr_t addr, addr_t mask, modes_t mode, trigger_t trigger) {
  breakpoints[n] = addr & mask;
  masks[n] = mask;
  modes[n] = mode;
  triggers[n] = trigger;
  // Update the hardware copy of the breakpoints
  uploadBreakpoints();
}

void clearBreakpoint(bknum_t n) {
  bknum_t i;
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
  bknum_t i;
  addr_t addr;
  addr_t mask = 0xFFFF;
  trigger_t trigger = TRIGGER_UNDEFINED;
  sscanf(params, "%x %x %hhx", &addr, &mask, &trigger);
  // First, see if a breakpoint with this address already exists
  for (i = 0; i < numbkpts; i++) {
    if (breakpoints[i] == addr) {
      if (modes[i] & mode) {
        logMode(mode);
        logstr(" already set at ");
        loghex4(addr);
        logc('\n');
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

char *testNames[] = {
  "Fixed",
  "Checkerboard",
  "Inverse checkerboard",
  "Address pattern",
  "Inverse address pattern",
  "Random"
};

data_t getData(addr_t addr, int data) {
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

void test(addr_t start, addr_t end, int data) {
  long i;
  int name;
  data_t actual;
  data_t expected;
  addr_t fail = 0;
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
      logstr("Fail at ");
      loghex4(i);
      logstr(" (Wrote: ");
      loghex2(expected);
      logstr(", Read back ");
      loghex2(actual);
      logstr(")\n");
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
  logstr("Memory test: ");
  logs(testNames[name]);
  if (data >= 0) {
    logc(' ');
    loghex2(data);
  }
  if (fail) {
    log0(": failed: %d errors\n", fail);
  } else {
    logstr(": passed\n");
  }
}

uint8_t pollForEvents() {
  uint8_t cont = 1;
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
  logstr("Resetting CPU\n");
  hwCmd(CMD_RESET, 1);
  Delay_us(1000);
  hwCmd(CMD_RESET, 0);
}

/*******************************************
 * User Commands
 *******************************************/

void doCmdHelp(char *params) {
  uint8_t i;
  version();
  logstr("Commands:\n");
  for (i = 0; i < NUM_CMDS; i++) {
    logstr("    ");
    logs(cmdStrings[i]);
    logc('\n');
  }
}

void doCmdStep(char *params) {
  long instructions = 1;
  long i;
  long j;
  sscanf(params, "%ld", &instructions);
  if (instructions <= 0) {
    logstr("Number of instuctions must be positive\n");
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
  uint8_t i;
  sscanf(params, "%x", &memAddr);
  loadAddr(memAddr);
  for (i = 0; i < 10; i++) {
    memAddr = disassemble(memAddr);
  }
}

void doCmdFill(char *params) {
  long i;
  addr_t start;
  addr_t end;
  data_t data;
  sscanf(params, "%x %x %hhx", &start, &end, &data);
  logstr("Wr: ");
  loghex4(start);
  logstr(" to ");
  loghex4(end);
  logstr(" = ");
  loghex2(data);
  logc('\n');
  loadData(data);
  loadAddr(start);
  for (i = start; i <= end; i++) {
    writeMemByteInc();
  }
}

void doCmdCrc(char *params) {
  long i;
  uint8_t j;
  addr_t start;
  addr_t end;
  data_t data;
  uint32_t crc = 0;
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
  logstr("crc: ");
  loghex4(crc);
  logc('\n');
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
  addr_t start;
  addr_t end;
  int data =-100;
  int8_t i;
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

uint8_t crc;

int getHex() {
   uint8_t i;
   char hex[2];
   hex[0] = Serial_RxByte0();
   hex[1] = Serial_RxByte0();
   sscanf(hex, "%2hhx", &i);
   crc += i;
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
   char c;
   uint8_t count;
   data_t data;
   addr_t good_rec = 0;
   addr_t bad_rec = 0;
   addr_t addr;
   addr_t total = 0;
   uint16_t timeout;

   addr_t addrlo = 0xFFFF;
   addr_t addrhi = 0x0000;


   logstr("Send file now...\n");

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

void logSpecial(char *function, uint8_t value) {
   logs(function);
   if (value) {
      logstr(" inhibited\n");
   } else {
      logstr(" enabled\n");
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
  // This should be bknum_t, but code increases by 22 bytes
  uint8_t i;
  if (numbkpts) {
    for (i = 0; i < numbkpts; i++) {
      log0("%d: %04X mask %04X: ", i, breakpoints[i], masks[i]);
      logMode(modes[i]);
      logs(" (");
      logTrigger(triggers[i]);
      logstr(")\n");
    }
  } else {
      logstr("No breakpoints set\n");
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
  bknum_t n = lookupBreakpoint(params);
  if (n < 0) {
    return;
  }
  logstr("Removing ");
  logMode(modes[n]);
  logstr(" at ");
  loghex4(breakpoints[n]);
  logc('\n');
  clearBreakpoint(n);
}

void doCmdTrigger(char *params) {
  trigger_t trigger = TRIGGER_UNDEFINED;
  sscanf(params, "%*x %hhx", &trigger);
  if (trigger >= NUM_TRIGGERS) {
    logstr("Trigger Codes:\n");
    for (trigger = 0; trigger < NUM_TRIGGERS; trigger++) {
      logstr("    ");
      loghex1(trigger);
      logstr(" = ");
      logs(triggerStrings[trigger]);
      logc('\n');
    }
    return;
  }
  // Lookup the breakpoint
  bknum_t n = lookupBreakpoint(params);
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
  uint8_t reset = 0;
  sscanf(params, "%hhd", &reset);

  // Disable single stepping
  setSingle(0);

  // Reset if required
  if (reset) {
    resetCpu();
  }

  // Wait for breakpoint to become active
  logstr("CPU free running...\n");
  while (pollForEvents());
  logstr("Interrupted\n");

  // Enable single stepping
  setSingle(1);

  // Show current instruction
  logAddr();

  // If we have hit the transient breakpoint, clear it
  bknum_t n = lookupBreakpointN(memAddr);
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
  char *cmdString;
  uint8_t i;
  uint8_t minLen;
  uint8_t cmdStringLen;
  uint8_t cmdLen = 0;
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
  logstr("Unknown command ");
  logs(cmd);
  logc('\n');
}

#ifdef COMMAND_HISTORY

#define HISTORY_LENGTH 16
#define COMMAND_LENGTH 32

static char history[HISTORY_LENGTH][COMMAND_LENGTH];
static char command[COMMAND_LENGTH];

// Last points to the most recent history item, or -1 if the history is empty
int8_t last = -1;

void doCmdHistory(char *params) {
  uint8_t id = 1;
  for (uint8_t i = 1; i <= HISTORY_LENGTH; i++) {
    char *h = history[(last + i) & (HISTORY_LENGTH - 1)];
    if (*h) {
      log0("[%d] %s\n", id++, h);
    }
  }
}

int main(void) {

  // Index points to the currently selected history item
  int8_t index = -1;

  // Direction indicates the direction of traversal through the history buffer
  int8_t direction = 0;

  initialize();
  doCmdContinue(NULL);
  while (1) {
    // Returns:
    // -1 to move back through the history buffer
    // 0 to use the current command
    // 1 to move forward through the history buffer
    direction = readCmd(command, direction);
    if (direction != 0) {
      // Calculate next history item, given the direction
      int8_t tmp = (index + direction + HISTORY_LENGTH) & (HISTORY_LENGTH - 1);
      // Update index of the next history item, or -1 if there isn't one
      if (index < 0) {
        if (direction < 0) {
          // This covers the first time back is pressed
          index = last;
        }
      } else {
        if (direction < 0) {
          // Stepping back through the history buffer
          if (tmp != last && *history[tmp]) {
            index = tmp;
          }
        } else {
          // Stepping forward through the history buffer
          if (index == last) {
            // Already the most recent item
            index = -1;
          } else {
            index = tmp;
          }
        }
      }
      // Relast the command from the history last
      if (index >= 0) {
        strcpy(command, history[index]);
      } else {
        direction = 0;
      }
    } else {
      if (*command) {
        if (last < 0 || strcmp(history[last], command)) {
          // Save the command on the end of the history buffer
          last = (last + 1) & (HISTORY_LENGTH - 1);
          strcpy(history[last], command);
        }
      }
      // Execute the command
      dispatchCmd(command);
      // Reset the history cursor to the current slot
      index = -1;
    }
  }
  return 0;
}

#else

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

#endif
