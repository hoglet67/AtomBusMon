#!/bin/bash
. /opt/Xilinx/14.7/ISE_DS/settings64.sh

# The S25FL032P has space for ~12 designs if they are uncompressed
#
#-u 1F8000                                       \
#-u 24C000                                       \
#-u 2A0000                                       \
#-u 2F4000                                       \
#-u 348000                                       \
#-u 39C000                                       \

DIR=icemulti

NAME=${DIR}/icemulti

mkdir -p ${DIR}

promgen                                          \
 -u      0 loader/MultiBootLoader.bit            \
 -u  54000 unknown/UnknownAdapter.bit            \
 -u  A8000 ice6502/ice6502.bit                   \
 -u  FC000 icez80/icez80.bit                     \
 -u 150000 ice65c02/ice65c02.bit                 \
 -u 1A4000 ice6809/ice6809.bit                   \
 -o $NAME.mcs  -p mcs -w -spi -s 8192

rm -f $NAME.cfi $NAME.prm
