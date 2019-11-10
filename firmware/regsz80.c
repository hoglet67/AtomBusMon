#include "AtomBusMon.h"

// Version 350 of T80 exposes the registers in this order (bit 211..bit 0):
// IFF2, IFF1, IM, IY, HL', DE', BC', IX, HL, DE, BC, PC, SP, R, I, F', A', F, A

#define OFFSET_REG_A   (32 + 0)
#define OFFSET_REG_F   (32 + 1)
#define OFFSET_REG_Ap  (32 + 2)
#define OFFSET_REG_Fp  (32 + 3)
#define OFFSET_REG_I   (32 + 4)
#define OFFSET_REG_R   (32 + 5)
#define OFFSET_REG_SP  (32 + 6)
#define OFFSET_REG_PC  (32 + 8)
#define OFFSET_REG_BC  (32 + 10)
#define OFFSET_REG_DE  (32 + 12)
#define OFFSET_REG_HL  (32 + 14)
#define OFFSET_REG_IX  (32 + 16)
#define OFFSET_REG_BCp (32 + 18)
#define OFFSET_REG_DEp (32 + 20)
#define OFFSET_REG_HLp (32 + 22)
#define OFFSET_REG_IY  (32 + 24)
#define OFFSET_REG_IFF (32 + 26)

char statusString[8] = "SZIH-P-C";

void doCmdRegs(char *params) {
  uint8_t i;
  uint8_t p = hwRead16(OFFSET_REG_F);
  logstr("Z80 Registers:\n   AF=");
  loghex2(hwRead8(OFFSET_REG_A));
  loghex2(p);
  logstr("  BC=");
  loghex4(hwRead16(OFFSET_REG_BC));
  logstr("  DE=");
  loghex4(hwRead16(OFFSET_REG_DE));
  logstr("  HL=");
  loghex4(hwRead16(OFFSET_REG_HL));
  logstr("\n  'AF=");
  loghex2(hwRead8(OFFSET_REG_Ap));
  loghex2(hwRead8(OFFSET_REG_Fp));
  logstr(" 'BC=");
  loghex4(hwRead16(OFFSET_REG_BCp));
  logstr(" 'DE=");
  loghex4(hwRead16(OFFSET_REG_DEp));
  logstr(" 'HL=");
  loghex4(hwRead16(OFFSET_REG_HLp));
  int iff2_iff1_im = hwRead8(OFFSET_REG_IFF) & 15;
  logstr("\n   IX=");
  loghex4(hwRead16(OFFSET_REG_IX));
  logstr("  IY=");
  loghex4(hwRead16(OFFSET_REG_IY));
  logstr("  PC=");
  loghex4(hwRead16(OFFSET_REG_PC));
  logstr("  SP=");
  loghex4(hwRead16(OFFSET_REG_SP));
  logstr(" I=");
  loghex2(hwRead8(OFFSET_REG_I));
  logstr(" R=");
  loghex2(hwRead8(OFFSET_REG_R));
  logstr(" IM=");
  loghex1((iff2_iff1_im & 3));
  logstr(" IFF1=");
  loghex1((iff2_iff1_im >> 2) & 1);
  logstr(" IFF2=");
  loghex1((iff2_iff1_im >> 3) & 1);
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
