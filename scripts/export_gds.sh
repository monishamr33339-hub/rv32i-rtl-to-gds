#!/bin/bash
# ==============================================================================
# Sky130 DEF to GDSII Streamout Script using KLayout
# ==============================================================================

# 1. Path Definitions
export PDK_PATH=$PDK_ROOT/sky130A
export DEF_IN=results/final/rv32i_final.def
export GDS_OUT=results/final/rv32i_final.gds

# Create gds output directory if needed
mkdir -p results/final

echo "--> Converting $DEF_IN to $GDS_OUT..."

# 2. Run KLayout in batch mode using Sky130 PDK tech files
klayout -b \
  -rd design_def=$DEF_IN \
  -rd gds_output=$GDS_OUT \
  -rd tech_file=$PDK_PATH/libs.tech/klayout/tech/sky130A.lyt \
  -rd config_file=$PDK_PATH/libs.tech/klayout/tech/sky130A.lyp \
  -rd ly_layers=$PDK_PATH/libs.tech/klayout/tech/sky130A.lyp \
  -rd seal_file="" \
  -rm $PDK_PATH/libs.tech/klayout/scripts/def2gds.py

if [ -f "$GDS_OUT" ]; then
    echo "======================================================="
    echo " SUCCESS: GDSII streamout complete!"
    echo " Output file: $GDS_OUT"
    echo "======================================================="
else
    echo "ERROR: GDSII generation failed."
fi
