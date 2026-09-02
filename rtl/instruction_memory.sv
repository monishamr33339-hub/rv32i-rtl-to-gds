module instruction_memory #(
    parameter MEM_DEPTH = 64,
    parameter MEM_FILE  = "program.mem"
)(
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    //--------------------------------------------------
    // Memory Array
    //--------------------------------------------------

    logic [31:0] memory [0:MEM_DEPTH-1];
    /*
    initial begin
    integer i;

    for (i = 0; i < MEM_DEPTH; i = i + 1)
        memory[i] = 32'h00000013; // NOP

    $readmemh(MEM_FILE, memory);
    end
    */
    //--------------------------------------------------
    // Combinational Read
    //--------------------------------------------------

    assign instruction = memory[address[31:2]];

endmodule
