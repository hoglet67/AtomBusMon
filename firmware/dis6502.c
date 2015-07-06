#include <avr/pgmspace.h>
#include "AtomBusMon.h"

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
BRA\
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
PHX\
PHY\
PLA\
PLP\
PLX\
PLY\
ROL\
ROR\
RTI\
RTS\
SBC\
SEC\
SED\
SEI\
STA\
STP\
STX\
STY\
STZ\
TAX\
TAY\
TRB\
TSB\
TSX\
TXA\
TXS\
TYA\
WAI\
---\
";

static const unsigned char dopname[256] PROGMEM =
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

static const unsigned char dopaddr[256] PROGMEM =
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

unsigned int disassemble(unsigned int addr)
{
  
	unsigned int temp;
	unsigned int op = readMemByteInc();
        int mode = pgm_read_byte(dopaddr + op);
	unsigned int p1 = (mode > MARK2) ? readMemByteInc() : 0;
	unsigned int p2 = (mode > MARK3) ? readMemByteInc() : 0;

	int opIndex = pgm_read_byte(dopname + op) * 3;
	log0("%04X : ", addr);
	for (temp = 0; temp < 3; temp++) {
	  log0("%c", pgm_read_byte(opString + opIndex + temp));
	}
	log0(" ");

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
