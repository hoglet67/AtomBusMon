#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <avr/pgmspace.h>

#include "hd44780.h"
#include "status.h"

#define CTRL_PORT     PORTB
#define CTRL_DDR      DDRB
#define CTRL_DIN      PINB

#define STATUS_PORT   PORTD
#define STATUS_DDR    DDRD
#define STATUS_DIN    PIND

#define MUX_PORT      PORTE
#define MUX_DDR       DDRE
#define MUX_DIN       PINE

#define OFFSET_IAL    0
#define OFFSET_IAH    1
#define OFFSET_BW_IAL 2
#define OFFSET_BW_IAH 3
#define OFFSET_BW_BAL 4
#define OFFSET_BW_BAH 5
#define OFFSET_BW_M   6

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
#define CMD_WATCH_READ    0x09
#define CMD_FIFO_RST      0x0A

// Control bits
#define CMD_MASK          0x1F
#define CMD_EDGE          0x10
#define MUX_SEL_MASK      0xE0
#define MUX_SEL_BIT          5

// Status bits
#define INTERRUPTED_MASK  0x40
#define BW_ACTIVE_MASK    0x80

// Breakpoint Modes
#define BRKPT_INSTR 0
#define BRKPT_READ  1
#define BRKPT_WRITE 2
#define WATCH_INSTR 3
#define WATCH_READ  4
#define WATCH_WRITE 5
#define UNDEFINED   6

#define BW_MEM_MASK  ((1<<BRKPT_READ) | (1<<BRKPT_WRITE) | (1<<WATCH_READ) | (1<<WATCH_WRITE))

char *modeStrings[7] = {
  "Instruction breakpoint",
  "Read breakpoint",
  "Write breakpoint",
  "Instruction watch",
  "Read watch",
  "Write watch",
  "Undefined"
};

#define NUM_TRIGGERS 16
#define TRIGGER_ALWAYS 15

