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

def dec_to_bin_array(value):
    """ Convert an value to binary array """
    return [int(i) for i in list('{0:0b}'.format(value))]

def bin_array_to_dec(value):
    """ Convert an binary array to dec number """
    return int("".join(str(x) for x in value), 2)

def matrix_mult(matrix1, matrix2):
    size = len(matrix1)
    result = numpy.zeros(shape=(width,width), dtype=int)
    for i in range(size):
        for j in range(size):
            for k in range(size):
                pass

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

    def cal_next_lfsr_value(self):
        next_lfsr_bin = [0 for _ in range(self.lfsr_width)]
        for i in range(self.lfsr_width):
            for j in range(self.lfsr_width):
                if self.final_transfer_matrix[i][j]:
                    next_lfsr_bin[i] = next_lfsr_bin[i] ^ self.init_val_bin[j]
        next_lfsr = bin_array_to_dec(next_lfsr_bin)
        return next_lfsr


def test_matrix_gen():
    lfsr = ParallelLFSR(4, 5, 0x14, 0xFF)
    lfsr.gen_transfer_matrix()
    print(lfsr.transfer_matrix)

def test_next_one():
    # parallel lfsr
    lfsr_p = ParallelLFSR(4, 5, 0x14, 0x1F)
    next_val = lfsr_p.cal_next_lfsr_value()
    print(hex(next_val))
    # serial lfsr
    lfsr = SerialLFSR(5, 0x14, 0x1F)
    data = lfsr.next_n_value(1)
    print(hex(data))
    assert next_val == data



if __name__ == '__main__':
    test_matrix_gen()
    test_next_one()



#print(parallel_lfsr_gen(4, 5, 0x14))
#print(parallel_lfsr_gen(8, 16, 0x801C))