# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/07/2023
# ------------------------------------------------------------------------------------------------
# Testbench for scrambler
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

COM = 0xBC
SKIP = 0x1C

async def check_data_scrambled(dut, data, dis=0):
    # wait 1 clock cycles for the latency
    await FallingEdge(dut.clk)
    if not dis:
        assert dut.scm_dout.value.integer != data, \
        dut._log.error(f"Data should not be scrambled: Original data: {hex(data)}, Scrambled data: {hex(dut.scm_dout.value.integer)}")
        dut._log.info(f"Data Scrambled. Original data: {hex(data)}, Scrambled data: {hex(dut.scm_dout.value.integer)}")
    else:
        assert dut.scm_dout.value.integer == data, \
        dut._log.error(f"Data should be scrambled: Original data: {hex(data)}, Scrambled data: {hex(dut.scm_dout.value.integer)}")
        dut._log.info(f"Data not Scrambled. Original data: {hex(data)}, Scrambled data: {hex(dut.scm_dout.value.integer)}")

async def check_data(dut, expected):
    # wait 2 clock cycles for the latency
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert (dut.descm_dout.value.integer == expected), \
    dut._log.error(f"Expected: {hex(expected)}. Get: {hex(dut.descm_dout.value.integer)}")
    dut._log.info(f"Check passed: Get data: {hex(expected)}")

async def send_cmd(dut, cmd):
    await FallingEdge(dut.clk)
    dut.din.value = cmd
    dut.k_in.value = 1
    dut.dis_scrambler.value = 0
    cocotb.start_soon(check_data_scrambled(dut, cmd, 1))
    cocotb.start_soon(check_data(dut, cmd))

async def send_data(dut, data, dis=0):
    await FallingEdge(dut.clk)
    dut.din.value = data
    dut.k_in.value = 0
    dut.dis_scrambler.value = dis
    cocotb.start_soon(check_data_scrambled(dut, data, dis))
    cocotb.start_soon(check_data(dut, data))

@cocotb.test()
async def test_scrambler(dut):
    dut.din.value = 0
    dut.k_in.value = 0
    dut.dis_scrambler.value = 0

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_b.value = 0
    await Timer(20, units="ns")
    dut.rst_b.value = 1

    # First few COM command
    await send_cmd(dut, COM)
    await send_cmd(dut, COM)
    await send_cmd(dut, COM)
    # Sent few data with scrambler enabled
    await send_data(dut, 0x12)
    await send_data(dut, 0x34)
    await send_data(dut, 0x00)
    await send_data(dut, 0xFF)
    # Sent few data without scrambler enabled
    await send_data(dut, 0x56, 1)
    await send_data(dut, 0x78, 1)
    # Send skip command
    await send_cmd(dut, SKIP)
    await send_cmd(dut, SKIP)
    await Timer(100, "ns")

