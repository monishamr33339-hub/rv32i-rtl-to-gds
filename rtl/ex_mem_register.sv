module ex_mem_register(

    input  logic        clk,
    input  logic        reset,

    //==================================================
    // Data Signals
    //==================================================

    input  logic [31:0] alu_result_in,
    input  logic [31:0] write_data_in,
    input logic [31:0] branch_target_in,
    input logic        branch_taken_in,
    input  logic [4:0]  rd_in,
    
    //==================================================
    // Control Signals
    //==================================================

    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic        mem_to_reg_in,
    input  logic        branch_in,
    input  logic        jump_in,
    input logic wb_pc4_in,
    input logic [31:0] pc_plus4_in,




 

    //==================================================
    // Outputs
    //==================================================

    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [31:0] branch_target_out,
    output logic        branch_taken_out,
    output logic [4:0]  rd_out,
    output logic wb_pc4_out,
    output logic [31:0] pc_plus4_out,
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic        mem_to_reg_out,
    output logic        branch_out,
    output logic        jump_out

);

always_ff @(posedge clk)
begin

    if(reset)
    begin

        alu_result_out <= 32'd0;
        write_data_out <= 32'd0;
        rd_out         <= 5'd0;
	branch_target_out <= 32'd0;
	branch_taken_out  <= 1'b0;
        reg_write_out  <= 1'b0;
        mem_read_out   <= 1'b0;
        mem_write_out  <= 1'b0;
        mem_to_reg_out <= 1'b0;
        branch_out     <= 1'b0;
        jump_out       <= 1'b0;
        wb_pc4_out <= 1'b0;
        pc_plus4_out <= 32'd0;

    end

    else
    begin

        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        rd_out         <= rd_in;
        wb_pc4_out <= wb_pc4_in;
	branch_target_out <= branch_target_in;
	branch_taken_out  <= branch_taken_in;
        reg_write_out  <= reg_write_in;
        mem_read_out   <= mem_read_in;
        mem_write_out  <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        branch_out     <= branch_in;
        jump_out       <= jump_in;
        pc_plus4_out <= pc_plus4_in;

    end

end

endmodule
