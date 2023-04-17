GIT_ROOT = $(shell git rev-parse --show-toplevel)
VERILOG_SOURCES += $(GIT_ROOT)/synchronization/rtl/async_pulse_sync.sv
VERILOG_SOURCES += $(GIT_ROOT)/synchronization/tb/async_pulse_sync/tb.sv

run: compile
	./async_pulse_sync

compile: $(VERILOG_SOURCES)
	iverilog -g2005-sv -o async_pulse_sync -s tb $(VERILOG_SOURCES)

clean:
	rm async_pulse_sync