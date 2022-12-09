def touching(a, b):
  return max(abs(a[0] - b[0]), abs(a[1] - b[1])) <= 1

with open('input.txt') as f:
  positions = [(0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0), (0, 0)]
  visited = {positions[-1]}
  for line in map(str.strip, f.readlines()):
    parts = line.split(' ')
    dir = parts[0]
    for ii in range(0, int(parts[1])):
      head = positions[0]
      if dir == 'U': positions[0] = (head[0], head[1] - 1)
      elif dir == 'D': positions[0] = (head[0], head[1] + 1)
      elif dir == 'L': positions[0] = (head[0] - 1, head[1])
      else: positions[0] = (head[0] + 1, head[1])
      for jj in range(1, len(positions)):
        prev = positions[jj - 1]
        while not touching(prev, positions[jj]):
          if prev[0] > positions[jj][0]: positions[jj] = (positions[jj][0] + 1, positions[jj][1])
          elif prev[0] < positions[jj][0]: positions[jj] = (positions[jj][0] - 1, positions[jj][1])
          if prev[1] > positions[jj][1]: positions[jj] = (positions[jj][0], positions[jj][1] + 1)
          elif prev[1] < positions[jj][1]: positions[jj] = (positions[jj][0], positions[jj][1] - 1)
      visited.add(positions[-1])
  print(len(visited))
