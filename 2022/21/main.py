monkeys = {}

class Literal:
  def __init__(self, value):
    self.value = value
  def execute(self):
    return (self.value, False)

class BinaryOp:
  def __init__(self, a, b):
    self.a = a
    self.b = b
  def execute(self):
    self.a_result = monkeys[self.a].execute()
    self.b_result = monkeys[self.b].execute()
    return (self.op(self.a_result[0], self.b_result[0]), self.a_result[1] or self.b_result[1])
  def correct(self, value):
    if self.a_result[1]:
      return monkeys[self.a].correct(self.correct_a(value, self.b_result[0]))
    else:
      return monkeys[self.b].correct(self.correct_b(value, self.a_result[0]))
  def correct_b(self, value, a):
    return self.correct_a(value, a)

class Add(BinaryOp):
  def op(self, a, b):
    return a + b
  def correct_a(self, value, b):
    return value - b

class Sub(BinaryOp):
  def op(self, a, b):
    return a - b
  def correct_a(self, value, b):
    return value + b
  def correct_b(self, value, a):
    return a - value

class Mul(BinaryOp):
  def op(self, a, b):
    return a * b
  def correct_a(self, value, b):
    return value // b

class Div(BinaryOp):
  def op(self, a, b):
    return a // b
  def correct_a(self, value, b):
    return b * value
  def correct_b(self, value, a):
    return a // value

class Root(BinaryOp):
  def execute(self):
    a_result = monkeys[self.a].execute()
    b_result = monkeys[self.b].execute()
    if a_result[1]: return monkeys[self.a].correct(b_result[0])
    else: return monkeys[self.b].correct(a_result[0])

class You:
  def execute(self):
    return (1, True)
  def correct(self, value):
    return value

with open('input.txt') as f:
  for line in f.readlines():
    parts = line.split()
    name = parts[0][:-1]
    if name == 'humn': monkeys[name] = You()
    elif len(parts) == 2: monkeys[name] = Literal(int(parts[1]))
    elif name == 'root': monkeys[name] = Root(parts[1], parts[3])
    elif parts[2] == '+': monkeys[name] = Add(parts[1], parts[3])
    elif parts[2] == '-': monkeys[name] = Sub(parts[1], parts[3])
    elif parts[2] == '*': monkeys[name] = Mul(parts[1], parts[3])
    else: monkeys[name] = Div(parts[1], parts[3])

print(monkeys['root'].execute())
