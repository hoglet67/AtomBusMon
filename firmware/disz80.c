/*  Z80 disassembler
    
*** Copyright:  1994-1996 Günter Woigk
mailto:kio@little-bat.de

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

Permission to use, copy, modify, distribute, and sell this software and
its documentation for any purpose is hereby granted without fee, provided
that the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation, and that the name of the copyright holder not be used
in advertising or publicity pertaining to distribution of the software
without specific, written prior permission.  The copyright holder makes no
representations about the suitability of this software for any purpose.
It is provided "as is" without express or implied warranty.

THE COPYRIGHT HOLDER DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY SPECIAL, INDIRECT OR
CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.

30.Jan.95:  Started work on disassembler stuff                  KIO !
02.Jun.95:  Reworked completely                                 KIO !
20.Oct.01   revised for CW7Pro and ANSI C compliance            hdusel@bnv-gz.de
*/

#include <string.h>
#include <avr/pgmspace.h>

#include "AtomBusMon.h"

#define legal       0
#define illegal     1
#define weird       2

#undef  RR
#undef  IM
#undef  RH
#undef  RL
#undef  BC
#undef  DE
#undef  HL
#undef  IX
#undef  IY
#undef  SP
#undef  PC
#undef  XH
#undef  XL
#undef  YH
#undef  YL
#undef  ADC

// ---- opcode definitions ------------------------------------------------------------------

enum {
  NIX,    NOP,    LD,     INC,    DEC,    RLCA,   EX,     ADD,    
  RRCA,   DJNZ,   RLA,    JR,     RRA,    DAA,    CPL,    HALT,
  SCF,    CCF,    RLC,    RRC,    RL,     RR,     SLA,    SRA,    
  SLL,    SRL,    IN,     OUT,    SBC,    NEG,    RETN,   IM,
  ADC,    RETI,   RRD,    RLD,    SUB,    AND,    XOR,    
  OR,     CP,     BIT,    RES,    SET,    LDI,    CPI,    INI,    
  OUTI,   LDD,    CPD,    IND,    OUTD,   LDIR,   CPIR,   INIR,   
  OTIR,   LDDR,   CPDR,   INDR,   OTDR,   RET,    POP,    JP, 
  CALL,   PUSH,   RST,    PFX,    EXX,    DI,     EI, 
  BC,     DE,     HL,     IX,     IY,     SP,     AF,     AF2,    
  B,      C,      D,      E,      H,      L,      XHL,    A,      // <- KEEP THIS ORDER!
  XBC,    XDE,    R,      I,      XC,     XSP,    PC,     F,
  N0,     N1,     N2,     N3,     N4,     N5,     N6,     N7,
  Z,      NZ,     NC,     PO,     PE,     M,      P,
  N,      NN,     XNN,    XN,     DIS,    CB,     ED,
  XH,     XL,     YH,     YL,     XIX,    XIY
};
    
char* word[] = 
  {   "",       "NOP",    "LD",     "INC",    "DEC",    "RLCA",   "EX",     "ADD",    
      "RRCA",   "DJNZ",   "RLA",    "JR",     "RRA",    "DAA",    "CPL",    "HALT",
      "SCF",    "CCF",    "RLC",    "RRC",    "RL",     "RR",     "SLA",    "SRA",
      "SLL",    "SRL",    "IN",     "OUT",    "SBC",    "NEG",    "RETN",   "IM",
      "ADC",    "RETI",   "RRD",    "RLD",    "SUB",    "AND",    "XOR",
      "OR",     "CP",     "BIT",    "RES",    "SET",    "LDI",    "CPI",    "INI",
      "OUTI",   "LDD",    "CPD",    "IND",    "OUTD",   "LDIR",   "CPIR",   "INIR",
      "OTIR",   "LDDR",   "CPDR",   "INDR",   "OTDR",   "RET",    "POP",    "JP",
      "CALL",   "PUSH",   "RST",    "PREFIX", "EXX",    "DI",     "EI",
      "BC",     "DE",     "HL",     "IX",     "IY",     "SP",     "AF",     "AF'",
      "B",      "C",      "D",      "E",      "H",      "L",      "(HL)",   "A",
      "(BC)",   "(DE)",   "R",      "I",      "(C)",    "(SP)",   "PC",     "F",
      "0",      "1",      "2",      "3",      "4",      "5",      "6",      "7",
      "Z",      "NZ",     "NC",     "PO",     "PE",     "M",      "P",  
      "N",      "NN",     "XNN",    "XN",     "DIS",    "CB",     "ED",
      "XH",     "XL",     "YH",     "YL",     "DIS(IX)","DIS(IY)"
  };
    
