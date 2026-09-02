`timescale 1ns/1ps

module pipeline_datapath(

    input logic clk,
    input logic reset,

    // Debug Interface

    output logic [31:0] debug_pc,

    output logic debug_reg_write,

    output logic [4:0] debug_reg_addr,

    output logic [31:0] debug_reg_data

);

`include "rv32i_defs.svh"


//====================================================
// PC
//====================================================

logic [31:0] pc_value;
logic [31:0] next_pc;


//====================================================
// Instruction
//====================================================

logic [31:0] instruction;
//====================================================
// IF/ID Pipeline Register
//====================================================

logic [31:0] if_id_pc;
logic [31:0] if_id_instruction;

//====================================================
// ID/EX Pipeline Register
//====================================================

logic [31:0] id_ex_pc;

logic [31:0] id_ex_rs1_data;
logic [31:0] id_ex_rs2_data;

logic [31:0] id_ex_imm;
logic [4:0] id_ex_rs1;
logic [4:0] id_ex_rs2;
logic [4:0] id_ex_rd;
logic [2:0] id_ex_funct3;
logic [6:0] id_ex_funct7;
logic [6:0] id_ex_opcode;
logic id_ex_reg_write;
logic id_ex_alu_src;
logic id_ex_mem_read;
logic id_ex_mem_write;
logic id_ex_mem_to_reg;
logic id_ex_branch;
logic id_ex_jump;
logic id_ex_wb_pc4;
logic [1:0] id_ex_alu_op;

//====================================================
// EX/MEM Pipeline Register
//====================================================

logic [31:0] ex_mem_alu_result;
logic [31:0] ex_mem_rs2_data;

logic [4:0] ex_mem_rd;
logic ex_mem_wb_pc4;
logic [31:0] ex_mem_pc_plus4;
logic ex_mem_reg_write;
logic ex_mem_mem_read;
logic ex_mem_mem_write;
logic ex_mem_mem_to_reg;
logic ex_mem_branch;
logic ex_mem_jump;

//====================================================
// MEM/WB Pipeline Register
//====================================================

logic [31:0] mem_wb_mem_data;
logic [31:0] mem_wb_alu_result;

logic [4:0] mem_wb_rd;
logic mem_wb_wb_pc4;
logic [31:0] mem_wb_pc_plus4;
logic mem_wb_reg_write;
logic mem_wb_mem_to_reg;

//====================================================
// Decoder Signals
//====================================================

logic [6:0] opcode;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;
logic [2:0] funct3;
logic [6:0] funct7;


//====================================================
// Register File
//====================================================

logic [31:0] rs1_data;
logic [31:0] rs2_data;


//====================================================
// Immediate
//====================================================

logic [31:0] imm_out;


//====================================================
// Control Signals
//====================================================

logic reg_write;
logic alu_src;
logic mem_read;
logic mem_write;
logic mem_to_reg;
logic branch;
logic jump;
logic wb_pc4;
logic [1:0] alu_op;

//====================================================
// Hazard Detection
//====================================================

logic pc_write;
logic if_id_write;
logic id_ex_flush;

//====================================================
// Forwarding Unit
//====================================================

logic [1:0] forward_a;
logic [1:0] forward_b;

//====================================================
// Forwarded ALU Inputs
//====================================================

logic [31:0] alu_input_a;
logic [31:0] alu_input_b_forwarded;
logic [31:0] alu_input_b;

//====================================================
// ALU
//====================================================

logic [3:0] alu_ctrl;


logic [31:0] alu_result;

logic zero;
//====================================================
// Branch Signals
//====================================================

logic [31:0] branch_target;
logic branch_taken;
logic [31:0] pc_branch;
logic [31:0] pc_plus4;
//====================================================
// Control Hazard Flush
//====================================================

logic if_id_flush;
logic id_ex_branch_flush;
//====================================================
// Jump Signals
//====================================================

logic [31:0] jump_target;
logic jump_taken;
logic [31:0] jalr_target;
//====================================================
// Store Data Forwarding
//====================================================

logic [31:0] store_data_forwarded;
//====================================================
// Data Memory
//====================================================

logic [31:0] mem_read_data;


//====================================================
// Writeback
//====================================================

logic [31:0] writeback_data;



//====================================================
// PC + 4
//====================================================

//----------------------------------------------------
// Next PC Selection
//----------------------------------------------------

always_comb
begin

    pc_plus4 = pc_value + 32'd4;


    if(branch_taken)
    begin
        next_pc = branch_target;
    end

    else if(jump_taken)
    begin

        if(id_ex_opcode == OPCODE_JALR)
            next_pc = jalr_target;

        else
            next_pc = jump_target;

    end

    else
    begin
        next_pc = pc_plus4;
    end


end

//----------------------------------------------------
// JAL Target
//----------------------------------------------------

assign jump_target = id_ex_pc + id_ex_imm;
//----------------------------------------------------
// JALR Target
//----------------------------------------------------

assign jalr_target = (alu_input_a + id_ex_imm) & 32'hFFFFFFFE;

//====================================================
// Module Instantiations
//====================================================


//---------------- PC ----------------

