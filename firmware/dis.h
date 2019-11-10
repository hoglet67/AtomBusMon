#ifndef __DIS_DEFINES__
#define __DIS_DEFINES__

// The processor dependent config/status port
#define PDC_PORT         PORTA
#define PDC_DDR          DDRA
#define PDC_DIN          PINA

addr_t disassemble(addr_t addr);

#endif
