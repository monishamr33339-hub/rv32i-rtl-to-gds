import sys
import pya

input_gds = "results/final/rv32i_final.gds"
output_gds = "results/final/rv32i_clean.gds"
target_top = "pipeline_datapath"

# Read original layout
orig_layout = pya.Layout()
orig_layout.read(input_gds)

target_cell = None
for idx in orig_layout.each_top_cell():
    c = orig_layout.cell(idx)
    if c.name == target_top:
        target_cell = c
        break

if not target_cell:
    print(f"ERROR: Could not find cell '{target_top}'!")
    sys.exit(1)

# Create a brand new clean layout and copy ONLY the target cell hierarchy
clean_layout = pya.Layout()
clean_layout.dbu = orig_layout.dbu

new_top = clean_layout.create_cell(target_top)
new_top.copy_tree(target_cell)

# Verify single top cell condition
top_count = len([idx for idx in clean_layout.each_top_cell()])
print(f"--> Clean layout created with {top_count} top cell(s): {new_top.name}")
print(f"--> Writing to {output_gds}...")

clean_layout.write(output_gds)
print("--> Done!")
