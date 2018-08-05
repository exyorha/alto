`timescale 1ns / 1ps
`include "alto_definitions.v"

module alto_control (
	input         clk_i,
	input         rst_i,
	
	input  [15:0] task_request_i,
	
	output  [2:0] bs_o,
	output  [4:0] rsel_o,
	output  [3:0] f1_o,
	output  [3:0] f2_o,  
	output  [3:0] aluf_o,
	output        load_l_o,
	output        load_t_o,
	output        dns_o,
	input         dns_carry_i,
	output        dns_carry_o,
	output  [7:0] constant_adr_o,
	output        constant_access_o,
	
	input   [9:0] next_modifier_i,
	output  [3:0] current_task_o,
	
	input         stall_i
);

	wire switch_task;
	reg [3:0] previous_task;
	wire [3:0] active_task;
	wire [9:0] next;
	wire [9:0] pending_modifier = 10'b0;
	reg [15:0] rmr = 16'hFFFF;
	wire clear_rmr;
	wire task_context_initializing;
	
	/* verilator lint_off UNOPTFLAT */
	wire [11:0] mpc;
	/* verilator lint_on UNOPTFLAT */
	wire [31:0] uinsn;
	
	reg [9:0] delayed_modifier;
	
	always @ (posedge clk_i)
	begin
		if(!stall_i)
		begin
			previous_task <= active_task;
			delayed_modifier <= next_modifier_i;
		end
	end
	
	always @ (posedge clk_i)
		if(clear_rmr)
			rmr <= 16'hFFFF;
		// TODO: RMR load
		
	alto_control_taskswitch taskswitch (
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		.switch_task_i(switch_task),
		
		.task_request_i(task_request_i),
		.active_task_o(active_task)
	);
	
	alto_control_taskcontext taskcontext (
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		.rmr_i(rmr),
		.clear_rmr_o(clear_rmr),
		.initializing_o(task_context_initializing),
		
		.task_i(previous_task),
		.next_task_i(active_task),
		.stall_i(stall_i),
		.mpc_i({ mpc[11:10], next | delayed_modifier }),
		.mpc_o(mpc)
	);
	
	alto_control_store store (
		.clk_i(clk_i),
		.initializing_i(task_context_initializing),
		
		.mpc_i(mpc),
		.instruction_o(uinsn)
	);
	
	wire special_constant_access = f1_o == `ALTO_F1_CONSTANT || f2_o == `ALTO_F2_CONSTANT;

	assign next = uinsn[9:0];
	assign load_l_o = ~uinsn[10] && !stall_i;
	assign load_t_o = uinsn[11] && !stall_i;
	assign f2_o = { ~uinsn[15], uinsn[14:12] };
	assign f1_o = { ~uinsn[19], uinsn[18:16] };
	assign bs_o = special_constant_access ? `ALTO_BS_NONE : uinsn[22:20];
	assign aluf_o = uinsn[26:23];
	assign rsel_o = uinsn[31:27];
	
	assign constant_adr_o    = { uinsn[31:27], uinsn[22:20] };
	assign constant_access_o = special_constant_access || bs_o >= 3'o4;
	
	assign switch_task = f1_o == `ALTO_F1_TASK && !stall_i;
	
	assign current_task_o = previous_task;
	
endmodule
