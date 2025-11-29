VPATH      = $(ROOT)/firmware

QUARTUS    ?= $(HOME)/altera/13.0sp1/quartus/bin

PATH       := $(PATH):${QUARTUS}/bin
SHELL      := env PATH=$(PATH) /bin/bash

# Frequency of the AVR CPU
F_CPU       ?= 15855484

# Default Baud Rate of serial interface
# Note: F_CPU / 16 / BAUD need to be close to an integer
BAUD        ?= 57600

# AVR dev environment
MCU=atmega103
CC=avr-gcc
OBJCOPY=avr-objcopy

PROG = avr_progmem

CFLAGS=$(CPU_CFLAGS) -DF_CPU=${F_CPU}UL -DBAUD=${BAUD} -std=c99 -mmcu=$(MCU) -Wall -Os -mcall-prologues

OBJECTS=AtomBusMon.o status.o $(CPU_OBJECTS)

build: output_files/$(TARGET).pof

output_files/$(TARGET).pof: output_files/$(TARGET).sof
	quartus_cpf -c -d epcs4 $< $@

output_files/$(TARGET).sof: $(PROG).mif
	quartus_sh --flow compile $(TARGET)

$(PROG).mif: $(PROG).bin
	echo "WIDTH=16;" > $(PROG).mif
	echo "DEPTH=$(XPM_SIZE);" >> $(PROG).mif
	echo "ADDRESS_RADIX=UNS;" >> $(PROG).mif
	echo "DATA_RADIX=HEX;" >> $(PROG).mif
	echo "CONTENT BEGIN" >> $(PROG).mif
	od -An -tx2 -w2 -v $(PROG).bin | nl -v 0 | awk '{print $$1 " : " $$2 ";"}' >> $(PROG).mif
	echo "END;" >> $(PROG).mif

$(PROG).bin : $(PROG).out
	$(OBJCOPY) -R .comment -O binary $(PROG).out $(PROG).bin

$(PROG).out : $(OBJECTS)
	$(CC) $(CFLAGS) -o $(PROG).out -Wl,-Map,$(PROG).map $^

%.o : %.c
	$(CC) $(CFLAGS) -Os -c $<

%.o : %.S
	$(CC) $(CFLAGS) -Os -c $<

clean:
	rm -f $(PROG).mif $(PROG).bin $(PROG).out $(PROG).map *.o

clobber: clean
	rm -rf output_files/ db/ incremental_db/
