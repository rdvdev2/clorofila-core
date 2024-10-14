`include "constants.svh"

import memory_access_width::*;

interface memory_port;
	logic valid;
	logic we;
	logic [`ADDR_MASK] addr;
	memory_access_width_t width;
	logic [`WORD_MASK] mem_rd;
	logic [`WORD_MASK] mem_wr;
endinterface;