char *triggerStrings[NUM_TRIGGERS] = {
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


#define VERSION "0.22"

#define NUM_CMDS 19
#define MAXBKPTS 8

int numbkpts = 0;

int single;
long trace;
long instructions = 1;

unsigned int breakpoints[MAXBKPTS] = {
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
};

unsigned int modes[MAXBKPTS] = {
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
};

unsigned int triggers[MAXBKPTS] = {
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
};


char *cmdStrings[NUM_CMDS] = {
  "help",
  "reset",
  "step",
  "trace",
  "blist",
  "breaki",
  "breakr",
  "breakw",
  "watchi",
  "watchr",
  "watchw",
  "bcleari",
  "bclearr",
  "bclearw",
  "wcleari",
  "wclearr",
  "wclearw",
  "trigger",
  "continue"
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

void logMode(unsigned int mode) {
  int i;
  int first = 1;
  for (i = 0; i < UNDEFINED; i++) {
    if (mode & 1) {
      if (first) {
	log0("%s", modeStrings[i]);
      } else {
	log0(", %c%s", tolower(*modeStrings[i]), modeStrings[i] + 1);
      }
      first = 0;
    }
    mode >>= 1;
  }
}

void logTrigger(unsigned int trigger) {
  if (trigger >= 0 && trigger < NUM_TRIGGERS) {
    log0("trigger: %s", triggerStrings[trigger]);
  } else {
    log0("trigger: ILLEGAL");
  }
}

int logDetails() {
  unsigned int i_addr = hwRead16(OFFSET_BW_IAL);
  unsigned int b_addr = hwRead16(OFFSET_BW_BAL);
  unsigned int mode   = hwRead8(OFFSET_BW_M);
  unsigned int watch = mode & 8;
  // Convert from 4-bit compressed to 6 bit expanded mode representation
  if (watch) {
    mode = (mode & 7) << 3;
  }
  // Update the serial console
  logMode(mode);
  log0(" hit at %04X", i_addr);
  if (mode & BW_MEM_MASK) {
    log0(" accessing %04X", b_addr);
  }
  log0("\n");
  return watch;
}

int lookupBreakpoint(char *params) {
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
    return n;
  }
  log0("Breakpoint/watch not set at %04X\n", n);
  return -1;
}


/*******************************************
 * Commands
 *******************************************/

void doCmdHelp(char *params) {
  int i;
  version();
  log0("Commands:\n");
  for (i = 0; i < NUM_CMDS; i++) {
    log0("    %s\n", cmdStrings[i]);
  }
  log0("Trigger Codes:\n");
  for (i = 0; i < NUM_TRIGGERS; i++) {
    log0("    %X = %s\n", i, triggerStrings[i]);
  }
}

void doCmdAddr() {
  unsigned int i_addr = hwRead16(OFFSET_IAL);
  // Update the LCD display
  lcdAddr(i_addr);
  // Update the serial console
  log0("%04X\n", i_addr);
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

void doCmdTrace(char *params) {
  long i;
  sscanf(params, "%ld", &i);
  setTrace(i);
}
  
void doCmdBList(char *params) {
  int i;
  if (numbkpts) {
    for (i = 0; i < numbkpts; i++) {
      log0("%d: %04X: ", i, breakpoints[i]);
      logMode(modes[i]);
      log0(" (");
      logTrigger(triggers[i]);
      log0(")\n");
    }
  } else {
      log0("No breakpoints set\n");
  }
}

void setBreakpoint(int i, unsigned int addr, unsigned int mode, unsigned int trigger) {
  logMode(mode);
  log0(" set at %04X\n", addr);
  breakpoints[i] = addr;
  modes[i] = mode;
  triggers[i] = trigger;
}

void doCmdBreak(char *params, unsigned int mode) {
  int i;
  unsigned int addr;
  unsigned int trigger = -1;
  sscanf(params, "%x %x", &addr, &trigger);
  for (i = 0; i < numbkpts; i++) {
    if (breakpoints[i] == addr) {
      if (modes[i] & mode) {
	logMode(mode);
	log0(" already set at %04X\n", addr);
      } else {
	// Preserve the existing trigger, unless it is overridden
	if (trigger == -1) {
	  trigger = triggers[i];
	}
	setBreakpoint(i, addr, modes[i] | mode, trigger);
      }
      return;
    }
  }
  if (numbkpts == MAXBKPTS) {
    log0("All %d breakpoints are already set\n", numbkpts);
    return;
  }
  numbkpts++;
  // New breakpoint, so if trigger not specified, set to ALWAYS
  if (trigger == -1) {
    trigger = TRIGGER_ALWAYS;
  }
  for (i = numbkpts - 2; i >= -1; i--) {
    if (i == -1 || breakpoints[i] < addr) {
      setBreakpoint(i + 1, addr, mode, trigger);
      return;
    } else {
      breakpoints[i + 1] = breakpoints[i];
      modes[i + 1] = modes[i];
      triggers[i + 1] = triggers[i];
    }
  }
}

void doCmdBreakI(char *params) {
  doCmdBreak(params, 1 << BRKPT_INSTR);
}

void doCmdBreakR(char *params) {
  doCmdBreak(params, 1 << BRKPT_READ);
}

void doCmdBreakW(char *params) {
  doCmdBreak(params, 1 << BRKPT_WRITE);
}

void doCmdWatchI(char *params) {
  doCmdBreak(params, 1 << WATCH_INSTR);
}

void doCmdWatchR(char *params) {
  doCmdBreak(params, 1 << WATCH_READ);
}

void doCmdWatchW(char *params) {
  doCmdBreak(params, 1 << WATCH_WRITE);
}

void doCmdBClear(char *params, unsigned int mode) {
  int i;
  int n = lookupBreakpoint(params);
  if (n < 0) {
    return;
  }
  if (modes[n] & mode) {
    log0("Removing ");
    logMode(mode);
    log0(" at %04X\n", breakpoints[n]);
    modes[n] &= ~mode;
    if (modes[n] == 0) {
      for (i = n; i < numbkpts; i++) {
	breakpoints[i] = breakpoints[i + 1];
	modes[i] = modes[i + 1];
	triggers[i] = triggers[i + 1];
      }
      numbkpts--;
    }
  } else {
    logMode(mode);
    log0(" not set at %04X\n", breakpoints[n]);
  }
}

void doCmdBClearI(char *params) {
  doCmdBClear(params, 1 << BRKPT_INSTR);
}

void doCmdBClearR(char *params) {
  doCmdBClear(params, 1 << BRKPT_READ);
}

void doCmdBClearW(char *params) {
  doCmdBClear(params, 1 << BRKPT_WRITE);
}

void doCmdWClearI(char *params) {
  doCmdBClear(params, 1 << WATCH_INSTR);
}

void doCmdWClearR(char *params) {
  doCmdBClear(params, 1 << WATCH_READ);
}

void doCmdWClearW(char *params) {
  doCmdBClear(params, 1 << WATCH_WRITE);
}

void doCmdTrigger(char *params) {
  unsigned int trigger = -1;
  int n = lookupBreakpoint(params);
  if (n < 0) {
    return;
  }
  sscanf(params, "%*x %x", &trigger);
  if (trigger >= 0 && trigger < NUM_TRIGGERS) {
    triggers[n] = trigger;
  } else {
    log0("Illegal trigger code (see help for trigger codes)\n"); 
  }
}

void shiftBreakpointRegister(unsigned int addr, unsigned int mode, unsigned int trigger) {
  int i;
  // Trigger is 4 bits
  long reg = trigger;
  // Mode is 6 bits
  reg <<= 6;
  reg |= mode;
  // Address is 16 bits
  reg <<= 16;
  reg |= addr;
  // Total size is 26 bits
  for (i = 0; i <= 25; i++) {
    hwCmd(CMD_LOAD_REG, reg & 1);
    reg >>= 1;
  }
}

void doCmdContinue(char *params) {
  int i;
  int status;
  unsigned int i_addr;

  // Step the 6502, otherwise the breakpoint happends again immediately
  hwCmd(CMD_STEP, 0);

  // Disable breakpoints to allow loading
  hwCmd(CMD_BRKPT_ENABLE, 0);

  // Load breakpoints into comparators
  for (i = 0; i < numbkpts; i++) {
    shiftBreakpointRegister(breakpoints[i], modes[i], triggers[i]);
  }
  for (i = numbkpts; i < MAXBKPTS; i++) {
    shiftBreakpointRegister(0, 0, 0);
  }

  // Enable breakpoints 
  hwCmd(CMD_BRKPT_ENABLE, 1);

  // Disable single stepping
  setSingle(0);

  // Wait for breakpoint to become active
  log0("6502 free running...\n");
  int cont = 1;
  do {
    // Update the LCD display
    i_addr = hwRead16(OFFSET_IAL);
    lcdAddr(i_addr);

    status = STATUS_DIN;
    if (status & BW_ACTIVE_MASK) {
      cont = logDetails();
      hwCmd(CMD_WATCH_READ, 0);
    }
    if (status & INTERRUPTED_MASK) {
      log0("Interrupted at ");
      doCmdAddr();
      cont = 0;
    }
    Delay_us(10);
  } while (cont);

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
  hwCmd(CMD_FIFO_RST, 0);
  setSingle(1);
  setTrace(1);
}

void (*cmdFuncs[NUM_CMDS])(char *params) = {
  doCmdHelp,
  doCmdReset,
  doCmdStep,
  doCmdTrace,
  doCmdBList,
  doCmdBreakI,
  doCmdBreakR,
  doCmdBreakW,
  doCmdWatchI,
  doCmdWatchR,
  doCmdWatchW,
  doCmdBClearI,
  doCmdBClearR,
  doCmdBClearW,
  doCmdWClearI,
  doCmdWClearR,
  doCmdWClearW,
  doCmdTrigger,
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
  for (i = 0; i < NUM_CMDS; i++) {
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
  doCmdContinue(NULL);
  while (1) {
    readCmd(command);
    dispatchCmd(command);
  }
  return 0;
}
