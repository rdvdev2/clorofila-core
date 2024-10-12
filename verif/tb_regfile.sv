`include "vunit_defines.svh"
`include "constants.svh"
`include "verif_constants.svh"

module tb_regfile;

    localparam WIDTH = `WORD_WIDTH;
    localparam REG_COUNT = `REG_COUNT;
    localparam ADDR_WIDTH = $clog2(REG_COUNT);

    logic clk;
    logic rst_n;
    logic [ADDR_WIDTH-1:0] addr_a;
    logic [ADDR_WIDTH-1:0] addr_b;
    logic [ADDR_WIDTH-1:0] addr_d;
    logic we_d;
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [WIDTH-1:0] d;

    regfile #(.WIDTH(WIDTH), .REG_COUNT(REG_COUNT)) DUT (.*);

    always #`CLOCK_SEMIPERIOD clk=~clk;

    task check_port_a(logic [ADDR_WIDTH-1:0] addr, logic [WIDTH-1:0] expected);
        addr_a = addr;
        #1
        `CHECK_EQUAL(a, expected, $sformatf("Unexpected value read from port B (addr = %0d)", addr));
    endtask;

    task check_port_b(logic [ADDR_WIDTH-1:0] addr, logic [WIDTH-1:0] expected);
        addr_b = addr;
        #1
        `CHECK_EQUAL(b, expected, $sformatf("Unexpected value read from port B (addr = %0d)", addr));
    endtask;

    task write_port_d(logic [ADDR_WIDTH-1:0] addr, logic [WIDTH-1:0] value);
        addr_d = addr;
        we_d = 1;
        d = value;
        #`CLOCK_PERIOD
        we_d = 0;
        $display("Written %0d to %0d", value, addr);
    endtask;

    `TEST_SUITE begin
        `TEST_SUITE_SETUP begin
            clk = 0;
        end

        `TEST_CASE_SETUP begin
            rst_n = 0;
            #`CLOCK_PERIOD
            rst_n = 1;
            #`CLOCK_PERIOD;
            $display("Regfile was reset");
        end

        `TEST_CASE("reset_state") begin
            integer i;

            for (i = 0; i < REG_COUNT; ++i)
            begin
                check_port_a(i, 0);
                check_port_b(i, 0);
            end
        end

        `TEST_CASE("write_then_read") begin
            integer i;

            for (i = 0; i < REG_COUNT; ++i)
            begin
                write_port_d(i, i);
                check_port_a(i, i);
                check_port_b(i, i);
            end
        end

        `TEST_CASE("write_all_then_read_all") begin
            integer i;

            for (i = 0; i < REG_COUNT; ++i)
            begin
                write_port_d(i, i);
            end

            for (i = 0; i < REG_COUNT; ++i)
            begin
                check_port_a(i, i);
                check_port_b(REG_COUNT - i - 1, REG_COUNT - i - 1);
            end
        end
    end;
endmodule