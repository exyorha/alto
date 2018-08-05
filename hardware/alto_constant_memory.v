`timescale 1ns / 1ps
module alto_constant_memory (
	input [7:0] address_i,
	input access_i,
	
	output [15:0] data_o
);

	reg [15:0] constant_memory [0:255];
	
	assign data_o = access_i ? constant_memory[address_i] : 16'hFFFF;
	
	integer i;
	initial
		for(i = 0; i < 256; i = i + 1)
			constant_memory[i[7:0]] = i[15:0];
			
endmodule
