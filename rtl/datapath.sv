`timescale 1ns/1ps

module datapath(

    input logic clk,
    input logic reset,

    // Debug Interface

    output logic [31:0] debug_pc,

    output logic debug_reg_write,

    output logic [4:0] debug_reg_addr,

    output logic [31:0] debug_reg_data

);


import rv32i_pkg::*;


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

logic [1:0] alu_op;


//====================================================
// ALU
//====================================================

logic [3:0] alu_ctrl;

logic [31:0] alu_input_b;

logic [31:0] alu_result;

logic zero;


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

assign next_pc = pc_value + 32'd4;



//====================================================
// Module Instantiations
//====================================================


//---------------- PC ----------------

pc pc_unit
(
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc(pc_value)
);



//---------------- Instruction Memory ----------------

instruction_memory imem
(
    .address(pc_value),
    .instruction(instruction)
);



//---------------- Decoder ----------------

decoder decoder_unit
(
    .instruction(instruction),

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

    .reg_write(reg_write),

    .rs1_addr(rs1),
    .rs2_addr(rs2),

    .rd_addr(rd),

    .rd_data(writeback_data),

    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);



//---------------- Immediate Generator ----------------

imm_gen imm_unit
(
    .instruction(instruction),

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

    .alu_op(alu_op)
);



//---------------- ALU Control ----------------

alu_control alu_control_unit
(
    .alu_op(alu_op),

    .funct3(funct3),

    .funct7(funct7),

    .alu_ctrl(alu_ctrl)
);



//---------------- ALU Input MUX ----------------

assign alu_input_b =
        (alu_src) ? imm_out :
                    rs2_data;



//---------------- ALU ----------------

alu alu_unit
(
    .a(rs1_data),

    .b(alu_input_b),

    .alu_ctrl(alu_ctrl),

    .result(alu_result)
);



//---------------- Data Memory ----------------

data_memory data_mem
(
    .clk(clk),

    .mem_read(mem_read),

    .mem_write(mem_write),

    .address(alu_result),

    .write_data(rs2_data),

    .read_data(mem_read_data)
);



//---------------- Writeback MUX ----------------

assign writeback_data =
        (mem_to_reg) ?
        mem_read_data :
        alu_result;

//====================================================
// Debug Interface
//====================================================

assign debug_pc = pc_value;


assign debug_reg_write = reg_write;


assign debug_reg_addr = rd;


assign debug_reg_data = writeback_data;

endmodule