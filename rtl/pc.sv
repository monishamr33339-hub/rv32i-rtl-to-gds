`timescale 1ns/1ps

module pc (

    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] next_pc,
    input  logic        pc_write,

    output logic [31:0] pc

);

always_ff @(posedge clk or posedge reset)
begin
    if (reset)
        pc <= 32'h0000_0000;

    else if (pc_write)
        pc <= next_pc;

    // else: retain current value
end

endmodule
