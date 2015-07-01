#ifndef __ATOMBUSMON_DEFINES__
#define __ATOMBUSMON_DEFINES__

#include "status.h"
#include "dis.h"

#ifdef LCD
#include "hd44780.h"
#endif

// The Atom CRC Polynomial
#define CRC_POLY          0x002d

#define Delay_us(__us) \
    if((unsigned long) (F_CPU/1000000.0 * __us) != F_CPU/1000000.0 * __us)\
          __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000000.0 * __us)+1);\
    else __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000000.0 * __us))

#define Delay_ms(__ms) \
    if((unsigned long) (F_CPU/1000.0 * __ms) != F_CPU/1000.0 * __ms)\
          __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000.0 * __ms)+1);\
    else __builtin_avr_delay_cycles((unsigned long) ( F_CPU/1000.0 * __ms))

unsigned int hwRead8(unsigned int offset);
unsigned int hwRead16(unsigned int offset);

#ifdef CPUEMBEDDED
unsigned int disMem(unsigned int addr);
void loadData(unsigned int data);
void loadAddr(unsigned int addr);
unsigned int readMemByte();
unsigned int readMemByteInc();
void writeMemByte();
void writeMemByteInc();
unsigned int disMem(unsigned int addr);
#endif

void doCmdBreak(char *params, unsigned int mode);
void doCmdBreakI(char *params);
void doCmdBreakRdIO(char *params);
void doCmdBreakRdMem(char *params);
void doCmdBreakWrIO(char *params);
void doCmdBreakWrMem(char *params);
void doCmdClear(char *params);
void doCmdContinue(char *params);
void doCmdCrc(char *params);
void doCmdDis(char *params);
void doCmdFill(char *params);
void doCmdHelp(char *params);
void doCmdIO(char *params);
void doCmdList(char *params);
void doCmdMem(char *params);
void doCmdReadIO(char *params);
void doCmdReadMem(char *params);
void doCmdRegs(char *params);
void doCmdReset(char *params);
void doCmdStep(char *params);
void doCmdTest(char *params);
void doCmdTrace(char *params);
void doCmdTrigger(char *params);
void doCmdWatchI(char *params);
void doCmdWatchRdIO(char *params);
void doCmdWatchRdMem(char *params);
void doCmdWatchWrIO(char *params);
void doCmdWatchWrMem(char *params);
void doCmdWriteIO(char *params);
void doCmdWriteMem(char *params);

#endif
