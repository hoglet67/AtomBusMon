#include "status.h"

enum
{
	IMP, IMPA, IMM, ZP, ZPX, ZPY, INDX, INDY, IND, ABS, ABSX, ABSY, IND16, IND1X, BRA
};

char dopname[256][6] =
{
/*00*/ "BRK", "ORA", "---", "---", "TSB", "ORA", "ASL", "---", "PHP", "ORA", "ASL", "---", "TSB", "ORA", "ASL", "---",
/*10*/ "BPL", "ORA", "ORA", "---", "TRB", "ORA", "ASL", "---", "CLC", "ORA", "INC", "---", "TRB", "ORA", "ASL", "---",
/*20*/ "JSR", "AND", "---", "---", "BIT", "AND", "ROL", "---", "PLP", "AND", "ROL", "---", "BIT", "AND", "ROL", "---",
/*30*/ "BMI", "AND", "AND", "---", "BIT", "AND", "ROL", "---", "SEC", "AND", "DEC", "---", "BIT", "AND", "ROL", "---",
/*40*/ "RTI", "EOR", "---", "---", "---", "EOR", "LSR", "---", "PHA", "EOR", "LSR", "---", "JMP", "EOR", "LSR", "---",
/*50*/ "BVC", "EOR", "EOR", "---", "---", "EOR", "LSR", "---", "CLI", "EOR", "PHY", "---", "---", "EOR", "LSR", "---",
/*60*/ "RTS", "ADC", "---", "---", "STZ", "ADC", "ROR", "---", "PLA", "ADC", "ROR", "---", "JMP", "ADC", "ROR", "---",
/*70*/ "BVS", "ADC", "ADC", "---", "STZ", "ADC", "ROR", "---", "SEI", "ADC", "PLY", "---", "JMP", "ADC", "ROR", "---",
/*80*/ "BRA", "STA", "---", "---", "STY", "STA", "STX", "---", "DEY", "BIT", "TXA", "---", "STY", "STA", "STX", "---",
/*90*/ "BCC", "STA", "STA", "---", "STY", "STA", "STX", "---", "TYA", "STA", "TXS", "---", "STZ", "STA", "STZ", "---",
/*A0*/ "LDY", "LDA", "LDX", "---", "LDY", "LDA", "LDX", "---", "TAY", "LDA", "TAX", "---", "LDY", "LDA", "LDX", "---",
/*B0*/ "BCS", "LDA", "LDA", "---", "LDY", "LDA", "LDX", "---", "CLV", "LDA", "TSX", "---", "LDY", "LDA", "LDX", "---",
/*C0*/ "CPY", "CMP", "---", "---", "CPY", "CMP", "DEC", "---", "INY", "CMP", "DEX", "WAI", "CPY", "CMP", "DEC", "---",
/*D0*/ "BNE", "CMP", "CMP", "---", "---", "CMP", "DEC", "---", "CLD", "CMP", "PHX", "STP", "---", "CMP", "DEC", "---",
/*E0*/ "CPX", "SBC", "---", "---", "CPX", "SBC", "INC", "---", "INX", "SBC", "NOP", "---", "CPX", "SBC", "INC", "---",
/*F0*/ "BEQ", "SBC", "SBC", "---", "---", "SBC", "INC", "---", "SED", "SBC", "PLX", "---", "---", "SBC", "INC", "---",
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
/*F0*/ BRA, INDY,  IND, IMP,  ZP,   ZPX,   ZPX,	 IMP,	IMP,  ABSY,  IMP,   IMP,  ABS,	  ABSX,	 ABSX, IMP,
};

unsigned int disassemble(unsigned int addr, unsigned int op, unsigned int p1, unsigned int p2)
{
	unsigned int temp;

	log0("%04X : %s ", addr, dopname[op]);
	switch (dopaddr[op])
	{
	case IMP:
		log0("        ");
		break;
	case IMPA:
		log0("A       ");
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
	case BRA:
		temp = addr + 2 + (signed char)p1;
		log0("%04X    ", temp);
		addr++;
		break;
	}
	log0("\n");
	addr++;
	return addr;
}
