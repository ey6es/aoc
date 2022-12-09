with open('input.txt') as f:
  data = list(map(str.strip, f.readlines()))
  max_product = 0
  for row in range(0, len(data)):
    for col in range(0, len(data[row])):
      height = data[row][col]
      left_distance = 0
      for prev_col in range(col - 1, -1, -1):
        left_distance += 1
        if data[row][prev_col] >= height: break
      right_distance = 0
      for next_col in range(col + 1, len(data[row])):
        right_distance += 1
        if data[row][next_col] >= height: break
      up_distance = 0
      for prev_row in range(row - 1, -1, -1):
        up_distance += 1
        if data[prev_row][col] >= height: break
      down_distance = 0
      for next_row in range(row + 1, len(data)):
        down_distance += 1
        if data[next_row][col] >= height: break
      max_product = max(left_distance * right_distance * up_distance * down_distance, max_product)
  print(max_product)
  