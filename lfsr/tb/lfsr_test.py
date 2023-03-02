# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/01/2023
# ------------------------------------------------------------------------------------------------
# Testbench for LFSR
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

def Fibonacci_LFSR(width, taps, initVal):
    """ A Fibonacci LFSR Generator. """
    lfsr_reg = initVal
    while True:
        yield lfsr_reg

        # calculate the tap bit
        tap_bit = 0
        for i in range(width):
            if ((taps >> i) & 0x1) == 1:
                tap_bit ^= ((lfsr_reg >> i) & 0x1)

        # Right shift
        lfsr_reg = (lfsr_reg >> 1) | (tap_bit << (width - 1))


@cocotb.test()
async def test_fibonacci_lfsr(dut):
    """Try accessing the design."""
    lfsr_model = Fibonacci_LFSR(16, 0xB400, 0xACE1)

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
