'''
dut = "alu"
parameters = { WIDTH = 32 }
sources = [
	"design/datapath/alu_operation.sv",
	"design/datapath/alu.sv",
]
'''

import enum
import random

import cocotb
from cocotb.triggers import Timer


class Operation(enum.Enum):
	ADD = 0


async def check_operation(dut, operation, a, b, expected):
	dut.op.value = operation.value
	dut.x.value = a
	dut.y.value = b

	await Timer(1)
	assert int(dut.w) == expected, f'Unexpected result for operation {a} {operation.name} {b}'


async def fuzz(dut, operation, a_max, b_max, calculate_expected, attempts):
	for _ in range(attempts):
		a = random.randint(0, a_max)
		b = random.randint(0, b_max)
		expected = calculate_expected(a, b)

		await check_operation(dut, operation, a, b, expected)

@cocotb.test()
async def add(dut):
	await fuzz(dut, Operation.ADD, 2**32 - 1, 2**32 - 1, lambda a, b: (a + b) % (2**32), 1000)
