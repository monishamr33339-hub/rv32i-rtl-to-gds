#############################################
# RV32I Pipeline CPU Timing Constraints
# OpenSTA Compatible SDC
#
# Target Frequency: 100 MHz
# Clock Period: 10 ns
#############################################


#############################################
# Clock Definition
#############################################

create_clock \
    -name clk \
    -period 10 \
    [get_ports clk]


#############################################
# Clock Uncertainty
#############################################

set_clock_uncertainty 0.2 \
    [get_clocks clk]


#############################################
# Input Delays
#############################################

# No external synchronous data inputs.
# Instruction memory and data memory are internal.
# Therefore only clock/reset enter the design.


#############################################
# Output Delays
#############################################

set_output_delay 1.0 \
    -clock clk \
    [all_outputs]


#############################################
# Reset Handling
#############################################

# Reset is asynchronous.
# Exclude reset from normal timing paths.

set_false_path \
    -from [get_ports reset]


#############################################
# Clock Transition
#############################################

set_clock_transition 0.1 \
    [get_clocks clk]


#############################################
# Fanout Constraint
#############################################

set_max_fanout 16 \
    [current_design]


#############################################
# End
#############################################
