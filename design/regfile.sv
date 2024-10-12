`include "constants.svh"

module regfile #(
    parameter WIDTH = `WORD_WIDTH,
    parameter COUNT,
    localparam ADDR_WIDTH = $clog2(COUNT)
) (
    input logic clk,
    input logic rst_n,

    input logic [ADDR_WIDTH-1:0] addr_a,
    input logic [ADDR_WIDTH-1:0] addr_b,
    input logic [ADDR_WIDTH-1:0] addr_d,
    input logic we_d,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] a,
    output logic [WIDTH-1:0] b
);

logic [WIDTH-1:0] regs [COUNT-1:0];

always_ff @(posedge clk)
begin
    if (!rst_n)
    begin
        regs <= '{default:0};
    end
    else if (we_d)
    begin
        regs[addr_d] <= d;
    end
end

always_comb
begin
    a = regs[addr_a];
    b = regs[addr_b];
end

endmodule;