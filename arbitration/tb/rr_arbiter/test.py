# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 05/01/2023
# ------------------------------------------------------------------------------------------------
# Testbench for arbiter
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
import random

WIDTH = 8
MAX_VALUES = (1 << WIDTH) - 1
BASE = 1

def arbiter_model(req, base, width):
    """ Arbiter. base determine the priority"""
    pos = 0
    pos_vld = False
    for i in range(width):
        bit = (req >> i) & 0x1
        if bit and ((1 << i) == base):
            return 1 << i
        if bit and ((1 << i) > base):
            return 1 << i
        if bit and ((1 << i) < base) and not pos_vld:
            pos = i
            pos_vld = True
    if pos_vld:
        return 1 << pos
    else:
        return 0

def rr_arbiter(req):
    global BASE
    grant = arbiter_model(req, BASE, WIDTH)
    BASE = grant << 1 | grant >> (WIDTH-1)
    return grant

########################################
# Test functions
########################################

async def setup(dut):
    dut.req.value = 0
    dut.rst_b.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await Timer(20, units="ns")
    await FallingEdge(dut.clk)
    dut.rst_b.value = 1

async def tester_fixed(dut, step, debug=False):
    await setup(dut)
    await FallingEdge(dut.clk)
    for _ in range(step):
        if debug:
            dut._log.info("Start a new round of arbitration")
        req = random.randint(1, MAX_VALUES)
        while True:
            await FallingEdge(dut.clk)
            dut.req.value = req
            await Timer(2, "ns")
            grant = dut.grant.value.integer
            expected_grant = rr_arbiter(req)
            error_msg = f"req = {bin(req)}, grant = {bin(grant)}, expected grant = {bin(expected_grant)}"
            assert grant == expected_grant, dut._log.error(error_msg)
            good_msg = f"req = {bin(req)}, grant = {bin(grant)}"
            if debug:
                dut._log.info(good_msg)
            req = req & ~grant
            if req == 0:
                break

async def tester_random(dut, step, debug=False):
    await setup(dut)
    await FallingEdge(dut.clk)
    for _ in range(step):
        req = random.randint(1, MAX_VALUES)
        await FallingEdge(dut.clk)
        dut.req.value = req
        await Timer(2, "ns")
        grant = dut.grant.value.integer
        expected_grant = rr_arbiter(req)
        error_msg = f"req = {bin(req)}, grant = {bin(grant)}, expected grant = {bin(expected_grant)}"
        assert grant == expected_grant, dut._log.error(error_msg)
        good_msg = f"req = {bin(req)}, grant = {bin(grant)}"
        if debug:
            dut._log.info(good_msg)


@cocotb.test()
async def test_fixed(dut):
    global BASE
    BASE = 1
    await tester_fixed(dut, 1000, False)

@cocotb.test()
async def test_random(dut):
    global BASE
    BASE = 1
    await tester_random(dut, 10000, False)