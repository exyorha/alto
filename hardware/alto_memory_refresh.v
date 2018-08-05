`timescale 1ns / 1ps
`include "alto_definitions.v"
module alto_memory_refresh (
	input clk_i,
	input rst_i,
	
	input [3:0] f1_i,
	
	output reg request_o
);

	wire match;

	reg [7:0] counter;
	
	always @ (posedge clk_i)
		if(rst_i)
			request_o <= 1'b1;
		else if(match)
			request_o <= 1'b1;
		else if(f1_i == `ALTO_F1_BLOCK)
			request_o <= 1'b0;
	
	always @ (posedge clk_i)
		if(rst_i)
			counter <= 8'd0;
		else if(match)
			counter <= 8'd223;
		else
			counter <= counter - 1'b1;

	assign match = counter == 8'd0;

endmodule
