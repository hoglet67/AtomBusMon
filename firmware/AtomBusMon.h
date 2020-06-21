#ifndef __ATOMBUSMON_DEFINES__
#define __ATOMBUSMON_DEFINES__

#include <stdio.h>

typedef uint8_t  data_t;
typedef uint16_t addr_t;
typedef uint8_t  offset_t;
typedef uint16_t modes_t;
typedef uint8_t  trigger_t;
typedef uint16_t cmd_t;
typedef uint16_t param_t;
typedef int16_t  bknum_t;

#include "status.h"
#include "dis.h"

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


uint8_t hwRead8(offset_t offset);
uint16_t hwRead16(offset_t offset);

addr_t disMem(addr_t addr);
void loadData(data_t data);
void loadAddr(addr_t addr);
data_t readMemByte();
data_t readMemByteInc();
void writeMemByte();
void writeMemByteInc();
addr_t disMem(addr_t addr);

void doCmdBreak(char *params, modes_t mode);
void doCmdBreakI(char *params);
void doCmdBreakRdIO(char *params);
void doCmdBreakRdMem(char *params);
void doCmdBreakWrIO(char *params);
void doCmdBreakWrMem(char *params);
void doCmdClear(char *params);
void doCmdCompare(char *params);
void doCmdContinue(char *params);
void doCmdCopy(char *params);
void doCmdCrc(char *params);
void doCmdDis(char *params);
void doCmdExec(char *params);
void doCmdFlush(char *params);
void doCmdFill(char *params);
void doCmdGo(char *params);
void doCmdHelp(char *params);
#if defined(COMMAND_HISTORY)
void doCmdHistory(char *params);
void helpForCommand(uint8_t i);
#endif
void doCmdIO(char *params);
void doCmdList(char *params);
void doCmdLoad(char *params);
void doCmdMem(char *params);
void doCmdMode(char *params);
void doCmdNext(char *params);
void doCmdReadIO(char *params);
void doCmdReadMem(char *params);
void doCmdRegs(char *params);
void doCmdReset(char *params);
void doCmdStep(char *params);
void doCmdTest(char *params);
void doCmdSave(char *params);
void doCmdSRec(char *params);
void doCmdSpecial(char *params);
void doCmdTimerMode(char *params);
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
