`include "constants.svh"

import memory_access_width::*;

interface memory_port;
	logic valid;
	logic we;
	logic [`ADDR_MASK] addr;
	memory_access_width_t width;
	logic [`WORD_MASK] data_wr;
	logic [`WORD_MASK] data_rd;

	modport memory (input valid, input we, input addr, input width, input data_wr, output data_rd);
	modport datapath (output valid, output we, output addr, output width, output data_wr, input data_rd);
endinterface;
