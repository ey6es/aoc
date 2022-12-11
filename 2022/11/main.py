class Monkey:
  total_product = 1
  def __init__(self, lines):
    self.items = list(map(int, next(lines).split(':')[1].split(',')))
    op = next(lines).split()
    if op[-1] == 'old': getter = lambda x: x
    else:
      value = int(op[-1])
      getter = lambda x: value
    if op[-2] == '+': self.func = lambda x: x + getter(x)
    else: self.func = lambda x: x * getter(x)
    self.divisor = int(next(lines).split()[-1])
    Monkey.total_product *= self.divisor
    self.true_monkey = int(next(lines).split()[-1])
    self.false_monkey = int(next(lines).split()[-1])
    self.total_inspections = 0
    next(lines, False)
  def receive(self, worry_level):
    self.items.append(worry_level)
  def act(self, monkeys):
    for worry_level in self.items:
      self.total_inspections += 1
      new_worry_level = self.func(worry_level) % Monkey.total_product
      monkeys[self.true_monkey if new_worry_level % self.divisor == 0 else self.false_monkey].receive(new_worry_level)
    self.items.clear()

with open('input.txt') as f:
  lines = map(str.strip, f.readlines())
  monkeys = []
  while next(lines, False): monkeys.append(Monkey(lines))  
  for ii in range(0, 10000):
    for monkey in monkeys: monkey.act(monkeys)
  monkeys.sort(key = lambda monkey: monkey.total_inspections, reverse = True)
  print(monkeys[0].total_inspections * monkeys[1].total_inspections)