static const unsigned char cmd_00[192] PROGMEM = 
  {
    NOP,0,0,    
    LD,BC,NN,   
    LD,XBC,A,   
    INC,BC,0,   
    INC,B,0,    
    DEC,B,0,    
    LD,B,N,     
    RLCA,0,0,
    EX,AF,AF2,  
    ADD,HL,BC,  
    LD,A,XBC,   
    DEC,BC,0,   
    INC,C,0,    
    DEC,C,0,    
    LD,C,N,     
    RRCA,0,0,
    DJNZ,DIS,0, 
    LD,DE,NN,   
    LD,XDE,A,   
    INC,DE,0,   
    INC,D,0,    
    DEC,D,0,    
    LD,D,N,     
    RLA,0,0,
    JR,DIS,0,   
    ADD,HL,DE,  
    LD,A,XDE,   
    DEC,DE,0,   
    INC,E,0,    
    DEC,E,0,    
    LD,E,N,     
    RRA,0,0,
    JR,NZ,DIS,  
    LD,HL,NN,   
    LD,XNN,HL,  
    INC,HL,0,   
    INC,H,0,    
    DEC,H,0,    
    LD,H,N,     
    DAA,0,0,
    JR,Z,DIS,   
    ADD,HL,HL,  
    LD,HL,XNN,  
    DEC,HL,0,   
    INC,L,0,    
    DEC,L,0,    
    LD,L,N,     
    CPL,0,0,
    JR,NC,DIS,  
    LD,SP,NN,   
    LD,XNN,A,   
    INC,SP,0,   
    INC,XHL,0,  
    DEC,XHL,0,  
    LD,XHL,N,   
    SCF,0,0,
    JR,C,N,     
    ADD,HL,SP,  
    LD,A,XNN,   
    DEC,SP,0,   
    INC,A,0,    
    DEC,A,0,    
    LD,A,N,     
    CCF,0,0
  };

static const unsigned char cmd_C0[192] PROGMEM = { 
  
    RET,NZ,0,   
    POP,BC,0,   
    JP,NZ,NN,   
    JP,NN,0,    
    CALL,NZ,NN, 
    PUSH,BC,0,  
    ADD,A,N,    
    RST,N0,0,
    RET,Z,0,    
    RET,0,0,    
    JP,Z,NN,    
    PFX,CB,0,   
    CALL,Z,NN,  
    CALL,NN,0,  
    ADC,A,N,    
    RST,N1,0,
    RET,NC,0,   
    POP,DE,0,   
    JP,NC,NN,   
    OUT,XN,A,   
    CALL,NC,NN, 
    PUSH,DE,0,  
    SUB,A,N,    
    RST,N2,0,
    RET,C,0,    
    EXX,0,0,    
    JP,C,NN,    
    IN,A,XN,    
    CALL,C,NN,  
    PFX,IX,0,   
    SBC,A,N,    
    RST,N3,0,
    RET,PO,0,   
    POP,HL,0,   
    JP,PO,NN,   
    EX,HL,XSP,  
    CALL,PO,NN, 
    PUSH,HL,0,  
    AND,A,N,    
    RST,N4,0,
    RET,PE,0,   
    LD,PC,HL,   
    JP,PE,NN,   
    EX,DE,HL,   
    CALL,PE,NN, 
    PFX,ED,0,   
    XOR,A,N,    
    RST,N5,0,
    RET,P,0,    
    POP,AF,0,   
    JP,P,NN,    
    DI,0,0,     
    CALL,P,NN,  
    PUSH,AF,0,  
    OR,A,N,     
    RST,N6,0,
    RET,M,0,    
    LD,SP,HL,   
    JP,M,NN,    
    EI,0,0,     
    CALL,M,NN,  
    PFX,IY,0,   
    CP,A,N,     
    RST,N7,0
};

