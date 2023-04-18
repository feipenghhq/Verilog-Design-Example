GIT_ROOT = $(shell git rev-parse --show-toplevel)
VERILOG_SOURCES += $(GIT_ROOT)/synchronization/rtl/async_handshake.sv
VERILOG_SOURCES += $(GIT_ROOT)/synchronization/tb/async_handshake/tb.sv

run: compile
	./async_handshake

compile: $(VERILOG_SOURCES)
	iverilog -g2005-sv -o async_handshake -s tb $(VERILOG_SOURCES)

clean:
	rm async_handshake