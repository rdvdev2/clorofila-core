'''
dut = "memory_vcomp"
parameters = { BYTES = 1000 }
sources = [
	"design/datapath/memory/memory_access_width.sv",
	"design/datapath/memory/memory_port.sv",
	"verif/components/memory_vcomp.sv"
]
wrap_top = true
wrap_top_parameters = """
	parameter BYTES
"""
wrap_top_declarations = """
	logic clk, rst_n;
	memory_port mem_port(clk);
"""
'''

import cocotb


@cocotb.test()
async def instantiate(dut):
	pass
