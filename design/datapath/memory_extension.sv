`include "constants.svh"

import memory_access_width::*;

module memory_extension (
	input logic [`WORD_MASK] data_rd,
	input memory_access_width_t width,
	input logic data_signed,
	output logic [`WORD_MASK] data_extended
);

always_comb
begin
	unique case (width)
		BYTE: if (data_signed)
				data_extended = {{24{data_rd[7]}}, data_rd[7:0]};
			else
				data_extended = {{24{1'b0}}, data_rd[7:0]};
		HALF: if (data_signed)
				data_extended = {{16{data_rd[15]}}, data_rd[15:0]};
			else
				data_extended = {{16{1'b0}}, data_rd[15:0]};
		WORD:
				data_extended = data_rd;
	endcase
end

endmodule;
