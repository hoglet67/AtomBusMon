#ifndef __DIS_DEFINES__
#define __DIS_DEFINES__

// The processor dependent config/status port
#define PDC_PORT         PORTA
#define PDC_DDR          DDRA
#define PDC_DIN          PINA

#define MODE_NORMAL      0
#define MODE_DIS_CMD     1

addr_t disassemble(addr_t addr, uint8_t m);


#endif
