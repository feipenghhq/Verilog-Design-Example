#!/usr/bin/python3
# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/06/2023
# ------------------------------------------------------------------------------------------------
# A Serial LFSR model for Galois LFSR
# We assume that the registers start at 1 and shift towards right with LSb on the right
# Similar to this format: https://en.wikipedia.org/wiki/File:LFSR-G16.svg
# ------------------------------------------------------------------------------------------------

class SerialLFSR():

    def __init__(self, width, taps, initVal):
        self.width = width
        self.taps = taps
        self.initVal = initVal
        self.lfsr_reg = self.initVal

    def advance(self):
        """ Advance the lfsr by one clock cycle """
        # log the lsb
        lsb = self.lfsr_reg & 0x1
        # the msb is also taken care here because of the xor-ing.
        self.lfsr_reg >>= 1
        if lsb:
            self.lfsr_reg ^= self.taps

    def next_n_value(self, n):
        """
        Return the next value of the parallel LFSR
        Effectively the same as advancing the serial LFSR by # of n cycle
        """
        for _ in range(n):
            self.advance()
        return self.lfsr_reg



def test_SerialLFSR_1():
    lfsr = SerialLFSR(16, 0xB400, 0xACE1)
    data = lfsr.next_n_value(4)
    print(hex(data))
    assert data == 0x1c4e

def test_SerialLFSR_2():
    lfsr = SerialLFSR(5, 0x14, 0x1F)
    data = lfsr.next_n_value(1)
    print(hex(data))

if __name__ == "__main__":
    test_SerialLFSR_1()
    test_SerialLFSR_2()