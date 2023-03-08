#!/usr/bin/python3
# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/07/2023
# ------------------------------------------------------------------------------------------------
# A parallel LFSR model for Galois LFSR with PCIe specification structure
# We assume that the registers start at 0 and shift towards right with LSb on the left
# Read scrambler.md session [Difference between the LFSR in wikipedia and PCIe]
# to understand the structure of the LFSR for PCIe specification
# ------------------------------------------------------------------------------------------------

from ParallelLFSR import ParallelLFSR

#############################################
# Common functions
#############################################

def reverse_bit(num, width):
    """
        Reverse bit of a number
        @param num: number to reverse
        @param width: width of the number
    """
    mask = (1 << width) - 1
    num_masked = num & mask
    result = 0
    for i in range(width):
        result |= (num_masked & 0x1) << (width-i-1)
        num_masked >>= 1
    return result

#############################################
# ParallelLFSR_PCIe Class
#############################################

# We can still reuse most of the algorithms in the ParallelLFSR
# class. We just need to convert the polynomial defined for the PCIe structure to
# the one that's defined in ParallelLFSR and then revert the bit in verilog code generation.

class ParallelLFSR_PCIe(ParallelLFSR):

    def __init__(self, data_width, lfsr_width, polynomial, init_val = 0):
        # Reverse each bits except for the msb
        self.converted_polynomial = reverse_bit(polynomial, lfsr_width-1) | 0x1 << (lfsr_width-1)
        # Reverse each bits
        self.converted_init_val = reverse_bit(init_val, lfsr_width)
        super().__init__(data_width, lfsr_width, self.converted_polynomial, self.converted_init_val)

    def gen_verilog_code(self, next_name="lfsr_next", current_name="lfsr_current"):
        return super().gen_verilog_code(next_name, current_name, True)

#############################################
# Test
#############################################

def test_init():
    lfsr_pcie = ParallelLFSR_PCIe(1, 7, 0x56, 0x56)
    assert lfsr_pcie.converted_polynomial == 0x5a
    assert lfsr_pcie.converted_init_val == 0x35
    #print(hex(lfsr_pcie.converted_polynomial))
    #print(hex(lfsr_pcie.converted_init_val))

def test_pcie():
    lfsr_pcie = ParallelLFSR_PCIe(8, 16, 0x801C, 0xFFFF)
    print(hex(lfsr_pcie.converted_polynomial))
    print(hex(lfsr_pcie.converted_init_val))

def test_next_n(n, lfsr_width, polynomial, init_val, print_matrix=False, print_verilog=False):
    print(f"Test: polynomial = {hex(polynomial)} init val = {hex(init_val)}, n = {n}")
    # parallel lfsr
    lfsr_p = ParallelLFSR_PCIe(n, lfsr_width, polynomial, init_val)
    next_val = lfsr_p.cal_next_lfsr_value()
    #print(f"Result: {hex(next_val)}")
    if print_matrix:
        print("Final transfer matrix:")
        print(lfsr_p.final_transfer_matrix)
    if print_verilog:
        print("Verilog code:")
        print(lfsr_p.gen_verilog_code())

if __name__ == "__main__":
    assert(reverse_bit(6, 3)) == 3
    assert(reverse_bit(8, 4)) == 1

    test_init()
    test_pcie()

    test_next_n(8, 16, 0x801C, 0xFFFF, True, True)

