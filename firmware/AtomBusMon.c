#include <stdio.h>
#include <string.h>
#include <avr/pgmspace.h>

#include "hd44780.h"
#include "status.h"

#define CTRL_PORT PORTB
#define CTRL_DDR  DDRB
#define STEP_MASK 0x01
#define SINGLE_MASK 0x02
#define RESET_MASK 0x04
#define CTRL_MASK (SINGLE_MASK | STEP_MASK | RESET_MASK)

#define AL_PORT PORTD
#define AL_DIN  PIND
#define AL_MASK 0x00
#define AL_DDR  DDRD

#define AH_PORT PORTE
#define AH_DIN  PINE
#define AH_MASK 0x00
#define AH_DDR  DDRE

#define VERSION "0.10"

#define NUMCMDS 10
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

char *cmdStrings[NUMCMDS] = {
  "help",
  "reset",
  "break",
  "continue",
  "address",
  "step",
  "trace",
  "blist",
  "bset",
  "bclear"
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

void setSingle(int i) {
  single = i;
  if (single) {
    CTRL_PORT |= SINGLE_MASK;
    log0("Single stepping enabled\n");
  } else {
    CTRL_PORT &= ~SINGLE_MASK;
    log0("Single stepping disabled\n");
  }
}

void setTrace(long i) {
  trace = i;
  if (trace) {
    log0("Tracing every %ld instructions\n", trace);
  } else {
    log0("Tracing disabled\n");
  }
}


/*******************************************
 * Commands
 *******************************************/

void notImplemented() {
  log0("Not implemented\n");
}

void doCmdHelp(char *params) {
  int i;
  log0("Atom Bus Monitor version %s\n", VERSION);
  log0("Commands:\n");
  for (i = 0; i < NUMCMDS; i++) {
    log0("    %s\n", cmdStrings[i]);
  }
}

void doCmdAddr() {
  unsigned int addr = AH_DIN << 8 | AL_DIN;
  sprintf(message, "%04X", addr);
  lcd_goto(6);
  lcd_puts(message);
  log0("%s\n", message);
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
    CTRL_PORT &= ~STEP_MASK;
    Delay_us(1);
    CTRL_PORT |= STEP_MASK;
    Delay_us(1);
    if (i == instructions || (trace && (--j == 0))) {
      doCmdAddr();
      j = trace;
    }
  }
}

void doCmdReset(char *params) {
  log0("Resetting 6502\n");
  CTRL_PORT |= RESET_MASK;
  Delay_us(100);
  CTRL_PORT &= ~RESET_MASK;
}

void doCmdBreak(char *params) {
  setSingle(true);
  doCmdAddr();
}

void doCmdContinue(char *params) {
  setSingle(false);
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
      log0("%d: %04X\n", i, breakpoints[i]);
    }
  } else {
      log0("No breakpoints set\n");
  }
}

void doCmdBSet(char *params) {
  int i;
  unsigned int addr;
  sscanf(params, "%x", &addr);
  if (numbkpts == MAXBKPTS) {
    log0("All breakpoints are already set\n");
    doCmdBList(NULL);
    return;
  }
  numbkpts++;
  for (i = numbkpts - 2; i >= -1; i--) {
    if (i == -1 || breakpoints[i] < addr) {
      log0("Setting breakpoint at %04X\n", addr);
      breakpoints[i + 1] = addr;
      doCmdBList(NULL);
      return;
    } else if (breakpoints[i] == addr) {
      log0("Breakpoint already set at %04X\n", addr);
      doCmdBList(NULL);
      return;
    } else {
      breakpoints[i + 1] = breakpoints[i];
    }
  }
}

void doCmdBClear(char *params) {
  int i;
  int n;
  sscanf(params, "%d", &n);
  if (n >= numbkpts) {
    log0("Breakpoint %d not set\n", n);
  } else {
    log0("Removing breakpoint at %04X\n", breakpoints[n]);
    for (i = n; i < numbkpts; i++) {
      breakpoints[i] = breakpoints[i + 1];
    }
    numbkpts--;
  }
  doCmdBList(NULL);
}

void initialize() {
  CTRL_DDR = CTRL_MASK;
  AL_DDR  = AL_MASK;
  AH_DDR  = AH_MASK;
  CTRL_PORT &= ~STEP_MASK;
  Serial_Init(57600,57600);
  lcd_init();
  lcd_puts("Addr: xxxx");
  log0("Atom Bus Monitor\n");
  setSingle(false);
  setTrace(0);
}

void (*cmdFuncs[NUMCMDS])(char *params) = {
  doCmdHelp,
  doCmdReset,
  doCmdBreak,
  doCmdContinue,
  doCmdAddr,
  doCmdStep,
  doCmdTrace,
  doCmdBList,
  doCmdBSet,
  doCmdBClear
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



