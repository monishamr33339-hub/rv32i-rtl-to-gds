# RV32I RTL-to-GDS ASIC Flow

A complete RTL-to-GDSII implementation of an **RV32I RISC-V processor datapath** using open-source ASIC design tools and the **SKY130A** process design kit.

The project demonstrates the digital ASIC implementation flow from synthesizable RTL through logic synthesis, floorplanning, placement, clock-tree synthesis, routing, physical verification, and GDSII generation.

> **Project Status:** GDSII generation and physical-layout verification infrastructure are functional. LVS comparison is currently under investigation due to extracted top-level connectivity and port/net correspondence mismatches.

---

## Architecture

The design implements an RV32I processor datapath with a 32-bit RISC-V architecture.

High-level flow:

```text
                RV32I RTL
                    │
                    ▼
              Yosys Synthesis
                    │
                    ▼
          Gate-Level Netlist
                    │
                    ▼
              OpenROAD
                    │
          ┌─────────┴─────────┐
          │                   │
          ▼                   ▼
     Floorplanning           PDN
          │
          ▼
       Placement
          │
          ▼
          CTS
          │
          ▼
        Routing
          │
          ▼
       Final DEF
          │
          ▼
      KLayout / GDSII
          │
          ▼
      Physical Verification
          │
          ▼
          LVS
```

---

## Project Goals

* Implement and synthesize an RV32I processor datapath.
* Convert RTL into a standard-cell gate-level netlist.
* Perform ASIC floorplanning using OpenROAD.
* Create power-distribution structures.
* Perform standard-cell placement.
* Perform clock-tree synthesis.
* Perform global and detailed routing.
* Generate a final DEF layout.
* Convert the routed design into GDSII.
* Inspect and verify the generated physical layout.
* Run LVS using the SKY130A technology stack.
* Document the complete RTL-to-GDS flow.

---

## Technology

| Component         | Technology / Tool       |
| ----------------- | ----------------------- |
| ISA               | RISC-V RV32I            |
| Data Width        | 32-bit                  |
| PDK               | SKY130A                 |
| Standard Cells    | SKY130 HD               |
| RTL               | Verilog / SystemVerilog |
| Synthesis         | Yosys                   |
| Physical Design   | OpenROAD                |
| Layout / GDS      | KLayout                 |
| Layout Extraction | Magic                   |
| LVS               | KLayout / Netgen        |
| Physical Format   | DEF / GDSII             |

---

## Repository Structure

```text
rv32i-rtl-to-gds/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── rtl/
│   └── *.v
│
├── constraints/
│   └── rv32i.sdc
│
├── netlist/
│   └── rv32i_netlist.v
│
├── scripts/
│   ├── run_openroad.tcl
│   ├── export_gds.sh
│   ├── def2gds_direct.py
│   ├── verify_gds.py
│   ├── clean_gds.py
│   ├── run_lvs.tcl
│   └── view_layout.tcl
│
├── results/
│   └── final/
│       ├── rv32i_final.def
│       └── rv32i_final.gds
│
├── reports/
│   ├── setup_timing.rpt
│   └── hold_timing.rpt
│
└── docs/
    ├── architecture.png
    ├── floorplan.png
    ├── routed_layout.png
    └── lvs_status.md
```

---

## RTL

The RTL describes the RV32I processor datapath before synthesis.

The main physical-design top-level cell is:

```text
pipeline_datapath
```

The design interface contains the processor datapath signals together with the required physical-design power and ground connections.

---

## Synthesis

Yosys is used to synthesize the RTL into a gate-level netlist using SKY130 standard cells.

The synthesized netlist is:

```text
netlist/rv32i_netlist.v
```

The synthesis stage converts RTL logic into technology-mapped standard-cell instances suitable for physical implementation.

---

## Physical Design

OpenROAD is used for the physical implementation flow.

The flow includes:

1. Technology and standard-cell library loading
2. Floorplan initialization
3. Standard-cell site generation
4. Routing-track generation
5. Power-distribution network generation
6. Global placement
7. Detailed placement
8. Clock-tree synthesis
9. Global routing
10. Detailed routing
11. Parasitic estimation
12. Timing analysis
13. DEF generation

