module mem_wb_register(

    input  logic        clk,
    input  logic        reset,

    //==================================================
    // Data Signals
    //==================================================

    input  logic [31:0] mem_data_in,
    input  logic [31:0] alu_result_in,
    input  logic [4:0]  rd_in,

    //==================================================
    // Control Signals
    //==================================================

    input  logic        reg_write_in,
    input  logic        mem_to_reg_in,
    input logic wb_pc4_in,

    input logic [31:0] pc_plus4_in,




    //==================================================
    // Outputs
    //==================================================

    output logic [31:0] mem_data_out,
    output logic [31:0] alu_result_out,
    output logic [4:0]  rd_out,
    output logic wb_pc4_out,
    output logic [31:0] pc_plus4_out,
    output logic        reg_write_out,
    output logic        mem_to_reg_out

);

always_ff @(posedge clk)
begin

    if(reset)
    begin

        mem_data_out   <= 32'd0;
        alu_result_out <= 32'd0;
        rd_out         <= 5'd0;
	wb_pc4_out   <=1'b0;
	pc_plus4_out <= 32'b0;
        reg_write_out  <= 1'b0;
        mem_to_reg_out <= 1'b0;

    end

    else
    begin

        mem_data_out   <= mem_data_in;
        alu_result_out <= alu_result_in;
        rd_out         <= rd_in;
        wb_pc4_out <= wb_pc4_in;

	pc_plus4_out <= pc_plus4_in;

        reg_write_out  <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;

    end

end

endmodule
