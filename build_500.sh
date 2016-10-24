#!/bin/bash

# Create custom versions of all the scripts and projects

sed "s/.xise/_500.xise/" < ise_clean.tcl > ise_clean_500.tcl
sed "s/.xise/_500.xise/" < ise_build.tcl > ise_build_500.tcl
chmod +x ./ise_clean_500.tcl 
chmod +x ./ise_build_500.tcl 

PROJECTS=`/bin/ls [A-Za-z0-9]*.xise`

for i in $PROJECTS
do
cat $i | sed "s/xc3s250e/xc3s500e/" | sed "s#working/250#working/500#" | sed "s#src/250#src/500#" | sed "s#ipcore/250#ipcore/500#" > `basename $i .xise`_500.xise
done

# Reset the logfile
rm -f build_500.log

# Compile the Xilinx Designs
./ise_clean_500.tcl 2>&1 | tee -a build_500.log
./ise_build_500.tcl 2>&1 | tee -a build_500.log

# Build the firmware release
./gen_mcs.sh 500 2>&1 | tee -a build_500.log

# Clean up
rm -f *_500.tcl
rm -f *_500.xise

