`timescale 1ns / 1ps
`include "alto_definitions.v"

module alto_emulator_support (
	input              clk_i,
	
	input        [3:0] current_task_i,
	input        [2:0] bs_i,
	input        [3:0] f2_i,
	
	input       [15:0] bus_i,
	output reg  [15:0] bus_o,
	
	output reg   [9:0] modifiers_o,
	
	input              stall_i,
	output reg         skip_o,
	output             magic_o
);

	reg [15:0] ir;

	wire in_emulator = current_task_i == `ALTO_TASK_EMULATOR;

	assign magic_o = in_emulator && f2_i == `ALTO_EMULATOR_F2_MAGIC;

	always @ (posedge clk_i)
		if(in_emulator && f2_i == `ALTO_EMULATOR_F2_IR_LOAD && !stall_i)
			skip_o <= 1'b0;
	
	always @ (posedge clk_i)
		if(in_emulator && f2_i == `ALTO_EMULATOR_F2_IR_LOAD && !stall_i)
			ir <= bus_i;

	always @ (*)
		case({ in_emulator, f2_i })
		{ 1'b1, `ALTO_EMULATOR_F2_IR_LOAD }: modifiers_o = { 6'b0, bus_i[15], bus_i[10:8] };
		{ 1'b1, `ALTO_EMULATOR_F2_BUSODD }:  modifiers_o = { 9'b0, bus_i[15] };
		default:                             modifiers_o = 10'b0;
		endcase
		
	always @ (*)
		if(bs_i == `ALTO_BS_DISP)
		begin
			bus_o[7:0] = ir[7:0];
			
			if(ir[9:8] == 2'b00)
				bus_o[15:8] = 8'b0;
			else
				bus_o[15:8] = { 8 { ir[7] } };
		end
		else
			bus_o = 16'hFFFF;

endmodule
