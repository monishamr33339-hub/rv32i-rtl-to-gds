module data_memory #(
    parameter MEM_DEPTH = 256
)(
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    //--------------------------------------------------
    // Memory Array
    //--------------------------------------------------

    logic [31:0] memory [0:MEM_DEPTH-1];

    //--------------------------------------------------
    // Initialize Memory (Simulation Only)
    //--------------------------------------------------

    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1)
            memory[i] = 32'd0;
    end

    //--------------------------------------------------
    // Synchronous Write
    //--------------------------------------------------

    always_ff @(posedge clk) begin
        if (mem_write)
            memory[address[31:2]] <= write_data;
    end

    //--------------------------------------------------
    // Asynchronous Read
    //--------------------------------------------------

    assign read_data = (mem_read) ?
                       memory[address[31:2]] :
                       32'd0;

endmodule