# Linear Feedback Shift Register

This design is in Chapter 6 - 6.1 LFSR (Linear Feedback Shift Register)

[TOC]

## Introduction

LFSR is used to produce repeatable pseudo-random bit pattern. The random patterns are also called PRBS (Pseudo Random Bit sequence Pattern).

There are two types of LFSR circuits - Fibonacci LFSR and Galois LFSR.



## Fibonacci and Galois LFSR

From wikipedia: [Linear-feedback_shift_register](https://en.wikipedia.org/wiki/Linear-feedback_shift_register)

Polynomial:

![{\displaystyle x^{16}+x^{14}+x^{13}+x^{11}+1.}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e2635c901f8dd49ffa7a57b3b659fbf866972738)

Fibonacci LFSR

![img](https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/LFSR-F16.svg/351px-LFSR-F16.svg.png)

Galois LFSR

![img](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/LFSR-G16.svg/393px-LFSR-G16.svg.png)