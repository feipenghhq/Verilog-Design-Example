# Cyclic Redundancy Check (CRC)

[TOC]

## Introduction

Read wikipedia for more details regarding CRC

<https://en.wikipedia.org/wiki/Cyclic_redundancy_check>



### Polynomials Specification

there are three common ways to express a polynomial as an integer: the  first two, which are mirror images in binary, are the constants found in code; the third is the number found in Koopman's papers.  *In each case, one term is omitted.* So the polynomial                            x<sup>4</sup> + x + 1 may be transcribed as:

- 0x3 = 0b0011, representing x<sup>4</sup> + (0x<sup>3</sup> + 0x<sup>2</sup> + 1x<sup>1</sup> + 1x<sup>0</sup>) (MSB-first code)
- 0xC = 0b1100, representing (1x<sup>4</sup> + 1x<sup>1</sup> + 0x<sup>2</sup> + 0x<sup>3</sup>) + x<sup>4</sup> (LSB-first code)
- 0x9 = 0b1001, representing (1x<sup>4</sup> + (0x<sup>3</sup> + 0x<sup>2</sup> + 1x<sup>1</sup>) + x<sup>0</sup> (Koopman notation)

In the table below they are shown as:

| Name  | Normal | Reversed | Reversed reciprocal |
| ----- | ------ | -------- | ------------------- |
| CRC-4 | 0x3    | 0xC      | 0x9                 |

## Serial CRC Calculation

Read wikipedia for more details regarding serial crc calculation

https://en.wikipedia.org/wiki/Computation_of_cyclic_redundancy_checks

### CRC generation

This is the algorithm used in my design

- The incoming data is XOR-ed with the initial values of the polynomial. If the data length is larger then the polynomial, then the   upper bits are XOR-ed with the initial values of the polynomials. 

- Then the data is loaded into the LFSR as the initial value. The rest of the data that are not loaded into the LFSR will be shifted into the LFSR each clock cycle.

- If term x^n is part of the polynomial, then the output of the corresponding flop is XOR-ed with the MSB before going into next level. If the term is not part of the polynomial then the output of the corresponding flop is going to the next level directly without XOR.
- When the last bit is shifted into the LFSR, then the calculation is done and the bit in LFSR register is the CRC value of the data.

### CRC checks

CRC checkers receives the data and the checksum, and it performs the same operation as the CRC generation, but it use the data and the received CRC checksum (instead of the initial value of the CRC). After all the bits are shifted, if the result of the LFSR is zero, then there is no error, otherwise, there is error during the transmission. 



## Parallel CRC Calculation



## Other useful reference

http://www.zlib.net/crc_v3.txt

https://reveng.sourceforge.io/crc-catalogue/all.htm

http://users.ece.cmu.edu/~koopman/pubs/KoopmanCRCWebinar9May2012.pdf

http://www.sunshine2k.de/articles/coding/crc/understanding_crc.html