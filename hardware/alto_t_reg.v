`timescale 1ns / 1ps
`include "alto_definitions.v"

module alto_t_reg (
	input             clk_i,
	
	input             load_i,
	input      [15:0] bus_dat_i,
	input      [15:0] alu_dat_i,
	input       [3:0] aluf_i,
	output reg [15:0] dat_o
);

	always @ (posedge clk_i)
		if(load_i)
			case(aluf_i)
			`ALTO_ALUF_BUS,
			`ALTO_ALUF_BUS_OR_T,
			`ALTO_ALUF_BUS_PLUS_1,
			`ALTO_ALUF_BUS_MINUS_1,
			`ALTO_ALUF_BUS_PLUS_T_PLUS_1,
			`ALTO_ALUF_BUS_PLUS_SKIP,
			`ALTO_ALUF_BUS_AND_T_ALT:
				dat_o <= alu_dat_i;
				
			default:
				dat_o <= bus_dat_i;
			endcase

endmodule
