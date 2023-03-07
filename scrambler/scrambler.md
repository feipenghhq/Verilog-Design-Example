# Scrambling/De-scrambling

This design is in Chapter 6 - 6.2 Scrambling/De-scrambling

[TOC]

## Introduction

https://en.wikipedia.org/wiki/Scrambler

Scrambling is an operation where a serial bit stream is changed to produce a randomized serial bit scream.

Scrambling is done by using LFSR to produce a pseduo random sequence of bit stream and then doing an XOR operation with the serial data.

Later in the receiver side, the received data is XORed with another LFSR to register to restore the original data.

In this achievable due to the following equation:

```
If A ^ B = C, then A = C ^ B
```

### Scrambling Serial Data

To scramble a serial, in each clock cycle, the serial data is XOR-ed with the last bit of the LFSR register.

### Scrambling Parallel Data

In real design, the data comes in parallel so we need to be able to scramble parallel data in the same clock cycle.

To scramble a parallel data with W width, we need to construct a "parallel" LFSR that can "advance" W cycles at a single clock cycle. Imagine the LFSR is running W time faster then the parallel data and during the W clock period, the corresponding bit of the parallel data is XOR-ed with the last bit of the LFSR.



## Scrambler Control

### Initialize Scramble

PCIe use a character called COM character that the transmitter and the receiver use to initialize the LFSR flops to a known agreed values. The COM character is sent periodically to synchronize the scrambler and de-scrambler periodically.

### Pausing the Scramble

The LFSR advances to a new value each clock cycle but it should be able to pause and not advance when pause signal is asserted.

In PCIe, some symbol such as SKIP is not scrambled so we need to be able to pause the scrambler when we send/receive skip symbol.

### Disabling the Scramble

Scramble should have the capability to not scramble a data but still advance the LFSR flops.

For example in PCIe, training sets (TS1/TS2) are not scramble but the LFSR keeps advancing.



## Parallel LFSR Generator

The following paper describe the parallel LFSR implementation for Fibonacci LFSR.

