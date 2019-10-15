#include "AtomBusMon.h"

// Version 350 of T80 exposes the registers in this order (bit 211..bit 0):
// IFF2, IFF1, IM, IY, HL', DE', BC', IX, HL, DE, BC, PC, SP, R, I, F', A', F, A

#define OFFSET_REG_AF  (32 + 0)
#define OFFSET_REG_AFp (32 + 2)
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
  int i;
  unsigned int p = hwRead16(OFFSET_REG_AF);
  log0("Z80 Registers:\n");
  log0("   AF=%04X  BC=%04X  DE=%04X  HL=%04X\n",
       p,
       hwRead16(OFFSET_REG_BC),
       hwRead16(OFFSET_REG_DE),
       hwRead16(OFFSET_REG_HL));
  log0("  'AF=%04X 'BC=%04X 'DE=%04X 'HL=%04X\n",
       hwRead16(OFFSET_REG_AFp),
       hwRead16(OFFSET_REG_BCp),
       hwRead16(OFFSET_REG_DEp),
       hwRead16(OFFSET_REG_HLp));
  int iff2_iff1_im = hwRead8(OFFSET_REG_IFF) & 15;
  log0("   IX=%04X  IY=%04X  PC=%04X  SP=%04X I=%02X R=%02X IM=%X IFF1=%X IFF2=%X\n",
       hwRead16(OFFSET_REG_IX),
       hwRead16(OFFSET_REG_IY),
       hwRead16(OFFSET_REG_PC),
       hwRead16(OFFSET_REG_SP),
       hwRead8(OFFSET_REG_I),
       hwRead8(OFFSET_REG_R),
       (iff2_iff1_im & 3),
       (iff2_iff1_im >> 2) & 1,
       (iff2_iff1_im >> 3) & 1
       );
  char *sp = statusString;
  log0("  Status: ");
  for (i = 0; i <= 7; i++) {
    log0("%c",  ((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  log0("\n");
}
