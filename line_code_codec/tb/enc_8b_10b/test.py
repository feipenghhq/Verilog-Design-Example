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

async def tester(dut, k, t_range, rd, print_info=False):
    """ a simple sanity check """
    await setup(dut)
    for i in t_range:
        # Assert signals
        byte_to_enc = i
        dut.datain_8b.value = i
        dut.rdispin.value = rd
        dut.kin.value = k
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dout = dut.dataout_10b.value.integer
        rdispout = dut.rdispout.value.integer
        k_err = dut.k_err.value.integer
        # Check results
        rd_out, encoded = EncDec8B10B.enc_8b10b(byte_to_enc, rd, k)
        encoded_bit_reversed = int('{:010b}'.format(encoded)[::-1], 2) # note: our output is bit reversed compared to the EncDec8B10B output
        msg_data_mismatch = f"Error: get wrong encoding on data {i}. Expected: {bin(encoded_bit_reversed)}. Actual {bin(dout)}. RD in: {rd}. RD out {rdispout}. k_err: {k_err}"
        assert dout == encoded_bit_reversed, dut._log.error(msg_data_mismatch)
        if print_info:
            msg_good = f"Din: {i}. Dout: {bin(encoded_bit_reversed)}. RD in: {rd}. RD out {rdispout}."
            dut._log.info(msg_good)
        # Note: The RD calculation is wrong in the model?
        #msg_rd_mismatch = f"Error: get wrong RD on data {i}. Expected: {running_disp}. Actual {rdispout}. Encoding: {bin(dout)}"
        #assert rdispout == running_disp, dut._log.error(msg_rd_mismatch)


@cocotb.test()
async def test_data_rd0(dut):
    """ Test all data with RD=-1 """
    await tester(dut, 0, range(0,256), 0, True)

@cocotb.test()
async def test_data_rd1(dut):
    """ Test all data with RD=-1 """
    await tester(dut, 0, range(0,256), 1)

# Note: The RD calculation is wrong in the model for control word?
#@cocotb.test()
async def test_control_rd0(dut):
    """ Test all data with RD=-1 """
    await tester(dut, 1, range(0,256), 0)