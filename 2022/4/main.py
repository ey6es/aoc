class Assignment:
  def __init__(self, string):
    parts = list(map(int, string.split('-')))
    self.min = parts[0]
    self.max = parts[1]

  def contains (self, other):
    return other.min >= self.min and other.max <= self.max

  def overlaps (self, other):
    return other.max >= self.min and other.min <= self.max

with open('input.txt') as f:
  total = 0
  for line in map(str.strip, f.readlines()):
    assignments = list(map(Assignment, line.split(',')))
    if assignments[0].overlaps(assignments[1]):
      total += 1
  print(total)
