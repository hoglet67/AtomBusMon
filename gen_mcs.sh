#!/bin/bash

DESIGNS="6502cpu 6502fast 6502mon z80cpu 6809cpu"
DATE=$(date +"%Y%m%d_%H%M")

VERSION=$(grep "define VERSION" firmware/AtomBusMon.c | cut -d\" -f2)

DIR=releases/$VERSION/$DATE

mkdir -p $DIR

pushd firmware

# Compile the firmware and inject into the .bit file
for i in $DESIGNS
do
make -f Makefile.$i clean
make -f Makefile.$i
done

# Create a .MCS file and move to releases directory
. /opt/Xilinx/14.7/ISE_DS/settings*.sh
for i in $DESIGNS
do
NAME=avr${i}
promgen -u 0 $NAME.bit -o $NAME.mcs -p mcs -w -spi -s 8192
mv $NAME.mcs ../$DIR
rm -f $NAME.bit $NAME.cfi $NAME.prm
done

popd

ls -lt $DIR
 
