`include "vunit_defines.svh"
`include "constants.svh"
`include "verif_constants.svh"

import memory_access_width::*;

module tb_memory_extension;

	logic [`WORD_MASK] data_rd;
	memory_access_width_t width;
	logic data_signed;
	logic [`WORD_MASK] data_extended;

	memory_extension DUT (.*);

	task check(logic [`WORD_WIDTH] value, memory_access_width_t value_width, logic value_signed, logic [`WORD_MASK] expected);
		string conversion;

		data_rd = value;
		width = value_width;
		data_signed = value_signed;
		#1
		if (value_signed) conversion = "signed";
		else conversion = "unsigned";
		`CHECK_EQUAL(data_extended, expected, $sformatf("Unexpected result for %s extension of %s %0d", conversion, value_width.name(), value));
		#1;
	endtask;

	`TEST_SUITE begin
		`TEST_CASE("byte") begin
			integer i;

			for (i = 0; i < 1000; ++i)
			begin
				automatic logic unsigned [7:0] x_u = $urandom();
				automatic logic signed [7:0] x_s = x_u;
				automatic logic [`WORD_WIDTH] x = {{48{'x}}, x_u};
				check(x, BYTE, 0, x_u);
				check(x, BYTE, 1, x_s);
			end
		end
	
		`TEST_CASE("half") begin
			integer i;

			for (i = 0; i < 1000; ++i)
			begin
				automatic logic unsigned [15:0] x_u = $urandom();
				automatic logic signed [15:0] x_s = x_u;
				automatic logic [`WORD_WIDTH] x = {{32{'x}}, x_u};
				check(x, HALF, 0, x_u);
				check(x, HALF, 1, x_s);
			end
		end
	
		`TEST_CASE("word_unchanged") begin
			integer i;

			for (i = 0; i < 1000; ++i)
			begin
				automatic logic [`WORD_WIDTH] x = $urandom();
				check(x, WORD, 0, x);
				check(x, WORD, 1, x);
			end
		end
	end
endmodule
