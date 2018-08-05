`timescale 1ns / 1ps
module bus_rom #(
	parameter DEPTH = 3,
	parameter READONLY = 1,
	parameter DEFINED_WORDS = 1 << DEPTH,
	parameter INITIALIZE_RAM = 0,
	parameter INITIALIZATION_FILE = ""
) (
	input               clk_i,
	input               rst_i,
	input [DEPTH - 1:0] adr_i,
	input         [1:0] sel_i,
	input               stb_i,
	input               cyc_i,
	input               we_i,
	input        [15:0] dat_i,
	output reg   [15:0] dat_o,
	output reg          ack_o,
	output reg          err_o
);

	`define BUS_ROM_IDLE  2'b00
	`define BUS_ROM_ACK   2'b01
	`define BUS_ROM_ERROR 2'b10

	reg [1:0] state;

	reg [15:0] ram_data [0:DEFINED_WORDS - 1];


	always @ (posedge clk_i)
		if(rst_i)
		begin
			state <= `BUS_ROM_IDLE;
			ack_o <= 1'b0;
			err_o <= 1'b0;
		end
		else
			case(state)
			`BUS_ROM_IDLE:
				if(cyc_i && stb_i)
				begin
					if(we_i)
					begin
						if(READONLY)
						begin
							err_o <= 1'b1;
							state <= `BUS_ROM_ERROR;
						end
						else
						begin
							if(sel_i[0])
								ram_data[adr_i][7:0] <= dat_i[7:0];

							if(sel_i[1])
								ram_data[adr_i][15:8] <= dat_i[15:8];

							ack_o <= 1'b1;
							state <= `BUS_ROM_ACK;
						end
					end
					else
					begin
						dat_o <= ram_data[adr_i];
						ack_o <= 1'b1;
						state <= `BUS_ROM_ACK;
					end
				end

			`BUS_ROM_ERROR:
			begin
				err_o <= 1'b0;
				state <= `BUS_ROM_IDLE;
			end


			`BUS_ROM_ACK:
			begin
				ack_o <= 1'b0;
				state <= `BUS_ROM_IDLE;
			end
            default: ;
			endcase

    integer i;
	initial
	begin
		if(INITIALIZE_RAM)
			$readmemh(INITIALIZATION_FILE, ram_data);
        else
        begin
            /*
             * RAM will be initialized outside of synthesis.
             * Fill with dummy data to prevent trimming.
             */
            for(i = 0; i < DEFINED_WORDS; i = i + 1)
                ram_data[i] = 16'h0;
									 
				/*
				 * Fake keyboard - all keys released
				 */
				ram_data['o177034] = 16'hFFFF;
				ram_data['o177035] = 16'hFFFF;
				ram_data['o177036] = 16'hFFFF;
				ram_data['o177037] = 16'hFFFF;
        end
	end
endmodule
