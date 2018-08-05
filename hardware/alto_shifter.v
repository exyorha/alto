`timescale 1ns / 1ps
`include "alto_definitions.v"
module alto_shifter (
	input      [15:0] input_i,
	output reg [15:0] output_o,
	
	input       [3:0] f1_i,
	
	input      [15:0] t_i,
	input             magic_i,
	input             dns_i,
	input             dns_carry_i,
	output reg        dns_carry_o
);

	always @ (*)
		casez({ f1_i, magic_i, dns_i })
		{ `ALTO_F1_L_LSH_1, 2'b00 }: output_o = { input_i[14:0], 1'b0 };
		{ `ALTO_F1_L_LSH_1, 2'b01 }: output_o = { (input_i[14] | dns_carry_i), input_i[13:0], 1'b0 };
		{ `ALTO_F1_L_LSH_1, 2'b10 }: output_o = { input_i[14:0], t_i[15] };
		{ `ALTO_F1_L_LSH_1, 2'b11 }: output_o = { (input_i[14] | dns_carry_i), input_i[13:0], t_i[15] };
		{ `ALTO_F1_L_RSH_1, 2'b00 }: output_o = { 1'b0, input_i[15:1] };
		{ `ALTO_F1_L_RSH_1, 2'b01 }: output_o = { 1'b0, input_i[15:2], (input_i[1] | dns_carry_i) };
		{ `ALTO_F1_L_RSH_1, 2'b10 }: output_o = { t_i[0], input_i[15:1] };
		{ `ALTO_F1_L_RSH_1, 2'b11 }: output_o = { t_i[0], input_i[15:2], (input_i[1] | dns_carry_i) };
		{ `ALTO_F1_L_LCY_8, 2'b?? }: output_o = { input_i[7:0], input_i[15:8] };
		default: output_o = input_i;
		endcase

	always @ (*)
		case({ f1_i, dns_i })
		{ `ALTO_F1_L_LSH_1, 1'b1 }: dns_carry_o = input_i[15];
		{ `ALTO_F1_L_RSH_1, 1'b1 }: dns_carry_o = input_i[0];
		default: dns_carry_o = dns_carry_i;
		endcase
	

endmodule
