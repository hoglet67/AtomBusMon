#include <avr/pgmspace.h>
#include "AtomBusMon.h"

enum
  {
    IMP, IMPA, MARK2, BRA, IMM, ZP, ZPX, ZPY, INDX, INDY, MARK3, ABS, ABSX, ABSY, IND16
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
    I_PLA,
    I_PLP,
    I_ROL,
    I_ROR,
    I_RTI,
    I_RTS,
    I_SBC,
    I_SEC,
    I_SED,
    I_SEI,
    I_STA,
    I_STX,
    I_STY,
    I_TAX,
    I_TAY,
    I_TSX,
    I_TXA,
    I_TXS,
    I_TYA,
    I_XXX
  };

static const char opString[] PROGMEM = "\
ADC\
AND\
ASL\
BCC\
BCS\
BEQ\
BIT\
BMI\
BNE\
BPL\
BRK\
BVC\
BVS\
CLC\
CLD\
CLI\
CLV\
CMP\
CPX\
CPY\
DEC\
DEX\
DEY\
EOR\
INC\
INX\
INY\
JMP\
JSR\
LDA\
LDX\
LDY\
LSR\
NOP\
ORA\
PHA\
PHP\
PLA\
PLP\
ROL\
ROR\
RTI\
RTS\
SBC\
SEC\
SED\
SEI\
STA\
STX\
STY\
TAX\
TAY\
TSX\
TXA\
TXS\
TYA\
---\
";

static const unsigned char dopname[256] PROGMEM =
{
/*00*/ I_BRK, I_ORA, I_XXX, I_XXX, I_XXX, I_ORA, I_ASL, I_XXX, I_PHP, I_ORA, I_ASL, I_XXX, I_XXX, I_ORA, I_ASL, I_XXX,
/*10*/ I_BPL, I_ORA, I_XXX, I_XXX, I_XXX, I_ORA, I_ASL, I_XXX, I_CLC, I_ORA, I_XXX, I_XXX, I_XXX, I_ORA, I_ASL, I_XXX,
/*20*/ I_JSR, I_AND, I_XXX, I_XXX, I_BIT, I_AND, I_ROL, I_XXX, I_PLP, I_AND, I_ROL, I_XXX, I_BIT, I_AND, I_ROL, I_XXX,
/*30*/ I_BMI, I_AND, I_XXX, I_XXX, I_XXX, I_AND, I_ROL, I_XXX, I_SEC, I_AND, I_XXX, I_XXX, I_XXX, I_AND, I_ROL, I_XXX,
/*40*/ I_RTI, I_EOR, I_XXX, I_XXX, I_XXX, I_EOR, I_LSR, I_XXX, I_PHA, I_EOR, I_LSR, I_XXX, I_JMP, I_EOR, I_LSR, I_XXX,
/*50*/ I_BVC, I_EOR, I_XXX, I_XXX, I_XXX, I_EOR, I_LSR, I_XXX, I_CLI, I_EOR, I_XXX, I_XXX, I_XXX, I_EOR, I_LSR, I_XXX,
/*60*/ I_RTS, I_ADC, I_XXX, I_XXX, I_XXX, I_ADC, I_ROR, I_XXX, I_PLA, I_ADC, I_ROR, I_XXX, I_JMP, I_ADC, I_ROR, I_XXX,
/*70*/ I_BVS, I_ADC, I_XXX, I_XXX, I_XXX, I_ADC, I_ROR, I_XXX, I_SEI, I_ADC, I_XXX, I_XXX, I_XXX, I_ADC, I_ROR, I_XXX,
/*80*/ I_XXX, I_STA, I_XXX, I_XXX, I_STY, I_STA, I_STX, I_XXX, I_DEY, I_XXX, I_TXA, I_XXX, I_STY, I_STA, I_STX, I_XXX,
/*90*/ I_BCC, I_STA, I_XXX, I_XXX, I_STY, I_STA, I_STX, I_XXX, I_TYA, I_STA, I_TXS, I_XXX, I_XXX, I_STA, I_XXX, I_XXX,
/*A0*/ I_LDY, I_LDA, I_LDX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX, I_TAY, I_LDA, I_TAX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX,
/*B0*/ I_BCS, I_LDA, I_XXX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX, I_CLV, I_LDA, I_TSX, I_XXX, I_LDY, I_LDA, I_LDX, I_XXX,
/*C0*/ I_CPY, I_CMP, I_XXX, I_XXX, I_CPY, I_CMP, I_DEC, I_XXX, I_INY, I_CMP, I_DEX, I_XXX, I_CPY, I_CMP, I_DEC, I_XXX,
/*D0*/ I_BNE, I_CMP, I_XXX, I_XXX, I_XXX, I_CMP, I_DEC, I_XXX, I_CLD, I_CMP, I_XXX, I_XXX, I_XXX, I_CMP, I_DEC, I_XXX,
/*E0*/ I_CPX, I_SBC, I_XXX, I_XXX, I_CPX, I_SBC, I_INC, I_XXX, I_INX, I_SBC, I_NOP, I_XXX, I_CPX, I_SBC, I_INC, I_XXX,
/*F0*/ I_BEQ, I_SBC, I_XXX, I_XXX, I_XXX, I_SBC, I_INC, I_XXX, I_SED, I_SBC, I_XXX, I_XXX, I_XXX, I_SBC, I_INC, I_XXX
};

