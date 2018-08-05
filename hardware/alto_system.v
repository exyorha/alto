`timescale 1ns / 1ps
module alto_system (
	input             clk_i,
	input             rst_i,
		
	output     [16:1] wb_adr_o,
	output            wb_stb_o,
	output            wb_cyc_o,
	output            wb_we_o,
	output      [1:0] wb_sel_o,
	output     [15:0] wb_dat_o,
	input      [15:0] wb_dat_i,
	input             wb_ack_i
);

	wire [15:0] bus_o, bus_i, bus_disk, bus_mouse;
	wire [9:0] modifiers, modifiers_disk;
	
	assign bus_i = bus_disk & bus_mouse;
	
	wire disk_sector_req, memory_refresh_req;
	
	wire [2:0] bs;
	wire [3:0] f1;
	wire [3:0] f2;
	wire [3:0] current_task;
	
	assign modifiers = modifiers_disk;
	
	alto_cpu cpu (
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		.bus_i(bus_i),
		.bus_o(bus_o),
		.modifiers_i(modifiers),
		
		.task_request_i({ 7'b0, memory_refresh_req, 3'b0, disk_sector_req, 3'b000 }),
		.bs_o(bs),
		.f1_o(f1),
		.f2_o(f2),
		.current_task_o(current_task),
		
		.wb_adr_o(wb_adr_o),
		.wb_stb_o(wb_stb_o),
		.wb_cyc_o(wb_cyc_o),
		.wb_we_o(wb_we_o),
		.wb_sel_o(wb_sel_o),
		.wb_dat_o(wb_dat_o),
		.wb_dat_i(wb_dat_i),
		.wb_ack_i(wb_ack_i)
	);
	
	alto_disk disk (
		.clk_i(clk_i),
		.rst_i(rst_i),
		.sector_req_o(disk_sector_req),
		.bus_i(bus_o),
		.bus_o(bus_disk),
		.modifiers_o(modifiers_disk),
		.bs_i(bs),
		.f1_i(f1),
		.f2_i(f2),
		.current_task_i(current_task)
	);
	
	alto_memory_refresh memory_refresh (
		.clk_i(clk_i),
		.rst_i(rst_i),
		.f1_i(f1),
		.request_o(memory_refresh_req)
	);
	
	alto_mouse mouse (
		.bs_i(bs),
		.bus_o(bus_mouse)
	);

endmodule
