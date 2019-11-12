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

const char statusString[8] = "EFHINZVC";

void doCmdRegs(char *params) {
  uint16_t i;
  uint8_t p = hwRead8(OFFSET_REG_CC);
  const char *sp = statusString;
  logstr("6809 Registers:\n   A=");
  loghex2(hwRead8(OFFSET_REG_A));
  logstr(" B=");
  loghex2(hwRead8(OFFSET_REG_B));
  logstr(" X=");
  loghex4(hwRead16(OFFSET_REG_X));
  logstr(" Y=");
  loghex4(hwRead16(OFFSET_REG_Y));
  logstr("\n  CC=");
  loghex2(p);
  logstr(" D=");
  loghex2(hwRead8(OFFSET_REG_D));
  logstr(" U=");
  loghex4(hwRead16(OFFSET_REG_U));
  logstr(" S=");
  loghex4(hwRead16(OFFSET_REG_S));
  logstr(" PC=");
  loghex4(hwRead16(OFFSET_REG_PC));
  logstr("\n  Status: ");
  for (i = 0; i <= 7; i++) {
    logc(((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  logc('\n');
}
