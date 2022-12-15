def parse_coord(string):
  parts = string.split()
  return (int(parts[-2][2:-1]), int(parts[-1][2:]))

def manhattan_distance(a, b):
  return abs(a[0] - b[0]) + abs(a[1] - b[1])

class Sensor:
  def __init__(self, string):
    parts = string.split(':')
    self.coord = parse_coord(parts[0])
    self.beacon_coord = parse_coord(parts[1])
    self.distance = manhattan_distance(self.coord, self.beacon_coord)

with open('input.txt') as f:
  sensors = list(map(Sensor, f.readlines()))
  max_coord = 4000000
  for yy in range(0, max_coord + 1):
    endpoints = []
    for sensor in sensors:
      width = 1 + 2 * (sensor.distance - abs(sensor.coord[1] - yy))
      if width > 0:
        endpoints.append((max(0, sensor.coord[0] - width // 2), True))
        endpoints.append((min(sensor.coord[0] + width // 2, max_coord), False))
    endpoints.sort()
    xx = -1
    range_count = 0
    for endpoint in endpoints:
      if endpoint[1]:
        if range_count == 0 and xx < endpoint[0] - 1:
          print((xx + 1) * 4000000 + yy)
          exit()
        range_count += 1
      else:
        range_count -= 1
      xx = endpoint[0]
    if xx < max_coord:
      print(max_coord * 4000000 + yy)
      exit()
  