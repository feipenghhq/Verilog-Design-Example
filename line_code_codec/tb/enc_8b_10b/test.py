# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/24/2023
# ------------------------------------------------------------------------------------------------
# Testbench for 8b/10b encoder
# The following module is required for the test
# https://pypi.org/project/encdec8b10b/
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from encdec8b10b import EncDec8B10B

async def setup(dut):
    dut.datain_8b.value = 0
    dut.kin.value = 0
    dut.rdispin.value = 0   # start with 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_b.value = 0
    await Timer(20, units="ns")
    dut.rst_b.value = 1
    await RisingEdge(dut.clk)


@cocotb.test()
async def test_sanity(dut):
    """ a simple sanity check """
    await setup(dut)
    for i in range(256):
        running_disp = 0
        byte_to_enc = i
        running_disp, encoded = EncDec8B10B.enc_8b10b(byte_to_enc, running_disp)
        dut.datain_8b.value = i
        # wait for the next clock cycle
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dout = dut.dataout_10b.value.integer
        rdispout = dut.rdispout.value.integer
        # note: our output is bit reversed compared to the EncDec8B10B output
        encoded_bit_reversed = int('{:010b}'.format(encoded)[::-1], 2)
        assert dout == encoded_bit_reversed, dut._log.error(f"Error: get wrong encoding on data {i}. Expected: {bin(encoded_bit_reversed)}. Actual {bin(dout)}. RD out {running_disp}")
        assert rdispout == running_disp, dut._log.error(f"Error: get wrong running disp on data {i}. Expected: {running_disp}. Actual {rdispout}. Encoding: {bin(dout)}")
        #dut._log.info(f"data {i}. {bin(encoded_bit_reversed)}. RD out {running_disp}")