pc pc_unit
(
    .clk(clk),
    .reset(reset),

    .pc_write(pc_write),

    .next_pc(next_pc),

    .pc(pc_value)
);



//---------------- Instruction Memory ----------------

instruction_memory #(
    .MEM_FILE("program.mem")
)
imem
(
    .address(pc_value),
    .instruction(instruction)
);

//----------------------------------------------------
// IF/ID Pipeline Register
//----------------------------------------------------

if_id_register if_id_reg
(
    .clk(clk),
    .reset(reset),

    .write_enable(if_id_write),

    .flush(if_id_flush),

    .pc_in(pc_value),
    .instruction_in(instruction),

    .pc_out(if_id_pc),
    .instruction_out(if_id_instruction)
);
//----------------------------------------------------
// ID/EX Pipeline Register
//----------------------------------------------------

id_ex_register id_ex_reg
(
    .clk(clk),
    .reset(reset),
    .flush(id_ex_flush | id_ex_branch_flush),
    .pc_in(if_id_pc),
    
    .rs1_data_in(rs1_data),
    .rs2_data_in(rs2_data),

    .imm_in(imm_out),
    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    .funct3_in(funct3),
    .funct7_in(funct7),
    .opcode_in(opcode),
    .reg_write_in(reg_write),
    .alu_src_in(alu_src),

    .mem_read_in(mem_read),
    .mem_write_in(mem_write),

    .mem_to_reg_in(mem_to_reg),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .branch_in(branch),
    .jump_in(jump),
.wb_pc4_in(wb_pc4),

.alu_op_in(alu_op),

    .pc_out(id_ex_pc),

    .rs1_data_out(id_ex_rs1_data),
    .rs2_data_out(id_ex_rs2_data),

    .imm_out(id_ex_imm),

    .rd_out(id_ex_rd),
    .funct3_out(id_ex_funct3),
    .funct7_out(id_ex_funct7),
    .opcode_out(id_ex_opcode),
    .reg_write_out(id_ex_reg_write),
    .alu_src_out(id_ex_alu_src),

    .mem_read_out(id_ex_mem_read),
    .mem_write_out(id_ex_mem_write),

    .mem_to_reg_out(id_ex_mem_to_reg),

    .branch_out(id_ex_branch),
    .jump_out(id_ex_jump),
.wb_pc4_out(id_ex_wb_pc4),

.alu_op_out(id_ex_alu_op)
);

//----------------------------------------------------
// EX/MEM Pipeline Register
//----------------------------------------------------

ex_mem_register ex_mem_reg
(
    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result),
    .write_data_in(store_data_forwarded),
    .rd_in(id_ex_rd),

    .reg_write_in(id_ex_reg_write),
    .mem_read_in(id_ex_mem_read),
    .mem_write_in(id_ex_mem_write),
    .mem_to_reg_in(id_ex_mem_to_reg),
    .branch_in(id_ex_branch),
    .jump_in(id_ex_jump),
.wb_pc4_in(id_ex_wb_pc4),

.pc_plus4_in(id_ex_pc + 32'd4),

    .alu_result_out(ex_mem_alu_result),
    .write_data_out(ex_mem_rs2_data),
    .rd_out(ex_mem_rd),

    .reg_write_out(ex_mem_reg_write),
    .mem_read_out(ex_mem_mem_read),
    .mem_write_out(ex_mem_mem_write),
    .mem_to_reg_out(ex_mem_mem_to_reg),
    .branch_out(ex_mem_branch),
    .jump_out(ex_mem_jump),
.wb_pc4_out(ex_mem_wb_pc4),

.pc_plus4_out(ex_mem_pc_plus4)
);

//----------------------------------------------------
// MEM/WB Pipeline Register
//----------------------------------------------------

mem_wb_register mem_wb_reg
(
    .clk(clk),
    .reset(reset),

    // Data
    .mem_data_in(mem_read_data),
    .alu_result_in(ex_mem_alu_result),
    .rd_in(ex_mem_rd),

    // Control
    .reg_write_in(ex_mem_reg_write),
    .mem_to_reg_in(ex_mem_mem_to_reg),

    .wb_pc4_in(ex_mem_wb_pc4),
    .pc_plus4_in(ex_mem_pc_plus4),

    // Outputs
    .mem_data_out(mem_wb_mem_data),
    .alu_result_out(mem_wb_alu_result),
    .rd_out(mem_wb_rd),

    .reg_write_out(mem_wb_reg_write),
    .mem_to_reg_out(mem_wb_mem_to_reg),

    .wb_pc4_out(mem_wb_wb_pc4),
    .pc_plus4_out(mem_wb_pc_plus4)
);

//---------------- Decoder ----------------

decoder decoder_unit
(
    .instruction(if_id_instruction),

    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
);



//---------------- Register File ----------------

