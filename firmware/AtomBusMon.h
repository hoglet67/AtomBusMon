#ifndef __ATOMBUSMON_DEFINES__
#define __ATOMBUSMON_DEFINES__

#include "status.h"
#include "dis.h"

#ifdef LCD
#include "hd44780.h"
#endif

#ifdef CPUEMBEDDED
unsigned int disMem(unsigned int addr);
void loadData(unsigned int data);
void loadAddr(unsigned int addr);
unsigned int readByte();
unsigned int readByteInc();
void writeByte();
void writeByteInc();
unsigned int disMem(unsigned int addr);
#endif

#endif
