
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge,FallingEdge
from enum import IntEnum
import random

DATA_WIDTH = 8

class pshpopcodes(IntEnum):
    nothing = 0 
    push = 1 
    pop = 2 

class ShiftRegisterStack:

    def reset(self):
        self.data = [0] * self.stack_size
        self.count = 0

    def update(self, code: pshpopcodes, data_in: int):
        if(self.count >= self.stack_size-1):
            full = 1
        else:
            full = 0
            if(code == pshpopcodes.push):
                self.count += 1
                for i in range(self.stack_size-1, 0, -1):
                    self.data[i] = self.data[i-1]
                self.data[0] = data_in
            elif(code == pshpopcodes.pop):
                self.count -= 2
                self.data[0] = data_in
                for i in range(1, self.stack_size-2):
                    self.data[i] = self.data[i+2]

        if(self.count < 0):
            self.count = 0

        return(self.data[0], self.data[1], full)
        
    def __init__(self, stack_size: int):
        self.stack_size = stack_size
        self.reset()

def generate_command() -> tuple[pshpopcodes, int]:
    code = pshpopcodes.nothing
    if random.random() > 0.3:
        code = pshpopcodes.push
    elif random.random() > 0.1:
        code = pshpopcodes.pop
    data_in = random.randrange(1 << 32)

    return (code, data_in)



@cocotb.test()
async def test_shift_register_stack(dut):
    stack_size = int(dut.STACK_SIZE.value)
    reference_device = ShiftRegisterStack(stack_size)

    # Start a 10 ns clock
    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )
    dut.rst.value = 1 
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    dut.rst.value = 0

    full_previous = 0

    for _ in range(10000):
        (code, data_in) = generate_command()
        (a, b, full) = reference_device.update(code, data_in)
        print(f"{code}, {data_in}")
        print(reference_device.data[:10])
        print(reference_device.data[-10:])
        dut.data_i.value = data_in
        dut.pshpop.value = code
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        assert a == int(dut.data_a.value)
        assert b == int(dut.data_b.value)
        assert full == dut.ful.value
        assert reference_device.count == int(dut.count.value)
        if(full and full_previous):
            dut.rst.value = 1 
            await RisingEdge(dut.clk)
            await FallingEdge(dut.clk)
            dut.rst.value = 0
            reference_device.reset()

        full_previous = full
