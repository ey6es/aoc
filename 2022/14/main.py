with open('input.txt') as f:
  data = {}
  lowest_platform = 0
  for line in map(str.strip, f.readlines()):
    last_coord = None
    for entry in line.split(' -> '):
      components = entry.split(',')
      target_coord = (int(components[0]), int(components[1]))
      if last_coord != None:
        delta = (0, 0)
        if target_coord[0] > last_coord[0]: delta = (1, 0)
        elif target_coord[0] < last_coord[0]: delta = (-1, 0)
        elif target_coord[1] > last_coord[1]: delta = (0, 1)
        else: delta = (0, -1)
        coord = last_coord
        while coord != (target_coord[0] + delta[0], target_coord[1] + delta[1]):
          data[coord] = '#'
          lowest_platform = max(coord[1], lowest_platform)
          coord = (coord[0] + delta[0], coord[1] + delta[1])
      last_coord = target_coord
  bottom = lowest_platform + 2
  grain_count = 0
  start = (500, 0)
  while not start in data:
    coord = start
    while True:
      if coord[1] + 1 < bottom:
        below = (coord[0], coord[1] + 1)
        if not below in data:
          coord = below
          continue
        below_left = (coord[0] - 1, coord[1] + 1)
        if not below_left in data:
          coord = below_left
          continue
        below_right = (coord[0] + 1, coord[1] + 1)
        if not below_right in data:
          coord = below_right
          continue
      data[coord] = 'o'
      grain_count += 1
      break
  print(grain_count)
  
