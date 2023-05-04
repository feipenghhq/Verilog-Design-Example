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

def arbiter_model(req, width):
    """ Arbiter. Lower bit has higher priority"""
    for i in range(width):
        bit = (req >> i) & 0x1
        if bit:
            return (1 << i)
    return 0

########################################
# Test functions
########################################

async def tester(dut, req):
    dut.req.value = req
    await Timer(1, "ns")
    grant = dut.grant.value.integer
    expected_grant = arbiter_model(req, 8)
    error_msg = f"req = {bin(req)}, grant = {bin(grant)}, expected grant = {bin(expected_grant)}"
    assert grant == expected_grant, dut._log.error(error_msg)

@cocotb.test()
async def test_arbiter(dut):
    for i in range(0, 1 << 8):
        await tester(dut, i)
