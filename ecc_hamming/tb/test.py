# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/07/2023
# ------------------------------------------------------------------------------------------------
# Testbench for scrambler
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

async def new_code(dut, data):
    dut.din.value = data
    await Timer(10, "ns")
    codeword = dut.codeword.value.integer
    codeword74 = dut.codeword_74.value.integer
    extra_parity = dut.extra_parity_74.value.integer
    extra_parity74 = dut.extra_parity.value.integer
    dut._log.info("************************************")
    dut._log.info(f"data = {hex(data)}, codeword       = {hex(codeword)}, extra_parity       = {extra_parity}")
    dut._log.info(f"data = {hex(data)}, codeword (7,4) = {hex(codeword74)}, extra_parity (7,4) = {extra_parity74}")
    assert (codeword == codeword74) and (extra_parity == extra_parity74), "ERROR: codeword or extra parity does not match"

@cocotb.test()
async def test_hamming_code(dut):
    await new_code(dut, 0x1)
    await new_code(dut, 0x2)
    await new_code(dut, 0x3)
    await new_code(dut, 0x4)
    await new_code(dut, 0x5)
    await new_code(dut, 0x6)
    await new_code(dut, 0x7)
    await Timer(100, "ns")
