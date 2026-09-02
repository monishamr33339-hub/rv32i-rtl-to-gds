`timescale 1ns/1ps

module hazard_detection_unit
(
    input  logic       id_ex_memread,
    input  logic [4:0] id_ex_rd,

    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,

    output logic       pc_write,
    output logic       if_id_write,
    output logic       control_mux_select
);

always_comb
begin
    // Default: normal pipeline operation
    pc_write           = 1'b1;
    if_id_write        = 1'b1;
    control_mux_select = 1'b0;

    // Detect load-use hazard
    if (id_ex_memread &&
        (id_ex_rd != 5'd0) &&
        ((id_ex_rd == if_id_rs1) ||
         (id_ex_rd == if_id_rs2)))
    begin
        pc_write           = 1'b0;
        if_id_write        = 1'b0;
        control_mux_select = 1'b1;
    end
end

endmodule