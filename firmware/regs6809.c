#include "AtomBusMon.h"

#define OFFSET_REG_A   32
#define OFFSET_REG_B   33
#define OFFSET_REG_X   34
#define OFFSET_REG_Y   36
#define OFFSET_REG_U   38
#define OFFSET_REG_S   40
#define OFFSET_REG_PC  42
#define OFFSET_REG_D   44
#define OFFSET_REG_CC  45

char statusString[8] = "EFHINZVC";

void doCmdRegs(char *params) {
  int i;
  unsigned int p = hwRead8(OFFSET_REG_CC);
  log0("6809 Registers:\n   A=%02X B=%02X X=%04X Y=%04X\n",
       hwRead8(OFFSET_REG_A),
       hwRead8(OFFSET_REG_B),
       hwRead16(OFFSET_REG_X),
       hwRead16(OFFSET_REG_Y));
  log0("  CC=%02X D=%02X U=%04X S=%04X PC=%04X\n",
       p,
       hwRead8(OFFSET_REG_D),
       hwRead16(OFFSET_REG_U),
       hwRead16(OFFSET_REG_S),
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
