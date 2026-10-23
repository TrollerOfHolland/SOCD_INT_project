# Author: Lars Gortemaker

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
from rpn_calc import RPN_Calculator


def gen_number():
    return random.randrange(99)


def generate_input() -> str:
    weighted_options = [(0, 0.6), (1, 0.38), (2, 0.02)]
    choices, weights = list(map(list, zip(*weighted_options)))
    code = random.choices(choices, weights=weights)[0]
    match code:
        case 0:
            return str(gen_number()) + "E"
        case 1:
            return random.choice(["+", "*"])
        case 2:
            return chr(random.randrange(100))
        case _:
            raise Exception("This should not happen")  # noqa: TRY002


def generate_rpn_expr():
    length = random.randrange(50)
    expr = ""
    for _ in range(length):
        add = generate_input()
        if expr and expr[-1] == "E" and (add == "*" or add == "+"):
            expr = expr[:-1] + " " + add
        else:
            expr += " " + add
    return expr


async def reset_dut(dut):
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    dut.reset.value = 0


@cocotb.test()
async def test_rpn(dut):
    stack_size = int(dut.STACK_SIZE.value)
    data_width = int(dut.DATA_WIDTH.value)
    reference_rpn = RPN_Calculator(stack_size, data_width)

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    for _ in range(1000):
        expr = generate_rpn_expr()
        print(expr)
        for e in expr:
            dut.data_in.value = ord(e)
            reference_rpn.update(ord(e))
            await RisingEdge(dut.clk)
            await FallingEdge(dut.clk)
            print(
                f"IN: {e} FULL: {reference_rpn.stack.full} COUNT: {reference_rpn.stack.count}"
            )
            print(reference_rpn.stack.data[:10])

            assert reference_rpn.stack.count == int(
                dut.shift_register_stack_inst.count.value
            )
            assert reference_rpn.stack.full == int(
                dut.shift_register_stack_inst.ful.value
            )
            assert reference_rpn.stack.data[0] == int(dut.data_out.value)

            if reference_rpn.stack.full:
                await reset_dut(dut)
                reference_rpn.stack.reset()
