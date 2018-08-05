`timescale 1ns / 1ps
`include "alto_definitions.v"
module alto_registers (
	input			      clk_i,
	
	input       [2:0] bs_i,
	input       [4:0] rsel_i,
	
	input      [15:0] dat_i,
	output reg [15:0] dat_o,
	
	input             stall_i
);

	reg [15:0] register_mem [31:0];

	wire [15:0] mem_data = register_mem[rsel_i];
		
	always @ (posedge clk_i)
		if(bs_i == `ALTO_BS_LOAD_R && !stall_i)
			register_mem[rsel_i] <= dat_i;

	always @ (*)
		case(bs_i)
		`ALTO_BS_READ_R: dat_o = mem_data;
		`ALTO_BS_LOAD_R: dat_o = 16'b0;
		default:         dat_o = 16'hFFFF;
		endcase

	integer i;
	initial
	begin
		for(i = 0; i < 32; i = i + 1)
			register_mem[i] = 16'b0;
	end

endmodule