static const unsigned char cmd_ED40[192] PROGMEM = {
  
    IN,B,XC,    
    OUT,XC,B,   
    SBC,HL,BC,  
    LD,XNN,BC,  
    NEG,0,0,    
    RETN,0,0,   
    IM,N0,0,    
    LD,I,A,
    IN,C,XC,    
    OUT,XC,C,   
    ADC,HL,BC,  
    LD,BC,XNN,  
    NEG,0,0,    
    RETI,0,0,   
    IM,N0,0,    
    LD,R,A,
    IN,D,XC,    
    OUT,XC,D,   
    SBC,HL,DE,  
    LD,XNN,DE,  
    NEG,0,0,    
    RETN,0,0,   
    IM,N1,0,    
    LD,A,I,
    IN,E,XC,    
    OUT,XC,E,   
    ADC,HL,DE,  
    LD,DE,XNN,  
    NEG,0,0,    
    RETI,0,0,   
    IM,N2,0,    
    LD,A,R,
    IN,H,XC,    
    OUT,XC,H,   
    SBC,HL,HL,  
    LD,XNN,HL,  
    NEG,0,0,    
    RETN,0,0,   
    IM,N0,0,    
    RRD,0,0,
    IN,L,XC,    
    OUT,XC,L,   
    ADC,HL,HL,  
    LD,HL,XNN,  
    NEG,0,0,    
    RETI,0,0,   
    IM,N0,0,    
    RLD,0,0,
    IN,F,XC,    
    OUT,XC,N0,  
    SBC,HL,SP,  
    LD,XNN,SP,  
    NEG,0,0,    
    RETN,0,0,   
    IM,N1,0,    
    NOP,0,0,
    IN,A,XC,    
    OUT,XC,A,   
    ADC,HL,SP,  
    LD,SP,XNN,  
    NEG,0,0,    
    RETI,0,0,   
    IM,N2,0,    
    NOP,0,0 
  };

unsigned char cmd_halt[] = { HALT,0,0 };
unsigned char cmd_nop[]  = { NOP,0,0 };

unsigned char c_ari[]    = { ADD,ADC,SUB,SBC,AND,XOR,OR,CP };

unsigned char c_blk[]    = { LDI,CPI,INI,OUTI,0,0,0,0,LDD,CPD,IND,OUTD,0,0,0,0,
			     LDIR,CPIR,INIR,OTIR,0,0,0,0,LDDR,CPDR,INDR,OTDR };

unsigned char c_sh[]     = { RLC,RRC,RL,RR,SLA,SRA,SLL,SRL };


// ============================================================================================


unsigned char Peek(unsigned int addr) {
  loadAddr(addr);
  return readMemByte();
}

const unsigned char *copyFromPgmMem(const unsigned char *mem) {
  static unsigned char buffer[3];
  buffer[0] = pgm_read_byte(mem++);
  buffer[1] = pgm_read_byte(mem++);
  buffer[2] = pgm_read_byte(mem++);
  return buffer;
}


// ---- return mnenonic descriptor for normal instructions
//      note: for immediate use only, returned result becomes invalid with next call!
const unsigned char* mnemo(unsigned char op) {
  static unsigned char cl[3]={LD,A,A};
  static unsigned char ca[3]={ADD,A,A};

  switch (op>>6)
    {
    case 0: return copyFromPgmMem(cmd_00 + op * 3);
    case 1: if (op==0x76) return cmd_halt;
      cl[1] = B + ((op>>3)&0x07); 
      cl[2] = B + (op&0x07); 
      return cl;
    case 2: ca[0] = c_ari[(op>>3)&0x07];
      ca[2] = B + (op&0x07); 
      return ca;
    case 3: return copyFromPgmMem(cmd_C0 + (op&0x3f) * 3);
    }
  return NULL;
}


// ---- return mnenonic descriptor for CB instructions
//      note: for immediate use only!
unsigned char* mnemoCB(unsigned char op) {
  static unsigned char cmd[3];

  switch (op>>6)
    {
    case 0: cmd[0] = c_sh[(op>>3)&0x07];
      cmd[1] = B + (op&0x07);
      cmd[2] = 0;
      return cmd;
    case 1: cmd[0] = BIT; break;
    case 2: cmd[0] = RES; break;
    case 3: cmd[0] = SET; break;
    }
  cmd[1] = N0 + ((op>>3)&0x07);
  cmd[2] = B + (op&0x07); 
  return cmd;
}


