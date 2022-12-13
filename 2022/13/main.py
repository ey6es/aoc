import functools

def parse(string, pos):
  start = pos[0]
  pos[0] += 1
  if string[start] == '[':
    elements = []
    while string[pos[0]] != ']':
      elements.append(parse(string, pos))
      if string[pos[0]] == ',': pos[0] += 1
    pos[0] += 1
    return elements
  else:
    while string[pos[0]].isdigit(): pos[0] += 1
    return int(string[start:pos[0]])

def compare(a, b):
  if isinstance(a, list):
    if isinstance(b, list):
      for ii in range(0, min(len(a), len(b))):
        result = compare(a[ii], b[ii])
        if result != 0: return result
      if len(a) < len(b): return -1
      elif len(a) > len(b): return 1
      else: return 0
    else:
      return compare(a, [b])
  else:
    if isinstance(b, list):
      return compare([a], b)
    else:
      if a < b: return -1
      elif a > b: return 1
      else: return 0

with open('input.txt') as f:
  first_divider = [[2]]
  second_divider = [[6]]
  packets = [first_divider, second_divider]
  while True:
    packets.append(parse(f.readline(), [0]))
    packets.append(parse(f.readline(), [0]))
    if f.readline() == '': break
  packets.sort(key=functools.cmp_to_key(compare))
  print((packets.index(first_divider) + 1) * (packets.index(second_divider) + 1))