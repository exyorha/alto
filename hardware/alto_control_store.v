`timescale 1ns / 1ps
module alto_control_store (
	input             clk_i,
	input             initializing_i,
	
	input      [11:0] mpc_i,
	output reg [31:0] instruction_o
);

	reg [31:0] microstore [0:4095];
	
	always @ (posedge clk_i)
		if(initializing_i)
			instruction_o <= 32'b0;
		else
			instruction_o <= microstore[mpc_i];

	integer i;
	initial
		for(i = 0; i < 4096; i = i + 1)
			microstore[i[11:0]] = i[31:0];

endmodule
