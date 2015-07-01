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
  log0("6502 Registers:\n  A=%02X X=%02X Y=%02X SP=%04X PC=%04X\n",
       hwRead8(OFFSET_REG_A),
       hwRead8(OFFSET_REG_X),
       hwRead8(OFFSET_REG_Y),
       hwRead16(OFFSET_REG_SP),
       hwRead16(OFFSET_REG_PC));
  char *sp = statusString;
  log0("  Status: ");
  for (i = 0; i <= 7; i++) {
    log0("%c",  ((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  log0("\n");
}
