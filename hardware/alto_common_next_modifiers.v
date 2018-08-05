`timescale 1ns / 1ps
`include "alto_definitions.v"

module alto_common_next_modifiers(
	input      [3:0] f2_i,
	
	input     [15:0] bus_i,
	input     [15:0] shifter_i,
	input            alu_carry_i,
	
	output reg [9:0] modifiers_o
);
	
	always @ (*)
		case(f2_i)
		`ALTO_F2_BUS_ZERO: modifiers_o = { 9'b0, bus_i == 16'b0 };
		`ALTO_F2_SH_NEG:   modifiers_o = { 9'b0, shifter_i[15] };
		`ALTO_F2_SH_ZERO:  modifiers_o = { 9'b0, shifter_i == 16'b0 };
		`ALTO_F2_BUS:      modifiers_o = bus_i[9:0];
		`ALTO_F2_ALUCY:    modifiers_o = { 9'b0, alu_carry_i };
		default:           modifiers_o = 10'b0;
		endcase

endmodule
