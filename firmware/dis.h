#ifndef __DIS_DEFINES__
#define __DIS_DEFINES__

// The processor dependent config/status port
#define PDC_PORT         PORTA
#define PDC_DDR          DDRA
#define PDC_DIN          PINA

unsigned int disassemble(unsigned int addr);

#endif
