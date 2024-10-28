'''
dut = "regfile"
parameters = { WIDTH = 32, REG_COUNT = 16 }
sources = [
	"design/datapath/regfile.sv"
]
'''

import cocotb
from cocotb.triggers import ClockCycles, Timer, RisingEdge
from cocotb.clock import Clock

async def reset(dut):
	dut.rst_n.value = 0
	await ClockCycles(dut.clk, 1)
	dut.rst_n.value = 1


async def setup(dut):
	clock = Clock(dut.clk, 10, 'ns')
	cocotb.start_soon(clock.start())
	await reset(dut)


async def check_port_a(dut, addr, expected):
	dut.addr_a.value = addr
	await Timer(1)
	assert int(dut.a) == expected, f'Unexpected value read from port A ({addr=})'


async def check_port_b(dut, addr, expected):
	dut.addr_b.value = addr
	await Timer(1)
	assert int(dut.b) == expected, f'Unexpected value read from port B ({addr=})'


async def write_port_d(dut, addr, value):
	dut.addr_d.value = addr
	dut.we_d.value = 1
	dut.d.value = value

	await RisingEdge(dut.clk)

	dut._log.info('Written %i to %i', value, addr)


@cocotb.test
async def reset_state(dut):
	await setup(dut)

	for addr in range(16):
		await check_port_a(dut, addr, 0)
		await check_port_b(dut, addr, 0)


@cocotb.test
async def write_then_read(dut):
	await setup(dut)

	for addr in range(16):
		await write_port_d(dut, addr, addr)
		await check_port_a(dut, addr, addr)
		await check_port_b(dut, addr, addr)


@cocotb.test
async def write_all_then_read_all(dut):
	await setup(dut)

	for addr in range(16):
		await write_port_d(dut, addr, addr)

	for addr in range(16):
		await check_port_a(dut, addr, addr)
		await check_port_b(dut, 16 - addr - 1, 16 - addr - 1)
