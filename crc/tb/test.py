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
from random import randint

########################################
# Test functions
########################################

PRINT_INTO = False

class Signals():
    """ Signal used for serial crc calculation """
    def __init__(self, din, req, ready, valid, crc):
        self.din = din
        self.req = req
        self.ready = ready
        self.valid = valid
        self.crc = crc

async def setup(dut, signals):
    """ Setup the design """
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_b.value = 0
    signals.req.value = 0
    signals.din.value = 0
    await Timer(20, units="ns")
    dut.rst_b.value = 1

async def crc_gen_s(dut, data, signals):
    """ give input to crc_gen_s module and wait for the crc to be ready """
    await FallingEdge(dut.clk)
    assert signals.ready.value.integer == 1, dut._log.error("crc_gen_s should be ready at this time.")
    signals.din.value = data
    signals.req.value = 1
    await RisingEdge(dut.clk)
    signals.din.value = 0
    signals.req.value = 0
    # wait till the valid is set
    await RisingEdge(signals.valid)
    return signals.crc.value.integer

async def crc_gen_s_tester(dut, calc, signals, num_bytes, first=0, last=0xff, iters=100):
    """ test the crc_gen_s module """
    await setup(dut, signals)
    for i in range(iters):
        num = randint(first, last)
        checksum = calc.checksum(num.to_bytes(num_bytes, byteorder='big'))
        crc = await crc_gen_s(dut, num, signals)
        await Timer(20, "ns")
        if PRINT_INTO:
            dut._log.info(f"Data: {hex(num)}, Expected CRC: {hex(checksum)}, Actual CRC: {hex(crc)}")
        assert (crc == checksum), dut._log.error(f"ERROR: Got wrong CRC result. Data: {hex(num)}, Expected CRC: {hex(checksum)}, Actual CRC: {hex(crc)}")

async def crc_gen_p_tester(dut, calc, din, crc_out, num_bytes, first=0, last=0xff, iters=100):
    """ test the crc_gen_p module """
    for i in range(iters):
        num = randint(first, last)
        checksum = calc.checksum(num.to_bytes(num_bytes, byteorder='big'))
        din.value = num
        await Timer(20, "ns")
        crc = crc_out.value.integer
        if PRINT_INTO:
            dut._log.info(f"Data: {hex(num)}, Expected CRC: {hex(checksum)}, Actual CRC: {hex(crc)}")
        assert (crc == checksum), dut._log.error(f"ERROR: Got wrong CRC result. Data: {hex(num)}, Expected CRC: {hex(checksum)}, Actual CRC: {hex(crc)}")
    pass

########################################
# Test 8 bit crc module
########################################

cfg8 = Configuration(
    width=8,
    polynomial=0x9b,
    init_value=0xFF,
    final_xor_value=0x00,
    reverse_input=False,
    reverse_output=False,
)

@cocotb.test()
async def test_crc_gen_s_8c_8d(dut):
    """ 8 bit serial crc with 8 bit data"""
    calc = Calculator(cfg8)
    signals = Signals(dut.din_8, dut.req_8, dut.ready_8, dut.valid_8, dut.crc_8)
    await crc_gen_s_tester(dut, calc, signals, 1, 0x0, 0x0)

@cocotb.test()
async def test_crc_gen_s_8c_16d(dut):
    """ 8 bit serial crc with 16 bit data"""
    calc = Calculator(cfg8)
    signals = Signals(dut.din_8a, dut.req_8a, dut.ready_8a, dut.valid_8a, dut.crc_8a)
    await crc_gen_s_tester(dut, calc, signals, 2, 0x0000, 0xffff)

@cocotb.test()
async def test_crc_gen_p_8c_8d(dut):
    """ 8 bit parallel crc with 8 bit data"""
    calc = Calculator(cfg8)
    await crc_gen_p_tester(dut, calc, dut.din_8p, dut.crc_8p, 1)

@cocotb.test()
async def test_crc_gen_p_8c_16d(dut):
    """ 8 bit parallel crc with 16 bit data"""
    calc = Calculator(cfg8)
    await crc_gen_p_tester(dut, calc, dut.din_8pa, dut.crc_8pa, 2, 0x0000, 0xffff)

########################################
# Test 16 bit crc module
########################################

cfg16 = Configuration(
    width=16,
    polynomial=0x1021,
    init_value=0xFFFF,
    final_xor_value=0x0000,
    reverse_input=False,
    reverse_output=False,
)

@cocotb.test()
async def test_crc_gen_16(dut):
    """ 16 bit crc with 16 bit data"""
    calc = Calculator(cfg16)
    signals = Signals(dut.din_16, dut.req_16, dut.ready_16, dut.valid_16, dut.crc_16)
    await crc_gen_s_tester(dut, calc, signals, 2, 0x0000, 0xffff)


@cocotb.test()
async def test_crc_gen_16_8bit(dut):
    """ 16 bit crc with 8 bit data"""
    calc = Calculator(cfg16)
    signals = Signals(dut.din_16a, dut.req_16a, dut.ready_16a, dut.valid_16a, dut.crc_16a)
    await crc_gen_s_tester(dut, calc, signals, 1)

@cocotb.test()
async def test_crc_gen_16_32bit(dut):
    """ 16 bit crc with 32 bit data"""
    calc = Calculator(cfg16)
    signals = Signals(dut.din_16b, dut.req_16b, dut.ready_16b, dut.valid_16b, dut.crc_16b)
    await crc_gen_s_tester(dut, calc, signals, 4, 0x00000000, 0xffffffff)

########################################
# Test 32 bit crc module
########################################

cfg32 = Configuration(
    width=32,
    polynomial=0x04C11DB7,
    init_value=0xFFFFFFFF,
    final_xor_value=0x00000000,
    reverse_input=False,
    reverse_output=False,
)

@cocotb.test()
async def test_crc_gen_32(dut):
    """ 32 bit crc with 32 bit data"""
    calc = Calculator(cfg32)
    signals = Signals(dut.din_32, dut.req_32, dut.ready_32, dut.valid_32, dut.crc_32)
    await crc_gen_s_tester(dut, calc, signals, 4, 0x0, 0xffffffff)

@cocotb.test()
async def test_crc_gen_32_8bit(dut):
    """ 32 bit crc with 8 bit data"""
    calc = Calculator(cfg32)
    signals = Signals(dut.din_32a, dut.req_32a, dut.ready_32a, dut.valid_32a, dut.crc_32a)
    await crc_gen_s_tester(dut, calc, signals, 1, 0x0, 0xff)

@cocotb.test()
async def test_crc_gen_32_16bit(dut):
    """ 32 bit crc with 16 bit data"""
    calc = Calculator(cfg32)
    signals = Signals(dut.din_32b, dut.req_32b, dut.ready_32a, dut.valid_32b, dut.crc_32b)
    await crc_gen_s_tester(dut, calc, signals, 2, 0x0, 0xffff)

@cocotb.test()
async def test_crc_gen_32_64bit(dut):
    """ 32 bit crc with 64 bit data"""
    calc = Calculator(cfg32)
    signals = Signals(dut.din_32c, dut.req_32c, dut.ready_32c, dut.valid_32c, dut.crc_32c)
    await crc_gen_s_tester(dut, calc, signals, 8, 0x0, 0xffffffff)
