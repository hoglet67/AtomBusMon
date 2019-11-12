/*
	Status.c

	Functions for logging program status to the serial port, to
	be used for debugging pruposes etc.

	2008-03-21, P.Harvey-Smith.

*/

#include <stdio.h>
#include <stdlib.h>
#include "terminalcodes.h"
#include "status.h"

static int StdioSerial_TxByte0(char DataByte, FILE *Stream);

FILE ser0stream = FDEV_SETUP_STREAM(StdioSerial_TxByte0,NULL,_FDEV_SETUP_WRITE);

void StdioSerial_TxByte(char DataByte)
{
  if((DataByte=='\r') || (DataByte=='\n')) {
    Serial_TxByte0('\r');
    Serial_TxByte0('\n');
  } else {
    Serial_TxByte0(DataByte);
  }
}

int StdioSerial_TxByte0(char DataByte, FILE *Stream)
{
	StdioSerial_TxByte(DataByte);
	return 0;
}

void cls()
{
  logs(ESC_ERASE_DISPLAY);
  logs(ESC_CURSOR_POS(0,0));
}


void USART_Init0(const uint32_t BaudRate)
{
#ifdef UCSR0A
	UCSR0A = 0;
	UCSR0B = ((1 << RXEN0) | (1 << TXEN0));
	UCSR0C = ((1 << UCSZ01) | (1 << UCSZ00));

	UBRR0  = SERIAL_UBBRVAL(BaudRate);
#else
	UCR = ((1 << RXEN)  | (1 << TXEN));

	UBRR  	= SERIAL_UBBRVAL(BaudRate);
#endif
}

/** Transmits a given byte through the USART.
 *
 *  \param DataByte  Byte to transmit through the USART
 */
void Serial_TxByte0(const char DataByte)
{
#ifdef UCSR0A
	while ( !( UCSR0A & (1<<UDRE0)) )		;
	UDR0=DataByte;
#else
	while ( !( USR & (1<<UDRE)) )		;
	UDR=DataByte;
#endif
}

/** Receives a byte from the USART.
 *
 *  \return Byte received from the USART
 */
char Serial_RxByte0(void)
{
#ifdef UCSR0A
	while (!(USR & (1 << RXC0)))	;
	return UDR0;
#else
	while (!(USR & (1<<RXC)))	;
	return UDR;
#endif
}

uint8_t Serial_ByteRecieved0(void)
{
#ifdef UCSR0A
	return (UCSR0A & (1 << RXC0));
#else
	return (USR & (1<<RXC));
#endif
}

void Serial_Init(const uint32_t BaudRate0)
{
	if (BaudRate0<=0)
		USART_Init0(DefaultBaudRate);
	else
		USART_Init0(BaudRate0);

	cls();
}

/********************************************************
 * Simple string logger, as log0 is expensive
 ********************************************************/

void logc(char c) {
  StdioSerial_TxByte(c);
}

void logs(const char *s) {
  while (*s) {
    logc(*s++);
  }
}

void logpgmstr(const char *s) {
  char c;
  do {
    c = pgm_read_byte(s++);
    if (c) {
      logc(c);
    }
  } while (c);
}

char hex1(uint8_t i) {
  i &= 0x0f;
  if (i < 10) {
    i += '0';
  } else {
    i += ('A' - 10);
  }
  return i;
}

void loghex1(uint8_t i) {
  logc(hex1(i));
}

void loghex2(uint8_t i) {
  loghex1(i >> 4);
  loghex1(i);
}

void loghex4(uint16_t i) {
  loghex2(i >> 8);
  loghex2(i);
}

void logint(int i) {
  char buffer[16];
  strint(buffer, i);
  logs(buffer);
}

void loglong(long i) {
  char buffer[16];
  strlong(buffer, i);
  logs(buffer);
}

char *strfill(char *buffer, char c, uint8_t i) {
  while (i-- > 0) {
    *buffer++ = c;
  }
  return buffer;
}

char *strhex1(char *buffer, uint8_t i) {
  *buffer++ = hex1(i);
  return buffer;
}

char *strhex2(char *buffer, uint8_t i) {
  buffer = strhex1(buffer, i >> 4);
  buffer = strhex1(buffer, i);
  return buffer;
}

char *strhex4(char *buffer, uint16_t i) {
  buffer = strhex2(buffer, i >> 8);
  buffer = strhex2(buffer, i);
  return buffer;
}

char *strint(char *buffer, int i) {
  return itoa(i, buffer, 10);
}

char *strlong(char *buffer, long i) {
  return ltoa(i, buffer, 10);
}

char *strinsert(char *buffer, const char *s) {
  while (*s) {
    *buffer++ = *s++;
  }
  return buffer;
}
