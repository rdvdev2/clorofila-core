`include "constants.svh"

import memory_access_width::*;

module memory_vcomp #(
    parameter BYTES = 64000 // 64K
) (
    input logic rst_n,
    memory_port.memory mem_port
);

logic [7:0] data [0:BYTES-1];

always_ff @ (posedge mem_port.clk)
begin
    if (!rst_n)
    begin
        data <= '{default:'x};
    end
    else if (mem_port.should_write())
    begin
        integer i;
        for (i = 0; i < memory_access_width_to_bytes(mem_port.width); ++i)
        begin
            data[mem_port.addr + i] <= mem_port.data_wr[i*8 +: 8];
        end
    end
end

always_comb
begin
    mem_port.data_rd = 'x;

    if (mem_port.should_read())
    begin
        integer i;
        for (i = 0; i < memory_access_width_to_bytes(mem_port.width); ++i)
        begin
            mem_port.data_rd[i*8 +: 8] = data[mem_port.addr + i];
        end
    end
end

endmodule;