static const unsigned char dopaddr[256] PROGMEM =
{
/*00*/ IMP, INDX,  IMP, IMP,  IMP,  ZP,    ZP,   IMP,   IMP,  IMM,   IMPA,  IMP,  IMP,    ABS,   ABS,  IMP,
/*10*/ BRA, INDY,  IMP, IMP,  IMP,  ZPX,   ZPX,  IMP,   IMP,  ABSY,  IMP,   IMP,  IMP,    ABSX,  ABSX, IMP,
/*20*/ ABS, INDX,  IMP, IMP,  ZP,   ZP,    ZP,   IMP,   IMP,  IMM,   IMPA,  IMP,  ABS,    ABS,   ABS,  IMP,
/*30*/ BRA, INDY,  IMP, IMP,  IMP,  ZPX,   ZPX,  IMP,   IMP,  ABSY,  IMP,   IMP,  IMP,    ABSX,  ABSX, IMP,
/*40*/ IMP, INDX,  IMP, IMP,  ZP,   ZP,    ZP,   IMP,   IMP,  IMM,   IMPA,  IMP,  ABS,    ABS,   ABS,  IMP,
/*50*/ BRA, INDY,  IMP, IMP,  ZP,   ZPX,   ZPX,  IMP,   IMP,  ABSY,  IMP,   IMP,  ABS,    ABSX,  ABSX, IMP,
/*60*/ IMP, INDX,  IMP, IMP,  IMP,  ZP,    ZP,   IMP,   IMP,  IMM,   IMPA,  IMP,  IND16,  ABS,   ABS,  IMP,
/*70*/ BRA, INDY,  IMP, IMP,  IMP,  ZPX,   ZPX,  IMP,   IMP,  ABSY,  IMP,   IMP,  IMP,    ABSX,  ABSX, IMP,
/*80*/ IMP, INDX,  IMP, IMP,  ZP,   ZP,    ZP,   IMP,   IMP,  IMP,   IMP,   IMP,  ABS,    ABS,   ABS,  IMP,
/*90*/ BRA, INDY,  IMP, IMP,  ZPX,  ZPX,   ZPY,  IMP,   IMP,  ABSY,  IMP,   IMP,  IMP,    ABSX,  IMP,  IMP,
/*A0*/ IMM, INDX,  IMM, IMP,  ZP,   ZP,    ZP,   IMP,   IMP,  IMM,   IMP,   IMP,  ABS,    ABS,   ABS,  IMP,
/*B0*/ BRA, INDY,  IMP, IMP,  ZPX,  ZPX,   ZPY,  IMP,   IMP,  ABSY,  IMP,   IMP,  ABSX,   ABSX,  ABSY, IMP,
/*C0*/ IMM, INDX,  IMP, IMP,  ZP,   ZP,    ZP,   IMP,   IMP,  IMM,   IMP,   IMP,  ABS,    ABS,   ABS,  IMP,
/*D0*/ BRA, INDY,  IMP, IMP,  ZP,   ZPX,   ZPX,  IMP,   IMP,  ABSY,  IMP,   IMP,  ABS,    ABSX,  ABSX, IMP,
/*E0*/ IMM, INDX,  IMP, IMP,  ZP,   ZP,    ZP,   IMP,   IMP,  IMM,   IMP,   IMP,  ABS,    ABS,   ABS,  IMP,
/*F0*/ BRA, INDY,  IMP, IMP,  ZP,   ZPX,   ZPX,  IMP,   IMP,  ABSY,  IMP,   IMP,  ABS,    ABSX,  ABSX, IMP
};

