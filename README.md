# Verilog Design Example

[TOC]

## Introduction

This repository contains various design written in SystemVerilog.

The topics of the design are chosen based on the book: **Advanced Chip Design Practical Examples in Verilog**.

## Tools/Prerequisite

- **icarus verilog**: <https://steveicarus.github.io/iverilog/>
  - Verilog Simulation tool

- **cocotb**: https://www.cocotb.org/
  - testbench is written in cocotb.

- **yosys**: https://github.com/YosysHQ/yosys
  - Synthesis tools used to synthesis the design

  - Standard cell library used in synthesis is downloaded here: <http://www.vlsitechnology.org/synopsys/vsclib013.lib>

## Topics

### Digital Design Building Blocks

- Linear Feedback Shift Register (LFSR)
- Scrambler
- Error Correction code (ECC)
  - Hamming Code
- Cyclic Redundancy Check (CRC)
- Line Code
  - 8b/10b encoder

## Repo structure

```txt
├── doc         # some documents/notes/references for this topic
├── rtl         # rtl collateral
├── scripts     # contains software models of the algorithm or scripts to generate some rtl code
├── syn         # synthesis collateral
└── tb          # testbench collateral
```

