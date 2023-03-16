# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/03/2023
# ------------------------------------------------------------------------------------------------
# Testbench for Galois LFSR
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

def Galois_LFSR_6801(initVal, dire):
    lfsr_reg = initVal
    while 1:
        yield lfsr_reg
        if dire == "MSB":
            msb = lfsr_reg & 0x8000
            if msb:
                lfsr_reg = ((lfsr_reg << 1) ^ 0x6801) & 0xffff
            else:
                lfsr_reg = (lfsr_reg << 1) | msb
        if dire == "LSB":
            lsb = lfsr_reg & 0x1
            if lsb:
                lfsr_reg = (lfsr_reg >> 1) ^ (0x6801 >> 1)
            else:
                lfsr_reg = (lfsr_reg >> 1) | (lsb << 15)

async def setup(dut):
    dut.load.value = 0
    dut.shift_en.value = 1
    dut.lfsr_in.value = 0
    dut.din.value = 0
    dut.rst_b.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await Timer(20, units="ns")
    dut.rst_b.value = 1

async def tester(dut, dire, lfsr_out):
    """Try accessing the design."""
    lfsr_model = Galois_LFSR_6801(0xACE1, dire)
    await setup(dut)
    for _ in range(10):
        expected = next(lfsr_model)
        dut._log.info("LFSR output is %x. LFSR Model output is %x", lfsr_out.value, expected)
        assert lfsr_out.value == expected, f"Got wrong value. See the value above."
        await FallingEdge(dut.clk)

@cocotb.test()
async def test_lsb(dut):
    await tester(dut, "MSB", dut.lfsr_out_lsb)
