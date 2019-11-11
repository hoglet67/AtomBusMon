#include "AtomBusMon.h"

// Version 350 of T80 exposes the registers in this order (bit 211..bit 0):
// IFF2, IFF1, IM, IY, HL', DE', BC', IX, HL, DE, BC, PC, SP, R, I, F', A', F, A

#define OFFSET_REG_AF      (32 + 0)
#define OFFSET_REG_AFp     (32 + 2)
#define OFFSET_REG_I       (32 + 4)
#define OFFSET_REG_R       (32 + 5)
#define OFFSET_REG_SP      (32 + 6)
#define OFFSET_REG_PC      (32 + 8)
#define OFFSET_REG_BCDEHL  (32 + 10)
#define OFFSET_REG_IX      (32 + 16)
#define OFFSET_REG_BCDEHLp (32 + 18)
#define OFFSET_REG_IY      (32 + 24)
#define OFFSET_REG_IFF     (32 + 26)

char statusString[8] = "SZYHXPNC";

void output_abcdehlf(char *prefix, uint8_t base_af, uint8_t base_bcdehl) {
  uint16_t i;
  logs(prefix);
  logstr("A=");
  loghex2(hwRead8(base_af));
  logs(prefix);
  logstr("BC=");
  loghex4(hwRead16(base_bcdehl));
  logs(prefix);
  logstr("DE=");
  loghex4(hwRead16(base_bcdehl + 2));
  logs(prefix);
  logstr("HL=");
  loghex4(hwRead16(base_bcdehl + 4));
  logs(prefix);
  logstr("F=");
  uint8_t p = hwRead8(base_af + 1);
  loghex2(p);
  logstr(" (");
  char *sp = statusString;
  for (i = 0; i <= 7; i++) {
    logc(((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  logs(")\n");
}

void doCmdRegs(char *params) {
  int iff2_iff1_im = hwRead8(OFFSET_REG_IFF) & 15;
  logstr("Z80 Registers:\n");
  output_abcdehlf("  ", OFFSET_REG_AF,  OFFSET_REG_BCDEHL);
  output_abcdehlf(" '", OFFSET_REG_AFp, OFFSET_REG_BCDEHLp);
  logstr("  R=");
  loghex2(hwRead8(OFFSET_REG_R));
  logstr("  IX=");
  loghex4(hwRead16(OFFSET_REG_IX));
  logstr("  IY=");
  loghex4(hwRead16(OFFSET_REG_IY));
  logstr("  PC=");
  loghex4(hwRead16(OFFSET_REG_PC));
  logstr(" SP=");
  loghex4(hwRead16(OFFSET_REG_SP));
  logstr(" I=");
  loghex2(hwRead8(OFFSET_REG_I));
  logstr(" IM=");
  loghex1((iff2_iff1_im & 3));
  logstr(" IFF1=");
  loghex1((iff2_iff1_im >> 2) & 1);
  logstr(" IFF2=");
  loghex1((iff2_iff1_im >> 3) & 1);
  logc('\n');
}
