#include <stdio.h>
#include <string.h>
#include <avr/pgmspace.h>

#include "hd44780.h"
#include "status.h"

#define CTRL_PORT PORTB
#define CTRL_DDR  DDRB
#define CTRL_DIN  PINB

#define STATUS_PORT PORTD
#define STATUS_DDR  DDRD
#define STATUS_DIN  PIND

#define MUX_PORT PORTE
#define MUX_DDR  DDRE
#define MUX_DIN  PINE

#define OFFSET_IAL 0
#define OFFSET_IAH 1
#define OFFSET_BAL 2
#define OFFSET_BAH 3
#define OFFSET_WAL 4
#define OFFSET_WAH 5
#define OFFSET_BM  6
#define OFFSET_WM  7

// Commands
// 000x Enable/Disable single strpping
// 001x Enable/Disable breakpoints / watches
// 010x Load register
// 011x Reset
// 1000 Singe Step

#define CMD_SINGLE_ENABLE 0x00
#define CMD_BRKPT_ENABLE  0x02
#define CMD_LOAD_REG      0x04
#define CMD_RESET         0x06
#define CMD_STEP          0x08

// Control bits
#define CMD_MASK 0x1F
#define CMD_EDGE 0x10
#define MUX_SEL_MASK 0xE0
#define MUX_SEL_BIT 5

// Status bits
#define BRKPT_INTERRUPTED_MASK  0x40
#define BRKPT_ACTIVE_MASK  0x80

// Breakpoint Modes
#define BRKPT_INSTR 0x01
#define BRKPT_READ 0x02
#define BRKPT_WRITE 0x04

char *brkptStrings[8] = {
   "No breakpoint",
   "Instruction breakpoint",
   "Read breakpoint",
   "Instruction, read breakpoints",
   "Write breakpoint",
   "Instruction, write breakpoints",
   "Read, write breakpoints",
   "Instruction, read, write breakpoints"
};

#define VERSION "0.11"

#define NUMCMDS 14
#define MAXBKPTS 4

int numbkpts = 0;

int single;
long trace;
long instructions = 1;

unsigned int breakpoints[MAXBKPTS] = {
  0,
  0,
  0,
  0
};

unsigned int modes[MAXBKPTS] = {
  0,
  0,
  0,
  0
};


char *cmdStrings[NUMCMDS] = {
  "help",
  "reset",
  "interrupt",
  "address",
  "step",
  "trace",
  "blist",
  "breaki",
  "breakr",
  "breakw",
  "bcleari",
  "bclearr",
  "bclearw",
  "continue",
};

#define Delay_us(__us) \
    if((unsigned long) (F_CPU/1000000.0 * __us) != F_CPU/1000000.0 * __us)\
          __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000000.0 * __us)+1);\
    else __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000000.0 * __us))

#define Delay_ms(__ms) \
    if((unsigned long) (F_CPU/1000.0 * __ms) != F_CPU/1000.0 * __ms)\
          __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000.0 * __ms)+1);\
    else __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000.0 * __ms))

char message[32];
char command[32];

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
    } else {
      // Handle any other character
      Serial_TxByte0(c);
      cmd[i] = c;
      i++;
    }
  }
}

void hwCmd(unsigned int cmd, unsigned int param) {
  cmd |= param;
  CTRL_PORT &= ~CMD_MASK;
  CTRL_PORT |= cmd;
  Delay_us(2);
  CTRL_PORT |= CMD_EDGE;
  Delay_us(2);
}

unsigned int hwRead8(unsigned int offset) {
  CTRL_PORT &= ~MUX_SEL_MASK;
  CTRL_PORT |= offset << MUX_SEL_BIT;
  Delay_us(1);
  return MUX_DIN;
}

unsigned int hwRead16(unsigned int offset) {
  unsigned int lsb;
  CTRL_PORT &= ~MUX_SEL_MASK;
  CTRL_PORT |= offset << MUX_SEL_BIT;
  Delay_us(1);
  lsb = MUX_DIN;
  CTRL_PORT |= 1 << MUX_SEL_BIT;
  Delay_us(1);
  return (MUX_DIN << 8) | lsb;
}

void setSingle(int i) {
  single = i;
  hwCmd(CMD_SINGLE_ENABLE, single ? 1 : 0);
}

void setTrace(long i) {
  trace = i;
  if (trace) {
    log0("Tracing every %ld instructions while single stepping\n", trace);
  } else {
    log0("Tracing disabled\n");
  }
}

