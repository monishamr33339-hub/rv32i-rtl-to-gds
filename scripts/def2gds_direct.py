import os
import sys
import pya

pdk_root = os.environ.get("PDK_ROOT")
if not pdk_root:
    print("ERROR: PDK_ROOT environment variable not set!")
    sys.exit(1)

def_file = "results/final/rv32i_final.def"
gds_out = "results/final/rv32i_final.gds"

# Paths to Sky130 LEF & GDS files
tech_lef = os.path.join(
    pdk_root, "sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
)
cell_lef = os.path.join(
    pdk_root, "sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
)
stdcell_gds = os.path.join(
    pdk_root, "sky130A/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds"
)

main_layout = pya.Layout()

# 1. Configure LEF/DEF Load Options
print(f"--> Setting up LEF/DEF Load Options:\n    1. {tech_lef}\n    2. {cell_lef}")
opt = pya.LoadLayoutOptions()

# Configure LEF files via lefdef_config property
opt.lefdef_config.lef_files = [tech_lef, cell_lef]

# 2. Read DEF layout with LEF options enabled
print(f"--> Reading DEF File: {def_file}")
main_layout.read(def_file, opt)

# 3. Read & Merge Physical Standard Cell GDS Geometries
if os.path.exists(stdcell_gds):
    print(f"--> Merging Standard Cell GDS Geometries: {stdcell_gds}")
    main_layout.read(stdcell_gds)
else:
    print(f"ERROR: Standard cell GDS not found at {stdcell_gds}")
    sys.exit(1)

# 4. Stream out final merged GDSII layout file
print(f"--> Writing merged GDSII layout to {gds_out}...")
main_layout.write(gds_out)

print("=======================================================")
print(" SUCCESS: GDSII File Written Successfully!")
print(f" Output layout: {gds_out}")
print("=======================================================")