// ---- return mnenonic descriptor for IXCB instructions
//      note: for immediate use only!
unsigned char* mnemoIXCB(unsigned char op) {
  unsigned char *c;

  c = mnemoCB(op);
  if (c[1]==XHL) c[1]=XIX;    // this is only allowed, because mnemo() doesn't
  if (c[2]==XHL) c[2]=XIX;    // retrieve a pointer but creates mnemo descr ad hoc
  return c;
}


// ---- return mnenonic descriptor for IYCB instructions
//      note: for immediate use only!
unsigned char* mnemoIYCB(unsigned char op) {
  unsigned char *c;

  c = mnemoCB(op);
  if (c[1]==XHL) c[1]=XIY;    // this is only allowed, because mnemo() doesn't
  if (c[2]==XHL) c[2]=XIY;    // retrieve a pointer but creates mnemo descr ad hoc
  return c;
}


// ---- return mnenonic descriptor for ED instructions
//      note: for immediate use only!
const unsigned char* mnemoED(unsigned char op) {
  static unsigned char cmd[3]={0,0,0};

  if (op<0x40) return cmd_nop;
    
  if (op>=0x080) 
    {   if ((op&0xE4)!=0xA0) return cmd_nop;
      cmd[0] = c_blk[op&0x1B];
      return cmd;
    };
    
  return copyFromPgmMem(cmd_ED40 + (op-0x40) * 3);   
}


// ---- return mnenonic descriptor for IX instructions
//      note: for immediate use only!
unsigned char*   mnemoIX (unsigned char op) {
  static unsigned char cmd[3];
    
  memcpy (cmd, mnemo(op), 3);

  if (cmd[1]==XHL) { cmd[1]=XIX; return cmd; }
  if (cmd[2]==XHL) { cmd[2]=XIX; return cmd; }
  if (cmd[1]==HL)  { cmd[1]=IX;  return cmd; }
  if (cmd[2]==HL)  { cmd[2]=IX;  return cmd; }
  if (cmd[1]==H) cmd[1]=XH;
  if (cmd[1]==L) cmd[1]=XL;
  if (cmd[2]==H) cmd[2]=XH;
  if (cmd[2]==L) cmd[2]=XL;
  return cmd;
}


// ---- return mnenonic descriptor for IY instructions
//      note: for immediate use only!
unsigned char*   mnemoIY (unsigned char op) {
  static unsigned char cmd[3];
    
  memcpy (cmd, mnemo(op), 3);

  if (cmd[1]==XHL) { cmd[1]=XIY; return cmd; }
  if (cmd[2]==XHL) { cmd[2]=XIY; return cmd; }
  if (cmd[1]==HL)  { cmd[1]=IY;  return cmd; }
  if (cmd[2]==HL)  { cmd[2]=IY;  return cmd; }
  if (cmd[1]==H) cmd[1]=YH;
  if (cmd[1]==L) cmd[1]=YL;
  if (cmd[2]==H) cmd[2]=YH;
  if (cmd[2]==L) cmd[2]=YL;
  return cmd;
}

// ---- get legal state of CB instruction --------------------------------------
//      all instructions legal except: sll is illegal
int IllegalCB (unsigned char op) {
  return op>=0x30 && op<0x38 ? illegal : legal;
}


// ---- get legal state of IXCB/IYCB instruction ----------------------------------
//      all instructions which do not use IX are weird
//      instructions using IX are legal except: sll is illegal
int IllegalXXCB (unsigned char op) {
  if ((op&0x07)!=6) return weird;
  return op>=0x30 && op<0x38 ? illegal : legal;   
}


// ---- get legal state of ED instruction --------------------------------------
//      0x00-0x3F and 0x80-0xFF weird except block instructions
//      0x40-0x7F legal or weird 
//      in f,(c) is legal; out (c),0 is weird
int IllegalED (unsigned char op) {
  char *il = "1111111111110101111100111111001111110001111100011011000011110000";

  if ((op>>6)==1) return il[op-0x40]-'0' ? weird : legal;
  return *mnemoED(op)==NOP ? weird : legal;
}


// ---- get legal state of IX/IY instruction --------------------------------------
//      all illegal instructions, which use XH or XL are illegal
//      all illegal instructions, which don't use XH or XL are weird
//      prefixes are legal
int IllegalXX (unsigned char op) {
  const unsigned char *c;
    
  c = mnemo(op);

  if (*c==PFX || c[1]==XHL || c[2]==XHL) return legal;
  if (c[1]==H||c[1]==L||c[2]==H||c[2]==L) return illegal;
  return weird;
}


