/*
	Status.h

	Functions for logging program status to the serial port, to
	be used for debugging pruposes etc.

	2008-03-21, P.Harvey-Smith.

	Some functions and macros borrowed from Dean Camera's LURFA
	USB libraries.

*/

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <stdbool.h>
#include <stdio.h>


#ifndef __STATUS_DEFINES__
#define __STATUS_DEFINES__



/********************************************************
 * Simple string logger, as log0 is expensive
 ********************************************************/

#define logstr(s) logpgmstr(PSTR((s)))

void logc(char c);
void logs(const char *s);
void logpgmstr(const char *s);
void loghex1(uint8_t i);
void loghex2(uint8_t i);
void loghex4(uint16_t i);
void logint(int i);
void loglong(long i);
char *strfill(char *buffer, char c, uint8_t i);
char *strhex1(char *buffer, uint8_t i);
char *strhex2(char *buffer, uint8_t i);
char *strhex4(char *buffer, uint16_t i);
char *strint(char *buffer, int i);
char *strlong(char *buffer, long i);
char *strinsert(char *buffer, const char *s);

char *parselong(char *params,     long *val);
char *parsehex2required(char *params,  uint8_t *val);
char *parsehex4required(char *params, uint16_t *val);
char *parsehex2(char *params,  uint8_t *val);
char *parsehex4(char *params, uint16_t *val);

#define log0(format,...) fprintf_P(&ser0stream,PSTR(format),##__VA_ARGS__)

//
// For stdio
//

extern FILE ser0stream;

/* Default baud rate if 0 passed to Serial_Init */

#define DefaultBaudRate	9600

/** Indicates whether a character has been received through the USART - boolean false if no character
 *  has been received, or non-zero if a character is waiting to be read from the reception buffer.
 */
#define Serial_IsCharReceived() ((UCSR1A & (1 << RXC1)) ? true : false)

/** Macro for calculating the baud value from a given baud rate when the U2X (double speed) bit is
 *  not set.
 */
#define SERIAL_UBBRVAL(baud)    (((F_CPU / 16) / baud) - 1)

/** Macro for calculating the baud value from a given baud rate when the U2X (double speed) bit is
 *  set.
 */
#define SERIAL_2X_UBBRVAL(baud) (((F_CPU / 8) / baud) - 1)

#define SerEOL0()	{ Serial_TxByte0('\r'); Serial_TxByte0('\n'); }

#ifdef NOUSART1
#undef UCSR1A
#endif

void USART_Init0(const uint32_t BaudRate);
void Serial_TxByte0(const char DataByte);
char Serial_RxByte0(void);
uint8_t Serial_ByteRecieved0(void);

void Serial_Init(const uint32_t BaudRate0);

void cls();

#endif
