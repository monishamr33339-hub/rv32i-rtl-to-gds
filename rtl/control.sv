`timescale 1ns/1ps

module control
(

    input  logic [6:0] opcode,

    output logic       reg_write,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,
    output logic       mem_to_reg,
    output logic       branch,
    output logic       jump,
    output logic wb_pc4,
    output logic [1:0] alu_op
    
);

`include "rv32i_defs.svh"

always_comb begin

    //-------------------------------------------------
    // Default Values
    //-------------------------------------------------

    reg_write = 1'b0;
    alu_src   = 1'b0;
    mem_read  = 1'b0;
    mem_write = 1'b0;
    mem_to_reg= 1'b0;
    branch    = 1'b0;
    jump      = 1'b0;
    wb_pc4 = 1'b0;
    alu_op    = ALUOP_ADD;

    //-------------------------------------------------
    // Opcode Decode
    //-------------------------------------------------

    case (opcode)

        //---------------------------------------------
        // R-Type
        //---------------------------------------------

        OPCODE_OP: begin
            reg_write = 1'b1;
            alu_src   = 1'b0;
            alu_op    = ALUOP_RTYPE;
        end

        //---------------------------------------------
        // I-Type Arithmetic
        //---------------------------------------------

        OPCODE_OP_IMM: begin
            reg_write = 1'b1;
            alu_src   = 1'b1;
            alu_op    = ALUOP_ITYPE;
        end

        //---------------------------------------------
        // Load
        //---------------------------------------------

        OPCODE_LOAD: begin
            reg_write = 1'b1;
            alu_src   = 1'b1;
            mem_read  = 1'b1;
            mem_to_reg= 1'b1;
            alu_op    = ALUOP_ADD;
        end

        //---------------------------------------------
        // Store
        //---------------------------------------------

        OPCODE_STORE: begin
            alu_src   = 1'b1;
            mem_write = 1'b1;
            alu_op    = ALUOP_ADD;
        end

        //---------------------------------------------
        // Branch
        //---------------------------------------------

        OPCODE_BRANCH: begin
            branch = 1'b1;
            alu_op = ALUOP_BRANCH;
        end

        //---------------------------------------------
        // JAL
        //---------------------------------------------

        OPCODE_JAL: begin
	    jump      = 1'b1;
	    reg_write = 1'b1;
	    wb_pc4    = 1'b1;
	end
        

        //---------------------------------------------
        // JALR
        //---------------------------------------------

	OPCODE_JALR: begin
	    jump      = 1'b1;
	    reg_write = 1'b1;
	    alu_src   = 1'b1;
	    wb_pc4    = 1'b1;
	end

        //---------------------------------------------
        // LUI
        //---------------------------------------------

        OPCODE_LUI: begin
            reg_write = 1'b1;
            alu_src   = 1'b1;
        end

        //---------------------------------------------
        // AUIPC
        //---------------------------------------------

        OPCODE_AUIPC: begin
            reg_write = 1'b1;
            alu_src   = 1'b1;
            alu_op    = ALUOP_ADD;
        end

        //---------------------------------------------
        // Default
        //---------------------------------------------

        default: begin
            // Keep safe defaults
        end

    endcase

end

endmodule