void version() {
  log0("Atom Bus Monitor version %s\n", VERSION);
  log0("Compiled at %s on %s\n",__TIME__,__DATE__);
}


void lcdAddr(unsigned int addr) {
  int i;
  int nibble;
  lcd_goto(6);
  // Avoid using sprintf, as it adds quite a lot of code
  for (i = 3; i >= 0; i--) {
    nibble = addr >> (i * 4);
    nibble &= 0x0F;
    nibble += '0';
    if (nibble > '9') {
      nibble += 'A' - '9' - 1;
    }
    lcd_putc(nibble);
  }

}

/*******************************************
 * Commands
 *******************************************/

void doCmdHelp(char *params) {
  int i;
  version();
  log0("Commands:\n");
  for (i = 0; i < NUMCMDS; i++) {
    log0("    %s\n", cmdStrings[i]);
  }
}

void doCmdAddr() {
  unsigned int i_addr = hwRead16(OFFSET_IAL);
  // Update the LCD display
  lcdAddr(i_addr);
  // Update the serial console
  log0("%04X %04X %02X\n", i_addr);
}


void doCmdAddrDetail() {
  unsigned int i_addr = hwRead16(OFFSET_IAL);
  unsigned int b_addr = hwRead16(OFFSET_BAL);
  unsigned int b_mode = hwRead8(OFFSET_BM);
  // Update the LCD display
  lcdAddr(i_addr);
  // Update the serial console
  log0("%s hit at %04X", brkptStrings[b_mode], i_addr);
  if (b_mode != BRKPT_INSTR) {
    log0(" accessing %04X", b_addr);
  }
  log0("\n");
}

void doCmdStep(char *params) {
  long i;
  long j;

  if (!single) {
    log0("Use the break command to stop the 6502\n");
    return;
  }

  sscanf(params, "%ld", &instructions);
  if (instructions <= 0) {
    log0("Number of instuctions must be positive\n");
    return;
  }

  log0("Stepping %ld instructions\n", instructions);
  
  j = trace;
  for (i = 1; i <= instructions; i++) {
    // Step the 6502
    hwCmd(CMD_STEP, 0);
    if (i == instructions || (trace && (--j == 0))) {
      Delay_us(10);
      doCmdAddr();
      j = trace;
    }
  }
}

void doCmdReset(char *params) {
  log0("Resetting 6502\n");
  hwCmd(CMD_RESET, 1);
  Delay_us(100);
  hwCmd(CMD_RESET, 0);
}

void doCmdInterrupt(char *params) {
  setSingle(1);
  doCmdAddr();
}


void doCmdTrace(char *params) {
  long i;
  sscanf(params, "%ld", &i);
  setTrace(i);
}
  
void doCmdBList(char *params) {
  int i;
  if (numbkpts) {
    for (i = 0; i < numbkpts; i++) {
      log0("%d: %04X %s\n", i, breakpoints[i], brkptStrings[modes[i]]);
    }
  } else {
      log0("No breakpoints set\n");
  }
}

void setBreakpoint(int i, int addr, int mode) {
  log0("%s set at %04X\n", brkptStrings[mode], addr);
  breakpoints[i] = addr;
  modes[i] = mode;
}

void doCmdBreak(char *params, unsigned int mode) {
  int i;
  unsigned int addr;
  sscanf(params, "%x", &addr);
  for (i = 0; i < numbkpts; i++) {
    if (breakpoints[i] == addr) {
      if (modes[i] & mode) {
	log0("%s already set at %04X\n", brkptStrings[mode], addr);
      } else {
	setBreakpoint(i, addr, modes[i] | mode);
      }
      doCmdBList(NULL);
      return;
    }
  }
  if (numbkpts == MAXBKPTS) {
    log0("All breakpoints are already set\n");
    doCmdBList(NULL);
    return;
  }
  numbkpts++;
  for (i = numbkpts - 2; i >= -1; i--) {
    if (i == -1 || breakpoints[i] < addr) {
      setBreakpoint(i + 1, addr, mode);
      doCmdBList(NULL);
      return;
    } else {
      breakpoints[i + 1] = breakpoints[i];
      modes[i + 1] = modes[i];
    }
  }
}

void doCmdBreakI(char *params) {
  doCmdBreak(params, BRKPT_INSTR);
}

void doCmdBreakR(char *params) {
  doCmdBreak(params, BRKPT_READ);
}

