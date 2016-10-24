#!/bin/bash

# Base defaults to 250, but can be passed in
BASE=${1:-250}
DESIGNS="6502cpu 6502fast 6502mon z80cpu 6809cpu"
DATE=$(date +"%Y%m%d_%H%M")

VERSION=$(grep "define VERSION" firmware/AtomBusMon.c | cut -d\" -f2)

DIR=releases/$BASE/$VERSION/$DATE/

echo "Building release in: "$DIR

mkdir -p $DIR

pushd firmware

# Compile the firmware and inject into the .bit file
for i in $DESIGNS
do
make -f Makefile.$i clean
make -f Makefile.$i SRC_DIR=src/${BASE} WORKING_DIR=working/${BASE}
ls -l *.bit
done

# Create a .MCS file and move to releases directory
# . /opt/Xilinx/14.7/ISE_DS/settings*.sh
for i in $DESIGNS
do
NAME=avr${i}
/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin/promgen -u 0 $NAME.bit -o $NAME.mcs -p mcs -w -spi -s 8192
mv $NAME.mcs ../$DIR
rm -f $NAME.bit $NAME.cfi $NAME.prm
done

popd

echo "Built release in: "$DIR
ls -lt $DIR
 
