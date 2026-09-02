`timescale 1ns/1ps

module alu_control

(

    input  logic [1:0] alu_op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,

    output logic [3:0] alu_ctrl

);

`include "rv32i_defs.svh"

always_comb begin

    //------------------------------------------
    // Safe Default
    //------------------------------------------

    alu_ctrl = ALUCTRL_ADD;

    //------------------------------------------
    // ALU Operation Decode
    //------------------------------------------

    case (alu_op)

        //--------------------------------------
        // Address Calculation
        // Used by:
        // LW, SW, AUIPC
        //--------------------------------------

        ALUOP_ADD:
            alu_ctrl = ALUCTRL_ADD;

        //--------------------------------------
        // Branch Comparison
        //--------------------------------------

        ALUOP_BRANCH:
            alu_ctrl = ALUCTRL_SUB;

        //--------------------------------------
        // R-Type Instructions
        //--------------------------------------

        ALUOP_RTYPE:
        begin

            case (funct3)

                //----------------------------------
                // ADD / SUB
                //----------------------------------

                3'b000:
                begin

                    if (funct7 == 7'b0100000)
                        alu_ctrl = ALUCTRL_SUB;
                    else
                        alu_ctrl = ALUCTRL_ADD;

                end

                //----------------------------------
                // SLL
                //----------------------------------

                3'b001:
                    alu_ctrl = ALUCTRL_SLL;

                //----------------------------------
                // SLT
                //----------------------------------

                3'b010:
                    alu_ctrl = ALUCTRL_SLT;

                //----------------------------------
                // XOR
                //----------------------------------

                3'b100:
                    alu_ctrl = ALUCTRL_XOR;

                //----------------------------------
                // SRL
                //----------------------------------

                3'b101:
                    alu_ctrl = ALUCTRL_SRL;

                //----------------------------------
                // OR
                //----------------------------------

                3'b110:
                    alu_ctrl = ALUCTRL_OR;

                //----------------------------------
                // AND
                //----------------------------------

                3'b111:
                    alu_ctrl = ALUCTRL_AND;

                default:
                    alu_ctrl = ALUCTRL_ADD;

            endcase

        end

        //--------------------------------------
        // I-Type Arithmetic
        //--------------------------------------

        ALUOP_ITYPE:
        begin

            case (funct3)

                3'b000: alu_ctrl = ALUCTRL_ADD;   // ADDI
                3'b001: alu_ctrl = ALUCTRL_SLL;   // SLLI
                3'b010: alu_ctrl = ALUCTRL_SLT;   // SLTI
                3'b100: alu_ctrl = ALUCTRL_XOR;   // XORI
                3'b101: alu_ctrl = ALUCTRL_SRL;   // SRLI
                3'b110: alu_ctrl = ALUCTRL_OR;    // ORI
                3'b111: alu_ctrl = ALUCTRL_AND;   // ANDI

                default:
                    alu_ctrl = ALUCTRL_ADD;

            endcase

        end

        //--------------------------------------

        default:
            alu_ctrl = ALUCTRL_ADD;

    endcase

end

endmodule