void doCmdBreakW(char *params) {
  doCmdBreak(params, BRKPT_WRITE);
}

void doCmdBClear(char *params, unsigned int mode) {
  int i;
  int n = 0;
  sscanf(params, "%x", &n);
  // First, look assume n is an address, and try to map to an index
  for (i = 0; i < numbkpts; i++) {
    if (breakpoints[i] == n) {
      n = i;
      break;
    }
  }
  if (n < numbkpts) {
    if (modes[n] & mode) {
      log0("Removing %s at %04X\n", brkptStrings[mode], breakpoints[n]);
      modes[n] &= ~mode;
      if (modes[n] == 0) {
	for (i = n; i < numbkpts; i++) {
	  breakpoints[i] = breakpoints[i + 1];
	  modes[i] = modes[i + 1];
	}
	numbkpts--;
      }
    } else {
      log0("%s not set at %04X\n", brkptStrings[mode], breakpoints[n]);
    }
  } else {
    log0("%s not set at %04X\n", brkptStrings[mode], n);
  }
  doCmdBList(NULL);
}

void doCmdBClearI(char *params) {
  doCmdBClear(params, BRKPT_INSTR);
}

void doCmdBClearR(char *params) {
  doCmdBClear(params, BRKPT_READ);
}

void doCmdBClearW(char *params) {
  doCmdBClear(params, BRKPT_WRITE);
}

void shiftBreakpointRegister(unsigned int addr, unsigned int mode) {
  int i;
  long reg = mode;
  reg <<= 16;
  reg |= addr;
  for (i = 0; i < 20; i++) {
    hwCmd(CMD_LOAD_REG, reg & 1);
    reg >>= 1;
  }
}

void doCmdContinue(char *params) {
  int i;
  int status;
  doCmdBList(NULL);

  // Disable breakpoints to allow loading
  hwCmd(CMD_BRKPT_ENABLE, 0);

  // Load breakpoints into comparators
  for (i = 0; i < numbkpts; i++) {
    shiftBreakpointRegister(breakpoints[i], modes[i]);
  }
  for (i = numbkpts; i < MAXBKPTS; i++) {
    shiftBreakpointRegister(0, 0);
  }

  // Enable breakpoints 
  hwCmd(CMD_BRKPT_ENABLE, 1);

  // Disable single stepping
  setSingle(0);

  // Wait for breakpoint to become active
  log0("6502 free running...\n");
  do {
    status = STATUS_DIN;
  } while (!(status & BRKPT_ACTIVE_MASK) && !(status && BRKPT_INTERRUPTED_MASK));

  // Output cause
  doCmdAddrDetail();

  // Enable single stepping
  setSingle(1);

  // Disable breakpoints
  hwCmd(CMD_BRKPT_ENABLE, 0);
}


void initialize() {
  CTRL_DDR = 255;
  STATUS_DDR = 0;
  MUX_DDR = 0;
  CTRL_PORT = 0;
  Serial_Init(57600,57600);
  lcd_init();
  lcd_puts("Addr: xxxx");
  version();
  hwCmd(CMD_RESET, 0);
  setSingle(1);
  setTrace(1);
  log0("6502 paused...\n");
  doCmdAddr();
}

void (*cmdFuncs[NUMCMDS])(char *params) = {
  doCmdHelp,
  doCmdReset,
  doCmdInterrupt,
  doCmdAddr,
  doCmdStep,
  doCmdTrace,
  doCmdBList,
  doCmdBreakI,
  doCmdBreakR,
  doCmdBreakW,
  doCmdBClearI,
  doCmdBClearR,
  doCmdBClearW,
  doCmdContinue
};


void dispatchCmd(char *cmd) {
  int i;
  char *cmdString;


  int minLen;
  int cmdStringLen;

  int cmdLen = 0;
  while (cmd[cmdLen] >= 'a' && cmd[cmdLen] <= 'z') {
    cmdLen++;
  }

  for (i = 0; i < NUMCMDS; i++) {
    cmdString = cmdStrings[i];
    cmdStringLen = strlen(cmdString);    
    minLen = cmdLen < cmdStringLen ? cmdLen : cmdStringLen;
    if (strncmp(cmdString, cmd, minLen) == 0) {
      (*cmdFuncs[i])(command + cmdLen);
      return;
    }
  }
  log0("Unknown command %s\n", cmd);
}

int main(void) {
  initialize();
  while (1) {
    readCmd(command);
    dispatchCmd(command);
  }
  return 0;
}



