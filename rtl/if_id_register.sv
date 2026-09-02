`timescale 1ns/1ps

module if_id_register
(

    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,

    input  logic [31:0] pc_in,
    input  logic [31:0] instruction_in,
    input logic flush,
    output logic [31:0] pc_out,
    output logic [31:0] instruction_out
   

);

//==================================================
// IF/ID Pipeline Register
//==================================================

always_ff @(posedge clk or posedge reset)
begin

    if(reset)
    begin

        pc_out          <= 32'd0;
        instruction_out <= 32'd0;

    end

    else
    begin

	    if(flush)
	    begin

		pc_out <= 32'd0;
		instruction_out <= 32'd0;

	    end

	    else if(write_enable)
	    begin

		pc_out <= pc_in;
		instruction_out <= instruction_in;

	    end

	end

end

endmodule
