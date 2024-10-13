`include "constants.svh"

import alu_operation::*;

module alu #(
    parameter WIDTH = `WORD_WIDTH
) (
    input logic [WIDTH-1:0] x,
    input logic [WIDTH-1:0] y,
    input alu_operation_t op,
    output logic [WIDTH-1:0] w
);

always_comb
begin

    case (op)
        ADD: w = x + y;
    endcase
end

endmodule;