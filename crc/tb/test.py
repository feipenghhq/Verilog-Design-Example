# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/12/2023
# ------------------------------------------------------------------------------------------------
# Testbench for CRC
# python crc packet is required for the test:
# https://pypi.org/project/crc/
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

from crc import Calculator, Configuration

class Signals():
    def __init__(self, din, req, ready, valid, crc):
        self.din = din
        self.req = req
        self.ready = ready
        self.valid = valid
        self.crc = crc

async def setup(dut, signals):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_b.value = 0
    signals.req.value = 0
    signals.din.value = 0
    await Timer(20, units="ns")
    dut.rst_b.value = 1

async def crc_gen(dut, data, signals):
    """ give input to crc_gen module and wait for the crc to be ready """
    await FallingEdge(dut.clk)
    assert signals.ready.value.integer == 1, dut._log.error("crc_gen should be ready at this time.")
    signals.din.value = data
    signals.req.value = 1
    await RisingEdge(dut.clk)
    signals.din.value = 0
    signals.req.value = 0
    # wait till the valid is set
    await RisingEdge(signals.valid)
    return signals.crc.value.integer

async def test_crc_gen(dut, calc, last, signals, num_byte, first=0, print_info=False):
    await setup(dut, signals)
    for i in range(first, last):
        checksum = calc.checksum(i.to_bytes(num_byte, byteorder='big'))
        crc = await crc_gen(dut, i, signals)
        await Timer(20, "ns")
        if print_info:
            dut._log.info(f"Data: {hex(i)}, Expected CRC: {hex(checksum)}, Actual CRC: {hex(crc)}")
        assert (crc == checksum), dut._log.error(f"ERROR: Got wrong CRC result. Expected CRC: {hex(checksum)}, Actual CRC: {hex(crc)}")

@cocotb.test()
async def test_crc_gen_8(dut):
    cfg = Configuration(
        width=8,
        polynomial=0x9b,
        init_value=0xFF,
        final_xor_value=0x00,
        reverse_input=False,
        reverse_output=False,
    )
    calc = Calculator(cfg)
    signals = Signals(dut.din_8, dut.req_8, dut.ready_8, dut.valid_8, dut.crc_8)
    await test_crc_gen(dut, calc, 0xff, signals, 1)

@cocotb.test()
async def test_crc_gen_16(dut):
    cfg = Configuration(
        width=16,
        polynomial=0x1021,
        init_value=0xFFFF,
        final_xor_value=0x0000,
        reverse_input=False,
        reverse_output=False,
    )
    calc = Calculator(cfg)
    signals = Signals(dut.din_16, dut.req_16, dut.ready_16, dut.valid_16, dut.crc_16)
    await test_crc_gen(dut, calc, 0x1ff, signals, 2)
