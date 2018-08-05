`timescale 1ns / 1ps
`include "alto_definitions.v"
module alto_mouse (
	input       [2:0] bs_i,
	output reg [15:0] bus_o
);

	always @ (*)
		if(bs_i == `ALTO_BS_MOUSE)
			bus_o = { 12'hFFF, 4'b0 };
		else
			bus_o = 16'hFFFF;

endmodule
