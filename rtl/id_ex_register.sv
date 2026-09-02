`timescale 1ns/1ps

module id_ex_register
(

    input logic clk,
    input logic reset,
    input logic flush,
    input logic wb_pc4_in,

    //------------------------------------------------
    // Data Signals
    //------------------------------------------------

    input logic [31:0] pc_in,
    input logic [31:0] rs1_data_in,
    input logic [31:0] rs2_data_in,
    input logic [31:0] imm_in,

    // NEW: Source Register Numbers
    input logic [4:0] rs1_in,
    input logic [4:0] rs2_in,

    input logic [4:0] rd_in,

    input logic [2:0] funct3_in,
    input logic [6:0] funct7_in,
    input logic [6:0] opcode_in,
    //------------------------------------------------
    // Control Signals
    //------------------------------------------------

    input logic reg_write_in,
    input logic alu_src_in,
    input logic mem_read_in,
    input logic mem_write_in,
    input logic mem_to_reg_in,
    input logic branch_in,
    input logic jump_in,

    input logic [1:0] alu_op_in,

    //------------------------------------------------
    // Outputs
    //------------------------------------------------

    output logic [31:0] pc_out,
    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    output logic [31:0] imm_out,
    output logic wb_pc4_out,

    // NEW: Source Register Numbers
    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,

    output logic [4:0] rd_out,

    output logic [2:0] funct3_out,
    output logic [6:0] funct7_out,
    output logic [6:0] opcode_out,

    output logic reg_write_out,
    output logic alu_src_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic mem_to_reg_out,
    output logic branch_out,
    output logic jump_out,

    output logic [1:0] alu_op_out

);

//==================================================
// Pipeline Register
//==================================================

always_ff @(posedge clk or posedge reset)
begin

    if(reset)
    begin

        pc_out <= 32'd0;

        rs1_data_out <= 32'd0;
        rs2_data_out <= 32'd0;
        imm_out      <= 32'd0;
	wb_pc4_out <= 1'b0;
        rs1_out <= 5'd0;
        rs2_out <= 5'd0;
        rd_out  <= 5'd0;

        funct3_out <= 3'd0;
        funct7_out <= 7'd0;
        opcode_out <= 7'd0;

        reg_write_out <= 1'b0;
        alu_src_out   <= 1'b0;
        mem_read_out  <= 1'b0;
        mem_write_out <= 1'b0;
        mem_to_reg_out<= 1'b0;
        branch_out    <= 1'b0;
        jump_out      <= 1'b0;

        alu_op_out <= 2'b00;

    end

    else
    begin

        //------------------------------------------------
        // Data always moves forward
        //------------------------------------------------

        pc_out <= pc_in;

        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        imm_out      <= imm_in;
	wb_pc4_out <= wb_pc4_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out  <= rd_in;

        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
	opcode_out <= opcode_in;
        //------------------------------------------------
        // Bubble insertion
        //------------------------------------------------

        if(flush)
        begin
            reg_write_out <= 1'b0;
            alu_src_out   <= 1'b0;
            mem_read_out  <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out<= 1'b0;
            branch_out    <= 1'b0;
            jump_out      <= 1'b0;
            alu_op_out    <= 2'b00;
            wb_pc4_out <= 1'b0;
        end
        else
        begin
            reg_write_out <= reg_write_in;
            alu_src_out   <= alu_src_in;
            mem_read_out  <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out<= mem_to_reg_in;
            branch_out    <= branch_in;
            jump_out      <= jump_in;
            alu_op_out    <= alu_op_in;
            wb_pc4_out <= wb_pc4_in;
        end

    end

end

endmodule
