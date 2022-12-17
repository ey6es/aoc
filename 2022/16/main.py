valves = []
nonzero_valves = []
dists = []

class Valve:
  def __init__(self, rate, dests):
    self.rate = rate
    self.dests = dests

cache = {}

all_nonzero_flags = 0
all_released = 0

def get_max_released(poses, flags = 0, remainings = [26, 26]):
  max_released = 0
  index = 0 if remainings[0] >= remainings[1] else 1
  for ii in range(0, len(nonzero_valves)):
    flag = 1 << ii
    if flags & flag == 0:
      next_pos = nonzero_valves[ii]
      next_remaining = remainings[index] - (1 + dists[poses[index]][next_pos])
      if next_remaining <= 0: continue
      released = valves[next_pos].rate * next_remaining
      next_poses = poses.copy()
      next_remainings = remainings.copy()
      next_poses[index] = next_pos
      next_remainings[index] = next_remaining
      max_released = max(max_released, released + get_max_released(next_poses, flags | flag, next_remainings))
  return max_released

with open('input.txt') as f:
  index = 0
  indices = {}
  for parts in map(str.split, f.readlines()):
    source = parts[1]
    rate = int(parts[4][5:-1])
    dests = []
    for ii in range(9, len(parts) - 1):
      dests.append(parts[ii][0:-1])
    dests.append(parts[len(parts) - 1])
    valves.append(Valve(rate, dests))
    indices[source] = index
    if rate > 0: nonzero_valves.append(index)
    all_released += rate
    index += 1
  all_nonzero_flags = (1 << len(nonzero_valves)) - 1
  for valve in valves:
    valve.dests = list(map(lambda n: indices[n], valve.dests))

for ii in range(0, len(valves)):
  row = []
  for jj in range(0, len(valves)):
    if ii == jj: row.append(0)
    elif valves[ii].dests.count(jj) > 0: row.append(1)
    else: row.append(None)
  dists.append(row)
for ii in range(0, len(valves)):
  for jj in range(0, len(valves)):
    for kk in range(0, len(valves)):
      for ll in range(0, len(valves)):
        d0 = dists[jj][ll]
        d1 = dists[ll][kk]
        if d0 != None and d1 != None:
          total = d0 + d1
          current = dists[jj][kk]
          if current == None or total < current:
            dists[jj][kk] = total

start = indices['AA']
print(get_max_released([start, start]))
