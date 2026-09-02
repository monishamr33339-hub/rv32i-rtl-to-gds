`timescale 1ns/1ps


module cpu
(

input logic clk,

input logic reset,


// Debug outputs

output logic [31:0] debug_pc,

output logic debug_reg_write,

output logic [4:0] debug_reg_addr,

output logic [31:0] debug_reg_data

);


//==================================================
// Datapath Instance
//==================================================


datapath datapath_unit
(

.clk(clk),

.reset(reset),


.debug_pc(debug_pc),

.debug_reg_write(debug_reg_write),

.debug_reg_addr(debug_reg_addr),

.debug_reg_data(debug_reg_data)

);



endmodule