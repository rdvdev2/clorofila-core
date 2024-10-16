`include "constants.svh"

import datapath_control_types::*;

module datapath (
	input logic clk,
	input logic rst_n,
	memory_port.datapath mem_port,
	datapath_control.datapath control
);

logic [`WORD_MASK] mem_rd_extended;

logic [`WORD_MASK] regfile_a;
logic [`WORD_MASK] regfile_b;
logic [`WORD_MASK] regfile_d;

// Regfile muxs
always_comb
begin
	unique case (control.regfile_d)
		REGFILE_D_MEMORY: regfile_d = mem_rd_extended;
	endcase
end

regfile regfile(
	.clk,
	.rst_n,
	.addr_a(control.rs1),
	.addr_b(control.rs2),
	.addr_d(control.rd),
	.we_d(control.regfile_we),
	.d(regfile_d),
	.a(regfile_a),
	.b(regfile_a)
);

logic [`WORD_MASK] alu_x;
logic [`WORD_MASK] alu_y;
logic [`WORD_MASK] alu_w;

// ALU muxs
always_comb
begin
	unique case (control.alu_x)
		ALU_X_REGFILE: alu_x = regfile_a;
		ALU_X_PC: alu_x = control.pc;
	endcase

	unique case (control.alu_y)
		ALU_Y_REGFILE: alu_y = regfile_b;
		ALU_Y_IMMED: alu_y = control.immed;
	endcase
end

alu alu(
	.x(alu_x),
	.y(alu_y),
	.op(control.alu_op),
	.w(alu_w)
);

// Memory mux & control
always_comb
begin
	mem_port.valid = control.mem_valid;
	mem_port.we = control.mem_we;

	unique case (control.mem_addr)
		MEM_ADDR_ALU: mem_port.addr = alu_w;
		MEM_ADDR_PC: mem_port.addr = control.pc;
	endcase

	mem_port.width = control.mem_width;
	mem_port.data_wr = alu_w;
end

memory_extension memory_extension (
	.data_rd(mem_port.data_rd),
	.width(control.mem_width),
	.data_signed(control.mem_signed),
	.data_extended(mem_rd_extended)
);

// Signals sent to the control module
always_comb
begin
	control.mem_rd = mem_port.data_rd;
	control.alu_w = alu_w;
end

endmodule;
