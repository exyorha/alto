`timescale 1ns / 1ps
`include "alto_definitions.v"

module alto_memory_interface (
	input clk_i,
	input rst_i,
	
	input [15:0] adr_i,
	input [2:0] bs_i,
	input [3:0] f1_i,
	input [3:0] f2_i,
	input [4:0] rsel_i,
	input [15:0] dat_i,
	output [15:0] dat_o,
	
	output reg [16:1] wb_adr_o,
	output            wb_stb_o,
	output            wb_cyc_o,
	output            wb_we_o,
	output      [1:0] wb_sel_o,
	output     [15:0] wb_dat_o,
	input      [15:0] wb_dat_i,
	input             wb_ack_i,
	
	output            stall_o
);

	`define ALTO_MEMORY_INTERFACE_STATE_IDLE	1'b0
	`define ALTO_MEMORY_INTERFACE_STATE_WRITE	1'b1

	reg [0:0] state;
	
	wire cycle = (f2_i == `ALTO_F2_MD_STORE && f1_i != `ALTO_F1_MAR_LOAD) || bs_i == `ALTO_BS_MD;
	assign wb_we_o = f2_i == `ALTO_F2_MD_STORE;
	assign wb_dat_o = dat_i;
					
	always @ (posedge clk_i)
		if(rst_i)
			wb_adr_o <= 16'b0;
		else if(f1_i == `ALTO_F1_MAR_LOAD && !(&rsel_i))
			wb_adr_o <= adr_i;
		else if(wb_ack_i)
			wb_adr_o[1] <= ~wb_adr_o[1];
			
	assign stall_o = (f2_i == `ALTO_F2_MD_STORE || bs_i == `ALTO_BS_MD) && !wb_ack_i;
	
	assign dat_o = (bs_i == `ALTO_BS_MD && !stall_o) ? wb_dat_i : 16'hFFFF;
	
	assign wb_stb_o = cycle;
	assign wb_cyc_o = cycle;
	assign wb_sel_o = 2'b11;
	
	always @ (posedge clk_i)
		if(wb_ack_i)
		begin
			if(wb_we_o)
				$display("write: %o to %o", wb_dat_o, wb_adr_o);
			else if(wb_dat_i != 16'o1 || wb_adr_o != 16'o1)
				$display("read: %o from %o", wb_dat_i, wb_adr_o);
		end
	
endmodule