The final physical design is written to:

```text
results/final/rv32i_final.def
```

---

## GDSII Generation

The routed DEF is converted into GDSII using KLayout and the SKY130 technology and standard-cell data.

Final layout:

```text
results/final/rv32i_final.gds
```

The generated GDS contains the physical geometry of the synthesized and routed RV32I design together with the required standard-cell geometries.

---

## Physical Verification

The generated GDS is checked for:

* Correct top-level cell
* Standard-cell geometry
* Cell hierarchy
* Active layers
* Physical layout completeness
* Top-level interface labels

The primary top-level layout cell is:

```text
pipeline_datapath
```

---

## LVS Status

KLayout LVS is used to compare the physical layout against the schematic/netlist representation.

### Current status

```text
GDS generation       : COMPLETE
DEF generation       : COMPLETE
Layout inspection    : COMPLETE
Standard-cell merge  : COMPLETE
LVS extraction       : COMPLETE
LVS comparison       : IN PROGRESS
```

The current LVS investigation is focused on **top-level extracted connectivity and port/net correspondence**.

The layout contains the expected top-level signal labels, while the extracted representation requires further investigation to obtain a clean schematic-to-layout correspondence.

This status is intentionally documented rather than claiming an LVS-clean result that has not yet been achieved.

---

## Important Outputs

### Gate-level netlist

```text
netlist/rv32i_netlist.v
```

### Final DEF

```text
results/final/rv32i_final.def
```

### Final GDSII

```text
results/final/rv32i_final.gds
```

### Timing reports

```text
reports/setup_timing.rpt
reports/hold_timing.rpt
```

### LVS information

```text
results/final/
```

---

## Running the Flow

### 1. Set the SKY130A environment

```bash
export PDK_ROOT=/home/chaos/PDKs
```

Make sure the SKY130A PDK is available at:

```text
$PDK_ROOT/sky130A
```

### 2. Run synthesis

Run the project synthesis flow to generate:

```text
netlist/rv32i_netlist.v
```

### 3. Run OpenROAD

From the project root:

```bash
openroad scripts/run_openroad.tcl
```

This generates the routed DEF and timing reports.

### 4. Generate GDSII

Run the DEF-to-GDS conversion:

```bash
python3 scripts/def2gds_direct.py
```

This produces:

```text
results/final/rv32i_final.gds
```

### 5. Verify the GDS

The GDS verification script requires KLayout's Python environment:

```bash
klayout -b -r scripts/verify_gds.py
```

---

## Design Flow Environment

The project was developed and tested in a Linux environment using the following open-source ASIC tools:

```text
Yosys
OpenROAD
KLayout
Magic
Netgen
SKY130A PDK
```

---

## Results

The project successfully demonstrates the following stages:

* [x] RV32I RTL
* [x] RTL synthesis
* [x] Technology-mapped netlist
* [x] Floorplanning
* [x] Power distribution
* [x] Placement
* [x] Clock-tree synthesis
* [x] Routing
* [x] DEF generation
* [x] GDSII generation
* [x] GDS physical inspection
* [x] LVS extraction
* [ ] Clean LVS sign-off

---

## Skills Demonstrated

This project demonstrates practical experience with:

* RISC-V architecture
* RTL design
* Digital logic synthesis
* Standard-cell ASIC design
* Technology mapping
* Floorplanning
* Power planning
* Placement
* Clock-tree synthesis
* Physical routing
* Timing analysis
* DEF/GDSII formats
* Layout inspection
* LVS debugging
* Open-source ASIC toolchains
* SKY130A PDK

---

## Future Work

Planned improvements include:

* Resolve remaining LVS top-level connectivity mismatches.
* Perform clean LVS verification.
* Add more detailed timing and area analysis.
* Add DRC verification reports.
* Improve automated flow scripts.
* Add automated regression checks.
* Document physical-design results with layout screenshots.

---

## Author

**RV32I RTL-to-GDS ASIC Implementation Project**

Built as a hands-on exploration of the open-source digital ASIC implementation flow using the SKY130A technology stack.

---

## License

This project is released under the MIT License. See [`LICENSE`](LICENSE) for details.
