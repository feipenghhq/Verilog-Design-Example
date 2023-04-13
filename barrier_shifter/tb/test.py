# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 04/12/2023
# ------------------------------------------------------------------------------------------------
# Testbench for Barrier Shifter
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

########################################
# Test functions
########################################

PRINT_INTO = False

class Signals():
    def __init__(self, din, shift, dout):
        self.din = din
        self.shift = shift
        self.dout = dout

def rotate_left(data, shift, width):
    mask = (1 << width) - 1
    return ((data & mask) >> (width - shift)) | ((data << shift) & mask)

def rotate_right(data, shift, width):
    mask = (1 << width) - 1
    return ((data << (width - shift)) & mask) | ((data & mask) >> shift)

async def tester(dut, signals, width, rotate_fun, din, shift):
    signals.din.value = din
    signals.shift.value = shift
    await Timer(1, units="ns")
    value = signals.dout.value
    exp_value = rotate_fun(din, shift, width)
    err_msg = f"Error: din: {bin(din)}, shift: {shift}, expected dout: {bin(exp_value)}, actual dout: {bin(value)}"
    pass_msg = f"din: {bin(din)}, shift: {shift}, dout: {bin(value)}"
    assert value == exp_value, dut._log.error(err_msg)

@cocotb.test()
async def test_right_8b(dut):
    """ Test rotate right """
    signals = Signals(dut.din8, dut.shift8, dut.dout8r)
    for din in range(0, (1<<8)-1):
        for shift in range(0, 7):
            await tester(dut, signals, 8, rotate_right, din, shift)

@cocotb.test()
async def test_left_8b(dut):
    """ Test rotate right """
    signals = Signals(dut.din8, dut.shift8, dut.dout8l)
    for din in range(0, (1<<8)-1):
        for shift in range(0, 7):
            await tester(dut, signals, 8, rotate_left, din, shift)

@cocotb.test()
async def test_right_12b(dut):
    """ Test rotate right """
    signals = Signals(dut.din12, dut.shift12, dut.dout12r)
    for din in range(0, (1<<12)-1):
        for shift in range(0, 11):
            await tester(dut, signals, 12, rotate_right, din, shift)

@cocotb.test()
async def test_left_12b(dut):
    """ Test rotate right """
    signals = Signals(dut.din12, dut.shift12, dut.dout12l)
    for din in range(0, (1<<12)-1):
        for shift in range(0, 11):
            await tester(dut, signals, 12, rotate_left, din, shift)