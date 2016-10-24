#!/bin/bash

# Reset the logfile
rm -f build_250.log

# Compile the Xilinx Designs
./ise_clean.tcl 2>&1 | tee -a build_250.log
./ise_build.tcl 2>&1 | tee -a build_250.log

# Build the firmware release
./gen_mcs.sh 250  2>&1 | tee -a build_250.log