regfile regfile_unit
(
    .clk(clk),
    .rs1_addr(rs1),
    .rs2_addr(rs2),
    .reg_write(mem_wb_reg_write),
    .rd_addr(mem_wb_rd),
    .rd_data(writeback_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);



//---------------- Immediate Generator ----------------

imm_gen imm_unit
(
    .instruction(if_id_instruction),

    .imm_out(imm_out)
);



//---------------- Control Unit ----------------

control control_unit
(
    .opcode(opcode),

    .reg_write(reg_write),
    .alu_src(alu_src),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .mem_to_reg(mem_to_reg),

    .branch(branch),
    .jump(jump),
.wb_pc4(wb_pc4),

.alu_op(alu_op)
);



//---------------- ALU Control ----------------

alu_control alu_control_unit
(
    .alu_op(id_ex_alu_op),

    .funct3(id_ex_funct3),

    .funct7(id_ex_funct7),

    .alu_ctrl(alu_ctrl)
);



//---------------- ALU Input MUX ----------------

//----------------------------------------------------
// Forwarding MUX : ALU Input A
//----------------------------------------------------

always_comb
begin

    case(forward_a)

        2'b00:
            alu_input_a = id_ex_rs1_data;

        2'b01:
            alu_input_a = writeback_data;

        2'b10:
            alu_input_a = ex_mem_alu_result;

        default:
            alu_input_a = id_ex_rs1_data;

    endcase

end

//----------------------------------------------------
// Forwarding MUX : Register Operand B
//----------------------------------------------------

always_comb
begin

    case(forward_b)

        2'b00:
            alu_input_b_forwarded = id_ex_rs2_data;

        2'b01:
            alu_input_b_forwarded = writeback_data;

        2'b10:
            alu_input_b_forwarded = ex_mem_alu_result;

        default:
            alu_input_b_forwarded = id_ex_rs2_data;

    endcase

end

//----------------------------------------------------
// ALU Source MUX
//----------------------------------------------------

assign alu_input_b =
        (id_ex_alu_src) ?
        id_ex_imm :
        alu_input_b_forwarded;

//----------------------------------------------------
// Store Data Forwarding MUX
//----------------------------------------------------

always_comb
begin

    case (forward_b)

        // Register file value
        2'b00:
            store_data_forwarded = id_ex_rs2_data;

        // Forward from MEM/WB
        2'b01:
            store_data_forwarded = writeback_data;

        // Forward from EX/MEM
        2'b10:
            store_data_forwarded = ex_mem_alu_result;

        default:
            store_data_forwarded = id_ex_rs2_data;

    endcase

end
//----------------------------------------------------
// Branch Target Calculation
//----------------------------------------------------

assign branch_target = id_ex_pc + id_ex_imm;

//----------------------------------------------------
// Branch Decision
//----------------------------------------------------

always_comb
begin

    branch_taken = 1'b0;


    if(id_ex_branch)
    begin

        case(id_ex_funct3)

            // BEQ
            3'b000:
            begin
                if(zero)
                    branch_taken = 1'b1;
            end


            // BNE
            3'b001:
            begin
                if(!zero)
                    branch_taken = 1'b1;
            end


            default:
                branch_taken = 1'b0;

        endcase

    end

end

//----------------------------------------------------
// Branch Flush Logic
//----------------------------------------------------

assign if_id_flush = branch_taken | jump_taken;

assign id_ex_branch_flush = branch_taken | jump_taken;

//----------------------------------------------------
// Jump Decision
//----------------------------------------------------

always_comb
begin

    jump_taken = 1'b0;


    if(id_ex_jump)
    begin

        jump_taken = 1'b1;

    end

end
//---------------- ALU ----------------

alu alu_unit
(
    .a(alu_input_a),

    .b(alu_input_b),

    .alu_ctrl(alu_ctrl),

    .result(alu_result),

    .zero(zero)
);

//----------------------------------------------------
// Hazard Detection Unit
//----------------------------------------------------

hazard_detection_unit hazard_unit
(
    .id_ex_memread(id_ex_mem_read),

    .id_ex_rd(id_ex_rd),

    .if_id_rs1(rs1),
    .if_id_rs2(rs2),

    .pc_write(pc_write),

    .if_id_write(if_id_write),

    .control_mux_select(id_ex_flush)
);

//----------------------------------------------------
// Forwarding Unit
//----------------------------------------------------

forwarding_unit forwarding_unit_inst
(
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),

    .ex_mem_rd(ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write),

    .mem_wb_rd(mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),

    .forward_a(forward_a),
    .forward_b(forward_b)
);

//---------------- Data Memory ----------------

data_memory data_mem
(
    .clk(clk),

    .mem_read(ex_mem_mem_read),
.mem_write(ex_mem_mem_write),

.address(ex_mem_alu_result),

.write_data(ex_mem_rs2_data),

    .read_data(mem_read_data)
);



//---------------- Writeback MUX ----------------

assign writeback_data =
        mem_wb_wb_pc4 ?
            mem_wb_pc_plus4 :
        (mem_wb_mem_to_reg ?
            mem_wb_mem_data :
            mem_wb_alu_result);

//====================================================
// Debug Interface
//====================================================

assign debug_pc = if_id_pc;
assign debug_reg_write = mem_wb_reg_write;
assign debug_reg_addr  = mem_wb_rd;
assign debug_reg_data = writeback_data;

endmodule