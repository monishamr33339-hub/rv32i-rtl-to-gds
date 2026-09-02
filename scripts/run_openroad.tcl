# ==============================================================================
# OpenROAD Physical Design Script for RV32I Core (Sky130A)
# ==============================================================================

# 1. Path & Setup Definitions
set pdk_path $::env(PDK_ROOT)/sky130A
set netlist  "netlist/rv32i_netlist.v"
set sdc      "constraints/rv32i.sdc"
set top_cell "pipeline_datapath"

# Create output subdirectories
file mkdir results/floorplan
file mkdir results/placement
file mkdir results/cts
file mkdir results/routing
file mkdir results/final

# 2. Read Technology & Cell LEFs
puts "--> Reading Sky130 LEF files..."
read_lef $pdk_path/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef $pdk_path/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef

# 3. Read Liberty Timing Models
puts "--> Reading Sky130 Liberty timing models..."
read_liberty $pdk_path/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# 4. Read Gate-Level Netlist & Link
puts "--> Reading Netlist: $netlist"
read_verilog $netlist
link_design $top_cell

# 5. Read SDC Constraints
puts "--> Reading Constraints: $sdc"
read_sdc $sdc

# ==============================================================================
# STEP 1: FLOORPLANNING & PIN PLACEMENT
# ==============================================================================
puts "--> Running Floorplan..."
initialize_floorplan -utilization 35 -aspect_ratio 1.0 -core_space 10 -site unithd
make_tracks
place_pins -hor_layer met3 -ver_layer met2

# Save Floorplan DEF
write_def results/floorplan/rv32i_floorplan.def
puts "--> Floorplan Complete!"

# ==============================================================================
# STEP 2: POWER DISTRIBUTION NETWORK (PDN)
# ==============================================================================
puts "--> Building Power Distribution Network (PDN)..."

# Connect global VDD and VSS to cell power/ground pins
add_global_connection -net VDD -inst_pattern .* -pin_pattern VPWR -power
add_global_connection -net VSS -inst_pattern .* -pin_pattern VGND -ground

# Specify core voltage domain
set_voltage_domain -name Core -power VDD -ground VSS

# Define standard cell power grid on met1 following row pins
define_pdn_grid -name stdcell_grid -starts_with POWER -voltage_domains Core
add_pdn_stripe -grid stdcell_grid -layer met1 -width 0.48 -followpins

pdngen
puts "--> PDN Complete!"

# ==============================================================================
# STEP 3: GLOBAL & DETAILED PLACEMENT
# ==============================================================================
puts "--> Running Global Placement..."
global_placement -density 0.65

puts "--> Running Detailed Placement..."
detailed_placement
check_placement

# Save Placed DEF
write_def results/placement/rv32i_placed.def
puts "--> Placement Complete! Output saved to results/placement/rv32i_placed.def"

# ==============================================================================
# STEP 4: CLOCK TREE SYNTHESIS (CTS)
# ==============================================================================
puts "--> Running Clock Tree Synthesis (CTS)..."

# Synthesize clock tree using Sky130 clock buffers
clock_tree_synthesis -buf_list {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8}

# Legalize placement after clock buffer insertion
detailed_placement

# Save CTS DEF
write_def results/cts/rv32i_cts.def
puts "--> CTS Complete!"

# ==============================================================================
# STEP 5: GLOBAL & DETAILED ROUTING
# ==============================================================================
puts "--> Running Global Routing..."
global_route

puts "--> Running Detailed Routing..."
# Reinforce signal net type before detailed routing
foreach net_name {one_ zero_} {
    set db_net [[ord::get_db_block] findNet $net_name]
    if {$db_net != "NULL"} {
        $db_net setSigType "SIGNAL"
    }
}

detailed_route

# Save Final Layout Output
write_def results/final/rv32i_final.def
puts "--> Routing Complete! Final DEF saved to results/final/rv32i_final.def"

# ==============================================================================
# STEP 6: RC EXTRACTION & POST-ROUTE STA
# ==============================================================================
puts "--> Running RC Extraction..."

# Set default routing layer for parasitics estimation
set_wire_rc -layer met2

# Extract wire resistance & capacitance from detailed routing geometries
estimate_parasitics -global_routing

puts "--> Generating Post-Route Timing Reports..."

# Create reports directory
file mkdir reports

# 1. Report Worst Setup Slack (Max Path)
report_checks -path_delay max \
              -fields {slew cap input net fanout} \
              -format full_clock_expanded \
              -digits 4 > reports/setup_timing.rpt

# 2. Report Worst Hold Slack (Min Path)
report_checks -path_delay min \
              -fields {slew cap input net fanout} \
              -format full_clock_expanded \
              -digits 4 > reports/hold_timing.rpt

# 3. Print Summary to Terminal
puts "\n======================================================="
puts "                 TIMING SUMMARY METRICS                "
puts "======================================================="
report_wns
report_tns
report_clock_skew
puts "=======================================================\n"

puts "--> STA Complete! Reports saved to reports/setup_timing.rpt and reports/hold_timing.rpt"

exit
