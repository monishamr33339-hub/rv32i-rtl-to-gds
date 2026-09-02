#############################################
# OpenSTA Script for RV32I Pipeline
#############################################


#############################################
# Load Sky130 Liberty Library
#############################################

read_liberty \
/home/chaos/OpenSTA/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib



#############################################
# Load Synthesized Netlist
#############################################

read_verilog \
../netlist/rv32i_netlist.v



#############################################
# Select Top Module
#############################################

link_design pipeline_datapath



#############################################
# Read Timing Constraints
#############################################

read_sdc \
../constraints/rv32i.sdc



#############################################
# Timing Analysis Reports
#############################################

# Setup timing report

report_checks \
-path_delay max \
-format full_clock \
> ../reports/setup_timing.rpt



# Hold timing report

report_checks \
-path_delay min \
-format full_clock \
> ../reports/hold_timing.rpt



# Worst Negative Slack

report_wns \
> ../reports/worst_slack.rpt



# Total Negative Slack

report_tns \
> ../reports/total_slack.rpt



# Clock skew report

report_clock_skew \
> ../reports/clock_skew.rpt



# Clock properties

report_clock_properties \
> ../reports/clock_report.rpt



#############################################
# Console Summary
#############################################

puts "======================================"
puts " RV32I OpenSTA Timing Analysis Complete "
puts " Reports Generated in ../reports "
puts "======================================"
