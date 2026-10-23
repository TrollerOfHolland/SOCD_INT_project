# Author: Lars Gortemaker

TOPLEVEL_LANG = vhdl
SIM = ghdl

.PHONY: test_stack

test_stack:
	$(MAKE) sim SIM=ghdl TOPLEVEL_LANG=vhdl TOPLEVEL=shift_register_stack MODULE=test_shift_register_stack

test_calc:
	$(MAKE) sim SIM=ghdl TOPLEVEL_LANG=vhdl TOPLEVEL=siso_gen MODULE=test_rpn


VHDL_SOURCES = $(PWD)/../*.vhd

include $(shell cocotb-config --makefiles)/Makefile.sim