`timescale 1ns / 1ps
`include "alto_definitions.v"
module alto_alu (
	input       [3:0] aluf_i,
	input      [15:0] bus_i,
	input      [15:0] t_i,
	input             skip_i,
	output reg [15:0] output_o,
	output reg        carry_o
);
	
	always @ (*)
		case(aluf_i)
		`ALTO_ALUF_BUS:                 { carry_o, output_o } = { 1'b0, bus_i };
		`ALTO_ALUF_T:                   { carry_o, output_o } = { 1'b0, t_i };
		`ALTO_ALUF_BUS_OR_T:            { carry_o, output_o } = { 1'b0, bus_i | t_i };
		`ALTO_ALUF_BUS_AND_T:           { carry_o, output_o } = { 1'b0, bus_i & t_i };
		`ALTO_ALUF_BUS_XOR_T:           { carry_o, output_o } = { 1'b0, bus_i ^ t_i };
		`ALTO_ALUF_BUS_PLUS_1:          { carry_o, output_o } = bus_i + 16'b0 + 1'b1;
		`ALTO_ALUF_BUS_MINUS_1:         { carry_o, output_o } = bus_i + ~17'hFFFF + 1'b1;
		`ALTO_ALUF_BUS_PLUS_T:          { carry_o, output_o } = bus_i + t_i;
		`ALTO_ALUF_BUS_MINUS_T:         { carry_o, output_o } = bus_i + ~{ 1'b0, t_i } + 1'b1;
		`ALTO_ALUF_BUS_MINUS_T_MINUS_1: { carry_o, output_o } = bus_i + ~{ 1'b0, t_i };
		`ALTO_ALUF_BUS_PLUS_T_PLUS_1:   { carry_o, output_o } = bus_i + t_i + 1'b1;
		`ALTO_ALUF_BUS_PLUS_SKIP:       { carry_o, output_o } = bus_i + 17'b0 + { 16'b0, skip_i };
		`ALTO_ALUF_BUS_AND_T_ALT:       { carry_o, output_o } = { 1'b0, bus_i & t_i };
		`ALTO_ALUF_BUS_AND_NOT_T:       { carry_o, output_o } = { 1'b0, bus_i & ~t_i };
		default:                        { carry_o, output_o } = { 1'b0, bus_i };
		endcase
	
endmodule
