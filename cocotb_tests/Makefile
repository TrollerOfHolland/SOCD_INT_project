TOPLEVEL_LANG = vhdl
SIM = ghdl

.PHONY: test_stack

test_stack:
	$(MAKE) sim SIM=ghdl TOPLEVEL_LANG=vhdl TOPLEVEL=shift_register_stack MODULE=test_shift_register_stack VHDL_SOURCES=$(PWD)/../shift_register_stack.vhd

VHDL_SOURCES = $(PWD)/../shift_register_stack.vhd

include $(shell cocotb-config --makefiles)/Makefile.sim