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
    dut.lfsr_in.value = 0
    dut.data.value = 0

async def tester(dut, dire, lfsr_out):
    """Try accessing the design."""
    lfsr_model = Galois_LFSR_6801(0xACE1, dire)
    await setup(dut)
    # get the expected value
    for _ in range(17):
        expected = next(lfsr_model)
    # drive input to lfsr
    dut.lfsr_in.value = 0xACE1
    dut.data.value = 0
    # wait some time
    await Timer(10, "ns")
    dut._log.info("LFSR output is %x. LFSR Model output is %x", lfsr_out.value, expected)
    assert lfsr_out.value == expected, f"Got wrong value. See the value above."


@cocotb.test()
async def test_msb1(dut):
    await tester(dut, "MSB", dut.lfsr_outa)

@cocotb.test()
async def test_msb2(dut):
    await tester(dut, "MSB", dut.lfsr_outb)