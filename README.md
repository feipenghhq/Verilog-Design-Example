# Verilog Design Example

[TOC]

## Introduction

This repository contains various design blocks written in SystemVerilog.

The topic of the design blocks are chosen based on the book **Advanced Chip Design Practical Examples in Verilog** since I am reading the book right now.



## Tools

- **cocotb**: https://www.cocotb.org/

  - testbench is written in cocotb.

- **yosys**: https://github.com/YosysHQ/yosys

  - Synthesis tools used to synthesis the design

  - Standard cell library used in synthesis is downloaded here: <http://www.vlsitechnology.org/synopsys/vsclib013.lib>




## Topics

### Digital Design Building Blocks

- Linear Feedback Shift Register (LFSR)
- Scrambler
  - Parallel LFSR generation
- Error Correction code (ECC)
  - Hamming Code

- Cyclic Redundancy Check (CRC)

## Repo structure

```txt
├── doc				# some documents/notes/references for this topic
├── rtl				# rtl collateral
├── scripts		# contains software models of the algorithm or scripts to generate some rtl code
├── syn       # synthesis collateral
└── tb				# testbench collateral

```

