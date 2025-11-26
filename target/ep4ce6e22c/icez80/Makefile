# The root directory of the project
ROOT       = ../../..

# The common directory for makefile includes, etc.
COMMON     = ../../common

# The target bitstream file to be generated including the monitor program
TARGET     = icez80

# Frequuency that the AVR runs at
F_CPU      = 24000000

# Default Baud Rate of serial interface
# Note: F_CPU / 16 / BAUD need to be close to an integer
BAUD       = 115200

# Common include files
include $(COMMON)/Makefile_$(TARGET).inc
include $(COMMON)/Makefile_Altera.inc
