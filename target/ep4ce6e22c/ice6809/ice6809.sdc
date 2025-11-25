#**************************************************************
# Create Clock
#**************************************************************

# External clock input
create_clock -period "50 MHz"  -name clock_50 [get_ports clock]

#**************************************************************
# Create Generated Clock
#**************************************************************

# Doing this manually above so we can name the clock
derive_pll_clocks

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
#derive_clock_uncertainty
