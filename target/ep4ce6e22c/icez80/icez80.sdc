#**************************************************************
# Create Clock
#**************************************************************

# External 50MHz clock input from on-board crystal
create_clock -period "50 MHz"  -name clock_50 [get_ports clock]

# Z80 CLK_n clock input
create_clock -period "16 MHz"  -name clock_clk [get_ports CLK_n]

# Trig(0) clock input
create_clock -period "16 MHz"  -name clock_trig0 [get_ports TRIG[0]]

#**************************************************************
# Create Generated Clock
#**************************************************************

# Doing this manually above so we can name the clock
# derive_pll_clocks

#create_generated_clock -source {wrapper|inst_dcm0|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 25 -multiply_by 12 -duty_cycle 50.00 -name clock_avr {wrapper|inst_dcm0|altpll_component|auto_generated|pll1|clk[0]}

create_generated_clock -source [get_ports clock] -divide_by 25 -multiply_by 12 -duty_cycle 50.00 -name clock_avr {wrapper|inst_dcm0|altpll_component|auto_generated|pll1|clk[0]}

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty

#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group {clock_avr}   -group {clock_clk}
set_clock_groups -asynchronous -group {clock_clk}   -group {clock_avr}

set_clock_groups -asynchronous -group {clock_avr}   -group {clock_trig0}
set_clock_groups -asynchronous -group {clock_trig0} -group {clock_avr}