addr_t disassemble(addr_t addr)
{

  char buffer[40];
  uint8_t temp;
  data_t op = readMemByteInc();
  data_t p1 = 0;
  data_t p2 = 0;
  uint8_t mode = pgm_read_byte(dopaddr + op);
  char *ptr;

  // 012345678901234567890123456789
  // AAAA : 11 22 33 : III MMMMMMMM

  // Template
  strfill(buffer, ' ', sizeof(buffer));
  buffer[5] = ':';
  buffer[16] = ':';

  // Address
  strhex4(buffer, addr++);

  // Hex
  strhex2(buffer + 7, op);

  if (mode > MARK2) {
    p1 = readMemByteInc();
    strhex2(buffer + 10, p1);
    addr++;
  }

  if (mode > MARK3) {
    p2 = readMemByteInc();
    strhex2(buffer + 13, p2);
    addr++;
  }

  uint16_t opIndex = pgm_read_byte(dopname + op) * 3;

  ptr = buffer + 18;
  for (temp = 0; temp < 3; temp++) {
    *ptr++ = pgm_read_byte(opString + opIndex + temp);
  }
  ptr++;

  switch (mode)
    {
    case IMP:
      break;
    case IMPA:
      *ptr++ = 'A';
      break;
    case BRA:
      *ptr++ = '$';
      ptr = strhex4(ptr, addr + (int8_t)p1);
      break;
    case IMM:
      *ptr++ = '#';
      // Fall through to
    case ZP:
      *ptr++ = '$';
      ptr = strhex2(ptr, p1);
      break;
    case ZPX:
      *ptr++ = '$';
      ptr = strhex2(ptr, p1);
      *ptr++ = ',';
      *ptr++ = 'X';
      break;
    case ZPY:
      *ptr++ = '$';
      ptr = strhex2(ptr, p1);
      *ptr++ = ',';
      *ptr++ = 'Y';
      break;
    case INDX:
      *ptr++ = '(';
      *ptr++ = '$';
      ptr = strhex2(ptr, p1);
      *ptr++ = ',';
      *ptr++ = 'X';
      *ptr++ = ')';
      break;
    case INDY:
      *ptr++ = '(';
      *ptr++ = '$';
      ptr = strhex2(ptr, p1);
      *ptr++ = ')';
      *ptr++ = ',';
      *ptr++ = 'Y';
      break;
    case ABS:
      *ptr++ = '$';
      ptr = strhex2(ptr, p2);
      ptr = strhex2(ptr, p1);
      break;
    case ABSX:
      *ptr++ = '$';
      ptr = strhex2(ptr, p2);
      ptr = strhex2(ptr, p1);
      *ptr++ = ',';
      *ptr++ = 'X';
      break;
    case ABSY:
      *ptr++ = '$';
      ptr = strhex2(ptr, p2);
      ptr = strhex2(ptr, p1);
      *ptr++ = ',';
      *ptr++ = 'Y';
      break;
    case IND16:
      *ptr++ = '(';
      *ptr++ = '$';
      ptr = strhex2(ptr, p2);
      ptr = strhex2(ptr, p1);
      *ptr++ = ')';
      break;
    }
  *ptr++ = '\n';
  *ptr++ = '\0';
  logs(buffer);
  return addr;
}
