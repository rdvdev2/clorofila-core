`include "vunit_defines.svh"
`include "constants.svh"
`include "verif_constants.svh"

module tb_datapath;

    logic clk;
    logic rst_n;
    memory_port mem_port(clk);
    datapath_control control();

    datapath DUT (.*);
    memory_vcomp MEM (.*);
    
    always #`CLOCK_SEMIPERIOD clk=~clk;

    `TEST_SUITE begin
        `TEST_SUITE_SETUP begin
            clk = 0;
        end

        `TEST_CASE_SETUP begin
            rst_n = 0;
            #`CLOCK_PERIOD
            rst_n = 1;
            #`CLOCK_PERIOD;
            $display("Datapath was reset");
        end

        `TEST_CASE("instantiation") begin
        end
    end;
endmodule
