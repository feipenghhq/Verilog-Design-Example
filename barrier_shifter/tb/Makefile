# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

GIT_ROOT = $(shell git rev-parse --show-toplevel)

VERILOG_SOURCES += $(GIT_ROOT)/barrier_shifter/rtl/barrier_shifter.sv
VERILOG_SOURCES += $(GIT_ROOT)/barrier_shifter/tb/tb.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim