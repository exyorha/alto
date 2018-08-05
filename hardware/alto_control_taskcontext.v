`timescale 1ns / 1ps
module alto_control_taskcontext (
	input         clk_i,
	input         rst_i,
	
	input  [15:0] rmr_i,
	output        clear_rmr_o,
	output        initializing_o,
	input         stall_i,
	
	input   [3:0] task_i,
	input   [3:0] next_task_i,
	input  [11:0] mpc_i,
	output [11:0] mpc_o
);

	reg [11:0] mpc_ram [0:15];
	
	reg initializing_mpc_ram;
	reg [3:0] initialization_adr;
	
	wire [3:0] internal_adr = initializing_mpc_ram ? initialization_adr : task_i;
	wire [11:0] internal_dat = initializing_mpc_ram ? { 1'b0, ~rmr_i[initialization_adr], 6'b0, initialization_adr } : mpc_i;
	
	assign mpc_o = (!initializing_mpc_ram && task_i == next_task_i && !stall_i) ? mpc_i : mpc_ram[next_task_i];
	
	always @ (posedge clk_i)
		if(!stall_i)
			mpc_ram[internal_adr] <= internal_dat;			
		
	always @ (posedge clk_i)
		if(rst_i)
			initializing_mpc_ram <= 1'b1;
		else if(&initialization_adr)
			initializing_mpc_ram <= 1'b0;
	
	always @ (posedge clk_i)
		if(rst_i)
			initialization_adr <= 4'b0;
		else if(initializing_mpc_ram)
			initialization_adr <= initialization_adr + 4'b1;

	assign clear_rmr_o = &initialization_adr;
	assign initializing_o = initializing_mpc_ram;
	
endmodule
