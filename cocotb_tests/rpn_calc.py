from test_shift_register_stack import ShiftRegisterStack, stack_code


class RPN_Calculator: 

    def update(self, ascii_code):
        MASK = (1 << self.data_width) - 1
        if(ascii_code >= 48 and ascii_code < 58):
          if(self.did_operation):
            self.stack.update(stack_code.push, int(ascii_code-48))
          else:
            stack_top = self.stack.data[0]
            number = (int(ascii_code-48) + stack_top * 10) & MASK
            self.stack.update(stack_code.replace_top, number)
          self.did_operation = False
        if(ascii_code == 69):   # E
          self.did_operation = True
        if(ascii_code == 42):   # * 
          result = self.stack.data[0] * self.stack.data[1] & MASK
          self.stack.update(stack_code.pop, result)
          self.did_operation = True
        if(ascii_code == 43):   # +
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
  calc = RPN_Calculator()
  while True:
    string_in = input("Provide an input: ")
    for e in string_in:
      if e == "!":
        exit()
      print(f"Parsing: {e}")
      calc.update(ord(e))
      print(f"Result: {calc.stack.data[:10]}")
