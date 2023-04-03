# Cyclic Redundancy Check (CRC)

[TOC]

## Introduction

Read wikipedia for more details regarding CRC: <https://en.wikipedia.org/wiki/Cyclic_redundancy_check>

### Polynomials Specification

> From wikipedia: <https://en.wikipedia.org/wiki/Cyclic_redundancy_check#Specification>

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

Use the following CRC as an example

```txt
CRC-8: x^8 + x^2 + x + 1
Poly: 0x07
```

#### Algorithm #1

LFSR structure

```txt
                            shift direction
                            <--------------
      +---+---+---+---+---+---+      +---+      +---+             +------+
      | 8 | 7 | 6 | 5 | 4 | 3 |<-(+)-| 2 |<-(+)-| 1 |<----(+)<----| data |
      +---+---+---+---+---+---+   |  +---+   |  +---+      |      +------+
        |                         |          |             |
        |                         |          |             |
        +-------------------------+----------+------------->
```



- **The incoming data is XOR-ed with the initial values of the polynomial**. If the data length is larger then the polynomial, then the upper portion are XOR-ed with the initial values of the polynomials. 

- Then the XOR-ed data is loaded into the LFSR as the initial value. The rest of the data that are not loaded into the LFSR will be shifted into the LFSR each clock cycle. If there is no more data left, then shift 0 into LFSR.

- Following the LFSR structure, shift the LFSR and the remaining data for N cycle. (N is the size of data bits.)
- When the shifting is done, the bits in LFSR register represent the CRC value of the data.

#### Algorithm #2

LFSR structure

```txt
                            shift direction
                            <--------------
                                                                  +------+
        >------------------------------------------------>(+)<----| data |
        |                                                  |      +------+
        |                         +----------+-------------|
        |                         |          |             |
      +---+---+---+---+---+---+   |  +---+   |  +---+      |
      | 8 | 7 | 6 | 5 | 4 | 3 |<-(+)-| 2 |<-(+)-| 1 |<-----+
      +---+---+---+---+---+---+      +---+      +---+
```

* The initial value of the polynomial is loaded in the the LFSR register, and the incoming data is stored in the data register.

* In each clock cycle, the MSB of the LFSR is XOR-ed with the MSB of the data, and this bit is loaded into LSB. The output of the tapped bit is XOR-ed with this XOR-ed bit before shifting into next position.

* Following the LFSR structure, shift the LFSR and the data for N cycle till the all the data is shifted into the LFSR. (N is the size of data bits.)

* When the shifting is done, the bits in LFSR register represent the CRC value of the data.

  

### CRC checks

CRC checkers receives the data and the checksum, and it performs the same operation as the CRC generation, but it use the data and the received CRC checksum (instead of the initial value of the CRC). After all the bits are shifted, if the result of the LFSR is zero, then there is no error, otherwise, there is error during the transmission. 

Or we can recalculate the CRC based on the received data and compare that if the CRC calculated is the same as the CRC we received.



## Parallel CRC Calculation

For parallel CRC calculation, we "unroll" the xor calculation N times to get the final result in the same cycle.

## Design

| Files            | Description                       |
| ---------------- | --------------------------------- |
| rtl/crc_gen_s.sv | CRC generator using serial LFSR   |
| rtl/crc_gen_p.sv | CRC generator using parallel LFSR |

## Other useful reference

http://www.zlib.net/crc_v3.txt

https://reveng.sourceforge.io/crc-catalogue/all.htm

http://users.ece.cmu.edu/~koopman/pubs/KoopmanCRCWebinar9May2012.pdf

http://www.sunshine2k.de/articles/coding/crc/understanding_crc.html