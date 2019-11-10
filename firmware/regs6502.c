#include "AtomBusMon.h"

#define OFFSET_REG_A   32
#define OFFSET_REG_X   33
#define OFFSET_REG_Y   34
#define OFFSET_REG_P   35
#define OFFSET_REG_SP  36
#define OFFSET_REG_PC  38

char statusString[8] = "NV-BDIZC";

void doCmdRegs(char *params) {
  int i;
  unsigned int p = hwRead8(OFFSET_REG_P);
  logstr("6502 Registers:\n  A=");
  loghex2(hwRead8(OFFSET_REG_A));
  logstr(" X=");
  loghex2(hwRead8(OFFSET_REG_X));
  logstr(" Y=");
  loghex2(hwRead8(OFFSET_REG_Y));
  logstr(" SP=01");
  loghex2(hwRead8(OFFSET_REG_SP));
  logstr(" PC=");
  loghex4(hwRead16(OFFSET_REG_PC));
  logc('\n');
  char *sp = statusString;
  logstr("  Status: ");
  for (i = 0; i <= 7; i++) {
    logc(((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  logc('\n');
}
