#!/usr/bin/python3
# ------------------------------------------------------------------------------------------------
# Copyright 2023 by Heqing Huang (feipenghhq@gamil.com)
# ------------------------------------------------------------------------------------------------
# Author: Heqing Huang
# Date Created: 03/06/2023
# ------------------------------------------------------------------------------------------------
# A parallel LFSR model for Galois LFSR
# We assume that the registers start at 1 and shift towards right with LSb on the right
# Similar to this format: https://en.wikipedia.org/wiki/File:LFSR-G16.svg
# Read scrambler.md for more details on the algorithm.
# ------------------------------------------------------------------------------------------------

import numpy
from SerialLFSR import SerialLFSR

#############################################
# Common functions
#############################################

def dec_to_bin_array(value):
    """ Convert an value to binary array """
    return [int(i) for i in list('{0:0b}'.format(value))]

def bin_array_to_dec(value):
    """ Convert an binary array to dec number """
    return int("".join(str(x) for x in value), 2)

def matrix_mult(matrix1, matrix2):
    size = len(matrix1)
    result = numpy.zeros(shape=(size,size), dtype=int)
    for i in range(size):
        for j in range(size):
            for k in range(size):
                result[i][j] = result[i][j] | matrix1[i][k] & matrix2[k][j]
    return result

#############################################
# ParallelLFSR class
#############################################

class ParallelLFSR():

    def __init__(self, data_width, lfsr_width, polynomial, init_val = 0):
        self.data_width = data_width
        self.lfsr_width = lfsr_width
        self.polynomial = polynomial
        self.init_val = init_val
        self.init_val_bin = dec_to_bin_array(init_val)

        self.gen_transfer_matrix()
        self.cal_final_transfer_matrix()

    def gen_transfer_matrix(self):
        """
        Generate the transfer matrix
        1:                  [0 0 ... 0 0 1]        [Qn]
        2:                  [1 0 ... 0 0 Cn-1]     [Qn-1]
        3:                  [0 1 ... 0 0 Cn-2]     [Qn-2]
        .                         .                 .
        .       Q_next =          .            X    .
        .                         .                 .
        n-1:                [0 0 ... 1 0 C2]       [Q2]
        n:                  [0 0 ... 0 1 C1]       [Q1]
        """
        width = self.lfsr_width
        self.transfer_matrix = numpy.zeros(shape=(width,width), dtype=int)

        # Transfer matrix without xor-ing feedback
        self.transfer_matrix[0][width-1] = 1
        for i in range(1, width):
                self.transfer_matrix[i][i-1] = 1
        # Transfer matrix after considering the xor-ing feedback
        # Here msb (Qn) is at the beginning so lsb (Q1) in at the end of the row
        for i in range(0, width-1):
            self.transfer_matrix[width-1-i][width-1] = \
                self.transfer_matrix[width-1-i][width-1] | ((self.polynomial >> i) & 0x1)

    def cal_final_transfer_matrix(self):
        self.final_transfer_matrix = self.transfer_matrix
        for i in range(self.data_width-1):
            self.final_transfer_matrix = matrix_mult(self.transfer_matrix, self.final_transfer_matrix)

    def cal_next_lfsr_value(self):
        next_lfsr_bin = [0 for _ in range(self.lfsr_width)]
        for i in range(self.lfsr_width):
            for j in range(self.lfsr_width):
                if self.final_transfer_matrix[i][j]:
                    next_lfsr_bin[i] = next_lfsr_bin[i] ^ self.init_val_bin[j]
        next_lfsr = bin_array_to_dec(next_lfsr_bin)
        return next_lfsr

    def gen_verilog_code(self, next_name="lfsr_next", current_name="lfsr_current", reverse=False):
        verilog = ""
        # MSb of the LFSR is in bit 0 of our array
        for i in range(self.lfsr_width):
            if reverse:
                idx = i
            else:
                idx = (self.lfsr_width-i-1)
            verilog += f"{next_name}[{idx}] = "
            previous = False
            for j in range(self.lfsr_width):
                if self.final_transfer_matrix[i][j]:
                    if previous:
                        verilog += " ^ "
                    else:
                        previous = True
                    if reverse:
                        idx = j
                    else:
                        idx = self.lfsr_width-j-1
                    verilog += f"{current_name}[{idx}]"
            verilog += ";\n"
        return verilog

#############################################
# test functions
#############################################

def test_matrix_gen():
    lfsr = ParallelLFSR(4, 5, 0x14, 0xFF)
    lfsr.gen_transfer_matrix()
    print(lfsr.transfer_matrix)

def test_next_n(n, lfsr_width, polynomial, init_val, print_matrix=False, print_verilog=False):
    print(f"Test: polynomial = {hex(polynomial)} init val = {hex(init_val)}, n = {n}")
    # parallel lfsr
    lfsr_p = ParallelLFSR(n, lfsr_width, polynomial, init_val)
    next_val = lfsr_p.cal_next_lfsr_value()
    # serial lfsr
    lfsr = SerialLFSR(lfsr_width, polynomial, init_val)
    exp = lfsr.next_n_value(n)
    assert next_val == exp, print(f"Expected: {hex(exp)}, got: {hex(next_val)}")
    print(f"Result: {hex(exp)}")
    if print_matrix:
        print(lfsr_p.final_transfer_matrix)
    if print_verilog:
        print(lfsr_p.gen_verilog_code())

def test_next_one(lfsr_width, polynomial, init_val):
    test_next_n(1, lfsr_width, polynomial, init_val)

if __name__ == '__main__':

    test_next_one(5, 0x14, 0x1F)
    test_next_one(16, 0xB400, 0xACE1)

    test_next_n(2, 5, 0x14, 0x1F)
    test_next_n(3, 5, 0x14, 0x1F)
    test_next_n(2, 16, 0xB400, 0xACE1)
    test_next_n(3, 16, 0xB400, 0xACE1)
    test_next_n(8, 16, 0xB400, 0xACE1, True, True)