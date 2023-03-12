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

from random import randint

async def encoder(dut, data):
    dut.din.value = data
    await Timer(10, "ns")
    codeword = dut.codeword.value.integer
    codeword74 = dut.codeword_74.value.integer
    extra_parity = dut.extra_parity_74.value.integer
    extra_parity74 = dut.extra_parity.value.integer
    dut._log.info("---------------------------------------")
    dut._log.info(f"data = {hex(data)}, codeword       = {hex(codeword)}, extra_parity       = {extra_parity}")
    dut._log.info(f"data = {hex(data)}, codeword (7,4) = {hex(codeword74)}, extra_parity (7,4) = {extra_parity74}")
    # make sure the 2 encode generate the same result
    assert (codeword == codeword74) and (extra_parity == extra_parity74), "ERROR: codeword or extra parity does not match"

async def decoder(dut, data, flip1=False, flip1_pos=0, flip2=False, flip2_pos=0):

    # encode the data
    dut.din.value = data
    await Timer(10, "ns")

    # get the codeword from encoder and feed into the decoder
    # flip the bit if necessary
    mask1 = 1 << flip1_pos if flip1 else 0
    mask2 = 1 << flip2_pos if flip2 else 0
    codeword = dut.codeword.value.integer ^ mask1 ^ mask2
    extra_parity = dut.extra_parity_74.value.integer
    dut.dec_codeword.value = codeword
    dut.dec_extra_parity.value = extra_parity
    await Timer(10, "ns")

    # get the data from the decoder
    dec_dout_74 = dut.dec_dout_74.value.integer
    dec_error_single_bit_74 = dut.dec_error_single_bit_74.value.integer
    dec_error_double_bit_74 = dut.dec_error_double_bit_74.value.integer
    syndrome_74 = dut.syndrome_74.value.integer

    dec_dout = dut.dec_dout.value.integer
    dec_error_single_bit = dut.dec_error_single_bit.value.integer
    dec_error_double_bit = dut.dec_error_double_bit.value.integer
    syndrome = dut.syndrome.value.integer

    # print out messages
    dut._log.info("---------------------------------------")
    dut._log.info(f"data = {hex(data)}, codeword = {hex(dut.codeword.value.integer)}")
    if flip1:
        dut._log.info(f"flip position 1: {flip1_pos}")
    if flip2:
        dut._log.info(f"flip position 2: {flip2_pos}")
    if flip1 or flip2:
        dut._log.info(f"flipped codeword: {hex(codeword)}")

    dut._log.info(f"decoded data = {hex(dec_dout_74)}, single flip: {dec_error_single_bit_74}, double flip: {dec_error_double_bit_74}, syndrome: {hex(syndrome_74)}")

    # assertion to check 2 design match
    assert dec_dout == dec_dout_74
    assert dec_error_single_bit == dec_error_single_bit_74
    assert dec_error_double_bit == dec_error_double_bit_74
    assert syndrome == syndrome_74

    # assertion to check error
    if not flip1 and not flip2:
        assert (data == dec_dout_74), "ERROR: get wrong data"
        assert (syndrome_74 == 0), "ERROR: syndrome should be zero when no error happen"

    if flip1 and not flip2:
        assert (data == dec_dout_74), "ERROR: data should be corrected"
        assert (syndrome_74 != 0), "ERROR: syndrome should NOT be zero when 1 bit is flipped"

    if flip1 and not flip2:
        assert (syndrome_74 != 0), "ERROR: syndrome should NOT be zero when 2 bit is flipped"

@cocotb.test()
async def test_hamming_encoder(dut):
    if 1:
        dut._log.info("\n\n============== Test (7,4) Hamming encoder ==============\n\n")
        for i in range(7):
            await encoder(dut, i)
        await Timer(20, "ns")

@cocotb.test()
async def test_hamming_decoder_no_error(dut):
    if 1:
        dut._log.info("\n\n============== Test (7,4) Hamming decoder, no error injection ==============\n\n")
        for i in range(7):
            await decoder(dut, i)
        await Timer(20, "ns")

@cocotb.test()
async def test_hamming_decoder_1b_error(dut):
    if 1:
        dut._log.info("\n\n============== Test (7,4) Hamming decoder, 1 bit error injection ==============\n\n")
        for i in range(7):
            for j in range(7):
                await decoder(dut, i, True, j)
        await Timer(20, "ns")

@cocotb.test()
async def test_hamming_decoder_2b_error(dut):
    if 1:
        dut._log.info("\n\n============== Test (7,4) Hamming decoder, 2 bit error injection ==============\n\n")
        for i in range(7):
            for j in range(7):
                for k in range(7):
                    if j != k:
                        await decoder(dut, i, True, j, True, k)
        await Timer(20, "ns")
