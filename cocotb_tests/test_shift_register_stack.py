import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
from rpn_calc import ShiftRegisterStack, stack_code

DATA_WIDTH = 8


def generate_command() -> tuple[stack_code, int]:
    weighted_options = [
        (stack_code.push, 0.5),
        (stack_code.nothing, 0.05),
        (stack_code.pop, 0.1),
        (stack_code.replace_top, 0.35),
    ]
    choices, weights = list(map(list, zip(*weighted_options)))
    code = random.choices(choices, weights=weights)[0]

    data_in = random.randrange(1 << 32)

    return (code, data_in)


@cocotb.test()
async def test_shift_register_stack(dut):
    stack_size = int(dut.STACK_SIZE.value)
    reference_device = ShiftRegisterStack(stack_size)

    # Start a 10 ns clock
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    dut.rst.value = 0

    force_pop_all = False

    for _ in range(10000):
        if reference_device.data[1] == 0:
            force_pop_all = False

        if force_pop_all:
            (code, data_in) = (stack_code.pop, random.randrange(1 << 32))
        else:
            (code, data_in) = generate_command()
        (a, b, full) = reference_device.update(code, data_in)

        dut.data_i.value = data_in
        dut.pshpop.value = code
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        print(f"{code}, {dut.ful.value}")
        print(f"{code}, {full}")
        print(reference_device.data[:10])
        print(reference_device.data[-10:])
        print()
        assert a == int(dut.data_a.value)
        assert b == int(dut.data_b.value)
        assert full == dut.ful.value
        assert reference_device.count == int(dut.count.value)
        # if(full and full_previous):
        #     if(random.random() > 0.3):
        #         force_pop_all = True
        #     else:
        #         dut.rst.value = 1
        #         await RisingEdge(dut.clk)
        #         await FallingEdge(dut.clk)
        #         dut.rst.value = 0
        #         reference_device.reset()

        full_previous = full
