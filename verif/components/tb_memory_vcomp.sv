`include "vunit_defines.svh"
`include "constants.svh"
`include "verif_constants.svh"

import memory_access_width::*;

module tb_memory_vcomp;

	parameter MEM_BYTES = 1000;

	logic clk;
	logic rst_n;
	memory_port mem_port(clk);

	memory_vcomp #(.BYTES(MEM_BYTES)) DUT (.*);

	always #`CLOCK_SEMIPERIOD clk=~clk;

	task check_read_byte(logic [`ADDR_MASK] addr, logic [7:0] expected);
		mem_port.valid = 1;
		mem_port.we = 0;
		mem_port.addr = addr;
		#1
		`CHECK_EQUAL(mem_port.data_rd, expected, $sformatf("Unexpected byte read from address %0d", addr));
		#1
		mem_port.valid = 0;
	endtask;

	task check_read(logic [`ADDR_MASK] addr, memory_access_width_t width, logic [`WORD_MASK] expected);
		mem_port.valid = 1;
		mem_port.we = 0;
		mem_port.addr = addr;
		mem_port.width = width;
		#1
		case (width)
			BYTE: begin
				`CHECK_EQUAL(mem_port.data_rd[7:0], expected[7:0], $sformatf("Unexpected byte read from address %0d", addr));
			end
			HALF: begin
				`CHECK_EQUAL(mem_port.data_rd[15:0], expected[15:0], $sformatf("Unexpected byte read from address %0d", addr));
			end
			WORD: begin
				`CHECK_EQUAL(mem_port.data_rd, expected, $sformatf("Unexpected byte read from address %0d", addr));
			end
		endcase
		#1
		mem_port.valid = 0;
	endtask;

	task check_read_verify_le(logic [`ADDR_MASK] addr, memory_access_width_t width, logic [`WORD_MASK] expected);
				case (width)
					BYTE: begin
						check_read(addr, BYTE, expected[7:0]);
					end
					HALF: begin
						check_read(addr, HALF, expected[15:0]);
						check_read(addr, BYTE, expected[7:0]);
						check_read(addr+1, BYTE, expected[15:8]);
					end
					WORD: begin
						check_read(addr, WORD, expected);
						check_read(addr, HALF, expected[15:0]);
						check_read(addr+2, HALF, expected[31:16]);
						check_read(addr, BYTE, expected[7:0]);
						check_read(addr+1, BYTE, expected[15:8]);
						check_read(addr+2, BYTE, expected[23:16]);
						check_read(addr+3, BYTE, expected[32:24]);
					end
				endcase
	endtask;

	task write(logic [`ADDR_MASK] addr, memory_access_width_t width, logic [`WORD_MASK] value);
		mem_port.valid = 1;
		mem_port.we = 1;
		mem_port.addr = addr;
		mem_port.width = width;
		mem_port.data_wr = value;
		#`CLOCK_PERIOD
		mem_port.valid = 0;
		$display("Written %0d to %0d as %s", value, addr, width.name());
	endtask;

	`TEST_SUITE begin
		`TEST_SUITE_SETUP begin
			clk = 0;
		end

		`TEST_CASE_SETUP begin
			rst_n = 0;
			#`CLOCK_PERIOD
			rst_n = 1;
			#`CLOCK_PERIOD
			$display("Regfile was reset");
		end

		`TEST_CASE("reset_state") begin
			integer i;

			for (i = 0; i < MEM_BYTES; ++i)
			begin
				check_read(i, BYTE, 'x);
				if (i % 2 == 0) check_read(i, HALF, 'x);
				if (i % 4 == 0) check_read(i, WORD, 'x);
			end
		end

		`TEST_CASE("write_then_read") begin
			integer i;

			for (i = 0; i < MEM_BYTES; ++i)
			begin
				write(i, BYTE, i[7:0]);
				check_read_verify_le(i, BYTE, i[7:0]);

				if (i % 2 == 0)
				begin
					write(i, HALF, i[15:0]);
					check_read_verify_le(i, HALF, i[15:0]);
				end

				if (i % 4 == 0)
				begin
					write(i, WORD, i);
					check_read_verify_le(i, WORD, i);
				end
			end
		end

		`TEST_CASE("write_all_then_read_all") begin
			integer i;

			for (i = 0; i < MEM_BYTES; i += 4)
			begin
				write(i, WORD, i);
			end

			for (i = 0; i < MEM_BYTES; i += 4)
			begin
				check_read_verify_le(i, WORD, i);
			end
		end

		`TEST_CASE("write_all_then_random_access") begin
			integer i, i_adj;

			for (i = 0; i < MEM_BYTES; i += 4)
			begin
				write(i, WORD, i);
			end

			for (i = 0; i < 1000; ++i)
			begin
				i_adj = (i - (i % 4)) % MEM_BYTES;
				check_read_verify_le(i_adj, WORD, i_adj);
			end
		end
		
	end
endmodule;