// ---- Calculate length of instruction                         30.jun.95 KIO !
//      op2 is only used if op1 is a prefix instruction
//      IX/IY before IX/IY/ed have no effect and are reported as length 1
int OpcodeLength (unsigned char op1, unsigned char op2) {
  static char* len0 = "1311112111111121231111212111112123311121213111212331112121311121"; // 0x00 - 0x3F
  static char* len3 = "1133312111303321113231211132302111313121113130211131312111313021"; // 0xC0 - 0xFF; prefixes are 0

  switch (op1>>6)
    {
    case 0: return len0[op1]-'0';       // 0x00 - 0x3F: various length
    case 1:                             // 0x40 - 0x7F: ld r,r: all 1
    case 2: return 1;                   // 0x80 - 0xBF: arithmetics/logics op a,r: all 1
    }

  switch (op1)    // test for prefix
    {
    case 0xcb:  return 2;
    case 0xed:  if (/* op2<0x40 || op2>=0x80 || ((op2&7)!=3) */ (op2&0xc7)!=0x43) return 2; else return 4;
    case 0xdd:  
    case 0xfd:
      switch (op2>>6)         
        {
        case 0: return len0[op2]-'0'+1 + (op2>=0x34&&op2<=0x36);    // inc(hl); dec(hl); ld(hl),N: add displacement
        case 1: 
        case 2: if (((op2&0x07)==6) == ((op2&0x0F8)==0x70)) return 2; else return 3;
        }
      if (op2==0xcb) return 4;
      return len3[op2&0x3F]-'0'+1;    // note: entries for prefixes are 0 giving a total of 1, just to skip the useless prefix
    }
    
  return len3[op1&0x3F]-'0';          // 0xC0 - 0xFF: no prefix:  various length
}


// ===================================================================================


void xword (unsigned char n, unsigned int *ip) {
  unsigned int nn;

  switch (n)
    {
    case DIS:
      n = Peek((*ip)++);
      log0("$%04X", *ip+(char)n,4);      // branch destination
      break;
    case N: 
      n = Peek((*ip)++);
      log0("$%02X", n);
      break;
    case NN:
      n = Peek((*ip)++);
      nn = n+256*Peek((*ip)++);
      log0("$%04X", nn);
      break;
    case XNN:
      n = Peek((*ip)++);
      nn = n+256*Peek((*ip)++);
      log0("($%04X)", nn);
      break;
    case XN:
      n = Peek((*ip)++);
      log0("($%02X)", n);
      break;
    case XIX:
      n = Peek((*ip)++);
      if (n&0x80) {
	log0("(IX-$%02X)", 256-n);
      } else {
	log0("(IX+$%02X)", n);
      }
      break;
    case XIY:
      n = Peek((*ip)++);
      if (n&0x80) {
	log0("(IY-$%02X)", 256-n);
      } else {
	log0("(IY+$%02X)", n);
      }
      break;
    default:
      log0("%s", word[n]);
      break;
    }
}


// ---- expand 3-char descriptor m[3] to mnemonic with arguments via pc
void disass (const unsigned char *m, unsigned int *ip) {
  log0("%-5s", word[*m++]);
  if (*m) {
    xword(*m++,ip);
  }
  if (*m) {
    log0(",");
    xword(*m,ip);
  }
}

void disassem (unsigned int *ip) {
  unsigned char op;
    
  op = Peek((*ip)++);
  switch (op)
    {
    case 0xcb:
      disass (mnemoCB(Peek((*ip)++)), ip);
      break;
    case 0xed:
      disass (mnemoED(Peek((*ip)++)), ip);
      break;
    case 0xdd:
      op = Peek((*ip)++);
      if (op!=0xCB) {
	disass (mnemoIX(op), ip);
      } else {
	disass (mnemoIXCB(Peek((*ip)+1)), ip);
	(*ip)++;
      }
      break;
    case 0xfd:
      op = Peek((*ip)++);
      if (op!=0xCB) {
	disass (mnemoIY(op), ip);
      } else {
        disass (mnemoIYCB(Peek((*ip)+1)), ip);
	(*ip)++;
      }
      break;
    default:
      disass (mnemo(op),ip);
      break;
    }
}

unsigned int disassemble(unsigned int addr) {
  log0("%04X : ", addr);
  disassem(&addr);
  log0("\n");
  return addr;
}
