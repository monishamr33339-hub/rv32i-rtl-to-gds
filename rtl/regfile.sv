module regfile (

    input  logic        clk,
    input  logic        reg_write,

    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,

    input  logic [31:0] rd_data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data

);

logic [31:0] regfile [31:0];
//write logic
always_ff @(posedge clk) begin
    if (reg_write && (rd_addr != 5'd0))
        regfile[rd_addr] <= rd_data;
end
integer i;

initial begin
    for (i = 0; i < 32; i = i + 1)
        regfile[i] = 32'd0;
end
//read logic 
always_comb begin

    if (rs1_addr == 5'd0)
        rs1_data = 32'd0;
    else
        rs1_data = regfile[rs1_addr];

    if (rs2_addr == 5'd0)
        rs2_data = 32'd0;
    else
        rs2_data = regfile[rs2_addr];

end
endmodule
