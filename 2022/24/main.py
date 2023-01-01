import heapq
import math

neighbors = [(-1, 0), (0, -1), (0, 0), (0, 1), (1, 0)]

with open('input.txt') as f:
  lines = list(map(str.strip, f.readlines()))
  height = len(lines) - 2
  width = len(lines[0]) - 2
  rights = set()
  lefts = set()
  ups = set()
  downs = set()
  for row in range(0, height):
    for col in range(0, width):
      ch = lines[row + 1][col + 1]
      if ch == '>': rights.add((row, col))
      elif ch == '<': lefts.add((row, col))
      elif ch == '^': ups.add((row, col))
      elif ch == 'v': downs.add((row, col))
  start_pos = (-1, 0)
  end_pos = (height, width - 1)
  time = 0
  goals = [end_pos, start_pos, end_pos]
  points = {start_pos}
  while True:
    time += 1
    next_points = set()
    for point in points:
      for row_offset, col_offset in neighbors:
        next_row = point[0] + row_offset
        next_col = point[1] + col_offset
        next_point = (next_row, next_col)
        if next_point == start_pos or next_point == end_pos or \
           next_row >= 0 and next_row < height and next_col >= 0 and next_col < width and \
           (next_row, (next_col - time) % width) not in rights and \
           (next_row, (next_col + time) % width) not in lefts and \
           ((next_row + time) % height, next_col) not in ups and \
           ((next_row - time) % height, next_col) not in downs:
          next_points.add(next_point)
    if goals[-1] in next_points:
      points = {goals.pop()}
      if len(goals) == 0:
        print(time)
        break
      continue
    points = next_points
  