#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <avr/pgmspace.h>

#include "hd44780.h"
#include "status.h"


#if (CPU == Z80)
#define NAME "ICE-T80"
#else
#define NAME "ICE-T65"
#endif

#ifdef CPUEMBEDDED

unsigned int disMem(unsigned int addr);

enum
{
  IMP, IMPA, MARK2, BRA, IMM, ZP, ZPX, ZPY, INDX, INDY, IND, MARK3, ABS, ABSX, ABSY, IND16, IND1X
};

enum
  {
    I_ADC,
    I_AND,
    I_ASL,
    I_BCC,
    I_BCS,
    I_BEQ,
    I_BIT,
    I_BMI,
    I_BNE,
    I_BPL,
    I_BRA,
    I_BRK,
    I_BVC,
    I_BVS,
    I_CLC,
    I_CLD,
    I_CLI,
    I_CLV,
    I_CMP,
    I_CPX,
    I_CPY,
    I_DEC,
    I_DEX,
    I_DEY,
    I_EOR,
    I_INC,
    I_INX,
    I_INY,
    I_JMP,
    I_JSR,
    I_LDA,
    I_LDX,
    I_LDY,
    I_LSR,
    I_NOP,
    I_ORA,
    I_PHA,
    I_PHP,
    I_PHX,
    I_PHY,
    I_PLA,
    I_PLP,
    I_PLX,
    I_PLY,
    I_ROL,
    I_ROR,
    I_RTI,
    I_RTS,
    I_SBC,
    I_SEC,
    I_SED,
    I_SEI,
    I_STA,
    I_STP,
    I_STX,
    I_STY,
    I_STZ,
    I_TAX,
    I_TAY,
    I_TRB,
    I_TSB,
    I_TSX,
    I_TXA,
    I_TXS,
    I_TYA,
    I_WAI,
    I_XXX
  };

char *opStrings[67] = {
    "ADC",
    "AND",
    "ASL",
    "BCC",
    "BCS",
    "BEQ",
    "BIT",
    "BMI",
    "BNE",
    "BPL",
    "BRA",
    "BRK",
    "BVC",
    "BVS",
    "CLC",
    "CLD",
    "CLI",
    "CLV",
    "CMP",
    "CPX",
    "CPY",
    "DEC",
    "DEX",
    "DEY",
    "EOR",
    "INC",
    "INX",
    "INY",
    "JMP",
    "JSR",
    "LDA",
    "LDX",
    "LDY",
    "LSR",
    "NOP",
    "ORA",
    "PHA",
    "PHP",
    "PHX",
    "PHY",
    "PLA",
    "PLP",
    "PLX",
    "PLY",
    "ROL",
    "ROR",
    "RTI",
    "RTS",
    "SBC",
    "SEC",
    "SED",
    "SEI",
    "STA",
    "STP",
    "STX",
    "STY",
    "STZ",
    "TAX",
    "TAY",
    "TRB",
    "TSB",
    "TSX",
    "TXA",
    "TXS",
    "TYA",
    "WAI",
    "---"
};

unsigned char dopname[256] =
{
/*00*/ I_BRK, I_ORA, I_XXX, I_XXX, I_TSB, I_ORA, I_ASL, I_XXX, I_PHP, I_ORA, I_ASL, I_XXX, I_TSB, I_ORA, I_ASL, I_XXX,
/*10*/ I_BPL, I_ORA, I_ORA, I_XXX, I_TRB, I_ORA, I_ASL, I_XXX, I_CLC, I_ORA, I_INC, I_XXX, I_TRB, I_ORA, I_ASL, I_XXX,
/*20*/ I_JSR, I_AND, I_XXX, I_XXX, I_BIT, I_AND, I_ROL, I_XXX, I_PLP, I_AND, I_ROL, I_XXX, I_BIT, I_AND, I_ROL, I_XXX,
/*30*/ I_BMI, I_AND, I_AND, I_XXX, I_BIT, I_AND, I_ROL, I_XXX, I_SEC, I_AND, I_DEC, I_XXX, I_BIT, I_AND, I_ROL, I_XXX,
/*40*/ I_RTI, I_EOR, I_XXX, I_XXX, I_XXX, I_EOR, I_LSR, I_XXX, I_PHA, I_EOR, I_LSR, I_XXX, I_JMP, I_EOR, I_LSR, I_XXX,
/*50*/ I_BVC, I_EOR, I_EOR, I_XXX, I_XXX, I_EOR, I_LSR, I_XXX, I_CLI, I_EOR, I_PHY, I_XXX, I_XXX, I_EOR, I_LSR, I_XXX,
/*60*/ I_RTS, I_ADC, I_XXX, I_XXX, I_STZ, I_ADC, I_ROR, I_XXX, I_PLA, I_ADC, I_ROR, I_XXX, I_JMP, I_ADC, I_ROR, I_XXX,
/*70*/ I_BVS, I_ADC, I_ADC, I_XXX, I_STZ, I_ADC, I_ROR, I_XXX, I_SEI, I_ADC, I_PLY, I_XXX, I_JMP, I_ADC, I_ROR, I_XXX,
/*80*/ I_BRA, I_STA, I_XXX, I_XXX, I_STY, I_STA, I_STX, I_XXX, I_DEY, I_BIT, I_TXA, I_XXX, I_STY, I_STA, I_STX, I_XXX,
/*90*/ I_BCC, I_STA, I_STA, I_XXX, I_STY, I_STA, I_STX, I_XXX, I_TYA, I_STA, I_TXS, I_XXX, I_STZ, I_STA, I_STZ, I_XXX,
/*A0*/ I_LDY, I_LDA, I_LDX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX, I_TAY, I_LDA, I_TAX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX,
/*B0*/ I_BCS, I_LDA, I_LDA, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX, I_CLV, I_LDA, I_TSX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX,
/*C0*/ I_CPY, I_CMP, I_XXX, I_XXX, I_CPY, I_CMP, I_DEC, I_XXX, I_INY, I_CMP, I_DEX, I_WAI, I_CPY, I_CMP, I_DEC, I_XXX,
/*D0*/ I_BNE, I_CMP, I_CMP, I_XXX, I_XXX, I_CMP, I_DEC, I_XXX, I_CLD, I_CMP, I_PHX, I_STP, I_XXX, I_CMP, I_DEC, I_XXX,
/*E0*/ I_CPX, I_SBC, I_XXX, I_XXX, I_CPX, I_SBC, I_INC, I_XXX, I_INX, I_SBC, I_NOP, I_XXX, I_CPX, I_SBC, I_INC, I_XXX,
/*F0*/ I_BEQ, I_SBC, I_SBC, I_XXX, I_XXX, I_SBC, I_INC, I_XXX, I_SED, I_SBC, I_PLX, I_XXX, I_XXX, I_SBC, I_INC, I_XXX
};

unsigned char dopaddr[256] =
{
/*00*/ IMP, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMPA,  IMP,  ABS,	  ABS,	 ABS,  IMP,
/*10*/ BRA, INDY,  IND, IMP,  ZP,   ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMPA,  IMP,  ABS,	  ABSX,	 ABSX, IMP,
/*20*/ ABS, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMPA,  IMP,  ABS,	  ABS,	 ABS,  IMP,
/*30*/ BRA, INDY,  IND, IMP,  ZPX,  ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMPA,  IMP,  ABSX,	  ABSX,	 ABSX, IMP,
/*40*/ IMP, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMPA,  IMP,  ABS,	  ABS,	 ABS,  IMP,
/*50*/ BRA, INDY,  IND, IMP,  ZP,   ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMP,   IMP,  ABS,	  ABSX,	 ABSX, IMP,
/*60*/ IMP, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMPA,  IMP,  IND16,  ABS,	 ABS,  IMP,
/*70*/ BRA, INDY,  IND, IMP,  ZPX,  ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMP,   IMP,  IND1X,  ABSX,	 ABSX, IMP,
/*80*/ BRA, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMP,   IMP,  ABS,	  ABS,	 ABS,  IMP,
/*90*/ BRA, INDY,  IND, IMP,  ZPX,  ZPX,   ZPY,	 IMP,	IMP,  ABSY,  IMP,   IMP,  ABS,	  ABSX,	 ABSX, IMP,
/*A0*/ IMM, INDX,  IMM, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMP,   IMP,  ABS,	  ABS,	 ABS,  IMP,
/*B0*/ BRA, INDY,  IND, IMP,  ZPX,  ZPX,   ZPY,	 IMP,	IMP,  ABSY,  IMP,   IMP,  ABSX,	  ABSX,	 ABSY, IMP,
/*C0*/ IMM, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMP,   IMP,  ABS,	  ABS,	 ABS,  IMP,
/*D0*/ BRA, INDY,  IND, IMP,  ZP,   ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMP,   IMP,  ABS,	  ABSX,	 ABSX, IMP,
/*E0*/ IMM, INDX,  IMP, IMP,  ZP,   ZP,	   ZP,	 IMP,	IMP,  IMM,   IMP,   IMP,  ABS,	  ABS,	 ABS,  IMP,
/*F0*/ BRA, INDY,  IND, IMP,  ZP,   ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMP,   IMP,  ABS,	  ABSX,	 ABSX, IMP
};
#endif

#define CRC_POLY 0x002d

#define CTRL_PORT      PORTB
#define CTRL_DDR       DDRB
#define CTRL_DIN       PINB

#define MUXSEL_PORT    PORTD

#define STATUS_PORT    PORTD
#define STATUS_DDR     DDRD
#define STATUS_DIN     PIND

#define MUX_PORT       PORTE
#define MUX_DDR        DDRE
#define MUX_DIN        PINE

// Hardware registers
#define OFFSET_IAL     0
#define OFFSET_IAH     1
#define OFFSET_DATA    2
#define OFFSET_CNTH    3
#define OFFSET_CNTL    4
#define OFFSET_CNTM    5

// Hardware fifo
#define OFFSET_BW_IAL  6
#define OFFSET_BW_IAH  7
#define OFFSET_BW_BAL  8
#define OFFSET_BW_BAH  9
#define OFFSET_BW_BD   10
#define OFFSET_BW_M    11
#define OFFSET_BW_CNTL 12
#define OFFSET_BW_CNTM 13
#define OFFSET_BW_CNTH 14

// Processor registers
#define OFFSET_REG_A   16
#define OFFSET_REG_X   17
#define OFFSET_REG_Y   18
#define OFFSET_REG_P   19
#define OFFSET_REG_SPL 20
#define OFFSET_REG_SPH 21
#define OFFSET_REG_PCL 22
#define OFFSET_REG_PCH 23

// Commands
// 000x Enable/Disable single strpping
// 001x Enable/Disable breakpoints / watches
// 010x Load register
// 011x Reset
// 1000 Singe Step

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

// Control bits
#define CMD_MASK          0x3F
#define CMD_EDGE          0x20
#define MUXSEL_MASK       0x1F
#define MUXSEL_BIT           0

// Status bits
#define INTERRUPTED_MASK  0x40
#define BW_ACTIVE_MASK    0x80

// Breakpoint Modes
#define BRKPT_EXEC  0
#define BRKPT_READ  1
#define BRKPT_WRITE 2
#define WATCH_EXEC  3
#define WATCH_READ  4
#define WATCH_WRITE 5
#define UNDEFINED   6

#define B_MASK  ((1<<BRKPT_READ) | (1<<BRKPT_WRITE) | (1<<BRKPT_EXEC))
#define W_MASK  ((1<<WATCH_READ) | (1<<WATCH_WRITE) | (1<<WATCH_EXEC))
#define B_MEM_MASK  ((1<<BRKPT_READ) | (1<<BRKPT_WRITE))
#define W_MEM_MASK  ((1<<BRKPT_WRITE) | (1<<WATCH_WRITE))
#define BW_MEM_MASK  ((1<<BRKPT_READ) | (1<<BRKPT_WRITE) | (1<<WATCH_READ) | (1<<WATCH_WRITE))

char *testNames[6] = {
  "Fixed",
  "Checkerboard",
  "Inverse checkerboard",
  "Address pattern",
  "Inverse address pattern",
  "Random"
};

