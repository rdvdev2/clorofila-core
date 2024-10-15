`include "constants.svh"

import memory_access_width::*;

interface memory_port(input logic clk);
	logic valid;
	logic we;
	logic [`ADDR_MASK] addr;
	memory_access_width_t width;
	logic [`WORD_MASK] data_wr;
	logic [`WORD_MASK] data_rd;

	modport memory (input valid, input we, input addr, input width, input data_wr, output data_rd, clk, input should_read, input should_write);

	modport datapath (output valid, output we, output addr, output width, output data_wr, input data_rd, clk);

	function logic should_read();
		should_read = valid & !we;
	endfunction;

	function logic should_write();
		should_write = valid & we;
	endfunction;
endinterface;
