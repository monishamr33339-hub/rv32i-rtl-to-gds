# ==============================================================================
# run_lvs.tcl - Netgen LVS Script
# ==============================================================================

if {![info exists ::env(PDK_ROOT)]} {
    puts "Error: PDK_ROOT environment variable is not defined!"
    exit 1
}

# Paths
set pdk_dir     "$::env(PDK_ROOT)/sky130A"
set setup_file  "$pdk_dir/libs.tech/netgen/sky130A_setup.tcl"
set std_cdl     "$pdk_dir/libs.ref/sky130_fd_sc_hd/cdl/sky130_fd_sc_hd.cdl"

set layout_netlist    "results/final/rv32i_extracted.spice"
set schematic_netlist "netlist/rv32i_schematic.spice"
set log_file          "results/final/lvs_report.log"
set top_cell          "pipeline_datapath"

# 1. Source Sky130 PDK Setup Rules
source $setup_file

# 2. Equate Global Power & Substrate Nodes
equate nodes "VPWR" "VPB"
equate nodes "VGND" "VNB"

# 3. Execute LVS Comparison
lvs "$layout_netlist $top_cell" \
    "$schematic_netlist $top_cell $std_cdl" \
    $setup_file \
    $log_file