[Implementation of Parallel LFSR for BIST](http://rcvt.tu-sofia.bg/ICEST2013_1_42.pdf)

(This paper can also be found in doc folder)

Based on the idea of this article, we can define an algorithm to generate parallel LFSR for the Galois LFSR with right shift operation.

### Difference between the LFSR in wikipedia and PCIe

There are some difference between to LFSR that defined in wikipedia:

![img](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/LFSR-G16.svg/393px-LFSR-G16.svg.png)

(x^16 + x^14+x^13+x^11+1)

And the PCIe Spec:

![image-20230305220523707](/home/feipenghhq/.config/Typora/typora-user-images/image-20230305220523707.png)

(x^16+x^5+x^4+x^3+1)

Here are the differences:

1. wikipedia shift right with MSb on the left and LSb on the right, while PCIe shift right with LSb on the left and MSb on the right.
2. wikipedia start the bit from bit 1 to bit 16 while PCIe start the bit from bit 0 to bit 15. But they both tap on the bit indicated by the polynomial. For example, polynomial for PCIe is x^16+x^5+x^4+x^3+1 and it tap on bit 3, 4 and 5 even its bit is starting from bit 0 instead of bit 1

### Algorithm to calculate parallel LFSR

Here is the algorithm to calculate parallel LFSR using the format defined in wikipedia, assume the polynomial we are using is 
$$
x^5 + x^3 + 1.
$$
And assume that the starting/initial state is Q<sup>0</sup> and the next state is Q<sup>1</sup>
$$
Q^0 = {Q^0_5 Q^0_4 Q^0_3 Q^0_2 Q^0_1} \\
Q^1 = {Q^1_5 Q^1_4 Q^1_3 Q^1_2 Q^1_1}
$$
So we have the following equation.
$$
Q^1 = A * Q^0
$$
A is a 5 x 5 matrix (For N degree polynomial it will be an N x N matrix). And here * is similar to regular matrix multiplication but we don't "add" each item together, instead, we XOR each item together.

If we assume that there is no shift meaning Q<sup>1</sup> == Q<sup>0</sup>, then 
$$
A = 
 \begin{pmatrix}
  1 & 0 & 0 & 0 & 0 \\
  0 & 1 & 0 & 0 & 0 \\
  0 & 0 & 1 & 0 & 0 \\
  0 & 0 & 0 & 1 & 0 \\
  0 & 0 & 0 & 0 & 1 \\
 \end{pmatrix}
$$
Now if we shift it by one clock cycle **without** any XOR, we got 
$$
Q^1 = 
\begin{pmatrix}
  Q^1_5 \\
  Q^1_4 \\
  Q^1_3 \\
  Q^1_2 \\
  Q^1_1 \\
\end{pmatrix} =
 \begin{pmatrix}
  0 & 0 & 0 & 0 & 1 \\
  1 & 0 & 0 & 0 & 0 \\
  0 & 1 & 0 & 0 & 0 \\
  0 & 0 & 1 & 0 & 0 \\
  0 & 0 & 0 & 1 & 0 \\
 \end{pmatrix} *
 \begin{pmatrix}
  Q^0_5 \\
  Q^0_4 \\
  Q^0_3 \\
  Q^0_2 \\
  Q^0_1 \\
\end{pmatrix} =
 \begin{pmatrix}
  Q^0_1 \\
  Q^0_5 \\
  Q^0_4 \\
  Q^0_3 \\
  Q^0_2 \\
 \end{pmatrix}
$$
Now taking the XOR into effect, then
$$
Q^1_3 = Q^0_1 \oplus Q^0_4
$$
This is similar to have an matrix operation of
$$
Q^1_3 =  
 \begin{pmatrix}
0 & 0 & 0 & 1 & 0 & 1
 \end{pmatrix} * 
 \begin{pmatrix}
  Q^0_5 \\
  Q^0_4 \\
  Q^0_3 \\
  Q^0_2 \\
  Q^0_1 \\
 \end{pmatrix} = Q^0_1 \oplus Q^0_4
$$
So Now, our matrix A and the equation become
$$
Q^1 = 
\begin{pmatrix}
  Q^1_5 \\
  Q^1_4 \\
  Q^1_3 \\
  Q^1_2 \\
  Q^1_1 \\
\end{pmatrix} =
 \begin{pmatrix}
  0 & 0 & 0 & 0 & 1 \\
  1 & 0 & 0 & 0 & 0 \\
  0 & 1 & 0 & 0 & 1 \\
  0 & 0 & 1 & 0 & 0 \\
  0 & 0 & 0 & 1 & 0 \\
 \end{pmatrix} *
 \begin{pmatrix}
  Q^0_5 \\
  Q^0_4 \\
  Q^0_3 \\
  Q^0_2 \\
  Q^0_1 \\
\end{pmatrix} =
 \begin{pmatrix}
  Q^0_1 \\
  Q^0_5 \\
  Q^0_1 \oplus Q^0_4 \\
  Q^0_3 \\
  Q^0_2 \\
 \end{pmatrix}
$$


Here we can deduct the matrix A to be like this. Assume that we have the following polynomial
$$
x^n + c_{n-1}x^{n-1} + ... + c_2x^ 2 + c_1x^1 + 1.
$$
Our matrix A is 
$$
A_{N, N} = 
 \begin{pmatrix}
  0 & 0 & \dots & 0 & 0 & 1 \\
  1 & 0 & \dots & 0 & 0 & c_{n-1} \\
  0 & 1 & \dots & 0 & 0 & c_{n-2} \\
  \vdots \\
  0 & 0 & \dots & 1 & 0 & c_2 \\
  0 & 0 & \dots & 0 & 1 & c_1 \\
 \end{pmatrix}
$$
Now to get the Nth LFSR value:
$$
Q^n = A * Q^{n-1} = A * A * Q^{n-2} = A^2 * Q^{n-2} = \dots = A^n * Q^0
$$
Here the operation of `A * A` is similar to regular matrix multiplication but we don't "add" each item together, instead, we XOR each item together. 

So for the final result of A<sup>n</sup>, for each lines, if the 1 is set in corresponding position then that bit is part of the final xor equation.

For example, in our previous example
$$
Q^5 = Q^0
$$
So we have the following equation

```verilog
LFSR_next[0] = LFSR[];
LFSR_next[1] = LFSR[];
LFSR_next[2] = LFSR[];
LFSR_next[3] = LFSR[];
```

