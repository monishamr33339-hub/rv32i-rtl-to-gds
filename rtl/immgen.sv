
module imm_gen(

    input  logic [31:0] instruction,
    output logic [31:0] imm_out

);

`include "rv32i_defs.svh"

always_comb begin

    case(instruction[6:0])

        //--------------------------------------------------
        // I-Type
        //--------------------------------------------------

        OPCODE_OP_IMM,
        OPCODE_LOAD,
        OPCODE_JALR:

            imm_out = {
                {20{instruction[31]}},
                instruction[31:20]
            };

        //--------------------------------------------------
        // S-Type
        //--------------------------------------------------

        OPCODE_STORE:

            imm_out = {
                {20{instruction[31]}},
                instruction[31:25],
                instruction[11:7]
            };

        //--------------------------------------------------
        // B-Type
        //--------------------------------------------------

        OPCODE_BRANCH:

            imm_out = {
                {19{instruction[31]}},
                instruction[31],
                instruction[7],
                instruction[30:25],
                instruction[11:8],
                1'b0
            };

        //--------------------------------------------------
        // U-Type
        //--------------------------------------------------

        OPCODE_LUI,
        OPCODE_AUIPC:

            imm_out = {
                instruction[31:12],
                12'b0
            };

        //--------------------------------------------------
        // J-Type
        //--------------------------------------------------

        OPCODE_JAL:

            imm_out = {
                {11{instruction[31]}},
                instruction[31],
                instruction[19:12],
                instruction[20],
                instruction[30:21],
                1'b0
            };

        //--------------------------------------------------

        default:

            imm_out = 32'd0;

    endcase

end

endmodule