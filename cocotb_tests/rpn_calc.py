# Author: Lars Gortemaker
from enum import IntEnum


class stack_code(IntEnum):
    nothing = 0
    push = 1
    pop = 2
    replace_top = 3


class ShiftRegisterStack:
    def reset(self):
        self.data = [0] * self.stack_size
        self.count = 0
        self.full = 0

    def update(self, code: stack_code, data_in: int):

        match code:
            case stack_code.replace_top:
                if self.count == 0:
                    self.count = 1
                self.data[0] = data_in
            case stack_code.pop:
                self.full = 0
                if self.count > 1:
                    self.count -= 1
                self.data[0] = data_in
                for i in range(1, self.stack_size - 1):
                    self.data[i] = self.data[i + 1]
                self.data[self.stack_size - 1] = 0
            case stack_code.push:
                if not self.full:
                    self.count += 1
                    for i in range(self.stack_size - 1, 0, -1):
                        self.data[i] = self.data[i - 1]
                    self.data[0] = data_in
        self.full = int(self.count >= self.stack_size)

        return (self.data[0], self.data[1], self.full)

    def __init__(self, stack_size: int):
        self.full = 0
        self.stack_size = stack_size
        self.reset()


class RPN_Calculator:
    def update(self, ascii_code):
        MASK = (1 << self.data_width) - 1
        if ascii_code >= 48 and ascii_code < 58:
            if self.did_operation:
                self.stack.update(stack_code.push, int(ascii_code - 48))
            else:
                stack_top = self.stack.data[0]
                number = (int(ascii_code - 48) + stack_top * 10) & MASK
                self.stack.update(stack_code.replace_top, number)
            self.did_operation = False
        if ascii_code == 69:  # E
            self.did_operation = True
        if ascii_code == 42:  # *
            result = self.stack.data[0] * self.stack.data[1] & MASK
            self.stack.update(stack_code.pop, result)
            self.did_operation = True
        if ascii_code == 43:  # +
            result = self.stack.data[0] + self.stack.data[1] & MASK
            self.stack.update(stack_code.pop, result)
            self.did_operation = True

    def update_expr(self, expr):
        for e in expr:
            self.update(ord(e))

    def __init__(self, stack_size, data_width):
        self.data_width = data_width
        self.stack = ShiftRegisterStack(stack_size)
        self.did_operation = False


if __name__ == "__main__":
    calc = RPN_Calculator(10, 32)
    while True:
        string_in = input("Provide an input: ")
        for e in string_in:
            if e == "!":
                exit()
            print(f"Parsing: {e}")
            calc.update(ord(e))
            print(f"Result: {calc.stack.data[:10]}")
