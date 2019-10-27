XILINX      ?= /opt/Xilinx/14.7

PATH       := $(PATH):${XILINX}/ISE_DS/ISE/bin/lin64:${PAPILIO}/linux64
SHELL      := env PATH=$(PATH) /bin/bash

build: working/$(TARGET).bit

working/$(TARGET).bit:
	# create a working directory if necessary
	mkdir -p working
	# use the xilinx tools to synthesise the project and generate a bitstream file
	xtclsh $(COMMON)/ise_build.tcl $(TARGET).xise

clean:
	rm -rf working/ iceconfig/

clobber: clean
