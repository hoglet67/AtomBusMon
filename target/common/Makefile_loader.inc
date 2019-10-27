XILINX      ?= /opt/Xilinx/14.7

PATH       := $(PATH):${XILINX}/ISE_DS/ISE/bin/lin64:${PAPILIO}/linux64
SHELL      := env PATH=$(PATH) /bin/bash

build: $(TARGET).bit

$(TARGET).bit:
	# create a working directory if necessary
	mkdir -p working
	# use the xilinx tools to synthesise the project and generate a bitstream file
	xtclsh $(COMMON)/ise_build.tcl $(TARGET).xise
	cp working/$(TARGET).bit $(TARGET).bit

clean:
	rm -rf working/ iceconfig/

clobber: clean
