with open('input.txt') as f:
  stacks = []
  reading_stacks = True
  for line in f.readlines():
    stripped = line.strip()
    if reading_stacks:
      if len(stripped) == 0:
        reading_stacks = False
      else:
        for ii in range(1, len(line), 4):
          ch = line[ii]
          if ch.isalpha():
            idx = (ii - 1) // 4
            while len(stacks) <= idx: stacks.append([])
            stacks[idx].insert(0, ch)
    else:
      values = stripped.split()
      count = int(values[1])
      src = int(values[3]) - 1
      dest = int(values[5]) - 1
      stacks[dest].extend(stacks[src][-count:])
      del stacks[src][-count:]
  print(''.join(map(lambda s: s[-1], stacks)))