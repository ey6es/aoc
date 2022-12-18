occupied = set()

min_pos = None
max_pos = None

with open('input.txt') as f:
  for line in map(str.strip, f.readlines()):
    parts = line.split(',')
    pos = (int(parts[0]), int(parts[1]), int(parts[2]))
    occupied.add(pos)
    if min_pos == None:
      min_pos = max_pos = pos
    else:
      min_pos = (min(min_pos[0], pos[0]), min(min_pos[1], pos[1]), min(min_pos[2], pos[2]))
      max_pos = (max(max_pos[0], pos[0]), max(max_pos[1], pos[1]), max(max_pos[2], pos[2]))

offsets = [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]

def add(a, b):
  return (a[0] + b[0], a[1] + b[1], a[2] + b[2])

min_pos = add(min_pos, (-1, -1, -1))
max_pos = add(max_pos, (1, 1, 1))

outside = set()

class Node:
  def __init__(self, pos):
    self.pos = pos
    self.next = None

def fill(start_pos):
  first = last = Node(start_pos)
  while first != None:
    pos = first.pos
    first = first.next
    if first == None: last = None
    if pos[0] < min_pos[0] or pos[1] < min_pos[1] or pos[2] < min_pos[2] or \
      pos[0] > max_pos[0] or pos[1] > max_pos[1] or pos[2] > max_pos[2] or \
      pos in occupied or pos in outside: continue
    outside.add(pos)
    for offset in offsets:
      new_node = Node(add(pos, offset))
      if last == None:
        first = last = new_node
      else:
        last.next = Node(add(pos, offset))
        last = last.next

fill(min_pos)

sides = 0

for pos in occupied:
  for offset in offsets:
    if add(pos, offset) in outside: sides += 1

print(sides)
