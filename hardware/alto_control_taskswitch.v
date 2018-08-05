`timescale 1ns / 1ps
module alto_control_taskswitch (
	input            clk_i,
	input            rst_i,
	
	input			     switch_task_i,
	
	input     [15:0] task_request_i,
	output reg [3:0] active_task_o
);

	(* priority_extract = "force" *)
	reg [3:0] next_task;
		
	always @ (posedge clk_i)
		if(rst_i)
			active_task_o <= 4'b0;
		else if(switch_task_i)
			active_task_o <= next_task;

	always @ (*)
		if(task_request_i[15])
			next_task = 4'd15;			
		else if(task_request_i[14])
			next_task = 4'd14;		
		else if(task_request_i[13])
			next_task = 4'd13;		
		else if(task_request_i[12])
			next_task = 4'd12;		
		else if(task_request_i[11])
			next_task = 4'd11;		
		else if(task_request_i[10])
			next_task = 4'd10;		
		else if(task_request_i[9])
			next_task = 4'd9;		
		else if(task_request_i[8])
			next_task = 4'd8;		
		else if(task_request_i[7])
			next_task = 4'd7;		
		else if(task_request_i[6])
			next_task = 4'd6;		
		else if(task_request_i[5])
			next_task = 4'd5;		
		else if(task_request_i[4])
			next_task = 4'd4;		
		else if(task_request_i[3])
			next_task = 4'd3;		
		else if(task_request_i[2])
			next_task = 4'd2;		
		else if(task_request_i[1])
			next_task = 4'd1;		
		else if(task_request_i[0])
			next_task = 4'd0;	
		else
			next_task = 4'bXXXX;

endmodule
