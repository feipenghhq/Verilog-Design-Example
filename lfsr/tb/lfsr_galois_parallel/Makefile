# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

GIT_ROOT = $(shell git rev-parse --show-toplevel)
VERILOG_SOURCES += $(GIT_ROOT)/lfsr/rtl/lfsr_galois_parallel.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = lfsr_galois_parallel

# MODULE is the basename of the Python test file
MODULE = lfsr_galois_parallel_test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim