VPATH      = $(ROOT)/firmware

XILINX      ?= /opt/Xilinx/14.7

PATH       := $(PATH):${XILINX}/ISE_DS/ISE/bin/lin:${PAPILIO}/linux32
SHELL      := env PATH=$(PATH) /bin/bash

# Frequency of the AVR CPU
F_CPU       ?= 15855484

# Path of the back anotated block memory map file
BMM_FILE    ?= memory_bd.bmm

# AVR dev environment
MCU=atmega103
CC=avr-gcc
OBJCOPY=avr-objcopy

PROG = avr_progmem

CFLAGS=$(CPU_CFLAGS) -DF_CPU=${F_CPU}UL -DSERIAL_STATUS -DCOOKED_SERIAL -DNOUSART1 -mmcu=$(MCU) -Wall -Os -mcall-prologues

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

$(PROG).mem: $(PROG).hex
	srec_cat  $< -Intel -Byte_Swap 2  -Data_Only -o tmp.mem -vmem 8
	gawk ' BEGIN{FS=" ";} { $$1= ""; print}' tmp.mem > $@
	rm tmp.mem

$(PROG).hex : $(PROG).out 
	$(OBJCOPY) -R .eeprom -O ihex $(PROG).out $(PROG).hex 

$(PROG).out : $(OBJECTS)
	$(CC) $(CFLAGS) -o $(PROG).out -Wl,-Map,$(PROG).map $^

%.o : %.c 
	$(CC) $(CFLAGS) -Os -c $<

%.o : %.S
	$(CC) $(CFLAGS) -Os -c $<

clean:
	rm -f $(TARGET).bit $(TARGET).mcs $(PROG).mem $(PROG).hex $(PROG).out $(PROG).map *.o

clobber: clean
	rm -rf $(BMM_FILE) working/ iceconfig/
