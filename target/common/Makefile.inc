VPATH      = $(ROOT)/firmware

XILINX      ?= /opt/Xilinx/14.7

PATH       := $(PATH):${XILINX}/ISE_DS/ISE/bin/lin64:${PAPILIO}/linux64
SHELL      := env PATH=$(PATH) /bin/bash

# Frequency of the AVR CPU
F_CPU       ?= 15855484

# Default Baud Rate of serial interface
# Note: F_CPU / 16 / BAUD need to be close to an integer
BAUD        ?= 57600

# Path of the back anotated block memory map file
BMM_FILE    ?= memory_bd.bmm

# AVR dev environment
MCU=atmega103
CC=avr-gcc
OBJCOPY=avr-objcopy

PROG = avr_progmem

CFLAGS=$(CPU_CFLAGS) -DF_CPU=${F_CPU}UL -DBAUD=${BAUD} -mmcu=$(MCU) -Wall -Os -mcall-prologues

OBJECTS=AtomBusMon.o status.o $(CPU_OBJECTS)

build: $(TARGET).mcs

$(TARGET).mcs: $(TARGET).bit
	promgen -u 0 $(TARGET).bit -o $(TARGET).mcs -p mcs -w -spi -s 8192
	rm -f $(TARGET).cfi $(TARGET).prm

working/$(PROJECT).bit:
	# create a working directory if necessary
	mkdir -p working
	# use the xilinx tools to synthesise the project and generate a bitstream file
	xtclsh $(COMMON)/ise_build.tcl $(TARGET).xise

$(TARGET).bit: $(PROG).mem working/$(PROJECT).bit
	data2mem -bm $(BMM_FILE) -bd $(PROG).mem -bt working/$(PROJECT).bit -o b $(TARGET).bit

$(PROG).mem: $(PROG).bin
	od -An -tx1 -w16 -v <$(PROG).bin >$(PROG).mem

$(PROG).bin : $(PROG).out
	$(OBJCOPY) -R .comment --reverse-bytes=2 -O binary $(PROG).out $(PROG).bin

$(PROG).out : $(OBJECTS)
	$(CC) $(CFLAGS) -o $(PROG).out -Wl,-Map,$(PROG).map $^

%.o : %.c
	$(CC) $(CFLAGS) -Os -c $<

%.o : %.S
	$(CC) $(CFLAGS) -Os -c $<

clean:
	rm -f $(TARGET).bit $(TARGET).mcs $(PROG).mem $(PROG).bin $(PROG).out $(PROG).map *.o

clobber: clean
	rm -rf $(BMM_FILE) working/ iseconfig/
