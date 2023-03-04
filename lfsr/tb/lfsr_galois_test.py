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

def Galois_LFSR(width, taps, initVal):
    """ A Galois LFSR Generator. """
    lfsr_reg = initVal
    while True:
        yield lfsr_reg

        # log the lsb
        lsb = lfsr_reg & 0x1
        # the msb is also taken care here because of the xoring.
        lfsr_reg >>= 1
        if lsb:
            lfsr_reg ^= taps

@cocotb.test()
async def test_galois_lfsr(dut):
    """Try accessing the design."""
    lfsr_model = Galois_LFSR(16, 0xB400, 0xACE1)

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_b.value = 0
    await Timer(20, units="ns")
    dut.rst_b.value = 1
    for _ in range(10):
        expected = next(lfsr_model)
        dut._log.info("LFSR output is %x. LFSR Model output is %x", dut.lfsr_out.value, expected)
        assert dut.lfsr_out.value == expected, "Got wrong value. See the value above."
        await FallingEdge(dut.clk)
    dut._log.info("Test Passed!")
