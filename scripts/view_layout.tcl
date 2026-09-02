# scripts/view_layout.tcl
set pdk_path $::env(PDK_ROOT)/sky130A

read_lef $pdk_path/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef $pdk_path/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef

# Change this path to whichever DEF you want to view:
read_def results/final/rv32i_final.def

# Automatically zoom to fit design die area
gui::fit
