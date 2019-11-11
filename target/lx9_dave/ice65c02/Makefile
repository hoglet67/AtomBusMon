# The root directory of the project
ROOT       = ../../..

# The common directory for makefile includes, etc.
COMMON     = ../../common

# The project .bit file produced by the Xilinx .xise project
PROJECT    = MOS6502CpuMonALS

# The target .bit file to be generated including the monitor program
TARGET     = ice65c02

# Frequuency that the AVR runs at
F_CPU      = 24000000

# Default Baud Rate of serial interface
# Note: F_CPU / 16 / BAUD need to be close to an integer
BAUD       = 115200

# Common include files
include $(COMMON)/Makefile_$(TARGET).inc
include $(COMMON)/Makefile.inc
