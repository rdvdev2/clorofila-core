`include "vunit_defines.svh"
`include "constants.svh"
`include "verif_constants.svh"

import alu_operation::*;

module tb_alu;

    localparam WIDTH = `WORD_WIDTH;

    logic [WIDTH-1:0] x;
    logic [WIDTH-1:0] y;
    alu_operation_t op;
    logic [WIDTH-1:0] w;

    alu #(.WIDTH(WIDTH)) DUT (.*);

    task check_operation(alu_operation_t operation, logic [WIDTH-1:0] a, logic [WIDTH-1:0] b, logic [WIDTH-1:0] expected);
        op = operation;
        x = a;
        y = b;
        #1
        `CHECK_EQUAL(w, expected, $sformatf("Unexpected result for operation %0d %s %0d", a, operation.name(), b));
    endtask;

    `TEST_SUITE begin
        `TEST_CASE("add") begin
            integer i;
            for (i = 0; i < 1000; ++i)
            begin
                automatic logic [WIDTH-1:0] a = $urandom();
                automatic logic [WIDTH-1:0] b = $urandom();
                check_operation(ADD, a, b, a+b);
            end
        end
    end;
endmodule;