char *modeStrings[7] = {
  "Ex Breakpoint",
  "Rn Breakpoint",
  "Wr Breakpoint",
  "Ex watch",
  "Rd watch",
  "Wr watch",
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


#define VERSION "0.41"

#ifdef CPUEMBEDDED
#define NUM_CMDS 27
#else
#define NUM_CMDS 19
#endif

#if (CPU == Z80)
#define MAXBKPTS 1
#else
#define MAXBKPTS 8
#endif

int numbkpts = 0;

long trace;
long instructions = 1;

unsigned int memAddr = 0;

char statusString[8] = "NV-BDIZC";

unsigned int breakpoints[MAXBKPTS] = {
#if (CPU != Z80)
  0,
  0,
  0,
  0,
  0,
  0,
  0,
#endif
  0
};

unsigned int masks[MAXBKPTS] = {
#if (CPU != Z80)
  0,
  0,
  0,
  0,
  0,
  0,
  0,
#endif
  0
};

unsigned int modes[MAXBKPTS] = {
#if (CPU != Z80)
  0,
  0,
  0,
  0,
  0,
  0,
  0,
#endif
  0
};

int triggers[MAXBKPTS] = {
#if (CPU != Z80)
  0,
  0,
  0,
  0,
  0,
  0,
  0,
#endif
  0
};


char *cmdStrings[NUM_CMDS] = {
  "help",
  "continue",
#ifdef CPUEMBEDDED
  "regs",
  "mem",
  "dis",
  "read",
  "write",
  "fill",
  "crc",
  "test",
#endif
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
  "trigger"
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
  MUXSEL_PORT &= ~MUXSEL_MASK;
  MUXSEL_PORT |= offset << MUXSEL_BIT;
  Delay_us(1);
  return MUX_DIN;
}

unsigned int hwRead16(unsigned int offset) {
  unsigned int lsb;
  MUXSEL_PORT &= ~MUXSEL_MASK;
  MUXSEL_PORT |= offset << MUXSEL_BIT;
  Delay_us(1);
  lsb = MUX_DIN;
  MUXSEL_PORT |= 1 << MUXSEL_BIT;
  Delay_us(1);
  return (MUX_DIN << 8) | lsb;
}

void setSingle(int single) {
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
#ifdef CPUEMBEDDED
  log0("%s In-Circuit Emulator version %s\n", NAME, VERSION);
#else
  log0("%s Bus Monitor version %s\n", NAME, VERSION);
#endif
  log0("Compiled at %s on %s\n",__TIME__,__DATE__);
  log0("%d watches/breakpoints implemented\n",MAXBKPTS);
}


#ifdef LCD
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
#endif

int lookupBreakpoint(char *params) {
  int i;
  int n = -1;
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


void logCycleCount(int offsetLow, int offsetHigh) {
  unsigned long count = (((unsigned long) hwRead8(offsetHigh)) << 16) | hwRead16(offsetLow); 
  unsigned long countSecs = count / 1000000;
  unsigned long countMicros = count % 1000000;
  log0("%02ld.%06ld: ", countSecs, countMicros);
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

void logTrigger(int trigger) {
  if (trigger >= 0 && trigger < NUM_TRIGGERS) {
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
  unsigned int watch = mode & 8;


  // Convert from 4-bit compressed to 6 bit expanded mode representation
  if (watch) {
    mode = (mode & 7) << 3;
  }
  // Update the serial console
  if (mode & W_MASK) {
    logCycleCount(OFFSET_BW_CNTL, OFFSET_BW_CNTH);
  }
  logMode(mode);
  log0(" hit at %04X", i_addr);
  if (mode & W_MEM_MASK) {
    log0(" writing");
  } else {
    log0(" reading");
  }
  log0(" %04X = %02X\n", b_addr, b_data);
  if (mode & B_MASK) {
    logCycleCount(OFFSET_BW_CNTL, OFFSET_BW_CNTH);
  }
#ifdef CPUEMBEDDED
  if (mode & B_MEM_MASK) {
    // It's only safe to do this for brkpts, as it makes memory accesses
    disMem(i_addr);
  }
#endif
  return watch;
}

#ifdef CPUEMBEDDED
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

unsigned int readByte() {
  hwCmd(CMD_RD_MEM, 0);
  Delay_us(10);
  return hwRead8(OFFSET_DATA);
}

unsigned int readByteInc() {
  hwCmd(CMD_RD_MEM_INC, 0);
  Delay_us(10);
  return hwRead8(OFFSET_DATA);
}

void writeByte() {
  hwCmd(CMD_WR_MEM, 0);
}

void writeByteInc() {
  hwCmd(CMD_WR_MEM_INC, 0);
}

unsigned int disassemble(unsigned int addr)
{
	unsigned int temp;
	unsigned int op = readByteInc();
        int mode = dopaddr[op];
	unsigned int p1 = (mode > MARK2) ? readByteInc() : 0;
	unsigned int p2 = (mode > MARK3) ? readByteInc() : 0;

	log0("%04X : %s ", addr, opStrings[dopname[op]]);
	switch (mode)
	{
	case IMP:
		log0("        ");
		break;
	case IMPA:
		log0("A       ");
		break;
	case BRA:
		temp = addr + 2 + (signed char)p1;
		log0("%04X    ", temp);
		addr++;
		break;
	case IMM:
		log0("#%02X     ", p1);
		addr++;
		break;
	case ZP:
		log0("%02X      ", p1);
		addr++;
		break;
	case ZPX:
		log0("%02X,X    ", p1);
		addr++;
		break;
	case ZPY:
		log0("%02X,Y    ", p1);
		addr++;
		break;
	case IND:
		log0("(%02X)    ", p1);
		addr++;
		break;
	case INDX:
		log0("(%02X,X)  ", p1);
		addr++;
		break;
	case INDY:
		log0("(%02X),Y  ", p1);
		addr++;
		break;
	case ABS:
		log0("%02X%02X    ", p2, p1);
		addr += 2;
		break;
	case ABSX:
		log0("%02X%02X,X  ", p2, p1);
		addr += 2;
		break;
	case ABSY:
		log0("%02X%02X,Y  ", p2, p1);
		addr += 2;
		break;
	case IND16:
		log0("(%02X%02X)  ", p2, p1);
		addr += 2;
		break;
	case IND1X:
		log0("(%02X%02X,X)", p2, p1);
		addr += 2;
		break;
	}
	log0("\n");
	addr++;
	return addr;
}

unsigned int disMem(unsigned int addr) {
  loadAddr(addr);
  return disassemble(addr);

}
#endif

void logAddr() {
  memAddr = hwRead16(OFFSET_IAL);
  // Update the LCD display
#ifdef LCD
  lcdAddr(memAddr);
#endif
  // Update the serial console
  logCycleCount(OFFSET_CNTL, OFFSET_CNTH);
#ifdef CPUEMBEDDED
  //log0("%04X\n", i_addr);
  disMem(memAddr);
#else
  log0("%04X\n", memAddr);
#endif
  return;
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
}


void doCmdStep(char *params) {
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
    if (i == instructions || (trace && (--j == 0))) {
      Delay_us(10);
      logAddr();
      j = trace;
    }
  }
}

void doCmdReset(char *params) {
  log0("Resetting CPU\n");
  hwCmd(CMD_RESET, 1);
  Delay_us(50);
  hwCmd(CMD_STEP, 0);
  Delay_us(50);
  hwCmd(CMD_RESET, 0);
}

#ifdef CPUEMBEDDED
void doCmdRegs(char *params) {
  int i;
  log0("CPU Registers:\n");
  log0("  A=%02X X=%02X Y=%02X SP=%04X PC=%04X\n",
       hwRead8(OFFSET_REG_A),
       hwRead8(OFFSET_REG_X),
       hwRead8(OFFSET_REG_Y),
       hwRead16(OFFSET_REG_SPL),
       hwRead16(OFFSET_REG_PCL));
  unsigned int p = hwRead8(OFFSET_REG_P);
  char *sp = statusString;
  log0("  P=%02X ", p);
  for (i = 0; i <= 7; i++) {
    log0("%c",  ((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  log0("\n");
}

void doCmdMem(char *params) {
  int i, j;
  unsigned int row[16];
  sscanf(params, "%x", &memAddr);
  loadAddr(memAddr);
  for (i = 0; i < 0x100; i+= 16) {
    for (j = 0; j < 16; j++) {
      row[j] = readByteInc();
    }
    log0("%04X ", memAddr + i);
    for (j = 0; j < 16; j++) {
      log0("%02X ", row[j]);
    }
    log0(" ");
    for (j = 0; j < 16; j++) {
      unsigned int c = row[j];
      if (c < 32 || c > 126) {
	c = '.';
      }
      log0("%c", c);
    }
    log0("\n");
  }
  memAddr += 0x100;
}

void doCmdDis(char *params) {
  int i;
  sscanf(params, "%x", &memAddr);
  loadAddr(memAddr);
  for (i = 0; i < 10; i++) {
    memAddr = disassemble(memAddr);
  }
}

void doCmdWrite(char *params) {
  unsigned int addr;
  unsigned int data;
  long count = 1;
  sscanf(params, "%x %x %ld", &addr, &data, &count);
  log0("Wr: %04X = %X\n", addr, data);
  loadData(data);
  loadAddr(addr);
  while (count-- > 0) {
    writeByte();
  }
}

void doCmdRead(char *params) {
  unsigned int addr;
  unsigned int data;
  unsigned int data2;
  long count = 1;
  sscanf(params, "%x %ld", &addr, &count);
  loadAddr(addr);
  data = readByte();
  log0("Rd: %04X = %X\n", addr, data);
  while (count-- > 1) {
    data2 = readByte();
    if (data2 != data) {
      log0("Inconsistent Rd: %02X <> %02X\n", data2, data);
    }
    data = data2;
  }
}

void doCmdFill(char *params) {
  long i;
  unsigned int start;
  unsigned int end;
  unsigned int data;
  sscanf(params, "%x %x %x", &start, &end, &data);
  log0("Wr: %04X to %04X = %X\n", start, end, data);
  loadData(data);
  loadAddr(start);
  for (i = start; i <= end; i++) {
    writeByteInc();
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
    data = readByteInc();
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
    writeByteInc();
  }
  // Read
  srand(data);
  loadAddr(start);
  for (i = start; i <= end; i++) {
    actual = readByteInc();
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

#endif

void doCmdTrace(char *params) {
  long i;
  sscanf(params, "%ld", &i);
  setTrace(i);
}
  
void doCmdBList(char *params) {
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

void setBreakpoint(int i, unsigned int addr, unsigned int mask, unsigned int mode, int trigger) {
  logMode(mode);
  log0(" set at %04X\n", addr);
  breakpoints[i] = addr & mask;
  masks[i] = mask;
  modes[i] = mode;
  triggers[i] = trigger;
}

void doCmdBreak(char *params, unsigned int mode) {
  int i;
  unsigned int addr;
  unsigned int mask = 0xFFFF;
  int trigger = -1;
  sscanf(params, "%x %x %x", &addr, &mask, &trigger);
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
	setBreakpoint(i, addr, mask, modes[i] | mode, trigger);
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
      setBreakpoint(i + 1, addr, mask, mode, trigger);
      return;
    } else {
      breakpoints[i + 1] = breakpoints[i];
      masks[i + 1] = masks[i];
      modes[i + 1] = modes[i];
      triggers[i + 1] = triggers[i];
    }
  }
}

void doCmdBreakI(char *params) {
  doCmdBreak(params, 1 << BRKPT_EXEC);
}

void doCmdBreakR(char *params) {
  doCmdBreak(params, 1 << BRKPT_READ);
}

void doCmdBreakW(char *params) {
  doCmdBreak(params, 1 << BRKPT_WRITE);
}

void doCmdWatchI(char *params) {
  doCmdBreak(params, 1 << WATCH_EXEC);
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
        masks[i] = masks[i + 1];
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
  doCmdBClear(params, 1 << BRKPT_EXEC);
}

void doCmdBClearR(char *params) {
  doCmdBClear(params, 1 << BRKPT_READ);
}

void doCmdBClearW(char *params) {
  doCmdBClear(params, 1 << BRKPT_WRITE);
}

void doCmdWClearI(char *params) {
  doCmdBClear(params, 1 << WATCH_EXEC);
}

void doCmdWClearR(char *params) {
  doCmdBClear(params, 1 << WATCH_READ);
}

void doCmdWClearW(char *params) {
  doCmdBClear(params, 1 << WATCH_WRITE);
}

void doCmdTrigger(char *params) {
  int trigger = -1;
  int n = lookupBreakpoint(params);
  if (n < 0) {
    log0("Trigger Codes:\n");
    for (trigger = 0; trigger < NUM_TRIGGERS; trigger++) {
      log0("    %X = %s\n", trigger, triggerStrings[trigger]);
    }
    return;
  }
  sscanf(params, "%*x %x", &trigger);
  if (trigger >= 0 && trigger < NUM_TRIGGERS) {
    triggers[n] = trigger;
  } else {
    log0("Illegal trigger code (see help for trigger codes)\n"); 
  }
}

void shiftBreakpointRegister(unsigned int addr, unsigned int mask, unsigned int mode, int trigger) {
  int i;
  for (i = 0; i <= 15; i++) {
    hwCmd(CMD_LOAD_BRKPT, addr & 1);
    addr >>= 1;
  }
  for (i = 0; i <= 15; i++) {
    hwCmd(CMD_LOAD_BRKPT, mask & 1);
    mask >>= 1;
  }
  for (i = 0; i <= 5; i++) {
    hwCmd(CMD_LOAD_BRKPT, mode & 1);
    mode >>= 1;
  }
  for (i = 0; i <= 3; i++) {
    hwCmd(CMD_LOAD_BRKPT, trigger & 1);
    trigger >>= 1;
  }
}

void doCmdContinue(char *params) {
  int i;
  int status;
#ifdef LCD
  unsigned int i_addr;
#endif
  int reset = 0;
  sscanf(params, "%d", &reset);
  
  // Disable breakpoints to allow loading
  hwCmd(CMD_BRKPT_ENABLE, 0);

  // Load breakpoints into comparators
  for (i = 0; i < numbkpts; i++) {
    shiftBreakpointRegister(breakpoints[i], masks[i], modes[i], triggers[i]);
  }
  for (i = numbkpts; i < MAXBKPTS; i++) {
    shiftBreakpointRegister(0, 0, 0, 0);
  }

  // Step the 6502, otherwise the breakpoint happends again immediately
  hwCmd(CMD_STEP, 0);

  // Enable breakpoints 
  hwCmd(CMD_BRKPT_ENABLE, 1);

  // Disable single stepping
  setSingle(0);

  // Reset if required
  if (reset) {
    log0("Resetting CPU\n");
    hwCmd(CMD_RESET, 1);
    Delay_us(100);
    hwCmd(CMD_RESET, 0);
  }

  // Wait for breakpoint to become active
  log0("CPU free running...\n");
  int cont = 1;
  do {
    // Update the LCD display
#ifdef LCD
    i_addr = hwRead16(OFFSET_IAL);
    lcdAddr(i_addr);
#endif

    status = STATUS_DIN;
    if (status & BW_ACTIVE_MASK) {
      cont = logDetails();
      hwCmd(CMD_WATCH_READ, 0);
    }
    if (status & INTERRUPTED_MASK || Serial_ByteRecieved0()) {
      log0("Interrupted\n");
      cont = 0;
    }
    Delay_us(10);
  } while (cont);

  // Junk the interrupt character
  if (Serial_ByteRecieved0()) {
    Serial_RxByte0();
  }

  // Enable single stepping
  setSingle(1);

  // Disable breakpoints
  hwCmd(CMD_BRKPT_ENABLE, 0);

  // Show current instruction
  logAddr();
}

void initialize() {
  CTRL_DDR = 255;
  STATUS_DDR = MUXSEL_MASK;
  MUX_DDR = 0;
  CTRL_PORT = 0;
  Serial_Init(57600,57600);
#ifdef LCD
  lcd_init();
  lcd_puts("Addr: xxxx");
#endif
  version();
  hwCmd(CMD_RESET, 0);
  hwCmd(CMD_FIFO_RST, 0);
  setSingle(1);
  setTrace(1);
}

void (*cmdFuncs[NUM_CMDS])(char *params) = {
  doCmdHelp,
  doCmdContinue,
#ifdef CPUEMBEDDED
  doCmdRegs,
  doCmdMem,
  doCmdDis,
  doCmdRead,
  doCmdWrite,
  doCmdFill,
  doCmdCrc,
  doCmdTest,
#endif
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
  doCmdTrigger
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
