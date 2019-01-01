`timescale 1ns / 1ps
`include "alto_definitions.v"

module alto_disk (
	input             clk_i,
	input             rst_i,
	output reg        sector_req_o,
	
	input       [3:0] current_task_i,
	input       [2:0] bs_i,
	input       [3:0] f1_i,
	input       [3:0] f2_i,
	
	input      [15:0] bus_i,
	output reg [15:0] bus_o,
	output reg  [9:0] modifiers_o
);

	reg [13:0] sector_counter;
	reg [1:0] state;

	`define ALTO_DISK_STATE_IDLE		2'b00
	`define ALTO_DISK_STATE_SEEK		2'b01
	`define ALTO_DISK_STATE_TRANSFER	2'b10
	
	wire disk_task = current_task_i == `ALTO_TASK_DISK_SECTOR;
	
	reg [3:0] sector;
	reg seek_fail;
	reg seek;
	reg not_rdy;
	reg data_late;
	reg idle;
	reg checksum_error;
	reg [1:0] completion_code;
	
	reg [7:0] kadr;
	
	wire [15:0] kstat = {
		sector,
		4'hF,
		seek_fail,
		seek,
		not_rdy,
		data_late,
		idle,
		checksum_error,
		completion_code
	};
	
	reg xferoff;
	reg wdinhib;
	reg bclksrc;
	reg wffo;
	reg sendaddr;
	reg [15:0] kdata_write;
	wire [15:0] kdata_read = 16'b0;
	
	reg [1:0] recno;
	
	reg [9:0] init_modifier;
	reg [9:0] rwc_modifier;
	reg [9:0] recno_modifier;
	
	wire data_xfer = ~kadr[1];
	
	wire wd_init = 1'b0;
		
	always @ (posedge clk_i)
		if(rst_i)
		begin
			state <= `ALTO_DISK_STATE_IDLE;
			sector_req_o <= 1'b0;
			sector_counter <= 14'b0;
			sector <= 4'b0;
			seek_fail <= 1'b0;
			seek <= 1'b0;
			not_rdy <= 1'b0;
			data_late <= 1'b0;
			idle <= 1'b1;
			checksum_error <= 1'b0;
			completion_code <= 2'b00;
			kadr <= 8'b0;
			xferoff <= 1'b1;
			wdinhib <= 1'b1;
			bclksrc <= 1'b0;
			wffo <= 1'b0;
			sendaddr <= 1'b0;
			kadr <= 8'b0;
			kdata_write <= 16'b0;
			recno <= 2'b00;
		end
		else
		begin
			if(current_task_i == `ALTO_TASK_DISK_SECTOR && f1_i == `ALTO_F1_BLOCK)
				sector_req_o <= 1'b0;
					
			if(disk_task)
				case(f1_i)
				`ALTO_DISK_F1_KSTAT_LOAD:
				begin
					$display("write kstat");
					
					idle <= bus_i[3];
					checksum_error <= checksum_error | ~bus_i[2];
					completion_code <= bus_i[1:0];
				end
				
				`ALTO_DISK_F1_INCRECNO:
				begin
					$display("advance kadr");
					
					kadr <= { kadr[5:0], 2'b00 };
				end
				
				`ALTO_DISK_F1_CLRSTAT:
				begin
					$display("clear status");
					
					checksum_error <= 1'b0;
					data_late <= 1'b0;
					not_rdy <= 1'b0;
					seek_fail <= 1'b0;
				end
				
				`ALTO_DISK_F1_KCOMM_LOAD:
				begin
					$display("load kcomm: %b, WDINHIB is %b", bus_i, bus_i[13]);
					
					xferoff <= bus_i[14];
					wdinhib <= bus_i[13];
					bclksrc <= bus_i[12];
					wffo <= bus_i[11];
					sendaddr <= bus_i[10];
				end
				
				`ALTO_DISK_F1_KADR_LOAD:
				begin
					$display("load kaddr");
					
					kadr <= bus_i[7:0];
				end
				
				`ALTO_DISK_F1_KDATA_LOAD:
				begin
					$display("load kdata");
					
					kdata_write <= bus_i;
				end

				default:;
				endcase
					
			case(state)
			`ALTO_DISK_STATE_IDLE:
			begin
				if(!(|sector_counter))
				begin
					sector_req_o <= 1'b1;
					sector_counter <= 14'd12249;
					seek <= 1'b0;
				end
				else
				begin
					sector_counter <= sector_counter - 1'b1;
				end
				
				if(disk_task && f1_i == `ALTO_DISK_F1_STROBE)
				begin
					$display("strobed, sendaddr %b", sendaddr);
					
					if(sendaddr)
					begin
						seek <= 1'b1;
					end
				end
			
				if(!wdinhib)
					state <= `ALTO_DISK_STATE_TRANSFER;
			end
			default:;
			endcase
		end
		
	always @ (*)
		if(disk_task)
			case(bs_i)
			`ALTO_DISK_BS_KSTAT: bus_o = kstat;
			`ALTO_DISK_BS_KDAT:  bus_o = kdata_read;
			default:             bus_o = 16'hFFFF;
			endcase
		else
			bus_o = 16'hFFFF;
	
	always @ (*)
		casez(kadr[7:6])
		2'b00: rwc_modifier = 10'd0;
		2'b01: rwc_modifier = 10'd2;
		2'b1?: rwc_modifier = 10'd3;
		endcase
	
	always @ (*)
		case(recno)
		2'b00: recno_modifier = 10'd0;
		2'b01: recno_modifier = 10'd2;
		2'b10: recno_modifier = 10'd3;
		2'b11: recno_modifier = 10'd1;
		endcase
	
	always @ (*)
		if(disk_task)
			case(f2_i)
			`ALTO_DISK_F2_INIT:    modifiers_o = init_modifier;
			`ALTO_DISK_F2_RWC:     modifiers_o = init_modifier | rwc_modifier;
			`ALTO_DISK_F2_RECNO:   modifiers_o = init_modifier | recno_modifier;
			`ALTO_DISK_F2_XFRDAT:  modifiers_o = init_modifier | { 9'b0, data_xfer };
			`ALTO_DISK_F2_SWRNRDY: modifiers_o = init_modifier | { 9'b0, (seek | not_rdy) };
			`ALTO_DISK_F2_NFER:    modifiers_o = init_modifier | { 9'b0, !(not_rdy | data_late | seek_fail) };
			`ALTO_DISK_F2_STROBON: modifiers_o = init_modifier | { 9'b0, seek };
			default:               modifiers_o = 10'b0;
			endcase
		else
			modifiers_o = 10'b0;
	
	always @ (*)
		if(current_task_i == `ALTO_TASK_DISK_WORD && wd_init)
			init_modifier = 10'o37;
		else
			init_modifier = 10'o0;
			
endmodule
