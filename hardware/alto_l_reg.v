`timescale 1ns / 1ps
module alto_l_reg (
	input             clk_i,
	
	input             load_i,
	input      [15:0] dat_i,
	input             carry_i,
	output reg [15:0] dat_o,
	output reg        carry_o
);

	always @ (posedge clk_i)
		if(load_i)
		begin
			dat_o <= dat_i;
			carry_o <= carry_i;
		end

endmodule
