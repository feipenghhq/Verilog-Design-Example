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

########################################
# Test functions
########################################

async def tester(dut, req, base):
    dut.req.value = req
    dut.base.value = base
    await Timer(1, "ns")
    grant = dut.grant.value.integer
    expected_grant = arbiter_model(req, base, 8)
    error_msg = f"req = {bin(req)}, grant = {bin(grant)}, expected grant = {bin(expected_grant)}"
    assert grant == expected_grant, dut._log.error(error_msg)

@cocotb.test()
async def test_arbiter(dut):
    for i in range(0, 1 << 8,):
        for j in range(0, 7):
            await tester(dut, i, 1 << j)
