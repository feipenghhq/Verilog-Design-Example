# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

GIT_ROOT = $(shell git rev-parse --show-toplevel)
VERILOG_SOURCES += $(GIT_ROOT)/lfsr/rtl/lfsr_fibonacci.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = lfsr_fibonacci

# MODULE is the basename of the Python test file
MODULE = lfsr_test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim