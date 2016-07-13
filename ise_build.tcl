#!/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin/xtclsh

project open AtomBusMon.xise
process run "Generate Programming File"
project close

project open AtomCpuMon.xise
process run "Generate Programming File"
project close

project open AtomFast6502.xise
process run "Generate Programming File"
project close

project open Z80CpuMon.xise
process run "Generate Programming File"
project close

project open MC6809ECpuMon.xise
process run "Generate Programming File"
project close

exit
