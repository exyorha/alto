`timescale 1ns / 1ps
module alto_cpu (
	input             clk_i,
	input             rst_i,
	
	input      [15:0] bus_i,
	output     [15:0] bus_o,
	input       [9:0] modifiers_i,
	
	input      [14:0] task_request_i,
	
	output      [3:0] current_task_o,
	output      [2:0] bs_o,
	output      [3:0] f1_o,
	output      [3:0] f2_o,
	
	output     [16:1] wb_adr_o,
	output            wb_stb_o,
	output            wb_cyc_o,
	output            wb_we_o,
	output      [1:0] wb_sel_o,
	output     [15:0] wb_dat_o,
	input      [15:0] wb_dat_i,
	input             wb_ack_i
);

	wire [15:0] bus, bus_regs, bus_constant, bus_emulator, bus_memory;
	wire [15:0] shifter_output;
	wire [15:0] alu_bus;
	wire [15:0] l_reg_dat;
	wire [15:0] t_reg_dat;
	wire alu_carry;
	wire l_reg_carry;
	wire dns_carry_i;
	wire dns_carry_o;
	wire emulator_skip;
	wire [9:0] next_modifier, next_modifier_common, next_modifier_emulator;
	
	wire [2:0] ctrl_bs;
	wire [4:0] ctrl_rsel;
	wire [3:0] ctrl_f1;
	wire [3:0] ctrl_f2;
	wire [3:0] ctrl_aluf;
	wire ctrl_load_l;
	wire ctrl_load_t;
	wire emulator_magic;
	wire ctrl_dns;
	wire [7:0] constant_addr;
	wire constant_access;
	wire [3:0] current_task;
	
	wire stall, stall_memory;
	
	assign bus = bus_regs & bus_i & bus_constant & bus_emulator & bus_memory;
	assign next_modifier = next_modifier_common | next_modifier_emulator | modifiers_i;
	assign stall = stall_memory;
	
	assign bus_o = bus;
	assign current_task_o = current_task;
	assign bs_o = ctrl_bs;
	assign f1_o = ctrl_f1;
	assign f2_o = ctrl_f2;

	alto_control control (
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		.task_request_i({ task_request_i, 1'b1 }),
		
		.bs_o(ctrl_bs),
		.rsel_o(ctrl_rsel),
		.f1_o(ctrl_f1),
		.f2_o(ctrl_f2),
		.aluf_o(ctrl_aluf),
		.load_l_o(ctrl_load_l),
		.load_t_o(ctrl_load_t),
		.dns_o(ctrl_dns),
		.dns_carry_i(dns_carry_i),
		.dns_carry_o(dns_carry_o),
		.constant_adr_o(constant_addr),
		.constant_access_o(constant_access),
		
		.next_modifier_i(next_modifier),
		.current_task_o(current_task),
		.stall_i(stall)
	);
	
	alto_emulator_support emulator_support (
		.clk_i(clk_i),
		.current_task_i(current_task),
		.bs_i(ctrl_bs),
		.f2_i(ctrl_f2),
		.bus_i(bus),
		.bus_o(bus_emulator),
		.modifiers_o(next_modifier_emulator),
		.skip_o(emulator_skip),
		.magic_o(emulator_magic),
		.stall_i(stall)
	);
	
	alto_common_next_modifiers common_modifiers (
		.f2_i(ctrl_f2),
		.bus_i(bus),
		.shifter_i(shifter_output),
		.alu_carry_i(l_reg_carry),
		.modifiers_o(next_modifier_common)
	);
	
	alto_constant_memory constant (
		.address_i(constant_addr),
		.access_i(constant_access),
		.data_o(bus_constant)
	);
	
	alto_alu alu (
		.aluf_i(ctrl_aluf),
		.bus_i(bus),
		.t_i(t_reg_dat),
		.skip_i(emulator_skip),
		.output_o(alu_bus),
		.carry_o(alu_carry)
	);
	
	alto_shifter shifter (
		.input_i(l_reg_dat),
		.output_o(shifter_output),
		
		.f1_i(ctrl_f1),
		
		.t_i(t_reg_dat),
		.magic_i(emulator_magic),
		.dns_i(ctrl_dns),
		.dns_carry_i(dns_carry_o),
		.dns_carry_o(dns_carry_i)
	);
	
	alto_registers regs (
		.clk_i(clk_i),
		
		.bs_i(ctrl_bs),
		.rsel_i(ctrl_rsel),
		.dat_i(shifter_output),
		.dat_o(bus_regs),
		.stall_i(stall)
	);
	
	alto_t_reg t_reg (
		.clk_i(clk_i),
		
		.load_i(ctrl_load_t),
		.bus_dat_i(bus),
		.alu_dat_i(alu_bus),
		.aluf_i(ctrl_aluf),
		.dat_o(t_reg_dat)
	);
	
	alto_l_reg l_reg (
		.clk_i(clk_i),
		
		.load_i(ctrl_load_l),
		.dat_i(alu_bus),
		.carry_i(alu_carry),
		.dat_o(l_reg_dat),
		.carry_o(l_reg_carry)
	);
	
	alto_memory_interface memory_interface (
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		.adr_i(alu_bus),
		.dat_i(bus),
		.bs_i(ctrl_bs),
		.f1_i(ctrl_f1),
		.f2_i(ctrl_f2),
		.rsel_i(ctrl_rsel),
		.stall_o(stall_memory),
		.dat_o(bus_memory),
		
		.wb_adr_o(wb_adr_o),
		.wb_stb_o(wb_stb_o),
		.wb_cyc_o(wb_cyc_o),
		.wb_we_o(wb_we_o),
		.wb_sel_o(wb_sel_o),
		.wb_dat_o(wb_dat_o),
		.wb_dat_i(wb_dat_i),
		.wb_ack_i(wb_ack_i)
	);
	
endmodule
