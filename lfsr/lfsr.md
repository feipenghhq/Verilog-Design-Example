# Linear Feedback Shift Register

[TOC]

## Introduction

There are two types of LFSR circuits: Fibonacci LFSR and Galois LFSR.

### Polynomials Specification

> From: <https://en.wikipedia.org/wiki/Cyclic_redundancy_check#Specification>

There are three common ways to express a polynomial as an integer: the  first two, which are mirror images in binary, are the constants found in code; the third is the number found in Koopman's papers.  *In each case, one term is omitted.* So the polynomial                            x<sup>4</sup> + x + 1 may be transcribed as:

- 0x3 = 0b0011, representing x<sup>4</sup> + (0x<sup>3</sup> + 0x<sup>2</sup> + 1x<sup>1</sup> + 1x<sup>0</sup>) (MSB-first code)
- 0xC = 0b1100, representing (1x<sup>0</sup> + 1x<sup>1</sup> + 0x<sup>2</sup> + 0x<sup>3</sup>) + x<sup>4</sup> (LSB-first code)
- 0x9 = 0b1001, representing (1x<sup>4</sup> + (0x<sup>3</sup> + 0x<sup>2</sup> + 1x<sup>1</sup>) + x<sup>0</sup> (Koopman notation)

In the table below they are shown as:

| Name  | Normal | Reversed | Reversed reciprocal |
| ----- | ------ | -------- | ------------------- |
| CRC-4 | 0x3    | 0xC      | 0x9                 |

In our design, we will use the **normal** representation.

### Fibonacci LFSR

> From: <https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Fibonacci_LFSRs>

The bit positions that affect the next state are called the taps. In the diagram the taps are [16,14,13,11]. The rightmost bit of the LFSR is called the output bit. The taps are XOR'd sequentially with the output bit and then fed back into the leftmost bit. The sequence of bits in the rightmost position is called the output stream.

```txt
                        shift direction                                  din
                        <--------------                                   |
    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+     |
    | 16| 15| 14| 13| 12| 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |<---(+)
    +-+-+---+-+-+-+-+---+-+-+---+---+---+---+---+---+---+---+---+---+     |
      |       |   |       |                                               |
      |       |   |       |                                               |
     (+)-----(+)-(+)-----(+)---------------------------------------------->
```

- The bits in the LFSR state that influence the input are called *taps*.

The arrangement of taps for feedback in an LFSR can be expressed in [finite field arithmetic](https://en.wikipedia.org/wiki/Finite_field_arithmetic) as a [polynomial](https://en.wikipedia.org/wiki/Polynomial) [mod](https://en.wikipedia.org/wiki/Modular_arithmetic) 2. This means that the coefficients of the polynomial must be 1s or 0s. This is called the feedback polynomial or reciprocal characteristic  polynomial. For example, if the taps are at the 16th, 14th, 13th and  11th bits (as shown), the feedback polynomial is

![{\displaystyle x^{16}+x^{14}+x^{13}+x^{11}+1.}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e2635c901f8dd49ffa7a57b3b659fbf866972738)

The "one" in the polynomial does not correspond to a tap – it corresponds to the input to the first bit (i.e. *x*0, which is equivalent to 1). The powers of the terms represent the tapped bits, counting from the left. The first and last bits are always  connected as an input and output tap respectively.

### Galois LFSR

> From: <https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Galois_LFSRs>

```txt
                                            shift direction
      din                                    ------------->
       |
       |    +---+---+      +---+      +---+---+      +---+---+---+---+---+---+---+---+---+---+---+
      (+)-->| 16| 15|-(+)->| 14|-(+)->| 13| 12|-(+)->| 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
       |    +---+---+  |   +---+  |   +---+---+  |   +---+---+---+---+---+---+---+---+---+---+---+
       |               |          |              |                                             |
       |               |          |              |                                             |
       <---------------<----------<--------------<---------------------------------------------+


```

In the Galois configuration, when the system is clocked, bits that are  not taps are shifted one position to the right unchanged. The taps, on  the other hand, are XOR-ed with the output bit before they are stored in  the next position.

The new output bit is the next input bit. The effect of this is that  when the output bit is zero, all the bits in the register shift to the  right unchanged, and the input bit becomes zero. When the output bit is  one, the bits in the tap positions all flip, and then the entire register is  shifted to the right and the input bit becomes 1.

To generate the same output stream, the order of the taps is the *counterpart* (see above) of the order for the conventional LFSR, otherwise the  stream will be in reverse. Note that the internal state of the LFSR is  not necessarily the same.

## Design

In this repository , I designed 3 LFSR RTL files and a python script to generate parallel using XOR structure.

| File                    | Description                                                          |
| ----------------------- | -------------------------------------------------------------------- |
| rtl/lfsr_fib_s.sv       | Serial Fibonacci LFSR                                                |
| rtl/lfsr_galois_s.sv    | Serial galois LFSR                                                   |
| rtl/lfsr_galois_p.sv    | Parallel galois LFSR                                                 |
| scripts/ParallelLFSR.py | A python script to generate parallel galois LFSR using XOR structure |

## Reference

1. wikipedia: <https://en.wikipedia.org/wiki/Linear-feedback_shift_register#>
2. Xilinx IEEE 802.3 Cyclic Redundancy Check <https://docs.xilinx.com/v/u/en-US/xapp209>
3. https://inst.eecs.berkeley.edu//~cs150/sp03/handouts/15/LectureA/lec27-6up
