#include "AtomBusMon.h"

#define OFFSET_REG_BC  32
#define OFFSET_REG_DE  34
#define OFFSET_REG_HL  36
#define OFFSET_REG_IX  38
#define OFFSET_REG_BCp 40
#define OFFSET_REG_DEp 42
#define OFFSET_REG_HLp 44
#define OFFSET_REG_IY  46
#define OFFSET_REG_AF  48
#define OFFSET_REG_AFp 50
#define OFFSET_REG_SP  52
#define OFFSET_REG_PC  54
#define OFFSET_REG_I   56
#define OFFSET_REG_R   57
#define OFFSET_REG_IFF 58

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
  log0("   IX=%04X  IY=%04X  PC=%04X  SP=%04X I=%02X R=%02X IFF=%02X\n",
       hwRead16(OFFSET_REG_IX),
       hwRead16(OFFSET_REG_IY),
       hwRead16(OFFSET_REG_PC),
       hwRead16(OFFSET_REG_SP),
       hwRead8(OFFSET_REG_I),
       hwRead8(OFFSET_REG_R),
       hwRead8(OFFSET_REG_IFF));
  char *sp = statusString;
  log0("  Status: ");
  for (i = 0; i <= 7; i++) {
    log0("%c",  ((p & 128) ? (*sp) : '-'));
    p <<= 1;
    sp++;
  }
  log0("\n");
}
