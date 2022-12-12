import heapq

def manhattan_distance(a, b):
  return abs(a[0] - b[0]) + abs(a[1] - b[1])

def get_min_distance(heights, start):
  fringe = [(manhattan_distance(start, end), 0, start)]
  visited = set()
  while len(fringe) > 0:
    least_item = heapq.heappop(fringe)
    pos = least_item[2]
    if pos == end:
      return least_item[1]
    for offset in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
      next = (pos[0] + offset[0], pos[1] + offset[1])
      if next[0] >= 0 and next[1] >= 0 and next[0] < len(heights) and next[1] < len(heights[next[0]]) and \
          (not next in visited) and heights[next[0]][next[1]] - heights[pos[0]][pos[1]] <= 1:
        visited.add(next)
        heapq.heappush(fringe, (least_item[1] + 1 + manhattan_distance(next, end), least_item[1] + 1, next))
  return 99999999999
  
with open('input.txt') as f:
  lines = list(map(str.strip, f.readlines()))
  heights = []
  starts = []
  for row in range(0, len(lines)):
    line = lines[row]
    row_heights = []
    for col in range(0, len(line)):
      if line[col] == 'S' or line[col] == 'a':
        starts.append((row, col))
        row_heights.append(0)
      elif line[col] == 'E':
        end = (row, col)
        row_heights.append(25)
      else:
        row_heights.append(ord(line[col]) - ord('a'))
    heights.append(row_heights)
  print(min(map(lambda start: get_min_distance(heights, start), starts)))