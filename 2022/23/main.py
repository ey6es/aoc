elves = set()

with open('input.txt') as f:
  lines = list(map(str.strip, f.readlines()))
  for row in range(0, len(lines)):
    line = lines[row]
    for col in range(0, len(line)):
      if line[col] == '#': elves.add((row, col))

offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
sides = [(0, 1), (0, 1), (1, 0), (1, 0)]

def any_adjacent(pos):
  for row in range(-1, 2):
    for col in range(-1, 2):
      if (row != 0 or col != 0) and (pos[0] + row, pos[1] + col) in elves: return True
  return False

for ii in range(0, 999999999999):
  dests = {}
  for elf in elves:
    if not any_adjacent(elf): continue
    for jj in range(0, 4):
      dir = (ii + jj) % 4
      offset = offsets[dir]
      pos = (elf[0] + offset[0], elf[1] + offset[1])
      if pos not in elves:
        side = sides[dir]
        if (pos[0] + side[0], pos[1] + side[1]) not in elves and (pos[0] - side[0], pos[1] - side[1]) not in elves:
          if pos in dests: dests[pos] = None
          else: dests[pos] = elf
          break
  any_moved = False
  for dest, src in dests.items():
    if src != None:
      elves.remove(src)
      elves.add(dest)
      any_moved = True
  if not any_moved:
    print(ii + 1)
    break
