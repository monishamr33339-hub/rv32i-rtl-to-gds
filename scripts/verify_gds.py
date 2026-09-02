import os
import sys
import pya

gds_file = "results/final/rv32i_final.gds"

if not os.path.exists(gds_file):
    print(f"ERROR: File {gds_file} does not exist.")
    sys.exit(1)

layout = pya.Layout()
layout.read(gds_file)

# Fetch top cell indices and convert to pya.Cell objects
top_cell_indices = [idx for idx in layout.each_top_cell()]
top_cells = [layout.cell(idx) for idx in top_cell_indices]

print("=======================================================")
print(" GDSII HIERARCHY AUDIT")
print("=======================================================")
print(f" Total Cells in Layout : {layout.cells()}")
print(f" Total Top-Level Cells : {len(top_cells)}")
print(f" Active Layers         : {len(layout.layer_indexes())}")

# Identify core design module (look for 'rv32' / 'core' or pick cell with child instances)
design_top = None
for cell in top_cells:
    if "rv32" in cell.name.lower() or "core" in cell.name.lower():
        design_top = cell
        break

# Fallback: pick the top cell that references the most child cells
if not design_top and top_cells:
    design_top = max(top_cells, key=lambda c: c.child_cells())

if design_top:
    print(f" Core Module Top Cell  : {design_top.name}")
    print(f" Sub-cell References   : {design_top.child_cells()}")
else:
    print(" WARNING: Could not automatically isolate core module top cell.")

# Check shape counts in standard cells to verify physical geometries merged
print("\n--- Top 5 Standard Cells by Primitive Shape Count ---")
cell_shape_counts = []

for cell in layout.each_cell():
    if design_top and cell.cell_index() == design_top.cell_index():
        continue
    # Sum up shapes across all active layers in the cell
    shapes_in_cell = sum(cell.shapes(layer).size() for layer in layout.layer_indexes())
    if shapes_in_cell > 0:
        cell_shape_counts.append((cell.name, shapes_in_cell))

cell_shape_counts.sort(key=lambda x: x[1], reverse=True)

for name, count in cell_shape_counts[:5]:
    print(f" - Cell: {name:<38} | Shapes: {count}")

print("=======================================================")
if cell_shape_counts:
    print(" VERIFICATION SUCCESS: Standard cell physical shapes merged successfully!")
else:
    print(" WARNING: Merged standard cells contain 0 shapes. Check GDS paths.")
print("=======================================================")
