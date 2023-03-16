# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/01/2023
# ------------------------------------------------------------------------------------------------
# Testbench for Fibonacci LFSR
# pylfsr module is required for this test:
# https://pypi.org/project/pylfsr/
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock


def bits(data, pos):
    return (data >> pos) & 0x1

def Fibonacci_LFSR_6801(initVal, dire):
    """
    Fibonacci LFSR for polynomial: x^16 + x^14 + x^13 + x^11 + 1
    """
    lfsr_reg = initVal
    while True:
        yield lfsr_reg
        # LFSR start with bit 0 as term x^1
        tap = bits(lfsr_reg, 13) ^ bits(lfsr_reg, 12) ^ bits(lfsr_reg, 10)
        if (dire == "MSB"):
            tap = tap ^ bits(lfsr_reg, 15)
            lfsr_reg = ((lfsr_reg << 1) | tap) & 0xFFFF
        if (dire == "LSB"):
            tap ^= bits(lfsr_reg, 0)
            lfsr_reg = (lfsr_reg >> 1) | (tap << (15))
        #print(f"lfsr is {hex(lfsr_reg)}, tap is {tap}")


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
    lfsr_model = Fibonacci_LFSR_6801(0xACE1, dire)
    await setup(dut)
    for _ in range(10):
        expected = next(lfsr_model)
        dut._log.info("LFSR output is %x. LFSR Model output is %x", lfsr_out.value, expected)
        assert lfsr_out.value == expected, f"Got wrong value. See the value above."
        await FallingEdge(dut.clk)

@cocotb.test()
async def test_msb(dut):
    await tester(dut, "MSB", dut.lfsr_out_msb)